<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO" %>
<%@ page import="member.MemberVO" %>
<%
	String user_id = request.getParameter("user_id");
	String password = request.getParameter("password");
	int role = Integer.parseInt(request.getParameter("role"));
	
	MemberDAO mDAO = MemberDAO.getinstance();
	// mDAO.login으로 유저 체크하고 이후 로직처리
	int result = mDAO.login(user_id, password, role);
	if (result == 1) {
		MemberVO member = mDAO.getMember(user_id);
		session.setAttribute("user_id", user_id);
		session.setAttribute("role", role);
		session.setAttribute("name", member.getName());
		
		response.sendRedirect("../main/main.jsp");
	} else if (result == -2) {
		out.print("Server ERROR!!!!");
	} else {
		out.print("아이디 또는 비밀번호또는 권한이 일치하지 않습니다.");
	}
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>로그인 중...</title>
</head>
<body>

</body>
</html>