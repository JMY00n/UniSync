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
        session.setAttribute("user_id",   member.getUser_id());
        session.setAttribute("name",      member.getName());
        session.setAttribute("role",      member.getRole());
        response.sendRedirect("../dashboard/dashboard.jsp");

    } else if (result == 0) {
        request.setAttribute("loginError", "아이디 또는 비밀번호가 올바르지 않습니다.");
        request.getRequestDispatcher("/login/login.jsp").forward(request, response);

    } else if (result == -1) {
        request.setAttribute("loginError", "등록되지 않은 아이디입니다.");
        request.getRequestDispatcher("/login/login.jsp").forward(request, response);

    } else {
        request.setAttribute("loginError", "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
        request.getRequestDispatcher("/login/login.jsp").forward(request, response);
    }
%>
