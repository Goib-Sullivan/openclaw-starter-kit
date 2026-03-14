# ⚙️ Configuration Guide — Field by Field

Your OpenClaw configuration lives in `~/.openclaw/openclaw.json`. This guide explains every important field so you know what you're looking at and what to change safely.

> ⚠️ **This file contains your API keys. Never commit it to GitHub. Never share it.**
> Lock it down: `chmod 600 ~/.openclaw/openclaw.json`

---

## Opening the Config File

```bash
nano ~/.openclaw/openclaw.json
```

It's a JSON file — structured like this:
```json
{
  "key": "value",
  "section": {
    "nestedKey": "nestedValue"
  }
}
```

After making changes, always restart the gateway:
```bash
openclaw gateway restart
```

And verify with:
```bash
openclaw doctor
```

---

## Understanding the Structure

OpenClaw's config is nested. The onboarding wizard generates this automatically, but here's how it's organized so you can find things when editing:

```
{
  agents → list → model        (which AI model to use)
  channels → telegram → ...    (Telegram settings)
  gateway → port, auth         (server settings)
  tools → web → search         (web search settings)
}
```

> 💡 **You usually don't need to edit this file manually.** The onboarding wizard (`openclaw onboard`) and reconfigure command (`openclaw configure`) handle most changes. This guide is for when you need to understand or tweak specific fields.

---

## `agents` Section

The model setting lives inside the agents configuration. For a simple single-agent setup, the onboarding wizard creates this for you.

The model format includes the provider prefix:

| Value | Description |
|-------|-------------|
| `"anthropic/claude-haiku-4-5"` | Fastest and cheapest. Good for simple tasks. |
| `"anthropic/claude-sonnet-4-5"` | ✅ Recommended. Best balance of quality and cost. |
| `"anthropic/claude-opus-4-5"` | Highest quality, most expensive. For complex work. |

> 💡 To change your model, the easiest way is: `openclaw configure`

---

## `auth` Section

Your API key is stored via an auth profile. The onboarding wizard sets this up securely.

> 🔒 This is sensitive. Never share your API key. If you need to update it, run `openclaw configure`.

---

## `gateway` Section

```json
"gateway": {
  "port": 18789
}
```

| Field | Type | Default | Description |
|-------|------|---------|-------------|
| `port` | number | `18789` | The port the gateway runs on. Don't change this unless you have a reason. |

The dashboard is accessible at `http://127.0.0.1:[port]/`. Default: http://127.0.0.1:18789/

---

## `channels.telegram` Section

Telegram settings live under `channels.telegram` in the config. All fields go inside this nested object.

```json
"channels": {
  "telegram": {
    "enabled": true,
    "botToken": "123456789:ABCdefGHIjklMNOpqrSTUvwxYZ",
    "dmPolicy": "allowlist",
    "groupPolicy": "allowlist",
    "allowFrom": [987654321],
    "streaming": "partial"
  }
}
```

### Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `enabled` | boolean | Yes | `true` to enable Telegram, `false` to disable |
| `botToken` | string | ✅ Yes | Your bot token from @BotFather. Format: `123456789:ABC...` |
| `dmPolicy` | string | ✅ Yes | Who can DM the bot. See values below. |
| `groupPolicy` | string | ✅ Yes | How the bot handles group chats. See values below. |
| `allowFrom` | array | Recommended | List of Telegram user IDs allowed to use the bot. |
| `streaming` | string | No | How responses stream in Telegram. See values below. |

> ⚠️ **`dmPolicy` and `groupPolicy` are REQUIRED.** If either is missing, the config will fail validation.

> ⚠️ **Field names are case-sensitive.** Use `botToken` not `bot_token`. Use `allowFrom` not `allowedUsers`.

---

### `dmPolicy` Values

Controls who can start a direct message conversation with your bot.

| Value | Behavior |
|-------|----------|
| `"allowlist"` | ✅ **Recommended.** Only users in `allowFrom` can chat with the bot in DMs. Everyone else is ignored. |
| `"pairing"` | Users must be approved via a pairing flow before they can chat. |
| `"open"` | ⚠️ Anyone who finds your bot can start a DM. Do not use this unless you intend a public bot. |

**Use `"allowlist"` for personal use.** It ensures only you (and people you explicitly add to `allowFrom`) can use your bot.

---

### `groupPolicy` Values

Controls whether and how the bot works in Telegram group chats.

| Value | Behavior |
|-------|----------|
| `"allowlist"` | ✅ **Recommended.** Bot only works in groups where users in `allowFrom` are present. |
| `"open"` | Bot responds in any group it's added to. |
| `"disabled"` | Bot ignores all group chats. |

---

### `allowFrom` — The Access List

```json
"allowFrom": [987654321]
```

This is an array (list) of Telegram user IDs. Only users whose ID is in this list can interact with the bot.

**How to find a Telegram user ID:**
1. Open Telegram
2. Search for @userinfobot
3. Start a chat and send any message
4. It replies with your user ID

**Adding multiple people:**
```json
"allowFrom": [987654321, 111222333, 444555666]
```

**If this field is empty or missing:** Combined with `dmPolicy: "open"`, anyone can use your bot.

---

### `streaming` Values

Controls how responses are delivered in Telegram — streamed progressively or sent all at once.

| Value | Behavior |
|-------|----------|
| `"partial"` | ✅ **Recommended.** Response streams progressively as it's generated. |
| `"block"` | Response streams in larger blocks (less frequent updates). |
| `"progress"` | Shows a progress indicator while generating. |
| `"off"` | Response sent all at once when complete. |

`"partial"` gives the most responsive feel. All options work fine.

---

## Complete Example Config

> 💡 **The onboarding wizard generates this for you.** This is just a reference so you understand the structure.

```json
{
  "channels": {
    "telegram": {
      "enabled": true,
      "botToken": "123456789:YOUR-BOT-TOKEN-HERE",
      "dmPolicy": "allowlist",
      "groupPolicy": "allowlist",
      "allowFrom": [YOUR_TELEGRAM_USER_ID],
      "streaming": "partial"
    }
  },
  "gateway": {
    "port": 18789
  }
}
```

The actual config file will have additional sections (agents, auth, tools, hooks, etc.) generated by the wizard. You typically only need to manually edit the `channels.telegram` section.

> 💡 **Prefer `openclaw configure` over manual editing** — it validates your changes and prevents typos.

---

## After Editing the Config

1. Save the file (`Ctrl+O` then Enter in nano, then `Ctrl+X`)
2. Restart the gateway:
   ```bash
   openclaw gateway restart
   ```
3. Run a health check:
   ```bash
   openclaw doctor
   ```
4. If the doctor shows errors, check the field that's flagged — it's usually a typo or missing required field.

---

## Common Config Mistakes

| Mistake | Correct |
|---------|---------|
| `"bot_token"` | `"botToken"` |
| `"allowedUsers"` | `"allowFrom"` |
| `"allow_from"` | `"allowFrom"` |
| Missing `dmPolicy` | Add `"dmPolicy": "allowlist"` |
| Missing `groupPolicy` | Add `"groupPolicy": "allowlist"` |
| Trailing comma on last item | JSON doesn't allow trailing commas |

---

*See also: [../reference/troubleshooting.md](troubleshooting.md) for config-related errors*
