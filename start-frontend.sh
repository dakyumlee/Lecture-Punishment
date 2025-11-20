#!/bin/bash

echo "===================================="
echo "프론트엔드 시작"
echo "===================================="
echo ""

if [ ! -d "frontend" ]; then
    echo "❌ frontend 디렉토리를 찾을 수 없습니다."
    echo "💡 프로젝트 루트에서 실행해주세요."
    exit 1
fi

cd frontend

echo "Flutter 패키지 설치 중..."
flutter pub get

echo ""
echo "프론트엔드 시작..."
flutter run -d chrome
