<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.ChannelDAO" %>
<%@ page import="channel.ChannelVO" %>
<%
    String id = (String) session.getAttribute("id");
    if (id == null) id = (String) session.getAttribute("user_id");
    if (id == null) {
%>
        <script>alert("로그인이 필요합니다."); location.href="../login/login.jsp";</script>
<%
        return;
    }

    // 수정할 방 번호 가져오기
    int channel_id = Integer.parseInt(request.getParameter("channel_id"));
    ChannelDAO cdao = ChannelDAO.getInstance();
    ChannelVO channel = cdao.getChannelById(channel_id);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>강의실 이름 수정</title>
<link href="../css/common.css" rel="stylesheet" type="text/css">
<link href="../css/board.css" rel="stylesheet" type="text/css">
</head>
<body>
<section>
  <h2>강의실 관리 > 강의실 이름 수정</h2>
  <div id="board_box">
  <form method="post" action="updateChannelPro.jsp">
     <input type="hidden" name="channel_id" value="<%= channel.getChannel_id() %>">
     
     <ul id="board_form">
        <li>
            <span class="col1">&nbsp;&nbsp;새 강의실 이름</span>
            <span class="col2"><input name="channel_name" type="text" value="<%= channel.getChannel_name() %>" required></span>
        </li>        
    </ul>
    <ul class="buttons">
        <li><button type="submit">수정 완료</button></li>
        <li><button type="button" onclick="history.go(-1)">취소</button></li>
    </ul>
  </form>
  </div>
</section>
</body>
</html>