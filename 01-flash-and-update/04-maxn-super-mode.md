# 04 — MAXN Super power mode

The Jetson Orin Nano Super can run at **25W** (MAXN Super power mode), but ships at lower power modes by default. Bumping it to MAXN Super gives you noticeably more performance — roughly 1.7× the GPU compute and TFLOPS — at the cost of a bit more heat and a louder fan.

For Hydra Detect, Ollama, ComfyUI, and basically anything compute-heavy: **you want MAXN Super.**

## What modes are there

```bash
sudo nvpmodel -q --verbose
```

This lists every power mode your Jetson supports. On Orin Nano Super you'll see:

| Mode | Name | Wattage | Notes |
|---|---|---|---|
| 0 | MAXN_SUPER | up to 25W | What you want — highest performance |
| 1 | 15W | 15W | Original Orin Nano default |
| 2 | 7W | 7W | Power-constrained, very slow |

The current mode is shown in the same output.

## Switch to MAXN Super

```bash
sudo nvpmodel -m 0
```

Confirm:

```bash
sudo nvpmodel -q
# Expected: NV Power Mode: MAXN_SUPER
```

The change is immediate and survives reboots.

## Lock clocks high (optional)

`nvpmodel` sets the *ceiling*. By default the Jetson dynamically scales down when idle. For sustained workloads (Hydra running 24/7, an Ollama session, a ComfyUI render) you usually want clocks pinned high:

```bash
sudo jetson_clocks
```

This locks GPU/CPU clocks at their max for the current power mode. **It does NOT survive reboot.** If you want it on every boot, add to `/etc/rc.local` or a systemd service. For most people, running it manually before a session is fine.

To go back to dynamic scaling without rebooting:

```bash
sudo jetson_clocks --restore
```

(`jetson_clocks` writes the previous state to `~/l4t_dfs.conf` when first run, and `--restore` reads from there.)

## What to expect

- **Fan:** more aggressive. The stock fan is loud at MAXN Super; not a defect.
- **Heat:** the heatsink will be hot to the touch under sustained load. Normal.
- **Throttle point:** Orin Nano starts thermal-throttling around 80°C. If you're hitting that consistently, improve airflow.
- **Power draw:** a higher-quality power supply matters more here. The official 5V/3A adapter is fine. Random USB-C cables and chargers will undervolt and reboot.

## Verify with `tegrastats`

Run `tegrastats` to see live CPU/GPU usage and temps. Useful if you want to confirm the Jetson is actually using the headroom MAXN Super gives it.

```bash
sudo tegrastats --interval 1000
```

Press Ctrl+C to stop. You're looking for:
- `RAM` — how much of the 8 GB is used
- `GR3D_FREQ` — GPU frequency, should be ~1020 MHz under load on MAXN Super
- `tj@` — junction temperature, keep below 80°C

## Done

You're now on JetPack 6.x at full power. Continue to `02-base-system/`.
