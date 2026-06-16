<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.ChannelDAO" %>
<%@ page import="channel.ChannelVO" %>
<%@ page import="channel.ActivityVO" %>
<%@ page import="member.MemberDAO" %>
<%@ page import="member.MemberVO" %>
<%@ page import="java.util.ArrayList" %>
<%!
    // 작성 시간 표기 (yyyy-MM-dd HH:mm)
    String fmtDate(java.sql.Timestamp t) {
        if (t == null) return "";
        return new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm").format(t);
    }
    // 아이콘/배지용 앞 2글자 (공백 제거)
    String two(String s) {
        if (s == null) return "";
        String x = s.replaceAll("\\s", "");
        return x.length() <= 2 ? x : x.substring(0, 2);
    }
%>
<%
    // ── 1. 세션 가드 ──
    String userId = (String) session.getAttribute("user_id");
    if (userId == null) userId = (String) session.getAttribute("id");
    Object roleObj = session.getAttribute("role");
    String name = (String) session.getAttribute("name");

    if (userId == null || roleObj == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }
    int role = (Integer) roleObj; // 1: 교수, 0: 학생

    // 이름: 세션 우선 → 없으면 DB에서 직접 조회 → 그래도 없으면 아이디
    if (name == null || name.trim().isEmpty()) {
        try {
            MemberVO me = MemberDAO.getinstance().getMember(userId);
            if (me != null && me.getName() != null && !me.getName().trim().isEmpty()) {
                name = me.getName();
            }
        } catch (Exception e) { e.printStackTrace(); }
    }
    if (name == null || name.trim().isEmpty()) name = userId;

    boolean isProf = (role == 1);

    // ── 2. 데이터 조회 (role별) ──
    ChannelDAO cdao = ChannelDAO.getInstance();
    ArrayList<ChannelVO> channelList;
    ArrayList<ActivityVO> recent;
    int weeklyNew, totalStudents = 0;

    if (isProf) {
        channelList   = cdao.getChannelsByProfessor(userId);
        weeklyNew     = cdao.countWeeklyMessagesByProfessor(userId);
        totalStudents = cdao.countTotalStudents(userId);
        recent        = cdao.getRecentActivityByProfessor(userId, 20);
    } else {
        channelList   = cdao.getChannelsByStudent(userId);
        weeklyNew     = cdao.countWeeklyMessagesByStudent(userId);
        recent        = cdao.getRecentActivityByStudent(userId, 20);
    }

    // 최근 활동 2열 분할 (홀수면 왼쪽이 1개 더)
    int rTotal = recent.size();
    int rHalf  = (rTotal + 1) / 2;

    // ── 강의실 정렬 (최신순 / 오래된순 / 인기순) ──
    String sort = request.getParameter("sort");
    if (sort == null) sort = "newest";
    final String sortMode = sort;

    // 인기순 기준: 최근활동 목록에서 채널명이 많이 등장할수록 활발(=인기)
    final java.util.Map<String,Integer> actCount = new java.util.HashMap<String,Integer>();
    for (ActivityVO a : recent) {
        String k = a.getChannel_name();
        if (k == null) k = "";
        actCount.put(k, (actCount.containsKey(k) ? actCount.get(k) : 0) + 1);
    }

    java.util.Collections.sort(channelList, new java.util.Comparator<ChannelVO>() {
        public int compare(ChannelVO x, ChannelVO y) {
            if ("popular".equals(sortMode)) {
                String kx = x.getChannel_name() == null ? "" : x.getChannel_name();
                String ky = y.getChannel_name() == null ? "" : y.getChannel_name();
                int cx = actCount.containsKey(kx) ? actCount.get(kx) : 0;
                int cy = actCount.containsKey(ky) ? actCount.get(ky) : 0;
                if (cx != cy) return cy - cx;               // 최근활동 많은 순
                return y.getChannel_id() - x.getChannel_id(); // 동률이면 최신
            } else if ("oldest".equals(sortMode)) {
                return x.getChannel_id() - y.getChannel_id();
            } else { // newest
                return y.getChannel_id() - x.getChannel_id();
            }
        }
    });
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>UniSync 대시보드</title>
<link href="../css/common.css" rel="stylesheet" type="text/css">
<link href="../css/dashboard.css" rel="stylesheet" type="text/css">
</head>
<body>
<div class="app">

    <!-- ══════════ 레일 ══════════ -->
    <div class="rail">
        <a class="rail-logo active" href="dashboard.jsp" title="홈 (대시보드)">
            <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="m3 9 9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"/><polyline points="9 22 9 12 15 12 15 22"/></svg>
        </a>
        <div class="rail-div"></div>
        <%
            int ri = 0;
            for (ChannelVO c : channelList) {
                String cls = "c" + ((ri % 3) + 1);
        %>
        <a class="ri <%= cls %>" href="../channel/lectures/lectureMain.jsp?channel_id=<%= c.getChannel_id() %>" title="<%= c.getChannel_name() %>"><%= two(c.getChannel_name()) %></a>
        <%      ri++;
            }
        %>
        <div class="rail-bot">
            <a class="r-ic" href="../login/logoutPro.jsp" title="로그아웃">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4"/><path d="m16 17 5-5-5-5"/><path d="M21 12H9"/></svg>
            </a>
            <div class="rail-me" title="<%= name %>"><%= name.substring(0, 1) %></div>
        </div>
    </div>

    <!-- ══════════ 메인 ══════════ -->
    <div class="main">

        <!-- 헤더: 인사 + 입장코드 입력 + (교수)새 강의실 개설 -->
        <div class="m-top">
            <div>
                <div class="hello">어서 오세요, <%= name %> <%= isProf ? "교수님" : "님" %></div>
                <div class="hello-sub"><%= isProf ? "개설한 강의실 현황을 한눈에 확인하세요" : "수강 중인 강의실을 확인하세요" %></div>
            </div>
            <div class="m-actions">
                <form class="join-form" action="../channel/joinChannelPro.jsp" method="post">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
                    <input type="text" name="entry_code" placeholder="입장 코드로 강의실 참여" required>
                    <button type="submit">참여</button>
                </form>
                <% if (isProf) { %>
                <button type="button" class="btn-primary" onclick="openCreateModal()">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>새 강의실 개설
                </button>
                <% } %>
            </div>
        </div>

        <div class="m-body">

            <!-- 통계 (교수: 개설 강의실 / 이번 주 새 글 / 총 수강생) -->
            <div class="stats">
                <div class="stat">
                    <div><div class="stat-lbl"><%= isProf ? "개설 강의실" : "입장 강의실" %></div><div class="stat-num"><%= channelList.size() %></div></div>
                    <div class="stat-ic"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg></div>
                </div>
                <div class="stat">
                    <div><div class="stat-lbl">이번 주 새 글</div><div class="stat-num"><%= weeklyNew %></div></div>
                    <div class="stat-ic"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg></div>
                </div>
                <% if (isProf) { %>
                <div class="stat">
                    <div><div class="stat-lbl">총 수강생</div><div class="stat-num"><%= totalStudents %><small>명</small></div></div>
                    <div class="stat-ic"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 21v-2a4 4 0 0 0-4-4H6a4 4 0 0 0-4 4v2"/><circle cx="9" cy="7" r="4"/><path d="M22 21v-2a4 4 0 0 0-3-3.87"/></svg></div>
                </div>
                <% } %>
            </div>

            <!-- 강의실 목록 -->
            <div class="sec-head">
                <span class="sec-title"><%= isProf ? "내가 개설한 강의실" : "내가 입장한 강의실" %></span>
                <span class="sec-count"><%= channelList.size() %>개</span>
                <% if (!channelList.isEmpty()) { %>
                <select class="sort-select" onchange="location.href='dashboard.jsp?sort='+this.value">
                    <option value="newest"  <%= "newest".equals(sort)  ? "selected" : "" %>>최신순</option>
                    <option value="oldest"  <%= "oldest".equals(sort)  ? "selected" : "" %>>오래된순</option>
                    <option value="popular" <%= "popular".equals(sort) ? "selected" : "" %>>인기순</option>
                </select>
                <% } %>
            </div>

            <% if (channelList.isEmpty()) { %>
                <div class="empty-state">
                    <div class="empty-ic">
                    <% if (isProf) { %>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><path d="M4 19.5A2.5 2.5 0 0 1 6.5 17H20"/><path d="M6.5 2H20v20H6.5A2.5 2.5 0 0 1 4 19.5v-15A2.5 2.5 0 0 1 6.5 2z"/></svg>
                    <% } else { %>
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"/><path d="m21 21-4.3-4.3"/></svg>
                    <% } %>
                    </div>
                    <div class="empty-title"><%= isProf ? "아직 개설한 강의실이 없어요" : "아직 입장한 강의실이 없어요" %></div>
                    <div class="empty-sub">
                        <%= isProf ? "첫 강의실을 개설하고, 생성된 입장 코드를 학생들에게 공유해보세요."
                                   : "교수님께 받은 입장 코드를 위 상단 입력란에 입력하면 강의실에 참여할 수 있어요." %>
                    </div>
                    <% if (isProf) { %>
                    <button type="button" class="btn-primary empty-cta" onclick="openCreateModal()">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.2" stroke-linecap="round"><path d="M12 5v14M5 12h14"/></svg>새 강의실 개설
                    </button>
                    <% } %>
                </div>
            <% } else { %>
            <div class="cgrid">
                <%
                    int ci = 0;
                    for (ChannelVO c : channelList) {
                        String cls = "c" + ((ci % 3) + 1);
                        int stCnt = cdao.countStudents(c.getChannel_id());
                %>
                <div class="cc">
                    <div class="cc-head">
                        <div class="cc-badge <%= cls %>"><%= two(c.getChannel_name()) %></div>
                        <div>
                            <div class="cc-name"><%= c.getChannel_name() %></div>
                            <div class="cc-code">
                                <span>입장 코드</span>
                                <span class="code-pill" onclick="copyCode('<%= c.getEntry_code() %>')" title="클릭하면 복사돼요"><%= c.getEntry_code() %><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg></span>
                            </div>
                        </div>
                    </div>
                    <div class="cc-meta">
                        <% if (isProf) { %>
                            <span>수강생 <b><%= stCnt %></b></span>
                        <% } else { %>
                            <span>교수 <b><%= c.getUser_id() %></b></span>
                            <span>수강생 <b><%= stCnt %></b></span>
                        <% } %>
                    </div>
                    <div class="cc-foot">
                        <% if (isProf) { %>
                            <button type="button" class="cc-btn" onclick="location.href='../channel/updateChannelForm.jsp?channel_id=<%= c.getChannel_id() %>'">수정</button>
                            <button type="button" class="cc-btn danger" onclick="if(confirm('정말 [<%= c.getChannel_name() %>] 강의실을 삭제하시겠습니까?\n참여한 학생 정보도 모두 삭제되며 복구할 수 없습니다.')) location.href='../channel/deleteChannelPro.jsp?channel_id=<%= c.getChannel_id() %>';">삭제</button>
                        <% } %>
                        <a class="cc-enter" href="../channel/lectures/lectureMain.jsp?channel_id=<%= c.getChannel_id() %>">입장</a>
                    </div>
                </div>
                <%      ci++;
                    }
                %>
            </div>
            <% } %>

            <!-- 최근 활동 (전체 강의실 최근 글, 2열 분할) -->
            <div class="sec-head"><span class="sec-title">최근 활동</span></div>
            <div class="panel">
                <div class="panel-head">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 8v4l3 3"/><circle cx="12" cy="12" r="10"/></svg>
                    전체 강의실 최근 글
                </div>
                <% if (rTotal == 0) { %>
                    <div class="panel-empty">
                        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><path d="M14 2v6h6"/><path d="M16 13H8"/><path d="M16 17H8"/></svg>
                        <div>
                            <div class="pe-title">아직 등록된 글이 없어요</div>
                            <div class="pe-sub">강의실에 공지·자료·질문 글이 올라오면 여기에 모여서 보여요.</div>
                        </div>
                    </div>
                <% } else { %>
                <div class="acts2">
                    <%
                        for (int i = 0; i < rTotal; i++) {
                            ActivityVO a = recent.get(i);
                            String dot = "c" + ((i % 3) + 1);
                            // 홀수 개수일 때 마지막 행은 양 칸에 걸쳐 공백 제거
                            boolean span = (rTotal % 2 == 1) && (i == rTotal - 1);
                    %>
                        <div class="row<%= span ? " row-span" : "" %>">
                            <span class="row-dot <%= dot %>"></span>
                            <span class="row-ch"><%= a.getChannel_name() %></span>
                            <span class="row-board"><%= a.getBoard_name() %></span>
                            <span class="row-txt"><%= a.getTitle() %></span>
                            <span class="row-time"><%= fmtDate(a.getCreated_at()) %></span>
                        </div>
                    <%  } %>
                </div>
                <% } %>
            </div>

        </div><!-- /m-body -->

        <!-- 푸터: 팀 크레딧 (실제 이름으로 교체) -->
        <div class="dash-foot">
            <span class="foot-brand">UniSync · JSP 기말과제</span>
            <div class="foot-team">
                <span class="tm"><b>이름</b> 백엔드</span>
                <span class="tm"><b>이름</b> DB 설계</span>
                <span class="tm"><b>이름</b> 프론트엔드 · 디자인</span>
            </div>
        </div>

    </div><!-- /main -->
</div><!-- /app -->

<% if (isProf) { %>
<!-- ══════════ 새 강의실 개설 모달 ══════════ -->
<div class="modal-overlay" id="createModal" onclick="if(event.target == this) closeCreateModal();">
  <div class="modal-card">
    <button type="button" class="modal-x" onclick="closeCreateModal()">
      <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M18 6 6 18M6 6l12 12"/></svg>
    </button>
    <div class="modal-head">
      <div class="modal-ic"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M16 20V4a2 2 0 0 0-2-2h-4a2 2 0 0 0-2 2v16"/><rect width="20" height="14" x="2" y="6" rx="2"/></svg></div>
      <div>
        <div class="modal-title">새 강의실 개설</div>
        <div class="modal-sub">강의실 이름을 입력하면 바로 만들 수 있어요.</div>
      </div>
    </div>
    <form name="channel_form" method="post" action="../channel/createChannelPro.jsp">
      <div class="cm-field">
        <label class="cm-label" for="cm_name">강의실 이름</label>
        <input class="cm-input" id="cm_name" name="channel_name" type="text" placeholder="예: 2026 자바프로그래밍" required>
      </div>
      <div class="cm-note">
        <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg>
        <span>개설하면 학생 입장용 <b>8자리 코드</b>가 자동으로 발급돼요. 공지사항·강의자료·Q&amp;A 게시판도 함께 생성됩니다.</span>
      </div>
      <div class="cm-actions">
        <button type="button" class="cm-cancel" onclick="closeCreateModal()">취소</button>
        <button type="submit" class="cm-submit">강의실 개설하기</button>
      </div>
    </form>
  </div>
</div>
<script>
    // 모달 열기 / 닫기
    function openCreateModal() {
        document.getElementById("createModal").style.display = "flex";
        document.getElementById("cm_name").value = "";
        document.getElementById("cm_name").focus();
    }
    function closeCreateModal() {
        document.getElementById("createModal").style.display = "none";
    }
</script>
<% } %>

<script>
    // 입장 코드 복사
    function copyCode(code) {
        navigator.clipboard.writeText(code);
        alert("입장 코드가 복사되었습니다: " + code);
    }
</script>
</body>
</html>
