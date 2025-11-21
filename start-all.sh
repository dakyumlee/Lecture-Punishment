#!/bin/bash

echo "===================================="
echo "허태훈의 분노 던전 (로컬 실행)"
echo "===================================="
echo ""

if [ ! -f .env ]; then
    echo "❌ .env 파일이 없습니다!"
    exit 1
fi

export $(cat .env | grep -v '^#' | xargs)

echo "1️⃣  PostgreSQL 도커 시작 (로컬용)..."
docker-compose -f docker-compose.local.yml up -d
echo "⏳ DB 준비 대기 중..."
sleep 5
echo "✅ PostgreSQL 도커 실행 완료"

echo ""
echo "2️⃣  AI 서비스 시작..."
osascript -e 'tell application "Terminal" to do script "cd \"'$(pwd)'/ai-service\" && python3 app.py"'
sleep 3

echo ""
echo "3️⃣  백엔드 시작..."
osascript -e 'tell application "Terminal" to do script "cd \"'$(pwd)'/backend\" && export DATABASE_URL=\"jdbc:postgresql://localhost:5432/heotaehoon_dungeon\" && export DB_USER=postgres && export DB_PASSWORD=postgres && export OPENAI_API_KEY='$OPENAI_API_KEY' && export AI_SERVICE_URL=http://localhost:5000 && mvn spring-boot:run"'
sleep 10

echo ""
echo "4️⃣  프론트엔드 시작..."
osascript -e 'tell application "Terminal" to do script "cd \"'$(pwd)'/frontend\" && flutter run -d chrome"'

echo ""
echo "===================================="
echo "✅ 실행 완료!"
echo "===================================="
echo "📍 백엔드: http://localhost:8080"
echo "📍 DB (도커): localhost:5432"
echo ""
echo "💡 종료: ./stop-all.sh"
echo ""
