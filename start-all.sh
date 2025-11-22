#!/bin/bash

echo "===================================="
echo "허태훈의 분노 던전 (로컬)"
echo "===================================="
echo ""
echo "📦 로컬 DB 정보:"
echo "   컨테이너: heotaehoon-local"
echo "   Database: heotaehoon_local"
echo "   Username: postgres"
echo "   Password: postgres123"
echo "   Host: localhost:5432"
echo ""
echo "💡 DB 접속: docker exec -it heotaehoon-local psql -U postgres -d heotaehoon_local"
echo ""

if [ ! -f .env ]; then
    echo "❌ .env 파일이 없습니다!"
    exit 1
fi

export $(cat .env | grep -v '^#' | grep OPENAI_API_KEY | xargs)

echo "1️⃣  PostgreSQL 도커 확인..."
if ! docker ps | grep heotaehoon-local > /dev/null; then
    echo "📦 DB 컨테이너 시작 중..."
    docker start heotaehoon-local 2>/dev/null || docker run -d \
      --name heotaehoon-local \
      -e POSTGRES_DB=heotaehoon_local \
      -e POSTGRES_USER=postgres \
      -e POSTGRES_PASSWORD=postgres123 \
      -p 5432:5432 \
      postgres:16
    sleep 5
fi
echo "✅ PostgreSQL 실행 중"

echo ""
echo "2️⃣  AI 서비스 시작..."
osascript -e 'tell application "Terminal" to do script "cd \"'$(pwd)'/ai-service\" && python3 app.py"'
sleep 3

echo ""
echo "3️⃣  백엔드 시작..."
osascript -e 'tell application "Terminal" to do script "cd \"'$(pwd)'/backend\" && export OPENAI_API_KEY='$OPENAI_API_KEY' && mvn spring-boot:run"'
sleep 10

echo ""
echo "4️⃣  프론트엔드 시작..."
osascript -e 'tell application "Terminal" to do script "cd \"'$(pwd)'/frontend\" && flutter run -d chrome"'

echo ""
echo "===================================="
echo "✅ 실행 완료!"
echo "===================================="
echo "📍 백엔드: http://localhost:8080"
echo "📍 DB: localhost:5432/heotaehoon_local"
echo ""
echo "🔐 관리자 계정:"
echo "   ID: hth422"
echo "   PW: password1234!"
echo ""
echo "🛑 종료: docker stop heotaehoon-local"
echo ""
