@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo ====================================
echo 로컬 PostgreSQL 초기화
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

set /p confirm="기존 데이터베이스를 삭제하고 새로 만들까요? (y/n): "
if /i "%confirm%"=="y" (
    echo.
    echo 기존 데이터베이스 삭제 중...
    psql -U %DB_USER% -h %DB_HOST% -p %DB_PORT% -c "DROP DATABASE IF EXISTS %DB_NAME%;" postgres
    
    echo 새 데이터베이스 생성 중...
    psql -U %DB_USER% -h %DB_HOST% -p %DB_PORT% -c "CREATE DATABASE %DB_NAME%;" postgres
    
    echo.
    echo ✅ 데이터베이스가 초기화되었습니다!
) else (
    echo.
    echo 데이터베이스 생성 시도 중...
    psql -U %DB_USER% -h %DB_HOST% -p %DB_PORT% -c "CREATE DATABASE %DB_NAME%;" postgres 2>nul
    echo ✅ 데이터베이스 확인 완료
)

echo.
echo 연결 테스트 중...
psql -U %DB_USER% -h %DB_HOST% -p %DB_PORT% -d %DB_NAME% -c "SELECT version();"

echo.
echo ====================================
echo ✅ 초기화 완료!
echo ====================================
echo.
echo 이제 백엔드를 실행하면 테이블이 자동 생성됩니다.
echo.
pause
