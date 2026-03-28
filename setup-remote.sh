#!/bin/bash
# ============================================
# AI 직원 기억 저장소 - 원격 장비 설치 스크립트
# 집맥 또는 GCP에서 이 스크립트를 실행하세요
# ============================================

echo "========================================"
echo "  AI 직원 기억 저장소 설치"
echo "========================================"

# 1. gh CLI 확인
if ! command -v gh &> /dev/null; then
    echo "[!] gh CLI가 없습니다. 설치합니다..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install gh
    else
        # Linux (GCP)
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        sudo apt update && sudo apt install gh -y
    fi
fi

# 2. GitHub 로그인 확인
if ! gh auth status &> /dev/null; then
    echo "[!] GitHub 로그인이 필요합니다."
    gh auth login
fi

# 3. 저장소 클론
if [ ! -d ~/ai-employee-memory ]; then
    echo "[*] 저장소를 클론합니다..."
    cd ~ && git clone https://github.com/seiyeolo/ai-employee-memory.git
else
    echo "[*] 저장소가 이미 존재합니다. 최신화합니다..."
    cd ~/ai-employee-memory && git pull
fi

# 4. 동기화 스크립트 실행 권한
chmod +x ~/ai-employee-memory/sync.sh

# 5. 에이전트 워크스페이스 memory 연결
for agent in main production logistics sales content; do
    case $agent in
        main) workspace=~/clawd ;;
        *) workspace=~/clawd-${agent} ;;
    esac
    
    if [ -d "${workspace}" ]; then
        if [ -d "${workspace}/memory" ] && [ ! -L "${workspace}/memory" ]; then
            cp -r ${workspace}/memory/* ~/ai-employee-memory/${agent}/memory/ 2>/dev/null
            mv ${workspace}/memory ${workspace}/memory.bak.$(date +%Y%m%d)
        fi
        if [ ! -L "${workspace}/memory" ]; then
            ln -s ~/ai-employee-memory/${agent}/memory ${workspace}/memory
            echo "  ${agent}: 연결 완료"
        fi
    else
        echo "  ${agent}: 워크스페이스 없음 (${workspace}) - 건너뜀"
    fi
done

# 6. 최초 동기화
cd ~/ai-employee-memory && bash sync.sh

echo ""
echo "========================================"
echo "  설치 완료!"
echo "  크론탭에 동기화를 추가하세요:"
echo "  */30 * * * * bash ~/ai-employee-memory/sync.sh"
echo "========================================"
