@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo ====================================
echo 허태훈의 분노 던전 전체 시작
echo ====================================
echo.

if not exist .env (
    echo ❌ .env 파일이 없습니다!
    echo 📝 .env.example을 복사해서 .env 파일을 만들어주세요.
    echo.
    pause
    exit /b 1
)

for /f "tokens=1,2 delims==" %%a in (.env) do (
    set "%%a=%%b"
)

echo ✅ 환경변수 로드 완료

set DATABASE_URL=jdbc:postgresql://%DB_HOST%:%DB_PORT%/%DB_NAME%

echo.
echo 1단계: 로컬 PostgreSQL 시작
echo ====================================

net start postgresql-x64-16 2>nul || net start postgresql-x64-15 2>nul || net start postgresql 2>nul
if errorlevel 1 (
    echo ⚠️  PostgreSQL 서비스를 자동으로 시작할 수 없습니다.
    echo 💡 수동으로 PostgreSQL을 시작해주세요.
) else (
    echo ✅ PostgreSQL 서비스 시작됨
)

timeout /t 3 /nobreak > nul

echo.
echo 2단계: AI 서비스 시작
echo ====================================
start "AI 서비스" cmd /k "cd ai-service && pip install -r requirements.txt && python app.py"
echo ✅ AI 서비스 새 창에서 시작됨

timeout /t 3 /nobreak > nul

echo.
echo 3단계: 백엔드 시작
echo ====================================
start "백엔드" cmd /k "cd backend && set DATABASE_URL=%DATABASE_URL% && set DB_USER=%DB_USER% && set DB_PASSWORD=%DB_PASSWORD% && set OPENAI_API_KEY=%OPENAI_API_KEY% && set AI_SERVICE_URL=%AI_SERVICE_URL% && mvn spring-boot:run"
echo ✅ 백엔드 새 창에서 시작됨

timeout /t 10 /nobreak > nul

echo.
echo 4단계: 프론트엔드 시작
echo ====================================
start "프론트엔드" cmd /k "cd frontend && flutter run -d chrome"
echo ✅ 프론트엔드 새 창에서 시작됨

echo.
echo ====================================
echo ✅ 모든 서비스가 시작되었습니다!
echo ====================================
echo.
echo 서비스 주소:
echo   - 프론트엔드: http://localhost:XXXX (Flutter가 자동 할당)
echo   - 백엔드: http://localhost:%BACKEND_PORT%
echo   - AI 서비스: %AI_SERVICE_URL%
echo   - DB: %DB_HOST%:%DB_PORT%
echo.
echo 💡 각 서비스는 별도 창에서 실행됩니다.
echo.
pause