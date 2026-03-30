#!/bin/bash
# 응용 프로그램 자동 정리 스크립트

LOG_FILE="/Users/mac/clawd/folder-cleanup/app_cleanup_log_$(date +%Y%m%d_%H%M%S).txt"

echo "=== 응용 프로그램 자동 정리 시작 ===" | tee -a "$LOG_FILE"
echo "시작 시간: $(date)" | tee -a "$LOG_FILE"
echo "안전 조치: 모든 앱은 휴지통으로 이동 (복구 가능)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

TOTAL_SAVED=0

# 1. Adobe 2025 버전 제거 (2026이 있으므로)
echo "1단계: Adobe 2025 구버전 제거" | tee -a "$LOG_FILE"
ADOBE_2025_APPS=(
  "Adobe Photoshop 2025"
  "Adobe Premiere Pro 2025"
  "Adobe Media Encoder 2025"
  "Adobe Bridge 2025"
  "Adobe InDesign 2025"
  "Adobe Illustrator 2025"
)

for app in "${ADOBE_2025_APPS[@]}"; do
  if [ -d "/Applications/$app" ]; then
    size=$(du -sh "/Applications/$app" 2>/dev/null | awk '{print $1}')
    echo "  이동: $app ($size) → 휴지통" | tee -a "$LOG_FILE"
    trash "/Applications/$app" 2>&1 | tee -a "$LOG_FILE"
  fi
done
echo "" | tee -a "$LOG_FILE"

# 2. 1년 이상 미사용 대용량 앱 (1GB+)
echo "2단계: 1년 이상 미사용 대용량 앱 제거" | tee -a "$LOG_FILE"
OLD_BIG_APPS=(
  "MAXON"
  "Wondershare Filmora Mac.app"
  "Kite.app"
  "mampstack-7.3.17-0"
  "GarageBand.app"
)

for app in "${OLD_BIG_APPS[@]}"; do
  if [ -d "/Applications/$app" ] || [ -e "/Applications/$app" ]; then
    size=$(du -sh "/Applications/$app" 2>/dev/null | awk '{print $1}')
    echo "  이동: $app ($size) → 휴지통" | tee -a "$LOG_FILE"
    trash "/Applications/$app" 2>&1 | tee -a "$LOG_FILE"
  fi
done
echo "" | tee -a "$LOG_FILE"

# 3. 오래된 보안/유틸리티 앱
echo "3단계: 오래된 보안 프로그램 제거" | tee -a "$LOG_FILE"
SECURITY_APPS=(
  "AhnLab"
  "nProtect"
  "SoftForum"
  "TouchEn nxKey"
  "DAmo for PKI"
  "NWS_IPinside"
)

for app in "${SECURITY_APPS[@]}"; do
  if [ -d "/Applications/$app" ] || [ -e "/Applications/$app" ]; then
    size=$(du -sh "/Applications/$app" 2>/dev/null | awk '{print $1}')
    echo "  이동: $app ($size) → 휴지통" | tee -a "$LOG_FILE"
    trash "/Applications/$app" 2>&1 | tee -a "$LOG_FILE"
  fi
done
echo "" | tee -a "$LOG_FILE"

# 4. 오래된 유틸리티/미디어 앱
echo "4단계: 오래된 유틸리티 제거" | tee -a "$LOG_FILE"
OLD_UTILS=(
  "Microsoft Teams classic.app"
  "Parallels Desktop.app"
  "Luminar 4.app"
  "Movavi Video Editor 15.app"
  "VideoProc.app"
  "VideoProc Vlogger.app"
  "VideoProc Converter.app"
  "DeepL.app"
  "Recoverit.app"
  "iMyFone Fixppo.app"
  "aiexe.app"
  "Toonly.app"
  "Maxon Cinema 4D R22"
)

for app in "${OLD_UTILS[@]}"; do
  if [ -d "/Applications/$app" ]; then
    size=$(du -sh "/Applications/$app" 2>/dev/null | awk '{print $1}')
    echo "  이동: $app ($size) → 휴지통" | tee -a "$LOG_FILE"
    trash "/Applications/$app" 2>&1 | tee -a "$LOG_FILE"
  fi
done
echo "" | tee -a "$LOG_FILE"

# 5. Python 중복 버전 (3.12, 3.13 작은 것들)
echo "5단계: Python 중복 버전 정리" | tee -a "$LOG_FILE"
PYTHON_VERS=(
  "Python 3.12"
  "Python 3.13"
)

for app in "${PYTHON_VERS[@]}"; do
  if [ -d "/Applications/$app" ]; then
    size=$(du -sh "/Applications/$app" 2>/dev/null | awk '{print $1}')
    echo "  이동: $app ($size) → 휴지통" | tee -a "$LOG_FILE"
    trash "/Applications/$app" 2>&1 | tee -a "$LOG_FILE"
  fi
done
echo "" | tee -a "$LOG_FILE"

# 6. 최종 결과
echo "=== 정리 완료 ===" | tee -a "$LOG_FILE"
echo "완료 시간: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 현재 Applications 폴더 상태
echo "=== 정리 후 Applications 폴더 ===" | tee -a "$LOG_FILE"
REMAINING_APPS=$(ls -1 /Applications | wc -l | tr -d ' ')
REMAINING_SIZE=$(du -sh /Applications 2>/dev/null | awk '{print $1}')
echo "남은 앱: ${REMAINING_APPS}개" | tee -a "$LOG_FILE"
echo "총 용량: ${REMAINING_SIZE}" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "✅ 모든 앱이 휴지통으로 이동되었습니다!" | tee -a "$LOG_FILE"
echo "복구가 필요하면 휴지통에서 되돌릴 수 있습니다." | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "로그 파일: $LOG_FILE" | tee -a "$LOG_FILE"
