# 🔑 Accounts Setup Guide

Set up every account you'll need **before** installing anything. This takes about 20 minutes and saves you from stopping mid-install to go create something.

Open a notepad (Notepad on Windows, or just a text file) and save each key as you create it. You'll need them during install.

> 💡 **What's an API key?** Think of it like a password that lets one app talk to another. Your assistant needs API keys to connect to services like the AI brain (Anthropic) and web search (Brave). You create them once, paste them during setup, and then forget about them.

---

## Overview — What You're Creating

| Account | Why You Need It | Cost | Required? |
|---------|----------------|------|-----------|
| Telegram | Chat interface — how you talk to your assistant | Free | ✅ Yes |
| GitHub | Community access + downloading this kit | Free | ✅ Yes |
| Anthropic | Cloud AI brain (Claude) — optional upgrade | Pay-as-you-go | ⬜ Optional |
| Brave Search | Web search for your assistant | Free (2,000/mo) | ⬜ Optional |
| Google | Gmail integration, Drive backups | Free | ⬜ Optional |

> 💡 **You're starting with a free local AI model** that runs on your computer (set up in [LOCAL-AI-SETUP.md](LOCAL-AI-SETUP.md)). The Anthropic cloud AI is an optional upgrade you can add later when you want more power for complex tasks.

---

## Account 1: Telegram 💬

**Why:** Telegram is your chat interface. You'll message your assistant here from your phone or computer, just like texting a friend.

### Steps

1. **Download Telegram** on your phone: [https://telegram.org/](https://telegram.org/)
   - iOS: App Store → search "Telegram"
   - Android: Google Play → search "Telegram"

2. **Create a Telegram account** if you don't have one:
   - Open the app
   - Tap "Start Messaging"
   - Enter your phone number
   - Enter the verification code sent via SMS
   - Set a username (e.g., `@yourname123`) — you'll need this later

<!-- SCREENSHOT: Telegram sign-up screen with phone number field -->

3. **Create a Bot** — a bot is an automated Telegram account that your assistant uses to send and receive messages. Here's how to make one:
   - In Telegram, search for **@BotFather** (it has a blue checkmark ✅)
   - Start a chat with BotFather
   - Send the message: `/newbot`
   - It will ask for a name — type something like `My Assistant`
   - It will ask for a username — must end in `bot`, e.g., `myassistant_bot`
   - BotFather will reply with a **token** that looks like: `123456789:ABCdefGHIjklMNOpqrSTUvwxYZ`

<!-- SCREENSHOT: BotFather conversation showing /newbot flow -->

4. **Save your bot token** — copy it to your notepad right now. Label it:
   ```
   Telegram Bot Token: 123456789:ABCdefGHIjklMNOpqrSTUvwxYZ
   ```

5. **Find your Telegram User ID** — you'll need this for security settings:
   - Search for **@userinfobot** in Telegram
   - Start a chat and send any message
   - It will reply with your User ID (a number like `987654321`)
   - Save it: `My Telegram ID: 987654321`

<!-- SCREENSHOT: userinfobot showing your user ID -->

✅ **Done!** You have: a Telegram account, a bot token, and your user ID.

---

## Account 2: GitHub 🐙

**Why:** GitHub is where OpenClaw's code and community live. Having an account lets you download this starter kit, report problems, and connect with other users. You won't need to learn how to "code" — just having the account is enough.

### Steps

1. **Sign up** at: [https://github.com/](https://github.com/)
   - Click "Sign up"
   - Enter your email, create a password, choose a username
   - Complete the verification puzzle
   - Verify your email

<!-- SCREENSHOT: GitHub sign-up page -->

2. **That's it for now!** You don't need to create any repositories or install anything. Just have the account ready.

> 💡 Later, after WSL is set up (in INSTALL-GUIDE.md), you'll install `git` inside your Linux terminal. Don't worry about that now — just create the account.

<!-- SCREENSHOT: GitHub dashboard after sign-up -->

✅ **Done!** You have a GitHub account. No API key needed.

---

## Account 3: Brave Search (Optional but Recommended) 🔍

**Why:** This gives your assistant the ability to search the web. Without it, your assistant can only use information it was trained on — which has a cutoff date. With Brave Search, it can look things up in real time.

**Free tier:** 2,000 queries/month — plenty for normal use.

### Steps

1. **Sign up** at: [https://brave.com/search/api/](https://brave.com/search/api/)
   - Click "Get Started for Free"
   - Create an account with your email

<!-- SCREENSHOT: Brave Search API sign-up page -->

2. **Create an API key:**
   - After signing in, go to your dashboard
   - Find **API Keys** → **Create New Key**
   - Name it `openclaw`
   - Copy the key

<!-- SCREENSHOT: Brave Search API dashboard with key creation -->

3. **Save your key:**
   ```
   Brave Search API Key: [your key here]
   ```

4. **Check your plan:** Free tier gives 2,000 queries/month. That's about 65 web searches per day — more than enough for personal use.

✅ **Done!** You have a Brave Search API key for web access.

---

## Account 4: Anthropic / Claude AI (Optional) 🧠

**Why:** Anthropic makes Claude, a powerful cloud AI model that's better than local models at complex reasoning, long documents, and precise writing. You pay for each conversation based on usage — typically $5–20/month.

> 💡 **You can skip this for now.** Your local AI model (set up in [LOCAL-AI-SETUP.md](LOCAL-AI-SETUP.md)) handles 80-90% of everyday tasks for free. Come back and set this up whenever you want an upgrade for the tough stuff.

### Steps (when you're ready)

1. **Sign up** at: [https://console.anthropic.com/](https://console.anthropic.com/)
   - Click "Sign Up"
   - Enter your email and create a password
   - Verify your email

2. **Add a payment method:**
   - Click on your account name (top right) → **Billing**
   - Click **Add Payment Method**
   - Enter your credit/debit card details
   - You won't be charged until you actually use the API

3. **Set a monthly spending limit** (important for cost control!):
   - Still in Billing, look for **Spend Limits** or **Usage Limits**
   - Set a monthly limit of **$25** to start — you can increase later
   - This is your safety net

4. **Create an API key:**
   - Go to **API Keys** (left sidebar) → **Create Key**
   - Name it `openclaw-home`
   - Copy the key — looks like: `sk-ant-api03-...`
   - ⚠️ **This key will only be shown ONCE.** Copy it immediately.

5. **Save your API key:**
   ```
   Anthropic API Key: sk-ant-api03-...
   ```

6. **Add to OpenClaw:** Run `openclaw configure` in your Ubuntu terminal and add Anthropic as a provider.

### 💰 What Does This Cost?

| Usage Level | Monthly Cost |
|-------------|-------------|
| Light (few chats/day) | $2–5 |
| Moderate (daily use) | $5–20 |
| Heavy (all-day) | $20–50 |

See [COST-GUIDE.md](COST-GUIDE.md) for full details.

✅ **Optional.** Skip for now — you'll have a fully working assistant with just the local model.

---

## Account 5: Google Account (Optional) 📧

**Why:** Needed for Gmail integration (read/send emails through your assistant) and Google Drive backups of your workspace. You can absolutely skip this for now and add it later.

### If You Already Have a Google Account

Nothing to do here — just know that Gmail integration will be available when you're ready.

### If You Want to Set One Up

1. Go to: [https://accounts.google.com/signup](https://accounts.google.com/signup)
2. Follow the steps to create a new Gmail address
3. No API key needed now — OpenClaw has a guided setup for Google integration

✅ **Optional.** Skip if you want — you can set this up later.

---

## ✅ Your Pre-Install Checklist

Before moving to [INSTALL-GUIDE.md](INSTALL-GUIDE.md), confirm you have:

**Required:**
- [ ] **Telegram Bot Token** (from @BotFather)
- [ ] **Your Telegram User ID** (from @userinfobot)
- [ ] **GitHub account** created

**Optional (can add later):**
- [ ] Brave Search API Key
- [ ] Anthropic API Key + spending limit set

🔒 Keep your notepad safe. These keys are like passwords — never share them.

---

➡️ **Next step:** [INSTALL-GUIDE.md](INSTALL-GUIDE.md) — Installing WSL2 and OpenClaw
