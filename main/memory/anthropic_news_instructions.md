# Anthropic 뉴스 모니터링 가이드

## 개요
https://www.anthropic.com/news 페이지를 주기적으로 모니터링하여 새로운 뉴스를 확인하고 알림을 받을 수 있는 시스템입니다.

## 모니터링 방법

### 1. 수동 확인 방법
3일에 한 번 또는 원할 때 다음 스크립트를 실행하여 새로운 뉴스 확인:
```bash
cd /Users/mac/clawd
./scripts/check_anthropic_news.sh
```

### 2. 자동 확인 방법 (구현 필요)
일정 주기로 자동 확인이 필요한 경우, 다음과 같이 시스템 캘린더에 등록할 수 있습니다:
- Mac의 캘린더 앱에 3일 간격으로 반복 이벤트 설정
- 알림을 통해 스크립트 실행 필요성 상기

## 파일 설명
- **memory/anthropic_news_latest.md**: 현재 확인된 최신 뉴스 목록
- **memory/anthropic_last_check.txt**: 마지막 확인 날짜
- **scripts/check_anthropic_news.sh**: 뉴스 확인 스크립트
- **scripts/anthropic_news_monitor.sh**: 더 정교한 모니터링 스크립트 (실험적)

## 뉴스 확인 시 작업
1. 스크립트를 실행하여 새로운 뉴스가 있는지 확인
2. 새로운 뉴스 발견 시 내용 확인 및 요약
3. 중요 업데이트의 경우 메모 앱에 "Anthropic 새 소식" 제목으로 저장

## 개선 사항 (향후 구현)
- 자동화된 크론 작업으로 설정
- 텔레그램 또는 이메일을 통한 알림 시스템
- 새로운 뉴스 내용 자동 요약 기능

---
마지막 업데이트: 2026년 1월 27일