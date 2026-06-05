CREATE TABLE member (
	id VARCHAR(20) PRIMARY KEY,
	password VARCHAR(50) NOT NULL,
	name VARCHAR(7) NOT NULL,
	role INT NOT NULL
);

ALTER TABLE member RENAME COLUMN id TO user_id;

INSERT INTO member VALUES ('testid', 'testpwd', 'tester', '0');
INSERT INTO member VALUES ('adminid', 'adminpwd', 'admin', '1');

-- 학생만 조회
SELECT *
FROM member
WHERE role=0;