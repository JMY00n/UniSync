<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.MessageDAO" %>
<%@ page import="channel.MessageVO" %>
<%@ page import="member.MemberDAO" %>
<%@ page import="member.MemberVO" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    String userId = (String) session.getAttribute("user_id");
    if (userId == null) userId = (String) session.getAttribute("id");
    if (userId == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    String channel_id = request.getParameter("channel_id");
    String midParam = request.getParameter("message_id");
    if (midParam == null || !midParam.matches("\\d+")) {
        if (channel_id != null && channel_id.matches("\\d+"))
            response.sendRedirect("../lectures/lectureMain.jsp?channel_id=" + channel_id + "&menu=notice");
        else
            response.sendRedirect("../../dashboard/dashboard.jsp");
        return;
    }
    int message_id = Integer.parseInt(midParam);

    MessageDAO mdao = MessageDAO.getInstance();
    MessageVO msg = mdao.getMessageById(message_id);

    if(msg == null) {
%>
        <script>alert("존재하지 않거나 삭제된 게시글입니다."); history.go(-1);</script>
<%
        return;
    }
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

    // 작성자 표시명: 닉네임(name) 우선, 없으면 학번(user_id)으로 폴백
    String authorName = msg.getUser_id();
    try {
        MemberVO author = MemberDAO.getinstance().getMember(msg.getUser_id());
        if (author != null && author.getName() != null && !author.getName().trim().isEmpty())
            authorName = author.getName();
    } catch (Exception e) { /* 조회 실패 시 학번 그대로 사용 */ }

    // 이전글(더 오래된 글) / 다음글(더 최신 글)
    MessageVO prev = mdao.getPrevMessage(msg.getChannel_id(), msg.getBoard_name(), message_id);
    MessageVO next = mdao.getNextMessage(msg.getChannel_id(), msg.getBoard_name(), message_id);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>공지사항 상세 - UniSync</title>
<link href="../../css/common.css" rel="stylesheet" type="text/css">
<style>
  .page-wrap { min-height: 100vh; display: flex; justify-content: center; padding: 40px 24px; }
  .d-card { width: 100%; max-width: 920px; }

  .d-back { display: inline-flex; align-items: center; gap: 6px; font-size: 13px; color: var(--text2); text-decoration: none; padding: 8px 13px; border: 1px solid var(--border-m); border-radius: 8px; margin-bottom: 16px; background: var(--surface); }
  .d-back:hover { background: var(--bg); }

  /* 클래식 헤더: 상단 라인 + 제목 + 메타 */
  .d-top { border-top: 3px solid var(--primary); }
  .d-head { background: var(--surface); border: 1px solid var(--border); border-top: none; padding: 30px 32px 22px; }
  .d-title { font-family: var(--brand); font-size: 27px; font-weight: 800; color: var(--text); line-height: 1.25; }
  .d-meta { display: flex; flex-wrap: wrap; align-items: center; gap: 0; margin-top: 16px; font-size: 13.5px; color: var(--text3); }
  .d-meta .mi { display: inline-flex; align-items: center; gap: 6px; }
  .d-meta .sep { margin: 0 14px; color: var(--border-m); }
  .d-meta svg { width: 15px; height: 15px; stroke: var(--text3); }

  /* 첨부 */
  .d-file { display: flex; align-items: center; gap: 10px; background: var(--surface); border-left: 1px solid var(--border); border-right: 1px solid var(--border); padding: 14px 32px; font-size: 14px; color: var(--text2); }
  .d-file .fl-label { font-weight: 700; color: var(--text2); }
  .d-file svg { width: 16px; height: 16px; stroke: var(--text3); }
  .d-file a { color: var(--primary); text-decoration: none; font-weight: 600; }
  .d-file a:hover { text-decoration: underline; }
  .d-divider { border-top: 1px solid var(--border); }

  /* 본문 */
  .d-body { background: var(--surface); border-left: 1px solid var(--border); border-right: 1px solid var(--border); border-bottom: 1px solid var(--border); padding: 30px 32px 40px; min-height: 220px; font-size: 15.5px; line-height: 1.8; color: var(--text); white-space: pre-wrap; word-break: break-word; }

  /* 액션 */
  .d-actions { display: flex; align-items: center; gap: 9px; padding: 18px 0 26px; }
  .d-actions .spacer { flex: 1; }
  .d-actions button { display: inline-flex; align-items: center; gap: 7px; height: 42px; padding: 0 18px; border-radius: 11px; font-family: var(--font); font-size: 14px; font-weight: 700; cursor: pointer; border: 1px solid transparent; transition: background .14s, border-color .14s, box-shadow .14s, transform .05s; }
  .d-actions button:active { transform: translateY(1px); }
  .d-actions button svg { width: 16px; height: 16px; }
  .btn-edit { background: #FEF5E1; color: #97670B; border-color: #F1DCA4; }
  .btn-edit:hover { background: #FBE9C0; border-color: #EACd7c; box-shadow: 0 2px 8px rgba(151,103,11,.12); }
  .btn-del { background: #FDECEC; color: #C5403B; border-color: #F1C7C5; }
  .btn-del:hover { background: #F9DADA; border-color: #E9AFAC; box-shadow: 0 2px 8px rgba(197,64,59,.12); }
  .btn-list { background: var(--primary); color: #fff; border-color: var(--primary); }
  .btn-list:hover { background: var(--primary-hover); border-color: var(--primary-hover); box-shadow: 0 4px 14px var(--primary-glow); }

  /* 이전글 / 다음글 */
  .d-nav { background: var(--surface); border: 1px solid var(--border); border-radius: var(--r, 10px); overflow: hidden; }
  .d-nav-row { display: flex; align-items: center; gap: 0; padding: 16px 24px; text-decoration: none; }
  .d-nav-row + .d-nav-row { border-top: 1px solid var(--border); }
  .d-nav-row.link:hover { background: var(--bg); }
  .d-nav-ico { display: inline-flex; width: 22px; color: var(--text3); }
  .d-nav-ico svg { width: 17px; height: 17px; stroke: var(--text3); }
  .d-nav-label { width: 64px; font-size: 13.5px; font-weight: 700; color: var(--text2); }
  .d-nav-text { flex: 1; font-size: 14px; color: var(--text); overflow: hidden; text-overflow: ellipsis; white-space: nowrap; }
  .d-nav-text.empty { color: var(--text3); font-weight: 400; }
</style>
</head>
<body>
<div class="page-wrap">
  <div class="d-card">
    <a class="d-back" href="../lectures/lectureMain.jsp?channel_id=<%= channel_id %>&menu=notice">‹ 공지사항 목록으로</a>

    <div class="d-top"></div>
    <div class="d-head">
      <div class="d-title"><%= msg.getTitle() %></div>
      <div class="d-meta">
        <span class="mi"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="9"/><path d="M12 7v5l3 2"/></svg><%= sdf.format(msg.getCreated_at()) %></span>
        <span class="sep">|</span>
        <span class="mi"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg><%= authorName %></span>
      </div>
    </div>

    <% if(msg.getFile_path() != null && !msg.getFile_path().equals("")) { %>
      <div class="d-file">
        <span class="fl-label">첨부파일</span>
        <svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21.4 11.05 12.25 20.2a5 5 0 0 1-7.07-7.07l9.19-9.19a3 3 0 0 1 4.24 4.24l-9.2 9.19a1 1 0 0 1-1.41-1.41l8.49-8.5"/></svg>
        <a href="<%= request.getContextPath() %>/upload/<%= msg.getFile_path() %>" download="<%= msg.getFile_path() %>"><%= msg.getFile_path() %></a>
      </div>
    <% } %>
    <div class="d-divider"></div>

    <div class="d-body"><%= msg.getContent() %></div>

    <div class="d-actions">
      <% if(userId.equals(msg.getUser_id())) { %>
        <button type="button" class="btn-edit" onclick="location.href='updateNoticeForm.jsp?message_id=<%= message_id %>&channel_id=<%= channel_id %>'">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.1 2.1 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>
          수정
        </button>
        <button type="button" class="btn-del" onclick="if(confirm('정말 삭제하시겠습니까?')) location.href='../notice/deleteNoticePro.jsp?message_id=<%= message_id %>&channel_id=<%= channel_id %>'">
          <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M3 6h18M8 6V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2m2 0v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6"/><path d="M10 11v6M14 11v6"/></svg>
          삭제
        </button>
      <% } %>
      <span class="spacer"></span>
      <button type="button" class="btn-list" onclick="location.href='../lectures/lectureMain.jsp?channel_id=<%= channel_id %>&menu=notice'">
        <svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M8 6h13M8 12h13M8 18h13M3 6h.01M3 12h.01M3 18h.01"/></svg>
        목록
      </button>
    </div>

    <div class="d-nav">
      <% if(prev != null) { %>
        <a class="d-nav-row link" href="noticeDetail.jsp?message_id=<%= prev.getMessage_id() %>&channel_id=<%= channel_id %>">
          <span class="d-nav-ico"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m18 15-6-6-6 6"/></svg></span>
          <span class="d-nav-label">이전글</span>
          <span class="d-nav-text"><%= prev.getTitle() %></span>
        </a>
      <% } else { %>
        <div class="d-nav-row">
          <span class="d-nav-ico"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m18 15-6-6-6 6"/></svg></span>
          <span class="d-nav-label">이전글</span>
          <span class="d-nav-text empty">이전글이 없습니다.</span>
        </div>
      <% } %>
      <% if(next != null) { %>
        <a class="d-nav-row link" href="noticeDetail.jsp?message_id=<%= next.getMessage_id() %>&channel_id=<%= channel_id %>">
          <span class="d-nav-ico"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6"/></svg></span>
          <span class="d-nav-label">다음글</span>
          <span class="d-nav-text"><%= next.getTitle() %></span>
        </a>
      <% } else { %>
        <div class="d-nav-row">
          <span class="d-nav-ico"><svg viewBox="0 0 24 24" fill="none" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m6 9 6 6 6-6"/></svg></span>
          <span class="d-nav-label">다음글</span>
          <span class="d-nav-text empty">다음글이 없습니다.</span>
        </div>
      <% } %>
    </div>

    <!-- ===== 댓글 영역 ===== -->
    <div style="margin-top:26px; background:#fff; border:1px solid rgba(0,0,0,0.08); border-radius:10px; padding:24px 26px 28px;">
      <div style="display:flex; align-items:center; gap:8px; font-size:17px; font-weight:800; color:#17171A; margin-bottom:16px;">
        <svg viewBox="0 0 24 24" fill="none" stroke="#342F92" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="18" height="18"><path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/></svg>
        댓글 <span id="cmtCount" style="color:#342F92;">0</span>
      </div>

      <!-- 작성 박스 -->
      <div style="display:flex; flex-direction:column; gap:10px; padding:14px; border:1px solid rgba(0,0,0,0.08); border-radius:12px; background:#FAFAFA; margin-bottom:22px;">
        <textarea id="cmtInput" placeholder="댓글을 입력하세요" style="width:100%; min-height:64px; resize:vertical; border:1px solid rgba(0,0,0,0.14); border-radius:9px; padding:11px 13px; font-size:14.5px; line-height:1.6; color:#2B2B30; background:#fff; box-sizing:border-box;"></textarea>
        <div style="display:flex; justify-content:flex-end;">
          <button type="button" onclick="submitComment()" style="display:inline-flex; align-items:center; gap:6px; height:38px; padding:0 18px; border:none; border-radius:10px; background:#342F92; color:#fff; font-size:14px; font-weight:700; cursor:pointer;">
            <svg viewBox="0 0 24 24" fill="none" stroke="#fff" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" width="15" height="15"><path d="m22 2-7 20-4-9-9-4Z"/><path d="M22 2 11 13"/></svg>
            등록
          </button>
        </div>
      </div>

      <div id="commentListArea"></div>
    </div>
  </div>
</div>

<script>
  const COMMENT_MESSAGE_ID = <%= message_id %>;
  let currentCommentPage = 1;

  // 목록 불러오기 (현재 페이지 기준) → #commentListArea 갱신
  function loadComments() {
    fetch('getCommentListAjax.jsp?message_id=' + COMMENT_MESSAGE_ID + '&page=' + currentCommentPage)
      .then(response => response.text())
      .then(html => {
        document.getElementById('commentListArea').innerHTML = html;
        // 서버가 보정한 페이지/총개수를 다시 읽어 동기화
        const meta = document.getElementById('cmtMeta');
        if (meta) {
          currentCommentPage = parseInt(meta.dataset.page) || 1;
          const cnt = document.getElementById('cmtCount');
          if (cnt) cnt.textContent = meta.dataset.count || '0';
        }
      })
      .catch(error => console.error('Error:', error));
  }

  // 페이지 이동
  function goCommentPage(n) {
    if (n < 1) return;
    currentCommentPage = n;
    loadComments();
  }

  // 댓글 등록 → 최신순이라 1페이지로 이동
  function submitComment() {
    const contentObj = document.getElementById('cmtInput');
    const content = contentObj.value.trim();
    if (!content) { alert('댓글 내용을 입력해주세요.'); contentObj.focus(); return; }

    fetch('writeCommentAjax.jsp', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: 'message_id=' + COMMENT_MESSAGE_ID + '&content=' + encodeURIComponent(content)
    })
    .then(response => response.text())
    .then(result => {
      if (result.trim() === 'success') { contentObj.value = ''; currentCommentPage = 1; loadComments(); }
      else { alert('댓글 등록에 실패했습니다.'); }
    })
    .catch(error => console.error('Error:', error));
  }

  // 인라인 수정 시작 — 내용 div를 숨기고 그 자리에 편집 박스 삽입
  function editComment(id) {
    if (document.getElementById('cmt_edit_' + id)) return; // 이미 편집 중
    const div = document.getElementById('cmt_content_' + id);
    const original = div.innerText;
    div.style.display = 'none';

    const box = document.createElement('div');
    box.id = 'cmt_edit_' + id;
    box.style.cssText = 'margin-top:6px; display:flex; flex-direction:column; gap:8px;';
    box.innerHTML =
      '<textarea style="width:100%; min-height:60px; resize:vertical; border:1px solid #342F92; border-radius:9px; padding:9px 12px; font-size:14.5px; line-height:1.6; color:#2B2B30; background:#fff; box-sizing:border-box;"></textarea>' +
      '<div style="display:flex; gap:7px;">' +
        '<button type="button" onclick="saveCommentEdit(' + id + ')" style="height:32px; padding:0 14px; border:none; border-radius:8px; background:#342F92; color:#fff; font-size:13px; font-weight:700; cursor:pointer;">저장</button>' +
        '<button type="button" onclick="cancelCommentEdit(' + id + ')" style="height:32px; padding:0 14px; border:1px solid rgba(0,0,0,0.14); border-radius:8px; background:#fff; color:#52525B; font-size:13px; font-weight:700; cursor:pointer;">취소</button>' +
      '</div>';
    const ta = box.querySelector('textarea');
    ta.value = original; // value로 주입
    div.parentNode.insertBefore(box, div.nextSibling);
    ta.focus();
  }

  function cancelCommentEdit(id) {
    const box = document.getElementById('cmt_edit_' + id);
    if (box) box.remove();
    const div = document.getElementById('cmt_content_' + id);
    if (div) div.style.display = '';
  }

  function saveCommentEdit(id) {
    const box = document.getElementById('cmt_edit_' + id);
    const content = box.querySelector('textarea').value.trim();
    if (!content) { alert('댓글 내용을 입력해주세요.'); return; }

    fetch('updateCommentAjax.jsp', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: 'comment_id=' + id + '&content=' + encodeURIComponent(content)
    })
    .then(response => response.text())
    .then(result => {
      if (result.trim() === 'success') { loadComments(); }
      else { alert('수정에 실패했습니다. 본인 댓글인지 확인해주세요.'); }
    })
    .catch(error => console.error('Error:', error));
  }

  function deleteComment(id) {
    if (!confirm('이 댓글을 삭제할까요?')) return;
    fetch('deleteCommentAjax.jsp', {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: 'comment_id=' + id
    })
    .then(response => response.text())
    .then(result => {
      if (result.trim() === 'success') { loadComments(); }
      else { alert('삭제에 실패했습니다. 본인 댓글인지 확인해주세요.'); }
    })
    .catch(error => console.error('Error:', error));
  }

  window.onload = function() {
    loadComments();
  };
</script>
</body>
</html>