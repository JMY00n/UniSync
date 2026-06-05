<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>로그인</title>
</head>
<body>
	<div>
		<h2>로그인</h2>
		<form method="post" action="loginPro.jsp"> <!-- 액션 및, 메서드 = post 작성 -->
			<input type="text" placeholder="아이디" name="user_id" required="required"><br />
			<input type="password" placeholder="비밀번호" name="password" required="required"><br />
			<input type="radio" name="role" value="0" />학생
			<input type="radio" name="role" value="1" />교사 <br />
			<input type="submit" value="로그인"/>
		</form>
	</div>
</body>
</html>