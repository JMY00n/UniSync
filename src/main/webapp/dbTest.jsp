<%@page import="java.io.PrintWriter"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="javax.naming.Context" %>
<%@ page import="javax.naming.InitialContext" %>
<%@ page import="javax.sql.DataSource" %>
<%@ page import="java.sql.Connection" %>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>DB 연결 테스트</title>
</head>
<body>
	<%
		Connection conn = null;
		try {
			Context initCtx = new InitialContext();
			DataSource ds = (DataSource) initCtx.lookup("java:comp/env/jdbc/app");
			conn = ds.getConnection();
			out.println("<h3>DBCP 연결 성공! 톰캣 커넥션 풀이 정상 작동합니다.</h3>");
		} catch (Exception e) {
			out.println("<h3>DBCP 연결 실패...</h3>");
			e.printStackTrace(new PrintWriter(out));
		} finally {
			if (conn != null) conn.close();
		}
	%>
</body>
</html>