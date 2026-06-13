<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.MessageDAO" %>
<%
    int message_id = Integer.parseInt(request.getParameter("message_id"));
    String channel_id = request.getParameter("channel_id");

    MessageDAO mdao = MessageDAO.getInstance();
    boolean isSuccess = mdao.deleteMessage(message_id);

    if(isSuccess) {
%>
        <script>
            alert("삭제되었습니다.");
            location.href = "../lectures/lectureMain.jsp?channel_id=<%= channel_id %>&menu=notice";
        </script>
<%
    } else {
%>
        <script>alert("삭제 실패!"); history.go(-1);</script>
<%
    }
%>