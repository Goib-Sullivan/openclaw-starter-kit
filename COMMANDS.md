# 📋 Commands Reference Card

Quick reference for every important command. Bookmark this page.

Commands marked with 🖥️ are run in your **Ubuntu terminal**.
Commands marked with 💬 are sent as **chat messages** in Telegram or the dashboard.

---

## 🌐 Gateway Commands

The gateway is the server process that runs your AI assistant.

| Command | What It Does |
|---------|-------------|
| `openclaw gateway start` 🖥️ | Start the gateway (if it's stopped) |
| `openclaw gateway stop` 🖥️ | Stop the gateway |
| `openclaw gateway restart` 🖥️ | Restart the gateway (use after config changes) |
| `openclaw status` 🖥️ | Show gateway status, active sessions, port |

**When to restart:** After editing your config file (`openclaw.json`), or if your bot stops responding.

```bash
# Example output of openclaw status
Gateway: running (port 18789)
Daemon: active
Sessions: 1 active
```

---

## 💬 Session Commands (Send in Chat)

These are sent as messages to your assistant in Telegram or the dashboard.

| Command | What It Does |
|---------|-------------|
| `/new` | Start a fresh conversation (clears chat history) |
| `/reset` | Full session reset (use if assistant seems stuck) |
| `/status` | Show current model, available tools, session info |

**Example:**
```
/new
```
Assistant replies: `✓ Starting fresh conversation.`

---

## 🔍 Diagnostics

| Command | What It Does |
|---------|-------------|
| `openclaw doctor` 🖥️ | Run a full health check on all components |
| `openclaw dashboard` 🖥️ | Open the web dashboard in your browser |
| `openclaw status` 🖥️ | Quick status overview |

**Run `openclaw doctor` whenever something seems wrong.** It checks your config, API connectivity, Telegram connection, and more, and tells you exactly what to fix.

---

## 📁 File Locations

| What | Where |
|------|-------|
| Config file | `~/.openclaw/openclaw.json` |
| Workspace | `~/.openclaw/workspace/` |
| Your personality file | `~/.openclaw/workspace/SOUL.md` |
| Your user profile | `~/.openclaw/workspace/USER.md` |
| Agent instructions | `~/.openclaw/workspace/AGENTS.md` |
| Memory | `~/.openclaw/workspace/MEMORY.md` |
| Skills | `~/.openclaw/workspace/skills/` |
| Logs | Check the dashboard at http://127.0.0.1:18789/ |

---

## ✏️ How to Edit Files

Use `nano` — the simplest Linux text editor.

```bash
# Edit your user profile
nano ~/.openclaw/workspace/USER.md

# Edit your personality file
nano ~/.openclaw/workspace/SOUL.md

# Edit the config (careful! contains API keys)
nano ~/.openclaw/openclaw.json
```

**Nano controls:**
- Type to insert text
- `Ctrl + O` → Save (then press Enter to confirm)
- `Ctrl + X` → Exit
- `Ctrl + K` → Delete a line
- Arrow keys → Move around

---

## 🔄 After Changing Config

Whenever you edit `openclaw.json`, run:
```bash
openclaw gateway restart
```

Then verify it worked:
```bash
openclaw doctor
```

---

## 🆘 Emergency Commands

```bash
# Something is broken — run health check
openclaw doctor

# Bot not responding — restart everything
openclaw gateway restart

# Check if gateway is actually running
openclaw status

# View live logs (Ctrl+C to stop)
# (Check the dashboard at http://127.0.0.1:18789/ → Logs)
```

---

## 💡 Quick Tips

- The gateway runs as a background daemon — you don't need to keep the terminal open
- After a Windows restart, WSL2 starts automatically; OpenClaw starts automatically with it
- The dashboard at **http://127.0.0.1:18789/** works without any terminal commands
- `/new` is your friend — use it frequently for cleaner conversations

---

*Full troubleshooting: [reference/troubleshooting.md](reference/troubleshooting.md)*
