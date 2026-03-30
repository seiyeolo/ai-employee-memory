#!/bin/bash
# 원격 코드 리뷰 & 자동 커밋 스크립트

# 사용법: ./remote-code-review.sh <프로젝트_경로> <리뷰_요청_내용>
# 예시: ./remote-code-review.sh ~/Projects/myapp "보안 취약점 점검 및 성능 최적화"

PROJECT_PATH="$1"
REVIEW_REQUEST="$2"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="/Users/mac/clawd/logs/code-review-${TIMESTAMP}.log"

# 로그 디렉토리 생성
mkdir -p /Users/mac/clawd/logs

echo "=== 원격 코드 리뷰 시작 ===" | tee -a "$LOG_FILE"
echo "프로젝트: $PROJECT_PATH" | tee -a "$LOG_FILE"
echo "요청사항: $REVIEW_REQUEST" | tee -a "$LOG_FILE"
echo "시작 시간: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 프로젝트 경로 확인
if [ ! -d "$PROJECT_PATH" ]; then
  echo "❌ 오류: 프로젝트 경로를 찾을 수 없습니다: $PROJECT_PATH" | tee -a "$LOG_FILE"
  exit 1
fi

cd "$PROJECT_PATH" || exit 1

# Git 상태 확인
if [ ! -d .git ]; then
  echo "❌ 오류: Git 저장소가 아닙니다" | tee -a "$LOG_FILE"
  exit 1
fi

# 현재 브랜치 확인
CURRENT_BRANCH=$(git branch --show-current)
echo "현재 브랜치: $CURRENT_BRANCH" | tee -a "$LOG_FILE"

# 커밋되지 않은 변경사항 확인
if ! git diff-index --quiet HEAD --; then
  echo "⚠️  경고: 커밋되지 않은 변경사항이 있습니다" | tee -a "$LOG_FILE"
  git status --short | tee -a "$LOG_FILE"
fi

# OpenCode 실행 (백그라운드)
echo "" | tee -a "$LOG_FILE"
echo "🔍 OpenCode 코드 리뷰 시작..." | tee -a "$LOG_FILE"

OPENCODE_PROMPT="프로젝트 코드를 전체적으로 점검하고 다음 사항을 분석해주세요:
${REVIEW_REQUEST}

분석 후 개선이 필요한 부분을 수정하고, 변경 사항을 명확한 커밋 메시지와 함께 준비해주세요.

완료되면 다음 명령으로 알림:
clawdbot gateway wake --text 'OpenCode 코드 리뷰 완료: $PROJECT_PATH' --mode now"

# OpenCode 실행 결과를 로그에 저장
opencode run "$OPENCODE_PROMPT" 2>&1 | tee -a "$LOG_FILE"

OPENCODE_EXIT_CODE=$?

echo "" | tee -a "$LOG_FILE"
echo "완료 시간: $(date)" | tee -a "$LOG_FILE"

if [ $OPENCODE_EXIT_CODE -eq 0 ]; then
  echo "✅ OpenCode 리뷰 완료" | tee -a "$LOG_FILE"
  
  # Git 변경사항 확인
  if ! git diff-index --quiet HEAD --; then
    echo "" | tee -a "$LOG_FILE"
    echo "📝 변경된 파일:" | tee -a "$LOG_FILE"
    git status --short | tee -a "$LOG_FILE"
    
    echo "" | tee -a "$LOG_FILE"
    echo "변경사항을 커밋하시겠습니까? (y/n)"
    # 자동 커밋을 원하면 이 부분을 수정
    # read -r CONFIRM
    # if [ "$CONFIRM" = "y" ]; then
    #   git add -A
    #   git commit -m "refactor: OpenCode 리뷰 반영 - ${REVIEW_REQUEST}"
    #   git push
    #   echo "✅ 커밋 및 푸시 완료" | tee -a "$LOG_FILE"
    # fi
  else
    echo "ℹ️  변경사항 없음" | tee -a "$LOG_FILE"
  fi
else
  echo "❌ OpenCode 리뷰 실패 (종료 코드: $OPENCODE_EXIT_CODE)" | tee -a "$LOG_FILE"
  exit 1
fi

echo "" | tee -a "$LOG_FILE"
echo "로그 파일: $LOG_FILE" | tee -a "$LOG_FILE"
