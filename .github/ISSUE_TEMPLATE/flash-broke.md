---
name: Flash / QSPI / first-boot broke
about: Something in 01-flash-and-update/ failed
title: "[FLASH] "
labels: flash
---

## What you were doing

Which step were you on? Paste the filename + section. Example:
> `01-flash-and-update/01-qspi-update.md` → Step 3, after `sudo reboot`

## What happened

Describe the actual symptom. The more concrete the better.
- "Screen went black and stayed black for 10 minutes"
- "Got error message: `Unable to locate package nvidia-...`"
- "Board halted but JP6 card still doesn't boot — re-flashed twice"

## What you tried

List what you've already tried from `troubleshooting.md` so we don't suggest the same things.

- [ ] Re-flashed the SD card with Etcher verify enabled
- [ ] Tried a different SD card
- [ ] Re-ran QSPI step with `--reinstall`
- [ ] Tried different USB-C power supply
- [ ] Checked for typos in the package name (lowercase L)

## Hardware

- Jetson model: Orin Nano Super 8GB / other
- SD card: brand + size
- Host PC OS (for flashing): Windows / Mac / Linux
- Power supply: official NVIDIA / other (specify)

## Logs / output

Paste relevant terminal output here. If you can SSH into the Jetson, run:

```bash
cat /etc/nv_tegra_release
dmesg | tail -100
```

and paste the output below.

```
(paste here)
```

## SORCC class

Which class did you attend? (CLS X, year)
