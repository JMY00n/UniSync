<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원가입</title>
<script>
	var isIdChecked = false;
	
	function checkId() {
		let userId = document.getElementById("user_id").value;
		
		if (userId == "") {
			alert("아이디를 입력해주세요.");
			return;
		}
		let popupWidth = 400;
		let popupHeight = 300;
		
		let popupX = (window.screen.width / 2) - (popupWidth / 2);
		let popupY = (window.screen.height / 2) - (popupHeight / 2);
		
		window.open(
		        "memberCheckId.jsp?user_id=" + userId, 
		        "idwin", 
		        "width=" + popupWidth + ", height=" + popupHeight + ", left=" + popupX + ", top=" + popupY
		    );
	}
	
	function validateForm() {
		if (!isIdChecked) {
			alert("아이디 중복 검사를 먼저 해주세요.");
			return false;
		}
		return true;
	}
</script>
</head>
<body>
	<div>
		<h2>회원가입</h2>
		<form method="post" action="registerPro.jsp" onsubmit="return validateForm()">
			<input type="text" placeholder="아이디" name="user_id" id="user_id" required="required">
			<button type="button" onclick="checkId()">중복 검사</button> <br />
			<input type="password" placeholder="비밀번호" name="password" required="required"><br />
			<input type="text" placeholder="이름" name="name" required="required"><br />
			<input type="radio" name="role" value="0" />학생
			<input type="radio" name="role" value="1" />교사 <br />
			<input type="submit" value="회원가입"/>
		</form>
	</div>
</body>
</html>