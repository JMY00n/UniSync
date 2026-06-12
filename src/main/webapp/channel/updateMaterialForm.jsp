<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.MessageDAO" %>
<%@ page import="channel.MessageVO" %>
<%
    int message_id = Integer.parseInt(request.getParameter("message_id"));
    String channel_id = request.getParameter("channel_id");

    MessageDAO mdao = MessageDAO.getInstance();
    MessageVO msg = mdao.getMessageById(message_id);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>강의자료 수정</title>
<style>
    .write_box { width: 700px; margin: 40px auto; padding: 20px; border: 1px solid #ccc; border-radius: 8px; background-color: #fff; }
    .input_row { margin-bottom: 15px; }
    .input_row label { display: block; font-weight: bold; margin-bottom: 5px; color: #333; }
    .input_row input[type="text"], .input_row textarea { width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px; box-sizing: border-box; }
    .btn_wrap { text-align: right; margin-top: 20px; }
    .btn_wrap button { padding: 10px 20px; font-weight: bold; cursor: pointer; border-radius: 4px; border: none; }
    .btn-submit { background-color: #ffc107; color: #333; }
    .btn-cancel { background-color: #6c757d; color: white; margin-left: 10px; }
</style>
</head>
<body style="background-color: #f4f7f6;">

<div class="write_box">
    <h2 style="border-bottom: 2px solid #28a745; padding-bottom: 10px;">✏️ 강의자료 수정</h2>
    
    <form action="updateMaterialPro.jsp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="message_id" value="<%= message_id %>">
        <input type="hidden" name="channel_id" value="<%= channel_id %>">
        
        <div class="input_row">
            <label>자료 제목</label>
            <input type="text" name="title" value="<%= msg.getTitle() %>" required>
        </div>
        
        <div class="input_row">
            <label>자료 설명</label>
            <textarea name="content" rows="10" required><%= msg.getContent() %></textarea>
        </div>
        
        <div class="input_row">
            <label>새로운 첨부파일 (기존 파일: <%= (msg.getFile_path() != null) ? msg.getFile_path() : "없음" %>)</label>
            <input type="file" name="uploadFile">
            <p style="font-size: 12px; color: gray; margin-top: 5px;">※ 새로운 파일을 선택하면 기존 자료가 교체됩니다. 선택하지 않으면 기존 파일이 유지됩니다.</p>
        </div>
        
        <div class="btn_wrap">
            <button type="submit" class="btn-submit">수정 완료</button>
            <button type="button" class="btn-cancel" onclick="history.go(-1)">취소</button>
        </div>
    </form>
</div>

</body>
</html>