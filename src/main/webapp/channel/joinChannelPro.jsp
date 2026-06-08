<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.ChannelDAO" %>
<%@ page import="channel.ChannelVO" %>
<% request.setCharacterEncoding("utf-8"); %>

<%
    String entry_code = request.getParameter("entry_code");
    
    // 세션에서 사용자 ID 가져오기
    String userId = (String) session.getAttribute("user_id");
    if (userId == null) userId = (String) session.getAttribute("id");

    if (userId == null) {
%>
        <script>
            alert("로그인 세션이 만료되었습니다. 다시 로그인해 주세요.");
            location.href = "../login/login.jsp";
        </script>
<%
        return;
    }

    ChannelDAO cdao = ChannelDAO.getInstance();
    
    // 1. 입력한 코드로 만들어진 방이 있는지 검색
    ChannelVO channel = cdao.getChannelByCode(entry_code);

    if (channel != null) {
        // 2. 방이 존재하면 가입 처리 (channel_list 테이블에 추가)
        int result = cdao.joinChannel(channel.getChannel_id(), userId);
        
        if (result > 0) {
%>
            <script>
                alert("<%= channel.getChannel_name() %> 강의실에 성공적으로 입장했습니다!");
                // 404 에러 방지를 위해 프로젝트명을 포함한 절대 경로로 수정!
                location.href = "/App/dashboard/dashboard.jsp"; 
            </script>
<%
        } else {
%>
            <script>
                alert("이미 입장한 강의실이거나 가입 중 오류가 발생했습니다.");
                history.go(-1);
            </script>
<%
        }
    } else {
%>
        <script>
            alert("존재하지 않거나 잘못된 입장 코드입니다. 다시 확인해 주세요.");
            history.go(-1);
        </script>
<%
    }
%>