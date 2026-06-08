package member;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.naming.InitialContext;
import javax.sql.DataSource;

public class MemberDAO {
    private static MemberDAO instance = new MemberDAO();

    public static MemberDAO getinstance() {
        return instance;
    }

    private MemberDAO() {}

    private Connection getConnection() {
        try {
            InitialContext ic = new InitialContext();
            DataSource ds = (DataSource) ic.lookup("java:comp/env/jdbc/app");
            return ds.getConnection();
        } catch (Exception e) {
            System.out.println("데이터베이스 연결에 문제가 발생했습니다.");
            e.printStackTrace();
            return null;
        }
    }

    // 로그인 — role 체크 없이 아이디/비번만
    public int login(String user_id, String password) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            String sql = "SELECT password FROM member WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, user_id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                String db_password = rs.getString("password");
                if (db_password.equals(password)) return 1;
                else return 0;
            } else {
                return -1;
            }
        } catch (Exception e) {
            System.out.println("로그인 실패");
            e.printStackTrace();
            return -2;
        } finally {
            if (rs    != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn  != null) conn.close();
        }
    }

    // 회원 정보 가져오기
    public MemberVO getMember(String user_id) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        MemberVO member = null;
        try {
            conn = getConnection();
            String sql = "SELECT * FROM member WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, user_id);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                member = new MemberVO();
                member.setUser_id(rs.getString("user_id"));
                member.setPassword(rs.getString("password"));
                member.setName(rs.getString("name"));
                member.setRole(rs.getInt("role"));
                return member;
            }
        } catch (Exception e) {
            System.out.println("getMember 에러");
            e.printStackTrace();
        } finally {
            if (rs    != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn  != null) conn.close();
        }
        return null;
    }

    // 회원가입
    public void register(MemberVO member) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            String sql = "INSERT INTO member VALUES(?, ?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, member.getUser_id());
            pstmt.setString(2, member.getPassword());
            pstmt.setString(3, member.getName());
            pstmt.setInt(4,    member.getRole());
            pstmt.executeUpdate();
        } catch (Exception e) {
            System.out.println("회원가입 실패");
            e.printStackTrace();
        } finally {
            if (pstmt != null) pstmt.close();
            if (conn  != null) conn.close();
        }
    }

    // 아이디 중복 검사
    public int validate(String user_id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = getConnection();
            String sql = "SELECT user_id FROM member WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, user_id);
            rs = pstmt.executeQuery();
            if (rs.next()) return 0;
            else return 1;
        } catch (Exception e) {
            System.out.println("중복 검사 에러");
            e.printStackTrace();
            return -2;
        }
    }
}
