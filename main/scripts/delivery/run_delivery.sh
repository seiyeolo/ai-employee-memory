#!/bin/bash
# ================================================================
# 퍼티스트 배송처리 자동화 (스마트스토어 → ALPS 롯데택배)
# 텔레그램: "배송처리 시작" or "배송처리 [스마트스토어비밀번호]"
# ================================================================
set -e
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
VENV="$DIR/venv/bin/python3"
DL_DIR="$HOME/clawd/data/delivery"
LOG_DIR="$HOME/clawd/logs"
LOG="$LOG_DIR/delivery_$(date +%Y%m%d_%H%M%S).log"

mkdir -p "$DL_DIR" "$LOG_DIR"

log()  { echo "[$(date '+%H:%M:%S')] $1" | tee -a "$LOG"; }
fail() { log "❌ $1"; echo "FAIL:$1"; exit 1; }

SS_PW="${1:-}"
[ -z "$SS_PW" ] && fail "스마트스토어 Excel 비밀번호 필요. 사용법: run_delivery.sh [비밀번호]"

log "=============================="
log "🚀 배송처리 자동화 시작"
log "=============================="

# ── 1. Chrome 확인 ──────────────────────────────────────────
log ""
log "[1/4] Chrome 연결 확인..."
if ! curl -s --max-time 3 http://127.0.0.1:9222/json/version >/dev/null 2>&1; then
    log "  Chrome 재시작 중..."
    bash "$HOME/bin/chrome-debug.sh" >> "$LOG" 2>&1
    sleep 5
    curl -s --max-time 5 http://127.0.0.1:9222/json/version >/dev/null 2>&1 || fail "Chrome 시작 실패"
fi
log "  ✅ Chrome OK"

# ── 2. 스마트스토어 Excel 다운로드 ──────────────────────────
log ""
log "[2/4] 스마트스토어 주문 다운로드..."
SS_FILE=$("$VENV" "$DIR/browser_automation.py" download "$SS_PW" 2>&1 | tee -a "$LOG" | grep "^결과 파일:" | awk '{print $NF}')

# fallback: 가장 최근 파일
[ -z "$SS_FILE" ] && SS_FILE=$(ls -t "$DL_DIR"/*.xlsx 2>/dev/null | head -1)
[ -z "$SS_FILE" ] || [ ! -f "$SS_FILE" ] && fail "스마트스토어 다운로드 실패"
log "  ✅ 다운로드: $(basename "$SS_FILE")"

# ── 3. ALPS 형식 변환 ───────────────────────────────────────
log ""
log "[3/4] ALPS 업로드 형식 변환..."
ALPS_FILE=$("$VENV" "$DIR/convert_to_lotte.py" "$SS_FILE" "$SS_PW" 2>&1 | tee -a "$LOG" | grep "^출력 파일:" | awk '{print $NF}')

[ -z "$ALPS_FILE" ] && ALPS_FILE=$(ls -t "$DL_DIR"/ALPS_업로드_*.xlsx 2>/dev/null | head -1)
[ -z "$ALPS_FILE" ] || [ ! -f "$ALPS_FILE" ] && fail "형식 변환 실패"
log "  ✅ 변환: $(basename "$ALPS_FILE")"

# ── 4. ALPS 업로드 ──────────────────────────────────────────
log ""
log "[4/4] ALPS(롯데택배) 운송장 업로드..."
"$VENV" "$DIR/alps_automation.py" upload "$ALPS_FILE" 2>&1 | tee -a "$LOG"

# ── 완료 ────────────────────────────────────────────────────
COUNT=$("$VENV" -c "import pandas as pd; print(len(pd.read_excel('$ALPS_FILE')))" 2>/dev/null || echo "?")
log ""
log "=============================="
log "✅ 배송처리 완료"
log "   처리 건수 : ${COUNT}건"
log "   원본 파일 : $(basename "$SS_FILE")"
log "   업로드 파일: $(basename "$ALPS_FILE")"
log "   로그      : $LOG"
log "=============================="

# OpenClaw가 텔레그램 보고에 사용할 출력
echo "DELIVERY_OK:${COUNT}건|$(basename "$ALPS_FILE")|$DL_DIR"
