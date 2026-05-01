# SORCC Jetson Keeper

Private guide for SORCC graduates who left class with a Jetson Orin Nano Super 8GB. Walks you from a stock dev kit (JetPack 5.1.x) all the way to JetPack 6.x in MAXN Super power mode, then lets you install whichever pieces of the SORCC "golden image" stack you actually want.

If your Jetson came home from class **already running Hydra**, you only need this repo when something breaks, you reformat the SD card, or you want to add a new app (Ollama, ComfyUI, etc).

## The happy path

```
   ┌────────────────┐    ┌─────────────┐    ┌──────────────┐    ┌──────────┐    ┌────────────┐
   │ Stock JP 5.1.x │ →  │ QSPI update │ →  │ Flash JP 6.x │ →  │ MAXN     │ →  │ Apps you   │
   │ dev kit        │    │             │    │ + first boot │    │ Super on │    │ care about │
   └────────────────┘    └─────────────┘    └──────────────┘    └──────────┘    └────────────┘
       you start                              walks you through                   pick & install
        here                                  the Ubuntu wizard                   (Hydra/Ollama
                                                                                   /ComfyUI)
```

Each section is its own folder. Read in order the first time. After that, jump where you need.

| Section | What it covers | Time |
|---|---|---|
| `00-before-you-start/` | What's in the box, what you need to gather, when to ask for help | 5 min |
| `01-flash-and-update/` | QSPI bootloader update, flashing JetPack 6.x, first boot wizard, MAXN Super | ~90 min |
| `02-base-system/` | Docker, NVIDIA container toolkit, group permissions, optional Tailscale | ~20 min |
| `03-hardware/` | (Optional) Wiring a Pixhawk flight controller — pinout + diagram | ~30 min |
| `04-apps/` | Independent installers for Hydra Detect, Ollama + Open WebUI, ComfyUI | ~15-60 min each |

## Quick check: what do you have?

Run this on your Jetson at any time. It tells you exactly which step you're on.

```bash
bash scripts/preflight.sh
```

If preflight passes, skip to `04-apps/` and pick what you want to install. If it fails, it'll tell you which doc to read.

## Hardware scope

This repo covers exactly **one** configuration:

- **NVIDIA Jetson Orin Nano Super 8GB** (the dev-kit carrier board)
- **JetPack 6.x** (currently 6.2.1, L4T R36.4.x)
- **MAXN Super power mode** (25W)

Other Jetsons (Nano 4GB, NX, AGX) might mostly work but aren't tested. The 4GB Nano in particular will run out of memory on the Ollama and ComfyUI sections.

## Support

This is a self-serve repo. The first place to look when something breaks is `01-flash-and-update/troubleshooting.md` and the `app-broke.md` issue template.

If you're truly stuck, file an issue using one of the templates in `.github/ISSUE_TEMPLATE/`. Read `00-before-you-start/support.md` first — there's a list of what info to include and what's out of scope.

Stuff that's out of scope here:
- AX12 / radio setup → separate repo (coming soon)
- Raspberry Pi (SORCC kit Pi) → separate repo (coming soon)
- Building Hydra Detect from source, contributing PRs → goes in the Hydra repo
- ArduPilot parameter tuning → covered by your SORCC curriculum slides

## The known traps

If you only read three things in this repo, read these. Each one has bitten a real student.

1. **The QSPI update has to happen first.** Brand new Orin Nanos can't even boot a JetPack 6 SD card until you update the QSPI bootloader from a JetPack 5.1.3 card. See `01-flash-and-update/01-qspi-update.md`.
2. **The package name has a lowercase L, not a 1.** `nvidia-l4t-jetson-orin-nano-qspi-updater` — that's `l4t`, not `14t`. Common typo, fails with "Unable to locate package".
3. **The QSPI updater is a one-shot per device.** If you reuse the same JP 5.1.3 SD card on a second Jetson, you must add `--reinstall` or the post-install hook won't fire and the QSPI stays untouched.
