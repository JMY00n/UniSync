<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="channel.MessageDAO" %>
<%@ page import="channel.MessageVO" %>
<%@ page import="java.util.ArrayList" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%
    // 로그인한 유저 아이디 가져오기 (본인 글 확인용)
    String userId = (String) session.getAttribute("user_id");
    if(userId == null) userId = (String) session.getAttribute("id");

    int channel_id = Integer.parseInt(request.getParameter("channel_id"));
    
    MessageDAO mdao = MessageDAO.getInstance();
    ArrayList<MessageVO> qnaList = mdao.getMessageList(channel_id, "Q&A");
    
    SimpleDateFormat dateFmt = new SimpleDateFormat("yyyy년 MM월 dd일");
    SimpleDateFormat timeFmt = new SimpleDateFormat("HH:mm");
    String prevDate = ""; 

    if(qnaList.isEmpty()) {
%>
    <div style="text-align:center; padding:30px; color:gray;">아직 등록된 질문이 없습니다. 첫 질문을 남겨보세요!</div>
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
%>
            <div style="border-bottom: 1px solid #eee; padding: 15px 0; margin-bottom: 5px;">
                <div style="font-weight: bold; color: #17a2b8; font-size: 14px; margin-bottom: 8px;">
                    👤 <%= msg.getUser_id() %> 
                    <span style="color:gray; font-size:12px; font-weight:normal; margin-left:10px;"><%= timeFmt.format(msg.getCreated_at()) %></span>
                    
                    <% if(userId != null && userId.equals(msg.getUser_id())) { %>
                        <button type="button" onclick="editQna(<%= msg.getMessage_id() %>)" style="margin-left: 10px; font-size: 11px; padding: 2px 6px; cursor: pointer; border: 1px solid #ccc; background-color: #fff; border-radius: 3px;">수정</button>
                    <% } %>
                </div>
                <div id="qna_content_<%= msg.getMessage_id() %>" style="font-size: 15px; color: #333; white-space: pre-wrap;"><%= msg.getContent() %></div>
            </div>
<%
        }
    }
%>