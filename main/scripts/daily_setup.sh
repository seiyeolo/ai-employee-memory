#!/bin/bash
# 일일 설정 스크립트
# 매일 아침 실행하여 효율성 관리 시스템을 준비합니다

DATE=$(date +"%Y-%m-%d")
MEMORY_FILE="memory/$DATE.md"

# 오늘의 메모리 파일이 없으면 생성
if [ ! -f "$MEMORY_FILE" ]; then
  echo "# $DATE - 일일 기록" > "$MEMORY_FILE"
  echo "" >> "$MEMORY_FILE"
  echo "## 오늘의 목표" >> "$MEMORY_FILE"
  echo "" >> "$MEMORY_FILE"
  echo "1. " >> "$MEMORY_FILE"
  echo "2. " >> "$MEMORY_FILE"
  echo "3. " >> "$MEMORY_FILE"
  echo "" >> "$MEMORY_FILE"
  echo "## 작업 기록" >> "$MEMORY_FILE"
  echo "" >> "$MEMORY_FILE"
  echo "## 발견 및 배움" >> "$MEMORY_FILE"
  echo "" >> "$MEMORY_FILE"
  echo "## 내일로 미룬 작업" >> "$MEMORY_FILE"
  echo "" >> "$MEMORY_FILE"
  
  echo "오늘($DATE)의 메모리 파일이 생성되었습니다."
else
  echo "오늘($DATE)의 메모리 파일이 이미 존재합니다."
fi

# 효율성 추적 보고서 생성
./scripts/efficiency_tracker.sh

# 브라우저 탭 저장
./scripts/tab_saver.sh

# 하루 시작 알림
echo ""
echo "=============================="
echo "    $DATE 하루를 시작합니다    "
echo "=============================="
echo ""
echo "1. 오늘의 메모리 파일이 준비되었습니다: $MEMORY_FILE"
echo "2. 시스템 효율성 보고서가 생성되었습니다: memory/efficiency_$DATE.md"
echo "3. 브라우저 탭 상태가 저장되었습니다: memory/tabs_$DATE.md"
echo ""
echo "세미에이전트를 통해 효율적인 하루를 보내세요!"