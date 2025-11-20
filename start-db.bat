@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo ====================================
echo 로컬 PostgreSQL 시작
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
echo.
echo 데이터베이스 정보:
echo   - Database: %DB_NAME%
echo   - Username: %DB_USER%
echo   - Port: %DB_PORT%
echo   - Host: %DB_HOST%
echo.

echo PostgreSQL 서비스 시작 중...
net start postgresql-x64-16 2>nul
if errorlevel 1 (
    net start postgresql-x64-15 2>nul
    if errorlevel 1 (
        net start postgresql 2>nul
        if errorlevel 1 (
            echo.
            echo ⚠️  PostgreSQL 서비스를 자동으로 시작할 수 없습니다.
            echo 💡 수동으로 PostgreSQL을 시작하거나 서비스 이름을 확인하세요.
            echo.
            echo 서비스 이름 확인: sc query ^| findstr postgres
            echo.
        ) else (
            echo ✅ PostgreSQL 서비스가 시작되었습니다!
        )
    ) else (
        echo ✅ PostgreSQL 서비스가 시작되었습니다!
    )
) else (
    echo ✅ PostgreSQL 서비스가 시작되었습니다!
)

echo.
echo 연결 대기 중...
timeout /t 2 /nobreak > nul

echo.
echo 연결 테스트 중...
psql -U %DB_USER% -h %DB_HOST% -p %DB_PORT% -d %DB_NAME% -c "SELECT version();" 2>nul

if errorlevel 1 (
    echo.
    echo ⚠️  데이터베이스가 존재하지 않습니다.
    echo 💡 init-local-db.bat을 실행해서 데이터베이스를 생성하세요.
) else (
    echo.
    echo ✅ 데이터베이스 연결 성공!
)

echo.
pause
