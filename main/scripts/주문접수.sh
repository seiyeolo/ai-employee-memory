#!/bin/bash
# ============================================
# 퍼티스트 주문접수 워크플로우
# 사용법: ./주문접수.sh "고객명" "전화번호" "주소" "제품코드" "수량" ["비고"]
# 예시: ./주문접수.sh "홍길동" "010-1234-5678" "서울시 강남구 테헤란로 123" "PG-001" "5" "택배"
# ============================================

set -euo pipefail

# 색상 정의
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# 경로 설정
ORDER_FILE="/Users/mac/clawd/data/주문대장.csv"
PRODUCTION_INVENTORY="/Users/mac/clawd-production/data/완제품재고.csv"
LOGISTICS_HISTORY="/Users/mac/clawd-logistics/data/출고이력.csv"
PRODUCTION_HISTORY="/Users/mac/clawd-production/data/입출고이력.csv"

# 제품코드 → 제품명 매핑
get_product_name() {
    case "$1" in
        PG-001) echo "퍼티스트 골프 고급형" ;;
        PG-002) echo "퍼티스트 골프 일반형" ;;
        PP-001) echo "퍼티스트 파크 고급형" ;;
        PP-002) echo "퍼티스트 파크 일반형" ;;
        PJ-001) echo "퍼티스트 일본형" ;;
        PM-001) echo "퍼티스트 미국형" ;;
        *) echo "알 수 없는 제품" ;;
    esac
}

# 인자 확인
if [ $# -lt 5 ]; then
    echo -e "${RED}❌ 사용법: $0 \"고객명\" \"전화번호\" \"주소\" \"제품코드\" \"수량\" [\"비고\"]${NC}"
    echo ""
    echo "제품코드 목록:"
    echo "  PG-001  퍼티스트 골프 고급형"
    echo "  PG-002  퍼티스트 골프 일반형"
    echo "  PP-001  퍼티스트 파크 고급형"
    echo "  PP-002  퍼티스트 파크 일반형"
    echo "  PJ-001  퍼티스트 일본형"
    echo "  PM-001  퍼티스트 미국형"
    exit 1
fi

CUSTOMER="$1"
PHONE="$2"
ADDRESS="$3"
PRODUCT_CODE="$4"
QUANTITY="$5"
NOTE="${6:-}"

PRODUCT_NAME=$(get_product_name "$PRODUCT_CODE")
TODAY=$(date +%Y-%m-%d)
ORDER_SEQ=$(grep -c "^ORD-" "$ORDER_FILE" 2>/dev/null || echo "0")
ORDER_SEQ=$((ORDER_SEQ + 1))
ORDER_NUM=$(printf "ORD-%s-%03d" "$(date +%Y%m%d)" "$ORDER_SEQ")

echo ""
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${BLUE}  퍼티스트 주문접수 시스템${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo ""
echo -e "📋 주문번호: ${GREEN}${ORDER_NUM}${NC}"
echo -e "👤 고객명:   ${CUSTOMER}"
echo -e "📞 전화번호: ${PHONE}"
echo -e "📍 주소:     ${ADDRESS}"
echo -e "📦 제품:     ${PRODUCT_NAME} (${PRODUCT_CODE})"
echo -e "🔢 수량:     ${QUANTITY}대"
echo ""

# ── STEP 1: 생산관리부 - 재고 확인 ──
echo -e "${YELLOW}[1/4] 생산관리부 → 재고 확인 중...${NC}"

CURRENT_STOCK=$(grep "^${PRODUCT_CODE}," "$PRODUCTION_INVENTORY" | cut -d',' -f3)

if [ -z "$CURRENT_STOCK" ]; then
    echo -e "${RED}  ❌ 제품코드 ${PRODUCT_CODE} 없음. 주문 중단.${NC}"
    exit 1
fi

if [ "$CURRENT_STOCK" -lt "$QUANTITY" ]; then
    echo -e "${RED}  ❌ 재고 부족! 현재고: ${CURRENT_STOCK}대, 요청: ${QUANTITY}대${NC}"
    echo -e "${RED}  주문을 접수할 수 없습니다. 생산 계획을 확인하세요.${NC}"

    # 주문대장에 재고부족으로 기록
    echo "${ORDER_NUM},${TODAY},${CUSTOMER},${PHONE},${ADDRESS},${PRODUCT_CODE},${PRODUCT_NAME},${QUANTITY},재고부족,부족,대기,재고부족-현재고${CURRENT_STOCK}" >> "$ORDER_FILE"
    exit 1
fi

NEW_STOCK=$((CURRENT_STOCK - QUANTITY))
echo -e "${GREEN}  ✅ 재고 확인: ${CURRENT_STOCK}대 → 출고 ${QUANTITY}대 → 잔여 ${NEW_STOCK}대${NC}"

# 재고 차감
sed -i '' "s/^${PRODUCT_CODE},${PRODUCT_NAME},${CURRENT_STOCK},/${PRODUCT_CODE},${PRODUCT_NAME},${NEW_STOCK},/" "$PRODUCTION_INVENTORY"

# 입출고이력 기록
echo "${TODAY},출고,${PRODUCT_CODE},${PRODUCT_NAME},${QUANTITY},${CUSTOMER},주문${ORDER_NUM}" >> "$PRODUCTION_HISTORY"

# ── STEP 2: 물류부 - 출고 기록 ──
echo -e "${YELLOW}[2/4] 물류부 → 출고 기록 중...${NC}"

SHIP_TYPE="택배"
if [ -n "$NOTE" ]; then
    SHIP_TYPE="$NOTE"
fi

echo "${TODAY},${SHIP_TYPE},${PRODUCT_CODE},${PRODUCT_NAME},${QUANTITY},${CUSTOMER}," >> "$LOGISTICS_HISTORY"
echo -e "${GREEN}  ✅ 출고이력 등록 완료 (${SHIP_TYPE})${NC}"

# ── STEP 3: 영업부 - 거래처 업데이트 ──
echo -e "${YELLOW}[3/4] 영업부 → 거래처 현황 업데이트 중...${NC}"

SALES_FILE="/Users/mac/clawd-sales/data/거래처현황.csv"
if grep -q "^${CUSTOMER}," "$SALES_FILE" 2>/dev/null; then
    echo -e "${GREEN}  ✅ 기존 거래처 확인: ${CUSTOMER}${NC}"
else
    echo "${CUSTOMER},일반,,,${TODAY},주문 ${QUANTITY}대 (${PRODUCT_NAME}),거래중" >> "$SALES_FILE"
    echo -e "${GREEN}  ✅ 신규 거래처 등록: ${CUSTOMER}${NC}"
fi

# ── STEP 4: 주문대장 기록 ──
echo -e "${YELLOW}[4/4] 주문대장 기록 중...${NC}"

echo "${ORDER_NUM},${TODAY},${CUSTOMER},${PHONE},${ADDRESS},${PRODUCT_CODE},${PRODUCT_NAME},${QUANTITY},접수완료,재고확인,출고준비,${NOTE}" >> "$ORDER_FILE"
echo -e "${GREEN}  ✅ 주문대장 등록 완료${NC}"

# ── 결과 요약 ──
echo ""
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo -e "${GREEN}  ✅ 주문접수 완료!${NC}"
echo -e "${BLUE}═══════════════════════════════════════════${NC}"
echo ""
echo "  주문번호: ${ORDER_NUM}"
echo "  고객:     ${CUSTOMER} (${PHONE})"
echo "  제품:     ${PRODUCT_NAME} × ${QUANTITY}대"
echo "  잔여재고: ${NEW_STOCK}대"
echo ""
echo "  📌 부서별 처리 현황:"
echo "    생산관리부: ✅ 재고 차감 완료 (${CURRENT_STOCK} → ${NEW_STOCK})"
echo "    물류부:     ✅ 출고이력 등록 (${SHIP_TYPE})"
echo "    영업부:     ✅ 거래처 업데이트"
echo "    주문대장:   ✅ 기록 완료"
echo ""

# ── 에이전트 알림 (선택) ──
if command -v openclaw &> /dev/null; then
    echo -e "${YELLOW}📢 에이전트 알림 전송 중...${NC}"

    openclaw agent --agent production --message \
        "[주문알림] ${ORDER_NUM}: ${CUSTOMER}에게 ${PRODUCT_NAME} ${QUANTITY}대 출고. 잔여재고 ${NEW_STOCK}대. 재고 확인 바랍니다." \
        > /dev/null 2>&1 &

    openclaw agent --agent logistics --message \
        "[출고요청] ${ORDER_NUM}: ${CUSTOMER}, ${PHONE}, ${ADDRESS}. ${PRODUCT_NAME} ${QUANTITY}대 ${SHIP_TYPE} 발송 준비 바랍니다." \
        > /dev/null 2>&1 &

    echo -e "${GREEN}  ✅ Production, Logistics 에이전트에 알림 전송됨${NC}"
fi

echo ""
echo -e "${BLUE}다음 단계: 물류부에서 택배 라벨 출력 및 발송 처리${NC}"
echo ""