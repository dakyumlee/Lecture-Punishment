@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo ====================================
echo 허태훈의 분노 던전 (로컬)
echo ====================================
echo.
echo 📦 로컬 DB 정보:
echo    컨테이너: heotaehoon-local
echo    Database: heotaehoon_local
echo    Username: postgres
echo    Password: postgres123
echo    Host: localhost:5432
echo.
echo 💡 DB 접속: docker exec -it heotaehoon-local psql -U postgres -d heotaehoon_local
echo.

if not exist .env (
    echo ❌ .env 파일 없음
    pause
    exit /b 1
)

for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
    if "%%a"=="OPENAI_API_KEY" set "OPENAI_API_KEY=%%b"
)

echo [1/4] PostgreSQL 도커 확인...
docker ps | findstr heotaehoon-local >nul 2>&1
if errorlevel 1 (
    echo 📦 DB 컨테이너 시작 중...
    docker start heotaehoon-local 2>nul || docker run -d --name heotaehoon-local -e POSTGRES_DB=heotaehoon_local -e POSTGRES_USER=postgres -e POSTGRES_PASSWORD=postgres123 -p 5432:5432 postgres:16
    timeout /t 5 /nobreak > nul
)
echo ✅ PostgreSQL 실행 중

echo.
echo [2/4] AI 서비스 시작...
start "AI 서비스" cmd /k "chcp 65001 > nul && cd /d %~dp0ai-service && python app.py"
timeout /t 3 /nobreak > nul

echo.
echo [3/4] 백엔드 시작...
start "백엔드" cmd /k "chcp 65001 > nul && cd /d %~dp0backend && set OPENAI_API_KEY=%OPENAI_API_KEY% && mvn spring-boot:run"
timeout /t 10 /nobreak > nul

echo.
echo [4/4] 프론트엔드 시작...
start "프론트엔드" cmd /k "chcp 65001 > nul && cd /d %~dp0frontend && flutter run -d chrome"

echo.
echo ====================================
echo ✅ 실행 완료!
echo ====================================
echo 📍 백엔드: http://localhost:8080
echo 📍 DB: localhost:5432/heotaehoon_local
echo.
echo 🔐 관리자 계정:
echo    ID: hth422
echo    PW: password1234!
echo.
echo 🛑 종료: docker stop heotaehoon-local
echo.
pause
