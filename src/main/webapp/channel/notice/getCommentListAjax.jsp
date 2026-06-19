<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.CommentDAO" %>
<%@ page import="channel.CommentVO" %>
<%@ page import="member.MemberDAO" %>
<%@ page import="member.MemberVO" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%!
    // 회원 id 기반 고정 아바타 색상 (회원마다 다른 색, 항상 동일 → "무작위처럼" 보이되 DB 불필요)
    static final String[] AV_COLORS = {
        "#6B65C8", "#1D9E75", "#D9803F", "#C0508F",
        "#3F8FD9", "#D94F4F", "#8A6FE0", "#2FA8A8"
    };
    String avatarColor(String s) {
        if (s == null || s.isEmpty()) return AV_COLORS[0];
        int h = 0;
        for (int i = 0; i < s.length(); i++) h = h * 31 + s.charAt(i);
        return AV_COLORS[Math.abs(h) % AV_COLORS.length];
    }
    String initial(String s) {
        if (s == null) return "?";
        String x = s.replaceAll("\\s", "");
        if (x.isEmpty()) return "?";
        return x.substring(0, 1);
    }
%>
<%
    final int PER_PAGE = 10; // 페이지당 댓글 수

    String userId = (String) session.getAttribute("user_id");
    if(userId == null) userId = (String) session.getAttribute("id");

    int message_id = Integer.parseInt(request.getParameter("message_id"));

    // 주의: 'page'는 JSP 내장 객체라 변수명으로 못 씀 → pageNo 사용
    int pageNo = 1;
    String pageParam = request.getParameter("page");
    if(pageParam != null && pageParam.matches("\\d+")) pageNo = Integer.parseInt(pageParam);
    if(pageNo < 1) pageNo = 1;

    CommentDAO cdao = CommentDAO.getInstance();
    int total = cdao.countComments(message_id);
    int totalPages = (total == 0) ? 1 : (int) Math.ceil(total / (double) PER_PAGE);
    if(pageNo > totalPages) pageNo = totalPages; // 마지막 댓글 삭제 등으로 페이지 초과 시 보정

    ArrayList<CommentVO> commentList = cdao.getCommentList(message_id, pageNo, PER_PAGE);

    SimpleDateFormat timeFmt = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<!-- JS가 현재 페이지/총페이지/총개수를 다시 읽어 동기화하기 위한 메타 -->
<div id="cmtMeta" data-page="<%= pageNo %>" data-pages="<%= totalPages %>" data-count="<%= total %>" hidden></div>

<%
    if(total == 0) {
%>
    <div style="text-align:center; padding:30px 16px; color:#A1A1AA; font-size:14px;">첫 댓글을 남겨보세요.</div>
<%
    } else {
        for(CommentVO c : commentList) {
            boolean isMine = (userId != null && userId.equals(c.getUser_id()));

            // 작성자 이름(닉네임) 조회 — 없으면 아이디로 폴백 / 학생만 학번 표기
            String authorName = c.getUser_id();
            boolean authorIsStudent = true;
            try {
                MemberVO author = MemberDAO.getinstance().getMember(c.getUser_id());
                if (author != null) {
                    if (author.getName() != null && !author.getName().trim().isEmpty())
                        authorName = author.getName();
                    authorIsStudent = (author.getRole() != 1);
                }
            } catch (Exception e) {}

            String color = avatarColor(c.getUser_id());
%>
            <div style="display:flex; gap:12px; padding:13px 6px; margin-bottom:4px; border-bottom:1px solid rgba(0,0,0,0.06);">
                <!-- 아바타 -->
                <div style="width:38px; height:38px; flex-shrink:0; border-radius:50%; background:<%= color %>; color:#fff; display:flex; align-items:center; justify-content:center; font-weight:800; font-size:15px;">
                    <%= initial(authorName) %>
                </div>

                <!-- 본문 -->
                <div style="flex:1; min-width:0;">
                    <div style="display:flex; align-items:center; flex-wrap:wrap; gap:8px; margin-bottom:5px;">
                        <span style="font-weight:700; color:#17171A; font-size:14px;"><%= authorName %></span>
                        <% if(authorIsStudent && !authorName.equals(c.getUser_id())){ %><span style="color:#A1A1AA; font-size:12px;">(<%= c.getUser_id() %>)</span><% } %>
                        <span style="color:#A1A1AA; font-size:12px;"><%= timeFmt.format(c.getCreated_at()) %></span>

                        <% if(isMine) { %>
                            <span style="margin-left:auto; display:inline-flex; gap:6px;">
                                <button type="button" onclick="editComment(<%= c.getComment_id() %>)" style="font-size:11px; padding:2px 9px; cursor:pointer; border:1px solid rgba(0,0,0,0.14); background:#fff; color:#52525B; border-radius:6px;">수정</button>
                                <button type="button" onclick="deleteComment(<%= c.getComment_id() %>)" style="font-size:11px; padding:2px 9px; cursor:pointer; border:1px solid rgba(217,79,79,0.35); background:#fff; color:#D94F4F; border-radius:6px;">삭제</button>
                            </span>
                        <% } %>
                    </div>
                    <div id="cmt_content_<%= c.getComment_id() %>" style="font-size:15px; color:#2B2B30; white-space:pre-wrap; line-height:1.55; word-break:break-word;"><%= c.getContent() %></div>
                </div>
            </div>
<%
        } // for
    } // else
%>

<%
    if(totalPages > 1) {
        int start = Math.max(1, pageNo - 2);
        int end   = Math.min(totalPages, start + 4);
        start = Math.max(1, end - 4);
%>
    <div style="display:flex; justify-content:center; align-items:center; gap:6px; margin-top:22px;">
        <button type="button" onclick="goCommentPage(<%= pageNo - 1 %>)" <%= (pageNo <= 1) ? "disabled" : "" %> style="min-width:34px; height:34px; padding:0 11px; border:1px solid rgba(0,0,0,0.14); border-radius:8px; background:#fff; color:#52525B; font-size:13px; font-weight:600; cursor:pointer; <%= (pageNo <= 1) ? "opacity:0.4; cursor:not-allowed;" : "" %>">‹ 이전</button>
        <% for(int n = start; n <= end; n++) {
               if(n == pageNo) { %>
            <button type="button" style="min-width:34px; height:34px; padding:0 11px; border:1px solid #342F92; border-radius:8px; background:#342F92; color:#fff; font-size:13px; font-weight:700; cursor:default;"><%= n %></button>
        <%     } else { %>
            <button type="button" onclick="goCommentPage(<%= n %>)" style="min-width:34px; height:34px; padding:0 11px; border:1px solid rgba(0,0,0,0.14); border-radius:8px; background:#fff; color:#52525B; font-size:13px; font-weight:600; cursor:pointer;"><%= n %></button>
        <%     }
           } %>
        <button type="button" onclick="goCommentPage(<%= pageNo + 1 %>)" <%= (pageNo >= totalPages) ? "disabled" : "" %> style="min-width:34px; height:34px; padding:0 11px; border:1px solid rgba(0,0,0,0.14); border-radius:8px; background:#fff; color:#52525B; font-size:13px; font-weight:600; cursor:pointer; <%= (pageNo >= totalPages) ? "opacity:0.4; cursor:not-allowed;" : "" %>">다음 ›</button>
    </div>
<% } %>
