# ComfyUI

ComfyUI is a node-graph-based UI for Stable Diffusion / SDXL / Flux image generation. Powerful, but tight on the Orin Nano's 8 GB shared RAM.

> **Be honest with yourself first:** the Orin Nano Super is the slowest machine you'd reasonably try to run ComfyUI on. A 1024×1024 SDXL render takes 60-180 seconds. If you want fast image gen, this isn't the box. Use it because you want offline / private / "look it works on a Jetson", not because you want speed.

## What runs and what doesn't

| Pipeline | Memory | Verdict |
|---|---|---|
| **SD 1.5** (512×512) | ~3 GB | Comfortable. The path to take. |
| **SDXL** (1024×1024, base + refiner) | ~7 GB | Tight. Might OOM on first run, retry usually works. Use single-file checkpoint. |
| **SDXL Turbo / Lightning** (1-4 step) | ~5 GB | Best quality-per-second on this hardware. Recommended. |
| **Flux** (any size) | 12+ GB | Doesn't fit. Don't bother. |
| **Video models (CogVideoX, etc.)** | 16+ GB | Doesn't fit. |

For SDXL: use a single-file `safetensors` checkpoint (e.g. `juggernautXL`, `realisticVisionXL`), not the separated UNet/CLIP/VAE setup. Single-file is dramatically more memory-efficient.

## Quick install

```bash
bash 04-apps/comfyui/install.sh
```

The script:

1. Clones ComfyUI into `~/ComfyUI`
2. Sets up a Python venv with the right PyTorch / xformers builds for JetPack 6
3. Installs ComfyUI-Manager (extension manager) for easy custom-node installs
4. Downloads SD 1.5 v1-5-pruned (only ~4 GB) as a known-working starter checkpoint
5. Creates a systemd unit so it auto-starts on boot (optional)

## After install

```
http://<jetson-ip>:8188
```

Drag-drop the default workflow JSON to get started. The Manager tab (right side) lets you install custom nodes.

## Where to put your own checkpoints

```
~/ComfyUI/models/checkpoints/   # base models (.safetensors)
~/ComfyUI/models/loras/         # LoRAs
~/ComfyUI/models/vae/           # VAE files
~/ComfyUI/models/controlnet/    # ControlNet models
```

For SDXL: put `juggernautXL.safetensors` (or whatever) in `models/checkpoints/`. Restart ComfyUI to pick up new files (or use the Manager's refresh).

## Performance tips

- **Use SDXL Turbo / Lightning checkpoints.** 1-4 step generation. Cuts render time from 90s to 5-15s, with surprisingly good quality.
- **Keep batch size at 1.** Memory budget is too tight for batches.
- **Use `--lowvram` flag** (the install script sets this by default) — keeps things off the GPU until needed.
- **Close everything else.** Stop Hydra and Ollama if you're rendering: `sudo systemctl stop hydra-detect ; sudo systemctl stop ollama`.

## OOM (out of memory) errors

These will happen. The Jetson's shared 8 GB is just barely enough for SDXL. When you OOM:

```
RuntimeError: CUDA out of memory.
```

In order of effort:

1. **Hit "Queue" again** — sometimes it just works the second time after the first run leaks settled.
2. **Stop other apps** (Hydra, Ollama, browser tabs).
3. **Drop resolution** to 768×768 or even 512×512 — most SDXL checkpoints are surprisingly tolerant.
4. **Switch to a SD 1.5 model** for the run.
5. **Reboot the Jetson** if memory is genuinely fragmented (rare).

## Stopping / starting

```bash
# If you used the systemd service:
sudo systemctl stop comfyui
sudo systemctl start comfyui

# Manual run:
cd ~/ComfyUI
source venv/bin/activate
python main.py --listen --lowvram
```

## Uninstall

```bash
sudo systemctl disable --now comfyui 2>/dev/null || true
sudo rm -f /etc/systemd/system/comfyui.service
rm -rf ~/ComfyUI
```

## Custom nodes / extensions

Install via ComfyUI-Manager (the right-side panel after install). Most community nodes work on Jetson, but ones that depend on x86-only libraries (some triton kernels, some flash-attention builds) won't. If a node fails to import on startup, check its requirements file for `triton` or x86-specific binaries.
