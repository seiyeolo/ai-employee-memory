#!/bin/bash
# 헤르메스 텔레그램 polling 헬스체크 (launchd, gateway와 독립 실행)
# 2026-06-16 작성. 배경: 텔레그램 inbound polling이 에러 없이 조용히 멈추는(silent stall) 반복 이슈.
# 한계: 텔레그램 API 제약(외부 getUpdates=409)으로 polling alive 능동 핑 불가.
#       → gateway 프로세스 다운은 확실 복구, silent stall은 spool 정체 휴리스틱+cooldown으로 추정 재시작.

OC=/opt/homebrew/bin/openclaw
SPOOL="$HOME/.openclaw/telegram/ingress-spool-default"
LOG="$HOME/clawd/scripts/hermes-healthcheck.log"
STATE="$HOME/clawd/scripts/.hermes-healthcheck-restart-ts"
CHAT_ID=307874469
STALL_MIN=180      # spool 정체 임계(분): 3시간 무활동이면 stall 의심
COOLDOWN_MIN=90    # 자동 재시작 최소 간격(분): 폭주 방지

NOW=$(date +%s)
ts() { date '+%Y-%m-%d %H:%M:%S'; }
log() { echo "$(ts) $1" >> "$LOG"; }

notify() {
  # gateway 재시작 직후라 CLI 경로 대신 텔레그램 Bot API 직접 호출(독립). 토큰은 런타임에 config에서 읽음.
  local msg="$1"
  local token
  token=$(python3 -c "import json;print(json.load(open('$HOME/.openclaw/openclaw.json'))['channels']['telegram']['botToken'])" 2>/dev/null)
  [ -n "$token" ] && curl -s --max-time 10 "https://api.telegram.org/bot${token}/sendMessage" \
    --data-urlencode "chat_id=${CHAT_ID}" --data-urlencode "text=${msg}" >/dev/null 2>&1
}

# --- 층1: gateway 프로세스 liveness ---
if ! pgrep -f "openclaw/dist/index.js gateway" >/dev/null 2>&1; then
  log "[L1] gateway DOWN → start"
  "$OC" gateway start >/dev/null 2>&1
  sleep 15
  notify "⚠️ 헤르메스 gateway가 내려가 자동 재시작했습니다.($(ts))"
  echo "$NOW" > "$STATE"
  exit 0
fi

# --- 층2: 텔레그램 polling silent stall 휴리스틱 ---
# gateway health의 텔레그램 세션 마지막 활동 시각(Nm ago)으로 stall 추정.
# (사용자 활동 의존 — 메시지 없으면 gap 증가하므로 임계는 보수적. spool은 처리 후 삭제돼 지표 부적합)
gap_min=$("$OC" health 2>/dev/null | grep -oE "telegram:direct:${CHAT_ID} \([0-9]+m ago\)" | grep -oE '\([0-9]+m' | grep -oE '[0-9]+' | head -1)
[ -z "$gap_min" ] && gap_min=0

last_restart=$(cat "$STATE" 2>/dev/null || echo 0)
since_restart_min=$(( (NOW - last_restart) / 60 ))

if [ "$gap_min" -ge "$STALL_MIN" ] && [ "$since_restart_min" -ge "$COOLDOWN_MIN" ]; then
  log "[L2] polling stall 의심 (spool ${gap_min}분 정체) → gateway restart"
  "$OC" gateway restart >/dev/null 2>&1
  echo "$NOW" > "$STATE"
  sleep 15
  # 복구 확인: polling 재시작 로그
  if "$OC" channels logs 2>/dev/null | grep -q "isolated polling ingress started"; then
    notify "✅ 헤르메스 텔레그램 polling 자동 복구 완료(${gap_min}분 정체 감지 → gateway 재시작).($(ts))"
    log "[L2] restart 후 polling 재시작 확인"
  else
    notify "⚠️ 헤르메스 polling 재시작 시도했으나 확인 실패. 수동 점검 필요.($(ts))"
    log "[L2] restart 후 polling 미확인"
  fi
else
  log "[ok] gateway up, 텔레그램 활동 ${gap_min}분 전, 마지막 재시작 ${since_restart_min}분 전"
fi
