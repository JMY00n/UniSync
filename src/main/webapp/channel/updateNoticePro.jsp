<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="channel.MessageDAO" %>
<%@ page import="channel.MessageVO" %>
<%
    request.setCharacterEncoding("utf-8");
    String savePath = request.getServletContext().getRealPath("/upload");
    int maxSize = 10 * 1024 * 1024;
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
        msg.setFile_path(fileName); // 파일이 없으면 null이 들어감
        
        MessageDAO mdao = MessageDAO.getInstance();
        boolean isSuccess = mdao.updateMessage(msg);
        
        if(isSuccess) {
%>
            <script>
                alert("수정되었습니다.");
                location.href = "noticeDetail.jsp?message_id=<%= message_id %>&channel_id=<%= channel_id %>";
            </script>
<%
        } else {
%>
            <script>alert("수정 실패!"); history.go(-1);</script>
<%
        }
    } catch(Exception e) {
        e.printStackTrace();
        out.println("<script>alert('오류 발생'); history.go(-1);</script>");
    }
%>