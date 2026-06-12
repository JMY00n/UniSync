<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.ChannelDAO" %>
<%@ page import="channel.ChannelVO" %>
<%@ page import="channel.MessageDAO" %>
<%@ page import="channel.MessageVO" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // 1. 세션 체크 (로그인 유지 및 권한 확인)
    String id = (String) session.getAttribute("user_id");
    if (id == null) id = (String) session.getAttribute("id");
    
    Object roleObj = session.getAttribute("role");
    if (id == null || roleObj == null) {
        response.sendRedirect("../login/login.jsp");
        return;
    }
    int role = (Integer) roleObj; // 1: 교수, 0: 학생

    // 2. 방 번호(channel_id) 받아오기
    String idParam = request.getParameter("channel_id");
    if (idParam == null) {
        response.sendRedirect("../dashboard/dashboard.jsp");
        return;
    }
    int channel_id = Integer.parseInt(idParam);
    
    // 3. DAO를 통해 현재 방 정보 가져오기
    ChannelDAO cdao = ChannelDAO.getInstance();
    ChannelVO channel = cdao.getChannelById(channel_id);
    
    // 4. 현재 선택된 메뉴 파악 (기본값은 '공지사항')
    String menu = request.getParameter("menu");
    if(menu == null) menu = "notice";
    
    // 날짜 포맷 객체
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title><%= channel.getChannel_name() %> - UniSync</title>
<style>
    body { margin: 0; font-family: sans-serif; background-color: #f4f7f6; }
    
    /* 상단 헤더 영역 */
    .header_area { background-color: #fff; padding: 20px 40px; border-bottom: 2px solid #516e7f; display: flex; justify-content: space-between; align-items: center; }
    .entry_code { background-color: #ffebee; padding: 5px 10px; border-radius: 5px; color: #d32f2f; font-weight: bold; letter-spacing: 2px;}
    
    /* 전체 레이아웃 (좌측 메뉴바 + 우측 컨텐츠) */
    .container { display: flex; min-height: 80vh; }
    
    /* 사이드바 */
    .sidebar { width: 220px; background-color: #343a40; padding-top: 20px; }
    .sidebar a { display: block; padding: 15px 25px; color: #d1d5db; text-decoration: none; font-size: 16px; transition: 0.3s; }
    .sidebar a:hover, .sidebar a.active { background-color: #495057; color: #fff; border-left: 4px solid #007bff; font-weight: bold; }
    
    /* 메인 컨텐츠 영역 */
    .content_area { flex: 1; padding: 30px; background-color: #fff; margin: 20px; border-radius: 8px; box-shadow: 0 0 10px rgba(0,0,0,0.05); }
    
    /* 게시판 테이블 스타일 */
    .board_table { width: 100%; border-collapse: collapse; margin-top: 15px; }
    .board_table th { background-color: #f8f9fa; border-bottom: 2px solid #dee2e6; padding: 12px; text-align: left; font-size: 14px; color: #495057; }
    .board_table td { border-bottom: 1px solid #dee2e6; padding: 12px; font-size: 14px; color: #333; }
    .board_table tr:hover { background-color: #f1f3f5; }
    
    /* 버튼 및 아이콘 스타일 */
    .btn-write { padding: 8px 15px; background-color: #007bff; color: white; border: none; border-radius: 4px; cursor: pointer; float: right; font-weight: bold; }
    .btn-write:hover { background-color: #0056b3; }
    .btn-material { background-color: #28a745; }
    .btn-material:hover { background-color: #218838; }
    .file-icon { background-color: #e9ecef; padding: 4px 8px; border-radius: 4px; font-size: 12px; color: #495057; font-weight: bold; }
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
            
            <%-- ========================= [공지사항 게시판] ========================= --%>
            <% if(menu.equals("notice")) { %>
                <div style="overflow: hidden; margin-bottom: 10px;">
                    <h3 style="float: left; margin: 0;">📢 공지사항 게시판</h3>
                    <% if(role == 1) { // 교수만 작성 가능 %>
                        <button type="button" class="btn-write" onclick="location.href='writeNoticeForm.jsp?channel_id=<%= channel_id %>'">공지사항 작성</button>
                    <% } %>
                </div>
                
                <table class="board_table">
                    <thead>
                        <tr>
                            <th style="width: 8%;">번호</th>
                            <th>제목</th>
                            <th style="width: 15%;">작성날짜</th>
                            <th style="width: 12%;">첨부파일</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        MessageDAO mdao = MessageDAO.getInstance();
                        ArrayList<MessageVO> noticeList = mdao.getMessageList(channel_id, "공지사항");
                        
                        if(noticeList.isEmpty()) {
                    %>
                        <tr>
                            <td colspan="4" style="text-align: center; color: gray; padding: 30px;">등록된 공지사항이 없습니다.</td>
                        </tr>
                    <%
                        } else {
                            int count = noticeList.size();
                            for(MessageVO msg : noticeList) {
                    %>
                        <tr>
                            <td><%= count-- %></td>
                            <td>
                                <a href="noticeDetail.jsp?message_id=<%= msg.getMessage_id() %>&channel_id=<%= channel_id %>" style="color: #007bff; text-decoration: none; font-weight: bold;">
                                    <%= msg.getTitle() %>
                                </a>
                            </td>
                            <td><%= sdf.format(msg.getCreated_at()) %></td>
                            <td>
                                <% if(msg.getFile_path() != null && !msg.getFile_path().equals("")) { %>
                                    <span class="file-icon" title="<%= msg.getFile_path() %>">📎 첨부됨</span>
                                <% } else { %>
                                    <span style="color: #ccc;">-</span>
                                <% } %>
                            </td>
                        </tr>
                    <%
                            }
                        }
                    %>
                    </tbody>
                </table>
                
            <%-- ========================= [강의자료실] ========================= --%>
            <% } else if(menu.equals("material")) { %>
                <div style="overflow: hidden; margin-bottom: 10px;">
                    <h3 style="float: left; margin: 0;">📁 강의자료실</h3>
                    <% if(role == 1) { // 교수만 자료 업로드 가능 %>
                        <button type="button" class="btn-write btn-material" onclick="location.href='writeMaterialForm.jsp?channel_id=<%= channel_id %>'">자료 올리기</button>
                    <% } %>
                </div>
                
                <table class="board_table">
                    <thead>
                        <tr>
                            <th style="width: 8%;">번호</th>
                            <th>자료 제목</th>
                            <th style="width: 15%;">등록일</th>
                            <th style="width: 12%;">다운로드</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        MessageDAO mdaoMaterial = MessageDAO.getInstance();
                        ArrayList<MessageVO> materialList = mdaoMaterial.getMessageList(channel_id, "강의자료");
                        
                        if(materialList.isEmpty()) {
                    %>
                        <tr>
                            <td colspan="4" style="text-align: center; color: gray; padding: 30px;">등록된 강의자료가 없습니다.</td>
                        </tr>
                    <%
                        } else {
                            int count = materialList.size();
                            for(MessageVO msg : materialList) {
                    %>
                        <tr>
                            <td><%= count-- %></td>
                            <td>
                                <a href="materialDetail.jsp?message_id=<%= msg.getMessage_id() %>&channel_id=<%= channel_id %>" style="color: #28a745; text-decoration: none; font-weight: bold;">
                                    <%= msg.getTitle() %>
                                </a>
                            </td>
                            <td><%= sdf.format(msg.getCreated_at()) %></td>
                            <td>
                                <% if(msg.getFile_path() != null && !msg.getFile_path().equals("")) { %>
                                    <a href="../upload/<%= msg.getFile_path() %>" download="<%= msg.getFile_path() %>" class="file-icon" style="text-decoration: none; color: #28a745; background-color: #d4edda; border: 1px solid #c3e6cb;">💾 받기</a>
                                <% } else { %>
                                    <span style="color: #ccc;">-</span>
                                <% } %>
                            </td>
                        </tr>
                    <%
                            }
                        }
                    %>
                    </tbody>
                </table>
                
            <%-- ========================= [실시간 Q&A] ========================= --%>
            <% } else if(menu.equals("qna")) { %>
                <h3>💬 실시간 Q&A</h3>
                <p style="color: gray;">여기에 새로고침 없이 대화가 이어지는 채팅창이 뜰 예정입니다.</p>
            <% } %>
            
        </div>
    </div>

</body>
</html>