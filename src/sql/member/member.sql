DROP TABLE member;
DROP TABLE channels;
DROP TABLE channel_participants;
DROP TABLE sub_boards;
DROP TABLE messages;
DROP TABLE comments;

-- 1. 사용자 테이블 (Member)
CREATE TABLE member (
    user_id VARCHAR(20) PRIMARY KEY,
    password VARCHAR(50) NOT NULL,
    name VARCHAR(30) NOT NULL,
    role INT NOT NULL -- 'professor' 또는 'student'
);


-- 2. 채널(방) 테이블 (Channel)
CREATE TABLE channel (
    channel_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(20) NOT NULL, -- 방을 개설한 교수 아이디
    channel_name VARCHAR(100) NOT NULL,
    entry_code VARCHAR(50) NOT NULL UNIQUE, -- 학생들이 입력할 입장 코드
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE
);

-- 3. 채널 참여목록 테이블 (channel_list)
-- 다대다(N:M) 관계를 해소하는 매핑 테이블
CREATE TABLE channel_list (
    channel_id INT NOT NULL,
    user_id VARCHAR(20) NOT NULL, -- 참여한 학생(또는 교수) 아이디
    PRIMARY KEY (channel_id, user_id),
    FOREIGN KEY (channel_id) REFERENCES channel(channel_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE
);

-- 4. 서브보드 테이블 (Sub-boards : 공지사항, 수업자료, Q&A 등)
CREATE TABLE subboard (
    board_id INT AUTO_INCREMENT PRIMARY KEY,
    board_name VARCHAR(50) NOT NULL,
    channel_id INT NOT NULL,
    FOREIGN KEY (channel_id) REFERENCES channel(channel_id) ON DELETE CASCADE
);

-- 5. 게시글 테이블 (Messages)
CREATE TABLE message (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    board_id INT NOT NULL,
    user_id VARCHAR(20) NOT NULL, -- 작성자 아이디
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    file_path VARCHAR(200), -- 파일 첨부 기능용
    FOREIGN KEY (board_id) REFERENCES subboard(board_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE
);

-- 6. 댓글 테이블 (Comments : Q&A나 게시물 답변용)
CREATE TABLE comment (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    message_id INT NOT NULL,
    user_id VARCHAR(20) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL,
    FOREIGN KEY (message_id) REFERENCES message(message_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE
);

SELECT *
FROM member;