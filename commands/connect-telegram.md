---
name: connect-telegram
description: Connect your Cortex agent to Telegram via NitroAgent — chat with Claude Code from your phone.
user-invocable: true
---

# Connect Telegram

## When to Use
When the user wants to chat with their Cortex agent from Telegram. This sets up NitroAgent as the runtime bridge between Telegram and Claude Code.

## Prerequisites
- macOS (NitroAgent runs as a launchd daemon)
- Rust toolchain (`cargo`) — if not installed, offer to install via `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
- A Telegram bot token from [@BotFather](https://t.me/BotFather)
- Your Telegram user ID (get it from [@userinfobot](https://t.me/userinfobot))

## Steps

### 1. Check Prerequisites
```bash
# Check Rust
command -v cargo >/dev/null 2>&1 || echo "MISSING: cargo"

# Check if NitroAgent already installed
NITRO_HOME="${CORTEX_HOME:-$HOME/.claude/cortex}/nitro-agent"
[ -d "$NITRO_HOME" ] && echo "EXISTS" || echo "NEW"
```

### 2. Gather Information
Ask the user for:
- **Telegram Bot Token** — from @BotFather (looks like `123456:ABC-DEF...`)
- **Telegram User ID** — numeric ID (looks like `6796594458`)
- **Agent name** — what to call the bot (default: the assistant name from SOUL.md, or "cortex")
- **Workspace** — which directory should the agent work in? (default: current project directory)

If the user already has `CORTEX_TELEGRAM_TOKEN` and `CORTEX_TELEGRAM_CHAT_ID` set, offer to reuse those.

### 3. Install NitroAgent
```bash
CORTEX_HOME="${CORTEX_HOME:-$HOME/.claude/cortex}"
NITRO_HOME="$CORTEX_HOME/nitro-agent"

# Clone if not present
if [ ! -d "$NITRO_HOME" ]; then
    git clone https://github.com/octaviusp/NitroAgent.git "$NITRO_HOME"
fi

# Build
cd "$NITRO_HOME/nitro-agent"
cargo build --release
```

### 4. Configure
Create `.env` at `$NITRO_HOME/nitro-agent/.env`:
```bash
AGENT_BOT_TOKEN=<the token the user provided>
RUST_LOG=info
```

Create `agents.toml` at `$NITRO_HOME/nitro-agent/agents.toml`:
```toml
[defaults]
allowed_user_ids = "<user_telegram_id>"
default_engine = "claude"
default_tool_mode = "safe"
max_output_chars = 8000
bot_to_bot_max_turns = 0

[agent.<agent_name>]
telegram_bot_token = "${AGENT_BOT_TOKEN}"
workspace_root = "<workspace_path>"
```

### 5. Install as Daemon
```bash
cd "$NITRO_HOME/nitro-agent"
bash install-service.sh
```

### 6. Verify
```bash
sleep 3
bash "$NITRO_HOME/nitro-agent/install-service.sh" --status
```

### 7. Confirm to User
```
Telegram connected!

Your agent "<agent_name>" is now running as a background service.
Open Telegram and send /start to your bot to begin chatting.

What you can do from Telegram:
  - Send any message → Claude Code executes it in your workspace
  - Send voice messages → transcribed and executed
  - Send photos → Claude analyzes them
  - /new → fresh conversation
  - /resume → continue previous session
  - /mode full → enable all tools (default: safe mode)

Service management:
  - Status: bash ~/.claude/cortex/nitro-agent/nitro-agent/install-service.sh --status
  - Stop:   bash ~/.claude/cortex/nitro-agent/nitro-agent/uninstall-service.sh
  - Logs:   tail -f ~/.claude/cortex/nitro-agent/nitro-agent/logs/daemon-stderr.log

The bot starts automatically on login and restarts on crash.
```

## Adding More Agents Later
The user can edit `~/.claude/cortex/nitro-agent/nitro-agent/agents.toml` to add more bots:
```toml
[agent.another-bot]
telegram_bot_token = "${ANOTHER_TOKEN}"
workspace_root = "/path/to/project"
```
Then add `ANOTHER_TOKEN=...` to `.env` and restart the service.

## Troubleshooting
- **"cargo: command not found"** → Install Rust: `curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh`
- **Bot not responding** → Check logs: `tail -f ~/.claude/cortex/nitro-agent/nitro-agent/logs/daemon-stderr.log`
- **Permission denied** → The bot only responds to the configured `allowed_user_ids`
- **Build fails** → Ensure Xcode CLI tools: `xcode-select --install`
