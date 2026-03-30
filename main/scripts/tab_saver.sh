#!/bin/bash
# 브라우저 탭 저장 스크립트

DATE=$(date +"%Y-%m-%d")
TAB_FILE="memory/tabs_$DATE.md"

echo "# 브라우저 탭 ($DATE)" > "$TAB_FILE"
echo "" >> "$TAB_FILE"
echo "## Chrome" >> "$TAB_FILE"

# Chrome 탭 가져오기
osascript -e 'tell application "Google Chrome" to get {URL, title} of tabs of front window' | 
while read -r line; do
  if [[ $line == http* ]]; then
    url=$(echo "$line" | sed 's/,.*$//')
    title=$(echo "$line" | sed -n 's/.*,//p')
    echo "- [$title]($url)" >> "$TAB_FILE"
  fi
done

echo "" >> "$TAB_FILE"
echo "## 실행 중인 앱" >> "$TAB_FILE"

# 실행 중인 앱 목록
ps -eo pcpu,pmem,comm | sort -k 1 -r | head -10 | 
while read -r cpu mem app; do
  if [[ $app == /* ]]; then
    app_name=$(basename "$app")
    echo "- $app_name (CPU: $cpu%, MEM: $mem%)" >> "$TAB_FILE"
  fi
done

echo "" >> "$TAB_FILE"
echo "마지막 저장 시간: $(date +"%H:%M:%S")" >> "$TAB_FILE"

echo "탭 정보가 $TAB_FILE에 저장되었습니다."