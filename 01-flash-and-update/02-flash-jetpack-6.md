# 02 — Flash JetPack 6.x

You've done the QSPI update. Now you flash your real, permanent operating system to a microSD card and boot it.

## What you need

- A microSD card, **64 GB+ recommended, UHS-I (Class 10) or faster**
- Etcher on your host PC (Windows / Mac / Linux)
- The JetPack 6.x SD card image — see below

### Get the JetPack 6.x image

1. Go to <https://developer.nvidia.com/embedded/downloads>
2. Find **"JetPack 6.2.1 SD Card Image — Jetson Orin Nano Developer Kit"** (or whatever the latest 6.x is when you read this)
3. Download. The file is ~10 GB and ends in `.img.xz`.

> **About card quality:** The cheapest microSD cards on Amazon are often counterfeit and will fail in weird, intermittent ways. Stick to SanDisk Extreme, Samsung EVO Select, or Kingston Canvas Go from a real retailer. A 64 GB card is fine; 128 GB gives you breathing room for ML models.

## Flash the card

1. Plug the SD card into your host PC's reader.
2. Open Etcher.
3. **Flash from file** → pick the JP 6.x `.img.xz` you downloaded.
4. **Select target** → pick your SD card. Etcher won't let you pick your system drive, but double-check the size matches your SD card.
5. **Flash!** This takes 10-15 min depending on your card speed.
6. When Etcher finishes, it runs a **verify** pass automatically. **Do not skip verify.** A failed verify means a bad flash and you'll save yourself hours by re-flashing now.

## Boot it

1. Eject the SD card from your host PC.
2. Insert it into the Jetson's microSD slot.
3. Plug in monitor, keyboard, mouse, USB-C power.
4. Power on.

You should see the **NVIDIA logo**, then a Linux boot sequence, then the **Ubuntu first-boot wizard**.

If you see nothing — black screen for >2 minutes — your QSPI update probably didn't take. Go back to `01-qspi-update.md` troubleshooting.

If you see Linux boot text but it kernel-panics or hangs — your SD card flash is bad. Re-flash with verify enabled.

If you see the Ubuntu wizard — congratulations, JetPack 6 is alive. Continue to `03-first-boot-oobe.md`.
