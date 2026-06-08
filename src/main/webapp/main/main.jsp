<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String user_id = (String)session.getAttribute("user_id");
	int role = (Integer)session.getAttribute("role");
	String name = (String)session.getAttribute("name");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>Insert title here</title>
</head>
<body>
	로그인된 아이디 : <%= user_id %><br />
	로그인된 권한 : <%= role == 0 ? "학생" : "교사" %><br />
	로그인한 이름 : <%= name %>
</body>
</html>