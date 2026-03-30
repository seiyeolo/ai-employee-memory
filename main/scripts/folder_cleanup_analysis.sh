#!/bin/bash
# 맥미니 폴더 구조 분석 스크립트

OUTPUT_DIR="/Users/mac/clawd/folder-cleanup"
mkdir -p "$OUTPUT_DIR"

echo "=== 맥미니 폴더 구조 분석 시작 ==="
echo "분석 시간: $(date)"
echo ""

# 1. 홈 디렉토리 구조 분석
echo "1. 홈 디렉토리 1단계 구조" > "$OUTPUT_DIR/01_home_structure.txt"
ls -lh ~ >> "$OUTPUT_DIR/01_home_structure.txt"

# 2. 각 주요 폴더의 크기
echo "2. 폴더별 크기" > "$OUTPUT_DIR/02_folder_sizes.txt"
du -h -d 1 ~ 2>/dev/null | sort -hr | head -30 >> "$OUTPUT_DIR/02_folder_sizes.txt"

# 3. Documents 폴더 구조
echo "3. Documents 폴더" > "$OUTPUT_DIR/03_documents.txt"
find ~/Documents -maxdepth 3 -type d 2>/dev/null | sort >> "$OUTPUT_DIR/03_documents.txt"

# 4. Downloads 폴더 구조
echo "4. Downloads 폴더" > "$OUTPUT_DIR/04_downloads.txt"
find ~/Downloads -maxdepth 3 -type d 2>/dev/null | sort >> "$OUTPUT_DIR/04_downloads.txt"

# 5. Desktop 폴더 구조
echo "5. Desktop 폴더" > "$OUTPUT_DIR/05_desktop.txt"
find ~/Desktop -maxdepth 3 -type d 2>/dev/null | sort >> "$OUTPUT_DIR/05_desktop.txt"

# 6. Development 폴더 구조
echo "6. Development 폴더" > "$OUTPUT_DIR/06_development.txt"
find ~/Development -maxdepth 3 -type d 2>/dev/null | sort >> "$OUTPUT_DIR/06_development.txt"

# 7. 중복 파일명 찾기 (같은 이름의 파일)
echo "7. 중복 파일명" > "$OUTPUT_DIR/07_duplicate_names.txt"
find ~ -maxdepth 5 -type f 2>/dev/null | 
  awk -F/ '{print $NF}' | 
  sort | uniq -d | head -50 >> "$OUTPUT_DIR/07_duplicate_names.txt"

# 8. 큰 파일 찾기 (100MB 이상)
echo "8. 큰 파일 (100MB+)" > "$OUTPUT_DIR/08_large_files.txt"
find ~ -type f -size +100M 2>/dev/null | 
  xargs ls -lh 2>/dev/null | 
  awk '{print $5, $9}' | 
  sort -hr | head -30 >> "$OUTPUT_DIR/08_large_files.txt"

# 9. 오래된 파일 (1년 이상 미사용)
echo "9. 오래된 파일" > "$OUTPUT_DIR/09_old_files.txt"
find ~ -type f -atime +365 -maxdepth 3 2>/dev/null | 
  head -50 >> "$OUTPUT_DIR/09_old_files.txt"

# 10. 프로젝트 폴더 목록
echo "10. 프로젝트 폴더" > "$OUTPUT_DIR/10_projects.txt"
find ~/Documents ~/Development ~/Downloads -maxdepth 3 -type d \
  -name "*project*" -o -name "*프로젝트*" -o -name "*app*" -o -name "*APP*" \
  2>/dev/null | sort >> "$OUTPUT_DIR/10_projects.txt"

echo ""
echo "✅ 분석 완료!"
echo "결과 위치: $OUTPUT_DIR"
echo ""
echo "생성된 파일:"
ls -lh "$OUTPUT_DIR"
