# 03 — First boot (Ubuntu OOBE wizard)

Ubuntu's "out-of-box experience" wizard runs the first time you boot any fresh JetPack image. It's a series of screens asking about language, network, account, etc. None of it is hard, but a couple of choices matter.

## Walk through the wizard

### License agreement

Click **I Accept**.

### Language

**English (United States)** — or whatever you actually want. Click **Continue**.

### Keyboard layout

**English (US)** — match your physical keyboard. Click **Continue**.

### Wi-Fi

Pick your network and enter the password. **Required** — the Jetson needs internet for the post-setup updates. If you have Ethernet plugged in, you can pick **I don't want to connect to a Wi-Fi network right now** and use Ethernet instead.

### Time zone

Pick yours. Click **Continue**.

### User account

| Field | What to put |
|---|---|
| Your name | `sorcc` |
| Your computer's name | `jetson` (or whatever — this is the hostname) |
| Pick a username | `sorcc` |
| Choose a password | `sorcc` |
| Confirm password | `sorcc` |
| Log in automatically | **Check this box** |

Click **Continue**.

> **Why `sorcc`/`sorcc`?** Matches the convention from class. Everything in `04-apps/` assumes username is `sorcc`. If you use something else, you'll need to mentally substitute throughout.
>
> **For the field:** Once you're operating the Jetson on a real platform, change to a stronger password with `passwd`. The default is fine for bench / lab.

### Partition size

Accept the default (use the whole SD card). Click **Continue**.

### Chromium browser

Click **Install**. You'll need a browser later to access Hydra's web dashboard. Wait for it to finish, then click **Close**.

The Jetson will apply the settings and reboot automatically. **Wait through this** — it can take 5 minutes.

## Post-reboot popups

After the reboot you land on the Ubuntu desktop. A few popups will appear over the next minute. Handle them in this order:

### Online accounts

Click **Skip**. You don't need a Google / Microsoft / etc account for this.

### Ubuntu Pro

Click **Skip**. Ubuntu Pro is a paid Canonical thing you don't need.

### Send system info to Canonical

Pick **No, don't send system info**. Click **Next**.

### Location services

> **Leave this OFF.** The Jetson does not need OS-level location services. If you're using Hydra Detect, it gets GPS from the flight controller via MAVLink — far better than the Jetson's nonexistent GPS hardware. Ubuntu's location services would just sit there making background network calls for nothing.

Click **Next**.

### Done

Click **Done**.

## System updater popup

Within a couple of minutes, a **Software Updater** window pops up. Click **Install Now**, enter your password (`sorcc`), and let it run.

> **This takes 20-30 minutes.** Get coffee. Don't power off.

When it finishes, click **Restart Now**.

> During restart you'll see an NVIDIA boot screen with an update progress bar. **Do not power off during this.** It's applying kernel / firmware updates.

When the desktop comes back up, you're ready for `04-maxn-super-mode.md`.

## Sanity check

Open a terminal (**Ctrl+Alt+T**) and run:

```bash
cat /etc/nv_tegra_release
```

Expected first line:

```
# R36 (release), REVISION: 4.x, GCID: ..., ...
```

If you see `R36` — JetPack 6 is alive.

```bash
docker --version
# Expected: Docker version 27.x or newer
```

```bash
df -h /
# Should show your SD card with most of it as free space.
```

You're good. Onwards.
