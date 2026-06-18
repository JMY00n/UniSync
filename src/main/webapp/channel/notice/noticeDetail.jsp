<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.MessageDAO" %>
<%@ page import="channel.MessageVO" %>
<%@ page import="member.MemberDAO" %>
<%@ page import="member.MemberVO" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    String userId = (String) session.getAttribute("user_id");
    if (userId == null) userId = (String) session.getAttribute("id");
    if (userId == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    String channel_id = request.getParameter("channel_id");
    String midParam = request.getParameter("message_id");
    if (midParam == null || !midParam.matches("\\d+")) {
        if (channel_id != null && channel_id.matches("\\d+"))
            response.sendRedirect("../lectures/lectureMain.jsp?channel_id=" + channel_id + "&menu=notice");
        else
            response.sendRedirect("../../dashboard/dashboard.jsp");
        return;
    }
    int message_id = Integer.parseInt(midParam);

    MessageDAO mdao = MessageDAO.getInstance();
    MessageVO msg = mdao.getMessageById(message_id);

    if(msg == null) {
%>
        <script>alert("존재하지 않거나 삭제된 게시글입니다."); history.go(-1);</script>
<%
        return;
    }
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

    // 작성자 표시명: 닉네임(name) 우선, 없으면 학번(user_id)으로 폴백
    String authorName = msg.getUser_id();
    try {
        MemberVO author = MemberDAO.getinstance().getMember(msg.getUser_id());
        if (author != null && author.getName() != null && !author.getName().trim().isEmpty())
            authorName = author.getName();
    } catch (Exception e) { /* 조회 실패 시 학번 그대로 사용 */ }

    // 이전글(더 오래된 글) / 다음글(더 최신 글)
    MessageVO prev = mdao.getPrevMessage(msg.getChannel_id(), msg.getBoard_name(), message_id);
    MessageVO next = mdao.getNextMessage(msg.getChannel_id(), msg.getBoard_name(), message_id);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>공지사항 상세 - UniSync</title>
<link href="../../css/common.css" rel="stylesheet" type="text/css">
<style>
  .page-wrap { min-height: 100vh; display: flex; justify-content: center; padding: 40px 24px; }
  .d-card { width: 100%; max-width: 920px; }

  .d-back { display: inline-flex; align-items: center; gap: 6px; font-size: 13px; color: var(--text2); text-decoration: none; padding: 8px 13px; border: 1px solid var(--border-m); border-radius: 8px; margin-bottom: 16px; background: var(--surface); }
  .d-back:hover { background: var(--bg); }

  /* 클래식 헤더: 상단 라인 + 제목 + 메타 */
  .d-top { border-top: 3px solid var(--primary); }
  .d-head { background: var(--surface); border: 1px solid var(--border); border-top: none; padding: 30px 32px 22px; }
  .d-title { font-family: var(--brand); font-size: 27px; font-weight: 800; color: var(--text); line-height: 1.25; }
  .d-meta { display: flex; flex-wrap: wrap; align-items: center; gap: 0; margin-top: 16px; font-size: 13.5px; color: var(--text3); }
  .d-meta .mi { display: inline-flex; align-items: center; gap: 6px; }
  .d-meta .sep { margin: 0 14px; color: var(--border-m); }
  .d-meta svg { width: 15px; height: 15px; stroke: var(--text3); }

  /* 첨부 */
  .d-file { display: flex; align-items: center; gap: 10px; background: var(--surface); border-left: 1px solid var(--border); border-right: 1px solid var(--border); padding: 14px 32px; font-size: 14px; color: var(--text2); }
  .d-file .fl-label { font-weight: 700; color: var(--text2); }
  .d-file svg { width: 16px; height: 16px; stroke: var(--text3); }
  .d-file a { color: var(--primary); text-decoration: none; font-weight: 600; }
  .d-file a:hover { text-decoration: underline; }
  .d-divider { border-top: 1px solid var(--border); }

  /* 본문 */
  .d-body { background: var(--surface); border-left: 1px solid var(--border); border-right: 1px solid var(--border); border-bottom: 1px solid var(--border); padding: 30px 32px 40px; min-height: 220px; font-size: 15.5px; line-height: 1.8; color: var(--text); white-space: pre-wrap; word-break: break-word; }

  /* 액션 */
  .d-actions { display: flex; align-items: center; gap: 9px; padding: 18px 0 26px; }
  .d-actions .spacer { flex: 1; }
  .d-actions button { display: inline-flex; align-items: center; gap: 7px; height: 42px; padding: 0 18px; border-radius: 11px; font-family: var(--font); font-size: 14px; font-weight: 700; cursor: pointer; border: 1px solid transparent; transition: background .14s, border-color .14s, box-shadow .14s, transform .05s; }
  .d-actions button:active { transform: translateY(1px); }
  .d-actions button svg { width: 16px; height: 16px; }
  .btn-edit { background: #FEF5E1; color: #97670B; border-color: #F1DCA4; }
  .btn-edit:hover { background: #FBE9C0; border-color: #EACd7c; box-shadow: 0 2px 8px rgba(151,103,11,.12); }
  .btn-del { background: #FDECEC; color: #C5403B; border-color: #F1C7C5; }
  .btn-del:hover { background: #F9DADA; border-color: #E9AFAC; box-shadow: 0 2px 8px rgba(197,64,59,.12); }
  .btn-list { background: var(--primary); color: #fff; border-color: var(--primary); }
  .btn-list:hover { background: var(--primary-hover); border-color: var(--primary-hover); box-shadow: 0 4px 14px var(--primary-glow); }

  /* 이전글 / 다음글 */
  .d-nav { background: var(--surface); border: 1px solid var(--border); border-radius: var(--r, 10px); overflow: hidden; }
  .d-nav-row { display: flex; align-items: center; gap: 0; padding: 16px 24px; text-decoration: none; }
  .d-nav-row + .d-nav-row { border-top: 1px solid var(--border); }
  .d-nav-row.link:hover { background: var(--bg); }
  .d-nav-ico { display: inline-flex; width: 22px; color: var(--text3); }
  .d-nav-ico svg { width: 17px; height: 17px; stroke: var(--text3); }
  .d-nav-label { width: 64px; font-size: 13.5px; font-weight: 700; color: var(--text2); }
  .d-nav-text { flex: 1; font-size: 14px; color: var(--text); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .d-nav-text.empty { color: var(--text3); font-weight: 400; }
</style>
</head>
<body>
<div class="page-wrap">
  <div class="d-card">
    <a class="d-back" href="../lectures/lectureMain.jsp?channel_id=<%= channel_id %>&menu=notice">‹ 공지사항 목록으로</a>

    <div class="d-top"></div>
    <div class="d-head">
      <div class="d-title"><%= msg.getTitle() %></div>
      <div class="d-meta">
        <span class="mi"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg><%= sdf.format(msg.getCreated_at()) %></span>
        <span class="sep">|</span>
        <span class="mi"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg><%= authorName %></span>
      </div>
    </div>

    <% if(msg.getFile_path() != null && !msg.getFile_path().equals("")) { %>
      <div class="d-file">
        <span class="fl-label">첨부파일</span>
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21.4 11.05 12.25 20.2a5 5 0 0 1-7.07-7.07l9.19-9.19a3 3 0 0 1 4.24 4.24l-9.2 9.19a1 1 0 0 1-1.41-1.41l8.49-8.5"/></svg>
        <a href="<%= request.getContextPath() %>/upload/<%= java.net.URLEncoder.encode(msg.getFile_path(), "UTF-8").replaceAll("\\+", "%20") %>" download="<%= msg.getFile_path() %>"><%= msg.getFile_path() %></a>
      </div>
    <% } %>
    <div class="d-divider"></div>

    <div class="d-body"><%= msg.getContent() %></div>

    <div class="d-actions">
      <% if(userId.equals(msg.getUser_id())) { %>
        <button type="button" class="btn-edit" onclick="location.href='updateNoticeForm.jsp?message_id=<%= message_id %>&channel_id=<%= channel_id %>'">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>
          수정
        </button>
        <button type="button" class="btn-del" onclick="if(confirm('정말 삭제하시겠습니까?')) location.href='../notice/deleteNoticePro.jsp?message_id=<%= message_id %>&channel_id=<%= channel_id %>'">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2m2 0v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6"/><path d="M10 11v6M14 11v6"/></svg>
          삭제
        </button>
      <% } %>
      <span class="spacer"></span>
      <button type="button" class="btn-list" onclick="location.href='../lectures/lectureMain.jsp?channel_id=<%= channel_id %>&menu=notice'">
        <svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01"/></svg>
        목록
      </button>
    </div>

    <div class="d-nav">
      <% if(prev != null) { %>
        <a class="d-nav-row link" href="noticeDetail.jsp?message_id=<%= prev.getMessage_id() %>&channel_id=<%= channel_id %>">
          <span class="d-nav-ico"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m18 15-6-6-6 6"/></svg></span>
          <span class="d-nav-label">이전글</span>
          <span class="d-nav-text"><%= prev.getTitle() %></span>
        </a>
      <% } else { %>
        <div class="d-nav-row">
          <span class="d-nav-ico"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m18 15-6-6-6 6"/></svg></span>
          <span class="d-nav-label">이전글</span>
          <span class="d-nav-text empty">이전글이 없습니다.</span>
        </div>
      <% } %>
      <% if(next != null) { %>
        <a class="d-nav-row link" href="noticeDetail.jsp?message_id=<%= next.getMessage_id() %>&channel_id=<%= channel_id %>">
          <span class="d-nav-ico"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6"/></svg></span>
          <span class="d-nav-label">다음글</span>
          <span class="d-nav-text"><%= next.getTitle() %></span>
        </a>
      <% } else { %>
        <div class="d-nav-row">
          <span class="d-nav-ico"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6"/></svg></span>
          <span class="d-nav-label">다음글</span>
          <span class="d-nav-text empty">다음글이 없습니다.</span>
        </div>
      <% } %>
    </div>
  </div>
</div>
</body>
</html>