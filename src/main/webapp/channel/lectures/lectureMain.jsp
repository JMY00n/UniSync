<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.ChannelDAO" %>
<%@ page import="channel.ChannelVO" %>
<%@ page import="channel.MessageDAO" %>
<%@ page import="channel.MessageVO" %>
<%@ page import="member.MemberVO" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%!
    // 아이콘/아바타용 앞 2글자
    String two(String s) {
        if (s == null) return "";
        String x = s.replaceAll("\\s", "");
        return x.length() <= 2 ? x : x.substring(0, 2);
    }
    // 아바타용 앞 1글자
    String one(String s) {
        if (s == null) return "";
        String x = s.replaceAll("\\s", "");
        return x.isEmpty() ? "" : x.substring(0, 1);
    }
    // 회원 id 기반 고정 아바타 색상 (Q&A와 동일 팔레트 → 화면마다 같은 사람은 같은 색)
    static final String[] AV_COLORS = {
        "#6B65C8", "#1D9E75", "#D9803F", "#C0508F",
        "#3F8FD9", "#D94F4F", "#8A6FE0", "#2FA8A8"
    };
    String avatarColor(String s) {
        if (s == null || s.isEmpty()) return AV_COLORS[0];
        int h = 0;
        for (int i = 0; i < s.length(); i++) h = h * 31 + s.charAt(i);
        return AV_COLORS[Math.abs(h) % AV_COLORS.length];
    }
%>
<%
    // 1. 세션 체크
    String id = (String) session.getAttribute("user_id");
    if (id == null) id = (String) session.getAttribute("id");
    Object roleObj = session.getAttribute("role");
    if (id == null || roleObj == null) {
        response.sendRedirect("../../login/login.jsp");
        return;
    }
    int role = (Integer) roleObj; // 1: 교수, 0: 학생
    boolean isProf = (role == 1);
    String name = (String) session.getAttribute("name");
    if (name == null || name.trim().isEmpty()) name = id;

    // 2. 방 번호
    String idParam = request.getParameter("channel_id");
    if (idParam == null) {
        response.sendRedirect("../../dashboard/dashboard.jsp");
        return;
    }
    int channel_id = Integer.parseInt(idParam);

    // 3. 방 정보
    ChannelDAO cdao = ChannelDAO.getInstance();
    ChannelVO channel = cdao.getChannelById(channel_id);
    if (channel == null) {
        response.sendRedirect("../../dashboard/dashboard.jsp");
        return;
    }

    // 4. 현재 메뉴 (notice / material / qna)
    String menu = request.getParameter("menu");
    if (menu == null) menu = "notice";

    // 5. 레일용 내 채널 목록 + 우측 멤버 명단
    ArrayList<ChannelVO> myChannels = isProf ? cdao.getChannelsByProfessor(id) : cdao.getChannelsByStudent(id);
    ArrayList<MemberVO> members = cdao.getChannelMembers(channel_id);
    int profCount = 0, stuCount = 0;
    for (MemberVO mv : members) { if (mv.getRole() == 1) profCount++; else stuCount++; }

    // 6. 게시판 제목
    String boardTitle;
    if (menu.equals("material"))  boardTitle = "강의자료";
    else if (menu.equals("qna"))  boardTitle = "Q&A";
    else                          boardTitle = "공지사항";

    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title><%= channel.getChannel_name() %> - UniSync</title>
<link href="../../css/common.css" rel="stylesheet" type="text/css">
<link href="../../css/lectureMain.css" rel="stylesheet" type="text/css">
</head>
<body>
<div class="lm-app">

  <!-- ══════════ 레일 ══════════ -->
  <div class="rail">
    <a class="rail-logo" href="../../dashboard/dashboard.jsp" title="대시보드">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
    </a>
    <div class="rail-div"></div>
    <%
        int ri = 0;
        for (ChannelVO c : myChannels) {
            String cls = "c" + ((ri % 3) + 1);
            String act = (c.getChannel_id() == channel_id) ? " active" : "";
    %>
    <a class="ri <%= cls %><%= act %>" href="lectureMain.jsp?channel_id=<%= c.getChannel_id() %>" title="<%= c.getChannel_name() %>"><%= two(c.getChannel_name()) %></a>
    <%      ri++;
        }
    %>
    <div class="rail-bot">
      <a class="r-ic" href="../../login/logoutPro.jsp" title="로그아웃">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><path d="m16 17 5-5-5-5"/><path d="M21 12H9"/></svg>
      </a>
    </div>
  </div>

  <!-- ══════════ 채널 사이드바 ══════════ -->
  <div class="ch-side">
    <div class="ch-side-top">
      <div class="ch-name"><%= channel.getChannel_name() %></div>
      <div class="ch-code">코드 <span class="ch-code-val"><%= channel.getEntry_code() %></span></div>
    </div>
    <div class="ch-side-nav">
      <div class="nav-sec">게시판</div>
      <a class="nav-item<%= menu.equals("notice") ? " active" : "" %>" href="lectureMain.jsp?channel_id=<%= channel_id %>&menu=notice">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m3 11 18-5v12L3 14v-3z"/><path d="M11.6 16.8a3 3 0 1 1-5.8-1.6"/></svg>
        공지사항
      </a>
      <a class="nav-item<%= menu.equals("material") ? " active" : "" %>" href="lectureMain.jsp?channel_id=<%= channel_id %>&menu=material">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 20h16a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13c0 1.1.9 2 2 2Z"/></svg>
        강의자료
      </a>
      <a class="nav-item<%= menu.equals("qna") ? " active" : "" %>" href="lectureMain.jsp?channel_id=<%= channel_id %>&menu=qna">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M7.9 20A9 9 0 1 0 4 16.1L2 22Z"/></svg>
        Q&amp;A
      </a>
    </div>
    <div class="ch-side-me">
      <div class="me-av" style="background:<%= avatarColor(id) %>; color:#fff;"><%= one(name) %></div>
      <div class="me-info">
        <div class="me-name"><%= name %></div>
        <div class="me-role"><%= isProf ? "교수" : "학생" %></div>
      </div>
    </div>
  </div>

  <!-- ══════════ 메인(게시판 본문) ══════════ -->
  <div class="lm-main">
    <div class="lm-top">
      <div class="lm-title">
        <span class="lm-title-ic">
        <% if (menu.equals("material")) { %>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 20h16a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13c0 1.1.9 2 2 2Z"/></svg>
        <% } else if (menu.equals("qna")) { %>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M7.9 20A9 9 0 1 0 4 16.1L2 22Z"/></svg>
        <% } else { %>
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m3 11 18-5v12L3 14v-3z"/><path d="M11.6 16.8a3 3 0 1 1-5.8-1.6"/></svg>
        <% } %>
        </span>
        <%= boardTitle %>
      </div>
      <div class="lm-actions">
        <% if (isProf && menu.equals("notice")) { %>
        <button type="button" class="btn-write" onclick="openWriteModal()">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>공지 작성
        </button>
        <% } else if (isProf && menu.equals("material")) { %>
        <button type="button" class="btn-write" onclick="openWriteModal()">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>자료 올리기
        </button>
        <% } %>
        <button type="button" class="btn-exit" onclick="location.href='../../dashboard/dashboard.jsp'">나가기</button>
      </div>
    </div>

    <div class="lm-body">

      <%-- ===== 공지사항 ===== --%>
      <% if (menu.equals("notice")) {
            MessageDAO mdao = MessageDAO.getInstance();
            ArrayList<MessageVO> noticeList = mdao.getMessageList(channel_id, "공지사항");
      %>
        <% if (noticeList.isEmpty()) { %>
          <div class="board-empty">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="m3 11 18-5v12L3 14v-3z"/><path d="M11.6 16.8a3 3 0 1 1-5.8-1.6"/></svg>
            <div>등록된 공지사항이 없습니다.</div>
          </div>
        <% } else { %>
          <table class="board-table">
            <thead><tr><th class="col-no">번호</th><th>제목</th><th class="col-date">작성날짜</th><th class="col-file">첨부</th></tr></thead>
            <tbody>
            <% int count = noticeList.size();
               for (MessageVO msg : noticeList) { %>
              <tr onclick="location.href='../notice/noticeDetail.jsp?message_id=<%= msg.getMessage_id() %>&channel_id=<%= channel_id %>'">
                <td class="col-no"><%= count-- %></td>
                <td class="col-title"><a href="../notice/noticeDetail.jsp?message_id=<%= msg.getMessage_id() %>&channel_id=<%= channel_id %>"><%= msg.getTitle() %></a></td>
                <td class="col-date"><%= sdf.format(msg.getCreated_at()) %></td>
                <td class="col-file">
                  <% if (msg.getFile_path() != null && !msg.getFile_path().equals("")) { %>
                    <span class="file-ico" title="첨부파일 있음" style="display:inline-flex;align-items:center;justify-content:center;color:var(--primary);">
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="16" height="16"><path d="M21.4 11.05 12.25 20.2a5 5 0 0 1-7.07-7.07l9.19-9.19a3 3 0 0 1 4.24 4.24l-9.2 9.19a1 1 0 0 1-1.41-1.41l8.49-8.5"/></svg>
                    </span>
                  <% } else { %><span class="dash">-</span><% } %>
                </td>
              </tr>
            <% } %>
            </tbody>
          </table>
        <% } %>

      <%-- ===== 강의자료 ===== --%>
      <% } else if (menu.equals("material")) {
            MessageDAO mdaoMaterial = MessageDAO.getInstance();
            ArrayList<MessageVO> materialList = mdaoMaterial.getMessageList(channel_id, "강의자료");
      %>
        <% if (materialList.isEmpty()) { %>
          <div class="board-empty">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round"><path d="M4 20h16a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13c0 1.1.9 2 2 2Z"/></svg>
            <div>등록된 강의자료가 없습니다.</div>
          </div>
        <% } else { %>
          <table class="board-table">
            <thead><tr><th class="col-no">번호</th><th>자료 제목</th><th class="col-date">등록일</th><th class="col-file">다운로드</th></tr></thead>
            <tbody>
            <% int count = materialList.size();
               for (MessageVO msg : materialList) { %>
              <tr onclick="location.href='materialDetail.jsp?message_id=<%= msg.getMessage_id() %>&channel_id=<%= channel_id %>'">
                <td class="col-no"><%= count-- %></td>
                <td class="col-title"><a href="materialDetail.jsp?message_id=<%= msg.getMessage_id() %>&channel_id=<%= channel_id %>"><%= msg.getTitle() %></a></td>
                <td class="col-date"><%= sdf.format(msg.getCreated_at()) %></td>
                <td class="col-file">
                  <% if (msg.getFile_path() != null && !msg.getFile_path().equals("")) { %>
                    <a href="../../upload/<%= msg.getFile_path() %>" download="<%= msg.getFile_path() %>" title="다운로드" onclick="event.stopPropagation();" style="display:inline-flex;align-items:center;justify-content:center;color:#1D9E75;">
                      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="17" height="17"><path d="M12 3v12"/><path d="m7 12 5 5 5-5"/><path d="M5 21h14"/></svg>
                    </a>
                  <% } else { %><span class="dash">-</span><% } %>
                </td>
              </tr>
            <% } %>
            </tbody>
          </table>
        <% } %>

      <%-- ===== Q&A (기존 AJAX 로직 그대로) ===== --%>
      <% } else if (menu.equals("qna")) { %>
        <div class="qna-writer">
          <textarea id="qnaContent" rows="2" placeholder="궁금한 점을 자유롭게 남겨보세요!"></textarea>
          <button type="button" onclick="submitQna()">등록</button>
        </div>
        <div id="qnaListArea" class="qna-list"></div>

        <%-- Q&A 수정 글래스 모달 (리스트 밖 → 3초 새로고침에 안 지워짐) --%>
        <div class="wm-overlay" id="qnaEditModal" onclick="if(event.target===this) closeQnaEdit()">
          <div class="wm-glass" style="width:560px;">
            <div class="wm-head">
              <div class="wm-icon">
                <svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>
              </div>
              <div class="wm-titles">
                <div class="wm-title">질문 수정</div>
                <div class="wm-sub">내용을 수정하고 저장하세요.</div>
              </div>
              <button type="button" class="wm-x" onclick="closeQnaEdit()">✕</button>
            </div>
            <div class="wm-field">
              <label class="wm-label">내용</label>
              <textarea class="wm-textarea" id="qnaEditText" style="min-height:160px;"></textarea>
            </div>
            <div class="wm-actions">
              <button type="button" class="wm-cancel" onclick="closeQnaEdit()">취소</button>
              <button type="button" class="wm-go" onclick="saveQnaEdit()">저장</button>
            </div>
          </div>
        </div>

        <script>
          const channelId = <%= channel_id %>;

          function loadQnaList() {
            fetch('../freechat/getQnaListAjax.jsp?channel_id=' + channelId)
              .then(response => response.text())
              .then(html => { document.getElementById('qnaListArea').innerHTML = html; })
              .catch(error => console.error('Error:', error));
          }

       // 입력창의 질문 내용을 백엔드로 전송하는 비동기 함수
          function submitQna() {
            const contentObj = document.getElementById('qnaContent');
            const content = contentObj.value.trim();
            if (!content) { alert('내용을 입력해주세요.'); contentObj.focus(); return; }

            fetch('../freechat/writeQnaAjax.jsp', {
              method: 'POST',
              headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
              body: 'channel_id=' + channelId + '&content=' + encodeURIComponent(content)
            })
            .then(response => response.text())
            .then(result => {
            	// DB 저장에 성공하면 입력창을 비우고 게시글 목록만 새로 고침
              if (result.trim() === 'success') { contentObj.value = ''; loadQnaList(); }
              else { alert('글 등록에 실패했습니다.'); }
            })
            .catch(error => console.error('Error:', error));
          }

          let editingQnaId = null;
          function editQna(messageId) {
            const contentDiv = document.getElementById('qna_content_' + messageId);
            editingQnaId = messageId;
            document.getElementById('qnaEditText').value = contentDiv.innerText;
            document.getElementById('qnaEditModal').classList.add('open');
            document.getElementById('qnaEditText').focus();
          }
          function closeQnaEdit() {
            document.getElementById('qnaEditModal').classList.remove('open');
            editingQnaId = null;
          }
          function saveQnaEdit() {
            const content = document.getElementById('qnaEditText').value;
            if (content.trim() === '') { alert('내용을 입력해주세요.'); return; }
            fetch('../freechat/updateQnaAjax.jsp', {
              method: 'POST',
              headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
              body: 'message_id=' + editingQnaId + '&content=' + encodeURIComponent(content.trim())
            })
            .then(response => response.text())
            .then(result => {
              if (result.trim() === 'success') { closeQnaEdit(); loadQnaList(); }
              else { alert('수정에 실패했습니다. 본인 글인지 확인해주세요.'); }
            })
            .catch(error => console.error('Error:', error));
          }

          function deleteQna(messageId) {
            if (!confirm('이 메시지를 삭제할까요?')) return;
            fetch('../freechat/deleteQnaAjax.jsp', {
              method: 'POST',
              headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
              body: 'message_id=' + messageId
            })
            .then(response => response.text())
            .then(result => {
              if (result.trim() === 'success') { loadQnaList(); }
              else { alert('삭제에 실패했습니다. 본인 글인지 확인해주세요.'); }
            })
            .catch(error => console.error('Error:', error));
          }

          function togglePin(messageId, isPin) {
            fetch('../freechat/pinQnaAjax.jsp', {
              method: 'POST',
              headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
              body: 'channel_id=' + channelId + '&message_id=' + messageId + '&is_pin=' + isPin
            })
            .then(response => response.text())
            .then(result => {
              if (result.trim() === 'success') { loadQnaList(); }
              else { alert('권한이 없거나 처리에 실패했습니다.'); }
            })
            .catch(error => console.error('Error:', error));
          }

          window.onload = function() {
            loadQnaList();
            setInterval(loadQnaList, 3000);
          };
        </script>
      <% } %>

    </div><!-- /lm-body -->
  </div><!-- /lm-main -->

  <!-- ══════════ 우측 멤버 명단 (온/오프라인 없이 인원 구성만) ══════════ -->
  <div class="mem-side">
    <div class="mem-head">참여 멤버 <span class="mem-count"><%= members.size() %></span></div>

    <div class="mem-group">교수 <span><%= profCount %></span></div>
    <% for (MemberVO mv : members) { if (mv.getRole() != 1) continue; %>
      <div class="mem">
        <div class="mem-av prof" style="background:<%= avatarColor(mv.getUser_id()) %>; color:#fff;"><%= one(mv.getName()) %></div>
        <div class="mem-info">
          <div class="mem-name"><%= mv.getName() %></div>
          <div class="mem-sub">교수</div>
        </div>
      </div>
    <% } %>

    <div class="mem-group">학생 <span><%= stuCount %></span></div>
    <% if (stuCount == 0) { %>
      <div class="mem-empty">아직 입장한 학생이 없어요.</div>
    <% } %>
    <% for (MemberVO mv : members) { if (mv.getRole() == 1) continue; %>
      <div class="mem">
        <div class="mem-av" style="background:<%= avatarColor(mv.getUser_id()) %>; color:#fff;"><%= one(mv.getName()) %></div>
        <div class="mem-info">
          <div class="mem-name"><%= mv.getName() %></div>
          <div class="mem-sub">학생 · <%= mv.getUser_id() %></div>
        </div>
      </div>
    <% } %>
  </div>

  <%-- ══════════ 글쓰기 글래스 모달 (공지/자료, 교수만) ══════════ --%>
  <% if (isProf && (menu.equals("notice") || menu.equals("material"))) {
       String wAction, wBoard, wTitle, wSub, wPh1, wPh2;
       if (menu.equals("material")) {
         wAction = "writeMaterialPro.jsp"; wBoard = "강의자료";
         wTitle = "강의자료 등록"; wSub = "학생들이 내려받을 강의자료를 올려주세요.";
         wPh1 = "예: [1주차] 강의 슬라이드"; wPh2 = "자료 설명을 입력하세요.";
       } else {
         wAction = "../notice/writeNoticePro.jsp"; wBoard = "공지사항";
         wTitle = "공지사항 작성"; wSub = "학생들에게 전달할 공지를 작성하세요.";
         wPh1 = "공지사항 제목을 입력하세요."; wPh2 = "공지사항 내용을 입력하세요.";
       }
  %>
  <div class="wm-overlay" id="writeModal" onclick="if(event.target===this) closeWriteModal()">
    <div class="wm-glass">
      <div class="wm-head">
        <div class="wm-icon">
          <% if (menu.equals("material")) { %>
            <svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 20h16a2 2 0 0 0 2-2V8a2 2 0 0 0-2-2h-7.9a2 2 0 0 1-1.69-.9L9.6 3.9A2 2 0 0 0 7.93 3H4a2 2 0 0 0-2 2v13c0 1.1.9 2 2 2Z"/></svg>
          <% } else { %>
            <svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m3 11 18-5v12L3 14v-3z"/><path d="M11.6 16.8a3 3 0 1 1-5.8-1.6"/></svg>
          <% } %>
        </div>
        <div class="wm-titles">
          <div class="wm-title"><%= wTitle %></div>
          <div class="wm-sub"><%= wSub %></div>
        </div>
        <button type="button" class="wm-x" onclick="closeWriteModal()">✕</button>
      </div>
      <form action="<%= wAction %>" method="post" enctype="multipart/form-data">
        <input type="hidden" name="channel_id" value="<%= channel_id %>">
        <input type="hidden" name="board_name" value="<%= wBoard %>">
        <div class="wm-field">
          <label class="wm-label">제목</label>
          <input class="wm-input" type="text" name="title" required placeholder="<%= wPh1 %>">
        </div>
        <div class="wm-field">
          <label class="wm-label">내용</label>
          <textarea class="wm-textarea" name="content" required placeholder="<%= wPh2 %>"></textarea>
        </div>
        <div class="wm-field">
          <label class="wm-label">첨부파일 <span style="color:var(--text3);font-weight:500;">(선택)</span></label>
          <input class="wm-file" type="file" name="uploadFile">
        </div>
        <div class="wm-actions">
          <button type="button" class="wm-cancel" onclick="closeWriteModal()">취소</button>
          <button type="submit" class="wm-go">작성 완료</button>
        </div>
      </form>
    </div>
  </div>
  <script>
    function openWriteModal(){ document.getElementById('writeModal').classList.add('open'); }
    function closeWriteModal(){ document.getElementById('writeModal').classList.remove('open'); }
  </script>
  <% } %>

</div><!-- /lm-app -->
</body>
</html>
