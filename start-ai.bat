@echo off
chcp 65001 > nul
setlocal enabledelayedexpansion

echo ====================================
echo AI 서비스 시작
echo ====================================
echo.

if exist .env (
    for /f "tokens=1,2 delims==" %%a in (.env) do (
        set "%%a=%%b"
    )
    echo ✅ 환경변수 로드 완료
) else (
    echo ⚠️  .env 파일이 없습니다. 기본값을 사용합니다.
)

if not exist ai-service (
    echo ❌ ai-service 디렉토리를 찾을 수 없습니다.
    echo 💡 프로젝트 루트에서 실행해주세요.
    pause
    exit /b 1
)

cd ai-service

echo.
echo Python 패키지 설치 중...
pip install -r requirements.txt

echo.
echo AI 서비스 시작...
python app.py

cd ..
