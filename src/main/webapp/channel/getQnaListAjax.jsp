<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.MessageDAO" %>
<%@ page import="channel.MessageVO" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    String userId = (String) session.getAttribute("user_id");
    if(userId == null) userId = (String) session.getAttribute("id");
    Integer role = session.getAttribute("role") != null ? (Integer) session.getAttribute("role") : 0;

    int channel_id = Integer.parseInt(request.getParameter("channel_id"));
    
    MessageDAO mdao = MessageDAO.getInstance();
    ArrayList<MessageVO> qnaList = mdao.getMessageList(channel_id, "Q&A");
    
    SimpleDateFormat dateFmt = new SimpleDateFormat("yyyy년 MM월 dd일");
    SimpleDateFormat timeFmt = new SimpleDateFormat("HH:mm");
    String prevDate = ""; 

    if(qnaList.isEmpty()) {
%>
    <div style="text-align:center; padding:30px; color:gray;">아직 등록된 질문이 없습니다.</div>
<%
    } else {
        for(MessageVO msg : qnaList) {
            String currentDate = dateFmt.format(msg.getCreated_at());
            
            if(!currentDate.equals(prevDate)) {
%>
                <div style="text-align: center; margin: 20px 0 10px 0;">
                    <span style="background-color: #e9ecef; color: #495057; font-size: 12px; padding: 4px 15px; border-radius: 20px; font-weight: bold;">
                        📅 <%= currentDate %>
                    </span>
                </div>
<%
                prevDate = currentDate;
            }
            
            // 고정글일 경우 배경색과 테두리 다르게 적용
            String boxStyle = msg.getIs_pinned() == 1 ? "background-color: #fff9db; border: 2px solid #fcc419; border-radius: 8px; padding: 15px; margin-bottom: 10px;" : "border-bottom: 1px solid #eee; padding: 15px 0; margin-bottom: 5px;";
%>
            <div style="<%= boxStyle %>">
                <div style="font-weight: bold; color: <%= msg.getIs_pinned() == 1 ? "#d9480f" : "#17a2b8" %>; font-size: 14px; margin-bottom: 8px;">
                    <%= msg.getIs_pinned() == 1 ? "📌 [공지]" : "👤" %> <%= msg.getUser_id() %> 
                    <span style="color:gray; font-size:12px; font-weight:normal; margin-left:10px;"><%= timeFmt.format(msg.getCreated_at()) %></span>
                    
                    <% if(userId != null && userId.equals(msg.getUser_id())) { %>
                        <button type="button" onclick="editQna(<%= msg.getMessage_id() %>)" style="margin-left: 10px; font-size: 11px; padding: 2px 6px; cursor: pointer; border: 1px solid #ccc; background-color: #fff; border-radius: 3px;">수정</button>
                    <% } %>
                    
                    <% if(role == 1) { %>
                        <% if(msg.getIs_pinned() == 1) { %>
                            <button type="button" onclick="togglePin(<%= msg.getMessage_id() %>, false)" style="float: right; font-size: 11px; padding: 3px 8px; cursor: pointer; border: none; background-color: #6c757d; color: white; border-radius: 3px;">고정 해제</button>
                        <% } else { %>
                            <button type="button" onclick="togglePin(<%= msg.getMessage_id() %>, true)" style="float: right; font-size: 11px; padding: 3px 8px; cursor: pointer; border: 1px solid #fcc419; background-color: #fff9db; color: #d9480f; border-radius: 3px; font-weight: bold;">상단 고정</button>
                        <% } %>
                    <% } %>
                </div>
                <div id="qna_content_<%= msg.getMessage_id() %>" style="font-size: 15px; color: #333; white-space: pre-wrap;"><%= msg.getContent() %></div>
            </div>
<%
        }
    }
%>