# 04 — Apps

Pick what you want. These are independent — installing one does not require any of the others.

| Folder | What it is | Disk | Memory | When to install |
|---|---|---|---|---|
| `hydra-detect/` | YOLO + ByteTrack object detection, MAVLink alerts, web dashboard, RTSP stream. Built for SORCC platforms. | ~7 GB | 2-3 GB | If you have a Pixhawk and want what you used in class |
| `ollama/` | Local LLM serving (Llama, Phi, Gemma, etc) + Open WebUI for chat | ~5-15 GB depending on models | 4-8 GB during inference | If you want a local ChatGPT-style chat with no cloud |
| `comfyui/` | Stable Diffusion / SDXL image generation, node-graph UI | ~10 GB base + 7+ GB per model | 6-8 GB during generation | If you want local AI image generation. Tight on 8 GB shared RAM. |

## Before you install anything

```bash
bash scripts/preflight.sh
```

If preflight fails, fix the listed issues before continuing. Most blockers are in `02-base-system/`.

## What "idempotent" means here

Every `install.sh` in this folder is safe to re-run. If the app is already installed, the script will:

- Detect it
- Check for updates if relevant
- Re-apply any config it manages
- Not break your existing data

So when in doubt, re-run the installer rather than manually patching.

## Memory budget reality check

The Jetson Orin Nano Super has **8 GB of shared CPU/GPU RAM**. That's the budget for:

- Linux + Docker daemon (~1-1.5 GB)
- Whatever you're running

You can comfortably run **one** of these at a time. Trying to run Hydra + ComfyUI + a 7B Ollama model concurrently will swap to disk and become unusably slow.

A reasonable strategy: use systemd or just stop containers you're not actively using. `docker stop hydra-detect` is your friend.

## Where Docker images live

By default Docker stores images at `/var/lib/docker/`. On a 64 GB SD card with multiple apps installed, you'll fill it up. To move Docker storage to an external SSD, see the [NVIDIA Jetson Linux Developer Guide on Docker storage](https://docs.nvidia.com/jetson/jetson-linux/) (out of scope here, but easy to find).
