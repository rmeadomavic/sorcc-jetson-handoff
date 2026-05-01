# 02 — Test MAVLink

You wired the Pixhawk to the Jetson per `01-fc-wiring.md`. Time to confirm the link works before you put any software in front of it.

## What you need

- Pixhawk wired to Jetson per `01-fc-wiring.md`
- Pixhawk powered (battery, or USB if bench testing — never both)
- The user `sorcc` already in the `dialout` group (handled by `02-base-system/01-base-bootstrap.sh`)

## Step 1 — Confirm the device exists

```bash
# For USB-C bench connection:
ls /dev/ttyACM*
# Expect: /dev/ttyACM0

# For TELEM2 UART (40-pin header):
ls /dev/ttyTHS*
# Expect: /dev/ttyTHS1
```

If neither shows up:
- USB-C: try a different cable. Some USB-C cables are charge-only.
- UART: re-check pin 1 orientation. Re-check TX/RX aren't swapped. Confirm the Pixhawk is actually powered.

## Step 2 — Install mavproxy

```bash
sudo apt-get update
sudo apt-get install -y python3-pip python3-dev libxml2-dev libxslt-dev
pip3 install --user MAVProxy
```

`mavproxy.py` will end up at `~/.local/bin/mavproxy.py` — already on PATH on JetPack 6.

## Step 3 — Connect

Pick the line that matches your wiring:

```bash
# USB-C connection:
mavproxy.py --master=/dev/ttyACM0 --baudrate=115200

# TELEM2 UART connection:
mavproxy.py --master=/dev/ttyTHS1 --baudrate=921600
```

Within ~2 seconds you should see:

```
Connect /dev/ttyACM0 source_system=255
Log Directory:
Telemetry log: mav.tlog
Waiting for heartbeat from /dev/ttyACM0
MAV> Detected vehicle 1:1 on link 0
online system 1
APM: ChibiOS: ...
APM: ArduRover V4.x.x
APM: ...
GPS lock at 0 meters    (or "no GPS" if indoors)
Mode MANUAL
```

If you see the `APM:` lines, the link is up. Hit **Ctrl+D** then `exit` to quit.

## Common failure modes

### "Waiting for heartbeat from..." forever

- TX/RX swapped on TELEM2 UART. Most common. Swap pin 8 and pin 10.
- Pixhawk not powered, or in bootloader mode (boot it normally with battery or USB-only).
- Wrong baud rate. USB is 115200, TELEM2 is 921600.
- `SERIAL2_PROTOCOL` on the Pixhawk isn't set to MAVLink2 (`= 2`). Should already be set from class. If not: see SORCC curriculum or the Pixhawk doc in the Hydra repo.

### "Permission denied: '/dev/ttyACM0'"

You're not in the `dialout` group. Either:

```bash
sudo usermod -aG dialout sorcc
# Log out and back in, or:
newgrp dialout
```

Or re-run `02-base-system/01-base-bootstrap.sh` which adds you automatically.

### Heartbeat works briefly, then drops

- Loose dupont connector — try wiggling the wires while watching the output.
- Bad ground (pin 6 not actually connected). Always wire GND.
- USB cable is marginal — try a known-good cable.

### `mavproxy.py: command not found`

`pip3 install --user` puts binaries in `~/.local/bin`. On most JetPack 6 setups this is on PATH automatically; if not:

```bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

## Once MAVLink works

You're ready for `04-apps/hydra-detect/`, which uses this same connection.

If you only want the Jetson for compute (Ollama / ComfyUI without a vehicle), you don't need any of this. Skip to `04-apps/`.
