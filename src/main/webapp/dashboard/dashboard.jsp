<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.ChannelDAO" %>
<%@ page import="channel.ChannelVO" %>
<%@ page import="java.util.ArrayList" %>
<%
    String user_id = (String)session.getAttribute("user_id");
    Object roleObj = session.getAttribute("role");
    String name = (String)session.getAttribute("name");

    if (user_id == null || roleObj == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    int role = (Integer)roleObj;
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>UniSync 대시보드</title>
<link href="../css/common.css" rel="stylesheet" type="text/css">
<link href="../css/board.css" rel="stylesheet" type="text/css">
<style>
    .dashboard_main { width: 600px; margin: 30px auto; padding: 20px; border: 1px solid #ccc; font-family: sans-serif; }
    .channel_list_box { margin-top: 20px; border-top: 2px solid #516e7f; padding-top: 15px; }
    .channel_item { padding: 10px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center; }
</style>
</head>
<body>
<div class="dashboard_main">
    <h2>UniSync 시스템 대시보드</h2>
    <hr>
    
    로그인된 아이디 : <%= user_id %><br />
    로그인된 권한 : <%= role == 0 ? "학생" : "교사" %><br />
    로그인한 이름 : <%= name %>
    <button onclick="location.href='../login/logoutPro.jsp'">로그아웃</button>
    
    <div class="channel_list_box">
        <h3>📚 나의 강의실 목록</h3>
        <%
            ChannelDAO cdao = ChannelDAO.getInstance();
            
            if (role == 1) { // ════ 교사 권한 목록 ════
        %>
                <div style="margin-bottom: 15px; text-align: right;">
                    <button type="button" onclick="location.href='../channel/createChannelForm.jsp'">+ 새 강의실 개설</button>
                </div>
        <%
                ArrayList<ChannelVO> channelList = cdao.getChannelsByProfessor(user_id);
                if (channelList.isEmpty()) {
        %>
                    <p style="color:gray; text-align:center;">개설된 강의실이 없습니다. 새 강의실을 만들어보세요!</p>
        <%
                } else {
                    for (ChannelVO c : channelList) {
        %>
                        <div class="channel_item">
                            <a href="../channel/lectureMain.jsp?channel_id=<%= c.getChannel_id() %>" style="font-weight:bold; color:#516e7f; text-decoration:none;">
                                🚪 <%= c.getChannel_name() %>
                            </a>
                            <span style="color:#888; font-size:12px;">입장 코드: <b><%= c.getEntry_code() %></b></span>
                        </div>
        <%
                    }
                }
            } else { // ════ 학생 권한 목록 (업데이트 완료) ════
        %>
                <div style="margin-bottom: 15px; text-align: right;">
                    <button type="button" onclick="location.href='../channel/joinChannelForm.jsp'">+ 새 강의실 입장 (코드 입력)</button>
                </div>
        <%
                // 학생이 가입한 방 목록을 DB에서 뽑아옴
                ArrayList<ChannelVO> studentChannels = cdao.getChannelsByStudent(user_id);
                if (studentChannels.isEmpty()) {
        %>
                    <p style="color:gray; text-align:center;">아직 입장한 강의실이 없습니다. 코드를 입력해 입장해 보세요!</p>
        <%
                } else {
                    for (ChannelVO c : studentChannels) {
        %>
                        <div class="channel_item">
                            <a href="../channel/lectureMain.jsp?channel_id=<%= c.getChannel_id() %>" style="font-weight:bold; color:#2e7d32; text-decoration:none;">
                                📝 <%= c.getChannel_name() %>
                            </a>
                            <span style="color:#888; font-size:12px;">개설 교수: <b><%= c.getUser_id() %></b></span>
                        </div>
        <%
                    }
                }
            }
        %>
    </div>
</div>
</body>
</html>