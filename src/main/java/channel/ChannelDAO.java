package channel;

import java.util.ArrayList;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import javax.naming.InitialContext;
import javax.sql.DataSource;

public class ChannelDAO {
    private static ChannelDAO instance = new ChannelDAO();

    public static ChannelDAO getInstance() {
        return instance;
    }

    private ChannelDAO() {}

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

    // 1. 채널(강의실) 생성 메서드
    public void createChannel(ChannelVO channel) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            String sql = "INSERT INTO channel(user_id, channel_name, entry_code) VALUES(?, ?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, channel.getUser_id());
            pstmt.setString(2, channel.getChannel_name());
            pstmt.setString(3, channel.getEntry_code());
            pstmt.executeUpdate();
        } catch (Exception e) {
            System.out.println("채널 생성 실패");
            e.printStackTrace();
        } finally {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
    }
    
    // 2. 입장 코드로 채널 존재 여부 및 정보 확인 (학생용)
    public ChannelVO getChannelByCode(String entry_code) throws SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        ChannelVO channel = null;
        
        try {
            conn = getConnection();
            String sql = "SELECT * FROM channel WHERE entry_code = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, entry_code);
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                channel = new ChannelVO();
                channel.setChannel_id(rs.getInt("channel_id"));
                channel.setUser_id(rs.getString("user_id"));
                channel.setChannel_name(rs.getString("channel_name"));
                channel.setEntry_code(rs.getString("entry_code"));
            }
        } catch (Exception e) {
            System.out.println("입장 코드 조회 실패");
            e.printStackTrace();
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        return channel;
    }
    
 // 3. 학생이 채널에 입장(가입)할 때 channel_list 테이블에 추가
    public int joinChannel(int channel_id, String user_id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            // channel_id와 user_id를 묶어서 PRIMARY KEY로 뒀기 때문에 중복 가입을 알아서 막아줌
            String sql = "INSERT INTO channel_list(channel_id, user_id) VALUES(?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, channel_id);
            pstmt.setString(2, user_id);
            return pstmt.executeUpdate(); // 가입 성공 시 1 반환
        } catch (Exception e) {
            System.out.println("채널 입장 실패 (이미 가입된 방이거나 DB 오류)");
            e.printStackTrace();
            return -1; // 중복 가입 등 에러 발생 시 -1 반환
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if (conn != null) try { conn.close(); } catch(Exception e) {}
        }
    }
    
 // 3. 교수가 개설한 강의실 목록 가져오기
    public java.util.ArrayList<ChannelVO> getChannelsByProfessor(String user_id) throws java.sql.SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        java.util.ArrayList<ChannelVO> list = new java.util.ArrayList<>();
        
        try {
            conn = getConnection();
            String sql = "SELECT * FROM channel WHERE user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, user_id);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                ChannelVO channel = new ChannelVO();
                channel.setChannel_id(rs.getInt("channel_id"));
                channel.setUser_id(rs.getString("user_id"));
                channel.setChannel_name(rs.getString("channel_name"));
                channel.setEntry_code(rs.getString("entry_code"));
                list.add(channel);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        return list;
    }
    
 // 4. 학생이 가입한 강의실 목록 가져오기 (JOIN 쿼리 사용)
    public java.util.ArrayList<ChannelVO> getChannelsByStudent(String user_id) throws java.sql.SQLException {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        java.util.ArrayList<ChannelVO> list = new java.util.ArrayList<>();
        
        try {
            conn = getConnection();
            // channel_list와 channel 테이블을 조인해서 학생이 가입한 방 정보를 가져옴
            String sql = "SELECT c.* FROM channel c JOIN channel_list cl ON c.channel_id = cl.channel_id WHERE cl.user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, user_id);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                ChannelVO channel = new ChannelVO();
                channel.setChannel_id(rs.getInt("channel_id"));
                channel.setUser_id(rs.getString("user_id"));
                channel.setChannel_name(rs.getString("channel_name"));
                channel.setEntry_code(rs.getString("entry_code"));
                list.add(channel);
            }
        } catch (Exception e) {
            e.printStackTrace();
        } finally {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.close();
        }
        return list;
    }
}