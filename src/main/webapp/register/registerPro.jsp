<%@page import="javax.tools.DocumentationTool.Location"%>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO" %>

<%
	request.setCharacterEncoding("utf-8");
%>
<jsp:useBean id="member" class="member.MemberVO">
	<jsp:setProperty name="member" property="*" />
</jsp:useBean>
<%
	MemberDAO mDAO = MemberDAO.getinstance();
	mDAO.register(member);
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>회원가입 중...</title>
</head>
<body>
	<script>
		location.href = "../login/login.jsp";
	</script>
</body>
</html>