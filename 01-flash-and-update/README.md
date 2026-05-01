# 01 — Flash and update

This is the hard part. You're taking your Jetson from a stock-from-NVIDIA dev kit (which ships with old firmware that **cannot boot JetPack 6**) all the way to a fully-updated JetPack 6.x system in MAXN Super power mode.

Do these in order. Don't skip ahead.

## The path

```
┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐    ┌──────────────────┐
│ 01-qspi-update   │ →  │ 02-flash-jp6     │ →  │ 03-first-boot    │ →  │ 04-maxn-super    │
│                  │    │                  │    │                  │    │                  │
│ Update the       │    │ Flash JetPack    │    │ Walk through     │    │ Switch the board │
│ bootloader from  │    │ 6.x to your real │    │ the Ubuntu       │    │ into 25W MAXN    │
│ a JP 5.1.3 SD    │    │ SD card and      │    │ first-boot wizard│    │ Super power mode │
│ card             │    │ boot it          │    │                  │    │                  │
└──────────────────┘    └──────────────────┘    └──────────────────┘    └──────────────────┘
   ~30 minutes            ~20 minutes              ~30 minutes             ~5 minutes
```

When you finish all four, your Jetson is on JetPack 6.x at full power and ready for `02-base-system/`.

## How to know you can skip a step

- **Skip QSPI update** if you've already booted JetPack 6.x on this exact board before. Verify with `cat /etc/nv_tegra_release` — if it starts with `# R36`, you don't need QSPI.
- **Skip flash + first boot** if your Jetson already has a working JetPack 6.x install you don't want to wipe.
- **You probably can't skip MAXN Super** unless you specifically remember setting it. Check with `sudo nvpmodel -q`.

## Stuck?

`troubleshooting.md` in this folder has every failure mode anyone has hit. Read it before you panic.

The single most common failure: the QSPI updater package name has a **lowercase L**, not a **number 1**. `nvidia-l4t-...` not `nvidia-14t-...`. If apt says "Unable to locate package", check this first.
