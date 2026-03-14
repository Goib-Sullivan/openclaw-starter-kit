# MEMORY.md — Long-Term Memory

This file is where your assistant stores important information between sessions.

It starts empty. Your assistant will add notes here as you have conversations — things you ask it to remember, preferences you express, important decisions.

---

## How It Works

During a conversation, you can say things like:
- "Remember that my car is a blue Honda Civic."
- "Add a note that I prefer bullet points over numbered lists."
- "Note that I have a meeting every Tuesday at 2pm."

Your assistant will write these to this file. Next session, it reads this file during startup and "remembers" what you told it.

---

## Format (for your assistant)

When adding entries, use this format:
```
## [Date] — [Category]
[What to remember]
```

Example:
```
## 2025-01-15 — Preferences
User prefers concise responses with bullet points. Dislikes long preambles.

## 2025-01-20 — Personal
User's car: blue Honda Civic. Lives in Chicago.
```

---

*This file is currently empty. Start a conversation and ask your assistant to remember something!*
