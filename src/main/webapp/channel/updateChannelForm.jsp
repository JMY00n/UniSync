<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.ChannelDAO" %>
<%@ page import="channel.ChannelVO" %>
<%
    String id = (String) session.getAttribute("id");
    if (id == null) id = (String) session.getAttribute("user_id");
    if (id == null) {
%>
        <script>alert("로그인이 필요합니다."); location.href="../login/login.jsp";</script>
<%
        return;
    }

    int channel_id = Integer.parseInt(request.getParameter("channel_id"));
    ChannelDAO cdao = ChannelDAO.getInstance();
    ChannelVO channel = cdao.getChannelById(channel_id);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>강의실 이름 수정 - UniSync</title>
<link href="../css/common.css" rel="stylesheet" type="text/css">
<style>
  .page-wrap { min-height: 100vh; display: flex; align-items: center; justify-content: center; padding: 40px 24px; }
  .form-card { width: 100%; max-width: 520px; background: var(--surface); border: 1px solid var(--border); border-radius: var(--rxl, 22px); padding: 32px; box-shadow: 0 10px 40px rgba(52,47,146,.08); }
  .fc-head { display: flex; align-items: center; gap: 14px; margin-bottom: 24px; }
  .fc-icon { width: 50px; height: 50px; flex-shrink: 0; border-radius: 14px; background: var(--primary); display: flex; align-items: center; justify-content: center; box-shadow: 0 6px 18px var(--primary-glow); }
  .fc-title { font-family: var(--brand); font-size: 21px; font-weight: 800; color: var(--text); }
  .fc-sub { font-size: 13px; color: var(--text3); margin-top: 2px; }
  .fc-label { display: block; font-size: 13px; font-weight: 700; color: var(--text2); margin-bottom: 8px; }
  .fc-input { width: 100%; border: 1.5px solid var(--border-m); border-radius: var(--r, 8px); padding: 13px 15px; font-family: var(--font); font-size: 15px; color: var(--text); outline: none; transition: border-color .14s, box-shadow .14s; }
  .fc-input:focus { border-color: var(--primary-mid); box-shadow: 0 0 0 3px var(--primary-glow); }
  .fc-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 26px; }
  .btn-cancel { padding: 0 22px; height: 46px; border-radius: var(--r, 8px); border: 1px solid var(--border-m); background: var(--surface); color: var(--text2); font-family: var(--font); font-size: 14px; font-weight: 600; cursor: pointer; }
  .btn-cancel:hover { background: var(--bg); }
  .btn-go { padding: 0 28px; height: 46px; border: none; border-radius: var(--r, 8px); background: var(--primary); color: #fff; font-family: var(--font); font-size: 14px; font-weight: 700; cursor: pointer; }
  .btn-go:hover { background: var(--primary-hover); }
</style>
</head>
<body>
<div class="page-wrap">
  <div class="form-card">
    <div class="fc-head">
      <div class="fc-icon">
        <svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="24" height="24"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>
      </div>
      <div>
        <div class="fc-title">강의실 이름 수정</div>
        <div class="fc-sub">강의실 이름을 변경하고 저장하세요.</div>
      </div>
    </div>

    <form method="post" action="updateChannelPro.jsp">
      <input type="hidden" name="channel_id" value="<%= channel.getChannel_id() %>">
      <label class="fc-label" for="channel_name">새 강의실 이름</label>
      <input class="fc-input" id="channel_name" name="channel_name" type="text" value="<%= channel.getChannel_name() %>" required>
      <div class="fc-actions">
        <button type="button" class="btn-cancel" onclick="history.go(-1)">취소</button>
        <button type="submit" class="btn-go">수정 완료</button>
      </div>
    </form>
  </div>
</div>
</body>
</html>
