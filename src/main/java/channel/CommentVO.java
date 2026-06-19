package channel;

import java.sql.Timestamp;

// 댓글 1건의 데이터를 담는 VO (comment 테이블과 1:1 매핑)
public class CommentVO {
    private int comment_id;       // PK (AUTO_INCREMENT)
    private int message_id;       // 어느 게시글의 댓글인지 (FK -> message)
    private String user_id;       // 작성자 학번/아이디 (FK -> member)
    private String content;       // 댓글 내용
    private Timestamp created_at; // 작성 시각 (DEFAULT CURRENT_TIMESTAMP)

    // Getter & Setter
    public int getComment_id() { return comment_id; }
    public void setComment_id(int comment_id) { this.comment_id = comment_id; }

    public int getMessage_id() { return message_id; }
    public void setMessage_id(int message_id) { this.message_id = message_id; }

    public String getUser_id() { return user_id; }
    public void setUser_id(String user_id) { this.user_id = user_id; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Timestamp getCreated_at() { return created_at; }
    public void setCreated_at(Timestamp created_at) { this.created_at = created_at; }
}
