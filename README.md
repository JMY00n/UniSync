---

## 개발 환경 표준 (Development Environment)
* **Java Version:** Java 17
* **Web Server:** Apache Tomcat v9.0
* **Dynamic Web Module Version:** 4.0
* **DBMS:** MySQL 8.0.x
* **Database Driver:** `mysql-connector-java` (프로젝트 내 `WEB-INF/lib`에 포함됨)

---

## 초기 로컬 세팅 가이드 (Setup Instructions)

### 1. 프로젝트 Import 및 서버 연결
1. 이클립스에서 `File` > `Import` > `Existing Projects into Workspace`를 통해 본 프로젝트를 불러옵니다.
2. 프로젝트 우클릭 > `Properties` > `Targeted Runtimes`에서 본인의 **Tomcat v9.0** 서버 체크박스를 체크하고 적용합니다.

### 2. 로컬 데이터베이스(MySQL) 설정
팀원 간의 DBCP 설정을 공유하기 위해 아래와 같이 MySQL 스키마와 계정을 통일해야 합니다. 본인의 MySQL CLI 또는 워크벤치에서 아래 쿼리를 실행해 주세요.

```sql
-- 1. 데이터베이스(스키마) 생성
CREATE DATABASE app;

-- 아래의 내용은 수업 시간에 한 내용이라 jpsid, jpspass로 아이디가 있으면 굳이 안 하셔도 됩니다.
-- 2. 팀 공용 사용자 계정 생성 (비밀번호: jsppass)
CREATE USER 'jspid'@'%' IDENTIFIED BY 'jsppass';

-- 3. 생성한 스키마에 대한 모든 권한 부여
GRANT ALL PRIVILEGES ON basicjsp.* TO 'jspid'@'%';
FLUSH PRIVILEGES;
```


