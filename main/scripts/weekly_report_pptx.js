const pptxgen = require("pptxgenjs");

let pres = new pptxgen();
pres.layout = "LAYOUT_16x9";
pres.author = "(주)퍼티스트 CEO 전략가";
pres.title = "주간 현황 보고서 — 2026년 4월 2주차";

// Color palette — Midnight Executive
const C = {
  navy: "1E2761",
  ice: "CADCFC",
  white: "FFFFFF",
  dark: "0D1B2A",
  accent: "3A86FF",
  green: "06D6A0",
  red: "EF476F",
  yellow: "FFD166",
  gray: "8D99AE",
  lightGray: "EDF2F4",
  text: "1D3557",
};

// ── Slide 1: Title ──
let s1 = pres.addSlide();
s1.background = { color: C.navy };
s1.addShape(pres.shapes.RECTANGLE, { x: 0, y: 4.5, w: 10, h: 1.125, fill: { color: C.accent } });
s1.addText("(주)퍼티스트", { x: 0.8, y: 1.0, w: 8.4, h: 0.8, fontSize: 20, color: C.ice, fontFace: "Arial" });
s1.addText("주간 현황 보고서", { x: 0.8, y: 1.8, w: 8.4, h: 1.2, fontSize: 44, bold: true, color: C.white, fontFace: "Arial Black" });
s1.addText("2026년 4월 2주차 (4/1 ~ 4/7)", { x: 0.8, y: 3.0, w: 8.4, h: 0.6, fontSize: 18, color: C.ice, fontFace: "Arial" });
s1.addText("작성: CEO 전략가 | 보고일: 2026.04.08", { x: 0.8, y: 4.7, w: 8.4, h: 0.4, fontSize: 12, color: C.white, fontFace: "Arial" });

// ── Slide 2: 조직 개요 ──
let s2 = pres.addSlide();
s2.background = { color: C.white };
s2.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.8, fill: { color: C.navy } });
s2.addText("조직 구성", { x: 0.5, y: 0.1, w: 9, h: 0.6, fontSize: 24, bold: true, color: C.white, fontFace: "Arial" });

const agents = [
  ["🎯", "CEO 전략가", "main", "총괄 지휘, 의사결정"],
  ["🏭", "생산부", "production", "생산 관리 (주2회×70대)"],
  ["🚚", "물류부", "logistics", "출고/택배 관리"],
  ["📈", "영업마케팅부", "sales", "스마트스토어, 가격조사"],
  ["🎬", "콘텐츠부", "content", "마케팅 콘텐츠"],
  ["💰", "재무부", "finance", "재무/세무"],
  ["💻", "코딩부", "coding", "개발/자동화"],
];

agents.forEach((a, i) => {
  const y = 1.1 + i * 0.6;
  s2.addShape(pres.shapes.RECTANGLE, { x: 0.5, y: y, w: 9, h: 0.5, fill: { color: i % 2 === 0 ? C.lightGray : C.white } });
  s2.addText(a[0], { x: 0.6, y: y + 0.05, w: 0.5, h: 0.4, fontSize: 16 });
  s2.addText(a[1], { x: 1.2, y: y + 0.05, w: 2.3, h: 0.4, fontSize: 14, bold: true, color: C.text, fontFace: "Arial" });
  s2.addText(a[2], { x: 3.5, y: y + 0.05, w: 2, h: 0.4, fontSize: 12, color: C.gray, fontFace: "Arial" });
  s2.addText(a[3], { x: 5.5, y: y + 0.05, w: 4, h: 0.4, fontSize: 13, color: C.text, fontFace: "Arial" });
});

// ── Slide 3: 출고 현황 ──
let s3 = pres.addSlide();
s3.background = { color: C.white };
s3.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.8, fill: { color: C.navy } });
s3.addText("판매·출고 현황", { x: 0.5, y: 0.1, w: 9, h: 0.6, fontSize: 24, bold: true, color: C.white, fontFace: "Arial" });

// 전주 출고 테이블
s3.addText("전주 대비 출고 (3/30 ~ 4/3)", { x: 0.5, y: 1.0, w: 9, h: 0.4, fontSize: 16, bold: true, color: C.text, fontFace: "Arial" });

const salesData = [
  [{ text: "품목", options: { bold: true, color: C.white, fill: { color: C.navy } } },
   { text: "출고", options: { bold: true, color: C.white, fill: { color: C.navy } } },
   { text: "단가", options: { bold: true, color: C.white, fill: { color: C.navy } } },
   { text: "매출", options: { bold: true, color: C.white, fill: { color: C.navy } } }],
  ["고급형", "21대", "199,000원", "4,179,000원"],
  ["일반형", "10대", "159,000원", "1,590,000원"],
  ["파크골프", "1대", "-", "-"],
  ["그립 SO", "14개", "-", "-"],
  [{ text: "합계", options: { bold: true } }, "32대+14개", "-", "약 577만원"],
];
s3.addTable(salesData, { x: 0.5, y: 1.5, w: 5.5, colW: [1.5, 1.2, 1.4, 1.4], border: { pt: 0.5, color: C.gray }, fontSize: 11, fontFace: "Arial", color: C.text });

// 이번주 출고 요약
s3.addText("이번주 출고 요약 (4/1~4/7)", { x: 6.2, y: 1.0, w: 3.5, h: 0.4, fontSize: 14, bold: true, color: C.text, fontFace: "Arial" });
const weeklySummary = [
  ["고급형 판매", "2대"],
  ["파크골프", "1대"],
  ["그립 SO", "6개"],
  ["A/S", "6건"],
  ["총 출고", "15건"],
];
weeklySummary.forEach((item, i) => {
  const y = 1.5 + i * 0.45;
  s3.addText(item[0], { x: 6.2, y: y, w: 1.8, h: 0.35, fontSize: 12, color: C.gray, fontFace: "Arial" });
  s3.addText(item[1], { x: 8.0, y: y, w: 1.5, h: 0.35, fontSize: 14, bold: true, color: C.text, fontFace: "Arial", align: "right" });
});

// ── Slide 4: 재고 현황 ──
let s4 = pres.addSlide();
s4.background = { color: C.white };
s4.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.8, fill: { color: C.navy } });
s4.addText("재고 현황 (4/6 기준)", { x: 0.5, y: 0.1, w: 9, h: 0.6, fontSize: 24, bold: true, color: C.white, fontFace: "Arial" });

// 완성품 카드
s4.addShape(pres.shapes.RECTANGLE, { x: 0.5, y: 1.0, w: 4.3, h: 2.2, fill: { color: C.lightGray }, shadow: { type: "outer", blur: 4, offset: 2, angle: 135, color: "000000", opacity: 0.1 } });
s4.addText("완성품 (포장 완료)", { x: 0.7, y: 1.1, w: 4, h: 0.4, fontSize: 14, bold: true, color: C.text, fontFace: "Arial" });

const finishData = [
  [{ text: "항목", options: { bold: true, color: C.white, fill: { color: C.navy } } },
   { text: "3/30", options: { bold: true, color: C.white, fill: { color: C.navy } } },
   { text: "출고", options: { bold: true, color: C.white, fill: { color: C.navy } } },
   { text: "4/6", options: { bold: true, color: C.white, fill: { color: C.navy } } }],
  ["미국형", "14", "-", "14"],
  ["한국형 고급형", "141", "-21", "120"],
  ["한국형 일반형", "51", "-10", "41"],
  ["일본형", "280", "-", "280"],
  [{ text: "총계", options: { bold: true } }, "486", "-31", "458"],
];
s4.addTable(finishData, { x: 0.7, y: 1.5, w: 3.9, colW: [1.4, 0.8, 0.7, 0.8], border: { pt: 0.5, color: C.gray }, fontSize: 10, fontFace: "Arial", color: C.text });

// 본체/부품/그립 카드
s4.addShape(pres.shapes.RECTANGLE, { x: 5.2, y: 1.0, w: 4.3, h: 2.2, fill: { color: C.lightGray }, shadow: { type: "outer", blur: 4, offset: 2, angle: 135, color: "000000", opacity: 0.1 } });
s4.addText("본체 / 부품 / 그립", { x: 5.4, y: 1.1, w: 4, h: 0.4, fontSize: 14, bold: true, color: C.text, fontFace: "Arial" });

const bodyData = [
  [{ text: "구분", options: { bold: true, color: C.white, fill: { color: C.navy } } },
   { text: "수량", options: { bold: true, color: C.white, fill: { color: C.navy } } }],
  ["일반형 본체", "210대"],
  ["고급형 본체", "2,032대"],
  ["리퍼(고급형)", "4대"],
  ["부품 총계", "3,514개"],
  ["배터리", "8,800개"],
  ["그립 총계", "295개"],
];
s4.addTable(bodyData, { x: 5.4, y: 1.5, w: 3.9, colW: [2, 1.9], border: { pt: 0.5, color: C.gray }, fontSize: 10, fontFace: "Arial", color: C.text });

// 주의사항 카드
s4.addShape(pres.shapes.RECTANGLE, { x: 0.5, y: 3.5, w: 9, h: 1.6, fill: { color: "FFF3CD" }, shadow: { type: "outer", blur: 4, offset: 2, angle: 135, color: "000000", opacity: 0.1 } });
s4.addText("⚠️ 주의 사항", { x: 0.7, y: 3.6, w: 4, h: 0.4, fontSize: 16, bold: true, color: "856404", fontFace: "Arial" });
s4.addText([
  { text: "한국형 일반형 완성품 41개 — 추가 포장 긴급 필요", options: { bullet: true, breakLine: true } },
  { text: "한국형 고급형 완성품 120개 — 출고 속도 대비 포장 보충 필요", options: { bullet: true, breakLine: true } },
  { text: "그립 SO 89개 — 재입고 검토", options: { bullet: true } },
], { x: 0.7, y: 4.0, w: 8.6, h: 0.9, fontSize: 12, color: "856404", fontFace: "Arial" });

// ── Slide 5: 자동화 현황 ──
let s5 = pres.addSlide();
s5.background = { color: C.white };
s5.addShape(pres.shapes.RECTANGLE, { x: 0, y: 0, w: 10, h: 0.8, fill: { color: C.navy } });
s5.addText("자동화 & 시스템 현황", { x: 0.5, y: 0.1, w: 9, h: 0.6, fontSize: 24, bold: true, color: C.white, fontFace: "Arial" });

// 자동화 카드
const autoItems = [
  ["07:00", "뉴스 다이제스트", "✅"],
  ["07:30", "모닝 브리프", "✅"],
  ["08:00", "파일 변경 감시", "✅"],
  ["09:00", "스마트스토어 점검", "⚠️"],
  ["10:00", "기억 동기화", "✅"],
  ["14:00", "스토어 리뷰 점검", "⚠️"],
  ["15:30", "일일 발송량 집계", "✅"],
  ["16:00", "재고 변동 체크", "✅"],
  ["17:00", "기억 동기화", "✅"],
];

autoItems.forEach((item, i) => {
  const y = 1.0 + i * 0.45;
  s5.addShape(pres.shapes.RECTANGLE, { x: 0.5, y: y, w: 5.5, h: 0.38, fill: { color: i % 2 === 0 ? C.lightGray : C.white } });
  s5.addText(item[0], { x: 0.6, y: y + 0.02, w: 0.8, h: 0.34, fontSize: 11, bold: true, color: C.accent, fontFace: "Consolas" });
  s5.addText(item[1], { x: 1.5, y: y + 0.02, w: 3.5, h: 0.34, fontSize: 11, color: C.text, fontFace: "Arial" });
  s5.addText(item[2], { x: 5.0, y: y + 0.02, w: 0.5, h: 0.34, fontSize: 12 });
});

// 이슈 카드
s5.addShape(pres.shapes.RECTANGLE, { x: 6.2, y: 1.0, w: 3.3, h: 4.0, fill: { color: C.lightGray }, shadow: { type: "outer", blur: 4, offset: 2, angle: 135, color: "000000", opacity: 0.1 } });
s5.addText("현재 이슈", { x: 6.4, y: 1.1, w: 3, h: 0.4, fontSize: 16, bold: true, color: C.text, fontFace: "Arial" });

const issues = [
  ["🔴", "스마트스토어 로그인 만료", "재로그인 필요"],
  ["🟡", "OpenClaw 4.7 업데이트", "업데이트 검토"],
  ["🔴", "하트비트 전부 비활성", "활성화 검토"],
  ["🔴", "보안 감사 5개 치명적", "강화 필요"],
];
issues.forEach((item, i) => {
  const y = 1.6 + i * 0.85;
  s5.addText(item[0], { x: 6.4, y: y, w: 0.4, h: 0.3, fontSize: 14 });
  s5.addText(item[1], { x: 6.9, y: y, w: 2.4, h: 0.3, fontSize: 12, bold: true, color: C.text, fontFace: "Arial" });
  s5.addText(item[2], { x: 6.9, y: y + 0.3, w: 2.4, h: 0.3, fontSize: 10, color: C.gray, fontFace: "Arial" });
});

// ── Slide 6: Next Steps ──
let s6 = pres.addSlide();
s6.background = { color: C.navy };
s6.addText("다음 주 계획", { x: 0.8, y: 0.8, w: 8.4, h: 0.8, fontSize: 36, bold: true, color: C.white, fontFace: "Arial Black" });

const nextSteps = [
  ["📦", "한국형 일반형 포량 긴급 보충 (현재 41개)"],
  ["🔑", "스마트스토어 로그인 복구"],
  ["🔄", "OpenClaw 4.7 업데이트"],
  ["💓", "하트비트 활성화 (순차적)"],
  ["🔒", "보안 감사 이슈 해결"],
  ["📊", "재고 변동 자동 추적 정상 가동 확인"],
];
nextSteps.forEach((item, i) => {
  const y = 1.8 + i * 0.55;
  s6.addText(item[0], { x: 0.8, y: y, w: 0.5, h: 0.4, fontSize: 16 });
  s6.addText(item[1], { x: 1.4, y: y, w: 8, h: 0.4, fontSize: 16, color: C.ice, fontFace: "Arial" });
});

s6.addText("— CEO 전략가 | 2026.04.08 —", { x: 0.8, y: 4.8, w: 8.4, h: 0.4, fontSize: 12, color: C.gray, fontFace: "Arial", align: "right" });

// Save
const outPath = "/Users/mac/Library/Mobile Documents/com~apple~CloudDocs/퍼티스트/20260406_주간재고현황/퍼티스트_주간현황보고서_20260408.pptx";
pres.writeFile({ fileName: outPath }).then(() => {
  console.log("✅ 저장 완료: " + outPath);
}).catch(err => {
  console.error("❌ 오류:", err);
});
