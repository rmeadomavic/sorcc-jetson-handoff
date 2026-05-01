#!/usr/bin/env bash
# 02-base-system/01-base-bootstrap.sh
#
# Idempotent base setup for a fresh JetPack 6.x Jetson Orin Nano:
#   1. apt update + upgrade
#   2. Docker CE
#   3. NVIDIA Container Toolkit
#   4. Pull dustynv/l4t-pytorch:r36.4.0 (the base image every app uses)
#   5. Add $USER to docker + dialout groups
#   6. 8 GB swap file (one-time)
#
# Safe to re-run. Each step checks for existing state before acting.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
. "$REPO_ROOT/scripts/lib/common.sh"

NEED_RELOGIN=false

echo
echo "==================================================="
echo "  Base system bootstrap"
echo "==================================================="
echo

require_jetpack_6
echo

# ── 1. apt update + upgrade ────────────────────────────────────
info "Step 1/6: apt update + upgrade"
sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y
ok "Base packages up to date"
echo

# ── 2. Docker CE ───────────────────────────────────────────────
info "Step 2/6: Docker"
if command -v docker >/dev/null 2>&1; then
    ok "Docker already installed: $(docker --version)"
else
    info "Installing Docker via NVIDIA's apt repo (already configured on JP 6.x)"
    sudo apt-get install -y docker.io
    sudo systemctl enable --now docker
    ok "Docker installed: $(docker --version)"
fi
echo

# ── 3. NVIDIA Container Toolkit ────────────────────────────────
info "Step 3/6: NVIDIA Container Toolkit"
if dpkg -l 2>/dev/null | grep -q nvidia-container-toolkit; then
    ok "nvidia-container-toolkit already installed"
else
    sudo apt-get install -y nvidia-container-toolkit
    sudo systemctl restart docker
    ok "nvidia-container-toolkit installed"
fi
echo

# ── 4. Pull base image ─────────────────────────────────────────
info "Step 4/6: Pull base Docker image"
BASE_IMAGE="dustynv/l4t-pytorch:r36.4.0"
if sudo docker image inspect "$BASE_IMAGE" >/dev/null 2>&1; then
    ok "Base image already present: $BASE_IMAGE"
else
    warn "Pulling $BASE_IMAGE (~6 GB, several minutes)"
    sudo docker pull "$BASE_IMAGE"
    ok "Base image pulled"
fi
echo

# ── 5. Group membership ────────────────────────────────────────
info "Step 5/6: User groups"
add_to_group docker
add_to_group dialout
echo

# ── 6. Swap file ───────────────────────────────────────────────
info "Step 6/6: Swap file (8 GB)"
if [ -f /swapfile ] && grep -q '/swapfile' /etc/fstab; then
    ok "Swap file already configured"
else
    info "Creating 8 GB /swapfile"
    sudo fallocate -l 8G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    if ! grep -q '/swapfile' /etc/fstab; then
        echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab >/dev/null
    fi
    ok "8 GB swap active and persistent"
fi
echo

# ── Done ───────────────────────────────────────────────────────
echo "==================================================="
ok "Base bootstrap complete"
echo "==================================================="
pause_for_relogin
echo
info "Next steps:"
info "  1. (Optional) Set up Tailscale: 02-base-system/02-tailscale.md"
info "  2. Verify everything works: bash 02-base-system/verify.sh"
info "  3. Pick an app to install: 04-apps/"
