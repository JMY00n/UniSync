<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.MessageDAO" %>
<%@ page import="channel.MessageVO" %>
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
    String userId = (String) session.getAttribute("user_id");
    if(userId == null) userId = (String) session.getAttribute("id");
    Integer role = session.getAttribute("role") != null ? (Integer) session.getAttribute("role") : 0;

    int channel_id = Integer.parseInt(request.getParameter("channel_id"));

    MessageDAO mdao = MessageDAO.getInstance();
    ArrayList<MessageVO> qnaList = mdao.getMessageList(channel_id, "Q&A");

    SimpleDateFormat dateFmt = new SimpleDateFormat("yyyy년 MM월 dd일");
    SimpleDateFormat timeFmt = new SimpleDateFormat("HH:mm");
    String prevDate = "";

    if(qnaList.isEmpty()) {
%>
    <div style="text-align:center; padding:40px 20px; color:#A1A1AA; font-size:14px;">아직 등록된 질문이 없습니다.</div>
<%
    } else {
        for(MessageVO msg : qnaList) {
            boolean isMine   = (userId != null && userId.equals(msg.getUser_id()));
            boolean isPinned = (msg.getIs_pinned() == 1);

            // 작성자 이름(닉네임) 조회 — 없으면 아이디로 폴백 / 학생만 학번 표기
            String authorName = msg.getUser_id();
            boolean authorIsStudent = true;
            try {
                MemberVO author = MemberDAO.getinstance().getMember(msg.getUser_id());
                if (author != null) {
                    if (author.getName() != null && !author.getName().trim().isEmpty())
                        authorName = author.getName();
                    authorIsStudent = (author.getRole() != 1);
                }
            } catch (Exception e) {}

            String color = avatarColor(msg.getUser_id());

            String currentDate = dateFmt.format(msg.getCreated_at());
            if(!currentDate.equals(prevDate)) {
%>
                <div style="text-align:center; margin:22px 0 14px;">
                    <span style="background:#EEEDF9; color:#52525B; font-size:12px; padding:5px 16px; border-radius:20px; font-weight:700;">
                        <%= currentDate %>
                    </span>
                </div>
<%
                prevDate = currentDate;
            }

            String wrapStyle = isPinned
                ? "display:flex; gap:12px; padding:14px; margin-bottom:10px; background:#F5F3FF; border:1px solid #DEDAF7; border-radius:14px;"
                : "display:flex; gap:12px; padding:13px 6px; margin-bottom:4px; border-bottom:1px solid rgba(0,0,0,0.06);";
%>
            <div style="<%= wrapStyle %>">
                <!-- 아바타 -->
                <div style="width:38px; height:38px; flex-shrink:0; border-radius:50%; background:<%= color %>; color:#fff; display:flex; align-items:center; justify-content:center; font-weight:800; font-size:15px;">
                    <%= initial(authorName) %>
                </div>

                <!-- 본문 -->
                <div style="flex:1; min-width:0;">
                    <div style="display:flex; align-items:center; flex-wrap:wrap; gap:8px; margin-bottom:5px;">
                        <% if(isPinned) { %><span style="display:inline-flex; align-items:center; gap:3px; font-size:11px; font-weight:800; color:#2E5BB8;"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="12" height="12"><path d="M12 17v5"/><path d="M9 10.76a2 2 0 0 1-1.11 1.79l-1.78.9A2 2 0 0 0 5 15.24V16a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-.76a2 2 0 0 0-1.11-1.79l-1.78-.9A2 2 0 0 1 15 10.76V7a1 1 0 0 1 1-1 2 2 0 0 0 0-4H8a2 2 0 0 0 0 4 1 1 0 0 1 1 1z"/></svg>고정</span><% } %>
                        <span style="font-weight:700; color:#17171A; font-size:14px;"><%= authorName %></span>
                        <% if(authorIsStudent && !authorName.equals(msg.getUser_id())){ %><span style="color:#A1A1AA; font-size:12px;">(<%= msg.getUser_id() %>)</span><% } %>
                        <span style="color:#A1A1AA; font-size:12px;"><%= timeFmt.format(msg.getCreated_at()) %></span>

                        <% if(isMine) { %>
                            <button type="button" onclick="editQna(<%= msg.getMessage_id() %>)" style="font-size:11px; padding:2px 9px; cursor:pointer; border:1px solid rgba(0,0,0,0.14); background:#fff; color:#52525B; border-radius:6px;">수정</button>
                            <button type="button" onclick="deleteQna(<%= msg.getMessage_id() %>)" style="font-size:11px; padding:2px 9px; cursor:pointer; border:1px solid rgba(217,79,79,0.35); background:#fff; color:#D94F4F; border-radius:6px;">삭제</button>
                        <% } %>

                        <% if(role == 1) { %>
                            <span style="margin-left:auto;">
                            <% if(isPinned) { %>
                                <button type="button" onclick="togglePin(<%= msg.getMessage_id() %>, false)" style="font-size:11px; padding:3px 10px; cursor:pointer; border:none; background:#A1A1AA; color:#fff; border-radius:6px;">고정 해제</button>
                            <% } else { %>
                                <button type="button" onclick="togglePin(<%= msg.getMessage_id() %>, true)" style="display:inline-flex; align-items:center; gap:4px; font-size:11px; padding:3px 10px; cursor:pointer; border:1px solid #D4D4D8; background:#fff; color:#52525B; border-radius:6px; font-weight:700;"><svg viewBox="0 0 24 24" fill="none" stroke="#2E5BB8" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="12" height="12"><path d="M12 17v5"/><path d="M9 10.76a2 2 0 0 1-1.11 1.79l-1.78.9A2 2 0 0 0 5 15.24V16a1 1 0 0 0 1 1h12a1 1 0 0 0 1-1v-.76a2 2 0 0 0-1.11-1.79l-1.78-.9A2 2 0 0 1 15 10.76V7a1 1 0 0 1 1-1 2 2 0 0 0 0-4H8a2 2 0 0 0 0 4 1 1 0 0 1 1 1z"/></svg>상단 고정</button>
                            <% } %>
                            </span>
                        <% } %>
                    </div>
                    <div id="qna_content_<%= msg.getMessage_id() %>" style="font-size:15px; color:#2B2B30; white-space:pre-wrap; line-height:1.55; word-break:break-word;"><%= msg.getContent() %></div>
                </div>
            </div>
<%
        }
    }
%>
