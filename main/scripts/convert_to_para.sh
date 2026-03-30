#!/bin/bash
# 맥미니 폴더 구조를 PARA 시스템으로 재구성

LOG_FILE="/Users/mac/clawd/folder-cleanup/para_conversion_$(date +%Y%m%d_%H%M%S).txt"

echo "=== PARA 시스템으로 재구성 시작 ===" | tee -a "$LOG_FILE"
echo "시작 시간: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 1단계: PARA 폴더 구조 생성
echo "1단계: PARA 폴더 구조 생성" | tee -a "$LOG_FILE"
mkdir -p ~/PARA/1_Projects
mkdir -p ~/PARA/2_Areas/{업무,건강,재무,AI학습}
mkdir -p ~/PARA/3_Resources/{AI,개발,디자인,강의}
mkdir -p ~/PARA/4_Archives

echo "✓ PARA 폴더 생성 완료" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 2단계: Projects - 현재 진행 중인 프로젝트만
echo "2단계: Projects (진행 중인 프로젝트)" | tee -a "$LOG_FILE"

# 퍼티스트 마케팅
if [ -d ~/03_업무/퍼티스트 ]; then
  echo "  이동: 퍼티스트 마케팅 → 1_Projects/" | tee -a "$LOG_FILE"
  mv ~/03_업무/퍼티스트/puttist-marketing ~/PARA/1_Projects/ 2>/dev/null || true
fi

echo "" | tee -a "$LOG_FILE"

# 3단계: Areas - 지속 관리 영역
echo "3단계: Areas (지속 관리 영역)" | tee -a "$LOG_FILE"

# 업무 영역
if [ -d ~/03_업무 ]; then
  echo "  이동: 업무 → 2_Areas/업무/" | tee -a "$LOG_FILE"
  mv ~/03_업무/* ~/PARA/2_Areas/업무/ 2>/dev/null || true
fi

# AI 학습 (진행 중인 것만)
if [ -d ~/04_학습자료 ]; then
  echo "  이동: 학습자료 → 2_Areas/AI학습/" | tee -a "$LOG_FILE"
  mv ~/04_학습자료/* ~/PARA/2_Areas/AI학습/ 2>/dev/null || true
fi

echo "" | tee -a "$LOG_FILE"

# 4단계: Resources - 참고 자료
echo "4단계: Resources (참고 자료)" | tee -a "$LOG_FILE"

# AI 프로젝트 자료
if [ -d ~/01_AI프로젝트 ]; then
  echo "  이동: AI프로젝트 → 3_Resources/AI/" | tee -a "$LOG_FILE"
  mv ~/01_AI프로젝트/* ~/PARA/3_Resources/AI/ 2>/dev/null || true
fi

# 개발 자료
if [ -d ~/02_개발 ]; then
  echo "  이동: 개발 → 3_Resources/개발/" | tee -a "$LOG_FILE"
  mv ~/02_개발/* ~/PARA/3_Resources/개발/ 2>/dev/null || true
fi

echo "" | tee -a "$LOG_FILE"

# 5단계: Archives - 나중에 확인할 것들
echo "5단계: Archives (보관)" | tee -a "$LOG_FILE"

if [ -d ~/나중에_확인 ]; then
  echo "  이동: 나중에_확인 → 4_Archives/" | tee -a "$LOG_FILE"
  mv ~/나중에_확인/* ~/PARA/4_Archives/ 2>/dev/null || true
fi

echo "" | tee -a "$LOG_FILE"

# 6단계: 기존 폴더 정리 (비어있으면 삭제)
echo "6단계: 기존 폴더 정리" | tee -a "$LOG_FILE"

for dir in 00_작업중 01_AI프로젝트 02_개발 03_업무 04_학습자료 나중에_확인; do
  if [ -d ~/"$dir" ]; then
    if [ -z "$(ls -A ~/$dir 2>/dev/null)" ]; then
      echo "  삭제: $dir (비어있음)" | tee -a "$LOG_FILE"
      rmdir ~/"$dir" 2>/dev/null || true
    else
      echo "  유지: $dir (파일 있음 - 수동 확인 필요)" | tee -a "$LOG_FILE"
    fi
  fi
done

echo "" | tee -a "$LOG_FILE"

# 7단계: PARA 구조 확인
echo "=== PARA 구조 완성 ===" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "📁 PARA/" | tee -a "$LOG_FILE"
echo "├── 1_Projects/ ($(find ~/PARA/1_Projects -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')개)" | tee -a "$LOG_FILE"
ls -1 ~/PARA/1_Projects 2>/dev/null | while read item; do
  echo "│   └── $item" | tee -a "$LOG_FILE"
done

echo "├── 2_Areas/ ($(find ~/PARA/2_Areas -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')개)" | tee -a "$LOG_FILE"
ls -1 ~/PARA/2_Areas 2>/dev/null | while read item; do
  echo "│   └── $item" | tee -a "$LOG_FILE"
done

echo "├── 3_Resources/ ($(find ~/PARA/3_Resources -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')개)" | tee -a "$LOG_FILE"
ls -1 ~/PARA/3_Resources 2>/dev/null | while read item; do
  echo "│   └── $item" | tee -a "$LOG_FILE"
done

echo "└── 4_Archives/ ($(find ~/PARA/4_Archives -maxdepth 1 -type d -o -type f 2>/dev/null | wc -l | tr -d ' ')개)" | tee -a "$LOG_FILE"

echo "" | tee -a "$LOG_FILE"
echo "✅ PARA 시스템 구축 완료!" | tee -a "$LOG_FILE"
echo "완료 시간: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "로그 파일: $LOG_FILE" | tee -a "$LOG_FILE"
