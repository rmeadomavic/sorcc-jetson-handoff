# Ollama + Open WebUI

Ollama is a local LLM runtime. Pull a model, chat with it, no cloud. Open WebUI is a ChatGPT-style web frontend that talks to Ollama. Together they give you a private LLM stack on the Jetson.

## What works on 8 GB shared RAM

The Jetson Orin Nano shares its 8 GB between CPU and GPU. After Linux + Docker (~1.5 GB), you have roughly 6-6.5 GB for the model.

| Model | Size | Real use |
|---|---|---|
| `phi3:mini` (3.8B) | ~2.3 GB | Fast, surprisingly good for its size. Default recommendation. |
| `gemma2:2b` | ~1.6 GB | Smallest viable. Works for quick Q&A and summarization. |
| `llama3:8b-instruct-q4_0` | ~4.7 GB | Better answers, slower (~3-5 tok/sec). The biggest you should run. |
| `qwen2.5-coder:3b` | ~1.9 GB | If you want code completion / programming assistant |
| `deepseek-r1:8b` | ~5 GB | Reasoning model — slow, but interesting for tough problems |

**Models 13B and larger** will not fit. Don't bother trying.

You can have multiple models pulled at once (only one runs at a time), but they each take disk space.

## Quick install

```bash
bash 04-apps/ollama/install.sh
```

This will:

1. Install Ollama natively (not in Docker — Ollama uses its own GPU integration which is finicky in containers)
2. Run Open WebUI in Docker
3. Pull `phi3:mini` as a starter model
4. Print the URL to access the chat UI

After it finishes, open your browser:

```
http://<jetson-ip>:3000
```

Create an account (the first user is auto-admin), then start chatting.

## Pulling more models

From the Open WebUI settings, or directly:

```bash
ollama pull llama3:8b-instruct-q4_0
ollama pull gemma2:2b
ollama list
```

## Memory pressure

If you start a model and your Jetson becomes unresponsive, you've blown the memory budget. Fixes:

- **Close other heavy apps.** Hydra Detect uses 2-3 GB GPU memory; running it concurrently with an 8B Ollama model is too tight.
- **Use a smaller model.** Switching from `llama3:8b` to `phi3:mini` halves the footprint.
- **Add more swap.** The bootstrap script creates 8 GB; you can extend to 16 GB if you really need it. Swap is much slower than RAM, but it prevents OOM kills.

Monitor live with:

```bash
tegrastats --interval 1000
```

Look for the `RAM` line — when it gets to ~7000 MB / 7800 MB, you're at the edge.

## Performance expectations

On MAXN Super (25W), with a small model like `phi3:mini`:

- First-token latency: ~1-3 seconds
- Generation speed: ~15-25 tokens/second

With `llama3:8b-instruct-q4_0`:

- First-token latency: ~5-10 seconds
- Generation speed: ~3-5 tokens/second

These aren't fast, but they're free, private, and offline.

## Stopping / starting

```bash
# Stop Open WebUI
sudo docker stop open-webui

# Stop Ollama
sudo systemctl stop ollama

# Start them back up
sudo systemctl start ollama
sudo docker start open-webui
```

## Where things live

| Path | What |
|---|---|
| `/usr/local/bin/ollama` | Ollama binary |
| `/etc/systemd/system/ollama.service` | systemd unit (Ollama runs as a system service) |
| `~/.ollama/models/` | Pulled models (can grow to many GB) |
| Docker container `open-webui` | Open WebUI |
| Open WebUI volume `open-webui-data` | Chat history, user accounts |

## Uninstall

```bash
sudo systemctl disable --now ollama
sudo rm -f /usr/local/bin/ollama
sudo rm -rf /etc/systemd/system/ollama.service
sudo docker rm -f open-webui
sudo docker volume rm open-webui-data
rm -rf ~/.ollama
```
