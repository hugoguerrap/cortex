---
name: connect-telegram
description: Connect your Cortex agent to Telegram via NitroAgent — guided setup, fully autonomous.
user-invocable: true
---

# Connect Telegram

## When to Use
When the user wants to chat with their Cortex agent from Telegram. This command handles EVERYTHING — installs dependencies, guides through bot creation, configures, builds, and starts the service. The user should need zero prior knowledge.

## Behavior
Be a hands-on guide. Don't list prerequisites and hope the user figures it out — check each one, fix what's missing, and walk through what requires manual steps (like creating a Telegram bot). Use short, clear messages between steps so the user knows what's happening.

## Steps

### 1. Check if Already Configured
```bash
CORTEX_HOME="${CORTEX_HOME:-$HOME/.claude/cortex}"
NITRO_HOME="$CORTEX_HOME/nitro-agent"
```
If `$NITRO_HOME/nitro-agent/agents.toml` exists and the service is running, tell the user it's already set up. Offer to reconfigure or add another agent.

### 2. Check and Fix Dependencies

#### Xcode CLI Tools
```bash
xcode-select -p >/dev/null 2>&1
```
If missing, run `xcode-select --install` and tell the user to click "Install" in the popup that appears. Wait for them to confirm it's done before continuing.

#### Rust Toolchain
```bash
command -v cargo >/dev/null 2>&1
```
If missing, tell the user:
> I need to install the Rust compiler to build the Telegram bridge. This is a one-time setup that takes about 2 minutes.

Then run:
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
source "$HOME/.cargo/env"
```
Verify with `cargo --version`.

#### Git
```bash
command -v git >/dev/null 2>&1
```
If missing (extremely rare on macOS), install via `xcode-select --install`.

### 3. Create the Telegram Bot (Guided)

Check if the user already has a token:
- Check env var `CORTEX_TELEGRAM_TOKEN`
- Ask: "Do you already have a Telegram bot token?"

**If they don't have one**, guide them step by step:

> Let's create your Telegram bot. This takes about 1 minute:
>
> 1. Open Telegram on your phone or desktop
> 2. Search for **@BotFather** and open the chat
> 3. Send: `/newbot`
> 4. BotFather will ask for a **name** — this is the display name (e.g. "My Assistant")
> 5. Then it asks for a **username** — must end in "bot" (e.g. "my_cortex_bot")
> 6. BotFather will reply with a token that looks like: `7409459116:AAEhhSREeHChoat648ZRDz8xsJQp-t29vZk`
>
> Paste the token here when you have it.

Wait for the user to provide the token. Validate format: should match pattern `\d+:[A-Za-z0-9_-]+`.

If the format looks wrong, say so and ask them to try again.

### 4. Get the User's Telegram ID

Check if the user already has it:
- Check env var `CORTEX_TELEGRAM_CHAT_ID`
- Ask: "Do you know your Telegram user ID?"

**If they don't know it**, guide them:

> Now I need your Telegram numeric user ID (not your username). To get it:
>
> 1. Open Telegram
> 2. Search for **@userinfobot** and open the chat
> 3. Send any message (or just `/start`)
> 4. It will reply with your ID — a number like `6796594458`
>
> Paste that number here.

Validate: should be a numeric string (all digits).

### 5. Configure Agent Details

Ask (with sensible defaults):
- **Agent name**: "What should your bot be called?" (default: assistant name from `~/.claude/cortex/identity/SOUL.md` if it exists, otherwise "cortex")
- **Workspace**: "Which project folder should it work in?" (default: the current working directory)

### 6. Clone and Build NitroAgent

Tell the user what's happening:
> Installing the Telegram bridge (NitroAgent). This compiles from source — first time takes 2-3 minutes, after that it's cached.

```bash
CORTEX_HOME="${CORTEX_HOME:-$HOME/.claude/cortex}"
NITRO_HOME="$CORTEX_HOME/nitro-agent"

# Clone
if [ ! -d "$NITRO_HOME" ]; then
    git clone https://github.com/octaviusp/NitroAgent.git "$NITRO_HOME"
fi

# Build
cd "$NITRO_HOME/nitro-agent"
cargo build --release 2>&1
```

If the build fails:
- Missing Xcode tools → `xcode-select --install`
- Missing OpenSSL → `brew install openssl` (if Homebrew available)
- Other error → show the error and suggest checking Rust installation

### 7. Write Configuration

Create `.env` at `$NITRO_HOME/nitro-agent/.env`:
```
AGENT_BOT_TOKEN=<token from step 3>
RUST_LOG=info
```

Create `agents.toml` at `$NITRO_HOME/nitro-agent/agents.toml`:
```toml
[defaults]
allowed_user_ids = "<user_id from step 4>"
default_engine = "claude"
default_tool_mode = "safe"
max_output_chars = 8000
bot_to_bot_max_turns = 0

[agent.<agent_name>]
telegram_bot_token = "${AGENT_BOT_TOKEN}"
workspace_root = "<workspace from step 5>"
```

### 8. Install and Start as Daemon

```bash
cd "$NITRO_HOME/nitro-agent"
bash install-service.sh
```

Wait 3 seconds, then verify:
```bash
bash install-service.sh --status
```

If it's not running, check logs and report the issue:
```bash
tail -20 logs/daemon-stderr.log
```

### 9. Send a Test Message

Tell the user:
> Your bot is running! Let's test it:
>
> 1. Open Telegram
> 2. Search for your bot's username (the one you chose in step 3)
> 3. Send `/start`
>
> You should see a welcome message with the model info. If it works, you're all set!

Wait for the user to confirm it works.

### 10. Final Summary

Once confirmed working:
```
Telegram connected!

Your agent "<agent_name>" is live at @<bot_username>.
Workspace: <workspace_path>

Quick commands from Telegram:
  /new        — fresh conversation
  /resume     — continue where you left off
  /mode full  — enable all Claude Code tools
  /compact    — compress long conversations
  /cancel     — stop current task

The bot runs in the background, starts on login, and restarts on crash.

To manage the service:
  Status: bash ~/.claude/cortex/nitro-agent/nitro-agent/install-service.sh --status
  Logs:   tail -f ~/.claude/cortex/nitro-agent/nitro-agent/logs/daemon-stderr.log
  Stop:   bash ~/.claude/cortex/nitro-agent/nitro-agent/uninstall-service.sh
```

Also save the configuration to memory:
```bash
# Append to ~/.claude/cortex/memory/context.md
echo "- Telegram bot connected: @<bot_username> → <workspace_path>" >> ~/.claude/cortex/memory/context.md
```

## Adding More Agents

If the user wants to add another bot later (e.g., for a different project):

1. Create another bot via @BotFather (same guided flow)
2. Add the new token to `.env`: `ANOTHER_TOKEN=<new_token>`
3. Add a new `[agent.name]` block to `agents.toml`
4. Restart: `bash ~/.claude/cortex/nitro-agent/nitro-agent/uninstall-service.sh && bash ~/.claude/cortex/nitro-agent/nitro-agent/install-service.sh`

## Troubleshooting

If something goes wrong at any step, don't just show the error — diagnose and fix:

| Problem | Diagnosis | Fix |
|---------|-----------|-----|
| cargo not found after install | Shell not reloaded | `source "$HOME/.cargo/env"` |
| Build fails with linker error | Missing Xcode tools | `xcode-select --install` |
| Bot doesn't respond | Wrong token or user ID | Verify token with `curl https://api.telegram.org/bot<TOKEN>/getMe` |
| Bot responds to /start but not messages | User ID mismatch | Check `allowed_user_ids` in agents.toml matches the user's actual ID |
| Service won't start | Port/binary issue | Check `tail -20 logs/daemon-stderr.log` |
| "claude: command not found" in daemon | PATH issue | Verify Claude CLI path: `which claude`, then check install-service.sh resolved PATH |
