<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.ChannelDAO" %>
<% request.setCharacterEncoding("utf-8"); %>

<%
    String id = (String) session.getAttribute("user_id");
    if (id == null) id = (String) session.getAttribute("id");
    
    if (id == null) {
%>
        <script>alert("세션이 만료되었습니다."); location.href="../login/login.jsp";</script>
<%
        return;
    }

    int channel_id = Integer.parseInt(request.getParameter("channel_id"));
    String new_name = request.getParameter("channel_name");

    ChannelDAO cdao = ChannelDAO.getInstance();
    boolean isSuccess = cdao.updateChannelName(channel_id, new_name);

    if (isSuccess) {
%>
        <script>
            alert("강의실 이름이 수정되었습니다.");
            location.href = "../dashboard/dashboard.jsp";
        </script>
<%
    } else {
%>
        <script>
            alert("수정에 실패했습니다.");
            history.go(-1);
        </script>
<%
    }
%>