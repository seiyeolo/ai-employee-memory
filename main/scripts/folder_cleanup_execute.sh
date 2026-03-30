#!/bin/bash
# 맥미니 폴더 정리 실행 스크립트

set -e  # 오류 발생 시 중단

BACKUP_DIR="/Users/mac/clawd/folder-cleanup/backup_$(date +%Y%m%d_%H%M%S)"
LOG_FILE="/Users/mac/clawd/folder-cleanup/cleanup_log_$(date +%Y%m%d_%H%M%S).txt"

echo "=== 맥미니 폴더 정리 시작 ===" | tee -a "$LOG_FILE"
echo "시작 시간: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 백업 디렉토리 생성
mkdir -p "$BACKUP_DIR"
echo "백업 위치: $BACKUP_DIR" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 1단계: 새 폴더 구조 생성
echo "1단계: 새 폴더 구조 생성" | tee -a "$LOG_FILE"
mkdir -p ~/00_작업중
mkdir -p ~/01_AI프로젝트/{A2A,MCP,Claude,기타AI}
mkdir -p ~/02_개발/{Web,Python,기타}
mkdir -p ~/03_업무/{퍼티스트,파크골프,문서}
mkdir -p ~/04_학습자료/{강의,논문}
mkdir -p ~/나중에_확인

echo "✓ 새 폴더 구조 생성 완료" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

# 2단계: A2A 관련 통합
echo "2단계: A2A 관련 폴더 통합" | tee -a "$LOG_FILE"
for dir in A2A a2a-agents-collection a2a-data a2a-samples new-a2a-agents simple-a2a-agent; do
  if [ -d ~/"$dir" ]; then
    echo "  이동: $dir → 01_AI프로젝트/A2A/" | tee -a "$LOG_FILE"
    mv ~/"$dir" ~/01_AI프로젝트/A2A/ 2>&1 | tee -a "$LOG_FILE"
  fi
done
echo "" | tee -a "$LOG_FILE"

# 3단계: Claude 관련 통합
echo "3단계: Claude 관련 폴더 통합" | tee -a "$LOG_FILE"
for dir in claude_backups claude-chatgpt-bridge claude-chatgpt-debate claude-chatgpt-mcp chatgpt-claude-bridge-enhanced; do
  if [ -d ~/"$dir" ]; then
    echo "  이동: $dir → 01_AI프로젝트/Claude/" | tee -a "$LOG_FILE"
    mv ~/"$dir" ~/01_AI프로젝트/Claude/ 2>&1 | tee -a "$LOG_FILE"
  fi
done
echo "" | tee -a "$LOG_FILE"

# 4단계: MCP 관련 통합
echo "4단계: MCP 관련 폴더 통합" | tee -a "$LOG_FILE"
for dir in mcp-agents-orchestra mcp-backups mcp-servers mcp-setup mcptools find-file-mcp cursor-talk-to-figma-mcp-main zen-mcp-server Google-Scholar-MCP-Server global-orchestra; do
  if [ -d ~/"$dir" ]; then
    echo "  이동: $dir → 01_AI프로젝트/MCP/" | tee -a "$LOG_FILE"
    mv ~/"$dir" ~/01_AI프로젝트/MCP/ 2>&1 | tee -a "$LOG_FILE"
  fi
done
echo "" | tee -a "$LOG_FILE"

# 5단계: AI 기타 프로젝트
echo "5단계: 기타 AI 프로젝트 통합" | tee -a "$LOG_FILE"
for dir in DeepTutor ComfyUI self-hosted-ai-starter-kit; do
  if [ -d ~/"$dir" ]; then
    echo "  이동: $dir → 01_AI프로젝트/기타AI/" | tee -a "$LOG_FILE"
    mv ~/"$dir" ~/01_AI프로젝트/기타AI/ 2>&1 | tee -a "$LOG_FILE"
  fi
done
echo "" | tee -a "$LOG_FILE"

# 6단계: 개발 프로젝트 정리
echo "6단계: 개발 프로젝트 정리" | tee -a "$LOG_FILE"
for dir in swimming-instructor-website hashbrown-gemini-app ZonosProjects; do
  if [ -d ~/"$dir" ]; then
    echo "  이동: $dir → 02_개발/Web/" | tee -a "$LOG_FILE"
    mv ~/"$dir" ~/02_개발/Web/ 2>&1 | tee -a "$LOG_FILE"
  fi
done

if [ -d ~/파이썬 ]; then
  echo "  이동: 파이썬 → 02_개발/Python/" | tee -a "$LOG_FILE"
  mv ~/파이썬 ~/02_개발/Python/ 2>&1 | tee -a "$LOG_FILE"
fi

if [ -d ~/anaconda_projects ]; then
  echo "  이동: anaconda_projects → 02_개발/Python/" | tee -a "$LOG_FILE"
  mv ~/anaconda_projects ~/02_개발/Python/ 2>&1 | tee -a "$LOG_FILE"
fi
echo "" | tee -a "$LOG_FILE"

# 7단계: 업무 관련 정리
echo "7단계: 업무 관련 정리" | tee -a "$LOG_FILE"
if [ -d ~/puttist-marketing ]; then
  echo "  이동: puttist-marketing → 03_업무/퍼티스트/" | tee -a "$LOG_FILE"
  mv ~/puttist-marketing ~/03_업무/퍼티스트/ 2>&1 | tee -a "$LOG_FILE"
fi
echo "" | tee -a "$LOG_FILE"

# 8단계: 학습 자료
echo "8단계: 학습 자료 정리" | tee -a "$LOG_FILE"
if [ -d ~/AI강의교재_Obsidian ]; then
  echo "  이동: AI강의교재_Obsidian → 04_학습자료/강의/" | tee -a "$LOG_FILE"
  mv ~/AI강의교재_Obsidian ~/04_학습자료/강의/ 2>&1 | tee -a "$LOG_FILE"
fi

if [ -d ~/papers ]; then
  echo "  이동: papers → 04_학습자료/논문/" | tee -a "$LOG_FILE"
  mv ~/papers ~/04_학습자료/논문/ 2>&1 | tee -a "$LOG_FILE"
fi
echo "" | tee -a "$LOG_FILE"

# 9단계: 나중에 확인할 폴더들
echo "9단계: 확인 필요 폴더 → 나중에_확인/" | tee -a "$LOG_FILE"
for dir in cache logs outputs temp downloadtemp data servers; do
  if [ -d ~/"$dir" ]; then
    echo "  이동: $dir → 나중에_확인/" | tee -a "$LOG_FILE"
    mv ~/"$dir" ~/나중에_확인/ 2>&1 | tee -a "$LOG_FILE"
  fi
done
echo "" | tee -a "$LOG_FILE"

# 10단계: 정리 완료 보고
echo "10단계: 정리 결과 확인" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "=== 새 폴더 구조 ===" | tee -a "$LOG_FILE"
ls -la ~ | grep "^d" | grep -E "^d.*[0-9]{2}_" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"

echo "✅ 폴더 정리 완료!" | tee -a "$LOG_FILE"
echo "완료 시간: $(date)" | tee -a "$LOG_FILE"
echo "" | tee -a "$LOG_FILE"
echo "로그 파일: $LOG_FILE" | tee -a "$LOG_FILE"

# 최종 요약
echo "" | tee -a "$LOG_FILE"
echo "=== 정리 요약 ===" | tee -a "$LOG_FILE"
echo "00_작업중: $(ls -1 ~/00_작업중 2>/dev/null | wc -l) 항목" | tee -a "$LOG_FILE"
echo "01_AI프로젝트: $(find ~/01_AI프로젝트 -maxdepth 2 -type d 2>/dev/null | wc -l) 폴더" | tee -a "$LOG_FILE"
echo "02_개발: $(find ~/02_개발 -maxdepth 2 -type d 2>/dev/null | wc -l) 폴더" | tee -a "$LOG_FILE"
echo "03_업무: $(find ~/03_업무 -maxdepth 2 -type d 2>/dev/null | wc -l) 폴더" | tee -a "$LOG_FILE"
echo "04_학습자료: $(find ~/04_학습자료 -maxdepth 2 -type d 2>/dev/null | wc -l) 폴더" | tee -a "$LOG_FILE"
echo "나중에_확인: $(ls -1 ~/나중에_확인 2>/dev/null | wc -l) 항목" | tee -a "$LOG_FILE"
