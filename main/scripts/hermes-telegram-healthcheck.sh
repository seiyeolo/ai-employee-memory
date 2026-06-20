#!/bin/bash
# 헤르메스 텔레그램 polling 헬스체크 v2 (launchd, gateway와 독립 실행)
# 배경: openclaw 2026.6.x의 isolated polling ingress가 망 단절(EHOSTUNREACH) 후
#       재연결을 못 하고 에러도 안 남기는 silent stall이 반복됨. 아웃바운드는 멀쩡해
#       사용자 입장에선 "보낸 답이 안 옴"으로만 보임.
#
# v1 실패 원인(2026-06-19 교체): `openclaw health`의 `telegram:direct:<id> (Nm ago)`
#       라인을 파싱했는데 이 버전 health엔 그 라인이 없어 gap_min이 항상 0 → 영원히 미탐지.
#
# v2 탐지 신호(둘 중 하나라도 stall이면 재시작):
#   (A) 로그: gateway.log에서 'isolated polling ingress' 마지막 라인이 'failed'면 = 죽은 채 방치.
#   (B) API: getWebhookInfo의 pending_update_count >= 1 이 10초 뒤에도 유지 = gateway가 안 빨아감.
#       (getWebhookInfo는 읽기 전용 — getUpdates 롱폴과 충돌(409) 없음)
# 토큰은 런타임에 로컬 config에서만 읽고 로그/외부로 절대 내보내지 않음.

OC=/opt/homebrew/bin/openclaw
CFG="$HOME/.openclaw/openclaw.json"
GWLOG="$HOME/Library/Logs/openclaw/gateway.log"
LOG="$HOME/clawd/scripts/hermes-healthcheck.log"
STATE="$HOME/clawd/scripts/.hermes-healthcheck-restart-ts"
CHAT_ID=307874469
COOLDOWN_MIN=10    # 자동 재시작 최소 간격(분): 폭주 방지

NOW=$(date +%s)
ts() { date '+%Y-%m-%d %H:%M:%S'; }
log() { echo "$(ts) $1" >> "$LOG"; }

get_token() {
  python3 - "$CFG" <<'PY' 2>/dev/null
import json,sys
d=json.load(open(sys.argv[1]))
t=d.get('channels',{}).get('telegram',{})
print(t.get('botToken') or t.get('accounts',{}).get('default',{}).get('botToken') or '')
PY
}

notify() {
  local msg="$1" token
  token=$(get_token)
  [ -n "$token" ] && curl -s --max-time 10 "https://api.telegram.org/bot${token}/sendMessage" \
    --data-urlencode "chat_id=${CHAT_ID}" --data-urlencode "text=${msg}" >/dev/null 2>&1
}

# pending_update_count 조회(읽기 전용). 실패 시 빈 문자열.
pending_count() {
  local token; token=$(get_token)
  [ -z "$token" ] && return 0
  curl -s --max-time 10 "https://api.telegram.org/bot${token}/getWebhookInfo" 2>/dev/null \
    | python3 -c "import json,sys;
try:
    print(json.load(sys.stdin).get('result',{}).get('pending_update_count',''))
except Exception:
    print('')" 2>/dev/null
}

cooldown_ok() {
  local last; last=$(cat "$STATE" 2>/dev/null || echo 0)
  [ $(( (NOW - last) / 60 )) -ge "$COOLDOWN_MIN" ]
}

do_restart() {
  local reason="$1"
  log "[restart] $reason"
  "$OC" gateway restart >/dev/null 2>&1
  echo "$NOW" > "$STATE"
  sleep 12
  if tail -40 "$GWLOG" 2>/dev/null | grep -q "isolated polling ingress started"; then
    log "[restart] polling 재시작 확인됨"
    notify "✅ 헤르메스 텔레그램 polling 자동 복구 완료 — ${reason} ($(ts))"
  else
    log "[restart] polling 재시작 미확인"
    notify "⚠️ 헤르메스 polling 재시작했으나 확인 실패. 수동 점검 필요 ($(ts))"
  fi
}

# --- 층1: gateway 프로세스 liveness ---
if ! pgrep -f "openclaw/dist/index.js gateway" >/dev/null 2>&1; then
  log "[L1] gateway DOWN → start"
  "$OC" gateway start >/dev/null 2>&1
  echo "$NOW" > "$STATE"
  sleep 12
  notify "⚠️ 헤르메스 gateway가 내려가 자동 재시작했습니다 ($(ts))"
  exit 0
fi

# --- 층2A: 로그 기반 — polling ingress가 failed로 끝난 채 방치 ---
last_ingress=$(grep -E "isolated polling ingress (started|failed)" "$GWLOG" 2>/dev/null | tail -1)
if echo "$last_ingress" | grep -q "failed"; then
  if cooldown_ok; then
    do_restart "ingress 마지막 상태=failed (로그 감지)"
    exit 0
  else
    log "[L2A] ingress failed 감지됐으나 cooldown 중 — skip"
    exit 0
  fi
fi

# --- 층2B: API 기반 — pending 적체(사용자가 보낸 메시지를 gateway가 안 빨아감) ---
p1=$(pending_count)
if [ -n "$p1" ] && [ "$p1" -ge 1 ] 2>/dev/null; then
  sleep 10
  p2=$(pending_count)
  if [ -n "$p2" ] && [ "$p2" -ge 1 ] 2>/dev/null; then
    if cooldown_ok; then
      do_restart "pending_update_count 적체 (${p1}→${p2})"
      exit 0
    else
      log "[L2B] pending 적체(${p1}→${p2})지만 cooldown 중 — skip"
      exit 0
    fi
  fi
fi

log "[ok] gateway up, ingress=started, pending=${p1:-na}"
