<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String id = (String) session.getAttribute("user_id");
    if (id == null) id = (String) session.getAttribute("id");
    if (id == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }
    String channel_id = request.getParameter("channel_id");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>강의자료 등록</title>
<style>
    .write_box { width: 700px; margin: 40px auto; padding: 20px; border: 1px solid #ccc; border-radius: 8px; background-color: #fff; }
    .input_row { margin-bottom: 15px; }
    .input_row label { display: block; font-weight: bold; margin-bottom: 5px; color: #333; }
    .input_row input[type="text"], .input_row textarea { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
    .btn_wrap { text-align: right; margin-top: 20px; }
    .btn_wrap button { padding: 10px 20px; font-weight: bold; cursor: pointer; border-radius: 4px; border: none; }
    .btn-submit { background-color: #28a745; color: white; }
    .btn-cancel { background-color: #6c757d; color: white; margin-left: 10px; }
</style>
</head>
<body style="background-color: #f4f7f6;">

<div class="write_box">
    <h2 style="border-bottom: 2px solid #28a745; padding-bottom: 10px;">📁 새 강의자료 등록</h2>
    
    <form action="writeMaterialPro.jsp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="channel_id" value="<%= channel_id %>">
        <input type="hidden" name="board_name" value="강의자료">
        
        <div class="input_row">
            <label>자료 제목</label>
            <input type="text" name="title" required placeholder="예: [1주차] 자바 개발환경 설정 및 기본 문법 PPT">
        </div>
        
        <div class="input_row">
            <label>자료 설명</label>
            <textarea name="content" rows="10" required placeholder="다운로드 받을 학생들에게 전달할 설명을 적어주세요."></textarea>
        </div>
        
        <div class="input_row">
            <label>강의 파일 첨부</label>
            <input type="file" name="uploadFile" required> </div>
        
        <div class="btn_wrap">
            <button type="submit" class="btn-submit">업로드 완료</button>
            <button type="button" class="btn-cancel" onclick="history.go(-1)">취소</button>
        </div>
    </form>
</div>

</body>
</html>