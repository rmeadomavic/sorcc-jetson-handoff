# What you have

You left SORCC with an **NVIDIA Jetson Orin Nano Super 8GB** dev kit. This page is a quick anatomy lesson so the rest of the docs make sense.

## The board itself

The dev kit is two parts:

- **The carrier board** — the green PCB with all the ports. This is what you plug things into.
- **The compute module** — the small board piggybacked on top with the heatsink. This is the actual Jetson. Don't unscrew it unless you have a reason.

## Ports you'll use

Looking at the carrier board with the big heatsink facing up:

| Port | Used for |
|---|---|
| **microSD slot** | Underneath the carrier board, on the bottom. This is where your operating system lives. |
| **USB-C (power)** | Power input. The official 5V/3A USB-C adapter goes here. |
| **USB-C (data, only on some kits)** | Some boards have a second USB-C for data — used for flashing in recovery mode. |
| **HDMI / DisplayPort** | Plug a monitor here for the first-boot wizard. |
| **USB-A x4** | Keyboard, mouse, USB camera, USB-to-flight-controller cable. |
| **Ethernet (RJ-45)** | Network. Use this for the QSPI step if your Wi-Fi is iffy. |
| **40-pin GPIO header** | The big header along one edge. This is where you wire a flight controller. See `03-hardware/`. |
| **Power button + recovery button** | Two small buttons on the side. You will rarely touch these. |

## What you also got from class

- **microSD card** with the SORCC golden image (already flashed)
- **Power supply** (5V / 3A USB-C — do not substitute a phone charger, it'll undervolt)
- **USB camera** (Logitech C270 or C920) for Hydra detection
- (Maybe) **Pixhawk 6C flight controller + telemetry cable** if your platform was a quad / boat / rover
- (Maybe) **NooElec NESDR Smart v5 RTL-SDR dongle** for RF homing experiments

## What "Super" means

The Orin Nano Super is the hardware refresh that NVIDIA released in late 2024. It's the same compute module as the original Orin Nano but unlocked to **25W (MAXN Super)** instead of capped at 15W. The original boards can be upgraded to Super capability via a JetPack 6.1+ flash (which is what this repo walks you through).

If you're not sure whether you have the Super hardware: it doesn't matter. The flash process is the same either way. Once you're on JetPack 6.x, you can switch to MAXN Super power mode and the board will use it if it's capable.

## Where to find your serial number

If you ever need to RMA the board (NVIDIA support, warranty), the serial is on a sticker on the underside of the carrier board. Take a photo of it before you put the board in a case.
