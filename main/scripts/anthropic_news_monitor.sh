#!/bin/bash
# Anthropic 뉴스 페이지 모니터링 스크립트
# 사용법: ./anthropic_news_monitor.sh

# 변수 설정
DATE=$(date +"%Y-%m-%d")
TIME=$(date +"%H:%M:%S")
NEWS_DIR="memory"
LATEST_FILE="$NEWS_DIR/anthropic_news_latest.md"
TEMP_FILE="$NEWS_DIR/anthropic_news_temp.html"
LOG_FILE="$NEWS_DIR/anthropic_news_log.md"
URL="https://www.anthropic.com/news"
NEW_NEWS_FOUND=false

echo "Anthropic 뉴스 모니터링 시작: $DATE $TIME"

# 디렉토리 확인
if [ ! -d "$NEWS_DIR" ]; then
  mkdir -p "$NEWS_DIR"
  echo "📁 $NEWS_DIR 디렉토리 생성됨"
fi

# 뉴스 페이지 다운로드
echo "🌐 $URL 페이지 다운로드 중..."
curl -s "$URL" > "$TEMP_FILE"

# 최신 뉴스 제목 추출 (간단한 예시, 실제로는 더 정교한 파싱이 필요)
LATEST_NEWS_TITLE=$(grep -o '<a href="/news/[^"]*"[^>]*>.*Jan [0-9]\+, 2026.*</a>' "$TEMP_FILE" | head -1 | sed 's/.*>\(.*\)<\/a>/\1/' | sed 's/<[^>]*>//g' | awk -F'Announcements' '{print $2}' | awk -F'Product' '{print $2}' | awk -F'Case Study' '{print $2}' | awk -F'Economic Research' '{print $2}' | awk -F'Policy' '{print $2}' | sed 's/^[[:space:]]*//')

# 기존에 저장된 최신 뉴스 제목 가져오기
if [ -f "$LATEST_FILE" ]; then
  PREVIOUS_NEWS_TITLE=$(grep -A 1 "### 최근 Anthropic 뉴스 목록" "$LATEST_FILE" | grep -v "###" | head -1 | sed 's/^[0-9]*\. \*\*\(.*\)\*\*.*/\1/')
  
  # 새로운 뉴스가 있는지 확인
  if [ "$LATEST_NEWS_TITLE" != "$PREVIOUS_NEWS_TITLE" ] && [ ! -z "$LATEST_NEWS_TITLE" ]; then
    echo "🔔 새로운 뉴스 발견: $LATEST_NEWS_TITLE"
    NEW_NEWS_FOUND=true
    
    # 로그 파일에 기록
    echo -e "## $DATE $TIME\n새로운 뉴스: **$LATEST_NEWS_TITLE**\n" >> "$LOG_FILE"
    
    # 여기에 알림 보내는 코드 추가 (예: 텔레그램 메시지)
    # 실제 구현은 환경에 따라 다름
  else
    echo "📰 새로운 뉴스 없음"
  fi
else
  echo "⚠️ 이전 뉴스 파일이 없습니다. 초기 설정 중..."
  NEW_NEWS_FOUND=true
fi

# 임시 파일 삭제
rm -f "$TEMP_FILE"

echo "✅ 모니터링 완료: $DATE $TIME"
echo ""

# 결과 출력
if [ "$NEW_NEWS_FOUND" = true ]; then
  echo "새로운 뉴스가 발견되었습니다. memory/anthropic_news_log.md 파일을 확인하세요."
  exit 1  # 새로운 뉴스가 있음을 나타내는 종료 코드
else
  echo "새로운 뉴스가 없습니다."
  exit 0  # 새로운 뉴스가 없음을 나타내는 종료 코드
fi