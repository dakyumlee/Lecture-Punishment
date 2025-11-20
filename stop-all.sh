#!/bin/bash

echo "===================================="
echo "모든 서비스 종료"
echo "===================================="
echo ""

echo "Spring Boot 프로세스 종료 중..."
pkill -f "spring-boot:run" 2>/dev/null
pkill -f "heotaehoon-dungeon" 2>/dev/null
echo "✅ 백엔드 종료됨"

echo ""
echo "AI 서비스 (Python) 종료 중..."
pkill -f "app.py" 2>/dev/null
pkill -f "ai-service" 2>/dev/null
echo "✅ AI 서비스 종료됨"

echo ""
echo "Flutter 프로세스 종료 중..."
pkill -f "flutter" 2>/dev/null
pkill -f "chrome" 2>/dev/null
echo "✅ 프론트엔드 종료됨"

echo ""
echo "PostgreSQL 서비스는 계속 실행됩니다."
echo "💡 PostgreSQL을 완전히 종료하려면:"

OS_TYPE=$(uname -s)

if [[ "$OS_TYPE" == "Darwin" ]]; then
    echo "   brew services stop postgresql"
elif [[ "$OS_TYPE" == "Linux" ]]; then
    echo "   sudo systemctl stop postgresql"
    echo "   또는"
    echo "   sudo service postgresql stop"
fi

echo ""
echo "===================================="
echo "✅ 애플리케이션 서비스가 종료되었습니다!"
echo "===================================="
echo ""
