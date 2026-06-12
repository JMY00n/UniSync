<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.MessageDAO" %>
<%@ page import="channel.MessageVO" %>
<%
    request.setCharacterEncoding("utf-8");
    String userId = (String) session.getAttribute("user_id");
    if(userId == null) userId = (String) session.getAttribute("id");
    
    // 로그인이 안 되어 있으면 실패 반환
    if(userId == null) { 
        out.print("fail"); 
        return; 
    }

    int channel_id = Integer.parseInt(request.getParameter("channel_id"));
    String content = request.getParameter("content");

    MessageVO msg = new MessageVO();
    msg.setChannel_id(channel_id);
    msg.setBoard_name("Q&A"); // 게시판 이름을 'Q&A'로 고정
    msg.setUser_id(userId);
    msg.setTitle(userId + "님의 질문"); // Slido 형식은 제목이 따로 없으므로 자동 생성
    msg.setContent(content);

    MessageDAO mdao = MessageDAO.getInstance();
    boolean isSuccess = mdao.insertMessage(msg);

    // 성공하면 프론트엔드로 success 글자만 딱 보냄 (새로고침 안 함)
    if(isSuccess) out.print("success");
    else out.print("fail");
%>