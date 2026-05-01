# 02 — Base system

After this section, your Jetson has Docker, the NVIDIA container runtime, the right group permissions, and (optionally) Tailscale for remote access.

Every app in `04-apps/` assumes you've finished this section.

## Quick path

```bash
# From the repo root, on your Jetson:
bash 02-base-system/01-base-bootstrap.sh
```

That installs Docker, NVIDIA Container Toolkit, adds you to the `docker` and `dialout` groups, and sets up the `dustynv/l4t-pytorch:r36.4.0` base image (~6 GB pull). The script is **idempotent** — safe to re-run, won't double-install or break existing setup.

After it finishes, **log out and back in** (or run `newgrp docker`) so the group changes apply.

Then verify:

```bash
bash 02-base-system/verify.sh
```

If verify is green, continue to `02-tailscale.md` (optional but recommended) or skip to `04-apps/`.

## What gets installed

| Component | Why | Script step |
|---|---|---|
| `apt update` + upgrade | Base hygiene | 1 |
| `docker-ce` | Container runtime | 2 |
| `nvidia-container-toolkit` | Lets containers see the GPU | 3 |
| `dustynv/l4t-pytorch:r36.4.0` | Pre-built CUDA + PyTorch + TensorRT base image (~6 GB) | 4 |
| `$USER` in `docker` group | So you can `docker run` without sudo | 5 |
| `$USER` in `dialout` group | So Hydra can talk to a Pixhawk on `/dev/ttyACM0` | 5 |
| Swap file (8 GB) | The 8 GB shared RAM fills up fast under load | 6 |

## Files

- `01-base-bootstrap.sh` — does everything above
- `02-tailscale.md` — install + configure Tailscale for remote access (optional)
- `verify.sh` — checks all of the above worked

## What this section does NOT do

- No app installs (Hydra, Ollama, ComfyUI). Those are in `04-apps/`.
- No flight controller wiring. That's `03-hardware/`.
- No platform-specific config (callsign, hostname, etc). The original golden image had a `platform-setup.sh` for that — for a personal Jetson, you usually don't need per-unit identity.
