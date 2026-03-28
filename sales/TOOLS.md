# TOOLS.md - 영업마케팅부 로컬 설정

## Google Sheets - A/S 관리 시스템

### A/S 데이터 접근
- **스프레드시트:** 구글시스템(서비스)
- **CSV 다운로드 (AS관리 시트):**
  ```
  curl -s -L 'https://docs.google.com/spreadsheets/d/1-4OYASJWt1k1wlM9ghlmIAUhaTf0FA-gl7XvU_sgjSI/export?format=csv&gid=835210099'
  ```
- **CSV 다운로드 (고객정보 시트):**
  ```
  curl -s -L 'https://docs.google.com/spreadsheets/d/1-4OYASJWt1k1wlM9ghlmIAUhaTf0FA-gl7XvU_sgjSI/export?format=csv&gid=0'
  ```

### AS관리 시트 컬럼 (A~P)
| 열 | 헤더 | 비고 |
|----|------|------|
| A | AS번호 | AS250901-620 / REQ-20260323-1605 형식 |
| B | 접수일시 | |
| C | 고객명 | |
| D | 연락처 | |
| E | 이메일 | |
| F | 주소 | |
| G | 제품 | 퍼티스트 II 고급형 등 |
| H | 모델명 | |
| I | 문제설명 | 고객 작성 증상 |
| J | 상태 | 드롭다운: 완료/접수완료/배송중/담당자배정/취소 |
| K | 담당자 | |
| L | 처리일시 | |
| M | 처리내용 | 수리/맞교환 등 |
| N | 비용 | |
| O | 구입일 | |
| P | 수리유형 | 유상/무상 |

### 고객 A/S 접수 폼
- **접수 URL:** https://buly.kr/5UJQodF
- 고객에게 전화번호로 폼 링크를 발송하면 고객이 직접 작성
- Google Apps Script로 자동 기록

## 스마트스토어
- **판매자센터:** https://sell.smartstore.naver.com/#/home/dashboard
- **판매 스토어:** https://smartstore.naver.com/3puttkiller

## 고객서비스
- **A/S 관리자:** https://buly.kr/9iGYb86

## SNS
- BAND: https://band.us/@putt
- Facebook: https://www.facebook.com/Theeasiestgreen
- YouTube: https://www.youtube.com/channel/UCd87qn1SxtvGNSCX-HYrlUQ
- Twitter(X): @oseyeol350
