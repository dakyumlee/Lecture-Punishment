# 🔥 허태훈의 분노 던전 (Lecture & Punishment)

학생들이 퀴즈를 풀면서 허태훈 강사의 분노를 피해 레벨업하는 게임형 학습 플랫폼

## 📋 주요 기능

### ✅ 구현 완료

#### 1. 기본 게임 시스템
- 🎮 학생 로그인/회원가입
- 🏰 던전 입장 → 보스 조우
- 📝 객관식 4지선다 퀴즈
- ⚡ EXP/레벨업 시스템
- 💬 AI 분노 대사 생성 (GPT-4)
- 🎯 실시간 채점

#### 2. PDF 문제지 시스템 ⭐ 신규!
- 📄 PDF 문제지 등록
- ✏️ 주관식 + 객관식 문제 지원
- 🤖 Levenshtein Distance 유사도 채점
- 📊 카테고리별 문제지 관리
- 📈 제출 이력 및 통계

#### 3. 관리자 기능
- 👨‍🏫 수업 등록/삭제
- 📊 통계 대시보드
- 👥 학생 관리
- 📝 문제지 관리

#### 4. 랭킹 시스템
- 🏆 학생별 점수/정답률
- 📈 클래스 랭킹

### 🚧 구현 예정

- 🎨 캐릭터 커스터마이징 (표정, 옷)
- 🛒 상점 시스템 (포인트로 아이템 구매)
- 🌌 멀티버스 (냉혈/자비/사이보그 허태훈)
- ⚔️ 레이드 모드 (클래스 협동)
- 🧘 멘탈 회복 미션
- 👨‍👦 아빠 허태훈 진화

## 🏗️ 기술 스택

### Backend
- Java 17
- Spring Boot 3.x
- PostgreSQL 15
- JPA/Hibernate
- Lombok

### Frontend
- Flutter Web
- Provider (상태관리)
- HTTP (API 통신)

### AI Service
- Python 3.11
- Flask
- OpenAI GPT-4
- OpenAI TTS

### Infrastructure
- Docker & Docker Compose
- Nginx (향후)

## 📂 프로젝트 구조

```
lecture-punishment/
├── backend/                    # Spring Boot API
│   ├── src/main/java/com/dungeon/heotaehoon/
│   │   ├── controller/        # REST API Controllers
│   │   ├── entity/            # JPA Entities
│   │   ├── repository/        # Data Repositories
│   │   ├── service/           # Business Logic
│   │   └── dto/               # Data Transfer Objects
│   └── pom.xml
│
├── frontend/                   # Flutter Web
│   ├── lib/
│   │   ├── screens/           # UI Screens
│   │   ├── models/            # Data Models
│   │   ├── providers/         # State Management
│   │   ├── services/          # API Services
│   │   ├── widgets/           # Reusable Widgets
│   │   └── theme/             # UI Theme
│   └── pubspec.yaml
│
├── ai-service/                 # Python AI Service
│   ├── rage_generator.py      # GPT-4 분노 대사 생성
│   ├── requirements.txt
│   └── Dockerfile
│
├── database/                   # Database Scripts
│   ├── schema.sql             # DB Schema
│   └── seed.sql               # Initial Data
│
├── docker-compose.yml
├── start.sh
└── .env
```

## 🚀 실행 방법

### 1. 환경 설정

```bash
# .env 파일 설정
OPENAI_API_KEY=your_openai_api_key_here
```

### 2. Docker로 전체 실행

```bash
# 실행 스크립트 권한 부여
chmod +x start.sh

# 전체 서비스 시작
./start.sh
```

또는 수동으로:

```bash
# 1. PostgreSQL 시작
docker-compose up -d postgres
sleep 5

# 2. Backend 시작
docker-compose up -d backend
sleep 10

# 3. AI Service 시작
docker-compose up -d ai-service
```

### 3. Flutter 앱 실행

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

## 🌐 서비스 엔드포인트

- Backend API: http://localhost:8080
- AI Service: http://localhost:5000
- PostgreSQL: localhost:5432

## 📚 API 문서

### 게임 API

```
GET    /api/students/username/{username}       # 학생 조회
POST   /api/students                           # 학생 생성
GET    /api/lessons/today                      # 오늘의 수업
POST   /api/quiz/generate/{lessonId}           # 퀴즈 생성
POST   /api/quiz/submit                        # 답안 제출
```

### 문제지 API ⭐ 신규!

```
POST   /api/worksheets                         # 문제지 생성
POST   /api/worksheets/{id}/questions          # 문제 추가
GET    /api/worksheets                         # 전체 문제지 조회
GET    /api/worksheets/category/{category}     # 카테고리별 조회
GET    /api/worksheets/{id}                    # 문제지 상세 + 문제 목록
POST   /api/worksheets/{id}/submit             # 답안 제출 및 채점
GET    /api/worksheets/student/{id}/submissions # 학생 제출 이력
GET    /api/worksheets/categories              # 카테고리 목록
```

### 관리자 API

```
POST   /api/admin/login                        # 관리자 로그인
POST   /api/admin/lessons                      # 수업 생성
GET    /api/admin/lessons                      # 수업 목록
DELETE /api/admin/lessons/{id}                 # 수업 삭제
GET    /api/admin/students                     # 학생 목록
GET    /api/admin/stats                        # 통계
```

## 🗄️ 데이터베이스 스키마

### 핵심 테이블

- `students` - 학생 정보
- `instructors` - 강사 정보
- `lessons` - 수업
- `bosses` - 보스
- `quizzes` - 퀴즈 (기존 4지선다)

### PDF 문제지 테이블 ⭐ 신규!

- `pdf_worksheets` - 문제지
- `worksheet_questions` - 문제 (주관식+객관식)
- `student_submissions` - 제출 이력
- `submission_answers` - 제출 답안
- `worksheet_categories` - 카테고리

## 🎨 디자인 시스템

### 컬러 팔레트

```
#00010D - 메인 다크
#595048 - 서브 다크
#736A63 - 그레이
#D9D4D2 - 라이트
#0D0D0D - 블랙
```

### 폰트

- 조선굴림체 (ChosunGu)

## 🤖 AI 기능

### 분노 대사 생성

- `wrong_answer`: 오답 시 독설
- `correct_answer`: 정답 시 무뚝뚝한 인정
- `mental_break`: 멘탈 붕괴 대사
- `combo_3`: 3연속 정답 시 칭찬

### TTS (향후)

- 허태훈 톤으로 대사 음성 변환

## 📊 채점 알고리즘

### 객관식
- 정확 일치 여부만 체크

### 주관식
- **Levenshtein Distance** 알고리즘 사용
- 문자열 정규화 (공백 제거, 소문자 변환)
- 유사도 임계값 (default: 0.85)
- 부분 점수 지원 (유사도 0.70 이상)

## 🧪 테스트

```bash
# Backend 테스트
cd backend
./mvnw test

# Frontend 테스트
cd frontend
flutter test
```

## 📝 개발 로그

### v2.0.0 (2025-11-12) ⭐ 신규
- PDF 문제지 시스템 구현
- 주관식 답안 채점 알고리즘 (Levenshtein)
- 카테고리 기반 문제지 관리
- 제출 이력 및 통계

### v1.0.0 (2025-11-11)
- 기본 게임 플로우
- 던전/보스 시스템
- AI 분노 대사 생성
- 관리자 대시보드

## 🤝 기여자

- [@dakyumlee] - 프로젝트 총괄
- 허태훈 강사 - 영감의 원천 😈

## 📄 라이선스

이 프로젝트는 MIT 라이선스를 따릅니다.

## 🔗 관련 링크

- [OpenAI API](https://platform.openai.com/)
- [Flutter Documentation](https://flutter.dev/)
- [Spring Boot](https://spring.io/projects/spring-boot)
