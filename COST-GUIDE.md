# 💰 Cost Guide — Optional Cloud AI Upgrade

**Your current setup is 100% free.** OpenClaw is free, Telegram is free, and your local AI model (Ollama + Qwen3.5) runs on your own computer at zero cost.

This guide covers what happens if you decide to add **Anthropic's Claude** as a cloud upgrade for tasks where you want more power.

---

## What Costs Money vs. What's Free

| Service | Cost |
|---------|------|
| OpenClaw software | ✅ Free forever |
| Telegram app | ✅ Free |
| GitHub account | ✅ Free |
| Brave Search (2,000 searches/mo) | ✅ Free tier |
| **Anthropic Claude API** | 💳 Pay-as-you-go |
| Google account | ✅ Free |

**The only bill you'll get** is from Anthropic, for Claude API usage. Everything else is free.

---

## Typical Monthly Costs

These are real-world estimates based on normal usage patterns:

| Usage Level | What It Looks Like | Monthly Cost |
|-------------|-------------------|-------------|
| **Light** | A few chats per day, simple questions, occasional web searches | $2–5 |
| **Moderate** | Daily use, research tasks, writing help, file work | $5–20 |
| **Heavy** | All-day use, complex multi-step tasks, lots of web searches | $20–50 |
| **Extreme** | Continuous automation, running agents overnight | $50–150+ |

Most people starting out fall in the **light to moderate** range.

---

## Understanding How You're Billed

Claude charges per **token** — roughly one token per word (or 4 characters).

- Every message you send costs tokens (input)
- Every response Claude gives costs tokens (output)
- Longer conversations = more tokens = more cost

**Practical implication:** A short, focused conversation costs much less than a long, rambling one.

---

## Model Cost Comparison

Not all Claude models cost the same. You can choose which model to use.

| Model | Speed | Quality | Cost | Best For |
|-------|-------|---------|------|----------|
| **Claude Haiku** | ⚡ Very fast | Good | 💲 Cheapest | Simple questions, quick tasks |
| **Claude Sonnet** | Fast | ✅ Excellent | 💲💲 Moderate | Most daily tasks (recommended) |
| **Claude Opus** | Slower | 🏆 Best | 💲💲💲 Expensive | Complex analysis, creative work |

**Recommendation:** Use **Sonnet** as your default. It gives you excellent quality at a reasonable price. Switch to Haiku for simple tasks if you're watching costs.

### Setting Your Default Model

Edit your config:
```bash
nano ~/.openclaw/openclaw.json
```

Look for the `model` field and change it:
The easiest way to change your model is:
```bash
openclaw configure
```

Or, if you want to edit manually, the model strings include the provider prefix:
```
anthropic/claude-haiku-4-5     (cheapest)
anthropic/claude-sonnet-4-5    (recommended default)
anthropic/claude-opus-4-5      (best quality, most expensive)
```

---

## How to Check Your Spending

1. Go to [https://console.anthropic.com/](https://console.anthropic.com/)
2. Click on your account name → **Usage** (or look for a "Usage" link in the sidebar)
3. You'll see:
   - Daily usage chart
   - Current month total
   - Breakdown by model

<!-- SCREENSHOT: Anthropic usage dashboard showing spending graph -->

**Check this weekly** until you have a sense of your normal usage pattern.

---

## How to Set a Monthly Spending Limit

Do this **now** if you haven't already. It's your safety net.

1. Go to [https://console.anthropic.com/](https://console.anthropic.com/)
2. Click your account name → **Billing** or **Settings**
3. Find **Usage Limits** or **Spend Limits**
4. Set a **Monthly Limit** — we recommend **$25 to start**
5. Optionally: Set an email alert at $20 (80% of your limit)
6. Save

<!-- SCREENSHOT: Anthropic spend limit configuration screen -->

**What happens when you hit the limit?** The API stops responding. Your bot goes quiet for the rest of the month. You'll need to increase the limit or wait for the next billing period. This is intentional — it's much better than surprise bills.

---

## Tips to Keep Costs Low

### 1. Use `/new` Frequently
Starting a new conversation clears the context. Shorter conversations = fewer tokens per message.

### 2. Be Specific and Concise
```
❌ "Hey can you help me think through some stuff about my work situation and maybe give me some ideas"

✅ "List 5 ways to politely decline a meeting invitation"
```
The second message gets a better answer AND costs less.

### 3. Use Haiku for Simple Tasks
If you're asking something simple — "What's the capital of France?" or "Format this list alphabetically" — switch to Haiku temporarily or ask your assistant to use it.

### 4. Don't Leave Long Conversations Running
If you've been chatting for a long time and the conversation got long, start fresh with `/new`. Every message in a conversation adds to the context that gets sent with each new message.

### 5. Watch Web Search Usage
Every web search uses API tokens to process the results. Searches are worth it for current information — just don't search unnecessarily.

### 6. Review Usage After the First Week
After your first full week of use, check your usage graph on Anthropic's console. This tells you your actual baseline cost and lets you decide if adjustments are needed.

---

## How to Pause or Stop (Stop All Charges)

If you want to stop paying entirely — maybe you're going on vacation or just want a break:

**Pause (stop charges, keep everything intact):**
```bash
openclaw gateway stop
```
Your assistant goes to sleep. No messages processed = no charges. Start it again anytime with `openclaw gateway start`.

**Full stop (remove all charges permanently):**
1. Stop the gateway: `openclaw gateway stop`
2. Revoke your API key: go to console.anthropic.com → API Keys → delete the key
3. That's it — with no valid API key, nothing can run and nothing can be charged

Your workspace files, personality, and memory are all saved locally on your computer. They don't go anywhere. You can always start again later by creating a new API key.

---

## Free Alternatives to Consider

If costs become a concern:
- **Brave Search:** Use the free tier (2,000 queries/month) — more than enough for personal use
- **Local models:** OpenClaw can connect to local AI models (like Ollama) — zero API cost, but requires a capable computer and the quality is lower

---

## Summary

| Action | Typical Cost |
|--------|-------------|
| One short conversation (5–10 messages) | ~$0.01–0.05 |
| One research task with web searches | ~$0.10–0.30 |
| One full day of moderate use | ~$0.50–2.00 |
| Monthly for normal daily use | $5–20 |

Start with a $25/month limit. Check your usage after the first week. Adjust from there.

---

*See also: [SECURITY.md](SECURITY.md) — Setting up spending alerts and budget limits*
