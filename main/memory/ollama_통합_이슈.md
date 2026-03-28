# Ollama 통합 이슈 및 해결 시도

## 문제 확인
파이오니어님이 요청하신 Ollama 로컬 API를 Clawdbot에 연결하는 작업에서 여러 이슈가 발생하고 있습니다.

## 주요 문제점

1. **자동 모델 탐지 실패**: Ollama API 키를 설정해도 Clawdbot이 Ollama 모델을 자동으로 인식하지 못함
   - 가능한 원인: Ollama 모델들이 tool support를 보고하지 않음
   
2. **명시적 설정 스키마 불일치**: 문서에 제시된 명시적 설정 방식이 실제 스키마와 맞지 않음
   - 문서상 제시된 `models.providers.ollama` 형식이 실제 스키마와 다름
   
3. **환경 변수 전달 문제**: LaunchAgent를 통해 실행되는 Clawdbot에 환경 변수가 제대로 전달되지 않음

## 시도한 해결책

1. 환경 변수 방식 (암시적 검색)
   ```bash
   export OLLAMA_API_KEY="ollama-local"
   ```

2. LaunchAgent의 환경 변수 설정
   ```xml
   <key>OLLAMA_API_KEY</key>
   <string>ollama-local</string>
   ```
   
3. 명시적 Provider 설정 (모델 직접 정의)
   ```json
   "models": {
     "providers": {
       "ollama": {
         "baseUrl": "http://localhost:11434/v1",
         "api": "openai-completions",
         "models": [...]
       }
     }
   }
   ```

4. auth.profiles에 ollama 설정 추가
   ```json
   "ollama:default": {
     "provider": "ollama",
     "mode": "api_key",
     "apiKey": "ollama-local"
   }
   ```

5. 스크립트를 통한 자동화 시도 (/Users/mac/clawd/scripts/setup_ollama.sh)
   - 모든 설정을 자동으로 구성하고 재시작

## 현재 상태
- 모든 시도 후에도 `clawdbot models list`에서 Ollama 모델이 표시되지 않음
- Clawdbot이 여전히 anthropic/claude-3-7-sonnet-latest만 인식함

## 다음 단계

1. 더 깊은 조사를 위해 Clawdbot 소스 코드 분석
2. Clawdbot 커뮤니티 포럼에 문의
3. 최신 버전 업그레이드 검토
4. 다른 통합 방식 탐색 (예: 프록시 서버)

## 업데이트 (2026-01-28)
- 현재 Ollama는 잘 작동 중 (버전 0.13.5)
- Clawdbot 설정은 유효하지만 Ollama 모델은 인식되지 않음
- 모든 설정 시도는 `/Users/mac/clawd/scripts/setup_ollama.sh`에 문서화됨