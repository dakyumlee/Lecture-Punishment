# 🚀 빠른 시작 가이드

## ⚡ 5분 안에 실행하기

### 1. 환경 설정 (30초)

```bash
# .env 파일 수정
OPENAI_API_KEY=your_key_here
```

### 2. 전체 실행 (3분)

```bash
# 실행 권한
chmod +x start.sh

# 시작!
./start.sh
```

### 3. Flutter 앱 실행 (1분)

```bash
cd frontend
flutter pub get
flutter run -d chrome
```

### 4. 접속

- 앱: http://localhost:8080 (Flutter 포트)
- API: http://localhost:8080/api
- DB: localhost:5432

---

## 🎮 첫 사용법

### 학생 입장

1. **회원가입/로그인**
   - 아이디: test1
   - 이름: 김철수

2. **문제지 풀기**
   - 홈 → 문제지 선택
   - 답안 입력 → 제출
   - 결과 확인

3. **상점 이용**
   - 포인트로 표정/옷 구매
   - 캐릭터 커스터마이징

### 관리자 입장

1. **로그인**
   - ID: hth422
   - PW: password1234!

2. **문제지 등록**
```bash
POST /api/worksheets
{
  "title": "자바 기초",
  "subject": "프로그래밍",
  "category": "프로그래밍",
  "difficultyLevel": 3
}
```

3. **문제 추가**
```bash
POST /api/worksheets/{id}/questions
{
  "questionNumber": 1,
  "questionType": "multiple_choice",
  "questionText": "자바의 특징은?",
  "correctAnswer": "A",
  "optionA": "객체지향",
  "optionB": "절차지향",
  "optionC": "함수형",
  "optionD": "논리형",
  "points": 10
}
```

---

## 🧪 API 테스트

### 문제지 제출 테스트

```bash
curl -X POST http://localhost:8080/api/worksheets/{worksheetId}/submit \
  -H "Content-Type: application/json" \
  -d '{
    "studentId": "student-uuid",
    "answers": [
      {
        "questionId": "question-uuid-1",
        "answer": "A"
      },
      {
        "questionId": "question-uuid-2",
        "answer": "객체지향 프로그래밍"
      }
    ]
  }'
```

### 응답 예시

```json
{
  "submissionId": "submission-uuid",
  "totalScore": 18,
  "maxScore": 20,
  "percentage": 90.00,
  "correctCount": 2,
  "wrongCount": 0,
  "expGained": 20,
  "pointsGained": 10,
  "leveledUp": false,
  "newLevel": 3,
  "encouragement": "오 제대로 외웠네"
}
```

---

## 🔥 주요 기능 사용법

### 1. 주관식 채점

- **유사도 기반**: Levenshtein Distance 알고리즘
- **임계값**: 0.85 (기본값)
- **부분 점수**: 0.70 이상 시 가능

예시:
- 정답: "객체지향 프로그래밍"
- 학생: "객체지향프로그래밍" → ✅ 정답 (100%)
- 학생: "객체지향" → ⚠️ 부분 점수 (70%)
- 학생: "절차지향" → ❌ 오답

### 2. 카테고리 관리

```bash
# 카테고리 조회
GET /api/worksheets/categories

# 카테고리별 문제지
GET /api/worksheets/category/프로그래밍
```

### 3. 상점 시스템

```bash
# 상점 아이템 조회
GET /api/shop/items

# 아이템 구매
POST /api/shop/buy
{
  "studentId": "uuid",
  "itemId": "item-uuid"
}
```

---

## 🐛 문제 해결

### PostgreSQL 연결 실패

```bash
# DB 재시작
docker-compose restart postgres
docker-compose logs postgres
```

### Backend 빌드 실패

```bash
cd backend
./mvnw clean install
docker-compose up -d --build backend
```

### Flutter 실행 오류

```bash
flutter clean
flutter pub get
flutter run -d chrome
```

---

## 📊 데이터베이스 초기화

```bash
# DB 초기화 (주의: 모든 데이터 삭제!)
docker-compose down -v
docker-compose up -d postgres
```

---

## 🎯 다음 단계

1. **멀티버스 구현** - 다양한 허태훈 변형
2. **레이드 모드** - 클래스 협동 플레이
3. **아빠 허태훈** - 최종 진화 스토리
4. **TTS 음성** - 실제 음성 구현
5. **모바일 앱** - Flutter 모바일 빌드

---

## 💡 팁

- 포인트는 정답 개수 × 5
- EXP는 정답 개수 × 10
- 레벨업 필요 EXP = 현재 레벨 × 100
- 멘탈 게이지는 오답 시 -5

---

더 자세한 내용은 [README.md](./README.md)를 참고하세요!
