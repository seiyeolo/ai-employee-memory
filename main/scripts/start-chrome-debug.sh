#!/bin/bash
# OpenClaw용 Chrome 원격 디버깅 자동 시작 스크립트
# 로그인 시 LaunchAgent가 이 스크립트를 실행

CHROME="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
# 기존 Chrome 프로필 사용 → 기존 로그인 그대로 유지
PROFILE_DIR="$HOME/Library/Application Support/Google/Chrome"
PORT=9222

# 이미 실행 중이면 스킵
if curl -s http://localhost:$PORT/json/version > /dev/null 2>&1; then
  echo "Chrome 이미 실행 중 (포트 $PORT)"
  exit 0
fi

# Chrome 원격 디버깅 모드로 시작
nohup "$CHROME" \
  --remote-debugging-port=$PORT \
  --user-data-dir="$PROFILE_DIR" \
  --no-first-run \
  --no-default-browser-check \
  --window-size=1280,900 \
  --lang=ko-KR \
  > /tmp/clawd-chrome.log 2>&1 &

disown
echo "Chrome 디버깅 모드 시작 (포트 $PORT, PID: $!)"
