@echo off
chcp 65001 > nul

echo ====================================
echo 허태훈의 분노 던전 (로컬 실행)
echo ====================================
echo.

if not exist .env (
    echo ❌ .env 파일이 없습니다!
    pause
    exit /b 1
)

for /f "tokens=1,2 delims==" %%a in (.env) do (
    set "%%a=%%b"
)

echo 1️⃣  PostgreSQL 도커 시작 (로컬용)...
docker-compose -f docker-compose.local.yml up -d
echo ⏳ DB 준비 대기 중...
timeout /t 5 /nobreak > nul
echo ✅ PostgreSQL 도커 실행 완료

echo.
echo 2️⃣  AI 서비스 시작...
start "AI 서비스" cmd /k "cd ai-service && python app.py"
timeout /t 3 /nobreak > nul

echo.
echo 3️⃣  백엔드 시작...
start "백엔드" cmd /k "cd backend && set DATABASE_URL=jdbc:postgresql://localhost:5432/heotaehoon_dungeon && set DB_USER=postgres && set DB_PASSWORD=postgres && set OPENAI_API_KEY=%OPENAI_API_KEY% && set AI_SERVICE_URL=http://localhost:5000 && mvn spring-boot:run"
timeout /t 10 /nobreak > nul

echo.
echo 4️⃣  프론트엔드 시작...
start "프론트엔드" cmd /k "cd frontend && flutter run -d chrome"

echo.
echo ====================================
echo ✅ 실행 완료!
echo ====================================
echo 📍 백엔드: http://localhost:8080
echo 📍 DB (도커): localhost:5432
echo.
echo 💡 종료: stop-all.bat
echo.
pause
