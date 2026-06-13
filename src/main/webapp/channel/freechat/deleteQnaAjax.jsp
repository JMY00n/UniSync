<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.MessageDAO" %>
<%@ page import="channel.MessageVO" %>
<%
    request.setCharacterEncoding("utf-8");
    String userId = (String) session.getAttribute("user_id");
    if(userId == null) userId = (String) session.getAttribute("id");

    if(userId == null) { out.print("fail"); return; }

    int message_id = Integer.parseInt(request.getParameter("message_id"));

    MessageDAO mdao = MessageDAO.getInstance();
    MessageVO msg = mdao.getMessageById(message_id);

    // 보안 체크: 본인이 작성한 글만 삭제 허용
    if(msg != null && msg.getUser_id().equals(userId)) {
        boolean isSuccess = mdao.deleteMessage(message_id);
        if(isSuccess) out.print("success");
        else out.print("fail");
    } else {
        out.print("fail");
    }
%>
