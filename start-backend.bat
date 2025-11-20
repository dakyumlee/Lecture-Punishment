@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo ====================================
echo 백엔드 시작 (로컬 DB)
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

set DATABASE_URL=postgresql://%DB_HOST%:%DB_PORT%/%DB_NAME%?user=%DB_USER%^&password=%DB_PASSWORD%

echo.
echo 환경변수 확인:
echo   - DATABASE_URL: %DATABASE_URL%
echo   - OPENAI_API_KEY: %OPENAI_API_KEY:~0,20%...
echo   - AI_SERVICE_URL: %AI_SERVICE_URL%
echo   - BACKEND_PORT: %BACKEND_PORT%
echo.

if not exist backend (
    echo ❌ backend 디렉토리를 찾을 수 없습니다.
    echo 💡 프로젝트 루트에서 실행해주세요.
    pause
    exit /b 1
)

cd backend

echo 백엔드 시작 중...
call mvn spring-boot:run

cd ..
