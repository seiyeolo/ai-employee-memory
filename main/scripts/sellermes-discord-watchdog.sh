#!/bin/zsh
set -u

PATH="/opt/homebrew/bin:/Users/mac/.hermes/node/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

OPENCLAW_BIN="${OPENCLAW_BIN:-/opt/homebrew/bin/openclaw}"
NODE_BIN="${NODE_BIN:-/Users/mac/.hermes/node/bin/node}"
LOG_DIR="${LOG_DIR:-/Users/mac/.openclaw/runtime}"
LOG_FILE="$LOG_DIR/sellermes-discord-watchdog.log"
COOLDOWN_FILE="$LOG_DIR/sellermes-discord-watchdog.last-restart"
STATUS_FILE="$LOG_DIR/sellermes-discord-watchdog.status.json"

mkdir -p "$LOG_DIR"

log() {
  print -r -- "$(date '+%Y-%m-%dT%H:%M:%S%z') $*" >> "$LOG_FILE"
}

status_raw="$("$OPENCLAW_BIN" channels status --json 2>&1)"
status_exit=$?
json_payload="$(print -r -- "$status_raw" | sed -n '/^{/,$p')"

if [[ $status_exit -ne 0 || -z "$json_payload" ]]; then
  log "status_failed exit=$status_exit"
  exit 1
fi

print -r -- "$json_payload" > "$STATUS_FILE"

missing="$("$NODE_BIN" - "$STATUS_FILE" <<'NODE'
const fs = require("fs");
const statusPath = process.argv[2];
const required = ["minho", "nayeon", "junho", "jinsu", "yumin", "sora", "haeun", "jia", "doyun"];
const data = JSON.parse(fs.readFileSync(statusPath, "utf8"));
const accounts = data.channelAccounts?.discord || [];
const byId = new Map(accounts.map((account) => [account.accountId, account]));
const missing = required.filter((id) => {
  const account = byId.get(id);
  return !account || !account.enabled || !account.configured || !account.running || !account.connected;
});
process.stdout.write(missing.join(" "));
NODE
)"

if [[ -z "$missing" ]]; then
  log "ok all_sellermes_connected"
  exit 0
fi

now="$(date +%s)"
last_restart="0"
if [[ -f "$COOLDOWN_FILE" ]]; then
  last_restart="$(cat "$COOLDOWN_FILE" 2>/dev/null || print 0)"
fi

elapsed=$(( now - last_restart ))
if (( elapsed < 600 )); then
  log "missing=$missing restart_skipped cooldown_elapsed=${elapsed}s"
  exit 2
fi

log "missing=$missing restarting_gateway"
print -r -- "$now" > "$COOLDOWN_FILE"
"$OPENCLAW_BIN" gateway restart >> "$LOG_FILE" 2>&1
restart_exit=$?
log "restart_exit=$restart_exit"
exit "$restart_exit"
