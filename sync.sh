#!/bin/bash
# AI 직원 기억 + 업무 데이터 동기화 스크립트
# GitHub ↔ 로컬 워크스페이스 양방향 동기화
# 사용법: ./sync.sh (또는 크론으로 자동 실행)

<<<<<<< HEAD
REPO_DIR=~/ai-employee-memory
HOSTNAME=$(hostname -s)
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')
=======
cd ~/PARA/1_Projects/clawd/ai-employee-memory || exit 1
>>>>>>> dd6045b (memory sync from Mac-mini-2 at 2026-03-31 09:01)

cd "$REPO_DIR" || exit 1

# ── 1. GitHub에서 최신 데이터 가져오기 ──
git pull --rebase --quiet 2>/dev/null

# ── 2. 로컬 워크스페이스 → GitHub 리포로 데이터 수집 ──
# 각 부서의 data/, knowledge/, memory/ 동기화

DEPTS="production logistics sales finance content"
for dept in $DEPTS; do
    SRC=~/clawd-${dept}
    DST=${REPO_DIR}/${dept}

    if [ -d "$SRC" ]; then
        # data 폴더
        if [ -d "$SRC/data" ]; then
            mkdir -p "$DST/data"
            rsync -a --delete "$SRC/data/" "$DST/data/" 2>/dev/null
        fi

        # knowledge 폴더
        if [ -d "$SRC/knowledge" ]; then
            mkdir -p "$DST/knowledge"
            rsync -a --delete "$SRC/knowledge/" "$DST/knowledge/" 2>/dev/null
        fi

        # memory 폴더
        if [ -d "$SRC/memory" ] && [ ! -L "$SRC/memory" ]; then
            mkdir -p "$DST/memory"
            rsync -a "$SRC/memory/" "$DST/memory/" 2>/dev/null
        fi

        # AGENTS.md 등 설정 파일
        for f in AGENTS.md IDENTITY.md SOUL.md TOOLS.md MEMORY.md; do
            if [ -f "$SRC/$f" ]; then
                cp "$SRC/$f" "$DST/$f" 2>/dev/null
            fi
        done
    fi
done

# main (공유 워크스페이스)
if [ -d ~/clawd/data ]; then
    mkdir -p "$REPO_DIR/main/data"
    rsync -a --delete ~/clawd/data/ "$REPO_DIR/main/data/" 2>/dev/null
fi
if [ -d ~/clawd/scripts ]; then
    mkdir -p "$REPO_DIR/main/scripts"
    rsync -a --delete ~/clawd/scripts/ "$REPO_DIR/main/scripts/" 2>/dev/null
fi
if [ -d ~/clawd/knowledge ]; then
    mkdir -p "$REPO_DIR/main/knowledge"
    rsync -a ~/clawd/knowledge/ "$REPO_DIR/main/knowledge/" 2>/dev/null
fi

# ── 3. 변경사항 있으면 GitHub에 푸시 ──
if [ -n "$(git status --porcelain)" ]; then
    git add -A
    git commit -m "sync from ${HOSTNAME} at ${TIMESTAMP}" --quiet
    git push --quiet 2>/dev/null
    echo "[sync] ${TIMESTAMP} - 동기화 완료 (${HOSTNAME})"
else
    echo "[sync] ${TIMESTAMP} - 변경 없음"
fi
