# 🛠️ Installation Guide — WSL2 + OpenClaw

This guide installs everything you need on a Windows PC. The process uses WSL2 (Windows Subsystem for Linux) — a way to run a Linux terminal inside Windows without any complicated setup.

**Before you start:** Make sure you've completed [ACCOUNTS-SETUP.md](ACCOUNTS-SETUP.md) and have your API keys ready.

Estimated time: **20–30 minutes**

---

## Step 1: Enable WSL2 on Windows

WSL2 lets you run Linux commands on your Windows PC. OpenClaw runs inside this Linux environment.

### Requirements
- Windows 10 (version 2004 or later — check with `winver` in Start menu) OR Windows 11
- Your computer must support virtualization (most modern PCs do)

### How to Enable WSL2

1. **Open PowerShell as Administrator:**
   - Click the Start menu
   - Type `PowerShell`
   - Right-click "Windows PowerShell" → **Run as administrator**
   - Click "Yes" on the security prompt

<!-- SCREENSHOT: Right-clicking PowerShell and selecting "Run as administrator" -->

2. **Run this command** (copy and paste it exactly):
   ```powershell
   wsl --install
   ```

3. **What you should see:**
   ```
   Installing: Windows Subsystem for Linux
   Windows Subsystem for Linux has been installed.
   Installing: Ubuntu
   Ubuntu has been installed.
   The requested operation is successful. Changes will not be effective until the system is restarted.
   ```

4. **Restart your computer** — this is required. Save anything open first.

5. **After restarting:** Ubuntu will automatically open and finish setting up. You'll be asked to:
   - Create a **Linux username** — use something simple, all lowercase, no spaces (e.g., `yourname`)
   - Create a **Linux password** — you'll type this a lot; make it short but memorable. (Note: when typing passwords in Linux, nothing appears on screen — that's normal!)

<!-- SCREENSHOT: Ubuntu first-time setup asking for username and password -->

6. **What you should see after setup:**
   ```
   yourname@DESKTOP-XXXXX:~$
   ```
   This is your Linux terminal prompt. You're in! The `$` means it's ready for commands.

### Troubleshooting WSL2 Setup
- **"Virtualization not enabled"** → You need to enable it in your PC's BIOS/UEFI. Search for your PC model + "enable virtualization" for specific steps.
- **WSL install seems stuck** → Wait 5 minutes. If nothing happens, restart and try again.
- **More help:** [reference/troubleshooting.md](reference/troubleshooting.md)

---

## Step 2: Update Ubuntu (Good Hygiene)

In your Ubuntu terminal, run:

```bash
sudo apt update && sudo apt upgrade -y
```

Enter your Linux password when prompted. This updates your Linux system's software list.

**What you should see:** A lot of text scrolling by, ending with something like:
```
0 upgraded, 0 newly installed, 0 to remove and 0 not upgraded.
```

(Or it may upgrade some packages — that's fine too.)

---

## Step 3: Run the Official OpenClaw Installer

OpenClaw has an official installer that handles everything automatically — including detecting your Node.js version, installing dependencies, and setting up the initial configuration.

**In your Ubuntu terminal, run:**

```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```

**What you should see:** The installer will:
1. Check your system requirements
2. Install or verify Node.js (Node 24 recommended, Node 22 LTS minimum)
3. Download and install OpenClaw
4. Set up your initial directory structure

It ends with something like:
```
✓ OpenClaw installed successfully!
Run 'openclaw onboard --install-daemon' to get started.
```

<!-- SCREENSHOT: Terminal showing successful OpenClaw installation -->

### If the Installer Fails
- **"command not found: curl"** → Run `sudo apt install curl -y` then try again
- **Permission errors** → Don't add `sudo` before `curl` — the installer handles its own permissions
- **Network errors** → Check your internet connection; try again
- More help: [reference/troubleshooting.md](reference/troubleshooting.md)

---

## Step 4: Run the Onboarding Wizard

This is the guided setup that configures your AI assistant. Have your API keys ready from [ACCOUNTS-SETUP.md](ACCOUNTS-SETUP.md)!

```bash
openclaw onboard --install-daemon
```

The wizard will walk you through each setting with prompts. Here's what to expect and how to answer:

| Prompt | What to Enter |
|--------|--------------|
| **Anthropic API key** | Your `sk-ant-api03-...` key |
| **Default model** | `claude-sonnet-4-5` (recommended) or press Enter for default |
| **Telegram bot token** | Your bot token from @BotFather |
| **Telegram dmPolicy** | Choose `allowlist` (keeps strangers out) |
| **Telegram groupPolicy** | Choose `allowlist` (controlled group access) |
| **allowFrom** | Your Telegram user ID (e.g., `987654321`) |
| **Workspace location** | Press Enter to accept default (`~/.openclaw/workspace`) |
| **Install as daemon** | `y` (runs OpenClaw automatically at startup) |
| **Install skills** | Choose what you want; you can always add more later |

<!-- SCREENSHOT: Terminal showing the onboarding wizard prompts -->

**What you should see at the end:**
```
✓ Configuration saved
✓ Daemon installed (systemd)
✓ Gateway started on port 18789
✓ OpenClaw is running!
```

> 💡 **What is `--install-daemon`?**
> A daemon is a background service — it means OpenClaw will start automatically every time your computer boots. Without this, you'd have to manually start OpenClaw every time you open Ubuntu.

---

## Step 5: Verify Everything Works

Run these two commands to confirm your installation is healthy:

```bash
openclaw doctor
```

**What you should see:**
```
✓ Node.js: OK (v24.x.x)
✓ Config: valid
✓ Anthropic API: connected
✓ Telegram: connected
✓ Gateway: running on port 18789
✓ All checks passed!
```

If anything shows ❌, the doctor will tell you what's wrong and usually how to fix it.

Then run:
```bash
openclaw status
```

**What you should see:**
```
Gateway: running (port 18789)
Daemon: active
Sessions: 0 active
```

---

## Step 6: Open the Web Dashboard

OpenClaw includes a browser-based control panel. Open it with:

```bash
openclaw dashboard
```

Or open your browser and go to: **http://127.0.0.1:18789/**

<!-- SCREENSHOT: OpenClaw web dashboard showing gateway status and session list -->

You'll see:
- Gateway status (running/stopped)
- Active sessions
- Configuration overview
- Logs

You can also chat with your assistant directly from the dashboard — no Telegram required!

---

## Step 7: Copy Workspace Templates

Your workspace is where your assistant's personality, memory, and instructions live. This kit includes starter templates.

First, navigate to the starter kit directory.

**If you cloned it via git inside WSL** (recommended):
```bash
cd ~/openclaw-starter-kit
```

**If you downloaded the zip to your Windows Downloads folder:**
```bash
cd /mnt/c/Users/YourWindowsUsername/Downloads/openclaw-starter-kit
```
(Replace `YourWindowsUsername` with your actual Windows username.)

> 💡 **Cloning inside WSL is faster and avoids path issues.** From your Ubuntu terminal:
> ```bash
> cd ~ && git clone https://github.com/YOUR-REPO/openclaw-starter-kit.git
> ```

Then run:
```bash
bash setup-workspace.sh
```

**What you should see:**
```
✓ Backed up existing SOUL.md → SOUL.md.backup
✓ Copied SOUL.md
✓ Copied USER.md
✓ Copied IDENTITY.md
✓ Copied AGENTS.md
✓ Copied TOOLS.md
✓ Copied MEMORY.md
✓ Copied HEARTBEAT.md
✓ Workspace templates installed to ~/.openclaw/workspace/
```

Now open the files and fill them in:
```bash
nano ~/.openclaw/workspace/USER.md
```
Replace the placeholder text with your actual name, timezone, etc.

---

## 🎉 You're Done!

Your assistant is installed and running. Next steps:

➡️ **[FIRST-STEPS.md](FIRST-STEPS.md)** — Learn to use your assistant, try your first commands, take a tour of the dashboard.

---

## 🆘 Installation Troubleshooting

| Problem | Fix |
|---------|-----|
| `openclaw: command not found` | Close and reopen your Ubuntu terminal; run `source ~/.bashrc` |
| Onboarding wizard skipped a prompt | Re-run `openclaw onboard` (without `--install-daemon` this time) |
| Telegram bot not responding | Check your bot token is correct; run `openclaw doctor` |
| WSL2 won't open after Windows update | See [reference/troubleshooting.md](reference/troubleshooting.md) |
| "Port 18789 already in use" | Run `openclaw gateway stop` then `openclaw gateway start` |

Full troubleshooting: [reference/troubleshooting.md](reference/troubleshooting.md)
