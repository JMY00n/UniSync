-- 1. 외래키 체크를 일시적으로 해제 (테이블 삭제 순서 상관없이 에러 안 나게 방지)
SET FOREIGN_KEY_CHECKS = 0;

-- 2. 기존에 존재하는 테이블들을 안전하게 삭제
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

-- 4. 서브보드 테이블 (Subboard)
CREATE TABLE subboard (
    channel_id INT NOT NULL,
    board_name VARCHAR(50) NOT NULL, -- '자유게시판', '강의자료', '공지사항'
    PRIMARY KEY (channel_id, board_name), -- 두 컬럼을 묶어서 PK로!
    FOREIGN KEY (channel_id) REFERENCES channel(channel_id) ON DELETE CASCADE
);

-- [수정됨] INSERT 문은 자바(ChannelDAO)에서 방이 생성될 때 자동으로 들어가도록 처리해야 외래키 에러가 안 납니다.
-- 테스트용으로 미리 넣고 싶다면, 반드시 channel 테이블에 먼저 1번 방을 만든 후 아래 코드를 실행해야 합니다.
-- INSERT INTO subboard (channel_id, board_name) VALUES (1, '자유게시판');
-- INSERT INTO subboard (channel_id, board_name) VALUES (1, '강의자료');
-- INSERT INTO subboard (channel_id, board_name) VALUES (1, '공지사항');

-- 5. 게시글 테이블 (Messages)
CREATE TABLE message (
    message_id INT AUTO_INCREMENT PRIMARY KEY,
    channel_id INT NOT NULL,
    board_name VARCHAR(50) NOT NULL,
    user_id VARCHAR(20) NOT NULL, -- 작성자 아이디
    title VARCHAR(100) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, -- 시간 자동 입력
    file_path VARCHAR(200), -- 파일 첨부 기능용
    
    -- 외래키 설정: subboard의 복합키(channel_id, board_name)를 묶어서 정확히 참조
    FOREIGN KEY (channel_id, board_name) 
        REFERENCES subboard(channel_id, board_name) 
        ON DELETE CASCADE,
        
    FOREIGN KEY (user_id) 
        REFERENCES member(user_id) 
        ON DELETE CASCADE
);

-- 6. 댓글 테이블 (Comments)
CREATE TABLE comment (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    message_id INT NOT NULL,
    user_id VARCHAR(20) NOT NULL,
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP, 
    FOREIGN KEY (message_id) REFERENCES message(message_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES member(user_id) ON DELETE CASCADE
);


ALTER TABLE message ADD is_pinned INT NOT NULL DEFAULT 0;
-- 0이면 일반 채팅글, 1이면 상단 고정글!
-- ════════════════ [ 확인용 조회 쿼리 ] ════════════════
SELECT * FROM channel;
SELECT * FROM channel_list;
SELECT * FROM member;
SELECT * FROM subboard;