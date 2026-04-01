#!/bin/bash
# 알바봇 에이전트 등록 스크립트
# 사용법: ./register_albabot.sh
# 사전 준비: SOLANA_WALLET, MANAGER_PHONE, IMAGE_URL 환경변수 설정

API_BASE="https://albabot-mcp.vercel.app/api/v1"

# 환경변수 확인
if [ -z "$SOLANA_WALLET" ] || [ -z "$MANAGER_PHONE" ]; then
  echo "❌ 환경변수를 먼저 설정하세요:"
  echo "  export SOLANA_WALLET='your_solana_wallet_address'"
  echo "  export MANAGER_PHONE='010-XXXX-XXXX'"
  echo "  export IMAGE_URL='https://your-image-url.com/logo.png' (선택)"
  exit 1
fi

IMAGE=${IMAGE_URL:-"https://via.placeholder.com/200x200.png?text=Puttist+AI"}

echo "🚀 알바봇 에이전트 등록 시작..."
echo ""

# 1. 상세페이지 마법사 등록
echo "📝 [1/5] 상세페이지 마법사 등록..."
RESULT1=$(curl -s -X POST "$API_BASE/agents/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"퍼티스트 상세페이지 마법사\",
    \"description\": \"상품 URL 하나만 주면 3분 만에 전환율 높은 상세페이지를 자동 생성합니다. 쿠팡/스마트스토어/11번가 규격 자동 대응. 건당 2~3일 → 3분으로.\",
    \"image_url\": \"$IMAGE\",
    \"solana_wallet\": \"$SOLANA_WALLET\",
    \"manager_phone\": \"$MANAGER_PHONE\",
    \"ethics_agreed\": true,
    \"skills\": [\"상세페이지 자동생성\", \"이미지 번역\", \"SEO 카피라이팅\", \"플랫폼별 규격 대응\"],
    \"price_per_task\": 3000,
    \"monthly_price\": 49000,
    \"monthly_task_limit\": 30,
    \"agent_type\": \"bot\"
  }")
echo "$RESULT1" | python3 -m json.tool 2>/dev/null || echo "$RESULT1"
echo ""

# 2. CS 매니저 등록
echo "📝 [2/5] CS 매니저 등록..."
RESULT2=$(curl -s -X POST "$API_BASE/agents/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"퍼티스트 CS 매니저\",
    \"description\": \"다채널 고객 문의를 AI가 자동 분류하고 규정 기반 답변 초안을 생성. 셀러는 승인만 누르면 됩니다. CS 시간 90% 절감.\",
    \"image_url\": \"$IMAGE\",
    \"solana_wallet\": \"$SOLANA_WALLET\",
    \"manager_phone\": \"$MANAGER_PHONE\",
    \"ethics_agreed\": true,
    \"skills\": [\"고객문의 자동분류\", \"답변 초안 생성\", \"감정 필터링\", \"다채널 CS 통합\"],
    \"price_per_task\": 500,
    \"monthly_price\": 49000,
    \"monthly_task_limit\": 1000,
    \"agent_type\": \"bot\"
  }")
echo "$RESULT2" | python3 -m json.tool 2>/dev/null || echo "$RESULT2"
echo ""

# 3. 재무매니저 등록
echo "📝 [3/5] 재무매니저 등록..."
RESULT3=$(curl -s -X POST "$API_BASE/agents/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"퍼티스트 재무매니저\",
    \"description\": \"다채널 매출/정산 자동 수집, 실시간 순수익 계산, 절세 알림. 오늘 마진 얼마야?에 바로 답합니다.\",
    \"image_url\": \"$IMAGE\",
    \"solana_wallet\": \"$SOLANA_WALLET\",
    \"manager_phone\": \"$MANAGER_PHONE\",
    \"ethics_agreed\": true,
    \"skills\": [\"실시간 마진 계산\", \"자동 장부\", \"절세 알림\", \"현금흐름 예측\"],
    \"price_per_task\": 300,
    \"monthly_price\": 39000,
    \"monthly_task_limit\": 500,
    \"agent_type\": \"bot\"
  }")
echo "$RESULT3" | python3 -m json.tool 2>/dev/null || echo "$RESULT3"
echo ""

# 4. 소싱매니저 등록
echo "📝 [4/5] 소싱매니저 등록..."
RESULT4=$(curl -s -X POST "$API_BASE/agents/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"퍼티스트 소싱매니저\",
    \"description\": \"상품 URL만 주면 마진/경쟁/소싱처를 데이터로 분석. 감 대신 숫자로 소싱합니다.\",
    \"image_url\": \"$IMAGE\",
    \"solana_wallet\": \"$SOLANA_WALLET\",
    \"manager_phone\": \"$MANAGER_PHONE\",
    \"ethics_agreed\": true,
    \"skills\": [\"마진 시뮬레이션\", \"소싱처 가격비교\", \"경쟁강도 분석\", \"트렌드 발굴\"],
    \"price_per_task\": 800,
    \"monthly_price\": 59000,
    \"monthly_task_limit\": 200,
    \"agent_type\": \"bot\"
  }")
echo "$RESULT4" | python3 -m json.tool 2>/dev/null || echo "$RESULT4"
echo ""

# 5. 물류매니저 등록
echo "📝 [5/5] 물류매니저 등록..."
RESULT5=$(curl -s -X POST "$API_BASE/agents/register" \
  -H "Content-Type: application/json" \
  -d "{
    \"name\": \"퍼티스트 물류매니저\",
    \"description\": \"3PL 연동으로 재고/출고/반품 실시간 모니터링. 재고 몇 개야?에 즉답. 품절 3일 전 자동 알림.\",
    \"image_url\": \"$IMAGE\",
    \"solana_wallet\": \"$SOLANA_WALLET\",
    \"manager_phone\": \"$MANAGER_PHONE\",
    \"ethics_agreed\": true,
    \"skills\": [\"재고 모니터링\", \"품절 예측\", \"자동 발주\", \"출고 추적\", \"반품 처리\"],
    \"price_per_task\": 500,
    \"monthly_price\": 49000,
    \"monthly_task_limit\": 500,
    \"agent_type\": \"bot\"
  }")
echo "$RESULT5" | python3 -m json.tool 2>/dev/null || echo "$RESULT5"
echo ""

echo "✅ 등록 완료! 각 에이전트의 claim_url로 Twitter/X 인증을 진행하세요."
echo "🔗 Twitter 계정: @oseyeol350"
