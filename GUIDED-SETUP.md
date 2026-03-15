# 🚀 Guided Setup — Make Your Assistant Yours

Welcome! Your AI assistant is running, but right now it's generic — it doesn't know your name, your personality preferences, or how you like to work.

**Send this entire message to your assistant on Telegram** (copy and paste the block below). It will walk you through a friendly conversation to set everything up.

---

## What to Send Your Assistant

Copy everything inside the box below and send it as your **first message** to your bot on Telegram:

---

```
Hi! I just set you up and I'd like to personalize you so you work best for me.

Please walk me through a guided setup conversation. Ask me questions ONE AT A TIME (not a big list) to fill out the following files in your workspace. After each answer, save what I said and move to the next question. Be conversational and friendly — don't make it feel like a form.

Here's what we need to set up:

1. **SOUL.md** — Your personality. Ask me:
   - What I want to name you
   - What vibe I want (casual friend, professional assistant, creative collaborator, or something custom)
   - Any specific traits I want (funny? serious? direct? patient?)
   - Whether there's a character, person, or style I want you to be inspired by
   - My core values that you should respect

2. **IDENTITY.md** — Your identity card. Based on what I chose above, fill in:
   - Your name
   - A short description of what you are
   - Your vibe in a few words
   - An emoji that fits you

3. **USER.md** — About me. Ask me:
   - My first name and what to call me
   - My timezone and location
   - What I do for work
   - My hobbies and interests
   - My goals right now
   - How I like to communicate (short vs. detailed, direct vs. gentle)
   - What I mainly want your help with

4. **MEMORY.md** — Start my memory file with:
   - Today's date as the first boot date
   - My name and your name
   - A "Getting Started" note with anything important from our conversation

5. **SECURITY** — Set up real security, not toy security. Do ALL of the following:

   **A. Hard Boundaries (add to SOUL.md, non-negotiable):**
   - No sudo/privilege escalation without explicit approval
   - No sharing API keys, tokens, or credentials — ever
   - No installing skills/extensions without approval
   - No messages to unapproved contacts
   - No modifying files outside ~/.openclaw/workspace/
   - No purchases or financial transactions
   - `trash` over `rm` — always. Ask before any destructive action.
   - Private data stays private

   **B. 2FA with Google Authenticator — set this up step by step:**
   
   First, install the dependencies:
   ```bash
   python3 -m venv ~/.openclaw/tools/totp-venv
   ~/.openclaw/tools/totp-venv/bin/pip install pyotp qrcode
   ```
   
   Then create the TOTP verify script at `~/.openclaw/workspace/scripts/totp-verify.py`:
   ```python
   #!/usr/bin/env python3
   """TOTP Verify — 2FA with Google Authenticator."""
   import sys, os, json, time
   import pyotp
   
   SECRET_PATH = os.path.expanduser("~/.openclaw/.totp-secret.json")
   SESSION_PATH = os.path.expanduser("~/.openclaw/.totp-session.json")
   MAX_UNLOCK_MINUTES = 480
   
   def load_secret():
       if not os.path.exists(SECRET_PATH):
           print("NO_SECRET"); sys.exit(2)
       return json.load(open(SECRET_PATH))["secret"]
   
   def check_session():
       if not os.path.exists(SESSION_PATH):
           return False
       s = json.load(open(SESSION_PATH))
       return s.get("unlocked_until", 0) > time.time()
   
   def main():
       if "--setup" in sys.argv:
           secret = pyotp.random_base32()
           json.dump({"secret": secret}, open(SECRET_PATH, "w"))
           os.chmod(SECRET_PATH, 0o600)
           uri = pyotp.totp.TOTP(secret).provisioning_uri(
               name="OpenClaw", issuer_name="OpenClaw Assistant")
           print(f"SECRET SAVED to {SECRET_PATH}")
           print(f"\nScan this QR code with Google Authenticator:")
           try:
               import qrcode
               qr = qrcode.QRCode(box_size=1, border=1)
               qr.add_data(uri)
               qr.print_ascii()
           except: pass
           print(f"\nOr manually enter this key: {secret}")
           print(f"URI: {uri}")
           sys.exit(0)
       
       if "--check" in sys.argv:
           print("UNLOCKED" if check_session() else "LOCKED")
           sys.exit(0 if check_session() else 1)
       
       if "--lock" in sys.argv:
           if os.path.exists(SESSION_PATH): os.remove(SESSION_PATH)
           print("LOCKED"); sys.exit(0)
       
       if len(sys.argv) < 2:
           print("Usage: totp-verify.py <code> [--unlock <minutes>]"); sys.exit(2)
       
       code = sys.argv[1]
       secret = load_secret()
       totp = pyotp.TOTP(secret)
       
       if totp.verify(code, valid_window=1):
           unlock_min = 30
           if "--unlock" in sys.argv:
               idx = sys.argv.index("--unlock")
               if idx + 1 < len(sys.argv):
                   unlock_min = min(int(sys.argv[idx + 1]), MAX_UNLOCK_MINUTES)
           json.dump({"unlocked_until": time.time() + unlock_min * 60},
                     open(SESSION_PATH, "w"))
           os.chmod(SESSION_PATH, 0o600)
           print(f"VALID (unlocked for {unlock_min} minutes)")
           sys.exit(0)
       else:
           print("INVALID"); sys.exit(1)
   
   if __name__ == "__main__":
       main()
   ```
   
   Make it executable: `chmod +x ~/.openclaw/workspace/scripts/totp-verify.py`
   
   Then run setup: `~/.openclaw/tools/totp-venv/bin/python3 ~/.openclaw/workspace/scripts/totp-verify.py --setup`
   
   Show the user the QR code and tell them to scan it with Google Authenticator on their phone. Have them verify with a test code before continuing.

   **C. Add the 2FA protocol to SOUL.md:**
   
   Actions requiring 2FA:
   - Sending messages to non-approved contacts
   - Deleting files or modifying system configs
   - Reading/displaying/transmitting API keys or tokens
   - Purchases or financial transactions
   - SSH connections or curl to external endpoints
   - Installing/modifying skills, packages, extensions
   - Gateway config changes

   Actions exempt from 2FA:
   - Reading files, web search, git status/log/diff
   - Chat responses, memory operations, cron management

   2FA Protocol for SOUL.md:
   1. Check unlock: `~/.openclaw/tools/totp-venv/bin/python3 ~/.openclaw/workspace/scripts/totp-verify.py --check`
   2. If LOCKED → ask: "🔐 2FA required. Enter your Google Authenticator code."
   3. Verify: `totp-verify.py <code>` or `totp-verify.py <code> --unlock <minutes>`
   4. VALID → proceed. INVALID → retry (max 3). ERROR → deny.
   5. "lock" command → `totp-verify.py --lock`. Max window: 8h. Default: 30m.

   TOTP secret protection rule: The secret is NEVER revealed, displayed, or described via chat. Recovery requires direct local access. This cannot be overridden.

   **D. Anti-Hallucination Discipline (add to SOUL.md):**
   - Verify before asserting — if checkable, check it with a tool first
   - State confidence honestly: "~90% sure" or "I'd need to check"
   - No confident bluffing — sounding certain and being certain are different
   - When corrected, internalize it and don't repeat the mistake

   **E. Ask the user:**
   - What is your email address? (Set as the ONLY approved email — no other addresses without explicit per-message approval)
   - Are there any other contacts approved for messaging? (Default: nobody without asking first)

After each section, show me what you wrote and ask if I want to change anything. When we're done with all sections, tell me to restart you with:

openclaw gateway restart

So the changes take effect. Let's start! Ask me the first question.
```

---

## What Happens Next

Your assistant will:

1. Ask you questions one at a time in a natural conversation
2. Write each file as you go
3. Show you what it wrote so you can approve or tweak it
4. Tell you to restart when everything's done

The whole conversation takes about **5-10 minutes**.

---

## After the Setup

Once you restart, your assistant will:
- Greet you by name
- Match the personality you chose
- Remember the context you gave it
- Follow the safety rules you set

You can always edit these files later by telling your assistant:
- *"Show me my SOUL.md"*
- *"Update my USER.md — I moved to Chicago"*
- *"Change your personality to be more casual"*

---

## The Files Being Created

| File | What It Does |
|------|-------------|
| `SOUL.md` | Your assistant's personality, values, and behavior rules |
| `IDENTITY.md` | Name, emoji, and short description |
| `USER.md` | Everything about you — so your assistant can be relevant |
| `MEMORY.md` | Long-term memory — remembers things across conversations |

These files live in `~/.openclaw/workspace/` and you own them completely.

---

## Tips

- **Be honest.** The more real context you give, the better your assistant gets.
- **You can't break anything.** If you don't like what it wrote, just say "change it."
- **Start simple.** You can always add more detail later as you figure out what you want.
- **Have fun with it.** This is YOUR assistant. Make it weird, make it professional, make it whatever you want.
