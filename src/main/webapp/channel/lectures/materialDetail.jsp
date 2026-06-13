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
<html>
<head>
<meta charset="UTF-8">
<title>강의자료 상세 보기</title>
<style>
    body { margin: 0; font-family: sans-serif; background-color: #f4f7f6; }
    .detail_box { width: 750px; margin: 40px auto; padding: 30px; border: 1px solid #ccc; border-radius: 8px; background-color: #fff; box-shadow: 0 0 10px rgba(0,0,0,0.05); }
    .detail_header { border-bottom: 2px solid #28a745; padding-bottom: 15px; margin-bottom: 20px; }
    .detail_title { font-size: 22px; font-weight: bold; color: #333; margin-bottom: 10px; }
    .detail_info { font-size: 13px; color: #666; display: flex; justify-content: space-between; }
    .file_box { background-color: #d4edda; padding: 15px; border-radius: 5px; margin-bottom: 20px; font-size: 15px; border: 1px solid #c3e6cb; }
    .file_box a { color: #155724; text-decoration: none; font-weight: bold; }
    .detail_content { min-height: 200px; line-height: 1.6; color: #333; font-size: 15px; white-space: pre-wrap; margin-bottom: 30px; }
    .btn_wrap { text-align: right; border-top: 1px solid #eee; padding-top: 20px; }
    .btn_wrap button { padding: 8px 16px; cursor: pointer; border-radius: 4px; border: none; font-weight: bold; margin-left: 5px; }
    .btn-list { background-color: #6c757d; color: white; }
    .btn-edit { background-color: #ffc107; color: #333; } /* 수정 버튼 색상 추가 */
    .btn-del { background-color: #dc3545; color: white; }
</style>
</head>
<body>

<div class="detail_box">
    <div class="detail_header">
        <div class="detail_title">📁 <%= msg.getTitle() %></div>
        <div class="detail_info">
            <span><b>등록자:</b> <%= msg.getUser_id() %></span>
            <span><b>등록일:</b> <%= sdf.format(msg.getCreated_at()) %></span>
        </div>
    </div>
    
    <% if(msg.getFile_path() != null && !msg.getFile_path().equals("")) { %>
        <div class="file_box">
            💾 <b>첨부파일:</b> 
            <a href="../upload/<%= msg.getFile_path() %>" download="<%= msg.getFile_path() %>"><%= msg.getFile_path() %></a>
        </div>
    <% } else { %>
        <div class="file_box" style="background-color: #f8f9fa; border: 1px solid #dee2e6; color: #6c757d;">
            ❌ 첨부된 파일이 없습니다.
        </div>
    <% } %>
    
    <div class="detail_content"><%= msg.getContent() %></div>
    
    <div class="btn_wrap">
        <% if(userId.equals(msg.getUser_id())) { %>
            <button type="button" class="btn-edit" onclick="location.href='updateMaterialForm.jsp?message_id=<%= message_id %>&channel_id=<%= channel_id %>'">수정</button>
            <button type="button" class="btn-del" onclick="if(confirm('이 강의자료를 정말 삭제하시겠습니까?')) location.href='deleteNoticePro.jsp?message_id=<%= message_id %>&channel_id=<%= channel_id %>&menu=material'">삭제</button>
        <% } %>
        <button type="button" class="btn-list" onclick="location.href='lectureMain.jsp?channel_id=<%= channel_id %>&menu=material'">목록으로</button>
    </div>
</div>

</body>
</html>