<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.MessageDAO" %>
<%@ page import="channel.MessageVO" %>
<%
    request.setCharacterEncoding("utf-8");

//1. 현재 로그인한 사용자의 세션 아이디 확인
    String userId = (String) session.getAttribute("user_id");
    if(userId == null) userId = (String) session.getAttribute("id");

    if(userId == null) { out.print("fail"); return; }

    int message_id = Integer.parseInt(request.getParameter("message_id"));

    MessageDAO mdao = MessageDAO.getInstance();
    MessageVO msg = mdao.getMessageById(message_id);

 // 2. 글 작성자와 로그인한 유저가 일치하는지 확인 (권한 검증)
    if(msg != null && msg.getUser_id().equals(userId)) {
    	// 본인이 맞으면 삭제 진행
        boolean isSuccess = mdao.deleteMessage(message_id);
        if(isSuccess) out.print("success");
     // 권한이 없으면 삭제 거부
        else out.print("fail");
    } else {
        out.print("fail");
    }
%>
