# 🔒 Security Guide — Protecting Your Setup

Security isn't optional with an AI assistant that has access to your files, can browse the web, and costs you money for every message. This guide covers the most important protections, explained plainly.

---

## 🔑 API Key Safety

Your Anthropic API key is like a credit card. Anyone who has it can rack up charges on your account.

### Rules for Your API Key

1. **Never share it** — not in chat messages, not in screenshots, not in emails
2. **Never put it in a file you might commit to GitHub**
3. **Never paste it into websites other than Anthropic's console**
4. **If it leaks** — go to console.anthropic.com → API Keys → revoke it immediately, create a new one

### Lock Down Your Config File

Your API key lives in OpenClaw's config file. Set its permissions so only you can read it:

```bash
chmod 600 ~/.openclaw/openclaw.json
```

**What this does:** Prevents other users on your system (or malicious scripts) from reading the file. Only your own user account can access it.

**Verify it worked:**
```bash
ls -la ~/.openclaw/openclaw.json
```

You should see: `-rw-------` at the start of the line (that means owner read/write only).

---

## 👥 allowFrom — Keep Strangers Out

**This is the most important security setting.**

The `allowFrom` field in your config controls who can use your bot. Without it, **anyone who finds your bot on Telegram can chat with it** — and every message they send costs you money.

### How It Works

```json
"allowFrom": ["987654321"]
```

This list contains Telegram user IDs. Only users whose ID is in this list can interact with your bot. Everyone else gets ignored.

### How to Find Your Telegram ID

1. In Telegram, search for **@userinfobot**
2. Start a chat and send any message
3. It will reply with your User ID — a number like `987654321`
4. That number goes in your `allowFrom` list

### Verifying Your Config

Open your config and check:
```bash
cat ~/.openclaw/openclaw.json
```

Look for the telegram section. It should contain your ID:
```json
"allowFrom": ["your_telegram_user_id_here"]
```

### Adding More People

If you want a family member or friend to also use your bot:
- Have them find their ID using @userinfobot
- Add their ID to the list: `"allowFrom": ["987654321", "111222333"]`
- Edit your config: `nano ~/.openclaw/openclaw.json`
- Restart the gateway: `openclaw gateway restart`

---

## 🔐 dmPolicy: "pairing" — The Safe Default

The `dmPolicy` setting controls who can start a direct message conversation with your bot.

| Setting | Behavior |
|---------|----------|
| `"pairing"` | ✅ Only approved users (in `allowFrom`) can chat |
| `"open"` | ⚠️ Anyone who finds your bot can start a conversation |

**Always use `"pairing"` unless you have a specific reason not to.**

If you accidentally set it to `"open"`, change it:
```bash
nano ~/.openclaw/openclaw.json
```
Find `"dmPolicy"` and change its value to `"pairing"`, then:
```bash
openclaw gateway restart
```

---

## 💰 Budget Alerts — Your Financial Safety Net

Even with `allowFrom` properly set, you should have a spending limit on Anthropic. Set it once and never worry about surprise bills.

### Step-by-Step: Set a Spending Limit

1. Go to [https://console.anthropic.com/](https://console.anthropic.com/)
2. Click your account name (top right) → **Billing** or **Settings**
3. Look for **Usage Limits** or **Spend Limits**
4. Set a **Monthly Spend Limit** — start with **$25/month**
5. Optionally set an **Email Alert** at 80% of your limit
6. Click **Save**

<!-- SCREENSHOT: Anthropic billing page showing spend limit configuration -->

**What happens when you hit the limit?** The API stops responding until the next billing cycle. Your assistant will stop working for the rest of the month. Better than a surprise $500 bill.

### Check Your Current Spending

- Go to console.anthropic.com → **Usage**
- You'll see a graph of your spending by day and month
- Check this occasionally — weekly at first

---

## 📁 Config File Security

Your config file (`~/.openclaw/openclaw.json`) contains your API key and bot token. Treat it like a password file.

### Never Commit It to GitHub

If you ever initialize a git repo in your workspace:
```bash
git init ~/.openclaw/workspace
```

Make sure there's a `.gitignore` that excludes the config. This kit's `.gitignore` file handles this. Place it in your project root.

The `.gitignore` in this kit excludes:
```
openclaw.json
*.key
*.token
.env
*.secret
```

### Back Up Your Config Separately

Copy your config to a secure, encrypted location (not GitHub):
```bash
cp ~/.openclaw/openclaw.json ~/Documents/openclaw-config-backup.json
```

Then store that backup somewhere safe — an encrypted USB drive, an encrypted note in a password manager, etc.

---

## 🛡️ Backup Basics

Your workspace (`~/.openclaw/workspace`) contains your assistant's personality, notes, and memory. Back it up weekly.

### Simple Backup Command

```bash
# Create a backup
tar -czf ~/openclaw-workspace-backup-$(date +%Y%m%d).tar.gz ~/.openclaw/workspace/

# Where did it go?
ls ~/openclaw-workspace-backup-*.tar.gz
```

### Restore From Backup

```bash
tar -xzf ~/openclaw-workspace-backup-20250101.tar.gz -C ~/
```

### Automated Weekly Backup

To run this automatically every Sunday at 9am:
```bash
crontab -e
```
Add this line:
```
0 9 * * 0 tar -czf ~/openclaw-workspace-backup-$(date +%Y%m%d).tar.gz ~/.openclaw/workspace/
```

---

## 🔐 Advanced: 2FA for Sensitive Actions (Optional)

OpenClaw supports Google Authenticator (TOTP) verification for sensitive operations like modifying system configs, deleting files, or sending messages to external contacts. This is an advanced feature.

If you want this extra layer of protection, see the OpenClaw documentation at:
[https://openclaw.ai/docs/security/2fa](https://openclaw.ai/docs/security/2fa)

This is optional but recommended if you're using your assistant for anything involving financial data, important emails, or file deletion.

---

## 🚨 Security Checklist

Do these once during setup, then check monthly:

- [ ] `chmod 600 ~/.openclaw/openclaw.json` — config file is locked down
- [ ] `allowFrom` contains only your Telegram ID(s)
- [ ] `dmPolicy` is set to `"pairing"`
- [ ] Monthly spending limit set on Anthropic (recommend $25 to start)
- [ ] Email alerts configured on Anthropic at 80% of limit
- [ ] `.gitignore` in place if using git
- [ ] Weekly backup configured or scheduled

---

## 🆘 If Something Goes Wrong

**"Someone is using my bot"** → Remove their ID from `allowFrom` immediately, or set `dmPolicy: "pairing"`. Then rotate your bot token in Telegram's @BotFather.

**"I see unexpected Anthropic charges"** → Go to console.anthropic.com → Usage, see what's running. Check your `allowFrom` list. Rotate your API key.

**"I leaked my API key"** → Revoke it immediately on Anthropic console → API Keys. Create a new one. Update your config.

---

➡️ **Next:** [COMMANDS.md](COMMANDS.md) — Quick reference card for all important commands
