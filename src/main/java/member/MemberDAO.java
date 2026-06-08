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
	
	private MemberDAO() { }

	private Connection getConnection() {
		try {
			InitialContext ic = new InitialContext();
			DataSource ds = (DataSource) ic.lookup("java:comp/env/jdbc/app");
			Connection conn = ds.getConnection();
			return conn;
		} catch (Exception e) {
			System.out.println("데이터베이스 연결에 문제가 발생했습니다.");
			e.printStackTrace();

			return null;
		}

	}
	
	// 회원가입
	public void register(MemberVO member) throws SQLException {
		Connection conn = null;
		PreparedStatement pstmt = null;
		
		try {
			conn = getConnection();
			// 아이디, 비밀번호 이름, 학생(0)or교사(1)
			String sql = "INSERT INTO member VALUES(?, ?, ?, ?)";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, member.getUser_id());
			pstmt.setString(2, member.getPassword());
			pstmt.setString(3, member.getName());
			pstmt.setInt(4, member.getRole());
			pstmt.executeUpdate();
		} catch (Exception error) {
			System.out.println("회원가입 실패!!");
			System.out.println(error);
		} finally {
			if (conn != null) conn.close();
			if (pstmt != null) conn.close();
		}
	}
	
	// 로그인
	public int login(String user_id, String password, int role) throws SQLException {
		Connection conn = null;
		PreparedStatement pstmt = null;
		ResultSet rs = null;
		try {
			conn = getConnection();
			String sql = "SELECT password FROM member WHERE user_id = ? AND role = ?";
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, user_id);
			pstmt.setInt(2, role);
			
			rs = pstmt.executeQuery();
			
			if (rs.next()) { // 아이디가 존재하면 비밀번호 검사
				String db_password = rs.getString("password");
				if (db_password.equals(password)) return 1;
				else return 0;
			} else {
				// 아이디가 존재하지 않음
				return -1;
			}
			
		} catch (Exception error) {
			System.out.println("로그인 실패");
			System.out.println(error);
			return -2; // 시스템 에러 시에는 -2 리턴
		} finally {
			if (rs != null) rs.close();
			if (pstmt != null) pstmt.close();
			if (conn != null) conn.close();
		}
		
	}
	
	// 중복검사
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
			
			if (rs.next()) return 0; // 0을 넘기면 회원가입 불가능
			else return 1;		     // 1을 넘기면 회원가입 가능
			
		} catch (Exception error) {
			System.out.println("중복 검사 중 에러발생");
			System.out.println(error);
			return -2;
		}
	}
	
	// 회원 가져오기
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
			
		} catch (Exception error) {
			System.out.println("getMember(Type:MemberDAO)에서 에러 발생!!");
			System.out.println(error);
		} finally {
			if (conn != null) conn.close();
			if (pstmt != null) pstmt.close();
			if (rs != null) rs.close();
		}
		
		return null;
	}

}
