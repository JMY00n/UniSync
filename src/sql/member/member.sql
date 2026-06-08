-- 1. 사용자 테이블 (Users)
CREATE TABLE users (
    user_id VARCHAR(50) PRIMARY KEY,
    password VARCHAR(50) NOT NULL,
    name VARCHAR(30) NOT NULL,
    role VARCHAR(20) NOT NULL -- 'professor' 또는 'student'
);

-- 2. 채널(방) 테이블 (Channels)
CREATE TABLE channels (
    channel_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(50) NOT NULL, -- 방을 개설한 교수 아이디
    channel_name VARCHAR(100) NOT NULL,
    entry_code VARCHAR(20) NOT NULL UNIQUE, -- 학생들이 입력할 입장 코드
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 3. 채널 참여목록 테이블 (Channel Participants)
-- 다대다(N:M) 관계를 해소하는 매핑 테이블
CREATE TABLE channel_participants (
    channel_id INT NOT NULL,
    user_id VARCHAR(50) NOT NULL, -- 참여한 학생(또는 교수) 아이디
    PRIMARY KEY (channel_id, user_id),
    FOREIGN KEY (channel_id) REFERENCES channels(channel_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 4. 서브보드 테이블 (Sub-boards : 공지사항, 수업자료, Q&A 등)
CREATE TABLE sub_boards (
    board_id INT AUTO_INCREMENT PRIMARY KEY,
    board_name VARCHAR(50) NOT NULL,
    channel_id INT NOT NULL,
    FOREIGN KEY (channel_id) REFERENCES channels(channel_id) ON DELETE CASCADE
);

-- 5. 게시글 테이블 (Messages)
CREATE TABLE messages (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    board_id INT NOT NULL,
    user_id VARCHAR(50) NOT NULL, -- 작성자 아이디
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME NOT NULL,
    file_path VARCHAR(200), -- 파일 첨부 기능용
    FOREIGN KEY (board_id) REFERENCES sub_boards(board_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 6. 댓글 테이블 (Comments : Q&A나 게시물 답변용)
CREATE TABLE comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    message_id INT NOT NULL,
    user_id VARCHAR(50) NOT NULL,
    content TEXT NOT NULL,
    created_at DATETIME NOT NULL,
    FOREIGN KEY (message_id) REFERENCES messages(message_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);