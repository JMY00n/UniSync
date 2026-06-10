<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.ChannelDAO" %>
<%@ page import="channel.ChannelVO" %>
<%
    // 1. 대시보드에서 클릭하고 넘어온 강의실 번호(channel_id) 받기
    String idParam = request.getParameter("channel_id");
    if (idParam == null) {
%>
        <script>
            alert("잘못된 접근입니다.");
            history.go(-1);
        </script>
<%
        return;
    }
    int channel_id = Integer.parseInt(idParam);

    // 2. 방금 추가한 DAO 메서드를 써서 DB에서 이 방의 정보(입장 코드 등)를 가져오기
    ChannelDAO cdao = ChannelDAO.getInstance();
    ChannelVO channel = cdao.getChannelById(channel_id);

    if (channel == null) {
%>
        <script>
            alert("존재하지 않는 강의실입니다.");
            history.go(-1);
        </script>
<%
        return;
    }
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title><%= channel.getChannel_name() %> - UniSync</title>
<link href="../css/common.css" rel="stylesheet" type="text/css">
<style>
    /* 방 코드와 타이틀이 예쁘게 보이도록 박스 디자인 */
    .room_header {
        border: 2px solid #516e7f;
        padding: 20px;
        margin: 20px auto;
        width: 700px;
        border-radius: 8px;
        font-family: sans-serif;
    }
    .entry_code_box {
        background-color: #ffebee;
        padding: 5px 10px;
        border-radius: 5px;
        font-weight: bold;
        color: #d32f2f;
        font-size: 18px;
        letter-spacing: 2px; /* 숫자가 잘 보이게 간격 넓힘 */
    }
</style>
</head>
<body>

    <div class="room_header">
        <h2 style="margin-top: 0;">📚 <%= channel.getChannel_name() %></h2>
        <p style="margin-bottom: 0;">
            👨‍🏫 개설 교수: <%= channel.getUser_id() %> &nbsp;|&nbsp; 
            🔑 학생 입장 코드: <span class="entry_code_box"><%= channel.getEntry_code() %></span>
        </p>
        <div style="margin-top: 15px; text-align: right;">
            <button onclick="location.href='../dashboard/dashboard.jsp'">나가기 (대시보드)</button>
        </div>
    </div>

    <div style="width: 700px; margin: 0 auto; text-align: center; color: gray;">
        <hr>
        <br>
        <h3>이곳에 서브 게시판(공지사항, Q&A) 목록이 들어갈 예정입니다.</h3>
    </div>

</body>
</html>