# TOOLS.md - Local Notes

Skills define *how* tools work. This file is for *your* specifics — the stuff that's unique to your setup.

## What Goes Here

Things like:
- Camera names and locations
- SSH hosts and aliases  
- Preferred voices for TTS
- Speaker/room names
- Device nicknames
- Anything environment-specific

## Examples

```markdown
### Cameras
- living-room → Main area, 180° wide angle
- front-door → Entrance, motion-triggered

### SSH
- home-server → 192.168.1.100, user: admin

### TTS
- Preferred voice: "Nova" (warm, slightly British)
- Default speaker: Kitchen HomePod
```

## Why Separate?

Skills are shared. Your setup is yours. Keeping them apart means you can update skills without losing your notes, and share skills without leaking your infrastructure.

## 제품 정보

### 제품 분류 체계
- **문서 위치**: `/Users/mac/clawd/제품분류체계.md`
- **본체 구분**: 고급형 / 일반형
- **일본형**: 배터리/레이저 조합 4가지 타입
- **참고**: 생산/포장 시 사양 확인 필요

### 스티커 재고
- **고급형 스티커**: 10,000장 (2026-03-04 기준)
- **주간 생산량**: 200대/주 기준
- **예상 소진일**: 2027-02-18 (약 11.5개월)
- **재주문 알림**: 2027-01-19 (1개월 전)
- **제조사**: 고급형 스티커 제조사 (택배 송장 참조)

## 택배 시스템

### 택배 발송 파일 경로
- **경로**: `/Users/mac/Library/Mobile Documents/com~apple~CloudDocs/퍼티스트/05_운영_관리/택배시스템/택배시스템/202603/택배/`
- **파일 형식**: `(주)퍼티스트_택배시스템(기본형식)_YYYY_MM_DD.xlsx`
- **자동 집계**: 매일 오후 3시 30분
- **용도**: 일일 발송량 자동 집계

### 중요 사항
- **파일 생성 원칙**: 매일 파일이 생성됨
- **발송 없는 날**: 택배 발송이 없는 날도 있음
- **처리 방법**: 파일이 없거나 발송 건수가 0이면 "발송 없음"으로 기록

## 소셜 미디어 / 연락처

### 대표 연락처
- **이메일**: seiyeolo@gmail.com
- **Twitter(X)**: @oseyeol350

## 고객 서비스

### 퍼티스트 애프터서비스
- **고객 애프터서비스 주소**: https://buly.kr/5UJQodF
- 용도: 고객 문의, A/S 접수, 제품 지원

### 관리자 페이지
- **관리자 페이지 주소**: https://buly.kr/9iGYb86
- 용도: 관리자 전용, 시스템 관리

## 클라우드 동기화

### Google Drive
- **동기화 폴더**: `~/Library/CloudStorage/GoogleDrive-seiyeolo@gmail.com/내 드라이브`
- **계정**: seiyeolo@gmail.com
- **상태**: 동기화 활성화 ✅
- **마지막 확인**: 2026-03-04 15:47
- **용도**: 보고서, CSV 파일 자동 백업/공유

## 네트워크

### Tailscale IP
- **집 맥미니 (mac-mini)**: 100.94.10.43
- **회사 맥미니 (seiyeol-macmini)**: 100.96.190.7
- **mac-imac**: 100.78.88.9

### 화면 공유 설정 (macOS)

**GUI 방식 (권장):**
```
시스템 설정 → 일반 → 공유 → 화면 공유 ON
```

**명령줄 방식:**
```bash
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -activate -configure -access -on \
  -clientopts -setvnclegacy -vnclegacy yes \
  -restart -agent -privs -all
```

**접속 방법:**
- Finder → 이동 → 서버에 연결 (⌘K)
- 주소: `vnc://100.96.190.7` (Tailscale IP 사용)

---

Add whatever helps you do your job. This is your cheat sheet.
