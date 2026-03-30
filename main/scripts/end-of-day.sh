#!/bin/bash
# 퇴근 시 컴퓨터 정리 스크립트

echo "🏃 퇴근 준비 시작..."

# 1. 메모리 많이 쓰는 앱 종료
echo "📱 앱 종료 중..."
killall "Google Chrome" 2>/dev/null && echo "  ✓ Chrome 종료"
killall "Adobe Photoshop 2026" 2>/dev/null && echo "  ✓ Photoshop 종료"
killall "Figma" 2>/dev/null && echo "  ✓ Figma 종료"
# Notion은 필요시 주석 해제
# killall "Notion" 2>/dev/null && echo "  ✓ Notion 종료"

# 2. 슬립 방해 앱 확인 및 종료
echo "😴 슬립 방해 요소 제거 중..."
pkill -f "Antigravity" 2>/dev/null && echo "  ✓ Antigravity 종료"

# 3. 백그라운드 정리
echo "🧹 시스템 정리 중..."
# 임시 파일 정리 (선택사항)
# sudo periodic daily weekly monthly

# 4. 메모리 상태 확인
echo ""
echo "💾 메모리 상태:"
vm_stat | perl -ne '/page size of (\d+)/ and $size=$1; /Pages\s+([^:]+)[^\d]+(\d+)/ and printf("%-16s % 16.2f Mi\n", "$1:", $2 * $size / 1048576);'

# 5. 화면 끄기
echo ""
echo "🖥️  화면 종료..."
sleep 2
pmset displaysleepnow

echo "✅ 퇴근 준비 완료!"
