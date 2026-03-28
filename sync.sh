#!/bin/bash
# AI 직원 기억 동기화 스크립트
# 사용법: ./sync.sh (또는 크론으로 자동 실행)

cd ~/ai-employee-memory || exit 1

# 1. 다른 장비에서 올린 최신 기억 가져오기
git pull --rebase --quiet 2>/dev/null

# 2. 새로 생긴 기억 파일이 있으면 올리기
if [ -n "$(git status --porcelain)" ]; then
    HOSTNAME=$(hostname -s)
    git add -A
    git commit -m "memory sync from ${HOSTNAME} at $(date '+%Y-%m-%d %H:%M')" --quiet
    git push --quiet 2>/dev/null
    echo "[sync] $(date '+%H:%M') - 기억 동기화 완료 (${HOSTNAME})"
else
    echo "[sync] $(date '+%H:%M') - 변경 없음"
fi
