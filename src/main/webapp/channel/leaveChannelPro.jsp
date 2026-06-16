<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.ChannelDAO" %>
<% request.setCharacterEncoding("utf-8"); %>

<%
    // 1. 보안 체크 (로그인 안 된 사람 튕겨내기)
    String id = (String) session.getAttribute("user_id");
    if (id == null) id = (String) session.getAttribute("id");

    if (id == null) {
%>
        <script>
            alert("로그인 세션이 만료되었습니다.");
            location.href = "../login/login.jsp";
        </script>
<%
        return;
    }

    // 2. 나갈 방 번호 받아오기 (숫자 가드)
    String channelIdStr = request.getParameter("channel_id");

    if (channelIdStr != null && channelIdStr.matches("\\d+")) {
        int channel_id = Integer.parseInt(channelIdStr);

        // 3. DAO를 통해 참여 목록에서 본인 행만 삭제
        ChannelDAO cdao = ChannelDAO.getInstance();
        boolean isSuccess = cdao.leaveChannel(channel_id, id);

        if (isSuccess) {
%>
            <script>
                alert("강의실에서 나갔습니다.");
                location.href = "../dashboard/dashboard.jsp";
            </script>
<%
        } else {
%>
            <script>
                alert("강의실 나가기 중 오류가 발생했거나, 참여 중인 강의실이 아닙니다.");
                location.href = "../dashboard/dashboard.jsp";
            </script>
<%
        }
    } else {
%>
        <script>
            alert("잘못된 접근입니다.");
            history.go(-1);
        </script>
<%
    }
%>
