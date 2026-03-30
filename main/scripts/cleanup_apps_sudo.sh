#!/bin/bash
# sudo 권한으로 앱 삭제

echo "=== sudo 권한으로 앱 삭제 시작 ==="

# 삭제할 앱 목록 (권한 문제로 실패했던 앱들)
APPS_TO_DELETE=(
  "Adobe Photoshop 2025"
  "Adobe Bridge 2025"
  "Adobe Illustrator 2025"
  "GarageBand.app"
  "AhnLab"
  "nProtect"
  "SoftForum"
  "DAmo for PKI"
  "Microsoft Teams classic.app"
  "Parallels Desktop.app"
  "Movavi Video Editor 15.app"
  "Maxon Cinema 4D R22"
  "Python 3.12"
  "Python 3.13"
)

for app in "${APPS_TO_DELETE[@]}"; do
  if [ -d "/Applications/$app" ] || [ -e "/Applications/$app" ]; then
    size=$(du -sh "/Applications/$app" 2>/dev/null | awk '{print $1}')
    echo "삭제 중: $app ($size)"
    sudo rm -rf "/Applications/$app"
    echo "  ✓ 삭제 완료"
  fi
done

echo ""
echo "=== 최종 결과 ==="
echo "남은 앱: $(ls -1 /Applications | wc -l)개"
echo "총 용량: $(du -sh /Applications 2>/dev/null | awk '{print $1}')"
