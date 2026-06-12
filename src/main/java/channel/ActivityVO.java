package channel;

import java.sql.Timestamp;

/**
 * 대시보드 '최근 활동' 한 줄을 담는 VO.
 * message 테이블 + channel 테이블을 JOIN한 결과(강의실명/게시판명/제목/작성시간)를 담는다.
 */
public class ActivityVO {
    private String channel_name; // 강의실 이름
    private String board_name;   // 게시판 이름 (공지사항/강의자료/Q&A 등 - 표시용)
    private String title;        // 글 제목
    private Timestamp created_at;// 작성 시간

    public String getChannel_name() { return channel_name; }
    public void setChannel_name(String channel_name) { this.channel_name = channel_name; }

    public String getBoard_name() { return board_name; }
    public void setBoard_name(String board_name) { this.board_name = board_name; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public Timestamp getCreated_at() { return created_at; }
    public void setCreated_at(Timestamp created_at) { this.created_at = created_at; }
}
