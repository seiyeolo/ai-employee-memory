#!/bin/bash
# Anthropic 뉴스 확인 스크립트
# 3일에 한 번 정도 이 스크립트를 실행하여 새로운 뉴스를 확인할 수 있습니다

# 변수 설정
DATE=$(date +"%Y-%m-%d")
NEWS_DIR="memory"
LATEST_NEWS_FILE="$NEWS_DIR/anthropic_news_latest.md"
TEMP_HTML="$NEWS_DIR/anthropic_temp.html"
LAST_CHECK_FILE="$NEWS_DIR/anthropic_last_check.txt"
URL="https://www.anthropic.com/news"

echo "=== Anthropic 뉴스 확인 ($DATE) ==="

# 마지막 확인 시간 기록
echo "$DATE" > "$LAST_CHECK_FILE"

# 뉴스 페이지 가져오기
echo "페이지 다운로드 중..."
curl -s "$URL" > "$TEMP_HTML"

# 최신 뉴스 제목 추출
echo "뉴스 분석 중..."
LATEST_NEWS=$(grep -o '<a href="/news/[^"]*"[^>]*>.*Jan [0-9]\+, 2026.*</a>' "$TEMP_HTML" | head -1)
LATEST_NEWS_TITLE=$(echo "$LATEST_NEWS" | sed 's/.*>\(.*\)<\/a>/\1/' | sed 's/<[^>]*>//g')
LATEST_NEWS_URL=$(echo "$LATEST_NEWS" | grep -o 'href="[^"]*"' | sed 's/href="/https:\/\/www.anthropic.com/g' | sed 's/"//g')

# 이전 뉴스 제목 확인
if [ -f "$LATEST_NEWS_FILE" ]; then
  PREVIOUS_TITLE=$(grep -A 1 "### 최근 Anthropic 뉴스 목록" "$LATEST_NEWS_FILE" | grep -v "###" | head -1 | sed 's/^[0-9]*\. \*\*\(.*\)\*\*.*/\1/')
  
  if [ "$LATEST_NEWS_TITLE" != "$PREVIOUS_TITLE" ] && [ ! -z "$LATEST_NEWS_TITLE" ]; then
    echo "새로운 뉴스 발견!"
    echo "제목: $LATEST_NEWS_TITLE"
    echo "URL: $LATEST_NEWS_URL"
    
    # 파일 업데이트
    sed -i'.bak' "s/## 마지막 확인: .*/## 마지막 확인: $DATE/" "$LATEST_NEWS_FILE"
    
    # 여기에 알림 메시지 생성 및 전송 코드 추가 가능
    echo "알림: Anthropic에 새로운 뉴스가 있습니다: $LATEST_NEWS_TITLE"
    echo "자세한 내용은 $LATEST_NEWS_URL 에서 확인하세요."
  else
    echo "새로운 뉴스가 없습니다."
  fi
else
  echo "이전 뉴스 기록이 없습니다. 새로 생성합니다."
  # 여기서는 기존 파일이 이미 생성되어 있으므로 추가 작업 불필요
fi

# 임시 파일 정리
rm -f "$TEMP_HTML"

echo "확인 완료!"
echo "다음 확인은 3일 후에 진행하세요."
echo "============================="