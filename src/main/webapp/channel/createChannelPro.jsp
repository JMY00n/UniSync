<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.ChannelDAO" %>
<%@ page import="java.util.Random" %>
<% request.setCharacterEncoding("utf-8"); %>

<jsp:useBean id="channel" class="channel.ChannelVO">
    <jsp:setProperty name="channel" property="*" />
</jsp:useBean>

<%
    // 1. 세션에서 로그인한 교수의 아이디 가져오기
    String id = (String) session.getAttribute("user_id");
    if (id == null) id = (String) session.getAttribute("id");
    
    if (id == null) {
%>
        <script>
            alert("로그인 세션이 만료되었습니다. 다시 로그인해 주세요.");
            location.href = "../login/login.jsp";
        </script>
<%
        return;
    }

    // 2. 0~9 숫자로만 구성된 8자리 랜덤 코드 만들기 (이 부분이 핵심!)
    String numbers = "0123456789";
    StringBuilder sb = new StringBuilder();
    Random random = new Random();
    
    for (int i = 0; i < 8; i++) {
        int index = random.nextInt(numbers.length());
        sb.append(numbers.charAt(index));
    }
    String generatedCode = sb.toString(); // 예: "48201937" 완성

    // 3. 폼에서 넘어온 방 이름 외에, 교수 아이디와 방금 만든 숫자 코드를 강제로 세팅
    channel.setUser_id(id);
    channel.setEntry_code(generatedCode);

    // 4. DB에 저장
    ChannelDAO cdao = ChannelDAO.getInstance();
    boolean isSuccess = cdao.createChannel(channel);

    if (isSuccess) {
%>
        <script>
            alert("성공적으로 강의실이 생성되었습니다!\n[입장 코드 : <%= generatedCode %>]");
            location.href = "../dashboard/dashboard.jsp";
        </script>
<%
    } else {
%>
        <script>
            alert("강의실 생성에 실패했습니다. 다시 시도해 주세요.");
            history.go(-1);
        </script>
<%
    }
%>