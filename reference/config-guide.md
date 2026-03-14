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

## Top-Level Fields

### `model`
The default AI model used for conversations.

```json
"model": "claude-sonnet-4-5"
```

| Value | Description |
|-------|-------------|
| `"claude-haiku-4-5"` | Fastest and cheapest. Good for simple tasks. |
| `"claude-sonnet-4-5"` | ✅ Recommended. Best balance of quality and cost. |
| `"claude-opus-4-5"` | Highest quality, most expensive. For complex work. |

---

## `anthropic` Section

```json
"anthropic": {
  "apiKey": "sk-ant-api03-..."
}
```

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `apiKey` | string | ✅ Yes | Your Anthropic API key from console.anthropic.com |

> 🔒 This is sensitive. Never share this value.

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

## `telegram` Section

This is where Telegram integration is configured. All fields go inside the `telegram` object.

```json
"telegram": {
  "enabled": true,
  "botToken": "123456789:ABCdefGHIjklMNOpqrSTUvwxYZ",
  "dmPolicy": "pairing",
  "groupPolicy": "enabled",
  "allowFrom": ["987654321"],
  "streaming": "words"
}
```

### Field Reference

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `enabled` | boolean | Yes | `true` to enable Telegram, `false` to disable |
| `botToken` | string | ✅ Yes | Your bot token from @BotFather. Format: `123456789:ABC...` |
| `dmPolicy` | string | ✅ Yes | Who can DM the bot. See values below. |
| `groupPolicy` | string | ✅ Yes | Whether the bot works in group chats. |
| `allowFrom` | array of strings | Recommended | List of Telegram user IDs allowed to use the bot. |
| `streaming` | string | No | How responses stream in Telegram. See values below. |

> ⚠️ **`dmPolicy` and `groupPolicy` are REQUIRED.** If either is missing, the config will fail validation.

> ⚠️ **Field names are case-sensitive.** Use `botToken` not `bot_token`. Use `allowFrom` not `allowedUsers`.

---

### `dmPolicy` Values

Controls who can start a direct message conversation with your bot.

| Value | Behavior |
|-------|----------|
| `"pairing"` | ✅ **Recommended.** Only users in `allowFrom` can chat with the bot in DMs. Everyone else is ignored. |
| `"open"` | ⚠️ Anyone who finds your bot can start a DM. Do not use this unless you intend a public bot. |
| `"disabled"` | DMs are disabled entirely. Only group chats work. |

**Always use `"pairing"` for personal use.** It ensures only you (and people you explicitly approve) can use your bot.

---

### `groupPolicy` Values

Controls whether and how the bot works in Telegram group chats.

| Value | Behavior |
|-------|----------|
| `"enabled"` | Bot participates in group chats where it's a member |
| `"disabled"` | Bot ignores all group chats |

---

### `allowFrom` — The Access List

```json
"allowFrom": ["987654321"]
```

This is an array (list) of Telegram user IDs. Only users whose ID is in this list can interact with the bot.

**How to find a Telegram user ID:**
1. Open Telegram
2. Search for @userinfobot
3. Start a chat and send any message
4. It replies with your user ID

**Adding multiple people:**
```json
"allowFrom": ["987654321", "111222333", "444555666"]
```

**If this field is empty or missing:** Combined with `dmPolicy: "open"`, anyone can use your bot.

---

### `streaming` Values

Controls how long responses are delivered in Telegram (streamed word by word, or sent all at once).

| Value | Behavior |
|-------|----------|
| `"words"` | Response appears word by word as it's generated |
| `"sentences"` | Response appears sentence by sentence |
| `"full"` | Response sent all at once when complete |

`"words"` gives the most responsive feel but generates more Telegram API calls. All options work fine.

---

## Complete Example Config

```json
{
  "model": "claude-sonnet-4-5",
  "anthropic": {
    "apiKey": "sk-ant-api03-YOUR-KEY-HERE"
  },
  "gateway": {
    "port": 18789
  },
  "telegram": {
    "enabled": true,
    "botToken": "123456789:YOUR-BOT-TOKEN-HERE",
    "dmPolicy": "pairing",
    "groupPolicy": "enabled",
    "allowFrom": ["YOUR-TELEGRAM-USER-ID"],
    "streaming": "words"
  }
}
```

Replace the placeholder values with your actual keys.

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
| Missing `dmPolicy` | Add `"dmPolicy": "pairing"` |
| Missing `groupPolicy` | Add `"groupPolicy": "enabled"` |
| Telegram user ID as number: `987654321` | Must be string: `"987654321"` |
| Trailing comma on last item | JSON doesn't allow trailing commas |

---

*See also: [../reference/troubleshooting.md](troubleshooting.md) for config-related errors*
