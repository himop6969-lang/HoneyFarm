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
    if command -v python3 &>/dev/null; then
        python3 -c '
import cv2
import os
import time
import shutil
import sys
from colorama import init

init()

def render_gif(url_or_path, duration_seconds=None):
    gif_cache = os.path.join("/tmp", "zerotwo.gif")

    if url_or_path.startswith("http"):
        if not os.path.exists(gif_cache):
            import urllib.request
            print("  Downloading Zero Two... (only once)")
            req = urllib.request.Request(url_or_path, headers={"User-Agent": "Mozilla/5.0"})
            with urllib.request.urlopen(req) as response, open(gif_cache, "wb") as f:
                f.write(response.read())
        path = gif_cache
    else:
        path = url_or_path

    cap = cv2.VideoCapture(path)

    if not cap.isOpened():
        return

    os.system("cls" if os.name == "nt" else "clear")

    start_time = time.time()

    try:
        while True:
            if duration_seconds and (time.time() - start_time) >= duration_seconds:
                break

            ret, frame = cap.read()
            if not ret:
                cap.set(cv2.CAP_PROP_POS_FRAMES, 0)
                continue

            cols, rows = shutil.get_terminal_size((80, 24))

            orig_h, orig_w = frame.shape[:2]
            aspect_ratio = orig_h / orig_w

            target_width = cols - 1
            target_height = int(target_width * aspect_ratio)

            max_height = (rows - 1) * 2
            if target_height > max_height:
                target_height = max_height
                target_width = int(target_height / aspect_ratio)

            if target_height % 2 != 0:
                target_height -= 1

            frame = cv2.resize(frame, (target_width, target_height))

            output = ""
            for i in range(0, target_height, 2):
                for j in range(target_width):
                    b1, g1, r1 = frame[i, j]
                    b2, g2, r2 = frame[i + 1, j] if (i + 1) < target_height else (0, 0, 0)
                    output += f"\033[38;2;{r1};{g1};{b1}m\033[48;2;{r2};{g2};{b2}m▀\033[0m"
                output += "\n"

            print("\033[H" + output, end="", flush=True)
            time.sleep(0.05)

    except KeyboardInterrupt:
        pass
    finally:
        cap.release()
        os.system("cls" if os.name == "nt" else "clear")

if __name__ == "__main__":
    duration = None
    if len(sys.argv) > 1:
        try:
            duration = float(sys.argv[1])
        except ValueError:
            duration = None

    render_gif("https://media.giphy.com/media/Te7SIBNsGk17VFadmi/giphy.gif", duration_seconds=duration)
' "$DURATION"
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
    echo "    ♦  Mass Honeygain Deployer  ♦  Sidecar Architecture  ♦  Zero Two Edition  ♦"
    echo -e "${DIM}${WHITE}    Version 1.0.0  |  github: HimOP  |  Architecture: Docker + Tun2Proxy${RESET}"
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

    # 3. Validate files
    if [ ! -f "$ACCOUNTS_FILE" ]; then
        echo -e "${RED}  [!] honeygain.txt not found!${RESET}"; exit 1
    fi
    if [ ! -f "$PROXIES_FILE" ]; then
        echo -e "${RED}  [!] proxies.txt not found!${RESET}"; exit 1
    fi

    # 4. Load data (strip Windows \r and blank lines and comment lines)
    mapfile -t ACCOUNTS < <(sed 's/\r//' "$ACCOUNTS_FILE" | grep -v '^\s*$' | grep -v '^\s*#')
    mapfile -t PROXIES  < <(sed 's/\r//' "$PROXIES_FILE"  | grep -v '^\s*$' | grep -v '^\s*#')

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
            docker rm -f "$PROXY_CTR" "$HG_CTR" &>/dev/null

            # Start Proxy sidecar
            docker run -d \
                --name "$PROXY_CTR" \
                --restart=always \
                --sysctl net.ipv6.conf.default.disable_ipv6=0 \
                --device /dev/net/tun \
                --cap-add=NET_ADMIN \
                ghcr.io/tun2proxy/tun2proxy:v0.7.16 \
                --proxy "$PROXY" &>/dev/null
            PROXY_OK=$?

            if [ "$PROXY_OK" -ne 0 ]; then
                # Move cursor up 1 line and overwrite with FAIL
                printf "\033[1A\033[2K"
                printf "  %-5s  %-32s  %-4s  %-36s  ${RED}✗ proxy failed${RESET}\n" \
                       "$((ACC_IDX+1))" "$DISPLAY_EMAIL" "$DEV" "$DISPLAY_PROXY"
                ((TOTAL_FAIL++))
                ((PROXY_INDEX++))
                continue
            fi

            sleep 1

            # Start Honeygain container
            docker run -d \
                --name "$HG_CTR" \
                --network="container:$PROXY_CTR" \
                --restart=always \
                honeygain/honeygain:latest \
                -tou-accept \
                -email "$EMAIL" \
                -pass "$PASS" \
                -device "$DEVICE_NAME" &>/dev/null
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
                docker rm -f "$PROXY_CTR" &>/dev/null
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

    CONTAINERS=$(docker ps -a --filter "name=${PREFIX}_hg_" --format "{{.Names}}\t{{.Status}}")

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

    HG_CTRS=$(docker ps -a --filter "name=${PREFIX}_hg_"    --format "{{.Names}}")
    PX_CTRS=$(docker ps -a --filter "name=${PREFIX}_proxy_" --format "{{.Names}}")

    COUNT=0
    for CTR in $HG_CTRS $PX_CTRS; do
        docker rm -f "$CTR" &>/dev/null
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
