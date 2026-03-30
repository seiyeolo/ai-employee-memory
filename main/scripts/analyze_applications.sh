#!/bin/bash
# 응용 프로그램 분석 및 정리 보고서 생성

OUTPUT_DIR="/Users/mac/clawd/folder-cleanup"
REPORT_FILE="$OUTPUT_DIR/응용프로그램_분석보고서_$(date +%Y%m%d_%H%M%S).md"

mkdir -p "$OUTPUT_DIR"

echo "=== 응용 프로그램 분석 시작 ===" 
echo "분석 시간: $(date)"
echo ""

# 보고서 헤더
cat > "$REPORT_FILE" << 'EOF'
# 응용 프로그램 분석 보고서

## 분석 개요
EOF

echo "분석 일시: $(date)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 1. 전체 앱 개수 및 총 크기
echo "## 1. 전체 현황" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

TOTAL_APPS=$(ls -1 /Applications | wc -l | tr -d ' ')
TOTAL_SIZE=$(du -sh /Applications 2>/dev/null | awk '{print $1}')

echo "- **총 설치된 앱**: ${TOTAL_APPS}개" >> "$REPORT_FILE"
echo "- **총 용량**: ${TOTAL_SIZE}" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 2. 앱 목록 및 크기
echo "## 2. 설치된 앱 목록 (크기 순)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| 순위 | 앱 이름 | 크기 | 마지막 수정일 |" >> "$REPORT_FILE"
echo "|------|---------|------|---------------|" >> "$REPORT_FILE"

counter=1
du -sh /Applications/* 2>/dev/null | sort -hr | head -30 | while read size path; do
    app_name=$(basename "$path")
    mod_date=$(stat -f "%Sm" -t "%Y-%m-%d" "$path" 2>/dev/null || echo "알 수 없음")
    echo "| $counter | $app_name | $size | $mod_date |" >> "$REPORT_FILE"
    counter=$((counter + 1))
done

echo "" >> "$REPORT_FILE"

# 3. 1년 이상 미사용 앱 찾기
echo "## 3. 1년 이상 미사용 앱 (삭제 고려 대상)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "> 마지막 접근 시간이 1년 이상 지난 앱들입니다." >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| 앱 이름 | 크기 | 마지막 사용 | 미사용 일수 |" >> "$REPORT_FILE"
echo "|---------|------|-------------|-------------|" >> "$REPORT_FILE"

OLD_APPS_COUNT=0
OLD_APPS_SIZE=0

find /Applications -maxdepth 1 -type d -atime +365 2>/dev/null | while read app; do
    if [ "$app" != "/Applications" ]; then
        app_name=$(basename "$app")
        size=$(du -sh "$app" 2>/dev/null | awk '{print $1}')
        last_access=$(stat -f "%Sa" -t "%Y-%m-%d" "$app" 2>/dev/null || echo "알 수 없음")
        days_ago=$(( ($(date +%s) - $(stat -f "%a" "$app" 2>/dev/null || echo 0)) / 86400 ))
        
        # 시스템 앱 제외
        if [[ ! "$app_name" =~ ^(Utilities|System|App\ Store) ]]; then
            echo "| $app_name | $size | $last_access | ${days_ago}일 전 |" >> "$REPORT_FILE"
            OLD_APPS_COUNT=$((OLD_APPS_COUNT + 1))
        fi
    fi
done

echo "" >> "$REPORT_FILE"
echo "**1년 이상 미사용 앱**: ${OLD_APPS_COUNT}개" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 4. 큰 용량 앱 (1GB 이상)
echo "## 4. 대용량 앱 (1GB 이상)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "| 앱 이름 | 크기 |" >> "$REPORT_FILE"
echo "|---------|------|" >> "$REPORT_FILE"

find /Applications -maxdepth 1 -type d -size +1G 2>/dev/null | while read app; do
    if [ "$app" != "/Applications" ]; then
        app_name=$(basename "$app")
        size=$(du -sh "$app" 2>/dev/null | awk '{print $1}')
        echo "| $app_name | $size |" >> "$REPORT_FILE"
    fi
done

echo "" >> "$REPORT_FILE"

# 5. 카테고리별 분류
echo "## 5. 카테고리별 분류 (추정)" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "### 개발 도구" >> "$REPORT_FILE"
ls -1 /Applications | grep -iE "(xcode|code|studio|cursor|cursor|jetbrains|idea|pycharm|webstorm|antigravity|claude)" >> "$REPORT_FILE" 2>/dev/null
echo "" >> "$REPORT_FILE"

echo "### 디자인 도구" >> "$REPORT_FILE"
ls -1 /Applications | grep -iE "(figma|sketch|adobe|photoshop|illustrator|design)" >> "$REPORT_FILE" 2>/dev/null
echo "" >> "$REPORT_FILE"

echo "### 커뮤니케이션" >> "$REPORT_FILE"
ls -1 /Applications | grep -iE "(slack|discord|telegram|zoom|teams|kakao)" >> "$REPORT_FILE" 2>/dev/null
echo "" >> "$REPORT_FILE"

echo "### 브라우저" >> "$REPORT_FILE"
ls -1 /Applications | grep -iE "(chrome|firefox|safari|edge|brave|arc)" >> "$REPORT_FILE" 2>/dev/null
echo "" >> "$REPORT_FILE"

echo "### 유틸리티" >> "$REPORT_FILE"
ls -1 /Applications | grep -iE "(cleaner|monitor|manager|tools|utility)" >> "$REPORT_FILE" 2>/dev/null
echo "" >> "$REPORT_FILE"

# 6. 권장 사항
echo "## 6. 정리 권장 사항" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "### 🔴 즉시 삭제 고려" >> "$REPORT_FILE"
echo "- 1년 이상 미사용 + 대용량 (1GB 이상) 앱" >> "$REPORT_FILE"
echo "- 중복 기능을 가진 앱" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "### 🟡 검토 후 결정" >> "$REPORT_FILE"
echo "- 1년 이상 미사용이지만 작은 크기의 앱" >> "$REPORT_FILE"
echo "- 가끔 사용할 가능성이 있는 앱" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "### 🟢 유지" >> "$REPORT_FILE"
echo "- 최근 사용한 앱" >> "$REPORT_FILE"
echo "- 시스템 필수 앱" >> "$REPORT_FILE"
echo "- 업무/개발 필수 도구" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

# 7. 삭제 방법
echo "## 7. 안전한 삭제 방법" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "### 방법 1: Finder에서 삭제" >> "$REPORT_FILE"
echo '1. Finder → 응용 프로그램' >> "$REPORT_FILE"
echo '2. 앱 선택 → 휴지통으로 이동 (Cmd+Delete)' >> "$REPORT_FILE"
echo '3. 휴지통 비우기' >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "### 방법 2: 명령어로 삭제 (세미가 도움)" >> "$REPORT_FILE"
echo '```bash' >> "$REPORT_FILE"
echo '# 예시: 앱 이름을 알려주시면 안전하게 삭제' >> "$REPORT_FILE"
echo 'trash /Applications/앱이름.app' >> "$REPORT_FILE"
echo '```' >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"

echo "---" >> "$REPORT_FILE"
echo "" >> "$REPORT_FILE"
echo "**보고서 생성 완료**: $(date)" >> "$REPORT_FILE"

echo "✅ 분석 완료!"
echo "보고서 위치: $REPORT_FILE"
