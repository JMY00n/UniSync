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
      <div class="ch-code">코드 : <%= channel.getEntry_code() %></div>
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
        실시간 Q&amp;A
      </a>
    </div>
    <div class="ch-side-me">
      <div class="me-av"><%= name.substring(0,1) %></div>
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
        <button type="button" class="btn-write" onclick="location.href='../notice/writeNoticeForm.jsp?channel_id=<%= channel_id %>'">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>공지 작성
        </button>
        <% } else if (isProf && menu.equals("material")) { %>
        <button type="button" class="btn-write" onclick="location.href='writeMaterialForm.jsp?channel_id=<%= channel_id %>'">
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
                    <span class="file-chip">첨부</span>
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
            <thead><tr><th class="col-no">번호</th><th>자료 제목</th><th class="col-date">등록일</th><th class="col-file">받기</th></tr></thead>
            <tbody>
            <% int count = materialList.size();
               for (MessageVO msg : materialList) { %>
              <tr onclick="location.href='materialDetail.jsp?message_id=<%= msg.getMessage_id() %>&channel_id=<%= channel_id %>'">
                <td class="col-no"><%= count-- %></td>
                <td class="col-title"><a href="materialDetail.jsp?message_id=<%= msg.getMessage_id() %>&channel_id=<%= channel_id %>"><%= msg.getTitle() %></a></td>
                <td class="col-date"><%= sdf.format(msg.getCreated_at()) %></td>
                <td class="col-file">
                  <% if (msg.getFile_path() != null && !msg.getFile_path().equals("")) { %>
                    <a href="../../upload/<%= msg.getFile_path() %>" download="<%= msg.getFile_path() %>" class="file-chip dl" onclick="event.stopPropagation();">받기</a>
                  <% } else { %><span class="dash">-</span><% } %>
                </td>
              </tr>
            <% } %>
            </tbody>
          </table>
        <% } %>

      <%-- ===== 실시간 Q&A (기존 AJAX 로직 그대로) ===== --%>
      <% } else if (menu.equals("qna")) { %>
        <div class="qna-writer">
          <textarea id="qnaContent" rows="2" placeholder="궁금한 점을 자유롭게 남겨보세요!"></textarea>
          <button type="button" onclick="submitQna()">등록</button>
        </div>
        <div id="qnaListArea" class="qna-list"></div>

        <script>
          const channelId = <%= channel_id %>;

          function loadQnaList() {
            fetch('../freechat/getQnaListAjax.jsp?channel_id=' + channelId)
              .then(response => response.text())
              .then(html => { document.getElementById('qnaListArea').innerHTML = html; })
              .catch(error => console.error('Error:', error));
          }

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
              if (result.trim() === 'success') { contentObj.value = ''; loadQnaList(); }
              else { alert('글 등록에 실패했습니다.'); }
            })
            .catch(error => console.error('Error:', error));
          }

          function editQna(messageId) {
            const contentDiv = document.getElementById('qna_content_' + messageId);
            const oldContent = contentDiv.innerText;
            const newContent = prompt('수정할 내용을 입력하세요:', oldContent);
            if (newContent !== null && newContent.trim() !== '' && newContent !== oldContent) {
              fetch('../freechat/updateQnaAjax.jsp', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: 'message_id=' + messageId + '&content=' + encodeURIComponent(newContent.trim())
              })
              .then(response => response.text())
              .then(result => {
                if (result.trim() === 'success') { loadQnaList(); }
                else { alert('수정에 실패했습니다. 본인 글인지 확인해주세요.'); }
              })
              .catch(error => console.error('Error:', error));
            }
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
        <div class="mem-av prof"><%= two(mv.getName()) %></div>
        <div class="mem-info">
          <div class="mem-name"><%= mv.getName() %></div>
          <div class="mem-sub">교수<%= mv.getUser_id().equals(channel.getUser_id()) ? " · 개설자" : "" %></div>
        </div>
      </div>
    <% } %>

    <div class="mem-group">학생 <span><%= stuCount %></span></div>
    <% if (stuCount == 0) { %>
      <div class="mem-empty">아직 입장한 학생이 없어요.</div>
    <% } %>
    <% for (MemberVO mv : members) { if (mv.getRole() == 1) continue; %>
      <div class="mem">
        <div class="mem-av"><%= two(mv.getName()) %></div>
        <div class="mem-info">
          <div class="mem-name"><%= mv.getName() %></div>
          <div class="mem-sub">학생</div>
        </div>
      </div>
    <% } %>
  </div>

</div><!-- /lm-app -->
</body>
</html>
