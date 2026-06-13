<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String id = (String) session.getAttribute("user_id");
    if (id == null) id = (String) session.getAttribute("id");
    if (id == null) {
        response.sendRedirect("../../login/login.jsp");
        return;
    }
    // 넘어온 방 번호 받기
    String channel_id = request.getParameter("channel_id");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>공지사항 작성 - UniSync</title>
<link href="../../css/common.css" rel="stylesheet" type="text/css">
<link href="../../css/login.css" rel="stylesheet" type="text/css">
<style>
  .page-wrap { min-height: 100vh; display: flex; align-items: flex-start; justify-content: center; padding: 40px 24px; }
  .form-card { width: 100%; max-width: 680px; background: var(--surface); border: 1px solid var(--border); border-radius: var(--rxl, 22px); padding: 32px; box-shadow: 0 10px 40px rgba(52,47,146,.08); }
  .form-card .back-btn { margin-bottom: 20px; }
  .w-field { margin-bottom: 18px; }
  .w-label { display: block; font-size: 13px; font-weight: 700; color: var(--text2); margin-bottom: 8px; }
  .w-input, .w-textarea {
    width: 100%; border: 1.5px solid var(--border-m); border-radius: var(--r, 8px); padding: 12px 14px;
    font-family: var(--font); font-size: 14px; color: var(--text); background: var(--surface); outline: none;
    transition: border-color .14s, box-shadow .14s;
  }
  .w-textarea { resize: vertical; min-height: 240px; line-height: 1.6; }
  .w-input:focus, .w-textarea:focus { border-color: var(--primary-mid); box-shadow: 0 0 0 3px var(--primary-glow); }
  .w-input::placeholder, .w-textarea::placeholder { color: var(--text4); }
  .w-file { width: 100%; padding: 11px 14px; border: 1.5px dashed var(--border-m); border-radius: var(--r, 8px); font-family: var(--font); font-size: 13px; color: var(--text2); background: var(--bg); cursor: pointer; }
  .w-file::file-selector-button { font-family: var(--font); font-size: 12.5px; font-weight: 600; color: #fff; background: var(--primary-mid); border: none; border-radius: 6px; padding: 7px 13px; margin-right: 12px; cursor: pointer; }
  .w-actions { display: flex; justify-content: flex-end; gap: 10px; margin-top: 24px; padding-top: 20px; border-top: 1px solid var(--border); }
  .btn-cancel { padding: 0 22px; height: 46px; border-radius: var(--r, 8px); border: 1px solid var(--border-m); background: var(--surface); color: var(--text2); font-family: var(--font); font-size: 14px; font-weight: 600; cursor: pointer; transition: background .15s; }
  .btn-cancel:hover { background: var(--bg); }
  .btn-go { padding: 0 28px; height: 46px; border: none; border-radius: var(--r, 8px); background: var(--primary); color: #fff; font-family: var(--font); font-size: 14px; font-weight: 700; cursor: pointer; transition: background .14s; }
  .btn-go:hover { background: var(--primary-hover); }
</style>
</head>
<body>
<div class="page-wrap">
  <div class="form-card">

    <a href="../lectures/lectureMain.jsp?channel_id=<%= channel_id %>&menu=notice" class="back-btn">
      <img src="../../images/icons/chevron-left.svg" width="15" height="15" alt="뒤로">
      공지사항 목록으로
    </a>

    <div class="form-header">
      <div style="display:flex; align-items:center; gap:14px;">
        <div class="reg-icon-box reg-icon-prof">
          <svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="24" height="24"><path d="m3 11 18-5v12L3 14v-3z"/><path d="M11.6 16.8a3 3 0 1 1-5.8-1.6"/></svg>
        </div>
        <div>
          <div class="form-title" style="margin-bottom:1px;">공지사항 작성</div>
          <div class="form-sub" style="margin-top:1px;">학생들에게 전달할 공지를 작성하세요.</div>
        </div>
      </div>
    </div>

    <form action="writeNoticePro.jsp" method="post" enctype="multipart/form-data">
      <input type="hidden" name="channel_id" value="<%= channel_id %>">
      <input type="hidden" name="board_name" value="공지사항">

      <div class="w-field">
        <label class="w-label" for="title">제목</label>
        <input class="w-input" type="text" id="title" name="title" required placeholder="공지사항 제목을 입력하세요.">
      </div>

      <div class="w-field">
        <label class="w-label" for="content">내용</label>
        <textarea class="w-textarea" id="content" name="content" required placeholder="공지사항 내용을 입력하세요."></textarea>
      </div>

      <div class="w-field">
        <label class="w-label" for="uploadFile">첨부파일 <span style="color:var(--text3);font-weight:500;">(선택)</span></label>
        <input class="w-file" type="file" id="uploadFile" name="uploadFile">
      </div>

      <div class="w-actions">
        <button type="button" class="btn-cancel" onclick="history.go(-1)">취소</button>
        <button type="submit" class="btn-go">작성 완료</button>
      </div>
    </form>

  </div>
</div>
</body>
</html>
