# UniSync

> "질문의 장벽을 낮추고, 수업의 데이터를 높이다."

강의실 단위로 공지사항 · 강의자료 · Q&A를 관리할 수 있는 **JSP 기반 학습관리 플랫폼**입니다.
학생/교수 역할에 따라 권한이 분리되며, 8자리 입장 코드로 원하는 강의실에 자유롭게 참여할 수 있습니다.

## 목차

- [프로젝트 개요](#프로젝트-개요)
- [기술 스택](#기술-스택)
- [담당 역할](#담당-역할)
- [주요 기능](#주요-기능)
- [발표 자료](#발표-자료)

---

## 프로젝트 개요

JSP 기말과제로 진행한 팀 프로젝트입니다.
수업마다 흩어져 있는 공지, 자료, 질문을 하나의 강의실(채널) 단위로 모아 관리할 수 있도록 설계했습니다.

- 학생은 **입장 코드**로 원하는 강의실에 참여
- 교수는 강의실을 개설하고 공지·자료·Q&A를 관리
- 역할(학생/교수)에 따라 접근 가능한 기능이 자동으로 분리됨

---

## 기술 스택

- **Backend** : JSP, Servlet (DAO/VO 패턴)
- **Database** : MySQL
- **Frontend** : HTML, CSS, JavaScript
- **협업 도구** : Git, Visual Paradigm(ERD/유스케이스 설계)

---

## 담당 역할 (정민)

- 프로젝트 팀장 — 전체 아키텍처 설계 및 팀원 개발환경 통일
- DB 설계(ERD) 및 컨벤션 수립
- 로그인 · 회원가입, 세션 기반 인증 흐름 구현
- 강의실 생성 로직 (8자리 랜덤 코드 발급)
- Git 형상관리 (커밋 스냅샷 기반 백업/복구)

---

## 주요 기능

### 1. 로그인 · 회원가입

- 학번/교번과 비밀번호로 로그인
- 가입 시 `role` 파라미터(0: 학생, 1: 교수)로 구분하여 처리
- 역할에 따라 로그인 이후 접근 가능한 기능이 자동으로 분기됨
  - **학생** : 강의실 입장, 자료 조회, Q&A 작성
  - **교수** : 강의실 개설, 자료 등록, 공지사항 작성, Q&A 고정

<img width="700" alt="로그인 화면" src="https://github.com/user-attachments/assets/4a7b9242-787c-463e-827a-e633d397f69b" /><br/>
<sub>로그인 화면</sub>

<img width="700" alt="학생 회원가입" src="https://github.com/user-attachments/assets/6f3c1c0c-e700-4655-8b2e-de82c2471189" /><br/>
<sub>회원가입 — role 파라미터로 학생/교수 구분</sub>

### 2. 강의실 입장 (코드 기반)

- 교수가 강의실을 개설하면 8자리 입장 코드가 자동 발급됨
- 학생은 대시보드 상단 검색창에 코드를 입력해 원하는 강의실에 즉시 참여

<img width="700" alt="코드로 강의실 참여" src="https://github.com/user-attachments/assets/802f5e76-447d-401f-864f-930834eb4dbd" /><br/>
<sub>발급받은 8자리 코드로 강의실 입장</sub>

### 3. 대시보드 (역할별 화면 분리)

<table>
  <tr>
    <td align="center">
      <img width="480" alt="학생 대시보드" src="https://github.com/user-attachments/assets/c3c5b00d-e8d9-491e-a33c-5c75280f168e" /><br/>
      <sub><b>학생</b> — 내가 입장한 강의실 목록</sub>
    </td>
    <td align="center">
      <img width="480" alt="교수 대시보드" src="https://github.com/user-attachments/assets/6602a5af-a23f-4cf8-9753-98ebc566dc38" /><br/>
      <sub><b>교수</b> — 내가 개설한 강의실 목록 및 관리</sub>
    </td>
  </tr>
</table>

- 학생 : 입장한 강의실 수, 최근 활동 피드 확인
- 교수 : 개설 강의실 수, 총 수강생, 강의실 수정/삭제

<img width="500" alt="새 강의실 개설" src="https://github.com/user-attachments/assets/4fb54782-302c-43cf-b842-81a511dc596c" /><br/>
<sub>교수 — 강의실 이름만 입력하면 코드/게시판이 자동 생성됨</sub>

### 4. 강의자료

- 교수가 자료(제목, 설명, 첨부파일)를 등록하면 학생이 목록에서 조회 및 다운로드

<img width="700" alt="강의자료 목록" src="https://github.com/user-attachments/assets/bdbf49a7-88ed-4ac8-9165-4bdf7d652686" /><br/>
<sub>강의자료 목록 및 다운로드</sub>

<img width="500" alt="강의자료 등록" src="https://github.com/user-attachments/assets/17e157b3-dc6c-4e3b-afce-38c96af03a14" /><br/>
<sub>교수 — 강의자료 등록 (제목, 설명, 첨부파일)</sub>

### 5. Q&A

- 학생이 질문을 남기면 교수가 답변 및 상단 고정 가능
- 고정된 질문은 목록 최상단에 표시되어 반복 질문을 줄임

<img width="700" alt="Q&A 화면" src="https://github.com/user-attachments/assets/f05258c6-eb79-415f-b7df-b4f078a1277f" /><br/>
<sub>Q&A — 교수 답변 및 상단 고정 기능</sub>

### 6. 공지사항

<img width="700" alt="공지사항" src="https://github.com/user-attachments/assets/adb011f9-ed66-473c-a3c3-23eec409ee90" /><br/>
<sub>공지사항 목록</sub>

---

## 발표 자료

📎 [Google Slides 발표자료 바로가기](구글슬라이드_뷰전용_링크)
