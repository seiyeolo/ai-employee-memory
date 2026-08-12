# ai-employee-memory
AI 직원 장기 기억 저장소

## (주)퍼티스트 AI 조직

```
세미에이전트 (main) — 오케스트레이터
├── 생산관리부장 (production) — 재고/생산/입고
├── 물류부장 (logistics) — 택배/출고/납품
├── 영업마케팅부장 (sales) — 거래처/견적/마케팅/CS/AS
├── 콘텐츠부장 (content) — 콘텐츠 기획/제작/시장 모니터링
├── 재무인사부장 (finance) — 재무/인사/경영관리
└── 디자인부장 (design) — 브랜드/제품/화면/인쇄물 디자인
```

## 폴더 구조

```
main/memory/          — 오케스트레이터 장기 기억
production/memory/    — 생산관리부 장기 기억
logistics/memory/     — 물류부 장기 기억
sales/memory/         — 영업마케팅부 장기 기억
content/memory/       — 콘텐츠부 장기 기억
finance/memory/       — 재무인사부 장기 기억
design/memory/        — 디자인부 장기 기억
```

각 부서 폴더 구성은 동일합니다.

```
{부서}/
├── IDENTITY.md   — 나는 누구인가
├── SOUL.md       — 어떻게 일하는가
├── AGENTS.md     — 업무 범위, 보고 규칙, 데이터 책임
├── MEMORY.md     — 장기 기억
├── TOOLS.md      — 환경별 도구 메모
├── knowledge/    — 참조 지식 (규정, 가이드, 제품 지식)
├── data/         — 원본 데이터
└── memory/       — 일일 기록 (YYYY-MM-DD.md)
```

## 사용법
각 에이전트가 세션 중 학습한 중요 사항을 기록하고, 다음 세션에서 참조합니다.
기억 파일은 YYYY-MM-DD.md 형식으로 일일 기록하고, MEMORY.md에 장기 요약을 유지합니다.

---
설정일: 2026-03-28
