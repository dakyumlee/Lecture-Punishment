@echo off
chcp 65001 > nul

echo ====================================
echo 프론트엔드 시작
echo ====================================
echo.

if not exist frontend (
    echo ❌ frontend 디렉토리를 찾을 수 없습니다.
    echo 💡 프로젝트 루트에서 실행해주세요.
    pause
    exit /b 1
)

cd frontend

echo Flutter 패키지 설치 중...
call flutter pub get

echo.
echo 프론트엔드 시작...
call flutter run -d chrome

cd ..
