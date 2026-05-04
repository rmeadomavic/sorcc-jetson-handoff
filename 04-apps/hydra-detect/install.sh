#!/usr/bin/env bash
# 04-apps/hydra-detect/install.sh
#
# Install or update Hydra Detect on a JetPack 6.x Jetson.
# Idempotent: safe to re-run for upgrades.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
. "$REPO_ROOT/scripts/lib/common.sh"

HYDRA_REMOTE="${HYDRA_REMOTE:-https://github.com/rmeadomavic/Hydra.git}"
HYDRA_DIR="$HOME/Hydra"
HYDRA_IMAGE="${HYDRA_IMAGE:-ghcr.io/rmeadomavic/hydra-detect:latest}"
SERVICE_NAME="hydra-detect"
NEED_RELOGIN=false

# Force a local source build instead of pulling from ghcr by exporting
# HYDRA_BUILD=1 before running. Useful if you've forked Hydra and want
# to test a local change.
HYDRA_BUILD="${HYDRA_BUILD:-0}"

echo
echo "==================================================="
echo "  Hydra Detect — install / update"
echo "==================================================="
echo

require_jetpack_6
require_command docker "Run 02-base-system/01-base-bootstrap.sh first"
echo

if ! in_group docker; then
    fail "User '$USER' is not in docker group. Run: newgrp docker"
    fail "Or log out and back in after running 02-base-system/01-base-bootstrap.sh"
    exit 1
fi

# ── 1. Clone or update Hydra ──────────────────────────────────
# We always need the repo — config.ini.factory and the systemd unit live in
# source, not in the Docker image. The image only ships the runtime code.
info "Step 1/5: Hydra repo (config + systemd unit)"
if [ -d "$HYDRA_DIR/.git" ]; then
    info "Updating existing repo at $HYDRA_DIR"
    cd "$HYDRA_DIR"
    git stash --include-untracked >/dev/null 2>&1 || true
    git fetch origin
    git checkout main 2>/dev/null || git checkout master
    git pull
    ok "Hydra repo updated to $(git rev-parse --short HEAD)"
else
    info "Cloning Hydra repo to $HYDRA_DIR"
    git clone "$HYDRA_REMOTE" "$HYDRA_DIR"
    cd "$HYDRA_DIR"
    ok "Hydra cloned at $(git rev-parse --short HEAD)"
fi
echo

# ── 2. Image: pull from GHCR, fall back to local build ────────
info "Step 2/5: Hydra Detect image"
PULLED=0
if [ "$HYDRA_BUILD" != "1" ]; then
    info "Trying to pull pre-built image: $HYDRA_IMAGE"
    if docker pull "$HYDRA_IMAGE" 2>&1 | tail -3; then
        docker tag "$HYDRA_IMAGE" hydra-detect:latest
        ok "Pulled $HYDRA_IMAGE and tagged as hydra-detect:latest"
        PULLED=1
    else
        warn "Pull failed — falling back to local build"
    fi
fi
if [ "$PULLED" -eq 0 ]; then
    info "Building hydra-detect:latest from source (~2 min after base image pull)"
    cd "$HYDRA_DIR"
    docker build --network=host -t hydra-detect:latest .
    ok "Image built locally"
fi
echo

# ── 3. Configure ──────────────────────────────────────────────
info "Step 3/5: Configure"

CONFIG="$HYDRA_DIR/config.ini"
if [ ! -f "$CONFIG" ]; then
    if [ -f "$HYDRA_DIR/config.ini.factory" ]; then
        cp "$HYDRA_DIR/config.ini.factory" "$CONFIG"
        ok "Created config.ini from factory defaults"
    else
        warn "No config.ini.factory found — leaving config.ini untouched"
    fi
else
    info "Existing config.ini preserved"
fi

# Detect serial devices
SERIAL_DEVICES=()
for dev in /dev/ttyACM* /dev/ttyUSB* /dev/ttyTHS*; do
    [ -e "$dev" ] && SERIAL_DEVICES+=("$dev")
done

if [ ${#SERIAL_DEVICES[@]} -gt 0 ]; then
    echo
    info "Serial devices detected:"
    for dev in "${SERIAL_DEVICES[@]}"; do echo "  - $dev"; done
    echo
    if ask "Enable MAVLink to a flight controller?" "Y"; then
        # Pick device
        if [ ${#SERIAL_DEVICES[@]} -eq 1 ]; then
            MAVLINK_DEVICE="${SERIAL_DEVICES[0]}"
        else
            echo "Which one is your flight controller?"
            for i in "${!SERIAL_DEVICES[@]}"; do echo "  $((i+1))) ${SERIAL_DEVICES[$i]}"; done
            read -rp "Pick a number [1]: " choice
            choice="${choice:-1}"; idx=$((choice - 1))
            MAVLINK_DEVICE="${SERIAL_DEVICES[$idx]}"
        fi
        # Baud
        if [[ "$MAVLINK_DEVICE" == /dev/ttyTHS* ]]; then
            MAVLINK_BAUD=921600
        else
            MAVLINK_BAUD=115200
        fi
        # Patch config
        sed -i '/^\[mavlink\]/,/^\[/{s/^enabled = .*/enabled = true/}' "$CONFIG"
        sed -i "/^\[mavlink\]/,/^\[/{s|^connection_string = .*|connection_string = ${MAVLINK_DEVICE}|}" "$CONFIG"
        sed -i "/^\[mavlink\]/,/^\[/{s/^baud = .*/baud = ${MAVLINK_BAUD}/}" "$CONFIG"
        ok "MAVLink: $MAVLINK_DEVICE @ $MAVLINK_BAUD baud"
    else
        sed -i '/^\[mavlink\]/,/^\[/{s/^enabled = .*/enabled = false/}' "$CONFIG"
        ok "MAVLink disabled"
    fi
else
    info "No serial devices found — MAVLink disabled"
    sed -i '/^\[mavlink\]/,/^\[/{s/^enabled = .*/enabled = false/}' "$CONFIG"
fi

mkdir -p "$HYDRA_DIR/models" "$HYDRA_DIR/output_data"
ok "Data dirs ready"

# Provision /etc/hydra/hydra.env if absent. hydra-detect.service declares
# EnvironmentFile=-/etc/hydra/hydra.env; without the file HYDRA_API_TOKEN
# is unset and Hydra logs a warning on every start.
HYDRA_ENV=/etc/hydra/hydra.env
if [ ! -f "$HYDRA_ENV" ]; then
    sudo mkdir -p /etc/hydra
    printf '# Hydra runtime secrets\n# Set HYDRA_API_TOKEN to restrict external API access (optional for local use).\nHYDRA_API_TOKEN=\n' \
        | sudo tee "$HYDRA_ENV" >/dev/null
    sudo chmod 600 "$HYDRA_ENV"
    warn "Created $HYDRA_ENV — edit to set HYDRA_API_TOKEN if needed"
else
    info "Existing $HYDRA_ENV preserved"
fi
echo

# ── 4. systemd service (optional) ─────────────────────────────
info "Step 4/5: systemd auto-start"
if ask "Install Hydra as a systemd service (auto-start on boot)?" "Y"; then
    if [ -f "$HYDRA_DIR/scripts/hydra-detect.service" ]; then
        sudo cp "$HYDRA_DIR/scripts/hydra-detect.service" /etc/systemd/system/
        sudo systemctl daemon-reload
        sudo systemctl enable "$SERVICE_NAME"
        ok "$SERVICE_NAME enabled"
    else
        warn "scripts/hydra-detect.service not found in repo — skipping systemd setup"
    fi
else
    info "Skipping systemd setup. Launch manually with: cd ~/Hydra && bash scripts/hydra-launch.sh"
fi
echo

# ── 5. Launch ─────────────────────────────────────────────────
info "Step 5/5: Launch"
if systemctl list-unit-files 2>/dev/null | grep -q "^${SERVICE_NAME}.service"; then
    if ask "Start Hydra now via systemd?" "Y"; then
        sudo systemctl restart "$SERVICE_NAME"
        sleep 5
        if systemctl is-active --quiet "$SERVICE_NAME"; then
            ok "Hydra is running"
            JETSON_IP="$(hostname -I | awk '{print $1}')"
            info "Dashboard: http://${JETSON_IP}:8080"
            if command -v tailscale >/dev/null 2>&1; then
                TS_IP="$(tailscale ip -4 2>/dev/null | head -1 || true)"
                [ -n "$TS_IP" ] && info "Dashboard (Tailscale): http://${TS_IP}:8080"
            fi
        else
            warn "Service did not start cleanly. Check: sudo journalctl -u $SERVICE_NAME -n 50"
        fi
    fi
fi

echo
echo "==================================================="
ok "Install complete"
echo "==================================================="
