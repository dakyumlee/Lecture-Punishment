@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo ====================================
echo 허태훈의 분노 던전 (로컬)
echo ====================================
echo.

if not exist .env (
    echo ❌ .env 파일 없음
    pause
    exit /b 1
)

for /f "usebackq tokens=1,2 delims==" %%a in (".env") do (
    if not "%%a"=="" if not "%%b"=="" (
        set "%%a=%%b"
    )
)

echo [1/4] PostgreSQL 도커 시작...
docker-compose -f docker-compose.local.yml up -d
if errorlevel 1 (
    echo ❌ 도커 실행 실패
    pause
    exit /b 1
)
timeout /t 5 /nobreak > nul
echo ✅ PostgreSQL 시작 완료

echo.
echo [2/4] AI 서비스 시작...
start "AI 서비스" cmd /k "chcp 65001 > nul && cd /d %~dp0ai-service && python app.py"
timeout /t 3 /nobreak > nul

echo.
echo [3/4] 백엔드 시작...
start "백엔드" cmd /k "chcp 65001 > nul && cd /d %~dp0backend && set DATABASE_URL=jdbc:postgresql://localhost:5432/heotaehoon_dungeon && set DB_USER=postgres && set DB_PASSWORD=postgres && set OPENAI_API_KEY=%OPENAI_API_KEY% && set AI_SERVICE_URL=http://localhost:5000 && mvn spring-boot:run"
timeout /t 10 /nobreak > nul

echo.
echo [4/4] 프론트엔드 시작...
start "프론트엔드" cmd /k "chcp 65001 > nul && cd /d %~dp0frontend && flutter run -d chrome"

echo.
echo ====================================
echo ✅ 모든 서비스 시작 완료!
echo ====================================
echo 📍 백엔드: http://localhost:8080
echo 📍 DB: localhost:5432
echo.
echo 💡 종료: stop-all.bat
echo.
pause
