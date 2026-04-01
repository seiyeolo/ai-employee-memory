#!/bin/bash
# 셀러드 작업 환경 복원 스크립트
# 사용법: source ~/PARA/1_Projects/ai-employee-memory/scripts/restore_session.sh

echo "🟢 셀러드 작업 환경 복원 중..."

# 1. 작업 디렉토리
cd /Users/mac/PARA/1_Projects/ai-employee-memory

# 2. OpenClaw + Paperclip 상태 확인
echo "--- OpenClaw ---"
curl -s http://localhost:18789/health 2>/dev/null && echo " ✅ OpenClaw 실행 중" || echo " ❌ OpenClaw 꺼져있음 → openclaw gateway start"

echo "--- Paperclip ---"
curl -s http://localhost:3100/api/health 2>/dev/null | python3 -c "import sys,json; print(' ✅ Paperclip 실행 중')" 2>/dev/null || echo " ❌ Paperclip 꺼져있음"

# 3. OpenClaw 스킬 확인
echo "--- 셀러 에이전트 스킬 ---"
/Users/mac/.npm-global/bin/openclaw skills list --eligible 2>&1 | grep "seller" | wc -l | xargs -I{} echo " ✅ {} 개 셀러 스킬 등록됨"

# 4. Git 상태
echo "--- Git ---"
echo " Branch: $(git branch --show-current)"
echo " Status: $(git status --short | wc -l | xargs -I{} echo '{}개 변경사항')"

# 5. 핵심 URL
echo ""
echo "=== 셀러드 핵심 링크 ==="
echo " 🌐 랜딩페이지: https://sellerd.netlify.app"
echo " 📊 Netlify: https://app.netlify.com/projects/sellerd"
echo " 🐙 GitHub: https://github.com/seiyeolo/ai-employee-memory"
echo " 📓 NotebookLM: https://notebooklm.google.com/notebook/536460a4-118d-4e76-b493-457e1344fdea"
echo ""
echo "=== 오늘 할 일 ==="
echo " □ 상표 출원 (특허로, 138,000원)"
echo " □ 유튜브 영상 편집 + 업로드"
echo " □ 토요일(4/5) 알바봇 등록"
echo ""
echo "🟢 복원 완료. 작업 시작하세요!"
