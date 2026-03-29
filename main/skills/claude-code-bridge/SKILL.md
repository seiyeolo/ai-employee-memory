---
name: claude-code-bridge
description: "OpenClaw에서 Claude Code를 호출하여 MCP 도구(Chrome DevTools, Playwright 등)가 필요한 고난이도 작업을 위임하는 브릿지 스킬. 사용 시점: (1) 브라우저 자동화 요청 (크롤링, 스마트스토어, SNS), (2) 복잡한 코드 작성/수정, (3) MCP 도구가 필요한 모든 작업. OpenClaw은 MCP stdio 서버를 직접 노출하지 않으므로, Claude Code를 경유해야 한다."
---

# Claude Code Bridge

OpenClaw → Claude Code 호출 브릿지. MCP 도구가 필요한 작업을 Claude Code에 위임한다.

## 왜 필요한가

OpenClaw은 MCP stdio 서버를 에이전트 도구로 직접 노출하지 않는다.
Chrome DevTools MCP, Playwright 등은 Claude Code에서만 작동한다.
따라서 브라우저 자동화, 웹 크롤링 등은 반드시 Claude Code를 경유해야 한다.

```
텔레그램 → OpenClaw(세미에이전트)
    → exec: claude --print "작업 내용"
    → Claude Code가 MCP 도구 사용
    → 결과 반환 → 텔레그램 보고
```

## 호출 조건

아래 키워드가 포함된 요청 시 이 스킬을 활성화한다:

| 트리거 | 예시 |
|--------|------|
| 브라우저/크롤링 | "스마트스토어 확인해줘", "웹사이트 크롤링" |
| SNS 댓글 | "유튜브 댓글 답글 달아줘", "쓰레드 댓글" |
| 경매 검색 | "경매 매물 찾아줘", "법원경매 검색" |
| 스크린샷 | "웹페이지 스크린샷 찍어줘" |
| 복잡한 코딩 | "코드 작성해줘", "리팩토링해줘" |
| 시스템 설정 | "openclaw.json 수정", "크론잡 수정" |

## 호출 방법

### 기본 호출
```bash
exec: /Users/mac/.npm-global/bin/claude --print "작업 내용을 구체적으로 기술" --workspace /Users/mac/clawd
```

### 브라우저 작업 호출 (Chrome DevTools MCP)
```bash
exec: /Users/mac/.npm-global/bin/claude --print "Chrome DevTools MCP를 사용해서 {구체적 작업}. 결과를 마크다운으로 정리해줘." --workspace /Users/mac/clawd
```

### 스마트스토어 크롤링
```bash
exec: /Users/mac/.npm-global/bin/claude --print "Chrome DevTools MCP로 스마트스토어(sell.smartstore.naver.com)에 접속해서 오늘 신규주문, 배송현황, 미답변 문의를 확인하고 보고서 작성해줘." --workspace /Users/mac/clawd
```

### SNS 댓글 답글 (sns-devtools-reply 스킬 연계)
```bash
exec: /Users/mac/.npm-global/bin/claude --print "sns-devtools-reply 스킬을 사용해서 {URL}의 댓글에 답글을 달아줘." --workspace /Users/mac/clawd
```

### 법원경매 검색 (court-auction-scraper 스킬 연계)
```bash
exec: /Users/mac/.npm-global/bin/claude --print "court-auction-scraper 스킬을 사용해서 {지역} {용도} {가격조건} 경매 매물을 검색하고 엑셀로 정리해줘." --workspace /Users/mac/clawd
```

## 결과 처리

1. Claude Code의 출력을 받아서 파이오니어에게 텔레그램으로 보고
2. 파일이 생성된 경우 (엑셀, 스크린샷 등) 파일 경로를 함께 전달
3. 에러 발생 시 에러 내용을 보고하고, 재시도 여부를 파이오니어에게 확인

## 주의사항

- Chrome DevTools MCP는 **현재 열려있는 크롬 브라우저에 직접 붙는다** (로그인 상태 유지)
- 크롬 리모트 디버깅이 켜져 있어야 한다 (`chrome://inspect/#remote-debugging`)
- Claude Code 호출 시 **절대경로** 사용 필수 (`/Users/mac/.npm-global/bin/claude`)
- 한 번에 하나의 Claude Code 세션만 실행 (동시 호출 금지)

## 연계 스킬

| 스킬 | 용도 | Claude Code 경유 필요 |
|------|------|:--:|
| sns-devtools-reply | SNS 댓글 답글 | ✅ (Chrome DevTools MCP) |
| court-auction-scraper | 법원경매 검색 | ✅ (Chrome DevTools MCP) |
| openclaw-harness | Plan→Work→Review | ❌ (OpenClaw 자체 실행) |
| AutoResearchClaw | 연구 파이프라인 | ❌ (CLI 직접 실행) |
