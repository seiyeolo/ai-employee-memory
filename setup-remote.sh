#!/bin/bash
# ============================================
# AI 직원 기억 저장소 - 원격 장비 설치 스크립트
# 각 장비의 실제 경로를 자동 감지합니다
# ============================================

echo "========================================"
echo "  AI 직원 기억 저장소 설치"
echo "========================================"

HOSTNAME=$(hostname -s)
echo "장비: ${HOSTNAME} ($(whoami))"

# 1. gh CLI 확인
if ! command -v gh &> /dev/null; then
    echo "[!] gh CLI가 없습니다. 설치합니다..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install gh
    else
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

# 5. 장비별 워크스페이스 감지 및 memory 연결
echo ""
echo "[*] 워크스페이스 감지 중..."

# 가능한 워크스페이스 경로들 (회사맥, 집맥, GCP 등)
WORKSPACE_FOUND=false

# Case A: 회사맥 구조 (~/clawd, ~/clawd-*)
if [ -d ~/clawd ]; then
    echo "  감지: 회사맥 구조 (~/clawd)"
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
                echo "    ${agent}: 연결 완료"
            fi
        fi
    done
    WORKSPACE_FOUND=true
fi

# Case B: 집맥 구조 (~/nanoclaw)
if [ -d ~/nanoclaw ]; then
    echo "  감지: 집맥 구조 (~/nanoclaw)"

    # nanoclaw/data에 memory 심볼릭 링크 생성
    if [ ! -L ~/nanoclaw/data/memory ]; then
        ln -s ~/ai-employee-memory/main/memory ~/nanoclaw/data/memory 2>/dev/null
        echo "    main(nanoclaw): 연결 완료"
    fi
    WORKSPACE_FOUND=true
fi

# Case C: openclaw Docker 구조
if [ -d ~/openclaw ]; then
    echo "  감지: Docker/openclaw 구조"
    if [ ! -L ~/openclaw/memory ]; then
        ln -s ~/ai-employee-memory/main/memory ~/openclaw/memory 2>/dev/null
        echo "    main(openclaw): 연결 완료"
    fi
    WORKSPACE_FOUND=true
fi

# Case D: OpenClaw 기본 경로 (~/.openclaw)
if [ -d ~/.openclaw/agents ] && [ "$WORKSPACE_FOUND" = false ]; then
    echo "  감지: 기본 OpenClaw 구조 (~/.openclaw)"
    for agent_dir in ~/.openclaw/agents/*/; do
        agent=$(basename "$agent_dir")
        if [ ! -L "${agent_dir}memory" ]; then
            mkdir -p ~/ai-employee-memory/${agent}/memory
            ln -s ~/ai-employee-memory/${agent}/memory ${agent_dir}memory 2>/dev/null
            echo "    ${agent}: 연결 완료"
        fi
    done
    WORKSPACE_FOUND=true
fi

if [ "$WORKSPACE_FOUND" = false ]; then
    echo "  [!] 워크스페이스를 찾지 못했습니다."
    echo "  GitHub 기억 저장소만 클론되었습니다."
    echo "  수동으로 memory 폴더를 연결해주세요."
fi

# 6. 최초 동기화
cd ~/ai-employee-memory && bash sync.sh

echo ""
echo "========================================"
echo "  설치 완료! (${HOSTNAME})"
echo ""
echo "  크론탭에 동기화를 추가하세요:"
echo "  */30 * * * * bash ~/ai-employee-memory/sync.sh"
echo "========================================"
