#!/bin/bash

echo "🐳 Docker Compose로 허태훈의 분노 던전 시작..."
echo ""

# Docker Compose 시작
docker-compose up -d

echo ""
echo "✅ 서비스 시작 완료!"
echo ""
echo "📊 상태 확인:"
docker-compose ps
echo ""
echo "🌐 접속 주소:"
echo "  - 백엔드: http://localhost:8080"
echo "  - 데이터베이스: localhost:5432"
echo ""
echo "📝 로그 확인:"
echo "  docker-compose logs -f backend"
echo ""
echo "🛑 종료:"
echo "  docker-compose down"
echo ""
