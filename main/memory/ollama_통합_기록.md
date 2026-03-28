# Ollama 통합 시도 기록

## 시도 일자: 2026-01-28

### 환경 정보
- Ollama 버전: 0.13.5
- Clawdbot 버전: 2026.1.24-3
- 사용 가능한 Ollama 모델: qwen3-vl:32b, gpt-oss:20b, llama3:latest, llama3.2:latest, qwen3-vl:8b, llama3:8b

### 시도한 방법

#### 1. 환경 변수 설정 (암시적 검색)
```bash
export OLLAMA_API_KEY="ollama-local"
```
- 결과: Ollama 모델이 인식되지 않음
- 가능한 원인: Ollama 모델이 tool support를 보고하지 않음

#### 2. Launch Agent에 환경 변수 추가
```xml
<key>EnvironmentVariables</key>
<dict>
  ...
  <key>OLLAMA_API_KEY</key>
  <string>ollama-local</string>
</dict>
```
- 결과: Ollama 모델이 인식되지 않음

#### 3. 명시적 provider 설정
```json
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
        ...
      ]
    }
  }
}
```
- 결과: 모델이 인식되지 않음

#### 4. auth.profiles 추가 시도
```json
"auth": {
  "profiles": {
    "anthropic:default": {
      "provider": "anthropic",
      "mode": "api_key"
    },
    "ollama:default": {
      "provider": "ollama",
      "mode": "api_key",
      "apiKey": "ollama-local"
    }
  }
}
```
- 결과: 스키마 오류 발생 (apiKey 키가 인식되지 않음)

### 다음 단계
1. Clawdbot 저장소 코드와 더 심층적인 문서 조사
2. 최신 버전의 Ollama 및 Clawdbot으로 업그레이드 고려
3. 해당 주제에 대한 Clawdbot 커뮤니티 검색