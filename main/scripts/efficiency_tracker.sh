#!/bin/bash
# 효율성 추적 스크립트
# 매일 시스템 사용 패턴을 기록하고 분석합니다

DATE=$(date +"%Y-%m-%d")
REPORT_FILE="memory/efficiency_$DATE.md"
STATS_DIR="memory/stats"
mkdir -p "$STATS_DIR"

# 헤더 생성
echo "# 효율성 추적 보고서 ($DATE)" > "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 시스템 리소스 사용량
echo "## 시스템 리소스 현황" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# CPU 부하
echo "### CPU 부하" >> "$REPORT_FILE"
ps -eo pcpu,comm | sort -k 1 -r | head -6 | 
while read -r cpu app; do
  if [[ $app == /* ]]; then
    app_name=$(basename "$app")
    echo "- $app_name: $cpu%" >> "$REPORT_FILE"
  fi
done
echo "" >> "$REPORT_FILE"

# 메모리 사용량
echo "### 메모리 사용량" >> "$REPORT_FILE"
ps -eo pmem,comm | sort -k 1 -r | head -6 | 
while read -r mem app; do
  if [[ $app == /* ]]; then
    app_name=$(basename "$app")
    echo "- $app_name: $mem%" >> "$REPORT_FILE"
  fi
done
echo "" >> "$REPORT_FILE"

# 실행 중인 앱 개수
app_count=$(ps -eo comm | grep -v "^\\[" | sort | uniq | wc -l | tr -d ' ')
echo "### 실행 중인 앱: $app_count" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# Chrome 탭 개수
echo "### 브라우저 탭" >> "$REPORT_FILE"
tab_count=$(osascript -e 'tell application "Google Chrome" to count tabs of front window')
echo "- Chrome 탭 수: $tab_count" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 효율성 점수 계산 (간단한 알고리즘)
# 100점 만점에서 과도한 리소스 사용과 앱/탭 개수에 따라 감점
top_cpu=$(ps -eo pcpu | sort -k 1 -r | head -1 | tr -d ' ')
# 부동 소수점 처리를 위해 정수로 변환
top_cpu_int=$(printf "%.0f" "$top_cpu")
cpu_score=$((100 - top_cpu_int / 2))
tab_score=$((100 - tab_count * 2))
app_score=$((100 - app_count * 3))

if [ $cpu_score -lt 0 ]; then cpu_score=0; fi
if [ $tab_score -lt 0 ]; then tab_score=0; fi
if [ $app_score -lt 0 ]; then app_score=0; fi

total_score=$(( (cpu_score + tab_score + app_score) / 3 ))

echo "## 효율성 점수: $total_score / 100" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "- CPU 효율성: $cpu_score / 100" >> "$REPORT_FILE"
echo "- 탭 관리 효율성: $tab_score / 100" >> "$REPORT_FILE"
echo "- 앱 관리 효율성: $app_score / 100" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 개선 제안
echo "## 개선 제안" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

if [ $cpu_score -lt 70 ]; then
  echo "- 🔴 CPU 사용량이 높습니다. 불필요한 백그라운드 프로세스를 확인하세요." >> "$REPORT_FILE"
fi

if [ $tab_score -lt 70 ]; then
  echo "- 🔴 브라우저 탭이 너무 많습니다. 필요한 정보는 저장하고 탭을 정리하세요." >> "$REPORT_FILE"
fi

if [ $app_score -lt 70 ]; then
  echo "- 🔴 실행 중인 앱이 너무 많습니다. 현재 필요하지 않은 앱은 종료하세요." >> "$REPORT_FILE"
fi

echo "" >> "$REPORT_FILE"
echo "마지막 업데이트: $(date +"%H:%M:%S")" >> "$REPORT_FILE"

# 통계 데이터 저장 (나중에 추세 분석용)
echo "$DATE,$total_score,$cpu_score,$tab_score,$app_score,$app_count,$tab_count" >> "$STATS_DIR/efficiency_stats.csv"

echo "효율성 보고서가 $REPORT_FILE에 저장되었습니다."