package channel;

public class ChannelVO {
    private int channel_id;
    private String user_id;       // 방을 개설한 교수 아이디
    private String channel_name;  // 방 이름
    private String entry_code;    // 학생 입장 코드

    public int getChannel_id() {
        return channel_id;
    }
    public void setChannel_id(int channel_id) {
        this.channel_id = channel_id;
    }
    
    public String getUser_id() {
        return user_id;
    }
    public void setUser_id(String user_id) {
        this.user_id = user_id;
    }
    
    public String getChannel_name() {
        return channel_name;
    }
    public void setChannel_name(String channel_name) {
        this.channel_name = channel_name;
    }
    
    public String getEntry_code() {
        return entry_code;
    }
    public void setEntry_code(String entry_code) {
        this.entry_code = entry_code;
    }
}