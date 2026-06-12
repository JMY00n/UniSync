<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="com.oreilly.servlet.MultipartRequest" %>
<%@ page import="com.oreilly.servlet.multipart.DefaultFileRenamePolicy" %>
<%@ page import="channel.MessageDAO" %>
<%@ page import="channel.MessageVO" %>
<%@ page import="java.io.File" %>
<%
    request.setCharacterEncoding("utf-8");

    // 로그인 세션 확인
    String userId = (String) session.getAttribute("user_id");
    if (userId == null) userId = (String) session.getAttribute("id");
    
    if(userId == null) {
%>
        <script>alert("로그인이 필요합니다."); location.href="../login/login.jsp";</script>
<%
        return;
    }

    // 1. 첨부파일 저장 경로 설정 (아까 만든 webapp/upload 폴더의 실제 컴퓨터 경로)
    String savePath = request.getServletContext().getRealPath("/upload");
    int maxSize = 10 * 1024 * 1024; // 최대 업로드 용량: 10MB
    String encoding = "UTF-8";
    
    try {
        // 2. 파일 업로드 실행 (cos.jar 핵심 코드)
        // 이 코드가 실행되는 순간 파일이 upload 폴더에 쏙 들어감!
        MultipartRequest multi = new MultipartRequest(request, savePath, maxSize, encoding, new DefaultFileRenamePolicy());
        
        // 3. 폼에서 넘어온 데이터 받기 (파일 업로드 폼은 request.getParameter 대신 multi.getParameter를 써야 함)
        int channel_id = Integer.parseInt(multi.getParameter("channel_id"));
        String board_name = multi.getParameter("board_name");
        String title = multi.getParameter("title");
        String content = multi.getParameter("content");
        
        // 4. 업로드된 실제 파일 이름 빼오기
        String fileName = multi.getFilesystemName("uploadFile");
        
        // 5. VO에 담기
        MessageVO msg = new MessageVO();
        msg.setChannel_id(channel_id);
        msg.setBoard_name(board_name);
        msg.setUser_id(userId);
        msg.setTitle(title);
        msg.setContent(content);
        msg.setFile_path(fileName); // 파일이 없으면 알아서 null이 들어감
        
        // 6. DAO로 DB에 저장
        MessageDAO mdao = MessageDAO.getInstance();
        boolean isSuccess = mdao.insertMessage(msg);
        
        if(isSuccess) {
%>
            <script>
                alert("공지사항이 성공적으로 등록되었습니다.");
                // 작성 완료 후 다시 해당 방의 공지사항 목록으로 튕겨줌!
                location.href = "lectureMain.jsp?channel_id=<%= channel_id %>&menu=notice";
            </script>
<%
        } else {
%>
            <script>alert("DB 저장 중 에러가 발생했습니다."); history.go(-1);</script>
<%
        }
    } catch(Exception e) {
        e.printStackTrace();
%>
        <script>
            alert("파일 용량이 너무 크거나 업로드 중 오류가 발생했습니다. (10MB 이하 권장)");
            history.go(-1);
        </script>
<%
    }
%>