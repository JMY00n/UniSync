<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="channel.MessageDAO" %>
<%@ page import="channel.MessageVO" %>
<%
    request.setCharacterEncoding("utf-8");
    String userId = (String) session.getAttribute("user_id");
    if (userId == null) userId = (String) session.getAttribute("id");
    
 // 1. 서버의 실제 저장 경로와 최대 파일 용량(20MB) 설정
    String savePath = request.getServletContext().getRealPath("/upload");
    int maxSize = 20 * 1024 * 1024; // 강의자료니까 용량을 좀 더 넉넉히 20MB로 설정!
    String encoding = "UTF-8";
    try {
    	// 2. 파일 업로드 실행 및 중복 파일명 자동 변경 정책(DefaultFileRenamePolicy) 적용
        MultipartRequest multi = new MultipartRequest(request, savePath, maxSize, encoding, new DefaultFileRenamePolicy());
        
        int channel_id = Integer.parseInt(multi.getParameter("channel_id"));
        String board_name = multi.getParameter("board_name");
        String title = multi.getParameter("title");
        String content = multi.getParameter("content");
        
     // 3. 업로드 완료 후 실제 저장된 파일 이름만 추출하여 DB 저장을 위해 준비
        String fileName = multi.getFilesystemName("uploadFile");
        
        MessageVO msg = new MessageVO();
        msg.setChannel_id(channel_id);
        msg.setBoard_name(board_name);
        msg.setUser_id(userId);
        msg.setTitle(title);
        msg.setContent(content);
        msg.setFile_path(fileName);
        
        MessageDAO mdao = MessageDAO.getInstance();
        boolean isSuccess = mdao.insertMessage(msg);
        
        if(isSuccess) {
%>
            <script>
                alert("강의자료가 성공적으로 등록되었습니다.");
                // 등록 완료 후 강의자료실(menu=material) 목록으로 리다이렉트
                location.href = "../lectures/lectureMain.jsp?channel_id=<%= channel_id %>&menu=material";
            </script>
<%
        } else {
%>
            <script>alert("DB 저장 실패!"); history.go(-1);</script>
<%
        }
    } catch(Exception e) {
        e.printStackTrace();
%>
        <script>alert("파일 업로드 중 오류가 발생했습니다. (최대 20MB 제한)"); history.go(-1);</script>
<%
    }
%>