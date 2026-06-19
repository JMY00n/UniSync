<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.ChannelDAO" %>
<% request.setCharacterEncoding("utf-8"); %>

<%
    // 1. 로그인 체크
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

    // 2. 파라미터 수신 + 가드
    String channelIdStr = request.getParameter("channel_id");
    String channelName = request.getParameter("channel_name");

    if (channelIdStr == null || !channelIdStr.matches("\\d+") || channelName == null || channelName.trim().isEmpty()) {
%>
        <script>
            alert("잘못된 접근입니다.");
            location.href = "../dashboard/dashboard.jsp";
        </script>
<%
        return;
    }

    int channel_id = Integer.parseInt(channelIdStr);

    // 3. DAO 호출 — 이름만 변경
    ChannelDAO cdao = ChannelDAO.getInstance();
    boolean isSuccess = cdao.updateChannelName(channel_id, channelName.trim());

    if (isSuccess) {
%>
        <script>
            alert("강의실 이름이 변경되었습니다.");
            location.href = "../dashboard/dashboard.jsp";
        </script>
<%
    } else {
%>
        <script>
            alert("강의실 이름 변경에 실패했습니다.");
            location.href = "../dashboard/dashboard.jsp";
        </script>
<%
    }
%>