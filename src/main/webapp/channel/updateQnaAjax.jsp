<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.MessageDAO" %>
<%@ page import="channel.MessageVO" %>
<%
    request.setCharacterEncoding("utf-8");
    String userId = (String) session.getAttribute("user_id");
    if(userId == null) userId = (String) session.getAttribute("id");
    
    if(userId == null) { out.print("fail"); return; }

    int message_id = Integer.parseInt(request.getParameter("message_id"));
    String content = request.getParameter("content");

    MessageDAO mdao = MessageDAO.getInstance();
    MessageVO msg = mdao.getMessageById(message_id);

    // 보안 팩트 체크: 다른 사람이 임의로 수정하는 걸 방지
    if(msg != null && msg.getUser_id().equals(userId)) {
        msg.setContent(content); // 내용만 덮어씀
        
        boolean isSuccess = mdao.updateMessage(msg);
        if(isSuccess) out.print("success");
        else out.print("fail");
    } else {
        out.print("fail");
    }
%>