#!/bin/bash
# Documents & Downloads 폴더를 PARA로 정리

LOG_FILE="/Users/mac/clawd/folder-cleanup/docs_downloads_cleanup_$(date +%Y%m%d_%H%M%S).txt"

echo "=== Documents & Downloads → PARA 정리 시작 ===" | tee -a "$LOG_FILE"
echo "시작 시간: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 1단계: Downloads → PARA
echo "1단계: Downloads 폴더 정리" | tee -a "$LOG_FILE"

# 인공지능 → Resources/AI
if [ -d ~/Downloads/인공지능 ]; then
  echo "  이동: 인공지능 → PARA/3_Resources/AI/" | tee -a "$LOG_FILE"
  mv ~/Downloads/인공지능 ~/PARA/3_Resources/AI/ 2>&1 | tee -a "$LOG_FILE"
fi

# 퍼티스트 → Projects (진행 중인 프로젝트)
if [ -d ~/Downloads/퍼티스트 ]; then
  echo "  이동: 퍼티스트 → PARA/1_Projects/" | tee -a "$LOG_FILE"
  mv ~/Downloads/퍼티스트 ~/PARA/1_Projects/ 2>&1 | tee -a "$LOG_FILE"
fi

# 까망이 → 확인 필요, 일단 Archives
if [ -d ~/Downloads/까망이 ]; then
  echo "  이동: 까망이 → PARA/4_Archives/ (확인 필요)" | tee -a "$LOG_FILE"
  mv ~/Downloads/까망이 ~/PARA/4_Archives/ 2>&1 | tee -a "$LOG_FILE"
fi

# 창작 스토리 → Resources
if [ -d "~/Downloads/창작 스토리 json" ]; then
  echo "  이동: 창작 스토리 json → PARA/3_Resources/" | tee -a "$LOG_FILE"
  mv ~/Downloads/"창작 스토리 json" ~/PARA/3_Resources/ 2>&1 | tee -a "$LOG_FILE"
fi

# K디지털마케팅 → Areas/AI학습
if [ -d ~/Downloads/K디지털마케팅 ]; then
  echo "  이동: K디지털마케팅 → PARA/2_Areas/AI학습/" | tee -a "$LOG_FILE"
  mv ~/Downloads/K디지털마케팅 ~/PARA/2_Areas/AI학습/ 2>&1 | tee -a "$LOG_FILE"
fi

# pdf-ai-tools → Resources/AI
if [ -d ~/Downloads/pdf-ai-tools ]; then
  echo "  이동: pdf-ai-tools → PARA/3_Resources/AI/" | tee -a "$LOG_FILE"
  mv ~/Downloads/pdf-ai-tools ~/PARA/3_Resources/AI/ 2>&1 | tee -a "$LOG_FILE"
fi

# 유튜브작업 → Projects
if [ -d ~/Downloads/유튜브작업.fcpbundle ]; then
  echo "  이동: 유튜브작업 → PARA/1_Projects/" | tee -a "$LOG_FILE"
  mv ~/Downloads/유튜브작업.fcpbundle ~/PARA/1_Projects/ 2>&1 | tee -a "$LOG_FILE"
fi

# 정리된 폴더들 → Archives
for dir in _Archive _Organized _유형별정리; do
  if [ -d ~/Downloads/"$dir" ]; then
    echo "  이동: $dir → PARA/4_Archives/" | tee -a "$LOG_FILE"
    mv ~/Downloads/"$dir" ~/PARA/4_Archives/ 2>&1 | tee -a "$LOG_FILE"
  fi
done

# Bookscan, 글꼴 → Resources
if [ -d ~/Downloads/Bookscan ]; then
  echo "  이동: Bookscan → PARA/3_Resources/" | tee -a "$LOG_FILE"
  mv ~/Downloads/Bookscan ~/PARA/3_Resources/ 2>&1 | tee -a "$LOG_FILE"
fi

if [ -d ~/Downloads/글꼴 ]; then
  echo "  이동: 글꼴 → PARA/3_Resources/디자인/" | tee -a "$LOG_FILE"
  mv ~/Downloads/글꼴 ~/PARA/3_Resources/디자인/ 2>&1 | tee -a "$LOG_FILE"
fi

# 지침 → Resources
if [ -d ~/Downloads/지침 ]; then
  echo "  이동: 지침 → PARA/3_Resources/" | tee -a "$LOG_FILE"
  mv ~/Downloads/지침 ~/PARA/3_Resources/ 2>&1 | tee -a "$LOG_FILE"
fi

# 김영진 → Archives
if [ -d ~/Downloads/김영진 ]; then
  echo "  이동: 김영진 → PARA/4_Archives/" | tee -a "$LOG_FILE"
  mv ~/Downloads/김영진 ~/PARA/4_Archives/ 2>&1 | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"

# 2단계: Documents → PARA
echo "2단계: Documents 폴더 정리" | tee -a "$LOG_FILE"

# kmy → Areas/업무
if [ -d ~/Documents/kmy ]; then
  echo "  이동: kmy → PARA/2_Areas/업무/" | tee -a "$LOG_FILE"
  # 이미 파크골프 폴더가 있을 수 있으므로 병합
  mkdir -p ~/PARA/2_Areas/업무/kmy 2>/dev/null
  mv ~/Documents/kmy/* ~/PARA/2_Areas/업무/kmy/ 2>&1 | tee -a "$LOG_FILE"
  rmdir ~/Documents/kmy 2>/dev/null || true
fi

# AI 강의자료 → Areas/AI학습
if [ -d ~/Documents/AI_공문서_강의자료 ]; then
  echo "  이동: AI_공문서_강의자료 → PARA/2_Areas/AI학습/" | tee -a "$LOG_FILE"
  mv ~/Documents/AI_공문서_강의자료 ~/PARA/2_Areas/AI학습/ 2>&1 | tee -a "$LOG_FILE"
fi

# aifi → Resources/AI
if [ -d ~/Documents/aifi ]; then
  echo "  이동: aifi → PARA/3_Resources/AI/" | tee -a "$LOG_FILE"
  mv ~/Documents/aifi ~/PARA/3_Resources/AI/ 2>&1 | tee -a "$LOG_FILE"
fi

# Cline → Resources/개발
if [ -d ~/Documents/Cline ]; then
  echo "  이동: Cline → PARA/3_Resources/개발/" | tee -a "$LOG_FILE"
  mv ~/Documents/Cline ~/PARA/3_Resources/개발/ 2>&1 | tee -a "$LOG_FILE"
fi

# Alfred 가이드 문서들 → Resources
for file in ~/Documents/Alfred*.md ~/Documents/macOS*.md; do
  if [ -f "$file" ]; then
    filename=$(basename "$file")
    echo "  이동: $filename → PARA/3_Resources/" | tee -a "$LOG_FILE"
    mv "$file" ~/PARA/3_Resources/ 2>&1 | tee -a "$LOG_FILE"
  fi
done

# n8n_backup_old → Archives
if [ -d ~/Documents/n8n_backup_old ]; then
  echo "  이동: n8n_backup_old → PARA/4_Archives/" | tee -a "$LOG_FILE"
  mv ~/Documents/n8n_backup_old ~/PARA/4_Archives/ 2>&1 | tee -a "$LOG_FILE"
fi

# $RECYCLE.BIN → 삭제
if [ -d ~/Documents/'$RECYCLE.BIN' ]; then
  echo "  삭제: \$RECYCLE.BIN (휴지통)" | tee -a "$LOG_FILE"
  rm -rf ~/Documents/'$RECYCLE.BIN' 2>&1 | tee -a "$LOG_FILE"
fi

echo "" | tee -a "$LOG_FILE"

# 3단계: 결과 확인
echo "=== 정리 완료 ===" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "Documents 폴더:" | tee -a "$LOG_FILE"
echo "  용량: $(du -sh ~/Documents 2>/dev/null | awk '{print $1}')" | tee -a "$LOG_FILE"
echo "  항목: $(ls -1 ~/Documents 2>/dev/null | wc -l | tr -d ' ')개" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "Downloads 폴더:" | tee -a "$LOG_FILE"
echo "  용량: $(du -sh ~/Downloads 2>/dev/null | awk '{print $1}')" | tee -a "$LOG_FILE"
echo "  항목: $(ls -1 ~/Downloads 2>/dev/null | wc -l | tr -d ' ')개" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "PARA 구조:" | tee -a "$LOG_FILE"
echo "  1_Projects: $(find ~/PARA/1_Projects -maxdepth 1 2>/dev/null | wc -l | tr -d ' ')개" | tee -a "$LOG_FILE"
echo "  2_Areas: $(find ~/PARA/2_Areas -maxdepth 2 -type d 2>/dev/null | wc -l | tr -d ' ')개" | tee -a "$LOG_FILE"
echo "  3_Resources: $(find ~/PARA/3_Resources -maxdepth 2 -type d 2>/dev/null | wc -l | tr -d ' ')개" | tee -a "$LOG_FILE"
echo "  4_Archives: $(find ~/PARA/4_Archives -maxdepth 1 2>/dev/null | wc -l | tr -d ' ')개" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "✅ Documents & Downloads → PARA 정리 완료!" | tee -a "$LOG_FILE"
echo "완료 시간: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "로그 파일: $LOG_FILE" | tee -a "$LOG_FILE"
