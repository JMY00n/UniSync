<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.ChannelDAO" %>
<%@ page import="channel.ChannelVO" %>
<%@ page import="java.util.ArrayList" %>
<%
    // 1. 세션 정보 가져오기 (방어 코드 적용)
    String userId = (String)session.getAttribute("user_id");
    if (userId == null) userId = (String)session.getAttribute("id");
    
    Object roleObj = session.getAttribute("role");
    String name = (String)session.getAttribute("name");

    // 로그인이 풀렸거나 비정상 접근 시 로그인 페이지로 튕겨내기
    if (userId == null || roleObj == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    int role = (Integer)roleObj; // 1: 교사, 0: 학생
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>UniSync 대시보드</title>
<link href="../css/common.css" rel="stylesheet" type="text/css">
<link href="../css/board.css" rel="stylesheet" type="text/css">
<style>
    .dashboard_main { width: 680px; margin: 30px auto; padding: 20px; border: 1px solid #ccc; font-family: sans-serif; border-radius: 8px; }
    .channel_list_box { margin-top: 20px; border-top: 2px solid #516e7f; padding-top: 15px; }
    .channel_item { padding: 12px; border-bottom: 1px solid #eee; display: flex; justify-content: space-between; align-items: center; }
    .channel_item:hover { background-color: #f9f9f9; }
    
    /* 버튼 디자인 */
    .btn-update {
        padding: 4px 10px; font-size: 12px; background-color: #28a745; color: white; border: none; border-radius: 4px; cursor: pointer; transition: 0.2s;
    }
    .btn-update:hover { background-color: #218838; }
    
    .btn-delete {
        padding: 4px 10px; font-size: 12px; background-color: #dc3545; color: white; border: none; border-radius: 4px; cursor: pointer; transition: 0.2s;
    }
    .btn-delete:hover { background-color: #c82333; }
</style>
</head>
<body>
<div class="dashboard_main">
    <h2>UniSync 시스템 대시보드</h2>
    <hr>
    
    <div style="background: #f1f8ff; padding: 15px; border-radius: 5px; margin-bottom: 20px;">
        <b>로그인 아이디:</b> <%= userId %> <br>
        <b>현재 권한:</b> <%= role == 0 ? "<span style='color:green;'>학생</span>" : "<span style='color:blue;'>교수</span>" %> <br>
        <b>사용자 이름:</b> <%= name %> 
        <button type="button" onclick="location.href='../login/logoutPro.jsp'" style="float: right;">로그아웃</button>
        <div style="clear: both;"></div>
    </div>
    
    <div class="channel_list_box">
        <h3>📚 나의 강의실 목록</h3>
        <%
            ChannelDAO cdao = ChannelDAO.getInstance();
            
            // =========================================================
            // [1] 교사 권한 (role == 1) 화면
            // =========================================================
            if (role == 1) { 
        %>
                <div style="margin-bottom: 15px; text-align: right;">
                    <button type="button" onclick="location.href='../channel/createChannelForm.jsp'">+ 새 강의실 개설</button>
                </div>
        <%
                ArrayList<ChannelVO> channelList = cdao.getChannelsByProfessor(userId);
                if (channelList.isEmpty()) {
        %>
                    <p style="color:gray; text-align:center; padding: 20px;">개설된 강의실이 없습니다. 새 강의실을 만들어보세요!</p>
        <%
                } else {
                    for (ChannelVO c : channelList) {
        %>
                        <div class="channel_item">
                            <a href="../channel/lectureMain.jsp?channel_id=<%= c.getChannel_id() %>" style="font-weight:bold; color:#516e7f; text-decoration:none; font-size: 16px;">
                                🚪 <%= c.getChannel_name() %>
                            </a>
                            
                            <div style="display: flex; align-items: center; gap: 8px;">
                                <span style="color:#555; font-size:13px; margin-right: 10px;">입장 코드: <b style="color:#d32f2f; letter-spacing: 1px;"><%= c.getEntry_code() %></b></span>
                                
                                <button type="button" class="btn-update" 
                                        onclick="location.href='../channel/updateChannelForm.jsp?channel_id=<%= c.getChannel_id() %>';">
                                    수정
                                </button>
                                
                                <button type="button" class="btn-delete" 
                                        onclick="if(confirm('정말 [<%= c.getChannel_name() %>] 강의실을 삭제하시겠습니까?\n참여한 학생 정보도 모두 삭제되며 복구할 수 없습니다.')) location.href='../channel/deleteChannelPro.jsp?channel_id=<%= c.getChannel_id() %>';">
                                    삭제
                                </button>
                            </div>
                        </div>
        <%
                    }
                }
                
            // =========================================================
            // [2] 학생 권한 (role == 0) 화면
            // =========================================================
            } else { 
        %>
                <div style="margin-bottom: 15px; text-align: right;">
                    <button type="button" onclick="location.href='../channel/joinChannelForm.jsp'">+ 새 강의실 입장 (코드 입력)</button>
                </div>
        <%
                ArrayList<ChannelVO> studentChannels = cdao.getChannelsByStudent(userId);
                if (studentChannels.isEmpty()) {
        %>
                    <p style="color:gray; text-align:center; padding: 20px;">아직 입장한 강의실이 없습니다. 코드를 입력해 입장해 보세요!</p>
        <%
                } else {
                    for (ChannelVO c : studentChannels) {
        %>
                        <div class="channel_item">
                            <a href="../channel/lectureMain.jsp?channel_id=<%= c.getChannel_id() %>" style="font-weight:bold; color:#2e7d32; text-decoration:none; font-size: 16px;">
                                📝 <%= c.getChannel_name() %>
                            </a>
                            
                            <span style="color:#888; font-size:13px;">개설 교수: <b><%= c.getUser_id() %></b></span>
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