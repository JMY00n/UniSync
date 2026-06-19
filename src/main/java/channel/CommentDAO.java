package channel;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import javax.naming.InitialContext;
import javax.sql.DataSource;

// 공지 상세(noticeDetail)의 댓글 기능 담당 DAO
public class CommentDAO {
    // 1. 싱글톤 패턴 적용 (MessageDAO와 동일한 방식)
    private static CommentDAO instance = new CommentDAO();

    public static CommentDAO getInstance() {
        return instance;
    }

    private CommentDAO() {}

    // 2. 데이터베이스 커넥션 풀(DBCP) 연결
    private Connection getConnection() {
        try {
            InitialContext ic = new InitialContext();
            DataSource ds = (DataSource) ic.lookup("java:comp/env/jdbc/app");
            return ds.getConnection();
        } catch (Exception e) {
            System.out.println("🚨 [CommentDAO] 데이터베이스 연결 실패");
            e.printStackTrace();
            return null;
        }
    }

    // 3. 특정 게시글(message_id)의 댓글 목록 조회 — 최신순 + 페이지네이션
    public ArrayList<CommentVO> getCommentList(int message_id, int page, int perPage) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        ArrayList<CommentVO> list = new ArrayList<>();

        if (page < 1) page = 1;
        int offset = (page - 1) * perPage;

        try {
            conn = getConnection();
            // 최신 댓글이 위에 오도록 comment_id 기준 내림차순 정렬
            String sql = "SELECT * FROM comment WHERE message_id = ? ORDER BY comment_id DESC LIMIT ? OFFSET ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, message_id);
            pstmt.setInt(2, perPage);
            pstmt.setInt(3, offset);
            rs = pstmt.executeQuery();

            // ResultSet에서 데이터를 꺼내 VO 리스트로 묶어 반환
            while (rs.next()) {
                CommentVO c = new CommentVO();
                c.setComment_id(rs.getInt("comment_id"));
                c.setMessage_id(rs.getInt("message_id"));
                c.setUser_id(rs.getString("user_id"));
                c.setContent(rs.getString("content"));
                c.setCreated_at(rs.getTimestamp("created_at"));
                list.add(c);
            }
        } catch (Exception e) {
            System.out.println("🚨 [CommentDAO] 댓글 목록 조회 중 에러 발생!");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return list;
    }

    // 4. 특정 게시글의 전체 댓글 수 (페이지네이션 계산용)
    public int countComments(int message_id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int total = 0;

        try {
            conn = getConnection();
            String sql = "SELECT COUNT(*) FROM comment WHERE message_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, message_id);
            rs = pstmt.executeQuery();
            if (rs.next()) total = rs.getInt(1);
        } catch (Exception e) {
            System.out.println("🚨 [CommentDAO] 댓글 수 조회 중 에러 발생!");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return total;
    }

    // 4-1. 댓글 1개 상세 조회 (수정/삭제 시 작성자 권한 검증용)
    public CommentVO getCommentById(int comment_id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        CommentVO c = null;

        try {
            conn = getConnection();
            String sql = "SELECT * FROM comment WHERE comment_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, comment_id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                c = new CommentVO();
                c.setComment_id(rs.getInt("comment_id"));
                c.setMessage_id(rs.getInt("message_id"));
                c.setUser_id(rs.getString("user_id"));
                c.setContent(rs.getString("content"));
                c.setCreated_at(rs.getTimestamp("created_at"));
            }
        } catch (Exception e) {
            System.out.println("🚨 [CommentDAO] 댓글 상세 조회 중 에러 발생!");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return c;
    }

    // 5. 댓글 작성 (INSERT) — created_at은 DB DEFAULT(CURRENT_TIMESTAMP)에 맡김
    public boolean insertComment(CommentVO c) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            String sql = "INSERT INTO comment (message_id, user_id, content) VALUES (?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, c.getMessage_id());
            pstmt.setString(2, c.getUser_id());
            pstmt.setString(3, c.getContent());
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("🚨 [CommentDAO] 댓글 작성 중 에러 발생!");
            e.printStackTrace();
            return false;
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    }

    // 6. 댓글 수정 (UPDATE) — 내용만 덮어씀
    public boolean updateComment(CommentVO c) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            String sql = "UPDATE comment SET content = ? WHERE comment_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, c.getContent());
            pstmt.setInt(2, c.getComment_id());
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("🚨 [CommentDAO] 댓글 수정 중 에러 발생!");
            e.printStackTrace();
            return false;
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    }

    // 7. 댓글 삭제 (DELETE)
    public boolean deleteComment(int comment_id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            String sql = "DELETE FROM comment WHERE comment_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, comment_id);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("🚨 [CommentDAO] 댓글 삭제 중 에러 발생!");
            e.printStackTrace();
            return false;
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
    }
}
