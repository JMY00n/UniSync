<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String id = (String) session.getAttribute("id");
    if (id == null) id = (String) session.getAttribute("user_id"); 
    
    Object roleObj = session.getAttribute("role");
    String roleStr = String.valueOf(roleObj);
    
    // 로그인이 안 되어 있거나 학생이 아니면(role이 0이 아니면) 접근 차단
    if (id == null || !roleStr.equals("0")) {
%>
        <script>
            alert("강의실 입장은 학생 권한이 필요합니다.");
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
<title>강의실 입장하기</title>
<link href="../css/common.css" rel="stylesheet" type="text/css">
<link href="../css/board.css" rel="stylesheet" type="text/css">
</head>
<body>

<section>
  <h2>나의 강의실 > 새 강의실 입장</h2>
  <div id="board_box">
  <form name="join_form" method="post" action="joinChannelPro.jsp">
     <ul id="board_form">
        <li>
            <span class="col1">&nbsp;&nbsp;입장 코드</span>
            <span class="col2"><input name="entry_code" type="text" placeholder="교수님이 알려주신 코드를 입력하세요" required></span>
        </li>           
    </ul>
    <ul class="buttons">
        <li><button type="submit">강의실 입장</button></li>
        <li><button type="button" onclick="history.go(-1)">취소</button></li>
    </ul>
  </form>
  </div>
</section>

</body>
</html>