# MEMORY.md - 오케스트레이터(세미에이전트) 장기 기억

## 설정 이력
- 2026-03-29: (주)퍼티스트 AI 조직 생성 (5부서: 생산/물류/영업/콘텐츠/재무인사)
- 2026-03-30: Mac-mini-2 자동 sync 파이프라인 구축, API 키 노출 수정
- 2026-03-31: gstack 스킬 라우팅 규칙 CLAUDE.md에 추가
- 2026-04-01: Paperclip+OpenClaw 베스트 프랙티스 학습, Retrieve-before-act 규칙 도입

## 조직 현황
- Paperclip(회사) + OpenClaw(직원) + NemoClaw(보안관) 3단 구조
- 5개 부서장 에이전트 활성화: production, logistics, sales, content, finance
- 메인 모델: Claude Opus 4.6 (CEO/오케스트레이터용)
- 실무 모델: GLM-5, GPT-5.4, Codex 등 (부서장용 - 비용 최적화 필요)

## 파이오니어(오세열) 핵심 정보
- 학습 스타일: 실행 먼저, 이해 나중. 역할 비유로 설명하면 잘 이해함
- 오픈클로 스쿨 수강 중 (4차시까지 완료, 토요일마다 강의)
- 4/5(토) 알바봇 마켓에 퍼티스트 AI 에이전트 첫 등록 시도 예정

## 운영 원칙 (학습에서 도출)
1. **Retrieve-before-act**: 행동 전 반드시 메모리 먼저 검색
2. **파일에 기록**: 채팅이 아닌 파일에 규칙 기록 (압축 시 소실 방지)
3. **단일 채널 시작**: 새 기능 추가 시 하나씩 검증 후 확장
4. **스킬 재사용**: 반복 작업은 SKILL.md로 문서화

## 부서별 데이터 접근 경로
| 부서 | 핵심 데이터 |
|------|------------|
| 생산관리 | `/Users/mac/clawd-production/data/재고현황.md` |
| 물류 | `/Users/mac/clawd-logistics/data/발송체크리스트.md` |
| 영업 | `/Users/mac/clawd-sales/data/거래처현황.md` |
| 콘텐츠 | `/Users/mac/clawd-content/data/콘텐츠캘린더.md` |
| 재무인사 | `/Users/mac/clawd-finance/knowledge/법인관리_체크리스트.md` |

## 미해결 과제
- 재무/인사 데이터: 대표가 독점 관리 중, 시스템 먼저 구축 후 요구하는 전략
- 모델 라우팅: 부서장별 저비용 모델 배정 아직 미완료
- 인박스 워크플로우: Paperclip 인박스 기반 결재 시스템 아직 미활용
- 예산 한도: 에이전트별 월간 토큰 예산 미설정
