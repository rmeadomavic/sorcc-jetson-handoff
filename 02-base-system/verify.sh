#!/usr/bin/env bash
# 02-base-system/verify.sh
# Confirms the base system is ready for apps in 04-apps/.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
. "$REPO_ROOT/scripts/lib/common.sh"

FAILS=0
note_fail() { FAILS=$((FAILS + 1)); }

echo
echo "==================================================="
echo "  Base system verify"
echo "==================================================="
echo

require_jetpack_6
echo

# Docker
if command -v docker >/dev/null 2>&1; then
    ok "Docker installed: $(docker --version)"
else
    fail "Docker not found"; note_fail
fi

if in_group docker; then
    ok "User is in docker group"
else
    fail "User '$USER' is NOT in docker group — run 'newgrp docker' or log out/in"; note_fail
fi
echo

# NVIDIA Container Toolkit
if dpkg -l 2>/dev/null | grep -q nvidia-container-toolkit; then
    ok "nvidia-container-toolkit installed"
else
    fail "nvidia-container-toolkit not installed"; note_fail
fi
echo

# GPU passthrough — actually run a container
info "Testing GPU passthrough (this runs a Docker container)..."
if docker run --rm --runtime nvidia dustynv/l4t-pytorch:r36.4.0 \
        python3 -c "import torch; print('CUDA available:', torch.cuda.is_available()); print('Device:', torch.cuda.get_device_name(0) if torch.cuda.is_available() else 'none')" 2>&1 | tee /tmp/gpu_test.log; then
    if grep -q 'CUDA available: True' /tmp/gpu_test.log; then
        ok "GPU passes through to containers — CUDA works"
    else
        fail "Container ran but CUDA is not available — likely missing --runtime nvidia"
        note_fail
    fi
else
    fail "Container did not run — check Docker + nvidia-container-toolkit"
    note_fail
fi
rm -f /tmp/gpu_test.log
echo

# dialout (only matters if FC will be connected)
if in_group dialout; then
    ok "User is in dialout group (can read serial)"
else
    warn "User '$USER' is NOT in dialout group — only matters if you'll connect a Pixhawk"
fi
echo

# Swap
SWAP_MB="$(free -m | awk '/^Swap/ {print $2}')"
if [ "$SWAP_MB" -ge 4000 ]; then
    ok "Swap: ${SWAP_MB} MB"
else
    warn "Swap is only ${SWAP_MB} MB — recommend 8 GB. Re-run 01-base-bootstrap.sh"
fi
echo

# Power mode (informational)
if command -v nvpmodel >/dev/null 2>&1; then
    MODE_LINE="$(sudo nvpmodel -q 2>/dev/null | grep -E '^NV Power Mode' || true)"
    if echo "$MODE_LINE" | grep -qi 'MAXN'; then
        ok "Power mode: $MODE_LINE"
    else
        warn "Power mode is not MAXN: $MODE_LINE — see 01-flash-and-update/04-maxn-super-mode.md"
    fi
fi
echo

echo "==================================================="
if [ "$FAILS" -eq 0 ]; then
    ok "Base system verified. Pick an app from 04-apps/."
    exit 0
else
    fail "Base system verification FAILED — $FAILS blocker(s) above"
    exit 1
fi
