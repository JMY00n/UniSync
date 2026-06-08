<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%-- 이미 로그인된 경우 대시보드로 리다이렉트 --%>
<% if (session.getAttribute("user_id") != null) {
     response.sendRedirect(request.getContextPath() + "/dashboard/dashboard.jsp");
     return;
   }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>UniSync — 로그인</title>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/css/login.css">
</head>
<body>
<div class="login-wrap">

  <!-- ══ 왼쪽 브랜드 패널 ══ -->
  <div class="brand-panel">
    <div class="brand-top">
      <div class="brand-logo">Uni<span>Sync</span></div>
    </div>
    <div class="brand-mid">
      <div class="brand-headline">
        질문의 장벽을 낮추고,<br>
        <em>수업의 데이터를</em><br>
        높이다.
      </div>
    </div>
    <div class="brand-features">
      <div class="feature-item">
        <div class="feature-icon">
          <img src="${pageContext.request.contextPath}/images/icons/message-square.svg" width="18" height="18" alt="Q&A">
        </div>
        <div class="feature-text">
          <strong>실시간 익명 Q&amp;A</strong>
          <span>질문 부담 없이, 수업에 집중</span>
        </div>
      </div>
      <div class="feature-item">
        <div class="feature-icon">
          <img src="${pageContext.request.contextPath}/images/icons/clock.svg" width="18" height="18" alt="강의 관리">
        </div>
        <div class="feature-text">
          <strong>채널 기반 강의 관리</strong>
          <span>공지 · Q&amp;A · 자료실 한 곳에서</span>
        </div>
      </div>
      <div class="feature-item">
        <div class="feature-icon">
          <img src="${pageContext.request.contextPath}/images/icons/chart-no-axes-column.svg" width="18" height="18" alt="권한 분리">
        </div>
        <div class="feature-text">
          <strong>교수/학생 권한 분리</strong>
          <span>역할에 맞는 맞춤형 화면 제공</span>
        </div>
      </div>
    </div>
  </div>

  <!-- ══ 오른쪽 폼 패널 ══ -->
  <div class="form-panel">
    <div class="form-inner">

      <!-- ── 로그인 폼 ── -->
      <div id="formLogin">
        <div class="form-header">
          <div class="form-title">로그인</div>
          <div class="form-sub">학번 또는 교번으로 로그인하세요.</div>
        </div>

        <%-- 로그인 실패 메시지 --%>
        <% String loginError = (String) request.getAttribute("loginError");
           if (loginError != null) { %>
          <div class="login-error-wrap">
            <div class="login-error">
              <img src="${pageContext.request.contextPath}/images/icons/x.svg" width="15" height="15" alt="오류" style="filter:brightness(0) saturate(100%) invert(25%) sepia(80%) saturate(1500%) hue-rotate(330deg); flex-shrink:0;">
              <%= loginError %>
            </div>
          </div>
        <% } %>

        <form method="post" action="${pageContext.request.contextPath}/login/loginPro.jsp" autocomplete="off">
          <div class="field-group">
            <label class="field-label" for="loginId">아이디 (학번 / 교번)</label>
            <input class="field-input" id="loginId" name="user_id" type="text"
                   placeholder="예: 2021038" required>
          </div>
          <div class="field-group">
            <label class="field-label" for="loginPw">비밀번호</label>
            <div class="pw-wrap">
              <input class="field-input" id="loginPw" name="password" type="password"
                     placeholder="비밀번호 입력" required>
              <button type="button" class="pw-eye" onclick="togglePw('loginPw',this)">
                <img class="eye-off" src="${pageContext.request.contextPath}/images/icons/eye-off.svg" width="17" height="17" alt="숨기기">
                <img class="eye-on"  src="${pageContext.request.contextPath}/images/icons/eye.svg" width="17" height="17" alt="보이기" style="display:none;">
              </button>
            </div>
          </div>
          <button type="submit" class="btn-submit">로그인</button>
        </form>

        <div class="form-divider"><span>처음이신가요?</span></div>
        <div class="slide-tabs" id="regTabs">
          <div class="slide-indicator" id="regIndicator"></div>
          <button class="stab-btn stab-active" id="stab-s"
                  onmouseenter="hoverTab('s')" onmouseleave="leaveTab()" onclick="selectTab('s')">
            <img src="${pageContext.request.contextPath}/images/icons/graduation-cap.svg" width="15" height="15" alt="학생">
            학생으로 가입
          </button>
          <button class="stab-btn" id="stab-p"
                  onmouseenter="hoverTab('p')" onmouseleave="leaveTab()" onclick="selectTab('p')">
            <img src="${pageContext.request.contextPath}/images/icons/briefcase-business.svg" width="15" height="15" alt="교수">
            교수자로 가입
          </button>
        </div>
      </div>



    </div>
  </div>
</div>

<script>
  var selectedTab = 's';
  function hoverTab(side) {
    document.getElementById('regTabs').classList.toggle('tab-right', side === 'p');
    document.getElementById('stab-s').classList.toggle('stab-active', side === 's');
    document.getElementById('stab-p').classList.toggle('stab-active', side === 'p');
  }
  function leaveTab() {
    document.getElementById('regTabs').classList.toggle('tab-right', selectedTab === 'p');
    document.getElementById('stab-s').classList.toggle('stab-active', selectedTab === 's');
    document.getElementById('stab-p').classList.toggle('stab-active', selectedTab === 'p');
  }
  function selectTab(side) {
    selectedTab = side;
    leaveTab();
    var role = (side === 's') ? 0 : 1;
    location.href = '${pageContext.request.contextPath}/register/register.jsp?role=' + role;
  }
  function togglePw(id, btn) {
    var inp = document.getElementById(id);
    var isText = inp.type === 'text';
    inp.type = isText ? 'password' : 'text';
    btn.querySelector('.eye-off').style.display = isText ? '' : 'none';
    btn.querySelector('.eye-on').style.display  = isText ? 'none' : '';
    btn.style.color = isText ? '' : 'var(--primary)';
  }
</script>
</body>
</html>
