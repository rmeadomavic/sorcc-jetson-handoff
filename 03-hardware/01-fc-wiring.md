# 01 — Wiring a Pixhawk flight controller

If your platform from class was a quad, fixed-wing, rover, or boat, your Jetson talks to a Pixhawk flight controller over a serial connection. This page covers the wiring. The MAVLink test is in `02-test-mavlink.md`. The Pixhawk's own ArduPilot parameters were configured in class — they're not covered here.

> **Skip this whole section** if you don't have a Pixhawk, or if your Jetson is purely a compute payload (Ollama, ComfyUI, no vehicle).

## Two connection options

You'll use one of these depending on the situation:

| Option | When to use | Connector | Speed |
|---|---|---|---|
| **USB-C** | Bench testing, fault-finding, no flight | USB-C cable, Pixhawk to Jetson | 115200 baud (virtual serial) |
| **TELEM2 UART** | Field deployment, on-vehicle | 6-pin JST-GH cable + 3 dupont jumpers | 921600 baud |

**USB-C is the easy path.** Plug a USB-C cable from the Pixhawk to a Jetson USB port, the Pixhawk shows up as `/dev/ttyACM0`. Done. Use this for first-time testing.

**TELEM2 UART is the field path.** You can't keep a USB-C cable dangling on a vehicle, so for real flights/runs you wire 3 jumpers from the Jetson's 40-pin GPIO header to the Pixhawk's TELEM2 port. This is what the rest of this page covers.

> **Power warning, both paths:** Do NOT power the Pixhawk from both USB and the vehicle battery at the same time. USB power backfeeds the Pixhawk's voltage rails and can damage them. For bench work: power the Pixhawk *only* via USB (motors won't spin without battery, which is what you want). For flight: battery only, no USB.

## TELEM2 UART wiring

Three wires, that's it. The other three pins of the JST-GH cable are unused for this.

| Jetson 40-pin header | Pixhawk TELEM2 (JST-GH 6-pin) | What it does |
|---|---|---|
| **Pin 8 (UART1 TX)** | Pin 3 (RX, Pixhawk's input) | Jetson talks to Pixhawk |
| **Pin 10 (UART1 RX)** | Pin 2 (TX, Pixhawk's output) | Pixhawk talks to Jetson |
| **Pin 6 (GND)** | Pin 6 (GND) | Common ground (required) |

**Important:** TX always crosses to RX. Jetson TX (pin 8) → Pixhawk RX (pin 3). If you wire TX-to-TX, nothing works and there's no error message — it just silently doesn't connect.

The Pixhawk side labels (TX, RX) are from the **Pixhawk's** perspective. So Pixhawk's "TX" is its output, which goes to your input (Jetson RX). Easy to flip if you read them as Jetson-side labels.

See `fc-wiring-diagram.svg` for a picture, and `jetson-40pin-pinout.svg` for the 40-pin header layout.

## Logic levels — both 3.3V

The Jetson 40-pin GPIO header runs at **3.3V logic**. The Pixhawk TELEM2 also runs at **3.3V logic**. They wire directly together — **no level shifter required**.

You may see other docs claiming the Jetson UART is 1.8V — that's a different UART (the debug UART), not the one on the 40-pin header. The pin 8/10 UART that this page uses is 3.3V and tested working with no level shifter (heartbeat received in <2 seconds, multiple field sessions).

If you wire it and get nothing, the cause is almost always TX/RX swapped or a missing GND, not a logic-level mismatch.

## Cable options

You have a few choices for the actual physical cable:

1. **The cable that came with your Pixhawk.** Most Pixhawk 6C kits ship with a 6-pin JST-GH-to-loose-pin "telemetry" cable. Trim/strip the 3 wires you need (TX, RX, GND), terminate them with female dupont connectors, plug them onto the Jetson header.
2. **JST-GH-to-Dupont harness from the Holybro store** — pre-terminated, prettiest option.
3. **Build your own** with a JST-GH crimp kit if you have one.

Don't try to solder directly to the Jetson header pins. The pins are short and the carrier board is delicate.

## Identifying the right pins

The Jetson 40-pin header is right next to the heatsink. Pin 1 is at the corner closest to the SD card slot, marked with a tiny silkscreen "1" or a square pad (the rest are round).

Counting from pin 1:
- Pin 6 = GND (3rd row, side closest to the board edge)
- Pin 8 = UART1 TX (4th row, side closest to the board edge)
- Pin 10 = UART1 RX (5th row, side closest to the board edge)

If you put pin 1 in the wrong corner, you'll wire to pins 33, 35, 37 by accident. If MAVLink doesn't connect, double-check pin 1 orientation before debugging anything else.

## Once it's wired

Continue to `02-test-mavlink.md` to confirm the connection works.
