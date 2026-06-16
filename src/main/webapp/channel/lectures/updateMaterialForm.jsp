<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.MessageDAO" %>
<%@ page import="channel.MessageVO" %>
<%
    String channel_id = request.getParameter("channel_id");
    String midParam = request.getParameter("message_id");
    if (midParam == null || !midParam.matches("\\d+")) {
        if (channel_id != null && channel_id.matches("\\d+"))
            response.sendRedirect("../lectures/lectureMain.jsp?channel_id=" + channel_id + "&menu=material");
        else
            response.sendRedirect("../../dashboard/dashboard.jsp");
        return;
    }
    int message_id = Integer.parseInt(midParam);

    MessageDAO mdao = MessageDAO.getInstance();
    MessageVO msg = mdao.getMessageById(message_id);

    if (msg == null) {
%>
        <script>alert("존재하지 않거나 삭제된 자료입니다."); history.go(-1);</script>
<%
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>강의자료 수정 - UniSync</title>
<link href="../../css/common.css" rel="stylesheet" type="text/css">
<style>
  .page-wrap { min-height: 100vh; display: flex; justify-content: center; padding: 40px 24px; }
  .e-card { width: 100%; max-width: 760px; }
  .e-back { display: inline-flex; align-items: center; gap: 6px; font-size: 13px; color: var(--text2); text-decoration: none; padding: 8px 13px; border: 1px solid var(--border-m); border-radius: 8px; margin-bottom: 16px; background: var(--surface); }
  .e-back:hover { background: var(--bg); }

  .e-top { border-top: 3px solid #1D9E75; }
  .e-box { background: var(--surface); border: 1px solid var(--border); border-top: none; border-radius: 0 0 var(--rxl, 16px) var(--rxl, 16px); padding: 28px 32px 32px; }
  .e-head { display: flex; align-items: center; gap: 12px; padding-bottom: 20px; margin-bottom: 22px; border-bottom: 1px solid var(--border); }
  .e-ico { width: 46px; height: 46px; flex-shrink: 0; border-radius: 12px; background: #E9F7F1; display: flex; align-items: center; justify-content: center; }
  .e-ico svg { width: 22px; height: 22px; stroke: #1D9E75; }
  .e-titles .t { font-family: var(--brand); font-size: 20px; font-weight: 800; color: var(--text); }
  .e-titles .s { font-size: 13px; color: var(--text3); margin-top: 2px; }

  .e-field { margin-bottom: 20px; }
  .e-label { display: block; font-size: 13.5px; font-weight: 700; color: var(--text2); margin-bottom: 8px; }
  .e-input, .e-textarea { width: 100%; border: 1.5px solid var(--border-m); border-radius: var(--r, 9px); padding: 13px 15px; font-family: var(--font); font-size: 14.5px; color: var(--text); background: var(--surface); outline: none; transition: border-color .14s, box-shadow .14s; }
  .e-textarea { min-height: 230px; resize: vertical; line-height: 1.7; }
  .e-input:focus, .e-textarea:focus { border-color: #1D9E75; box-shadow: 0 0 0 3px rgba(29,158,117,.20); }
  .e-file { width: 100%; padding: 11px 14px; border: 1.5px dashed var(--border-m); border-radius: var(--r, 9px); font-size: 13px; color: var(--text2); background: var(--bg); }
  .e-file::file-selector-button { font-family: var(--font); font-size: 12.5px; font-weight: 600; color: #fff; background: #1D9E75; border: none; border-radius: 6px; padding: 7px 13px; margin-right: 12px; cursor: pointer; }
  .e-hint { font-size: 12px; color: var(--text3); margin-top: 6px; }
  .e-hint b { color: var(--text2); font-weight: 700; }

  .e-actions { display: flex; justify-content: flex-end; gap: 9px; margin-top: 28px; }
  .e-actions a, .e-actions button { display: inline-flex; align-items: center; gap: 7px; height: 46px; padding: 0 22px; border-radius: 11px; font-family: var(--font); font-size: 14px; font-weight: 700; cursor: pointer; border: 1px solid transparent; text-decoration: none; transition: background .14s, border-color .14s, box-shadow .14s, transform .05s; }
  .e-actions a:active, .e-actions button:active { transform: translateY(1px); }
  .e-actions svg { width: 16px; height: 16px; }
  .e-cancel { background: var(--surface); color: var(--text2); border-color: var(--border-m); }
  .e-cancel:hover { background: var(--bg); }
  .e-save { background: #1D9E75; color: #fff; border-color: #1D9E75; }
  .e-save:hover { background: #178a65; border-color: #178a65; box-shadow: 0 4px 14px rgba(29,158,117,.28); }
</style>
</head>
<body>
<div class="page-wrap">
  <div class="e-card">
    <a class="e-back" href="materialDetail.jsp?message_id=<%= message_id %>&channel_id=<%= channel_id %>">‹ 상세로 돌아가기</a>

    <div class="e-top"></div>
    <div class="e-box">
      <div class="e-head">
        <div class="e-ico">
          <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6"/><path d="M16 13H8"/><path d="M16 17H8"/></svg>
        </div>
        <div class="e-titles">
          <div class="t">강의자료 수정</div>
          <div class="s">기존 자료 내용을 수정한 뒤 저장하세요.</div>
        </div>
      </div>

      <form action="updateMaterialPro.jsp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="message_id" value="<%= message_id %>">
        <input type="hidden" name="channel_id" value="<%= channel_id %>">
        <input type="hidden" name="board_name" value="강의자료">

        <div class="e-field">
          <label class="e-label" for="title">자료 제목</label>
          <input class="e-input" type="text" id="title" name="title" value="<%= msg.getTitle() %>" required placeholder="강의자료 제목을 입력하세요.">
        </div>

        <div class="e-field">
          <label class="e-label" for="content">자료 설명</label>
          <textarea class="e-textarea" id="content" name="content" required placeholder="강의자료에 대한 설명을 입력하세요."><%= msg.getContent() %></textarea>
        </div>

        <div class="e-field">
          <label class="e-label" for="uploadFile">첨부파일</label>
          <input class="e-file" type="file" id="uploadFile" name="uploadFile">
          <p class="e-hint">현재 파일: <b><%= (msg.getFile_path() != null && !msg.getFile_path().equals("")) ? msg.getFile_path() : "없음" %></b> · 새 파일을 선택하면 교체되고, 선택하지 않으면 기존 파일이 유지됩니다.</p>
        </div>

        <div class="e-actions">
          <a class="e-cancel" href="materialDetail.jsp?message_id=<%= message_id %>&channel_id=<%= channel_id %>">취소</a>
          <button type="submit" class="e-save">
            <svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg>
            수정 완료
          </button>
        </div>
      </form>
    </div>
  </div>
</div>
</body>
</html>
