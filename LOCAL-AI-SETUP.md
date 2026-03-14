# 🧠 Local AI Setup — Run Models on Your Own Computer (Free)

OpenClaw can use AI models that run entirely on your computer — no API key, no monthly bill, no data leaving your machine. This guide shows you how to set it up.

**Requirements:** At least 16GB of RAM. More RAM = bigger (smarter) models.

---

## What Is Local AI?

When you use Anthropic's Claude, your messages go to Anthropic's servers, get processed there, and come back. You pay for each message.

With local AI, the model runs on **your computer**. Messages never leave your machine. It's completely free and private. The tradeoff: local models aren't quite as smart as the best cloud models, but they're surprisingly good for everyday tasks.

---

## Step 1: Install Ollama

Ollama is a free tool that makes running AI models on your computer easy. Think of it as a model manager — it downloads, runs, and manages models for you.

In your Ubuntu terminal, run:

```bash
curl -fsSL https://ollama.com/install.sh | sh
```

> Remember: **right-click** to paste in the terminal.

**What you should see:**
```
>>> Installing ollama
>>> Downloading...
>>> ollama installed successfully
```

Verify it's working:
```bash
ollama --version
```

You should see a version number like `ollama version 0.x.x`.

---

## Step 2: Download a Model

Which model you download depends on how much RAM you have. Here's what we recommend:

### If You Have 64GB RAM (Best Option)

```bash
ollama pull qwen3.5:32b
```

This downloads **Qwen3.5 32B** — the best all-around local model for your hardware. It's excellent at conversation, reasoning, coding help, and writing. The download is about 20GB, so it will take a few minutes depending on your internet speed.

### If You Have 32GB RAM

```bash
ollama pull qwen3.5:14b
```

A smaller but still very capable model. Great for everyday tasks.

### If You Have 16GB RAM

```bash
ollama pull qwen3.5:9b
```

The most efficient option. Good for simple tasks, quick questions, and casual chat.

> 💡 **Not sure how much RAM you have?** In your Ubuntu terminal, run: `free -h` and look at the "total" number under "Mem".

**What you should see during download:**
```
pulling manifest
pulling abc123def... 100% ████████████████ 20 GB
verifying sha256 digest
writing manifest
success
```

The download can take 5–30 minutes depending on your internet speed. Just let it run.

---

## Step 3: Test the Model

Before connecting it to OpenClaw, let's make sure it works:

```bash
ollama run qwen3.5:32b
```

(Replace `32b` with whichever size you downloaded.)

This opens a chat with the model right in your terminal. Try typing:
```
Hello! What's 2 + 2?
```

It should respond conversationally. Type `/bye` to exit the chat.

If this works, your model is ready!

---

## Step 4: Connect Ollama to OpenClaw

Now tell OpenClaw about your local model. The easiest way is to use the configure command:

```bash
openclaw configure
```

When it asks about model providers, add Ollama with:
- **Provider type:** Ollama
- **Base URL:** `http://127.0.0.1:11434`
- **Model:** `qwen3.5:32b` (or whichever size you downloaded)

Then restart:
```bash
openclaw gateway restart
```

### Setting the Local Model as Default

If you want to use the local model for everyday conversations (free!) and only use Anthropic for complex tasks:

You can tell your assistant in chat:
```
Use the local model for this conversation.
```

Or change the default model in your config to `ollama/qwen3.5:32b` using `openclaw configure`.

### Using Both (Recommended Setup)

The best approach is to keep **both** models available:

- **Local model (Qwen3.5)** → Default for everyday chat, simple questions, brainstorming. **Free.**
- **Anthropic (Claude Sonnet)** → For complex research, long documents, precise writing. **Paid.**

This way, 80% of your usage costs nothing, and you have full frontier power when you need it.

---

## How Local Models Compare to Cloud Models

Here's an honest comparison:

| Task | Local (Qwen3.5 32B) | Cloud (Claude Sonnet) |
|------|---------------------|----------------------|
| Casual conversation | ✅ Great | ✅ Great |
| Simple questions | ✅ Great | ✅ Great |
| Writing help | ✅ Good | ✅ Excellent |
| Web search + summarize | ✅ Good | ✅ Excellent |
| Complex reasoning | 🟡 Good | ✅ Excellent |
| Long document analysis | 🟡 Decent | ✅ Excellent |
| Multi-step tasks | 🟡 Decent | ✅ Excellent |
| Creative writing | ✅ Good | ✅ Excellent |
| Coding help | ✅ Good | ✅ Excellent |

**Bottom line:** For 80% of daily use, you won't notice much difference. For the tough stuff, the cloud model is noticeably better.

---

## Useful Ollama Commands

| Command | What It Does |
|---------|-------------|
| `ollama list` | Show all downloaded models |
| `ollama run qwen3.5:32b` | Chat directly with a model |
| `ollama pull qwen3.5:32b` | Download or update a model |
| `ollama rm qwen3.5:32b` | Delete a model (frees up disk space) |
| `ollama ps` | Show currently running models |
| `ollama --version` | Check Ollama version |

---

## Troubleshooting

### "ollama: command not found"

Run the installer again:
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

Then close and reopen your terminal.

### Model is Very Slow

- **Check your RAM:** Run `free -h`. If the model is larger than your available RAM, it will use disk (swap), which is extremely slow. Download a smaller model instead.
- **Close other programs:** Games, browsers with many tabs, and other apps all use RAM.
- **First response is slow, but later ones are fast?** That's normal — the model needs to load into memory the first time. After that, it stays loaded.

### "Error: model not found"

Make sure you pulled the model first:
```bash
ollama pull qwen3.5:32b
```

Check the name matches exactly (including the `:32b` part).

### Model Gives Bad or Weird Responses

- Try starting a fresh conversation (close the chat and reopen)
- Local models are less consistent than cloud models — if a response is off, just ask again
- For important or complex tasks, switch to the cloud model (Anthropic)

### Ollama Won't Start

```bash
# Check if it's already running
ollama ps

# If not, start the service
ollama serve
```

> 💡 Ollama typically runs as a background service after installation. If it's not starting automatically, you can always run `ollama serve` in one terminal window and use another window for your commands.

---

## Storage Space

Models take up disk space. Here's what to expect:

| Model | Disk Space |
|-------|-----------|
| Qwen3.5 9B | ~6 GB |
| Qwen3.5 14B | ~9 GB |
| Qwen3.5 32B | ~20 GB |

To check your available disk space:
```bash
df -h /
```

Look at the "Avail" column. You need at least the model size plus a few GB of breathing room.

---

*See also: [COST-GUIDE.md](COST-GUIDE.md) for understanding cloud model costs vs. local*
