#!/bin/bash

# Antigravity 프로세스 모니터링
# 작업 완료 시 Telegram으로 알림

MONITOR_PID=15320
CHECK_INTERVAL=60  # 60초마다 확인

echo "안티그래비티 작업 모니터링 시작 (PID: $MONITOR_PID)"
echo "$(date): 모니터링 시작"

while true; do
    if ! ps -p $MONITOR_PID > /dev/null 2>&1; then
        echo "$(date): 프로세스 종료 감지!"
        
        # OpenClaw를 통해 메시지 전송
        export PATH="/Users/mac/.npm-global/bin:$PATH"
        
        # 완료 메시지 작성
        MESSAGE="✅ 안티그래비티 작업 완료!

시작: 오전 7:12
종료: $(date +'%p %I:%M')
작업 시간: 약 $((($(date +%s) - $(date -j -f "%H:%M" "07:12" +%s)) / 60))분

결과를 확인해주세요!"
        
        # 메시지 전송 (OpenClaw message tool 사용)
        curl -X POST http://127.0.0.1:18789/api/message/send \
          -H "Content-Type: application/json" \
          -d "{\"target\": \"307874469\", \"message\": \"$MESSAGE\"}" \
          > /dev/null 2>&1
        
        echo "완료 알림 전송됨"
        break
    fi
    
    sleep $CHECK_INTERVAL
done

echo "$(date): 모니터링 종료"
