# 01 — QSPI bootloader update

> **Read this entire page before starting.** The two callouts below are the things that fail most often. Both have bitten students.

> **TRAP 1 — Lowercase L:** The package name is `nvidia-l4t-jetson-orin-nano-qspi-updater`. That's a lowercase **L**, not a **number 1**. If you mistype it, apt says "Unable to locate package" and you'll spend 20 minutes wondering why.
>
> **TRAP 2 — Single-shot install:** The QSPI updater only fires its post-install hook the *first* time it's installed on a given SD card. If you reuse a JP 5.1.3 card on a second Jetson, you must add `--reinstall` or it'll be a silent no-op.

## What and why

Brand-new Jetson Orin Nano dev kits ship with old QSPI firmware (the bootloader baked into the on-board flash) that physically cannot boot a JetPack 6.x SD card. The board powers on and just sits there with a blank screen.

The fix is to boot a JetPack 5.1.3 SD card *first*, run an apt package that flashes new QSPI firmware during reboot, then swap to your JetPack 6.x card.

The whole process takes about 30 minutes per board.

## What you need

- The Jetson, monitor, keyboard, USB-C power supply (see `00-before-you-start/what-you-need.md`)
- A microSD card (the temporary one, 32 GB+) flashed with **JetPack 5.1.3**
- Internet for the Jetson (Wi-Fi or Ethernet)

### Get the JetPack 5.1.3 image

1. Go to <https://developer.nvidia.com/embedded/downloads>
2. Search for **"JetPack 5.1.3 SD Card Image"** — there's an Orin Nano Developer Kit version. Download it.
3. The file ends in `.img.xz`. Etcher can flash `.img.xz` directly — no need to extract.
4. Open Etcher → Flash from file → pick the `.img.xz` → select your microSD card → Flash. Takes 10-15 min.

## The procedure

### Step 1 — Boot the JP 5.1.3 card

1. Insert the JP 5.1.3 microSD into the Jetson (slot is on the underside of the carrier board).
2. Plug in monitor, keyboard, USB-C power. The board boots.
3. Walk through the Ubuntu first-boot wizard. **Use `sorcc` for username and `sorcc` for password.** This matches what `02-flash-jp6` will use later — keeps your muscle memory simple.
4. Wait for the desktop to load.

### Step 2 — Install the QSPI updater

Open a terminal: **Ctrl+Alt+T**.

```bash
sudo apt-get update
sudo apt-get install nvidia-l4t-jetson-orin-nano-qspi-updater
```

> **Triple-check the package name.** `nvidia-l4t-jetson-orin-nano-qspi-updater` — the `l4t` part is lowercase letter L + 4 + lowercase letter T. Tab completion is your friend: type `nvidia-l4t-` and press Tab.

If apt says "Unable to locate package":
- Did you run `sudo apt-get update` first? Required.
- Are you on Wi-Fi that has a captive portal (hotel, coffee shop)? Switch to a hotspot or home network.
- Is your package name actually correct? Type `apt search qspi-updater` to verify.

### Step 3 — Reboot

```bash
sudo reboot
```

The Jetson will reboot, then start flashing the QSPI firmware. **The screen will go blank, or you'll see a UEFI prompt, and the board will halt.** This is exactly what's supposed to happen — do not touch anything.

Wait at least 60 seconds after the screen goes blank.

### Step 4 — Power down

Unplug the USB-C power supply. The board is now done with the QSPI update.

You can now remove the JP 5.1.3 SD card and continue to `02-flash-jetpack-6.md`.

## Verifying the update worked

You can't easily verify QSPI from JP 5.1.3 (the whole point is that the version on the board doesn't match what's on the card). The real test: does the Jetson boot the JP 6.x card after the swap? If yes, the QSPI update worked. If no, see the troubleshooting section.

After you boot JetPack 6.x successfully:

```bash
cat /etc/nv_tegra_release
# Expected first line: # R36 (release), REVISION: 4.x, ...
```

If you see `R36` here, the QSPI is current.

## Troubleshooting

### `Unable to locate package nvidia-l4t-jetson-orin-nano-qspi-updater`

Almost always one of:
1. Lowercase L vs number 1 typo — the most common. Use tab completion.
2. You skipped `sudo apt-get update` — required, packages aren't visible until apt refreshes its index.
3. No internet — captive portal, broken DNS, dead Wi-Fi. Test with `ping 8.8.8.8`.

### Board does NOT halt — reboots back into JP 5.1.3 desktop

The post-install hook didn't fire. Re-run with `--reinstall`:

```bash
sudo apt-get install --reinstall nvidia-l4t-jetson-orin-nano-qspi-updater
sudo reboot
```

### Board halts, but the JP 6.x card still won't boot afterward

This is the case that bit one student in CLS 8 — QSPI looked successful but JP 6 still failed.

Try in order:
1. **Re-flash the JP 6.x SD card** with Etcher. Use **verify enabled**. A bad flash is more common than a bad QSPI update.
2. Try a **different SD card** — UHS-I or faster, 64 GB+. Cheap or counterfeit cards fail in weird ways.
3. **Re-do the QSPI step with `--reinstall`** even though the first run looked successful. Costs 10 minutes, sometimes fixes it.
4. If you've done all three: file an issue with the `flash-broke.md` template. Include the output of `dmesg` from a JP 5.1.3 boot.

### The board boots straight into JP 6.x without halting

Lucky you — this Jetson already had a recent QSPI. Skip ahead to `02-flash-jetpack-6.md`.
