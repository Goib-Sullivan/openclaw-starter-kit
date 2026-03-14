# 🚀 First Steps — Your First 30 Minutes

Congratulations — OpenClaw is installed and running! Now let's explore what your assistant can do.

This guide covers your first conversation, the essential commands, and a tour of the dashboard.

---

## Where Can You Chat?

You have two ways to talk to your assistant:

### Option A: Telegram (Recommended for daily use)
Open Telegram on your phone or desktop and find the bot you created during setup (search for your bot's username, e.g., `@myassistant_bot`). Start a chat and say hello!

### Option B: Web Dashboard
Open your browser and go to: **http://127.0.0.1:18789/**

Click the chat interface in the dashboard. Great for when you're at your computer and don't want to switch apps.

<!-- SCREENSHOT: Dashboard chat interface showing a conversation -->

---

## Your First Conversation

Open Telegram (or the dashboard) and try these:

### 👋 Say Hello
```
Hello! Can you introduce yourself?
```

Your assistant will respond with its name and a brief introduction based on what you put in `SOUL.md`.

### 🌐 Try a Web Search
```
What's in the news today?
```

If you set up a Brave Search API key, your assistant will search the web and summarize the latest news.

### 📁 Ask About Files
```
What files are in my workspace?
```

### 🤔 Ask It Anything
```
Explain what a REST API is in simple terms.
```

Your assistant is patient and won't make you feel silly for asking basic questions.

---

## Essential Commands

These are special commands that control your assistant session (not regular chat messages). Send them in Telegram or the dashboard chat.

### `/new` — Start a Fresh Conversation
```
/new
```
Clears the current conversation context. Use this when you're switching topics and want a clean slate. Your assistant's memory and personality stay intact — just the current chat history resets.

**When to use:** When a conversation gets long and cluttered, or you're done with one task and starting another.

### `/reset` — Full Reset
```
/reset
```
Resets the session more thoroughly. Use if your assistant seems confused or stuck in an odd loop.

**When to use:** Rarely — usually `/new` is enough.

### `/status` — Check What's Running
```
/status
```
Your assistant will report on its own health — which model it's using, what tools are available, and the current session state.

**What you should see:**
```
🟢 Status: Active
Model: claude-sonnet-4-5
Tools: web_search, exec, read, write...
Session: [session ID]
```

---

## Terminal Commands (Run in Ubuntu)

These are commands you type in your WSL2/Ubuntu terminal — not in the chat.

### Check Gateway Status
```bash
openclaw status
```

### Start the Gateway (if it's stopped)
```bash
openclaw gateway start
```

### Open the Dashboard
```bash
openclaw dashboard
```

### Run a Health Check
```bash
openclaw doctor
```

---

## The Web Dashboard Tour

Open **http://127.0.0.1:18789/** in your browser.

<!-- SCREENSHOT: OpenClaw dashboard main screen with labeled sections -->

### What You'll Find

**🏠 Home / Overview**
- Gateway status (green = running)
- Active session count
- Quick health indicators

**💬 Chat**
- Full chat interface — same as Telegram but in the browser
- Good for long sessions when you're at your desk

**⚙️ Settings**
- View your current configuration
- Manage connected channels (Telegram, etc.)
- Skill management

**📋 Logs**
- Real-time activity log
- Useful for debugging if something isn't working

**📊 Sessions**
- List of active and recent sessions
- See what's been happening

---

## Things to Try in Your First Session

Here are some fun and useful things to explore:

### 1. Set Up Your Identity
Edit your USER.md to personalize your assistant:
```
Please call me [your name] and use a friendly, casual tone.
```

### 2. Ask for Help With a Task
```
I need to write an email to my landlord about a maintenance issue. Can you help?
```

### 3. Try a Research Task
```
Research the pros and cons of standing desks and give me a summary.
```

### 4. Get Organized
```
I have these tasks to do today: [list them]. Help me prioritize them.
```

### 5. Learn About Your Assistant
```
What skills do you have? What can you help me with?
```

---

## Understanding Your Assistant's Behavior

### It Has a Personality
The `SOUL.md` and `USER.md` files in your workspace shape how your assistant responds. Open them with a text editor and fill in the placeholders — the more context you give, the better it gets.

### It Has Memory
Your assistant can remember things between conversations. Try:
```
My car is a blue Honda Civic. Please remember that.
```
Then in a future conversation:
```
What kind of car do I have?
```

### It Can Use Tools
Your assistant can browse the web, read and write files, run commands, and more — depending on which tools and skills are enabled. It will ask for permission before doing anything significant.

### It Runs in the Background
Once installed as a daemon, OpenClaw keeps running even when you close the Ubuntu terminal. It will still respond to Telegram messages. To check: run `openclaw status` in a new terminal.

---

## What's Next?

- 🔒 **[SECURITY.md](SECURITY.md)** — Lock down your setup (do this soon!)
- 💰 **[COST-GUIDE.md](COST-GUIDE.md)** — Understand what you're spending and how to keep it low
- 📋 **[COMMANDS.md](COMMANDS.md)** — Quick reference card to keep handy

---

## Quick Tips

💡 **Keep messages focused** — shorter, clearer messages get better responses than long rambling ones.

💡 **Be specific** — "Summarize this article: [URL]" works better than "can you help me with this article?"

💡 **You can paste long text** — paste an entire email or document and ask your assistant to analyze it.

💡 **The dashboard is great for debugging** — if your Telegram bot isn't responding, check the dashboard logs.

💡 **Restart if things get weird** — `openclaw gateway restart` fixes most strange behavior.
