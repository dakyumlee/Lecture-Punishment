@echo off
chcp 65001 > nul
echo 🛑 모든 서비스 종료 중...
docker-compose -f docker-compose.local.yml down
echo ✅ 종료 완료
pause
