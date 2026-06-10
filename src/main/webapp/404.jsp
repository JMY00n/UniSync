<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page isErrorPage="true" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>UniSync — 404</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/common.css">
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css">
  <style>
    body {
      display: flex;
      align-items: center;
      justify-content: center;
      min-height: 100vh;
      margin: 0;
      background: var(--bg);
    }
    .error-box {
      text-align: center;
      padding: 48px 40px;
      max-width: 440px;
    }
    .error-num {
      font-family: var(--brand);
      font-size: 100px;
      font-weight: 800;
      line-height: 1;
      letter-spacing: -4px;
      background: linear-gradient(135deg, #342F92, #6B65C8);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
      margin-bottom: 12px;
    }
    .error-title {
      font-family: var(--brand);
      font-size: 20px;
      font-weight: 700;
      color: var(--text);
      margin: 0 0 10px;
    }
    .error-desc {
      font-size: 14px;
      color: var(--text2);
      line-height: 1.7;
      margin: 0 0 32px;
    }
    .error-btn {
      display: inline-flex;
      align-items: center;
      gap: 8px;
      background: var(--primary);
      color: #fff;
      padding: 12px 28px;
      border-radius: var(--r);
      font-size: 14px;
      font-weight: 700;
      text-decoration: none;
      font-family: var(--font);
      transition: background 0.14s;
    }
    .error-btn:hover { background: var(--primary-hover); }
  </style>
</head>
<body>
  <div class="error-box">
    <div class="error-num">404</div>
    <p class="error-title">페이지를 찾을 수 없습니다.</p>
    <p class="error-desc">요청하신 페이지가 존재하지 않거나<br>이동되었을 수 있습니다.</p>
    <a href="${pageContext.request.contextPath}/login/login.jsp" class="error-btn">
      로그인 화면으로 돌아가기
    </a>
  </div>
</body>
</html>
