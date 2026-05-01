# 02 — Tailscale (optional)

Tailscale gives your Jetson a stable, secure address that works from anywhere. SSH into it from a coffee shop, point your laptop browser at the Hydra dashboard from across town, all without port forwarding or a public IP.

This is optional. If your Jetson never leaves your bench Wi-Fi, you can skip Tailscale and just use its LAN IP. Most people will want Tailscale once they've used it.

## What it does

- Assigns the Jetson a permanent IPv4 address in the `100.x.y.z` range that only your devices can reach.
- Encrypts all traffic to/from the Jetson with WireGuard.
- Lets you SSH in by hostname (`ssh sorcc@my-jetson`) instead of remembering an IP.
- Optionally enables **Tailscale SSH** so SSH itself is brokered by Tailscale's auth — no SSH keys to manage.

## Make a Tailscale account first

You need your own tailnet — **do not** use someone else's account.

1. Go to <https://login.tailscale.com/start>
2. Sign in with Google, Microsoft, GitHub, or a custom OIDC provider.
3. The free plan covers up to 100 devices and 3 users — plenty for personal use.

## Install on the Jetson

Run on the Jetson (not your laptop):

```bash
curl -fsSL https://tailscale.com/install.sh | sh
```

The installer adds Tailscale's apt repo and installs the daemon. Takes about a minute.

## Bring it up

```bash
sudo tailscale up
```

It prints a URL like `https://login.tailscale.com/a/abcdef123`. **Open that URL on any device** (your laptop, phone, whatever) and sign in. The Jetson appears in your tailnet.

If you want SSH brokered by Tailscale (skip managing your own SSH keys):

```bash
sudo tailscale set --ssh
```

## Verify

```bash
tailscale ip -4
# Prints your Jetson's tailnet IP, e.g. 100.76.40.123

tailscale status
# Lists every device in your tailnet
```

From any device that's signed into the same tailnet:

```bash
ssh sorcc@100.76.40.123
# or, if you set a hostname in the Tailscale admin console:
ssh sorcc@my-jetson
```

## Setting a friendlier hostname

In the [Tailscale admin console](https://login.tailscale.com/admin/machines), click your Jetson, then **Edit name** to set something memorable like `my-jetson`. With MagicDNS enabled (default), you can then SSH using that name from any tailnet device.

## Reaching the Hydra dashboard from anywhere

Once Hydra is installed (see `04-apps/hydra-detect/`), you can hit the dashboard from any tailnet device:

```
http://<jetson-tailscale-ip>:8080
```

No port forwarding. No public IP. No fiddling.

## Things to know

- **Battery life:** Tailscale is very lightweight — you won't notice the impact.
- **Field operations:** if your platform has cellular (e.g. via a Pi 5G hat), Tailscale gives you a stable address even on a roaming IP.
- **Sharing:** you can share specific machines with other tailnet users via the admin console. Useful if you want a teammate to be able to access your Jetson without giving them your whole tailnet.

## Removing the Jetson from your tailnet

Two steps:

```bash
# On the Jetson:
sudo tailscale logout
sudo apt remove --purge tailscale
```

And in the [admin console](https://login.tailscale.com/admin/machines), delete the device entry.
