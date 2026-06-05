<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO" %>
<%
	request.setCharacterEncoding("utf-8");

	String user_id = request.getParameter("user_id");
	
	MemberDAO mDAO = MemberDAO.getinstance();
	int check = mDAO.validate(user_id);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
<script>
	function useId() {
		opener.isIdChecked = true;
		/* opener.document.getElementsByName("user_id")[0].readOnly = true; */
		self.close();
	}
</script>
</head>
<body>
	<% if (check == 0) { %> 
		<p style="color: red;">이미 존재하는 아이디입니다.</p>
		<button onclick="self.close()">닫기</button>
	<% } else { %>
		<p style="color: blue;">가입 가능한 아이디입니다.</p>
		<button onclick="useId()">이 아이디 사용하기</button>
	<% } %>
</body>
</html>