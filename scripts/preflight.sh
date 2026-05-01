#!/usr/bin/env bash
# preflight.sh — does this Jetson meet the baseline for the apps in 04-apps/?
# Exits 0 if all checks pass, 1 otherwise. Prints which doc to read for any failure.
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/lib/common.sh"

FAIL_COUNT=0
note_fail() { FAIL_COUNT=$((FAIL_COUNT + 1)); }

echo
echo "==================================================="
echo "  SORCC Jetson Preflight"
echo "==================================================="
echo

# 1. Hardware + JetPack version
if [ ! -f /etc/nv_tegra_release ]; then
    fail "Not a Jetson — no /etc/nv_tegra_release"
    fail "  → This whole repo is for Jetson Orin Nano Super 8GB only."
    note_fail
elif grep -q '^# R36' /etc/nv_tegra_release; then
    ok "JetPack 6.x (L4T R36.x) detected"
    cat /etc/nv_tegra_release | head -1
elif grep -q '^# R35' /etc/nv_tegra_release; then
    fail "JetPack 5.x detected — you need to upgrade to JetPack 6.x"
    fail "  → See 01-flash-and-update/ — start with 01-qspi-update.md"
    note_fail
else
    fail "Unrecognized JetPack — see /etc/nv_tegra_release"
    note_fail
fi
echo

# 2. MAXN Super power mode
if command -v nvpmodel >/dev/null 2>&1; then
    MODE_LINE="$(sudo nvpmodel -q 2>/dev/null | grep -E '^NV Power Mode' || true)"
    if echo "$MODE_LINE" | grep -qi 'MAXN'; then
        ok "Power mode: $MODE_LINE"
    else
        warn "Power mode is not MAXN: $MODE_LINE"
        warn "  → See 01-flash-and-update/04-maxn-super-mode.md to enable MAXN Super (25W)"
    fi
else
    warn "nvpmodel not found — cannot check power mode"
fi
echo

# 3. Docker
if command -v docker >/dev/null 2>&1; then
    ok "Docker installed: $(docker --version)"
else
    fail "Docker not installed"
    fail "  → Run 02-base-system/01-base-bootstrap.sh"
    note_fail
fi

if in_group docker; then
    ok "User is in docker group"
else
    fail "User '$USER' is not in docker group"
    fail "  → Run 02-base-system/01-base-bootstrap.sh, then log out/in"
    note_fail
fi
echo

# 4. NVIDIA Container Toolkit
if dpkg -l 2>/dev/null | grep -q nvidia-container-toolkit; then
    ok "nvidia-container-toolkit installed"
else
    fail "nvidia-container-toolkit not installed"
    fail "  → Run 02-base-system/01-base-bootstrap.sh"
    note_fail
fi
echo

# 5. GPU passthrough into Docker
if command -v docker >/dev/null 2>&1 && in_group docker; then
    if docker run --rm --runtime nvidia ubuntu:22.04 nvidia-smi >/dev/null 2>&1 || \
       docker run --rm --runtime nvidia dustynv/l4t-pytorch:r36.4.0 nvidia-smi >/dev/null 2>&1; then
        ok "GPU passes through to containers (--runtime nvidia works)"
    else
        warn "Could not verify GPU passthrough (no test image, or first run)"
        warn "  → Will be tested when you install Hydra Detect"
    fi
fi
echo

# 6. Serial / dialout
if in_group dialout; then
    ok "User is in dialout group (can read serial / FC)"
else
    warn "User '$USER' is not in dialout group"
    warn "  → Needed if you'll connect a Pixhawk. Run 02-base-system/01-base-bootstrap.sh"
fi
echo

# 7. Tailscale (optional)
if command -v tailscale >/dev/null 2>&1; then
    TS_IP="$(tailscale ip -4 2>/dev/null | head -1 || true)"
    if [ -n "$TS_IP" ]; then
        ok "Tailscale up: $TS_IP"
    else
        warn "Tailscale installed but not connected"
        warn "  → See 02-base-system/02-tailscale.md"
    fi
else
    info "Tailscale not installed (optional). See 02-base-system/02-tailscale.md"
fi
echo

# Summary
echo "==================================================="
if [ "$FAIL_COUNT" -eq 0 ]; then
    ok "Preflight PASSED. You're ready to install apps from 04-apps/."
    exit 0
else
    fail "Preflight FAILED — $FAIL_COUNT blocker(s) above. Fix them before installing apps."
    exit 1
fi
