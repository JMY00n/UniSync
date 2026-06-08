<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="member.MemberDAO" %>
<%
    request.setCharacterEncoding("utf-8");
    String user_id = request.getParameter("user_id");
    MemberDAO mDAO = MemberDAO.getinstance();
    int check = mDAO.validate(user_id);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>아이디 중복 확인</title>
<link rel="stylesheet" href="../css/login.css">
<style>
  body {
    display: flex;
    align-items: center;
    justify-content: center;
    min-height: 100vh;
    margin: 0;
    background: var(--bg);
  }
  .popup-card {
    background: var(--surface);
    border: 1px solid var(--border-m);
    border-radius: var(--rl);
    padding: 32px 28px;
    width: 320px;
    text-align: center;
  }
  .icon-circle {
    width: 52px;
    height: 52px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    margin: 0 auto 16px;
    font-size: 24px;
  }
  .icon-circle.success { background: #E1F5EE; color: #0F6E56; }
  .icon-circle.error   { background: #FCEBEB; color: #A32D2D; }
  .popup-title {
    font-size: 15px;
    font-weight: 700;
    color: var(--text);
    margin: 0 0 6px;
  }
  .popup-desc {
    font-size: 13px;
    color: var(--text2);
    margin: 0 0 22px;
    line-height: 1.5;
  }
  .popup-btn {
    width: 100%;
    padding: 11px;
    border-radius: var(--r);
    font-size: 14px;
    font-weight: 700;
    font-family: var(--font);
    cursor: pointer;
    border: none;
    transition: background 0.14s;
  }
  .popup-btn.primary {
    background: var(--primary);
    color: #fff;
  }
  .popup-btn.primary:hover { background: var(--primary-hover); }
  .popup-btn.secondary {
    background: var(--bg);
    color: var(--text2);
    border: 1px solid var(--border-m);
  }
  .popup-btn.secondary:hover { background: var(--primary-light); }
</style>
<script>
  function useId() {
    opener.isIdChecked = true;
    self.close();
  }
</script>
</head>
<body>

<% if (check == 0) { %>
  <div class="popup-card">
    <div class="icon-circle error"><img src="../images/icons/x.svg" width="22" height="22" alt="오류" style="filter:brightness(0) saturate(100%) invert(20%) sepia(80%) saturate(2000%) hue-rotate(330deg);"></div>
    <p class="popup-title">이미 사용 중인 아이디입니다.</p>
    <p class="popup-desc">다른 아이디를 입력해 주세요.</p>
    <button class="popup-btn secondary" onclick="self.close()">닫기</button>
  </div>
<% } else { %>
  <div class="popup-card">
    <div class="icon-circle success"><img src="../images/icons/check.svg" width="22" height="22" alt="확인" style="filter:brightness(0) saturate(100%) invert(25%) sepia(60%) saturate(800%) hue-rotate(120deg);"></div>
    <p class="popup-title">사용 가능한 아이디입니다.</p>
    <p class="popup-desc">이 아이디로 가입을 진행할 수 있습니다.</p>
    <button class="popup-btn primary" onclick="useId()">이 아이디 사용하기</button>
  </div>
<% } %>

</body>
</html>
