<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="channel.MessageDAO" %>
<%@ page import="channel.MessageVO" %>
<%
    request.setCharacterEncoding("utf-8");
    String savePath = request.getServletContext().getRealPath("/upload");
    int maxSize = 20 * 1024 * 1024; // 자료실이니까 20MB
    String encoding = "UTF-8";
    
    try {
        MultipartRequest multi = new MultipartRequest(request, savePath, maxSize, encoding, new DefaultFileRenamePolicy());
        
        int message_id = Integer.parseInt(multi.getParameter("message_id"));
        String channel_id = multi.getParameter("channel_id");
        String title = multi.getParameter("title");
        String content = multi.getParameter("content");
        String fileName = multi.getFilesystemName("uploadFile"); 
        
        MessageVO msg = new MessageVO();
        msg.setMessage_id(message_id);
        msg.setTitle(title);
        msg.setContent(content);
        msg.setFile_path(fileName); 
        
        MessageDAO mdao = MessageDAO.getInstance();
        boolean isSuccess = mdao.updateMessage(msg);
        
        if(isSuccess) {
%>
            <script>
                alert("강의자료가 수정되었습니다.");
                location.href = "materialDetail.jsp?message_id=<%= message_id %>&channel_id=<%= channel_id %>";
            </script>
<%
        } else {
%>
            <script>alert("수정 실패!"); history.go(-1);</script>
<%
        }
    } catch(Exception e) {
        e.printStackTrace();
        out.println("<script>alert('파일 용량이 너무 크거나 에러가 발생했습니다.'); history.go(-1);</script>");
    }
%>