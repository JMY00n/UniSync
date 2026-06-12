<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.ChannelDAO" %>
<%@ page import="channel.ChannelVO" %>
<%
    // 1. 세션 체크 (로그인 풀리면 로그인 창으로 보내기)
    String id = (String) session.getAttribute("user_id");
    if (id == null) id = (String) session.getAttribute("id");
    if (id == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }

    // 2. 대시보드에서 클릭한 방 번호(channel_id) 받아오기
    String idParam = request.getParameter("channel_id");
    if (idParam == null) {
        response.sendRedirect("../dashboard/dashboard.jsp");
        return;
    }
    int channel_id = Integer.parseInt(idParam);
    
    // 3. DAO를 통해 방 이름, 입장코드 등 정보 가져오기
    ChannelDAO cdao = ChannelDAO.getInstance();
    ChannelVO channel = cdao.getChannelById(channel_id);
    
    // 4. 현재 선택된 메뉴가 무엇인지 파악 (기본값은 '공지사항')
    String menu = request.getParameter("menu");
    if(menu == null) menu = "notice";
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title><%= channel.getChannel_name() %> - UniSync</title>
<style>
    body { margin: 0; font-family: sans-serif; background-color: #f4f7f6; }
    
    /* 상단 헤더 (방 정보 고정) */
    .header_area { background-color: #fff; padding: 20px 40px; border-bottom: 2px solid #516e7f; display: flex; justify-content: space-between; align-items: center; }
    .entry_code { background-color: #ffebee; padding: 5px 10px; border-radius: 5px; color: #d32f2f; font-weight: bold; letter-spacing: 2px;}
    
    /* 전체 레이아웃 (좌측 메뉴 + 우측 컨텐츠) */
    .container { display: flex; min-height: 80vh; }
    
    /* 왼쪽 사이드바 메뉴 */
    .sidebar { width: 220px; background-color: #343a40; padding-top: 20px; }
    .sidebar a { display: block; padding: 15px 25px; color: #d1d5db; text-decoration: none; font-size: 16px; transition: 0.3s; }
    .sidebar a:hover, .sidebar a.active { background-color: #495057; color: #fff; border-left: 4px solid #007bff; font-weight: bold; }
    
    /* 오른쪽 메인 컨텐츠 영역 */
    .content_area { flex: 1; padding: 30px; background-color: #fff; margin: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.05); }
</style>
</head>
<body>

    <div class="header_area">
        <h2 style="margin: 0; color: #333;">📚 <%= channel.getChannel_name() %></h2>
        <div>
            <span style="margin-right: 15px;">👨‍🏫 개설 교수: <b><%= channel.getUser_id() %></b></span>
            <span>🔑 입장 코드: <span class="entry_code"><%= channel.getEntry_code() %></span></span>
            <button onclick="location.href='../dashboard/dashboard.jsp'" style="margin-left: 20px; padding: 6px 12px; cursor: pointer;">나가기</button>
        </div>
    </div>

    <div class="container">
        <div class="sidebar">
            <a href="lectureMain.jsp?channel_id=<%= channel_id %>&menu=notice" class="<%= menu.equals("notice") ? "active" : "" %>">📢 공지사항</a>
            <a href="lectureMain.jsp?channel_id=<%= channel_id %>&menu=material" class="<%= menu.equals("material") ? "active" : "" %>">📁 강의자료</a>
            <a href="lectureMain.jsp?channel_id=<%= channel_id %>&menu=qna" class="<%= menu.equals("qna") ? "active" : "" %>">💬 실시간 Q&A</a>
        </div>
        
        <div class="content_area">
            <% if(menu.equals("notice")) { %>
                <h3>📢 공지사항 게시판</h3>
                <p style="color: gray;">여기에 DB(message 테이블)에서 가져온 공지사항 목록(제목, 작성날짜, 첨부파일 미리보기)이 뜰 예정입니다.</p>
            <% } else if(menu.equals("material")) { %>
                <h3>📁 강의자료실</h3>
                <p style="color: gray;">여기에 교수님이 올린 PPT, 소스코드 자료 목록이 뜰 예정입니다.</p>
            <% } else if(menu.equals("qna")) { %>
                <h3>💬 Slido형 실시간 Q&A</h3>
                <p style="color: gray;">여기에 새로고침 없이 대화가 이어지는 채팅창이 뜰 예정입니다.</p>
            <% } %>
        </div>
    </div>

</body>
</html>