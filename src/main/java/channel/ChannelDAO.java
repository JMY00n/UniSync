package channel;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.ArrayList;
import javax.naming.InitialContext;
import javax.sql.DataSource;
import member.MemberVO;

public class ChannelDAO {
    // 1. 싱글톤 패턴 적용 (하나의 객체만 생성)
    private static ChannelDAO instance = new ChannelDAO();

    public static ChannelDAO getInstance() {
        return instance;
    }

    private ChannelDAO() {}

    // 2. DB 연결 (DBCP 사용)
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

    // 3. 채널(강의실) 생성 및 3대 서브보드(공지사항, 강의자료, Q&A) 동시 자동 생성 (트랜잭션 적용)
    public boolean createChannel(ChannelVO channel) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        PreparedStatement pstmtBoard = null;
        ResultSet rs = null;
        boolean isSuccess = false;

        try {
            conn = getConnection();
            
            // 트랜잭션 시작 (방과 게시판 생성을 하나로 묶음)
            conn.setAutoCommit(false);	// 트랜잭션 시작 (방 + 게시판 생성을 하나로 묶음)

         // 1. 강의실(channel) INSERT 및 방금 생성된 방 번호(PK) 요청
            String sql1 = "INSERT INTO channel(user_id, channel_name, entry_code) VALUES(?, ?, ?)";
            // Statement.RETURN_GENERATED_KEYS를 통해 자동 생성된 채널 ID 확보
            pstmt = conn.prepareStatement(sql1, Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, channel.getUser_id());
            pstmt.setString(2, channel.getChannel_name());
            pstmt.setString(3, channel.getEntry_code());
            int result1 = pstmt.executeUpdate();
            if (result1 > 0) {
                // 2단계: 방금 생성된 방 번호(channel_id) 가져오기
                rs = pstmt.getGeneratedKeys();
                int newChannelId = -1;
                if (rs.next()) {
                    newChannelId = rs.getInt(1); 
                }
                if (newChannelId != -1) {
                    // 3단계: 팀장님 복합키 구조에 맞춰 subboard 테이블에 게시판 3개 삽입
                    String sql2 = "INSERT INTO subboard(channel_id, board_name) VALUES(?, ?)";
                    pstmtBoard = conn.prepareStatement(sql2);
                    String[] boardNames = {"공지사항", "강의자료", "Q&A"};
                    for (String bName : boardNames) {
                        pstmtBoard.setInt(1, newChannelId);
                        pstmtBoard.setString(2, bName);
                        pstmtBoard.executeUpdate(); 
                    }
                    // 모든 작업 성공 시 DB 반영
                    conn.commit();
                    isSuccess = true;
                } else {
                    conn.rollback(); // 방 번호 못 가져오면 취소
                }
            }
        } catch (Exception e) {
            System.out.println("🚨 [ChannelDAO] 채널 및 서브보드 생성 중 에러 발생!");
            e.printStackTrace();
            try { if (conn != null) conn.rollback(); } catch (Exception ex) {} 
        } finally {
            // 오토커밋 원래대로 복구
            try { if (conn != null) conn.setAutoCommit(true); } catch (Exception e) {} 
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmtBoard != null) try { pstmtBoard.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return isSuccess;
    }

    // 4. 특정 방 번호(channel_id)로 채널 정보 1개 가져오기 (lectureMain.jsp 상단바에 방 이름 띄울 때 사용)
    public ChannelVO getChannelById(int channel_id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        ChannelVO channel = null;

        try {
            conn = getConnection();
            String sql = "SELECT * FROM channel WHERE channel_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, channel_id);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                channel = new ChannelVO();
                channel.setChannel_id(rs.getInt("channel_id"));
                channel.setUser_id(rs.getString("user_id"));
                channel.setChannel_name(rs.getString("channel_name"));
                channel.setEntry_code(rs.getString("entry_code"));
            }
        } catch (Exception e) {
            System.out.println("🚨 [ChannelDAO] 채널 정보 단일 조회 중 에러 발생!");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return channel;
    }

    // 5. 생성된 전체 채널 목록 가져오기 (대시보드 화면에서 방 목록 뿌려줄 때 사용)
    public ArrayList<ChannelVO> getAllChannels() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        ArrayList<ChannelVO> list = new ArrayList<>();

        try {
            conn = getConnection();
            // 최신 개설된 방이 먼저 나오도록 내림차순 정렬
            String sql = "SELECT * FROM channel ORDER BY channel_id DESC";
            pstmt = conn.prepareStatement(sql);
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
            System.out.println("🚨 [ChannelDAO] 전체 채널 목록 조회 중 에러 발생!");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return list;
    }
    
 // 6. 특정 채널(강의실) 삭제 (대시보드에서 방 삭제 시 사용)
    public boolean deleteChannel(int channel_id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            
            // [팩트 체크] 팀장님의 완벽한 DB 설계 덕분에 ON DELETE CASCADE가 걸려있음!
            // 따라서 channel 테이블에서 방 하나만 지우면, 
            // 그 방에 속한 subboard(게시판), message(글), comment(댓글)이 전부 연쇄적으로 자동 삭제됨.
            String sql = "DELETE FROM channel WHERE channel_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, channel_id);
            
            return pstmt.executeUpdate() > 0;
            
        } catch (Exception e) {
            System.out.println("🚨 [ChannelDAO] 채널 삭제 중 에러 발생!");
            e.printStackTrace();
            return false;
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if (conn != null) try { conn.close(); } catch(Exception e) {}
        }
    }
    
 // 7. 채널(강의실) 정보 수정 (updateChannel)
    // - 방 이름(channel_name)과 입장 코드(entry_code)를 변경할 때 사용
    public boolean updateChannel(ChannelVO channel) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            String sql = "UPDATE channel SET channel_name = ?, entry_code = ? WHERE channel_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, channel.getChannel_name());
            pstmt.setString(2, channel.getEntry_code());
            pstmt.setInt(3, channel.getChannel_id());
            
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("🚨 [ChannelDAO] 채널 수정 중 에러 발생!");
            e.printStackTrace();
            return false;
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if (conn != null) try { conn.close(); } catch(Exception e) {}
        }
    }

    // 8. 강의실 입장 (학생이 참여 목록에 추가됨 - joinChannel)
    // - channel_list 테이블에 학생 아이디와 방 번호를 매핑해서 INSERT
    public boolean joinChannel(int channel_id, String user_id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            
            // 팩트 체크: 이미 가입된 방인지 확인하는 로직은 JSP나 다른 곳에서 처리했다고 가정하고,
            // 여기서는 순수하게 명단에 추가하는 역할만 수행함!
            String sql = "INSERT INTO channel_list (channel_id, user_id) VALUES (?, ?)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, channel_id);
            pstmt.setString(2, user_id);
            
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("🚨 [ChannelDAO] 채널 입장(참여) 중 에러 발생! (이미 가입된 방일 수 있음)");
            e.printStackTrace();
            return false;
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if (conn != null) try { conn.close(); } catch(Exception e) {}
        }
    }
    
    // 8-1. 강의실 나가기 (학생이 참여 목록에서 빠짐 - leaveChannel)
    // - channel_list 테이블에서 해당 학생-방 매핑 행을 DELETE (본인 글/멤버십만 제거)
    public boolean leaveChannel(int channel_id, String user_id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            String sql = "DELETE FROM channel_list WHERE channel_id = ? AND user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, channel_id);
            pstmt.setString(2, user_id);
            return pstmt.executeUpdate() > 0;
        } catch (Exception e) {
            System.out.println("🚨 [ChannelDAO] 채널 나가기 중 에러 발생!");
            e.printStackTrace();
            return false;
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if (conn != null) try { conn.close(); } catch(Exception e) {}
        }
    }
    
 // 9. 입장 코드로 특정 채널(방) 정보 찾기 (학생이 코드로 방 입장할 때 사용)
    public ChannelVO getChannelByCode(String entry_code) {
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
            System.out.println("🚨 [ChannelDAO] 입장 코드로 방 검색 중 에러 발생!");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return channel;
    }
    
 // 10. 특정 채널(강의실)의 이름만 단독 수정 (updateChannelName)
    public boolean updateChannelName(int channel_id, String new_name) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        try {
            conn = getConnection();
            // 팩트 체크: 전달받은 새 이름(new_name)으로 해당 방(channel_id)의 이름만 업데이트!
            String sql = "UPDATE channel SET channel_name = ? WHERE channel_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, new_name);
            pstmt.setInt(2, channel_id);
            
            return pstmt.executeUpdate() > 0;
            
        } catch (Exception e) {
            System.out.println("🚨 [ChannelDAO] 강의실 이름 수정 중 에러 발생!");
            e.printStackTrace();
            return false;
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch(Exception e) {}
            if (conn != null) try { conn.close(); } catch(Exception e) {}
        }
    }
    
 // 11. 특정 교수가 개설한 강의실 목록 조회 (getChannelsByProfessor)
    public ArrayList<ChannelVO> getChannelsByProfessor(String user_id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        ArrayList<ChannelVO> list = new ArrayList<>();

        try {
            conn = getConnection();
            // 교수 본인 아이디로 개설된 방만 내림차순(최신순)으로 가져옴
            String sql = "SELECT * FROM channel WHERE user_id = ? ORDER BY channel_id DESC";
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
            System.out.println("🚨 [ChannelDAO] 교수용 강의실 목록 조회 중 에러 발생!");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return list;
    }

    // 12. 특정 학생이 참여 중인 강의실 목록 조회 (getChannelsByStudent)
    public ArrayList<ChannelVO> getChannelsByStudent(String user_id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        ArrayList<ChannelVO> list = new ArrayList<>();

        try {
            conn = getConnection();
            // 팩트 체크: channel 테이블과 channel_list 테이블을 JOIN해서 학생이 가입한 방만 쏙 뽑아옴!
            String sql = "SELECT c.* FROM channel c JOIN channel_list cl ON c.channel_id = cl.channel_id WHERE cl.user_id = ? ORDER BY c.channel_id DESC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, user_id);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                ChannelVO channel = new ChannelVO();
                channel.setChannel_id(rs.getInt("channel_id"));
                channel.setUser_id(rs.getString("user_id")); // 개설 교수 아이디
                channel.setChannel_name(rs.getString("channel_name"));
                channel.setEntry_code(rs.getString("entry_code"));
                list.add(channel);
            }
        } catch (Exception e) {
            System.out.println("🚨 [ChannelDAO] 학생용 강의실 목록 조회 중 에러 발생!");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return list;
    }

    // ═══════════════════════════════════════════════════════════════
    // [대시보드 추가분] 통계 / 최근활동 조회 메서드
    // ═══════════════════════════════════════════════════════════════

    // 13. 특정 강의실의 수강생 수 (channel_list 인원 수)
    public int countStudents(int channel_id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int cnt = 0;
        try {
            conn = getConnection();
            String sql = "SELECT COUNT(*) FROM channel_list WHERE channel_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, channel_id);
            rs = pstmt.executeQuery();
            if (rs.next()) cnt = rs.getInt(1);
        } catch (Exception e) {
            System.out.println("🚨 [ChannelDAO] 강의실 수강생 수 조회 중 에러 발생!");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return cnt;
    }

    // 14. 특정 강의실의 게시판 수 (subboard 개수)
    public int countBoards(int channel_id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int cnt = 0;
        try {
            conn = getConnection();
            String sql = "SELECT COUNT(*) FROM subboard WHERE channel_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, channel_id);
            rs = pstmt.executeQuery();
            if (rs.next()) cnt = rs.getInt(1);
        } catch (Exception e) {
            System.out.println("🚨 [ChannelDAO] 강의실 게시판 수 조회 중 에러 발생!");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return cnt;
    }

    // 15. 교수의 전체 강의실 통합 수강생 수 (여러 방에 중복 가입한 학생은 1명으로 - DISTINCT)
    public int countTotalStudents(String professorId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int cnt = 0;
        try {
            conn = getConnection();
            String sql = "SELECT COUNT(DISTINCT cl.user_id) "
                       + "FROM channel_list cl JOIN channel c ON cl.channel_id = c.channel_id "
                       + "WHERE c.user_id = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, professorId);
            rs = pstmt.executeQuery();
            if (rs.next()) cnt = rs.getInt(1);
        } catch (Exception e) {
            System.out.println("🚨 [ChannelDAO] 총 수강생 수 조회 중 에러 발생!");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return cnt;
    }

    // 16. 이번 주(최근 7일) 새 글 수 - 교수가 개설한 강의실 전체 기준
    public int countWeeklyMessagesByProfessor(String professorId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int cnt = 0;
        try {
            conn = getConnection();
            String sql = "SELECT COUNT(*) FROM message m "
                       + "JOIN channel c ON m.channel_id = c.channel_id "
                       + "WHERE c.user_id = ? AND m.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, professorId);
            rs = pstmt.executeQuery();
            if (rs.next()) cnt = rs.getInt(1);
        } catch (Exception e) {
            System.out.println("🚨 [ChannelDAO] 이번 주 새 글 수 조회(교수) 중 에러 발생!");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return cnt;
    }

    // 17. 이번 주(최근 7일) 새 글 수 - 학생이 참여 중인 강의실 전체 기준
    public int countWeeklyMessagesByStudent(String studentId) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        int cnt = 0;
        try {
            conn = getConnection();
            String sql = "SELECT COUNT(*) FROM message m "
                       + "JOIN channel_list cl ON m.channel_id = cl.channel_id "
                       + "WHERE cl.user_id = ? AND m.created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, studentId);
            rs = pstmt.executeQuery();
            if (rs.next()) cnt = rs.getInt(1);
        } catch (Exception e) {
            System.out.println("🚨 [ChannelDAO] 이번 주 새 글 수 조회(학생) 중 에러 발생!");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return cnt;
    }

    // 18. 최근 활동(전체 강의실 최근 글) - 교수: 본인이 개설한 강의실 기준
    public ArrayList<ActivityVO> getRecentActivityByProfessor(String professorId, int limit) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        ArrayList<ActivityVO> list = new ArrayList<>();
        try {
            conn = getConnection();
            String sql = "SELECT m.title, m.board_name, m.created_at, c.channel_name "
                       + "FROM message m JOIN channel c ON m.channel_id = c.channel_id "
                       + "WHERE c.user_id = ? ORDER BY m.created_at DESC LIMIT ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, professorId);
            pstmt.setInt(2, limit);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                ActivityVO a = new ActivityVO();
                a.setTitle(rs.getString("title"));
                a.setBoard_name(rs.getString("board_name"));
                a.setCreated_at(rs.getTimestamp("created_at"));
                a.setChannel_name(rs.getString("channel_name"));
                list.add(a);
            }
        } catch (Exception e) {
            System.out.println("🚨 [ChannelDAO] 최근 활동 조회(교수) 중 에러 발생!");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return list;
    }

    // 19. 최근 활동(전체 강의실 최근 글) - 학생: 본인이 참여 중인 강의실 기준
    public ArrayList<ActivityVO> getRecentActivityByStudent(String studentId, int limit) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        ArrayList<ActivityVO> list = new ArrayList<>();
        try {
            conn = getConnection();
            String sql = "SELECT m.title, m.board_name, m.created_at, c.channel_name "
                       + "FROM message m "
                       + "JOIN channel c ON m.channel_id = c.channel_id "
                       + "JOIN channel_list cl ON cl.channel_id = c.channel_id "
                       + "WHERE cl.user_id = ? ORDER BY m.created_at DESC LIMIT ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, studentId);
            pstmt.setInt(2, limit);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                ActivityVO a = new ActivityVO();
                a.setTitle(rs.getString("title"));
                a.setBoard_name(rs.getString("board_name"));
                a.setCreated_at(rs.getTimestamp("created_at"));
                a.setChannel_name(rs.getString("channel_name"));
                list.add(a);
            }
        } catch (Exception e) {
            System.out.println("🚨 [ChannelDAO] 최근 활동 조회(학생) 중 에러 발생!");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return list;
    }

    // 20. 특정 채널의 참여 멤버 명단 (개설 교수 + 입장한 학생 전체)
    //  - 온/오프라인 상태 없이, 누가 이 채널에 속해 있는지 명단만 조회
    //  - 정렬: 교수(role=1) 먼저 → 그다음 이름순
    public ArrayList<MemberVO> getChannelMembers(int channel_id) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        ArrayList<MemberVO> list = new ArrayList<>();
        try {
            conn = getConnection();
            String sql = "SELECT m.user_id, m.name, m.role FROM member m "
                       + "WHERE m.user_id IN ( "
                       + "    SELECT user_id FROM channel WHERE channel_id = ? "
                       + "    UNION "
                       + "    SELECT user_id FROM channel_list WHERE channel_id = ? "
                       + ") ORDER BY m.role DESC, m.name";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, channel_id);
            pstmt.setInt(2, channel_id);
            rs = pstmt.executeQuery();
            while (rs.next()) {
                MemberVO mv = new MemberVO();
                mv.setUser_id(rs.getString("user_id"));
                mv.setName(rs.getString("name"));
                mv.setRole(rs.getInt("role"));
                list.add(mv);
            }
        } catch (Exception e) {
            System.out.println("🚨 [ChannelDAO] 채널 멤버 명단 조회 중 에러 발생!");
            e.printStackTrace();
        } finally {
            if (rs != null) try { rs.close(); } catch (Exception e) {}
            if (pstmt != null) try { pstmt.close(); } catch (Exception e) {}
            if (conn != null) try { conn.close(); } catch (Exception e) {}
        }
        return list;
    }
}
