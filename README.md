# 🔥 허태훈의 분노 던전 (Heo Taehoon's Rage Dungeon)

교육을 RPG 게임으로 변환한 혁신적인 학습 관리 플랫폼

---

## 📋 목차

- [프로젝트 소개](#-프로젝트-소개)
- [주요 기능](#-주요-기능)
- [기술 스택](#-기술-스택)
- [시작하기](#-시작하기)
- [프로젝트 구조](#-프로젝트-구조)
- [디자인 시스템](#-디자인-시스템)
- [환경 설정](#-환경-설정)
- [배포](#-배포)

---

## 🎮 프로젝트 소개

**허태훈의 분노 던전**은 전통적인 학습을 RPG 스타일의 게임으로 변환하여 학생들의 참여도를 높이는 교육 플랫폼입니다.

AI 기반 강사 캐릭터 "허태훈"이 학생의 성과에 따라 격려부터 독설까지 다양한 피드백을 제공하며, 던전 탐험, 보스 전투, 경험치 시스템 등 게임 요소를 통해 학습 동기를 부여합니다.

---

## ✨ 주요 기능

### 🎯 핵심 시스템
- **던전 & 퀘스트**: 수업이 던전으로, 문제가 퀘스트로 변환
- **AI 강사 허태훈**: GPT-4 기반 동적 피드백 (분노 대사 자동 생성)
- **경험치 시스템**: 학생과 강사 모두 성장하는 이중 EXP 구조
- **분노 게이지**: 오답률에 따라 변화하는 실시간 감정 상태

### 🎨 게이미피케이션
- **보스 전투**: 각 수업의 최종 퀴즈
- **캐릭터 커스터마이징**: 포인트로 표정/의상 구매
- **레이드 모드**: 팀 협력 대규모 퀴즈
- **멀티버스 학원**: 평행세계 스토리라인
- **멘탈브레이커 모드**: 심리전 기반 학습
- **빌드메이커**: AI 자동 강의 생성

### 📝 학습 관리
- **PDF 워크시트**: OCR 자동 문제 추출 (Tesseract)
- **자동 채점**: 객관식 & 주관식 AI 채점
- **성적 관리**: Excel 내보내기, 그룹별 분석
- **실시간 피드백**: 학생별 맞춤형 AI 코멘트

---

## 🛠 기술 스택

### Frontend
- **Flutter** (Web/Mobile)
- **Dart**

### Backend
- **Spring Boot** 3.2.0
- **Java** 17
- **Maven**

### Database
- **PostgreSQL** 16

### AI Services
- **Python** Flask
- **OpenAI GPT-4**
- **Tesseract OCR**

### DevOps
- **Docker** & Docker Compose
- **Railway** (Production)

---

## 🚀 시작하기

### 필수 요구사항

- Docker Desktop
- Flutter SDK
- Java 17+
- Maven
- Python 3.9+
- OpenAI API Key

### 로컬 개발 환경 설정

#### 1. 저장소 클론
```bash
git clone https://github.com/your-username/lecture-punishment.git
cd lecture-punishment
```

#### 2. 환경변수 설정

`.env` 파일 생성:
```bash
# .env
OPENAI_API_KEY=your-openai-api-key-here
```

#### 3. 로컬 설정 파일 생성
```bash
# Frontend
cp frontend/lib/config/env.dart.example frontend/lib/config/env.dart

# Backend
cp backend/src/main/resources/application.properties.example backend/src/main/resources/application.properties
```

#### 4. 전체 실행

**macOS/Linux:**
```bash
chmod +x start-all.sh
./start-all.sh
```

**Windows:**
```bash
start-all.bat
```

#### 5. 접속

- **프론트엔드**: http://localhost:53362 (Flutter 자동 포트)
- **백엔드 API**: http://localhost:8080
- **AI 서비스**: http://localhost:5000
- **PostgreSQL**: localhost:5432

#### 6. 관리자 로그인
```
ID: hth422
PW: password1234!
```

### 종료

**macOS/Linux:**
```bash
./stop-all.sh
```

**Windows:**
```bash
stop-all.bat
```

---

## 📁 프로젝트 구조
```
lecture-punishment/
├── frontend/              # Flutter Web/Mobile
│   ├── lib/
│   │   ├── screens/      # 화면 컴포넌트
│   │   ├── services/     # API 서비스
│   │   ├── models/       # 데이터 모델
│   │   └── config/       # 환경 설정
│   └── pubspec.yaml
│
├── backend/               # Spring Boot API
│   ├── src/main/java/com/dungeon/heotaehoon/
│   │   ├── controller/   # REST 컨트롤러
│   │   ├── service/      # 비즈니스 로직
│   │   ├── entity/       # JPA 엔티티
│   │   └── repository/   # 데이터 접근
│   └── pom.xml
│
├── ai-service/            # Python AI 서비스
│   ├── app.py            # Flask 서버
│   └── requirements.txt
│
├── .env.example          # 환경변수 템플릿
├── docker-compose.local.yml  # 로컬 DB
├── start-all.sh          # 통합 실행 스크립트
└── README.md
```

---

## 🎨 디자인 시스템

### 컬러 팔레트
- Primary: `#00010D` (다크 블랙)
- Secondary: `#595048` (브라운 그레이)
- Tertiary: `#736A63` (라이트 그레이)
- Background: `#D9D4D2` (베이지)
- Accent: `#0D0D0D` (블랙)

### 폰트
- **조선굴림** (JoseonGulim)
- CDN: `https://cdn.jsdelivr.net/gh/projectnoonnu/noonfonts_20-04@1.0/ChosunGu.woff`

### 디자인 원칙
- 플랫 디자인 (그라데이션은 노노노 ㅋㅋ)
- 미니멀리즘
- 높은 가독성

---

## 🔐 환경 설정

### 로컬 개발
- **Database**: `heotaehoon_local` (Docker)
- **API URL**: `http://localhost:8080`
- **설정 파일**: 
  - `frontend/lib/config/env.dart`
  - `backend/src/main/resources/application.properties`

### 프로덕션 (Railway)
- **환경변수**: Railway 자동 주입
  - `DATABASE_URL`
  - `OPENAI_API_KEY`

---

## 🗃️ 데이터베이스

### 주요 테이블
- `students` - 학생 정보
- `instructors` - 강사 정보
- `lessons` - 수업 정보
- `quizzes` - 퀴즈/문제
- `bosses` - 보스 정보
- `worksheets` - PDF 워크시트
- `exp_logs` - 경험치 로그
- `rage_dialogues` - 분노 대사
- `student_groups` - 그룹 관리

---

## 📦 배포

### Railway 배포

1. **Railway 프로젝트 생성**
2. **PostgreSQL 추가**
3. **환경변수 설정**:
```
   OPENAI_API_KEY=your-key
```
4. **배포**:
```bash
   git push
```

Railway가 자동으로 빌드 및 배포합니다.

---

## 🤝 기여하기

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📝 라이선스

This project is licensed under the MIT License.

---

## 👥 제작

**이다겸**

---

## 🙏 감사의 말

- OpenAI GPT-4 for AI features
- Tesseract OCR for PDF processing
- Flutter & Spring Boot communities
- Railway for hosting
- 영감의 원천 **허태훈**강사님

---

## 📧 문의

프로젝트 관련 문의사항이 있으시면 https://oicrcutie.up.railway.app/ 여기로 방문해주세요❤️

---

**Made with 🔥 by 이다겸**
