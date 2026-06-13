<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String id = (String) session.getAttribute("user_id");
    if (id == null) id = (String) session.getAttribute("id");
    if (id == null) {
        response.sendRedirect("../../login/login.jsp");
        return;
    }
    String channel_id = request.getParameter("channel_id");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>강의자료 등록 - UniSync</title>
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
  .w-textarea { resize: vertical; min-height: 200px; line-height: 1.6; }
  .w-input:focus, .w-textarea:focus { border-color: var(--primary-mid); box-shadow: 0 0 0 3px var(--primary-glow); }
  .w-input::placeholder, .w-textarea::placeholder { color: var(--text4); }
  .w-file { width: 100%; padding: 11px 14px; border: 1.5px dashed var(--border-m); border-radius: var(--r, 8px); font-family: var(--font); font-size: 13px; color: var(--text2); background: var(--bg); cursor: pointer; }
  .w-file::file-selector-button { font-family: var(--font); font-size: 12.5px; font-weight: 600; color: #fff; background: var(--primary-mid); border: none; border-radius: 6px; padding: 7px 13px; margin-right: 12px; cursor: pointer; }
  .w-hint { font-size: 12px; color: var(--text3); margin-top: 7px; }
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

    <a href="lectureMain.jsp?channel_id=<%= channel_id %>&menu=material" class="back-btn">
      <img src="../../images/icons/chevron-left.svg" width="15" height="15" alt="뒤로">
      강의자료 목록으로
    </a>

    <div class="form-header">
      <div style="display:flex; align-items:center; gap:14px;">
        <div class="reg-icon-box reg-icon-prof">
          <svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="24" height="24"><path d="M4 20h16a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13c0 1.1.9 2 2 2Z"/></svg>
        </div>
        <div>
          <div class="form-title" style="margin-bottom:1px;">강의자료 등록</div>
          <div class="form-sub" style="margin-top:1px;">학생들이 내려받을 강의자료를 올려주세요.</div>
        </div>
      </div>
    </div>

    <form action="writeMaterialPro.jsp" method="post" enctype="multipart/form-data">
      <input type="hidden" name="channel_id" value="<%= channel_id %>">
      <input type="hidden" name="board_name" value="강의자료">

      <div class="w-field">
        <label class="w-label" for="title">자료 제목</label>
        <input class="w-input" type="text" id="title" name="title" required placeholder="예: [1주차] 자바 개발환경 설정 및 기본 문법 PPT">
      </div>

      <div class="w-field">
        <label class="w-label" for="content">자료 설명</label>
        <textarea class="w-textarea" id="content" name="content" required placeholder="다운로드 받을 학생들에게 전달할 설명을 적어주세요."></textarea>
      </div>

      <div class="w-field">
        <label class="w-label" for="uploadFile">강의 파일 첨부</label>
        <input class="w-file" type="file" id="uploadFile" name="uploadFile">
        <div class="w-hint">PPT · PDF · 압축파일 등 (최대 10MB 권장)</div>
      </div>

      <div class="w-actions">
        <button type="button" class="btn-cancel" onclick="history.go(-1)">취소</button>
        <button type="submit" class="btn-go">업로드 완료</button>
      </div>
    </form>

  </div>
</div>
</body>
</html>
