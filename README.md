## 개발 환경 표준 (Development Environment)
* **Java Version:** Java 17
* **Web Server:** Apache Tomcat v9.0
* **Dynamic Web Module Version:** 4.0
* **DBMS:** MySQL 8.0.x
* **Database Driver:** `mysql-connector-java` (프로젝트 내 `WEB-INF/lib`에 포함됨)

<hr />

## 초기 로컬 세팅 가이드 (Setup Instructions)

### 1. 프로젝트 Import 및 서버 연결
1. 이클립스에서 `File` > `Import` > `Existing Projects into Workspace`를 통해 본 프로젝트를 불러옵니다.
2. 프로젝트 우클릭 > `Properties` > `Targeted Runtimes`에서 본인의 **Tomcat v9.0** 서버 체크박스를 체크하고 적용합니다.

### 2. 로컬 데이터베이스(MySQL) 설정
 팀원 간 DB연동 편리성을 위해 아이디와 패스워드는 수업시간에 한 jspid, jpspass로 통일하여 이용하겠습니다.
 백엔드 프로그래밍 수업에서 사용 한 PC이면 아래에 2번과 3번은 하지 않으셔도 되고 app으로 스키마 생성만 해주세요.

```sql
-- 1. 데이터베이스(스키마) 생성
CREATE DATABASE app;

-- 2. 팀 공용 사용자 계정 생성 (비밀번호: jsppass)
CREATE USER 'jspid'@'%' IDENTIFIED BY 'jsppass';

-- 3. 생성한 스키마에 대한 모든 권한 부여
GRANT ALL PRIVILEGES ON *.* TO 'jspid'@'%';
FLUSH PRIVILEGES;
```


