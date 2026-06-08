<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    // 1. 에러 방지를 위한 안전한 세션 체크 (실습 때 배운 방식)
    String id = (String) session.getAttribute("id");
    if (id == null) id = (String) session.getAttribute("user_id"); 
    
    // 2. role(권한) 체크 중 발생하는 에러 원천 차단
    Object roleObj = session.getAttribute("role");
    String roleStr = String.valueOf(roleObj);
    
    // 로그인이 안 되어 있거나 교수가 아니면(role이 1이 아니면) 접근 차단
    if (id == null || !roleStr.equals("1")) {
%>
        <script>
            alert("강의실 개설은 교수 권한이 필요합니다.");
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
<title>새 강의실 만들기</title>
<link href="../css/common.css" rel="stylesheet" type="text/css">
<link href="../css/board.css" rel="stylesheet" type="text/css">
</head>
<body>

<%-- 
<header>
  <jsp:include page="../module/header.jsp" flush="false"/>
</header> 
--%>

<section>
  <h2>강의실 관리 > 새 강의실 생성</h2>
  <div id="board_box">
  <form name="channel_form" method="post" action="createChannelPro.jsp">
     <ul id="board_form">
        <li>
            <span class="col1">&nbsp;&nbsp;강의실 이름</span>
            <span class="col2"><input name="channel_name" type="text" placeholder="예: 2026 자바프로그래밍" required></span>
        </li>       
        <li>
            <span class="col1">&nbsp;&nbsp;입장 코드</span>
            <span class="col2"><input name="entry_code" type="text" placeholder="예: JAVA2026" required></span>
        </li>           
    </ul>
    <ul class="buttons">
        <li><button type="submit">채널 생성</button></li>
        <li><button type="button" onclick="history.go(-1)">취소</button></li>
    </ul>
  </form>
  </div>
</section>

<%-- 
<footer>
  <jsp:include page="../module/footer.jsp" flush="false"/>
</footer> 
--%>
</body>
</html>