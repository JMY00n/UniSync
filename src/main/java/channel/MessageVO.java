package channel;

import java.sql.Timestamp;

public class MessageVO {
    private int message_id;
    private int channel_id;
    private String board_name;
    private String user_id;
    private String title;
    private String content;
    private Timestamp created_at;
    private String file_path;
    private int is_pinned; // 0: 일반, 1: 상단 고정

    public int getIs_pinned() { return is_pinned; }
    public void setIs_pinned(int is_pinned) { this.is_pinned = is_pinned; }

    // Getter와 Setter
    public int getMessage_id() { return message_id; }
    public void setMessage_id(int message_id) { this.message_id = message_id; }

    public int getChannel_id() { return channel_id; }
    public void setChannel_id(int channel_id) { this.channel_id = channel_id; }

    public String getBoard_name() { return board_name; }
    public void setBoard_name(String board_name) { this.board_name = board_name; }

    public String getUser_id() { return user_id; }
    public void setUser_id(String user_id) { this.user_id = user_id; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Timestamp getCreated_at() { return created_at; }
    public void setCreated_at(Timestamp created_at) { this.created_at = created_at; }

    public String getFile_path() { return file_path; }
    public void setFile_path(String file_path) { this.file_path = file_path; }
}