<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.CommentDAO" %>
<%@ page import="channel.CommentVO" %>
<%
    request.setCharacterEncoding("utf-8");
    String userId = (String) session.getAttribute("user_id");
    if(userId == null) userId = (String) session.getAttribute("id");

    // 로그인이 안 되어 있으면 실패 반환
    if(userId == null) {
        out.print("fail");
        return;
    }

    int message_id = Integer.parseInt(request.getParameter("message_id"));
    String content = request.getParameter("content");

    CommentVO c = new CommentVO();
    c.setMessage_id(message_id);
    c.setUser_id(userId);
    c.setContent(content);

    CommentDAO cdao = CommentDAO.getInstance();
    boolean isSuccess = cdao.insertComment(c);

    // 성공하면 프론트엔드로 success 글자만 딱 보냄 (새로고침 안 함)
    if(isSuccess) out.print("success");
    else out.print("fail");
%>
