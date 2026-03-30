#!/bin/bash
# 회사 파일 중앙 색인 시스템
# 모든 회사 관련 폴더를 스캔하여 색인 생성 + 변경 감지

INDEX_DIR="$HOME/clawd/file-index"
mkdir -p "$INDEX_DIR"

TODAY=$(date '+%Y-%m-%d')
CURRENT="$INDEX_DIR/current.txt"
PREVIOUS="$INDEX_DIR/previous.txt"
REPORT="$INDEX_DIR/report-${TODAY}.md"

# 이전 색인 백업
[ -f "$CURRENT" ] && cp "$CURRENT" "$PREVIOUS"

# 새 색인 생성 (파일경로 | 수정일시 | 크기)
echo "# 파일 색인 - ${TODAY} $(date '+%H:%M')" > "$CURRENT"
echo "" >> "$CURRENT"

scan_dir() {
    local label="$1"
    local path="$2"
    local depth="${3:-3}"
    
    if [ -d "$path" ]; then
        echo "## ${label}" >> "$CURRENT"
        find "$path" -maxdepth $depth -type f \
            ! -name ".*" ! -name "*.DS_Store" ! -path "*/.git/*" ! -path "*/node_modules/*" \
            -printf "%T@ %s %p\n" 2>/dev/null | \
        while read ts size filepath; do
            mod=$(date -r "${ts%.*}" '+%Y-%m-%d %H:%M' 2>/dev/null || echo "unknown")
            echo "  ${mod} | $(numfmt --to=iec $size 2>/dev/null || echo "${size}B") | ${filepath}" >> "$CURRENT"
        done
        # macOS용 (find -printf 없을 때)
        if [ "$(uname)" = "Darwin" ]; then
            # macOS에서는 stat 사용
            find "$path" -maxdepth $depth -type f \
                ! -name ".*" ! -name "*.DS_Store" ! -path "*/.git/*" ! -path "*/node_modules/*" 2>/dev/null | \
            while read filepath; do
                mod=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$filepath" 2>/dev/null)
                size=$(stat -f "%z" "$filepath" 2>/dev/null)
                echo "  ${mod} | ${size} | ${filepath}" >> "$CURRENT"
            done
        fi
        echo "" >> "$CURRENT"
    fi
}

# 모든 회사 폴더 스캔
scan_dir "iCloud 퍼티스트" "$HOME/Library/Mobile Documents/com~apple~CloudDocs/퍼티스트" 4
scan_dir "Google Drive" "$HOME/Library/CloudStorage/GoogleDrive-seiyeolo@gmail.com/내 드라이브" 3
scan_dir "PARA 프로젝트" "$HOME/PARA/1_Projects/퍼티스트" 3
scan_dir "PARA 업무영역" "$HOME/PARA/2_Areas/업무" 3
scan_dir "택배시스템" "$HOME/PARA/1_Projects/퍼티스트/05_운영_관리" 3
scan_dir "OpenClaw 메인" "$HOME/clawd" 2
scan_dir "OpenClaw 생산" "$HOME/clawd-production" 2
scan_dir "OpenClaw 물류" "$HOME/clawd-logistics" 2
scan_dir "OpenClaw 영업" "$HOME/clawd-sales" 2
scan_dir "OpenClaw 콘텐츠" "$HOME/clawd-content" 2

# 파일 수 집계
TOTAL=$(grep -c "^  " "$CURRENT" 2>/dev/null || echo 0)
echo "---" >> "$CURRENT"
echo "총 파일 수: ${TOTAL}" >> "$CURRENT"

# 변경 감지 보고서 생성
if [ -f "$PREVIOUS" ]; then
    # 이전에 없던 파일 (신규)
    NEW_FILES=$(comm -13 <(grep "| /" "$PREVIOUS" | awk -F'|' '{print $3}' | sort) \
                         <(grep "| /" "$CURRENT" | awk -F'|' '{print $3}' | sort) 2>/dev/null)
    
    # 이전에 있었지만 지금 없는 파일 (삭제)
    DEL_FILES=$(comm -23 <(grep "| /" "$PREVIOUS" | awk -F'|' '{print $3}' | sort) \
                         <(grep "| /" "$CURRENT" | awk -F'|' '{print $3}' | sort) 2>/dev/null)
    
    NEW_COUNT=$(echo "$NEW_FILES" | grep -c "/" 2>/dev/null || echo 0)
    DEL_COUNT=$(echo "$DEL_FILES" | grep -c "/" 2>/dev/null || echo 0)
    
    cat << EOF > "$REPORT"
# 파일 변경 보고서 - ${TODAY}

## 요약
- 총 파일 수: ${TOTAL}
- 신규 파일: ${NEW_COUNT}건
- 삭제 파일: ${DEL_COUNT}건

## 신규 파일
${NEW_FILES:-없음}

## 삭제 파일
${DEL_FILES:-없음}

---
생성 시각: $(date '+%Y-%m-%d %H:%M')
EOF
    echo "[file-index] 보고서 생성: ${REPORT} (총 ${TOTAL}개, 신규 ${NEW_COUNT}, 삭제 ${DEL_COUNT})"
else
    echo "[file-index] 최초 색인 생성 완료 (총 ${TOTAL}개)"
fi
