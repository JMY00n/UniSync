<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String id = (String) session.getAttribute("user_id");
    if (id == null) id = (String) session.getAttribute("id");
    if (id == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }
    
    // 넘어온 방 번호 받기
    String channel_id = request.getParameter("channel_id");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>공지사항 작성 - UniSync</title>
<link href="../css/common.css" rel="stylesheet" type="text/css">
<style>
    .write_box { width: 700px; margin: 40px auto; padding: 20px; border: 1px solid #ccc; border-radius: 8px; background-color: #fff; }
    .input_row { margin-bottom: 15px; }
    .input_row label { display: block; font-weight: bold; margin-bottom: 5px; color: #333; }
    .input_row input[type="text"], .input_row textarea { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
    .btn_wrap { text-align: right; margin-top: 20px; }
    .btn_wrap button { padding: 10px 20px; font-weight: bold; cursor: pointer; border-radius: 4px; border: none; }
    .btn-submit { background-color: #007bff; color: white; }
    .btn-cancel { background-color: #6c757d; color: white; margin-left: 10px; }
</style>
</head>
<body style="background-color: #f4f7f6;">

<div class="write_box">
    <h2 style="border-bottom: 2px solid #516e7f; padding-bottom: 10px;">📢 공지사항 작성</h2>
    
    <form action="writeNoticePro.jsp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="channel_id" value="<%= channel_id %>">
        <input type="hidden" name="board_name" value="공지사항">
        
        <div class="input_row">
            <label>제목</label>
            <input type="text" name="title" required placeholder="공지사항 제목을 입력하세요.">
        </div>
        
        <div class="input_row">
            <label>내용</label>
            <textarea name="content" rows="12" required placeholder="공지사항 내용을 입력하세요."></textarea>
        </div>
        
        <div class="input_row">
            <label>첨부파일</label>
            <input type="file" name="uploadFile">
        </div>
        
        <div class="btn_wrap">
            <button type="submit" class="btn-submit">작성 완료</button>
            <button type="button" class="btn-cancel" onclick="history.go(-1)">취소</button>
        </div>
    </form>
</div>

</body>
</html>