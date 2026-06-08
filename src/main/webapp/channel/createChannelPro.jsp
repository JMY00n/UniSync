<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.ChannelDAO" %>
<% request.setCharacterEncoding("utf-8"); %>

<jsp:useBean id="channel" class="channel.ChannelVO">
    <jsp:setProperty name="channel" property="*" />
</jsp:useBean>

<%
    // 세션에서 방을 개설하는 교수의 아이디를 가져와 VO에 세팅
    String id = (String) session.getAttribute("id");
    if (id == null) id = (String) session.getAttribute("user_id");
    channel.setUser_id(id);

    // DB에 채널 정보 저장
    ChannelDAO cdao = ChannelDAO.getInstance();
    cdao.createChannel(channel);
%>

<script>
    alert("성공적으로 강의실이 생성되었습니다!");
    // 존재하는 페이지인 대시보드 화면으로 경로 수정!
    location.href = "../dashboard/dashboard.jsp";
</script>