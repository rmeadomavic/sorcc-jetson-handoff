#!/usr/bin/env bash
# Shared helpers for sorcc-jetson-keeper scripts.
# Source this from any install script: . "$(dirname "$0")/../scripts/lib/common.sh"

# Colors (no-op when stdout is not a tty)
if [ -t 1 ]; then
    GREEN='\033[0;32m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; CYAN='\033[0;36m'; NC='\033[0m'
else
    GREEN=''; YELLOW=''; RED=''; CYAN=''; NC=''
fi

ok()   { printf "${GREEN}[ OK ]${NC} %s\n" "$1"; }
warn() { printf "${YELLOW}[WARN]${NC} %s\n" "$1"; }
fail() { printf "${RED}[FAIL]${NC} %s\n" "$1" >&2; }
info() { printf "${CYAN}[INFO]${NC} %s\n" "$1"; }

# ask "prompt" [Y|N default]  → returns 0 yes, 1 no
ask() {
    local prompt="$1" default="${2:-Y}" yn
    if [ "$default" = "Y" ]; then
        read -rp "$prompt [Y/n]: " yn; yn="${yn:-Y}"
    else
        read -rp "$prompt [y/N]: " yn; yn="${yn:-N}"
    fi
    [[ "$yn" =~ ^[Yy] ]]
}

# require_jetpack_6  → exits 1 if not on JP6 / L4T R36.x
require_jetpack_6() {
    if [ ! -f /etc/nv_tegra_release ]; then
        fail "Not a Jetson (no /etc/nv_tegra_release). This script is for Jetson Orin Nano only."
        exit 1
    fi
    if ! grep -q '^# R36' /etc/nv_tegra_release; then
        fail "JetPack 6.x (L4T R36.x) required. You're on:"
        head -1 /etc/nv_tegra_release >&2
        fail "Run the flash + QSPI procedure in 01-flash-and-update/ first."
        exit 1
    fi
    ok "JetPack 6.x detected ($(awk '{print $1, $2, $3, $4, $5}' /etc/nv_tegra_release | head -1))"
}

# require_command CMD [hint]
require_command() {
    local cmd="$1" hint="${2:-}"
    if ! command -v "$cmd" >/dev/null 2>&1; then
        fail "Required command not found: $cmd"
        [ -n "$hint" ] && fail "$hint"
        exit 1
    fi
}

# in_group GROUPNAME  → 0 if user is in group
in_group() { id -nG | tr ' ' '\n' | grep -qx "$1"; }

# add_to_group GROUP  → adds $USER to group, sets NEED_RELOGIN=true
add_to_group() {
    local group="$1"
    if in_group "$group"; then
        ok "Already in $group group"
        return 0
    fi
    info "Adding $USER to $group group"
    sudo usermod -aG "$group" "$USER"
    NEED_RELOGIN=true
    ok "Added to $group (takes effect after logout/login)"
}

# pause_for_relogin  → checks NEED_RELOGIN and warns
pause_for_relogin() {
    if [ "${NEED_RELOGIN:-false}" = "true" ]; then
        echo
        warn "Group changes require logout/login to take effect."
        warn "Run 'newgrp docker' for an immediate Docker session, or log out/in for permanent effect."
    fi
}
