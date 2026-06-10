#!/bin/bash
# =============================================================
#  HimOP HoneyFarm - Mass Honeygain Deployer
#  By: HimOP | Architecture: Docker Sidecar (Tun2Proxy)
#  Commands: --install | --start | --stop | --status
# =============================================================

ACCOUNTS_FILE="$(dirname "$(realpath "$0")")/honeygain.txt"
PROXIES_FILE="$(dirname "$(realpath "$0")")/proxies.txt"
SCRIPT_DIR="$(dirname "$(realpath "$0")")"
PREFIX="HimOP"

# ─── COLORS ───────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BLUE='\033[0;34m'
WHITE='\033[1;37m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ─── ZERO TWO ANIMATION ───────────────────────────────────────
play_zerotwo() {
    local DURATION="${1:-5}"
    local ZEROTWO_PY="$SCRIPT_DIR/play_zerotwo.py"
    if command -v python3 &>/dev/null && [ -f "$ZEROTWO_PY" ]; then
        python3 "$ZEROTWO_PY" "$DURATION" 2>/dev/null || true
    fi
}

# ─── STATIC LOGO (shown after animation) ──────────────────────
show_logo() {
    clear
    echo -e "${MAGENTA}${BOLD}"
    echo "  ██╗  ██╗██╗███╗   ███╗ ██████╗ ██████╗ "
    echo "  ██║  ██║██║████╗ ████║██╔═══██╗██╔══██╗"
    echo "  ███████║██║██╔████╔██║██║   ██║██████╔╝"
    echo "  ██╔══██║██║██║╚██╔╝██║██║   ██║██╔═══╝ "
    echo "  ██║  ██║██║██║ ╚═╝ ██║╚██████╔╝██║     "
    echo "  ╚═╝  ╚═╝╚═╝╚═╝     ╚═╝ ╚═════╝ ╚═╝     "
    echo -e "${YELLOW}${BOLD}"
    echo "  ██╗  ██╗ ██████╗ ███╗   ██╗███████╗██╗   ██╗███████╗ █████╗ ██████╗ ███╗   ███╗"
    echo "  ██║  ██║██╔═══██╗████╗  ██║██╔════╝╚██╗ ██╔╝██╔════╝██╔══██╗██╔══██╗████╗ ████║"
    echo "  ███████║██║   ██║██╔██╗ ██║█████╗   ╚████╔╝ █████╗  ███████║██████╔╝██╔████╔██║"
    echo "  ██╔══██║██║   ██║██║╚██╗██║██╔══╝    ╚██╔╝  ██╔══╝  ██╔══██║██╔══██╗██║╚██╔╝██║"
    echo "  ██║  ██║╚██████╔╝██║ ╚████║███████╗   ██║   ██║     ██║  ██║██║  ██║██║ ╚═╝ ██║"
    echo "  ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝"
    echo -e "${CYAN}"
    echo "    ♦  Mass Honeygain Deployer  ♦  Docker Sidecar Architecture  ♦"
    echo -e "${YELLOW}    ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo ""
}

# ─── INSTALL COMMAND ──────────────────────────────────────────
do_install() {
    play_zerotwo 5
    show_logo
    echo -e "${CYAN}${BOLD}[*] Running HimOP HoneyFarm Installer...${RESET}\n"

    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}[!] Please run with sudo: sudo bash HimOP_HoneyFarm.sh --install${RESET}"
        exit 1
    fi

    echo -e "${YELLOW}  [1/5] Updating apt package lists...${RESET}"
    apt-get update -qq
    echo -e "${GREEN}         Done.${RESET}"

    echo -e "${YELLOW}  [2/5] Installing Python3 + pip...${RESET}"
    apt-get install -y python3-pip -qq 2>/dev/null
    echo -e "${GREEN}         Done.${RESET}"

    echo -e "${YELLOW}  [3/5] Installing Python deps (opencv-python, colorama)...${RESET}"
    pip3 install opencv-python colorama -q
    echo -e "${GREEN}         Done.${RESET}"

    echo -e "${YELLOW}  [4/5] Checking / Installing Docker...${RESET}"
    if ! command -v docker &>/dev/null; then
        curl -fsSL https://get.docker.com | sh -s -- -q
        systemctl start docker && systemctl enable docker
        echo -e "${GREEN}         Docker installed: $(docker --version)${RESET}"
    else
        echo -e "${GREEN}         Docker already installed: $(docker --version)${RESET}"
    fi

    echo -e "${YELLOW}  [5/5] Pulling Docker images...${RESET}"
    docker pull honeygain/honeygain:latest -q
    docker pull ghcr.io/tun2proxy/tun2proxy:v0.7.16 -q
    echo -e "${GREEN}         Images ready.${RESET}"

    echo -e "${YELLOW}\n  [+] Checking TUN device...${RESET}"
    if [ ! -c /dev/net/tun ]; then
        echo -e "${RED}  [!] /dev/net/tun missing. Ask your VPS provider to enable TUN/TAP.${RESET}"
        exit 1
    fi
    echo -e "${GREEN}      /dev/net/tun OK.${RESET}"

    echo -e "\n${GREEN}${BOLD}  ✓  Installation complete!${RESET}"
    echo -e "${CYAN}  Next → Fill honeygain.txt and proxies.txt, then run:${RESET}"
    echo -e "${WHITE}          bash HimOP_HoneyFarm.sh --start${RESET}\n"
}

# ─── START COMMAND ────────────────────────────────────────────
do_start() {
    # 1. Zero Two dance
    play_zerotwo 5

    # 2. Static logo
    show_logo

    # 3. Validate files and TUN device
    if [ ! -f "$ACCOUNTS_FILE" ]; then
        echo -e "${RED}  [!] honeygain.txt not found!${RESET}"; exit 1
    fi
    if [ ! -f "$PROXIES_FILE" ]; then
        echo -e "${RED}  [!] proxies.txt not found!${RESET}"; exit 1
    fi
    if [ ! -c /dev/net/tun ]; then
        echo -e "${RED}  [!] /dev/net/tun not found!${RESET}"
        echo -e "${YELLOW}  Fix: mkdir -p /dev/net && mknod /dev/net/tun c 10 200 && chmod 666 /dev/net/tun${RESET}"
        exit 1
    fi

    # Pull images once before starting containers
    echo -e "${YELLOW}  [+] Pulling Docker images...${RESET}"
    sudo docker pull ghcr.io/tun2proxy/tun2proxy:v0.7.16 -q
    sudo docker pull honeygain/honeygain:latest -q
    echo -e "${GREEN}  [+] Images ready.${RESET}\n"

    # 4. Load data (strip Windows \r and blank lines and comment lines)
    mapfile -t ACCOUNTS < <(sed 's/\r//' "$ACCOUNTS_FILE" | grep -v '^\s*$' | grep -v '^\s*#')
    mapfile -t RAW_PROXIES < <(sed 's/\r//' "$PROXIES_FILE" | grep -v '^\s*$' | grep -v '^\s*#')

    # Auto-convert ip:port:user:pass → http://user:pass@ip:port
    PROXIES=()
    for RAW in "${RAW_PROXIES[@]}"; do
        if [[ "$RAW" == http://* ]] || [[ "$RAW" == socks5://* ]]; then
            # Already in URL format, use as-is
            PROXIES+=("$RAW")
        else
            # Assume ip:port:user:pass format
            IFS=':' read -r _IP _PORT _USER _PASS <<< "$RAW"
            if [ -n "$_IP" ] && [ -n "$_PORT" ] && [ -n "$_USER" ] && [ -n "$_PASS" ]; then
                PROXIES+=("http://${_USER}:${_PASS}@${_IP}:${_PORT}")
            fi
        fi
    done

    TOTAL_ACCS=${#ACCOUNTS[@]}
    TOTAL_PROXIES=${#PROXIES[@]}
    REQUIRED=$(( TOTAL_ACCS * 10 ))

    # 5. Summary bar
    echo -e "  ${GREEN}Accounts loaded : ${BOLD}$TOTAL_ACCS${RESET}"
    echo -e "  ${GREEN}Proxies  loaded : ${BOLD}$TOTAL_PROXIES${RESET}  ${DIM}(need $REQUIRED for 10 devices/account)${RESET}"
    if [ "$TOTAL_PROXIES" -lt "$REQUIRED" ]; then
        echo -e "  ${YELLOW}[!] Not enough proxies — will deploy until proxies run out.${RESET}"
    fi
    echo -e "${YELLOW}  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"

    # Column header
    printf "  ${BOLD}${WHITE}%-5s  %-32s  %-4s  %-36s  %s${RESET}\n" \
           "ACC#" "EMAIL" "DEV" "PROXY" "STATUS"
    echo -e "${DIM}  ──────────────────────────────────────────────────────────────────────────────${RESET}"

    PROXY_INDEX=0
    TOTAL_OK=0
    TOTAL_FAIL=0

    for ACC_IDX in "${!ACCOUNTS[@]}"; do
        IFS=':' read -r EMAIL PASS <<< "${ACCOUNTS[$ACC_IDX]}"
        EMAIL="${EMAIL//[[:space:]]/}"
        PASS="${PASS//[[:space:]]/}"

        if [ -z "$EMAIL" ] || [ -z "$PASS" ]; then
            echo -e "  ${YELLOW}[skip] Invalid line at row $((ACC_IDX+1))${RESET}"
            continue
        fi

        # Truncate email display if too long
        DISPLAY_EMAIL="$EMAIL"
        if [ ${#EMAIL} -gt 30 ]; then DISPLAY_EMAIL="${EMAIL:0:27}..."; fi

        for DEV in {1..10}; do
            if [ "$PROXY_INDEX" -ge "$TOTAL_PROXIES" ]; then
                echo -e "\n  ${YELLOW}[!] Proxies exhausted at Account $((ACC_IDX+1)) Device $DEV.${RESET}"
                break 2
            fi

            PROXY="${PROXIES[$PROXY_INDEX]}"
            SUFFIX="${ACC_IDX}_${DEV}"
            PROXY_CTR="${PREFIX}_proxy_${SUFFIX}"
            HG_CTR="${PREFIX}_hg_${SUFFIX}"
            DEVICE_NAME="${PREFIX}_Dev_$((ACC_IDX+1))_${DEV}"

            # Truncate proxy display
            DISPLAY_PROXY="$PROXY"
            if [ ${#PROXY} -gt 34 ]; then DISPLAY_PROXY="${PROXY:0:31}..."; fi

            # Show "Starting..." line
            printf "  %-5s  %-32s  %-4s  %-36s  ${DIM}starting...${RESET}\n" \
                   "$((ACC_IDX+1))" "$DISPLAY_EMAIL" "$DEV" "$DISPLAY_PROXY"

            # Remove stale containers silently
            sudo docker rm -f "$PROXY_CTR" "$HG_CTR" &>/dev/null

            # Start Proxy sidecar (InternetIncome exact pattern)
            PROXY_CTR_ID=$(sudo docker run -d \
                --name "$PROXY_CTR" \
                --restart=always \
                --sysctl net.ipv6.conf.default.disable_ipv6=0 \
                --device /dev/net/tun \
                --cap-add=NET_ADMIN \
                ghcr.io/tun2proxy/tun2proxy:v0.7.16 \
                --dns virtual \
                --proxy "$PROXY" \
                --verbosity off 2>/tmp/himop_proxy_err.txt)
            PROXY_OK=$?

            if [ -z "$PROXY_CTR_ID" ] || [ "$PROXY_OK" -ne 0 ]; then
                PROXY_ERR=$(cat /tmp/himop_proxy_err.txt 2>/dev/null)
                printf "\033[1A\033[2K"
                printf "  %-5s  %-32s  %-4s  %-36s  ${RED}✗ %s${RESET}\n" \
                       "$((ACC_IDX+1))" "$DISPLAY_EMAIL" "$DEV" "$DISPLAY_PROXY" "$PROXY_ERR"
                ((TOTAL_FAIL++))
                ((PROXY_INDEX++))
                continue
            fi

            sleep 2

            # Start Honeygain container (InternetIncome exact pattern)
            HG_CTR_ID=$(sudo docker run -d \
                --name "$HG_CTR" \
                --network="container:$PROXY_CTR" \
                --restart=always \
                honeygain/honeygain:latest \
                -tou-accept \
                -email "$EMAIL" \
                -pass "$PASS" \
                -device "$DEVICE_NAME" 2>/tmp/himop_hg_err.txt)
            HG_OK=$?

            # Move cursor up 1 line and overwrite with result
            printf "\033[1A\033[2K"
            if [ "$HG_OK" -eq 0 ]; then
                printf "  %-5s  %-32s  %-4s  %-36s  ${GREEN}✓ running${RESET}\n" \
                       "$((ACC_IDX+1))" "$DISPLAY_EMAIL" "$DEV" "$DISPLAY_PROXY"
                ((TOTAL_OK++))
            else
                printf "  %-5s  %-32s  %-4s  %-36s  ${RED}✗ hg failed${RESET}\n" \
                       "$((ACC_IDX+1))" "$DISPLAY_EMAIL" "$DEV" "$DISPLAY_PROXY"
                sudo docker rm -f "$PROXY_CTR" &>/dev/null
                ((TOTAL_FAIL++))
            fi

            ((PROXY_INDEX++))
        done
    done

    # Final summary
    echo -e "${YELLOW}\n  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
    echo -e "  ${GREEN}${BOLD}✓  HimOP HoneyFarm is LIVE!${RESET}"
    echo -e "  ${GREEN}   Devices started : ${BOLD}$TOTAL_OK${RESET}"
    echo -e "  ${RED}   Devices failed  : ${BOLD}$TOTAL_FAIL${RESET}"
    echo -e "  ${CYAN}   Monitor with    : ${WHITE}bash HimOP_HoneyFarm.sh --status${RESET}\n"
}

# ─── STATUS COMMAND ───────────────────────────────────────────
do_status() {
    play_zerotwo 3
    show_logo
    echo -e "${CYAN}${BOLD}[*] HimOP HoneyFarm — Live Status${RESET}\n"

    CONTAINERS=$(sudo docker ps -a --filter "name=${PREFIX}_hg_" --format "{{.Names}}\t{{.Status}}")

    if [ -z "$CONTAINERS" ]; then
        echo -e "  ${YELLOW}No HimOP containers found. Run --start first.${RESET}\n"; exit 0
    fi

    RUNNING=0; STOPPED=0

    printf "  ${BOLD}${WHITE}%-30s  %s${RESET}\n" "CONTAINER" "STATUS"
    echo -e "${DIM}  ────────────────────────────────────────────────────────────${RESET}"

    while IFS=$'\t' read -r NAME STATUS; do
        if echo "$STATUS" | grep -q "^Up"; then
            printf "  ${GREEN}●  %-28s${RESET}  ${GREEN}%s${RESET}\n" "$NAME" "$STATUS"
            ((RUNNING++))
        else
            printf "  ${RED}○  %-28s${RESET}  ${RED}%s${RESET}\n" "$NAME" "$STATUS"
            ((STOPPED++))
        fi
    done <<< "$CONTAINERS"

    echo -e "${DIM}  ────────────────────────────────────────────────────────────${RESET}"
    echo -e "  ${GREEN}Running : ${BOLD}$RUNNING${RESET}  |  ${RED}Stopped : ${BOLD}$STOPPED${RESET}  |  ${CYAN}Total : ${BOLD}$((RUNNING+STOPPED))${RESET}\n"
}

# ─── STOP COMMAND ─────────────────────────────────────────────
do_stop() {
    show_logo
    echo -e "${RED}${BOLD}[*] Stopping all HimOP HoneyFarm containers...${RESET}\n"

    HG_CTRS=$(sudo docker ps -a --filter "name=${PREFIX}_hg_"    --format "{{.Names}}")
    PX_CTRS=$(sudo docker ps -a --filter "name=${PREFIX}_proxy_" --format "{{.Names}}")

    COUNT=0
    for CTR in $HG_CTRS $PX_CTRS; do
        sudo docker rm -f "$CTR" &>/dev/null
        echo -e "  ${RED}✗  Removed: $CTR${RESET}"
        ((COUNT++))
    done

    if [ "$COUNT" -eq 0 ]; then
        echo -e "  ${YELLOW}No HimOP containers found.${RESET}"
    else
        echo -e "\n  ${GREEN}✓  Removed $COUNT containers.${RESET}"
        echo -e "  ${CYAN}   Existing Pawns/other containers were NOT touched.${RESET}\n"
    fi
}

# ─── ENTRY POINT ──────────────────────────────────────────────
case "$1" in
    --install) do_install ;;
    --start)   do_start   ;;
    --status)  do_status  ;;
    --stop)    do_stop    ;;
    *)
        play_zerotwo 5
        show_logo
        echo -e "  ${BOLD}Usage:${RESET}"
        echo -e "    ${CYAN}sudo bash HimOP_HoneyFarm.sh --install${RESET}   Install all dependencies"
        echo -e "    ${CYAN}      bash HimOP_HoneyFarm.sh --start${RESET}    Deploy all accounts"
        echo -e "    ${CYAN}      bash HimOP_HoneyFarm.sh --status${RESET}   Live container status"
        echo -e "    ${CYAN}      bash HimOP_HoneyFarm.sh --stop${RESET}     Stop all HimOP containers\n"
        ;;
esac
