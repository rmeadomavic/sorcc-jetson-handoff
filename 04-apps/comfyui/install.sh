#!/usr/bin/env bash
# 04-apps/comfyui/install.sh
#
# Install ComfyUI on JetPack 6.x using the dustynv/l4t-pytorch base image.
# Idempotent: safe to re-run.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
. "$REPO_ROOT/scripts/lib/common.sh"

COMFY_DIR="$HOME/ComfyUI"
COMFY_PORT="${COMFY_PORT:-8188}"
SD15_URL="https://huggingface.co/runwayml/stable-diffusion-v1-5/resolve/main/v1-5-pruned-emaonly.safetensors"

echo
echo "==================================================="
echo "  ComfyUI"
echo "==================================================="
echo

require_jetpack_6
require_command git
require_command python3
echo

# ── 1. Clone ComfyUI ──────────────────────────────────────────
info "Step 1/5: ComfyUI repo"
if [ -d "$COMFY_DIR/.git" ]; then
    info "Updating existing ComfyUI at $COMFY_DIR"
    cd "$COMFY_DIR"
    git pull
else
    info "Cloning ComfyUI to $COMFY_DIR"
    git clone https://github.com/comfyanonymous/ComfyUI "$COMFY_DIR"
    cd "$COMFY_DIR"
fi
ok "ComfyUI at $(git rev-parse --short HEAD)"
echo

# ── 2. Python venv + deps ─────────────────────────────────────
info "Step 2/5: Python venv + dependencies"
if [ ! -d "$COMFY_DIR/venv" ]; then
    python3 -m venv "$COMFY_DIR/venv"
fi
# shellcheck disable=SC1091
. "$COMFY_DIR/venv/bin/activate"

pip install --upgrade pip wheel

# Use the base image's PyTorch — it's already CUDA-enabled for Jetson.
# But the venv is its own Python env, so we install jetson-compatible torch from the NVIDIA index.
info "Installing PyTorch for Jetson (jp6, cu126)"
pip install --extra-index-url https://pypi.jetson-ai-lab.dev/jp6/cu126 torch torchvision torchaudio || \
    pip install torch torchvision torchaudio  # fallback to whatever is on PyPI

info "Installing ComfyUI requirements"
pip install -r requirements.txt
ok "Python deps installed"
echo

# ── 3. ComfyUI-Manager ────────────────────────────────────────
info "Step 3/5: ComfyUI-Manager (extension manager)"
MANAGER_DIR="$COMFY_DIR/custom_nodes/ComfyUI-Manager"
if [ -d "$MANAGER_DIR/.git" ]; then
    cd "$MANAGER_DIR"
    git pull
else
    git clone https://github.com/ltdrdata/ComfyUI-Manager "$MANAGER_DIR"
fi
ok "ComfyUI-Manager installed"
echo

# ── 4. Starter checkpoint (SD 1.5) ────────────────────────────
info "Step 4/5: Starter checkpoint (SD 1.5)"
mkdir -p "$COMFY_DIR/models/checkpoints"
if [ -f "$COMFY_DIR/models/checkpoints/v1-5-pruned-emaonly.safetensors" ]; then
    ok "SD 1.5 checkpoint already present"
else
    if ask "Download SD 1.5 starter checkpoint (~4 GB)?" "Y"; then
        info "Downloading from HuggingFace..."
        curl -L -o "$COMFY_DIR/models/checkpoints/v1-5-pruned-emaonly.safetensors" "$SD15_URL"
        ok "SD 1.5 checkpoint downloaded"
    else
        info "Skipping. Drop your own .safetensors into ~/ComfyUI/models/checkpoints/"
    fi
fi
echo

# ── 5. systemd unit (optional) ────────────────────────────────
info "Step 5/5: systemd auto-start"
SERVICE_FILE="/etc/systemd/system/comfyui.service"
if ask "Install ComfyUI as a systemd service (auto-start on boot)?" "N"; then
    sudo tee "$SERVICE_FILE" >/dev/null <<EOF
[Unit]
Description=ComfyUI
After=network.target

[Service]
Type=simple
User=$USER
WorkingDirectory=$COMFY_DIR
ExecStart=$COMFY_DIR/venv/bin/python $COMFY_DIR/main.py --listen --port $COMFY_PORT --lowvram
Restart=on-failure
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF
    sudo systemctl daemon-reload
    sudo systemctl enable comfyui
    if ask "Start ComfyUI now?" "Y"; then
        sudo systemctl start comfyui
        sleep 5
        if systemctl is-active --quiet comfyui; then
            ok "ComfyUI service started"
        else
            warn "Service did not start cleanly. Check: sudo journalctl -u comfyui -n 50"
        fi
    fi
else
    info "Skipping systemd setup. Run manually with:"
    info "  cd $COMFY_DIR && source venv/bin/activate && python main.py --listen --port $COMFY_PORT --lowvram"
fi
echo

JETSON_IP="$(hostname -I | awk '{print $1}')"
echo "==================================================="
ok "Install complete"
echo "==================================================="
info "Web UI: http://${JETSON_IP}:${COMFY_PORT}"
if command -v tailscale >/dev/null 2>&1; then
    TS_IP="$(tailscale ip -4 2>/dev/null | head -1 || true)"
    [ -n "$TS_IP" ] && info "Web UI (Tailscale): http://${TS_IP}:${COMFY_PORT}"
fi
info ""
info "Drop your own checkpoints into: $COMFY_DIR/models/checkpoints/"
info "Drop LoRAs into: $COMFY_DIR/models/loras/"
