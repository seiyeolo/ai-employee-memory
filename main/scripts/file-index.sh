#!/bin/bash
# file-index.sh — 퍼티스트 워크스페이스 파일 변경 감시 스크립트
# 매일 실행하여 신규/삭제/수정 파일을 감지합니다.

WORKSPACE="$HOME/clawd"
INDEX_DIR="$HOME/clawd/file-index"
TODAY=$(date +%Y-%m-%d)
YESTERDAY=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "yesterday" +%Y-%m-%d)

# 인덱스 디렉토리 생성
mkdir -p "$INDEX_DIR"

# 오늘 날짜의 인덱스 생성
TODAY_INDEX="$INDEX_DIR/index_$TODAY.txt"
YESTERDAY_INDEX="$INDEX_DIR/index_$YESTERDAY.txt"

# 현재 파일 목록 스캔 (숨김파일, node_modules 제외)
find "$WORKSPACE" \
  -not -path "*/node_modules/*" \
  -not -path "*/.git/*" \
  -not -path "*/file-index/*" \
  -not -path "*/.openclaw/*" \
  -not -name ".*" \
  -type f 2>/dev/null | sort > "$TODAY_INDEX"

# 총 파일 수
TOTAL_FILES=$(wc -l < "$TODAY_INDEX" | tr -d ' ')

# 리포트 생성
REPORT="$INDEX_DIR/report_$TODAY.md"
echo "# 파일 변경 감시 리포트 — $TODAY" > "$REPORT"
echo "" >> "$REPORT"
echo "- 총 파일 수: ${TOTAL_FILES}개" >> "$REPORT"

# 어제 인덱스와 비교
if [ -f "$YESTERDAY_INDEX" ]; then
  NEW_FILES=$(comm -13 "$YESTERDAY_INDEX" "$TODAY_INDEX")
  DELETED_FILES=$(comm -23 "$YESTERDAY_INDEX" "$TODAY_INDEX")

  NEW_COUNT=$(echo "$NEW_FILES" | grep -c . 2>/dev/null || echo 0)
  DEL_COUNT=$(echo "$DELETED_FILES" | grep -c . 2>/dev/null || echo 0)

  echo "- 신규 파일: ${NEW_COUNT}건" >> "$REPORT"
  echo "- 삭제 파일: ${DEL_COUNT}건" >> "$REPORT"

  if [ -n "$NEW_FILES" ]; then
    echo "" >> "$REPORT"
    echo "### 신규 파일" >> "$REPORT"
    echo "$NEW_FILES" | while read f; do
      echo "- \`$f\`" >> "$REPORT"
    done
  fi

  if [ -n "$DELETED_FILES" ]; then
    echo "" >> "$REPORT"
    echo "### 삭제된 파일" >> "$REPORT"
    echo "$DELETED_FILES" | while read f; do
      echo "- \`$f\`" >> "$REPORT"
    done
  fi
else
  echo "- 신규 파일: 첫 실행으로 비교 불가" >> "$REPORT"
  echo "- 삭제 파일: 첫 실행으로 비교 불가" >> "$REPORT"
  echo "" >> "$REPORT"
  echo "> 이것은 첫 실행입니다. 내일부터 변경사항이 추적됩니다." >> "$REPORT"
fi

# 30일 이상 된 인덱스 정리
find "$INDEX_DIR" -name "index_*.txt" -mtime +30 -delete 2>/dev/null
find "$INDEX_DIR" -name "report_*.md" -mtime +30 -delete 2>/dev/null

echo ""
echo "✅ 파일 인덱스 완료: ${TOTAL_FILES}개 파일 스캔"
echo "📄 리포트: $REPORT"
