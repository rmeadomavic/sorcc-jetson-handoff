#!/usr/bin/env bash
# 04-apps/ollama/install.sh
#
# Install Ollama (native, not Docker) + Open WebUI (Docker) on JetPack 6.x.
# Idempotent: safe to re-run.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
. "$REPO_ROOT/scripts/lib/common.sh"

WEBUI_PORT="${WEBUI_PORT:-3000}"
DEFAULT_MODEL="${DEFAULT_MODEL:-phi3:mini}"

echo
echo "==================================================="
echo "  Ollama + Open WebUI"
echo "==================================================="
echo

require_jetpack_6
require_command docker "Run 02-base-system/01-base-bootstrap.sh first"
echo

# ── 1. Install Ollama ─────────────────────────────────────────
info "Step 1/4: Ollama"
if command -v ollama >/dev/null 2>&1; then
    ok "Ollama already installed: $(ollama --version 2>&1 | head -1)"
    info "Updating to latest..."
    curl -fsSL https://ollama.com/install.sh | sh
else
    info "Installing Ollama (this configures a systemd service automatically)"
    curl -fsSL https://ollama.com/install.sh | sh
fi
sudo systemctl enable ollama
sudo systemctl start ollama
sleep 3
if curl -sf http://localhost:11434/api/tags >/dev/null; then
    ok "Ollama daemon responding on port 11434"
else
    fail "Ollama installed but daemon not responding. Check: sudo journalctl -u ollama"
    exit 1
fi
echo

# ── 2. Pull starter model ─────────────────────────────────────
info "Step 2/4: Starter model — $DEFAULT_MODEL"
if ollama list 2>/dev/null | grep -q "^${DEFAULT_MODEL}"; then
    ok "$DEFAULT_MODEL already pulled"
else
    info "Pulling $DEFAULT_MODEL (~2-3 GB, several minutes)"
    ollama pull "$DEFAULT_MODEL"
    ok "$DEFAULT_MODEL pulled"
fi
echo

# ── 3. Open WebUI in Docker ───────────────────────────────────
info "Step 3/4: Open WebUI (Docker)"
if sudo docker ps -a --format '{{.Names}}' | grep -qx open-webui; then
    info "Stopping/removing existing open-webui container"
    sudo docker rm -f open-webui >/dev/null
fi

# Open WebUI talks to Ollama via host networking (simpler than bridge + IP juggling)
sudo docker run -d \
    --name open-webui \
    --restart unless-stopped \
    --network host \
    -e OLLAMA_BASE_URL=http://localhost:11434 \
    -e WEBUI_PORT="$WEBUI_PORT" \
    -v open-webui-data:/app/backend/data \
    ghcr.io/open-webui/open-webui:main
ok "Open WebUI container started"
echo

# ── 4. Health check ───────────────────────────────────────────
info "Step 4/4: Health check"
sleep 8
if curl -sf "http://localhost:$WEBUI_PORT/health" >/dev/null 2>&1 || \
   curl -sf "http://localhost:$WEBUI_PORT/" >/dev/null 2>&1; then
    ok "Open WebUI responding on port $WEBUI_PORT"
else
    warn "Open WebUI not yet responding — first start can take 30s. Check: sudo docker logs open-webui"
fi
echo

# ── Done ──────────────────────────────────────────────────────
JETSON_IP="$(hostname -I | awk '{print $1}')"
echo "==================================================="
ok "Install complete"
echo "==================================================="
info "Web UI:  http://${JETSON_IP}:${WEBUI_PORT}"
if command -v tailscale >/dev/null 2>&1; then
    TS_IP="$(tailscale ip -4 2>/dev/null | head -1 || true)"
    [ -n "$TS_IP" ] && info "Web UI (Tailscale): http://${TS_IP}:${WEBUI_PORT}"
fi
info "First user to register becomes admin."
info ""
info "Pull more models:"
info "  ollama pull llama3:8b-instruct-q4_0"
info "  ollama pull gemma2:2b"
info "  ollama list"
