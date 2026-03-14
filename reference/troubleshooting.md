# 🔧 Troubleshooting Guide

Something not working? Find your symptom below and follow the steps.

**First, always try:** `openclaw doctor` — it detects most common problems automatically.

---

## Installation Issues

### "curl: command not found"

You need to install curl first:
```bash
sudo apt update && sudo apt install curl -y
```
Then re-run the OpenClaw installer.

---

### "openclaw: command not found" after install

The installer added OpenClaw to your PATH, but your current terminal session doesn't know yet.

**Fix:**
```bash
source ~/.bashrc
```

Or close and reopen your Ubuntu terminal window.

If it still doesn't work:
```bash
echo $PATH
```
Look for a line mentioning openclaw or npm global packages. If it's missing:
```bash
export PATH="$HOME/.npm-global/bin:$PATH"
echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> ~/.bashrc
```

---

### The Official Installer Fails Partway Through

**Try:**
1. Check your internet connection
2. Run `sudo apt update` first
3. Re-run the installer — it's designed to be re-runnable safely

If it fails with a permission error:
```bash
# Don't sudo the curl command itself, but you may need to fix npm permissions:
mkdir -p ~/.npm-global
npm config set prefix '~/.npm-global'
```

---

## WSL2 Issues

### WSL2 Won't Open After a Windows Update

Windows updates sometimes disrupt WSL2. Try these in order:

**Option 1 — Restart WSL service:**
1. Open PowerShell as Administrator
2. Run: `wsl --shutdown`
3. Wait 10 seconds
4. Open Ubuntu again from Start menu

**Option 2 — Update WSL:**
1. Open PowerShell as Administrator
2. Run: `wsl --update`
3. Run: `wsl --shutdown`
4. Open Ubuntu again

**Option 3 — Check virtualization:**
1. Open Task Manager → Performance → CPU
2. Look for "Virtualization: Enabled"
3. If "Disabled": You need to enable virtualization in your BIOS/UEFI (search for your PC model + "enable virtualization")

**Option 4 — Reinstall WSL2:**
1. Open PowerShell as Administrator
2. Run: `wsl --unregister Ubuntu`
3. Run: `wsl --install Ubuntu`
4. This will recreate your Ubuntu environment — your files will be reset

> ⚠️ Option 4 deletes your Linux files. Back up anything important first with: `cp -r ~/.openclaw ~/openclaw-backup` while WSL is still working.

---

### "WslRegisterDistribution failed" Error

1. Open PowerShell as Administrator
2. Run: `dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart`
3. Restart your computer
4. Run: `wsl --set-default-version 2`
5. Try installing Ubuntu again: `wsl --install Ubuntu`

---

### WSL2 is Very Slow

- Try restarting: `wsl --shutdown` then reopen Ubuntu
- Windows Defender may be scanning Linux files — add the WSL path to Windows Defender exclusions (search for "Windows Security" → Virus & threat protection → Exclusions → Add `\\wsl$`)

---

## Telegram Bot Issues

### "Bot doesn't respond to my messages"

Work through this checklist:

1. **Is OpenClaw running?**
   ```bash
   openclaw status
   ```
   If stopped: `openclaw gateway start`

2. **Is your Telegram user ID in `allowFrom`?**
   ```bash
   cat ~/.openclaw/openclaw.json
   ```
   Look for `allowFrom`. Your Telegram user ID must be listed there as a string in quotes.

3. **Is `dmPolicy` set to `"allowlist"`?**
   Check your config. If it's `"allowlist"`, only users in `allowFrom` get responses.

4. **Is the bot token correct?**
   ```bash
   openclaw doctor
   ```
   It will verify the Telegram connection.

5. **Did you message the right bot?**
   In Telegram, search for your bot's username (the one you created with @BotFather, ending in `_bot`). Make sure you're messaging that bot.

---

### "Bot responds to strangers"

Someone else found your bot and is chatting with it (costing you money).

**Immediate fix:**
1. Set `dmPolicy: "allowlist"` in your config if it isn't already
2. Set `allowFrom` to contain only your Telegram user ID
3. Restart: `openclaw gateway restart`

**To see who was chatting:** Check your Anthropic usage dashboard for unexpected activity, and check the OpenClaw logs via the dashboard at http://127.0.0.1:18789/.

---

### Bot Stops Responding Mid-Conversation

1. Check if you've hit your Anthropic spending limit (console.anthropic.com → Billing)
2. Run `openclaw doctor` for errors
3. Try `/reset` in the chat
4. If all else fails: `openclaw gateway restart`

---

## Configuration Issues

### "Config validation error" or "Invalid config"

This means your `openclaw.json` has a problem — usually a missing required field, a typo, or invalid JSON syntax.

**Step 1 — Check for JSON syntax errors:**
```bash
cat ~/.openclaw/openclaw.json | python3 -m json.tool
```
If it says "JSONDecodeError", you have a syntax error. Common causes:
- Missing or extra comma
- Missing or extra quote
- Mismatched brackets `{}` or `[]`

**Step 2 — Check for required fields:**
The Telegram section requires both `dmPolicy` AND `groupPolicy`. Make sure both are present:
```json
"telegram": {
  "botToken": "...",
  "dmPolicy": "pairing",
  "groupPolicy": "enabled"
}
```

**Step 3 — Check field names (case-sensitive!):**

| ❌ Wrong | ✅ Correct |
|---------|-----------|
| `bot_token` | `botToken` |
| `allowedUsers` | `allowFrom` |
| `allow_from` | `allowFrom` |
| `dm_policy` | `dmPolicy` |
| `group_policy` | `groupPolicy` |

**Step 4 — Re-run configuration to fix config:**
```bash
openclaw configure
```
This walks you through settings again without reinstalling anything. Or use `openclaw onboard` (without `--install-daemon`) for the full wizard.

---

### Gateway Shows Wrong Port

Default port is **18789**. If something else is using that port:
```bash
# Check what's on port 18789
sudo lsof -i :18789

# Change the port in config
nano ~/.openclaw/openclaw.json
# Change "port": 18789 to "port": 18790 (or any unused port)

openclaw gateway restart
```

---

## API / Cost Issues

### "Anthropic API error: 401 Unauthorized"

Your API key is invalid, expired, or revoked.

1. Go to console.anthropic.com → API Keys
2. Check if your key is still active
3. Create a new key if needed
4. Update your config: `nano ~/.openclaw/openclaw.json`
5. Replace the `apiKey` value with your new key
6. Restart: `openclaw gateway restart`

---

### "Anthropic API error: 429 Rate Limited"

You've made too many requests too quickly, or you've hit your monthly spending limit.

1. Check your spending limit: console.anthropic.com → Billing
2. If you've hit your limit: wait for the next billing cycle or increase the limit
3. If not at limit: wait a few minutes and try again

---

### Unexpected Charges on Anthropic

1. Check `allowFrom` — make sure only your ID is listed
2. Set `dmPolicy: "pairing"` to block strangers
3. Review usage details on console.anthropic.com → Usage
4. If charges seem fraudulent: revoke your API key immediately, create a new one

---

## Dashboard Issues

### Dashboard Not Loading at http://127.0.0.1:18789/

1. Check if the gateway is running: `openclaw status`
2. If stopped: `openclaw gateway start`
3. If running but dashboard won't load: try `openclaw gateway restart`
4. Check the port: your config might have a different port number

---

## How to Completely Reset and Start Over

Only do this if everything is broken and you want a clean slate.

> ⚠️ This deletes your configuration and workspace. Back up anything important first.

**Backup first:**
```bash
cp ~/.openclaw/openclaw.json ~/openclaw.json.backup
cp -r ~/.openclaw/workspace ~/openclaw-workspace-backup
```

**Stop the daemon:**
```bash
openclaw gateway stop
# On systemd (Ubuntu/WSL2):
systemctl --user stop openclaw
systemctl --user disable openclaw
```

**Remove OpenClaw:**
```bash
npm uninstall -g openclaw
```

**Clean up the directory:**
```bash
rm -rf ~/.openclaw
```

**Reinstall from scratch:**
```bash
curl -fsSL https://openclaw.ai/install.sh | bash
openclaw onboard --install-daemon
```

**Restore your workspace after reinstall:**
```bash
cp -r ~/openclaw-workspace-backup/* ~/.openclaw/workspace/
```

---

## Still Stuck?

- Run `openclaw doctor` — it's the best first diagnostic
- Check the dashboard logs at http://127.0.0.1:18789/ → Logs
- Visit the OpenClaw community: [https://github.com/openclaw/openclaw/discussions](https://github.com/openclaw/openclaw/discussions)
- Check the official documentation: [https://openclaw.ai/docs](https://openclaw.ai/docs)
