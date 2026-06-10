<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String roleParam = request.getParameter("role");
    int role = (roleParam != null) ? Integer.parseInt(roleParam) : 0;
    String roleLabel = (role == 1) ? "교수" : "학생";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>UniSync — 회원가입</title>
<link rel="stylesheet" href="../css/common.css">
<link rel="stylesheet" href="../css/login.css">
<script>
    var isIdChecked = false;

    function checkId() {
        var userId = document.getElementById("user_id").value;
        if (userId == "") {
            alert("아이디를 입력해주세요.");
            return;
        }
        var popupWidth  = 400;
        var popupHeight = 300;
        var popupX = (window.screen.width  / 2) - (popupWidth  / 2);
        var popupY = (window.screen.height / 2) - (popupHeight / 2);
        window.open(
            "memberCheckId.jsp?user_id=" + userId,
            "idwin",
            "width=" + popupWidth + ", height=" + popupHeight + ", left=" + popupX + ", top=" + popupY
        );
    }

    // 팝업에서 "이 아이디 사용하기" 누르면 호출됨
    var checkedId = "";
    function onIdChecked() {
        var input = document.getElementById("user_id");
        var btn   = document.getElementById("idCheckBtn");
        var msg   = document.getElementById("idCheckMsg");

        isIdChecked = true;
        checkedId   = input.value;

        input.classList.add("input-ok");
        btn.textContent = "확인 완료";
        btn.classList.add("btn-id-checked");
        btn.disabled = true;

        msg.textContent = "✓ 사용 가능한 아이디입니다.";
        msg.className   = "id-check-msg ok";
    }

    // 확인 후 아이디를 바꾸면 다시 검사하도록 초기화
    function resetIdCheck() {
        var input = document.getElementById("user_id");
        if (input.value === checkedId) return;

        var btn = document.getElementById("idCheckBtn");
        var msg = document.getElementById("idCheckMsg");

        isIdChecked = false;
        input.classList.remove("input-ok");
        btn.textContent = "중복 확인";
        btn.classList.remove("btn-id-checked");
        btn.disabled = false;
        msg.textContent = "";
        msg.className   = "id-check-msg";
    }

    function validateForm() {
        if (!isIdChecked) {
            alert("아이디 중복 검사를 먼저 해주세요.");
            return false;
        }
        var pw  = document.member_form.password.value;
        var pw2 = document.member_form.password2.value;
        if (pw != pw2) {
            alert("비밀번호가 일치하지 않습니다.\n다시 입력해 주세요.");
            document.member_form.password.focus();
            document.member_form.password.select();
            return false;
        }
        return true;
    }
</script>
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
          <img src="../images/icons/message-square.svg" width="18" height="18" alt="Q&A">
        </div>
        <div class="feature-text">
          <strong>실시간 익명 Q&amp;A</strong>
          <span>질문 부담 없이, 수업에 집중</span>
        </div>
      </div>
      <div class="feature-item">
        <div class="feature-icon">
          <img src="../images/icons/clock.svg" width="18" height="18" alt="강의 관리">
        </div>
        <div class="feature-text">
          <strong>채널 기반 강의 관리</strong>
          <span>공지 · Q&amp;A · 자료실 한 곳에서</span>
        </div>
      </div>
      <div class="feature-item">
        <div class="feature-icon">
          <img src="../images/icons/chart-no-axes-column.svg" width="18" height="18" alt="권한 분리">
        </div>
        <div class="feature-text">
          <strong>교수/학생 권한 분리</strong>
          <span>역할에 맞는 맞춤형 화면 제공</span>
        </div>
      </div>
    </div>
  </div>

  <!-- ══ 오른쪽 폼 패널 ══ -->
  <div class="form-panel register-panel">
    <div class="form-inner register-inner">

      <a href="../login/login.jsp" class="back-btn">
        <img src="../images/icons/chevron-left.svg" width="15" height="15" alt="뒤로">
        돌아가기
      </a>

      <div class="form-header">
        <div style="display:flex; align-items:center; gap:14px; margin-bottom:4px;">
          <div class="reg-icon-box <%= role == 1 ? "reg-icon-prof" : "reg-icon-student" %>">
            <% if (role == 1) { %>
            <img src="../images/icons/briefcase-business.svg" width="24" height="24" alt="교수" style="filter:brightness(0) invert(1);">
            <% } else { %>
            <img src="../images/icons/graduation-cap.svg" width="24" height="24" alt="학생" style="filter:brightness(0) invert(1);">
            <% } %>
          </div>
          <div>
            <div class="form-title" style="margin-bottom:1px;"><%= roleLabel %> 회원가입</div>
            <div class="form-sub" style="margin-top:1px;"><%= role == 1 ? "교번과 비밀번호를 입력하여 가입하세요." : "학번과 비밀번호를 입력하여 가입하세요." %></div>
          </div>
        </div>
      </div>

      <form name="member_form" method="post" action="registerPro.jsp" onsubmit="return validateForm()" autocomplete="off">
        <%-- role hidden으로 고정 --%>
        <input type="hidden" name="role" value="<%= role %>">

        <div class="field-group">
          <label class="field-label" for="user_id">아이디 (<%= role == 1 ? "교번" : "학번" %>)</label>
          <div style="display:flex; gap:8px;">
            <input class="field-input" id="user_id" name="user_id" type="text"
                   placeholder="<%= role == 1 ? "예: P2024001" : "예: 2021038" %>" required style="flex:1;"
                   oninput="resetIdCheck()">
            <button type="button" id="idCheckBtn" onclick="checkId()" class="btn-id-check">중복 확인</button>
          </div>
          <p id="idCheckMsg" class="id-check-msg"></p>
        </div>

        <div class="field-group">
          <label class="field-label" for="reg_pw">비밀번호</label>
          <input class="field-input" id="reg_pw" name="password" type="password"
                 placeholder="비밀번호 입력" required>
        </div>

        <div class="field-group">
          <label class="field-label" for="reg_pw2">비밀번호 확인</label>
          <input class="field-input" id="reg_pw2" name="password2" type="password"
                 placeholder="비밀번호 재입력" required>
        </div>

        <div class="field-group">
          <label class="field-label" for="reg_name">이름</label>
          <input class="field-input" id="reg_name" name="name" type="text"
                 placeholder="홍길동" required>
        </div>

        <button type="submit" class="btn-submit <%= role == 1 ? "btn-submit-prof" : "" %>">
          <%= roleLabel %>으로 가입하기
        </button>
      </form>

    </div>
  </div>
</div>
</body>
</html>
