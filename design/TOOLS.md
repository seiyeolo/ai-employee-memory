# TOOLS.md - 디자인부 로컬 노트

> 스킬은 도구가 *어떻게* 동작하는지 정의한다. 이 파일은 *우리 환경*의 구체적인 값을 적는다.

## 사용 가능한 스킬
| 스킬 | 용도 |
|------|------|
| `canvas-design` | 포스터·아트워크 등 정적 비주얼 (.png/.pdf) |
| `artifact-design` | HTML 아티팩트 디자인 설계 |
| `artifact-diagramming` | 다이어그램 (구조도, 흐름도) |
| `dataviz` | 차트·그래프·대시보드 (숫자 표현 규칙 §3.2와 함께 사용) |
| `theme-factory` / `professional-themes` | 문서·슬라이드 테마 적용 |
| `pptx` / `docx` / `pdf` | 산출물 포맷 |
| `slide-creator` | 발표자료 |
| `web-artifacts-builder` | 복잡한 웹 아티팩트 |

## 폰트
- Plus Jakarta Sans — Google Fonts (`@import`로 로드 중)
- JetBrains Mono — Google Fonts
- ⚠️ 아티팩트(CSP 차단 환경)에서는 외부 폰트 로드 불가 → 시스템 폰트 폴백 사용

## 대비 측정 (눈으로 판단 금지)
```bash
python3 -c "
def L(h):
    h=h.lstrip('#'); c=[int(h[i:i+2],16)/255 for i in (0,2,4)]
    c=[(x/12.92 if x<=0.03928 else ((x+0.055)/1.055)**2.4) for x in c]
    return 0.2126*c[0]+0.7152*c[1]+0.0722*c[2]
def cr(a,b):
    l1,l2=sorted([L(a),L(b)],reverse=True); return (l1+0.05)/(l2+0.05)
print('%.2f' % cr('#FFFFFF','#2ECC71'))
"
```

## 채널 관리 링크
- 스마트스토어: https://smartstore.naver.com/3puttkiller
- Amazon US: https://www.amazon.com/dp/B0CJCMBXH7
- A/S 접수: https://buly.kr/5UJQodF
- 관리자 페이지: https://buly.kr/9iGYb86

## 확인 필요 (환경 정보 미확보)
- [ ] 디자인 원본 파일(AI/PSD/Figma) 보관 위치
- [ ] 인쇄소 연락처 및 입고 사양 (재단 여백, 파일 포맷)
- [ ] 제품 사진 원본 보관 위치
