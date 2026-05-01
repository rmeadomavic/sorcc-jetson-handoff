# What you need

Gather all of this before you start the flash process. Stopping halfway because you don't have a USB-C cable is annoying.

## Required for everyone

- **Your Jetson Orin Nano Super dev kit** (with carrier board, compute module, heatsink)
- **The SORCC microSD card** (or a fresh 64 GB+ UHS-I card if you've lost it)
- **A second microSD card**, 32 GB or larger — temporary, used for the QSPI update step. Reusable after.
- **The USB-C power supply** that came with your kit (5V / 3A). A phone charger will undervolt and cause weird crashes — do not skip this.
- **A monitor** with HDMI or DisplayPort
- **A USB keyboard and mouse**
- **An Ethernet cable or known-good Wi-Fi network** for the package downloads
- **A host computer** (Windows / Mac / Linux) with:
  - A microSD card reader
  - **[Balena Etcher](https://etcher.balena.io/)** installed (free, cross-platform)
  - Internet (you'll be downloading 8-15 GB total)
- **Time:** budget 90 min for the flash + base setup. Apps in `04-apps/` add another 15-60 min each.

## Required only if you're wiring a flight controller

- **Pixhawk 6C** (or compatible ArduPilot FC)
- **Pixhawk JST-GH TELEM2 cable** (came with your Pixhawk; 6-pin)
- **Three jumper wires (female-to-female, dupont)** OR a custom JST-GH-to-Dupont harness
  - You only need 3 wires of the 6: TX, RX, GND
- **A USB-C cable** for first-time bench connection (connects Jetson to Pixhawk)

## Required only if you'll use SDR / Kismet RF features

- **NooElec NESDR Smart v5** (RTL-SDR, the blue one with the case) or any other RTL2832U-based dongle
- **An SMA antenna** appropriate for your band (the stock one works for 433/915 MHz)

## Files you will download

These show up at specific steps in the flash docs. Don't pre-download — Etcher is happiest if the file is fresh:

- **JetPack 5.1.3 SD card image** — needed for the QSPI step. From [NVIDIA Jetson Downloads](https://developer.nvidia.com/embedded/downloads). Filename ends in `.img.xz`.
- **JetPack 6.x SD card image** — your final OS. From the same page. Currently 6.2.1.
- (Optional) **The SORCC golden image** — if Kyle gives you a copy, this skips the JetPack 6 + Hydra install steps.

## Network notes

- The Jetson will pull ~6 GB of Docker images during `02-base-system/` and again per app in `04-apps/`. Don't do this on a metered connection.
- The QSPI step needs apt to reach NVIDIA's package repo. If you're on a captive-portal network (hotel, coffee shop), the apt install will silently fail. Use a phone hotspot or home Wi-Fi.

## What you do NOT need

- Any cloud account (GitHub, Google, Anthropic)
- Any paid software
- A second computer beyond the host you're using to flash the SD card
- The original SORCC laptop / GCS — your Jetson is standalone now
