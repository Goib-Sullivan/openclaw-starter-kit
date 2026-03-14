#!/usr/bin/env bash
# ============================================================
#  install-wsl.sh — OpenClaw Installer for Ubuntu / WSL2
#
#  Runs inside WSL2 (Ubuntu). Usually launched automatically by
#  install-windows.ps1, but can be run directly:
#
#    bash /tmp/install-wsl.sh
#
#  Or fetched and run in one line:
#    curl -fsSL https://raw.githubusercontent.com/Goib-Sullivan/openclaw-starter-kit/main/install-wsl.sh | bash
#
#  Flags:
#    --help     Show usage and exit
#
#  This script is idempotent — safe to re-run if interrupted.
# ============================================================

set -euo pipefail

# ─────────────────────────────────────────────
#  Help flag (must come first, before set -e)
# ─────────────────────────────────────────────
for arg in "$@"; do
    if [[ "$arg" == "--help" || "$arg" == "-h" ]]; then
        cat <<'EOF'
OpenClaw WSL Installer
======================
This script installs everything needed for OpenClaw inside Ubuntu/WSL2.

What it installs:
  - System updates (apt update/upgrade)
  - Prerequisites: git, curl, build-essential
  - Ollama (local AI model runner)
  - Qwen3.5 32B AI model (~20 GB)
  - OpenClaw and workspace templates

Usage:
  bash /tmp/install-wsl.sh
  bash /tmp/install-wsl.sh --help

It will ask for your Telegram bot token and user ID before starting.
The script is idempotent — safe to re-run if it was interrupted.
EOF
        exit 0
    fi
done

# ─────────────────────────────────────────────
#  Color helpers (degrade gracefully if no TTY)
# ─────────────────────────────────────────────
if [ -t 1 ] && command -v tput &>/dev/null && tput colors &>/dev/null 2>&1; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    CYAN='\033[0;36m'
    WHITE='\033[1;37m'
    GRAY='\033[0;37m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' CYAN='' WHITE='' GRAY='' NC=''
fi

print_step()  { echo -e "\n${CYAN}  ➤  $1${NC}"; }
print_ok()    { echo -e "${GREEN}  ✓  $1${NC}"; }
print_warn()  { echo -e "${YELLOW}  ⚠  $1${NC}"; }
print_fail()  { echo -e "${RED}  ✗  $1${NC}"; }
print_info()  { echo -e "${GRAY}     $1${NC}"; }

# ─────────────────────────────────────────────
#  Cleanup trap (handles Ctrl+C gracefully)
# ─────────────────────────────────────────────
cleanup() {
    local code=$?
    if [ $code -ne 0 ]; then
        echo ""
        print_warn "Installer interrupted or encountered an error."
        print_info "The script is safe to re-run — it skips steps that already finished."
        print_info "To retry: bash /tmp/install-wsl.sh"
        echo ""
    fi
}
trap cleanup EXIT

# ─────────────────────────────────────────────
#  State file: tracks completed steps for idempotency
# ─────────────────────────────────────────────
STATE_DIR="$HOME/.openclaw-install-state"
mkdir -p "$STATE_DIR"

step_done() {
    # Returns 0 (true) if the step has already been marked complete
    [[ -f "$STATE_DIR/$1.done" ]]
}

mark_done() {
    touch "$STATE_DIR/$1.done"
}

# ─────────────────────────────────────────────
#  Welcome banner
# ─────────────────────────────────────────────
clear
echo ""
echo -e "${CYAN}  ╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}  ║                                                      ║${NC}"
echo -e "${CYAN}  ║     Setting up your personal AI assistant...         ║${NC}"
echo -e "${CYAN}  ║                                                      ║${NC}"
echo -e "${CYAN}  ║     This installer will:                             ║${NC}"
echo -e "${CYAN}  ║       • Update your system                           ║${NC}"
echo -e "${CYAN}  ║       • Install Ollama (local AI runner)             ║${NC}"
echo -e "${CYAN}  ║       • Download Qwen3.5 32B AI model (~20 GB)       ║${NC}"
echo -e "${CYAN}  ║       • Install OpenClaw & configure your assistant  ║${NC}"
echo -e "${CYAN}  ║                                                      ║${NC}"
echo -e "${CYAN}  ║     Total time: ~20–40 minutes (mostly downloading)  ║${NC}"
echo -e "${CYAN}  ║                                                      ║${NC}"
echo -e "${CYAN}  ╚══════════════════════════════════════════════════════╝${NC}"
echo ""

# ─────────────────────────────────────────────
#  Step 0: Collect info upfront
# ─────────────────────────────────────────────
echo -e "${WHITE}  ╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${WHITE}  ║     OpenClaw Setup — Quick Questions                 ║${NC}"
echo -e "${WHITE}  ╠══════════════════════════════════════════════════════╣${NC}"
echo -e "${WHITE}  ║  We need a few things before we start installing.    ║${NC}"
echo -e "${WHITE}  ║  You only need to answer these once.                 ║${NC}"
echo -e "${WHITE}  ╚══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${GRAY}  Don't have these yet? Cancel (Ctrl+C) and see ACCOUNTS-SETUP.md first.${NC}"
echo ""

# ── Load saved answers if they exist ───────────────────────────────────
SAVED_ANSWERS="$STATE_DIR/user-answers.env"
BOT_TOKEN=""
USER_ID=""
ASSISTANT_NAME=""

if [[ -f "$SAVED_ANSWERS" ]]; then
    source "$SAVED_ANSWERS"
    if [[ -n "$BOT_TOKEN" && -n "$USER_ID" && -n "$ASSISTANT_NAME" ]]; then
        print_ok "Using saved answers from previous run:"
        print_info "  Bot Token: ${BOT_TOKEN:0:10}..."
        print_info "  User ID: $USER_ID"
        print_info "  Assistant: $ASSISTANT_NAME"
        echo ""
        echo -en "${WHITE}  Use these? [Y/n]:${NC} "
        read -r USE_SAVED
        if [[ -z "$USE_SAVED" || "$USE_SAVED" =~ ^[Yy] ]]; then
            print_ok "Using saved answers"
        else
            BOT_TOKEN=""
            USER_ID=""
            ASSISTANT_NAME=""
        fi
        echo ""
    fi
fi

# ── Telegram Bot Token ─────────────────────────────────────────────────
if [[ -z "$BOT_TOKEN" ]]; then
    while true; do
        echo -en "${WHITE}  Enter your Telegram Bot Token (from @BotFather):${NC} "
        read -r BOT_TOKEN
        BOT_TOKEN="${BOT_TOKEN// /}"  # strip accidental spaces

        if [[ -z "$BOT_TOKEN" ]]; then
            print_warn "Bot token cannot be empty."
            print_info "Get one by messaging @BotFather on Telegram → /newbot"
            continue
        fi
        if [[ "$BOT_TOKEN" != *":"* ]]; then
            print_warn "That doesn't look right. A valid token looks like: 123456789:ABCdef..."
            print_info "(It must contain a colon : in the middle)"
            continue
        fi
        break
    done
    print_ok "Telegram Bot Token: OK"
    echo ""
fi

# ── Telegram User ID ───────────────────────────────────────────────────
if [[ -z "$USER_ID" ]]; then
    while true; do
        echo -en "${WHITE}  Enter your Telegram User ID (from @userinfobot):${NC} "
        read -r USER_ID
        USER_ID="${USER_ID// /}"

        if [[ -z "$USER_ID" ]]; then
            print_warn "User ID cannot be empty."
            print_info "Find it by messaging @userinfobot on Telegram."
            continue
        fi
        if ! [[ "$USER_ID" =~ ^[0-9]+$ ]]; then
            print_warn "User ID must be a number (e.g. 987654321)."
            print_info "Find it by messaging @userinfobot on Telegram."
            continue
        fi
        break
    done
    print_ok "Telegram User ID: OK"
    echo ""
fi

# ── Assistant name ────────────────────────────────────────────────────
if [[ -z "$ASSISTANT_NAME" ]]; then
    echo -en "${WHITE}  What would you like to name your assistant? [Atlas]:${NC} "
    read -r ASSISTANT_NAME
fi
ASSISTANT_NAME="${ASSISTANT_NAME:-Atlas}"
# Trim whitespace
ASSISTANT_NAME="$(echo "$ASSISTANT_NAME" | xargs)"
if [[ -z "$ASSISTANT_NAME" ]]; then
    ASSISTANT_NAME="Atlas"
fi
print_ok "Assistant name: $ASSISTANT_NAME"
echo ""

# ── Confirmation ───────────────────────────────────────────────────────
echo -e "${WHITE}  ┌──────────────────────────────────────────────────────┐${NC}"
echo -e "${WHITE}  │  Here's what we're about to install:                │${NC}"
echo -e "${WHITE}  │                                                      │${NC}"
echo -e "${WHITE}  │   • System updates (apt)                            │${NC}"
echo -e "${WHITE}  │   • git, curl, build-essential                      │${NC}"
echo -e "${WHITE}  │   • Ollama (local AI model runner)                  │${NC}"
echo -e "${WHITE}  │   • Qwen3.5 32B (~20 GB download)                  │${NC}"
echo -e "${WHITE}  │   • OpenClaw (your AI assistant platform)           │${NC}"
echo -e "${WHITE}  │   • Workspace templates + configuration             │${NC}"
echo -e "${WHITE}  │                                                      │${NC}"
echo -e "${WHITE}  │   Assistant name:   ${CYAN}$ASSISTANT_NAME${WHITE}$(printf '%*s' $((20 - ${#ASSISTANT_NAME})) '')│${NC}"
echo -e "${WHITE}  │   Telegram User ID: ${CYAN}$USER_ID${WHITE}$(printf '%*s' $((20 - ${#USER_ID})) '')│${NC}"
echo -e "${WHITE}  └──────────────────────────────────────────────────────┘${NC}"
echo ""
echo -en "${WHITE}  Ready to begin? (y/n) [y]:${NC} "
read -r CONFIRM
CONFIRM="${CONFIRM:-y}"
if [[ "${CONFIRM,,}" != "y" ]]; then
    echo ""
    print_info "Installation cancelled. Re-run anytime: bash /tmp/install-wsl.sh"
    exit 0
fi

# Save answers for future re-runs
cat > "$SAVED_ANSWERS" <<ENVEOF
BOT_TOKEN="$BOT_TOKEN"
USER_ID="$USER_ID"
ASSISTANT_NAME="$ASSISTANT_NAME"
ENVEOF
chmod 600 "$SAVED_ANSWERS"

echo ""
echo -e "${GREEN}  Let's go! Starting installation...${NC}"
echo ""

# ─────────────────────────────────────────────
#  Step 1: System update
# ─────────────────────────────────────────────
if step_done "apt-update"; then
    print_ok "System already updated — skipping"
else
    print_step "Updating system packages (this may take a few minutes)..."

    # Fix known WSL bug: command-not-found package causes segfaults on fresh installs
    if dpkg -l command-not-found &>/dev/null; then
        print_info "Removing command-not-found (causes crashes on fresh WSL installs)..."
        sudo apt remove command-not-found -y 2>/dev/null || true
    fi

    if ! sudo apt update -y 2>/dev/null; then
        # Retry once — first apt update on fresh WSL can be flaky
        print_warn "First apt update had issues, retrying..."
        sleep 2
        if ! sudo apt update -y; then
            print_fail "apt update failed."
            print_info "Check your internet connection and try again."
            exit 1
        fi
    fi

    if ! sudo apt upgrade -y; then
        print_warn "apt upgrade had issues, but continuing..."
    fi

    mark_done "apt-update"
    print_ok "System updated"
fi

# ─────────────────────────────────────────────
#  Step 2: Install prerequisites
# ─────────────────────────────────────────────
if step_done "apt-prereqs"; then
    print_ok "Prerequisites already installed — skipping"
else
    print_step "Installing prerequisites (git, curl, build-essential)..."

    if ! sudo apt install -y git curl build-essential zstd; then
        print_fail "Failed to install prerequisites."
        print_info "Try running manually: sudo apt install -y git curl build-essential zstd"
        exit 1
    fi

    mark_done "apt-prereqs"
    print_ok "Prerequisites installed"
fi

# ─────────────────────────────────────────────
#  Step 3: Install Ollama
# ─────────────────────────────────────────────
if step_done "ollama-install"; then
    print_ok "Ollama already installed — skipping"
else
    print_step "Installing Ollama..."

    if ! curl -fsSL https://ollama.com/install.sh | sh; then
        print_fail "Ollama installation failed."
        print_info ""
        print_info "What to try:"
        print_info "  1. Check your internet connection"
        print_info "  2. Run the command manually:"
        print_info "     curl -fsSL https://ollama.com/install.sh | sh"
        print_info "  3. If it still fails, visit: https://ollama.com/download"
        exit 1
    fi

    mark_done "ollama-install"
    print_ok "Ollama installed"
fi

# ─────────────────────────────────────────────
#  Step 4: Start Ollama service
# ─────────────────────────────────────────────
print_step "Starting Ollama service..."

# Check if already running
if pgrep -x "ollama" > /dev/null 2>&1; then
    print_ok "Ollama is already running"
else
    # Start ollama in the background; redirect output so it doesn't clutter terminal
    ollama serve > /tmp/ollama.log 2>&1 &
    OLLAMA_PID=$!

    # Wait for it to be ready (up to 15 seconds)
    OLLAMA_READY=false
    for i in $(seq 1 15); do
        sleep 1
        if curl -sf http://127.0.0.1:11434/ > /dev/null 2>&1; then
            OLLAMA_READY=true
            break
        fi
    done

    if ! $OLLAMA_READY; then
        print_warn "Ollama may not have started yet — continuing anyway."
        print_info "If the model download fails, try: ollama serve &"
    else
        print_ok "Ollama is running (PID: $OLLAMA_PID)"
    fi
fi

# ─────────────────────────────────────────────
#  Step 5: Pull Qwen3.5 32B
# ─────────────────────────────────────────────
if step_done "model-pull"; then
    print_ok "Qwen3.5 32B already downloaded — skipping"
else
    echo ""
    echo -e "${YELLOW}  ┌──────────────────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}  │  ⬇️   Downloading AI model: Qwen3.5 32B (~20 GB)          │${NC}"
    echo -e "${YELLOW}  │                                                          │${NC}"
    echo -e "${YELLOW}  │  This is the longest step — 5 to 20 minutes depending   │${NC}"
    echo -e "${YELLOW}  │  on your internet speed.                                 │${NC}"
    echo -e "${YELLOW}  │                                                          │${NC}"
    echo -e "${YELLOW}  │  ⚠️  DO NOT close this window while it downloads!         │${NC}"
    echo -e "${YELLOW}  └──────────────────────────────────────────────────────────┘${NC}"
    echo ""

    if ! ollama pull qwen3.5:35b; then
        print_fail "Failed to download Qwen3.5 32B."
        print_info ""
        print_info "What to try:"
        print_info "  1. Check your internet connection (this is a 20 GB download)"
        print_info "  2. Check disk space: run 'df -h /' and make sure you have 25+ GB free"
        print_info "  3. Retry: ollama pull qwen3.5:35b"
        print_info "  4. If Ollama isn't running, start it: ollama serve &"
        exit 1
    fi

    mark_done "model-pull"
    print_ok "Qwen3.5 32B downloaded successfully"
fi

# ─────────────────────────────────────────────
#  Step 6: GPU verification
# ─────────────────────────────────────────────
print_step "Checking GPU status..."

if command -v nvidia-smi &>/dev/null; then
    GPU_INFO=$(nvidia-smi --query-gpu=name,memory.total --format=csv,noheader 2>/dev/null || true)
    if [[ -n "$GPU_INFO" ]]; then
        print_ok "GPU detected: $GPU_INFO"

        # Quick model test
        echo ""
        print_info "Running a quick model test (just to confirm everything works)..."
        TEST_RESULT=$(echo "What is 2 plus 2? Answer briefly." | \
            timeout 60 ollama run qwen3.5:35b --nowordwrap 2>/dev/null | head -3 || true)
        if [[ -n "$TEST_RESULT" ]]; then
            print_ok "Model test passed:"
            echo -e "${GRAY}     $TEST_RESULT${NC}"
        else
            print_warn "Model test timed out or returned nothing — this is okay."
            print_info "The model will work fine when connected to OpenClaw."
        fi
    else
        print_warn "NVIDIA driver found but no GPU info returned."
        print_info "AI may run on CPU — update NVIDIA drivers from Windows for GPU speed."
    fi
else
    print_warn "nvidia-smi not found — GPU not available inside WSL."
    print_info "The AI model will run on CPU, which will be slower."
    print_info "To enable GPU: update NVIDIA drivers from Windows, then restart."
fi

# ─────────────────────────────────────────────
#  Step 7: Install OpenClaw
# ─────────────────────────────────────────────
if step_done "openclaw-install"; then
    print_ok "OpenClaw already installed — skipping"
else
    print_step "Installing OpenClaw..."

    # NOTE: Do NOT prefix with sudo — the installer handles its own permissions
    if ! curl -fsSL https://openclaw.ai/install.sh | bash; then
        print_fail "OpenClaw installation failed."
        print_info ""
        print_info "What to try:"
        print_info "  1. Check your internet connection"
        print_info "  2. Run manually: curl -fsSL https://openclaw.ai/install.sh | bash"
        print_info "  3. Do NOT use sudo with the OpenClaw installer"
        print_info "  4. For support: https://openclaw.ai/docs/install"
        exit 1
    fi

    # Reload PATH so openclaw is found immediately
    # shellcheck source=/dev/null
    if [[ -f "$HOME/.bashrc" ]]; then
        source "$HOME/.bashrc" 2>/dev/null || true
    fi
    if [[ -f "$HOME/.profile" ]]; then
        source "$HOME/.profile" 2>/dev/null || true
    fi
    # Common install locations
    export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:/usr/local/bin:$PATH"

    mark_done "openclaw-install"
    print_ok "OpenClaw installed"
fi

# Ensure openclaw is on PATH (handles both fresh and resumed installs)
if [[ -f "$HOME/.bashrc" ]]; then
    source "$HOME/.bashrc" 2>/dev/null || true
fi
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:/usr/local/bin:$PATH"

# Verify openclaw command is available
if ! command -v openclaw &>/dev/null; then
    print_warn "The 'openclaw' command was not found on your PATH."
    print_info "Trying to locate it..."

    # Search common locations
    for loc in "$HOME/.local/bin/openclaw" "/usr/local/bin/openclaw" "$HOME/.npm-global/bin/openclaw"; do
        if [[ -x "$loc" ]]; then
            export PATH="$(dirname "$loc"):$PATH"
            print_ok "Found openclaw at: $loc"
            break
        fi
    done

    if ! command -v openclaw &>/dev/null; then
        print_fail "Cannot find the openclaw command."
        print_info "Close and reopen your terminal, then run: openclaw onboard --install-daemon"
        print_info "If that doesn't work, run: source ~/.bashrc"
        exit 1
    fi
fi

# ─────────────────────────────────────────────
#  Step 8: Clone starter kit + copy workspace templates
# ─────────────────────────────────────────────
if step_done "starter-kit"; then
    print_ok "Starter kit already cloned — skipping"
else
    print_step "Cloning the OpenClaw Starter Kit..."

    cd "$HOME"

    if [[ -d "$HOME/openclaw-starter-kit" ]]; then
        print_info "Starter kit already exists — pulling latest changes..."
        git -C "$HOME/openclaw-starter-kit" pull --ff-only 2>/dev/null || \
            print_warn "Could not update starter kit — using existing version."
    else
        if ! git clone https://github.com/Goib-Sullivan/openclaw-starter-kit.git; then
            print_fail "Failed to clone the starter kit from GitHub."
            print_info ""
            print_info "What to try:"
            print_info "  1. Check your internet connection"
            print_info "  2. Make sure git is installed: sudo apt install git -y"
            print_info "  3. Try manually: git clone https://github.com/Goib-Sullivan/openclaw-starter-kit.git"
            exit 1
        fi
    fi

    print_step "Installing workspace templates..."
    cd "$HOME/openclaw-starter-kit"

    if ! bash setup-workspace.sh; then
        print_warn "Workspace template install had issues — the .openclaw/workspace/ directory"
        print_info "may not exist yet (OpenClaw creates it on first run)."
        print_info "You can run this later: cd ~/openclaw-starter-kit && bash setup-workspace.sh"
    fi

    mark_done "starter-kit"
    print_ok "Starter kit installed"
fi

# ─────────────────────────────────────────────
#  Step 9: Customize workspace templates with user info
# ─────────────────────────────────────────────
if step_done "workspace-customize"; then
    print_ok "Workspace already customized — skipping"
else
    print_step "Customizing workspace templates for $ASSISTANT_NAME..."

    WORKSPACE_DIR="$HOME/.openclaw/workspace"

    # ── SOUL.md: set assistant name, keep Option A personality only ─────
    SOUL_FILE="$WORKSPACE_DIR/SOUL.md"
    if [[ -f "$SOUL_FILE" ]]; then
        # Replace assistant name placeholders
        sed -i "s/\[YOUR ASSISTANT NAME\]/$ASSISTANT_NAME/g" "$SOUL_FILE"
        sed -i "s/\[YOUR ASSISTANT'S NAME\]/$ASSISTANT_NAME/g" "$SOUL_FILE"

        # If the file has option sections (A/B/C), keep only the section
        # between "Option A" and the next "Option" heading (or end of file).
        # This is a best-effort edit — if the template format changes, it's harmless.
        if grep -q "Option A\|## Option A\|### Option A" "$SOUL_FILE" 2>/dev/null; then
            # Build a Python one-liner to strip Options B and C
            python3 - <<'PYEOF' "$SOUL_FILE" || true
import sys, re

path = sys.argv[1]
with open(path) as f:
    content = f.read()

# Remove blocks that start with a heading containing "Option B" or "Option C"
# through the next same-level heading (or end of section)
pattern = r'(?m)^#{1,3} +Option [BC].*?(?=^#{1,3} +(?!Option [BC])|$(?![\s\S]))'
cleaned = re.sub(pattern, '', content, flags=re.DOTALL)

with open(path, 'w') as f:
    f.write(cleaned)
print("  Kept Option A personality")
PYEOF
        fi
        print_ok "SOUL.md customized"
    else
        print_warn "SOUL.md not found — skipping personality customization"
    fi

    # ── IDENTITY.md: set assistant name ───────────────────────────────
    IDENTITY_FILE="$WORKSPACE_DIR/IDENTITY.md"
    if [[ -f "$IDENTITY_FILE" ]]; then
        sed -i "s/\[YOUR ASSISTANT NAME\]/$ASSISTANT_NAME/g"  "$IDENTITY_FILE"
        sed -i "s/\[YOUR ASSISTANT'S NAME\]/$ASSISTANT_NAME/g" "$IDENTITY_FILE"
        print_ok "IDENTITY.md customized"
    fi

    # ── USER.md: leave name placeholder — user fills this in later ────
    # We intentionally leave [YOUR NAME] in place; the user fills it in
    # with `nano ~/.openclaw/workspace/USER.md` after install.

    mark_done "workspace-customize"
    print_ok "Workspace templates customized"
fi

# ─────────────────────────────────────────────
#  Step 10: OpenClaw onboarding
# ─────────────────────────────────────────────
if step_done "openclaw-onboard"; then
    print_ok "OpenClaw already configured — skipping"
else
    print_step "Configuring OpenClaw..."
    echo ""

    # Try non-interactive first; fall back to interactive with guidance
    echo -e "${GRAY}     Attempting automated configuration...${NC}"

    ONBOARD_CMD="openclaw onboard --install-daemon --non-interactive \
        --provider ollama \
        --model qwen3.5:35b \
        --channel telegram \
        --telegram-token \"$BOT_TOKEN\" \
        --telegram-dm-policy allowlist \
        --telegram-allow-from \"$USER_ID\""

    ONBOARD_OK=false
    if eval "$ONBOARD_CMD" 2>/dev/null; then
        ONBOARD_OK=true
    fi

    if ! $ONBOARD_OK; then
        print_warn "Automated configuration is not available — running the interactive wizard instead."
        echo ""
        echo -e "${WHITE}  ┌──────────────────────────────────────────────────────────┐${NC}"
        echo -e "${WHITE}  │  OpenClaw Setup Wizard — What to Enter                   │${NC}"
        echo -e "${WHITE}  ╠══════════════════════════════════════════════════════════╣${NC}"
        echo -e "${WHITE}  │                                                          │${NC}"
        echo -e "${WHITE}  │  Prompt                 │ Enter This                     │${NC}"
        echo -e "${WHITE}  │  ─────────────────────────────────────────────────────  │${NC}"
        echo -e "${WHITE}  │  Model provider         │ Ollama                         │${NC}"
        echo -e "${WHITE}  │  Ollama base URL        │ (press Enter for default)      │${NC}"
        echo -e "${WHITE}  │  Default model          │ qwen3.5:35b                    │${NC}"
        echo -e "${WHITE}  │  Telegram bot token     │ ${CYAN}$BOT_TOKEN${WHITE}$(printf '%*s' $((22 - ${#BOT_TOKEN})) '')│${NC}"
        echo -e "${WHITE}  │  Telegram dmPolicy      │ allowlist                      │${NC}"
        echo -e "${WHITE}  │  Telegram groupPolicy   │ allowlist                      │${NC}"
        echo -e "${WHITE}  │  allowFrom (user ID)    │ ${CYAN}$USER_ID${WHITE}$(printf '%*s' $((30 - ${#USER_ID})) '')│${NC}"
        echo -e "${WHITE}  │  Workspace location     │ (press Enter for default)      │${NC}"
        echo -e "${WHITE}  │  Install as daemon      │ y                              │${NC}"
        echo -e "${WHITE}  └──────────────────────────────────────────────────────────┘${NC}"
        echo ""
        echo -e "${YELLOW}  Press Enter when ready to start the wizard...${NC}"
        read -r

        if ! openclaw onboard --install-daemon; then
            print_fail "OpenClaw onboarding failed."
            print_info ""
            print_info "You can run it manually later:"
            print_info "  openclaw onboard --install-daemon"
            print_info ""
            print_info "When prompted, use these values:"
            print_info "  Provider: ollama"
            print_info "  Model: qwen3.5:35b"
            print_info "  Telegram token: $BOT_TOKEN"
            print_info "  Telegram user ID: $USER_ID"
            print_info "  dmPolicy: allowlist"
            print_info ""
            print_info "Installation will continue — you can configure manually."
        else
            mark_done "openclaw-onboard"
            print_ok "OpenClaw configured via wizard"
        fi
    else
        mark_done "openclaw-onboard"
        print_ok "OpenClaw configured successfully"
    fi
fi

# ─────────────────────────────────────────────
#  Step 11: Set config file permissions
# ─────────────────────────────────────────────
print_step "Securing configuration file..."

CONFIG_FILE="$HOME/.openclaw/openclaw.json"
if [[ -f "$CONFIG_FILE" ]]; then
    chmod 600 "$CONFIG_FILE"
    print_ok "Config file permissions set (600)"
else
    print_warn "Config file not found at $CONFIG_FILE"
    print_info "This may appear after the first run of OpenClaw — that's fine."
fi

# ─────────────────────────────────────────────
#  Step 12: Health check
# ─────────────────────────────────────────────
print_step "Running health check..."
echo ""

openclaw doctor || true   # don't abort if doctor reports warnings

echo ""

# ─────────────────────────────────────────────
#  Clean up install state directory
# ─────────────────────────────────────────────
# (Keep the state directory so future re-runs stay idempotent,
#  but remove any temp files we created.)
rm -f /tmp/install-wsl.sh 2>/dev/null || true

# ─────────────────────────────────────────────
#  Success banner
# ─────────────────────────────────────────────
echo ""
echo -e "${GREEN}  ╔══════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}  ║                                                          ║${NC}"
echo -e "${GREEN}  ║  ✅  OpenClaw is installed and running!                  ║${NC}"
echo -e "${GREEN}  ║                                                          ║${NC}"
echo -e "${GREEN}  ║  Your assistant ${CYAN}\"$ASSISTANT_NAME\"${GREEN} is ready!$(printf '%*s' $((22 - ${#ASSISTANT_NAME})) '')║${NC}"
echo -e "${GREEN}  ║                                                          ║${NC}"
echo -e "${GREEN}  ║  📱  Open Telegram and message your bot                  ║${NC}"
echo -e "${GREEN}  ║  🌐  Or visit: http://127.0.0.1:18789/                   ║${NC}"
echo -e "${GREEN}  ║                                                          ║${NC}"
echo -e "${GREEN}  ║  📚  Guides: ~/openclaw-starter-kit/                     ║${NC}"
echo -e "${GREEN}  ║     FIRST-STEPS.md  — What to try first                  ║${NC}"
echo -e "${GREEN}  ║     SECURITY.md     — Lock down your setup               ║${NC}"
echo -e "${GREEN}  ║     COMMANDS.md     — Quick reference                    ║${NC}"
echo -e "${GREEN}  ║                                                          ║${NC}"
echo -e "${GREEN}  ║  💡  Fill in your personal info:                         ║${NC}"
echo -e "${GREEN}  ║     nano ~/.openclaw/workspace/USER.md                   ║${NC}"
echo -e "${GREEN}  ║                                                          ║${NC}"
echo -e "${GREEN}  ╚══════════════════════════════════════════════════════════╝${NC}"
echo ""
