<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.MessageDAO" %>
<%@ page import="channel.MessageVO" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    String userId = (String) session.getAttribute("user_id");
    if (userId == null) userId = (String) session.getAttribute("id");
    if (userId == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    int message_id = Integer.parseInt(request.getParameter("message_id"));
    String channel_id = request.getParameter("channel_id");

    MessageDAO mdao = MessageDAO.getInstance();
    MessageVO msg = mdao.getMessageById(message_id);

    if(msg == null) {
%>
        <script>alert("존재하지 않거나 삭제된 자료입니다."); history.go(-1);</script>
<%
        return;
    }
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>강의자료 상세 - UniSync</title>
<link href="../../css/common.css" rel="stylesheet" type="text/css">
<style>
  .page-wrap { min-height: 100vh; display: flex; align-items: flex-start; justify-content: center; padding: 40px 24px; }
  .d-card { width: 100%; max-width: 760px; background: var(--surface); border: 1px solid var(--border); border-radius: var(--rxl, 22px); padding: 32px; box-shadow: 0 10px 40px rgba(52,47,146,.06); }
  .d-back { display: inline-flex; align-items: center; gap: 6px; font-size: 13px; color: var(--text2); text-decoration: none; padding: 7px 12px; border: 1px solid var(--border-m); border-radius: 8px; margin-bottom: 22px; }
  .d-back:hover { background: var(--bg); }
  .d-head { border-bottom: 2px solid var(--success, #1D9E75); padding-bottom: 16px; margin-bottom: 20px; }
  .d-title { display: flex; align-items: center; gap: 9px; font-family: var(--brand); font-size: 22px; font-weight: 800; color: var(--text); margin-bottom: 12px; }
  .d-info { display: flex; justify-content: space-between; font-size: 13px; color: var(--text3); }
  .d-info b { color: var(--text2); font-weight: 700; }
  .d-file { display: flex; align-items: center; gap: 8px; background: #E9F7F1; border: 1px solid #C5E8DB; padding: 13px 16px; border-radius: var(--r, 8px); margin-bottom: 22px; font-size: 14px; color: var(--text2); }
  .d-file a { color: var(--success, #1D9E75); text-decoration: none; font-weight: 700; }
  .d-file a:hover { text-decoration: underline; }
  .d-file.none { background: var(--bg); border: 1px solid var(--border); color: var(--text3); }
  .d-content { min-height: 180px; line-height: 1.7; color: var(--text); font-size: 15px; white-space: pre-wrap; word-break: break-word; margin-bottom: 28px; }
  .d-actions { display: flex; justify-content: flex-end; gap: 9px; border-top: 1px solid var(--border); padding-top: 20px; }
  .d-actions button { height: 44px; padding: 0 20px; border-radius: var(--r, 8px); font-family: var(--font); font-size: 14px; font-weight: 700; cursor: pointer; border: none; }
  .btn-edit { background: #FFF4D6; color: #9A6B00; border: 1px solid #F0D58A; }
  .btn-del { background: #FDECEC; color: var(--danger, #D94F4F); border: 1px solid rgba(217,79,79,.3); }
  .btn-list { background: var(--primary); color: #fff; }
  .btn-list:hover { background: var(--primary-hover); }
</style>
</head>
<body>
<div class="page-wrap">
  <div class="d-card">
    <a class="d-back" href="../lectures/lectureMain.jsp?channel_id=<%= channel_id %>&menu=material">‹ 강의자료 목록으로</a>

    <div class="d-head">
      <div class="d-title">
        <svg viewBox="0 0 24 24" fill="none" stroke="var(--success, #1D9E75)" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="22" height="22"><path d="M4 20h16a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13c0 1.1.9 2 2 2Z"/></svg>
        <%= msg.getTitle() %>
      </div>
      <div class="d-info">
        <span><b>등록자</b> <%= msg.getUser_id() %></span>
        <span><b>등록일</b> <%= sdf.format(msg.getCreated_at()) %></span>
      </div>
    </div>

    <% if(msg.getFile_path() != null && !msg.getFile_path().equals("")) { %>
      <div class="d-file">
        💾 첨부파일 <a href="../upload/<%= msg.getFile_path() %>" download="<%= msg.getFile_path() %>"><%= msg.getFile_path() %></a>
      </div>
    <% } else { %>
      <div class="d-file none">📂 첨부된 파일이 없습니다.</div>
    <% } %>

    <div class="d-content"><%= msg.getContent() %></div>

    <div class="d-actions">
      <% if(userId.equals(msg.getUser_id())) { %>
        <button type="button" class="btn-edit" onclick="location.href='updateMaterialForm.jsp?message_id=<%= message_id %>&channel_id=<%= channel_id %>'">수정</button>
        <button type="button" class="btn-del" onclick="if(confirm('이 강의자료를 정말 삭제하시겠습니까?')) location.href='deleteMaterialPro.jsp?message_id=<%= message_id %>&channel_id=<%= channel_id %>&menu=material'">삭제</button>
      <% } %>
      <button type="button" class="btn-list" onclick="location.href='../lectures/lectureMain.jsp?channel_id=<%= channel_id %>&menu=material'">목록으로</button>
    </div>
  </div>
</div>
</body>
</html>
