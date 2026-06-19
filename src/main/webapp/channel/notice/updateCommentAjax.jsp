<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.CommentDAO" %>
<%@ page import="channel.CommentVO" %>
<%
    request.setCharacterEncoding("utf-8");
    String userId = (String) session.getAttribute("user_id");
    if(userId == null) userId = (String) session.getAttribute("id");

    if(userId == null) { out.print("fail"); return; }

    int comment_id = Integer.parseInt(request.getParameter("comment_id"));
    String content = request.getParameter("content");

    CommentDAO cdao = CommentDAO.getInstance();
    CommentVO c = cdao.getCommentById(comment_id);

    // 보안 팩트 체크: 다른 사람이 임의로 수정하는 걸 방지
    if(c != null && c.getUser_id().equals(userId)) {
        c.setContent(content); // 내용만 덮어씀

        boolean isSuccess = cdao.updateComment(c);
        if(isSuccess) out.print("success");
        else out.print("fail");
    } else {
        out.print("fail");
    }
%>
