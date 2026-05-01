# Troubleshooting — flash and update

Failure modes that actually happen, in order of how often they bite people.

## "I did the QSPI update, but JetPack 6 still won't boot"

This is the case that bit a CLS 8 student. The fix sequence:

1. **Re-flash the JP 6 SD card with verify enabled.** Use Etcher. A bad flash is more common than a failed QSPI update.
2. **Try a different SD card.** Stick to UHS-I 64 GB+ from a known brand.
3. **Re-do the QSPI step with `--reinstall`** even though step 1 of the QSPI procedure looked successful:
   ```bash
   sudo apt-get install --reinstall nvidia-l4t-jetson-orin-nano-qspi-updater
   sudo reboot
   ```
   Wait for the halt. Power down. Try the JP 6 card again.
4. **Different USB-C power supply.** Some chargers / cables undervolt at boot and the bootloader bails.
5. If still stuck: file an issue with the `flash-broke.md` template. Include `dmesg` output from a JP 5.1.3 boot.

## "Unable to locate package nvidia-l4t-jetson-orin-nano-qspi-updater"

Three causes, in order of probability:

1. **Typo:** lowercase L, not number 1. Use tab completion.
2. **Forgot `sudo apt-get update`** before the install.
3. **Captive-portal Wi-Fi:** hotel, coffee shop, conference center. Switch to a phone hotspot or actual home Wi-Fi.

## "JetPack 6 boots, I see the NVIDIA logo, then a black screen"

X server failed to start. Often a display compatibility issue.

1. Try a different HDMI cable.
2. Try a different monitor (some 4K TVs do weird things with the Jetson's display output).
3. SSH in if Wi-Fi was configured: `ssh sorcc@<jetson-ip>`. If SSH works, the Jetson is healthy and only the display is broken — re-attach a monitor at boot, the connection sometimes only initializes during early boot.

## "First-boot wizard hangs at the Wi-Fi step"

Some Wi-Fi networks just don't work with the Jetson's onboard radio (5 GHz channel issues, captive portals, enterprise WPA2-Enterprise).

- Use Ethernet during setup; switch to Wi-Fi later.
- Or skip Wi-Fi entirely (the wizard lets you), then configure it after first boot via `nmtui`.

## "Software Updater says 'Failed to download package files'"

The post-install update is large. Common causes:
- Patchy Wi-Fi → switch to Ethernet, retry.
- Disk full → `df -h /`, you should have at least 30 GB free on a fresh JP 6 install.
- Mirror flake → `sudo apt-get update` then `sudo apt-get upgrade -y` from a terminal manually. Fewer dependencies than the GUI updater pulls.

## "Docker isn't installed after first boot"

Some JetPack images do, some don't. If `docker --version` fails:
- Skip ahead to `02-base-system/01-base-bootstrap.sh` — it installs Docker as part of the base setup.

## "I want to start over"

Reflashing the SD card is always safe. The Jetson hardware doesn't store any state across reflashes (except the QSPI firmware itself, which is what you actually wanted to update).

```
1. Power down the Jetson.
2. Pull the SD card.
3. Re-flash JP 6 with Etcher (verify enabled).
4. Re-insert, power on. You're back at first boot.
```

## "I bricked the Jetson by interrupting the QSPI flash"

Probably not. The QSPI flash is fairly resilient — interrupting it usually just means the update didn't complete and you'll need to re-run.

If the board is completely unresponsive (no power LED, no boot text on monitor, no USB enumeration on a host PC), you may be in the territory of needing NVIDIA's force-recovery mode and using SDK Manager from a Linux x86 host. That's beyond the scope of this repo — file an issue and include exactly what you did.

## "Where's the Hydra software / golden image / ComfyUI?"

Not here yet — those are in `04-apps/`. You first need a JetPack 6 system with the `02-base-system/` bootstrap done.
