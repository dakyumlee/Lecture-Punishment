#!/bin/bash

echo "===================================="
echo "AI 서비스 시작"
echo "===================================="
echo ""

if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo "✅ 환경변수 로드 완료"
else
    echo "⚠️  .env 파일이 없습니다. 기본값을 사용합니다."
fi

if [ ! -d "ai-service" ]; then
    echo "❌ ai-service 디렉토리를 찾을 수 없습니다."
    echo "💡 프로젝트 루트에서 실행해주세요."
    exit 1
fi

cd ai-service

echo ""
echo "Python 패키지 설치 중..."
pip3 install -r requirements.txt

echo ""
echo "AI 서비스 시작..."
python3 app.py
