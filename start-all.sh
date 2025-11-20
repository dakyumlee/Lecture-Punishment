#!/bin/bash

echo "===================================="
echo "허태훈의 분노 던전 전체 시작"
echo "===================================="
echo ""

if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
    echo "✅ 환경변수 로드 완료"
else
    echo "❌ .env 파일이 없습니다!"
    echo "📝 .env.example을 복사해서 .env 파일을 만들어주세요."
    exit 1
fi

export DATABASE_URL="postgresql://$DB_HOST:$DB_PORT/$DB_NAME?user=$DB_USER&password=$DB_PASSWORD"

OS_TYPE=$(uname -s)

echo ""
echo "1단계: 로컬 PostgreSQL 시작"
echo "===================================="

if [[ "$OS_TYPE" == "Darwin" ]]; then
    if command -v brew &> /dev/null; then
        brew services start postgresql@16 2>/dev/null || brew services start postgresql@15 2>/dev/null || brew services start postgresql 2>/dev/null
        echo "✅ macOS - PostgreSQL 서비스 시작됨"
    fi
elif [[ "$OS_TYPE" == "Linux" ]]; then
    if command -v systemctl &> /dev/null; then
        sudo systemctl start postgresql 2>/dev/null
        echo "✅ Linux - PostgreSQL 서비스 시작됨"
    elif command -v service &> /dev/null; then
        sudo service postgresql start 2>/dev/null
        echo "✅ Linux - PostgreSQL 서비스 시작됨"
    fi
fi

sleep 3

echo ""
echo "2단계: AI 서비스 시작"
echo "===================================="

if [[ "$OS_TYPE" == "Darwin" ]]; then
    osascript -e 'tell application "Terminal" to do script "cd \"'$(pwd)'/ai-service\" && pip3 install -r requirements.txt && python3 app.py"' 2>/dev/null
    echo "✅ AI 서비스 새 터미널에서 시작됨"
elif [[ "$OS_TYPE" == "Linux" ]]; then
    if command -v gnome-terminal &> /dev/null; then
        gnome-terminal -- bash -c "cd $(pwd)/ai-service && pip3 install -r requirements.txt && python3 app.py; exec bash" 2>/dev/null
        echo "✅ AI 서비스 새 터미널에서 시작됨"
    elif command -v xterm &> /dev/null; then
        xterm -e "cd $(pwd)/ai-service && pip3 install -r requirements.txt && python3 app.py; exec bash" &
        echo "✅ AI 서비스 새 터미널에서 시작됨"
    else
        echo "⚠️  새 터미널을 열 수 없습니다. 수동으로 AI 서비스를 시작하세요."
        echo "   cd ai-service && pip3 install -r requirements.txt && python3 app.py"
    fi
fi

sleep 3

echo ""
echo "3단계: 백엔드 시작"
echo "===================================="

if [[ "$OS_TYPE" == "Darwin" ]]; then
    osascript -e 'tell application "Terminal" to do script "cd \"'$(pwd)'/backend\" && export DATABASE_URL=postgresql://'$DB_HOST':'$DB_PORT'/'$DB_NAME'?user='$DB_USER'\\&password='$DB_PASSWORD' && export OPENAI_API_KEY='$OPENAI_API_KEY' && export AI_SERVICE_URL='$AI_SERVICE_URL' && mvn spring-boot:run"' 2>/dev/null
    echo "✅ 백엔드 새 터미널에서 시작됨"
elif [[ "$OS_TYPE" == "Linux" ]]; then
    if command -v gnome-terminal &> /dev/null; then
        gnome-terminal -- bash -c "cd $(pwd)/backend && export DATABASE_URL=postgresql://$DB_HOST:$DB_PORT/$DB_NAME?user=$DB_USER\\&password=$DB_PASSWORD && export OPENAI_API_KEY=$OPENAI_API_KEY && export AI_SERVICE_URL=$AI_SERVICE_URL && mvn spring-boot:run; exec bash" 2>/dev/null
        echo "✅ 백엔드 새 터미널에서 시작됨"
    elif command -v xterm &> /dev/null; then
        xterm -e "cd $(pwd)/backend && export DATABASE_URL=postgresql://$DB_HOST:$DB_PORT/$DB_NAME?user=$DB_USER\\&password=$DB_PASSWORD && export OPENAI_API_KEY=$OPENAI_API_KEY && export AI_SERVICE_URL=$AI_SERVICE_URL && mvn spring-boot:run; exec bash" &
        echo "✅ 백엔드 새 터미널에서 시작됨"
    else
        echo "⚠️  새 터미널을 열 수 없습니다. 수동으로 백엔드를 시작하세요."
        echo "   cd backend && mvn spring-boot:run"
    fi
fi

sleep 10

echo ""
echo "4단계: 프론트엔드 시작"
echo "===================================="

if [[ "$OS_TYPE" == "Darwin" ]]; then
    osascript -e 'tell application "Terminal" to do script "cd \"'$(pwd)'/frontend\" && flutter run -d chrome"' 2>/dev/null
    echo "✅ 프론트엔드 새 터미널에서 시작됨"
elif [[ "$OS_TYPE" == "Linux" ]]; then
    if command -v gnome-terminal &> /dev/null; then
        gnome-terminal -- bash -c "cd $(pwd)/frontend && flutter run -d chrome; exec bash" 2>/dev/null
        echo "✅ 프론트엔드 새 터미널에서 시작됨"
    elif command -v xterm &> /dev/null; then
        xterm -e "cd $(pwd)/frontend && flutter run -d chrome; exec bash" &
        echo "✅ 프론트엔드 새 터미널에서 시작됨"
    else
        echo "⚠️  새 터미널을 열 수 없습니다. 수동으로 프론트엔드를 시작하세요."
        echo "   cd frontend && flutter run -d chrome"
    fi
fi

echo ""
echo "===================================="
echo "✅ 모든 서비스가 시작되었습니다!"
echo "===================================="
echo ""
echo "서비스 주소:"
echo "  - 프론트엔드: http://localhost:XXXX (Flutter가 자동 할당)"
echo "  - 백엔드: http://localhost:$BACKEND_PORT"
echo "  - AI 서비스: $AI_SERVICE_URL"
echo "  - DB: $DB_HOST:$DB_PORT"
echo ""
echo "💡 각 서비스는 별도 터미널 창에서 실행됩니다."
echo ""
