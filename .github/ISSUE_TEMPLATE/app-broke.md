---
name: App install / runtime broke
about: Something in 02-base-system/ or 04-apps/ failed
title: "[APP] "
labels: app
---

## Which app / script

- [ ] `02-base-system/01-base-bootstrap.sh`
- [ ] `02-base-system/verify.sh`
- [ ] `04-apps/hydra-detect/install.sh`
- [ ] `04-apps/ollama/install.sh`
- [ ] `04-apps/comfyui/install.sh`
- [ ] Other (specify):

## What happened

Concrete symptom + at which step the install / run failed.

## Preflight output

Paste the output of `bash scripts/preflight.sh`.

```
(paste here)
```

## Error / log

If the install script crashed:
```
(paste the last ~50 lines of output)
```

If the app runs but doesn't behave right:
```bash
# For Hydra:
sudo docker logs hydra-detect | tail -100
# For Ollama:
sudo journalctl -u ollama -n 100
# For ComfyUI:
sudo journalctl -u comfyui -n 100   # if using systemd unit
```

## Hardware + state

- JetPack version: `cat /etc/nv_tegra_release | head -1`
- Power mode: `sudo nvpmodel -q | head -2`
- Disk free: `df -h /`
- Memory: `free -h`

```
(paste here)
```

## What you tried

What have you already tried from the relevant `install.md` troubleshooting section?

## SORCC class

Which class did you attend? (CLS X, year)
