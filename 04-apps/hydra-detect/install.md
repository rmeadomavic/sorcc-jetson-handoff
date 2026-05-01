# Hydra Detect

Hydra Detect is the real-time object detection and tracking payload you used in class. Camera in → YOLO detection → ByteTrack tracking → MAVLink alerts to your Pixhawk + web dashboard + RTSP stream + (optional) TAK output.

This page covers **installing** Hydra. Operating it (mission profiles, geofencing, autonomous strike, RF homing) is documented in the Hydra repo itself.

## Requirements

- Base system bootstrap done (`02-base-system/01-base-bootstrap.sh`)
- `bash scripts/preflight.sh` passes
- ~7 GB free disk for the Docker image
- USB camera (Logitech C270 / C920 or similar) plugged in
- (Optional) Pixhawk wired and tested per `03-hardware/`

## Quick install

```bash
bash 04-apps/hydra-detect/install.sh
```

The script:

1. Clones the Hydra repo to `~/Hydra` (or pulls latest if it's already there)
2. Builds the `hydra-detect:latest` Docker image (~2 minutes after base image)
3. Asks 3 questions (MAVLink yes/no, MAVLink device, optional Tailscale already-up check)
4. Writes a sane `config.ini`
5. Optionally installs Hydra as a systemd service (auto-start on boot)
6. Optionally launches it now

## After install

Open the dashboard:

```
http://<jetson-ip>:8080
```

If Tailscale is up, use the Tailscale IP — works from any of your tailnet devices.

You should see a live camera feed with detection bounding boxes.

## Updating Hydra later

Re-run the installer:

```bash
bash 04-apps/hydra-detect/install.sh
```

It pulls the latest from `main`, rebuilds the image, restarts the service. The script preserves your `config.ini` and any data in `~/Hydra/output_data/`.

## Common things that go wrong

### Camera not detected

```bash
ls /dev/video*
```

If empty, your camera isn't enumerated. Try a different USB port. Some USB-C hubs don't pass camera devices through cleanly.

### MAVLink won't connect

You probably haven't run `03-hardware/02-test-mavlink.md`. Confirm `mavproxy` works first; Hydra uses the same connection.

### Dashboard says "no detections" but camera works

Check that YOLO loaded (look at logs):

```bash
sudo docker logs hydra-detect | head -50
```

Look for `YOLO model loaded`. If you see "OOM" or "out of memory", you're trying to run a model bigger than 8 GB shared RAM allows. Switch to `yolov8n` (smallest) in `config.ini`.

### `--runtime nvidia` errors / OpenCV import crash

You ran the container without `--runtime nvidia`. Re-run the installer; it always uses `--runtime nvidia`. If you're invoking Docker manually, make sure you include `--runtime nvidia`.

### Update broke things

Roll back to the last working version:

```bash
cd ~/Hydra
git log --oneline | head -10  # find the SHA you had before
git checkout <sha>
docker build --network=host -t hydra-detect:latest .
sudo systemctl restart hydra-detect
```

## Where things live

| Path | Purpose |
|---|---|
| `~/Hydra/` | The git repo |
| `~/Hydra/config.ini` | Your config (preserved across updates) |
| `~/Hydra/output_data/` | Detection logs, screenshots, video clips |
| `~/Hydra/models/` | YOLO `.pt` and `.engine` files |
| `/etc/systemd/system/hydra-detect.service` | systemd unit (if you enabled auto-start) |

## Operating Hydra

Once installed, the dashboard is the interface — you do not need to SSH for normal use. The relevant docs live in the Hydra repo at `~/Hydra/docs/` (vendored offline copies are also installed at `~/Hydra/docs/` after the install script runs):

- `dashboard-user-guide.md` — every UI element explained
- `configuration.md` — every config knob
- `safety-review-2026-04-20.md` — the safety model and arming chain
- `tak-integration.md` — TAK / ATAK output

## Uninstall

```bash
sudo systemctl disable --now hydra-detect 2>/dev/null || true
sudo docker rm -f hydra-detect 2>/dev/null || true
sudo docker rmi hydra-detect:latest 2>/dev/null || true
sudo rm -f /etc/systemd/system/hydra-detect.service
# Leaves ~/Hydra in place — delete manually if you want
```
