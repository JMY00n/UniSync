package channel;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import javax.naming.InitialContext;
import javax.sql.DataSource;

public class MessageDAO {
    // 1. 싱글톤 패턴 적용 (DAO 객체를 하나만 생성해서 공유)
    private static MessageDAO instance = new MessageDAO();

    public static MessageDAO getInstance() {
        return instance;
    }

    private MessageDAO() {}

    // 2. 데이터베이스 커넥션 풀(DBCP) 연결 메서드
    private Connection getConnection() {
        try {
            InitialContext ic = new InitialContext();
            DataSource ds = (DataSource) ic.lookup("java:comp/env/jdbc/app");
            return ds.getConnection();
        } catch (Exception e) {
            System.out.println("🚨 데이터베이스 연결 실패");
            e.printStackTrace();
            return null;
        }
    }

    // 3. 특정 방(channel_id)과 특정 게시판(board_name)의 글 목록 조회 (최신순)
    public ArrayList<MessageVO> getMessageList(int channel_id, String board_name) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        ArrayList<MessageVO> list = new ArrayList<>();

        try {
            conn = getConnection();
            String sql = "SELECT * FROM message WHERE channel_id = ? AND board_name = ? ORDER BY message_id DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, channel_id);
            pstmt.setString(2, board_name);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                MessageVO msg = new MessageVO();
                msg.setMessage_id(rs.getInt("message_id"));
                msg.setChannel_id(rs.getInt("channel_id"));
                msg.setBoard_name(rs.getString("board_name"));
                msg.setUser_id(rs.getString("user_id"));
                msg.setTitle(rs.getString("title"));
                msg.setContent(rs.getString("content"));
                msg.setCreated_at(rs.getTimestamp("created_at"));
                msg.setFile_path(rs.getString("file_path"));
                list.add(msg);
            }
        } catch (Exception e) {
            System.out.println("🚨 [MessageDAO] 게시글 목록 조회 중 에러 발생!");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch(Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if (conn != null) try { conn.close(); } catch(Exception e) {}
        }
        return list;
    }

    // 4. 특정 게시글 1개 상세 조회 (글 제목 클릭 시)
    public MessageVO getMessageById(int message_id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        MessageVO msg = null;

        try {
            conn = getConnection();
            String sql = "SELECT * FROM message WHERE message_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, message_id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                msg = new MessageVO();
                msg.setMessage_id(rs.getInt("message_id"));
                msg.setChannel_id(rs.getInt("channel_id"));
                msg.setBoard_name(rs.getString("board_name"));
                msg.setUser_id(rs.getString("user_id"));
                msg.setTitle(rs.getString("title"));
                msg.setContent(rs.getString("content"));
                msg.setCreated_at(rs.getTimestamp("created_at"));
                msg.setFile_path(rs.getString("file_path"));
            }
        } catch (Exception e) {
            System.out.println("🚨 [MessageDAO] 상세 글 조회 중 에러 발생!");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return msg;
    }

    // 5. 게시글(공지사항, 강의자료 등) 작성 (INSERT)
    public boolean insertMessage(MessageVO msg) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            String sql = "INSERT INTO message (channel_id, board_name, user_id, title, content, file_path) VALUES (?, ?, ?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, msg.getChannel_id());
            pstmt.setString(2, msg.getBoard_name());
            pstmt.setString(3, msg.getUser_id());
            pstmt.setString(4, msg.getTitle());
            pstmt.setString(5, msg.getContent());
            pstmt.setString(6, msg.getFile_path()); // 파일이 없으면 null
            
            int result = pstmt.executeUpdate();
            return result > 0;
        } catch (Exception e) {
            System.out.println("🚨 [MessageDAO] 게시글 작성 중 에러 발생!");
            e.printStackTrace();
            return false;
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if (conn != null) try { conn.close(); } catch(Exception e) {}
        }
    }

    // 6. 특정 게시글 삭제 (DELETE)
    public boolean deleteMessage(int message_id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            String sql = "DELETE FROM message WHERE message_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, message_id);
            
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("🚨 [MessageDAO] 글 삭제 중 에러 발생!");
            e.printStackTrace();
            return false;
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if (conn != null) try { conn.close(); } catch(Exception e) {}
        }
    }

    // 7. 특정 게시글 수정 (UPDATE)
    public boolean updateMessage(MessageVO msg) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            
            // 첨부파일이 새로 등록되었는지 여부에 따라 쿼리 분리
            if(msg.getFile_path() != null) {
                String sql = "UPDATE message SET title=?, content=?, file_path=? WHERE message_id=?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, msg.getTitle());
                pstmt.setString(2, msg.getContent());
                pstmt.setString(3, msg.getFile_path());
                pstmt.setInt(4, msg.getMessage_id());
            } else {
                String sql = "UPDATE message SET title=?, content=? WHERE message_id=?";
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, msg.getTitle());
                pstmt.setString(2, msg.getContent());
                pstmt.setInt(3, msg.getMessage_id());
            }
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("🚨 [MessageDAO] 글 수정 중 에러 발생!");
            e.printStackTrace();
            return false;
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if (conn != null) try { conn.close(); } catch(Exception e) {}
        }
    }
}