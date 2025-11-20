@echo off
chcp 65001 > nul

echo ====================================
echo 모든 서비스 종료
echo ====================================
echo.

echo Spring Boot 프로세스 종료 중...
taskkill /F /FI "WINDOWTITLE eq 백엔드*" 2>nul
taskkill /F /FI "IMAGENAME eq java.exe" /FI "COMMANDLINE eq *spring-boot*" 2>nul
echo ✅ 백엔드 종료됨

echo.
echo AI 서비스 (Python) 종료 중...
taskkill /F /FI "WINDOWTITLE eq AI 서비스*" 2>nul
taskkill /F /FI "IMAGENAME eq python.exe" /FI "COMMANDLINE eq *app.py*" 2>nul
echo ✅ AI 서비스 종료됨

echo.
echo Flutter 프로세스 종료 중...
taskkill /F /FI "WINDOWTITLE eq 프론트엔드*" 2>nul
taskkill /F /FI "IMAGENAME eq flutter.exe" 2>nul
echo ✅ 프론트엔드 종료됨

echo.
echo PostgreSQL 서비스는 계속 실행됩니다.
echo 💡 PostgreSQL을 완전히 종료하려면:
echo    net stop postgresql-x64-16
echo    또는
echo    net stop postgresql
echo.
echo ====================================
echo ✅ 애플리케이션 서비스가 종료되었습니다!
echo ====================================
echo.
pause
