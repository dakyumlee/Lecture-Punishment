@echo off
chcp 65001 > nul
echo ====================================
echo 완전 초기화 후 시작
echo ====================================
echo.

echo 🗑️  기존 컨테이너 삭제 중...
docker-compose -f docker-compose.local.yml down -v

echo.
echo 🚀 새로 시작...
docker-compose -f docker-compose.local.yml up -d

timeout /t 5 /nobreak > nul

echo.
echo 📦 서비스 시작...
call start-all.bat
