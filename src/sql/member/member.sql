-- 1. 외래키 체크를 일시적으로 해제 (테이블 삭제 순서 상관없이 에러 안 나게 방지)
SET FOREIGN_KEY_CHECKS = 0;

-- 2. 기존에 존재하는 테이블들을 안전하게 삭제 (생성할 이름과 정확히 매칭)
DROP TABLE IF EXISTS comment;
DROP TABLE IF EXISTS message;
DROP TABLE IF EXISTS subboard;
DROP TABLE IF EXISTS channel_list;
DROP TABLE IF EXISTS channel;
DROP TABLE IF EXISTS member;

-- 3. 외래키 체크 다시 활성화
SET FOREIGN_KEY_CHECKS = 1;

-- ════════════════ [ 테이블 생성 시작 ] ════════════════

-- 1. 사용자 테이블 (Member)
CREATE TABLE member (
    user_id VARCHAR(20) PRIMARY KEY,
    password VARCHAR(50) NOT NULL,
    name VARCHAR(30) NOT NULL,
    role INT NOT NULL -- '0: student', '1: professor'
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
CREATE TABLE channel_list (
    channel_id INT NOT NULL,
    user_id VARCHAR(20) NOT NULL, -- 참여한 학생/교수 아이디
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
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- 시간 자동 입력 보완
    file_path VARCHAR(200), -- 파일 첨부 기능용
    FOREIGN KEY (board_id) REFERENCES subboard(board_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE
);

-- 6. 댓글 테이블 (Comments)
CREATE TABLE comment (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    message_id INT NOT NULL,
    user_id VARCHAR(20) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- 시간 자동 입력 보완
    FOREIGN KEY (message_id) REFERENCES message(message_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE
);

-- 1. 공지사항 테이블 생성
CREATE TABLE notice (
    notice_id INT AUTO_INCREMENT PRIMARY KEY,  -- 공지사항 고유 번호
    channel_id INT NOT NULL,                   -- 어떤 강의실의 공지사항인지 구별
    user_id VARCHAR(50) NOT NULL,              -- 작성자 아이디 (교수)
    title VARCHAR(255) NOT NULL,               -- 공지사항 제목
    content TEXT NOT NULL,                     -- 공지사항 내용
    filename VARCHAR(255),                     -- 첨부파일 이름 (없으면 NULL)
    reg_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 작성 날짜 (자동 입력)
    FOREIGN KEY (channel_id) REFERENCES channel(channel_id) ON DELETE CASCADE
);

-- 2. 공지사항 댓글 테이블 생성
CREATE TABLE notice_reply (
    reply_id INT AUTO_INCREMENT PRIMARY KEY,   -- 댓글 고유 번호
    notice_id INT NOT NULL,                    -- 어떤 공지사항의 댓글인지 구별
    user_id VARCHAR(50) NOT NULL,              -- 댓글 작성자 아이디
    reply_content TEXT NOT NULL,               -- 댓글 내용
    reg_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- 댓글 작성 날짜
    FOREIGN KEY (notice_id) REFERENCES notice(notice_id) ON DELETE CASCADE
);



SELECT * FROM channel;
SELECT * FROM channel_list;
SELECT * FROM member;