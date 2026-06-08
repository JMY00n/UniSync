<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO" %>
<%@ page import="member.MemberVO" %>

<% request.setCharacterEncoding("utf-8"); %>

<%
    String user_id  = request.getParameter("user_id");
    String password = request.getParameter("password");

    MemberDAO mDAO = MemberDAO.getinstance();
    int result = -2;
    try {
        result = mDAO.login(user_id, password);
    } catch (Exception e) {
        e.printStackTrace();
    }

    if (result == 1) {
        MemberVO member = null;
        try { member = mDAO.getMember(user_id); } catch (Exception e) { e.printStackTrace(); }
        session.setAttribute("user_id", member.getUser_id());
        session.setAttribute("name",    member.getName());
        session.setAttribute("role",    member.getRole());
        response.sendRedirect("../dashboard/dashboard.jsp");
    } else if (result == 0) {
%>
        <script>
            alert("비밀번호가 맞지 않습니다.");
            history.go(-1);
        </script>
<%
    } else if (result == -1) {
%>
        <script>
            alert("등록된 아이디가 아닙니다.");
            history.go(-1);
        </script>
<%
    } else {
%>
        <script>
            alert("서버 오류가 발생했습니다.");
            history.go(-1);
        </script>
<%
    }
%>
