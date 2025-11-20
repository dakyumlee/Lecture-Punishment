#!/bin/bash

echo "===================================="
echo "로컬 PostgreSQL 시작"
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

echo ""
echo "데이터베이스 정보:"
echo "  - Database: $DB_NAME"
echo "  - Username: $DB_USER"
echo "  - Port: $DB_PORT"
echo "  - Host: $DB_HOST"
echo ""

OS_TYPE=$(uname -s)

echo "PostgreSQL 서비스 시작 중..."
echo ""

if [[ "$OS_TYPE" == "Darwin" ]]; then
    if command -v brew &> /dev/null; then
        brew services start postgresql@16 || brew services start postgresql@15 || brew services start postgresql
        echo "✅ macOS - Homebrew PostgreSQL 서비스 시작됨"
    else
        echo "❌ Homebrew가 설치되지 않았습니다."
        exit 1
    fi
elif [[ "$OS_TYPE" == "Linux" ]]; then
    if command -v systemctl &> /dev/null; then
        sudo systemctl start postgresql
        echo "✅ Linux - systemd PostgreSQL 서비스 시작됨"
    elif command -v service &> /dev/null; then
        sudo service postgresql start
        echo "✅ Linux - service PostgreSQL 서비스 시작됨"
    else
        pg_ctl -D /usr/local/var/postgres start
        echo "✅ Linux - pg_ctl PostgreSQL 서비스 시작됨"
    fi
else
    echo "❌ 지원하지 않는 OS입니다: $OS_TYPE"
    exit 1
fi

echo ""
echo "연결 대기 중..."
sleep 2

echo ""
echo "연결 테스트 중..."
psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME -c "SELECT version();" 2>/dev/null

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ 데이터베이스 연결 성공!"
else
    echo ""
    echo "⚠️  데이터베이스가 존재하지 않습니다."
    echo "💡 init-local-db.sh를 실행해서 데이터베이스를 생성하세요."
fi

echo ""
