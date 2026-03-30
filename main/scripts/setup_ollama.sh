#!/bin/bash

# Ollama 모델 검사 및 설정 스크립트

# Ollama 서버 실행 확인
echo "Ollama 서버 상태 확인..."
curl -s http://localhost:11434/api/version || {
  echo "Ollama 서버가 실행 중이 아닙니다. 서버를 시작합니다."
  ollama serve &
  sleep 5
}

# 설치된 모델 확인
echo "설치된 Ollama 모델 확인..."
MODELS=$(curl -s http://localhost:11434/api/tags | jq -r '.models[].name')
echo "사용 가능한 모델: $MODELS"

# Clawdbot 설정 업데이트 (1번 방식: 명시적 provider 설정)
echo "Clawdbot 설정 업데이트 (명시적 provider 방식)..."
cat > ~/.clawdbot/clawdbot.json << EOL
{
  "meta": {
    "lastTouchedVersion": "2026.1.24-3",
    "lastTouchedAt": "$(date -u +"%Y-%m-%dT%H:%M:%S.000Z")"
  },
  "wizard": {
    "lastRunAt": "2026-01-26T02:05:28.782Z",
    "lastRunVersion": "2026.1.24-3",
    "lastRunCommand": "onboard",
    "lastRunMode": "local"
  },
  "auth": {
    "profiles": {
      "anthropic:default": {
        "provider": "anthropic",
        "mode": "api_key"
      }
    }
  },
  "models": {
    "providers": {
      "ollama": {
        "baseUrl": "http://localhost:11434/v1",
        "api": "openai-completions",
        "models": [
          {
            "id": "qwen3-vl:32b",
            "name": "Qwen 3 VL 32B",
            "reasoning": false,
            "input": ["text"],
            "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
            "contextWindow": 8192,
            "maxTokens": 8192
          },
          {
            "id": "gpt-oss:20b",
            "name": "GPT-OSS 20B",
            "reasoning": false,
            "input": ["text"],
            "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
            "contextWindow": 8192,
            "maxTokens": 8192
          },
          {
            "id": "llama3:latest",
            "name": "Llama 3",
            "reasoning": false,
            "input": ["text"],
            "cost": { "input": 0, "output": 0, "cacheRead": 0, "cacheWrite": 0 },
            "contextWindow": 8192,
            "maxTokens": 8192
          }
        ]
      }
    }
  },
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-3-7-sonnet-latest"
      },
      "models": {
        "anthropic/claude-3-7-sonnet-latest": {
          "params": {
            "cacheControlTtl": "1h"
          }
        }
      },
      "workspace": "/Users/mac/clawd",
      "contextPruning": {
        "mode": "cache-ttl",
        "ttl": "1h"
      },
      "compaction": {
        "mode": "safeguard"
      },
      "heartbeat": {
        "every": "30m"
      },
      "maxConcurrent": 4,
      "subagents": {
        "maxConcurrent": 8
      }
    }
  },
  "messages": {
    "ackReactionScope": "group-mentions"
  },
  "commands": {
    "native": "auto",
    "nativeSkills": "auto",
    "restart": true
  },
  "hooks": {
    "internal": {
      "enabled": true,
      "entries": {
        "session-memory": {
          "enabled": true
        }
      }
    }
  },
  "channels": {
    "telegram": {
      "enabled": true,
      "dmPolicy": "pairing",
      "botToken": "8246782788:AAHDkjNuvzpMVv6_kuxrTOdcz6adflyV7rU",
      "groupPolicy": "allowlist",
      "streamMode": "partial"
    }
  },
  "gateway": {
    "port": 18789,
    "mode": "local",
    "bind": "loopback",
    "auth": {
      "mode": "token",
      "token": "d873e7fb5b655652b7f54355797833a247aa8f7c52514433"
    },
    "tailscale": {
      "mode": "off",
      "resetOnExit": false
    }
  },
  "skills": {
    "install": {
      "nodeManager": "npm"
    },
    "entries": {
      "nano-banana-pro": {
        "apiKey": "${ANTHROPIC_API_KEY}"
      },
      "coding-agent": {
        "enabled": true
      },
      "notion": {
        "enabled": true
      },
      "nano-pdf": {
        "enabled": true
      }
    }
  },
  "plugins": {
    "entries": {
      "telegram": {
        "enabled": true
      }
    }
  }
}
EOL

# 환경 변수 설정 (launchd 설정)
echo "LaunchAgent에 환경 변수 설정..."
cat > ~/Library/LaunchAgents/com.clawdbot.gateway.plist << EOL
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>com.clawdbot.gateway</string>
    
    <key>Comment</key>
    <string>Clawdbot Gateway (v2026.1.24-3)</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>ProgramArguments</key>
    <array>
      <string>/opt/homebrew/bin/node</string>
      <string>/Users/mac/.npm-global/lib/node_modules/clawdbot/dist/entry.js</string>
      <string>gateway</string>
      <string>--port</string>
      <string>18789</string>
    </array>
    
    <key>StandardOutPath</key>
    <string>/Users/mac/.clawdbot/logs/gateway.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/mac/.clawdbot/logs/gateway.err.log</string>
    <key>EnvironmentVariables</key>
    <dict>
    <key>HOME</key>
    <string>/Users/mac</string>
    <key>PATH</key>
    <string>/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin</string>
    <key>CLAWDBOT_GATEWAY_PORT</key>
    <string>18789</string>
    <key>CLAWDBOT_GATEWAY_TOKEN</key>
    <string>d873e7fb5b655652b7f54355797833a247aa8f7c52514433</string>
    <key>CLAWDBOT_LAUNCHD_LABEL</key>
    <string>com.clawdbot.gateway</string>
    <key>CLAWDBOT_SYSTEMD_UNIT</key>
    <string>clawdbot-gateway.service</string>
    <key>CLAWDBOT_SERVICE_MARKER</key>
    <string>clawdbot</string>
    <key>CLAWDBOT_SERVICE_KIND</key>
    <string>gateway</string>
    <key>CLAWDBOT_SERVICE_VERSION</key>
    <string>2026.1.24-3</string>
    <key>OLLAMA_API_KEY</key>
    <string>ollama-local</string>
    </dict>
  </dict>
</plist>
EOL

# Gateway 재시작
echo "Gateway 재시작..."
launchctl bootout gui/501/com.clawdbot.gateway 2>/dev/null || true
sleep 2
launchctl bootstrap gui/501 ~/Library/LaunchAgents/com.clawdbot.gateway.plist
sleep 5

# 설정 확인
echo "Clawdbot 모델 목록 확인..."
clawdbot models list

echo "설정 완료! Ollama 연결이 성공적으로 설정되었는지 확인하세요."