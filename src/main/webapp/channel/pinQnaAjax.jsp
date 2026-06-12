<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.MessageDAO" %>
<%
    // 교수 권한 체크
    Integer role = (Integer) session.getAttribute("role");
    if(role == null || role != 1) { 
        out.print("fail"); return; 
    }

    int channel_id = Integer.parseInt(request.getParameter("channel_id"));
    int message_id = Integer.parseInt(request.getParameter("message_id"));
    boolean isPin = Boolean.parseBoolean(request.getParameter("is_pin"));

    MessageDAO mdao = MessageDAO.getInstance();
    boolean result = mdao.setPinnedMessage(channel_id, message_id, isPin);

    if(result) out.print("success");
    else out.print("fail");
%>