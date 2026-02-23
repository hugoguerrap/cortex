---
name: setup
description: Initialize Cortex — creates memory, identity, and data directories in ~/.claude/cortex/.
user-invocable: true
---

# Setup

## When to Use
- First time using Cortex
- To re-initialize missing directories (idempotent — won't overwrite existing files)

## Important
All Cortex data lives in `~/.claude/cortex/`, NOT in the user's project. This keeps projects clean.

## Steps

### 1. Create Directory Structure
```bash
CORTEX_HOME="${CORTEX_HOME:-$HOME/.claude/cortex}"
mkdir -p "$CORTEX_HOME/memory"
mkdir -p "$CORTEX_HOME/identity"
mkdir -p "$CORTEX_HOME/data/logs"
mkdir -p "$CORTEX_HOME/data/reports"
mkdir -p "$CORTEX_HOME/data/exports"
mkdir -p "$CORTEX_HOME/scripts"
```

### 2. Copy Memory Templates
For each template, read it from `${CLAUDE_PLUGIN_ROOT}/templates/memory/` and write it to `~/.claude/cortex/memory/` **only if it doesn't already exist**:

Files: `context.md`, `strategy.md`, `lessons.md`, `preferences.md`, `conversations.md`, `watchlist.md`

### 3. Copy Identity Templates
From `${CLAUDE_PLUGIN_ROOT}/templates/identity/` to `~/.claude/cortex/identity/`:

Files: `SOUL.md`, `USER.md`

### 4. Copy Utility Scripts
From `${CLAUDE_PLUGIN_ROOT}/scripts/` to `~/.claude/cortex/scripts/`:

Files: `notify.sh`, `system_status.sh`, `awareness_scan.py`, `extract_transcripts.py`, `cron_runner.sh`

Make all executable: `chmod +x ~/.claude/cortex/scripts/*`

### 5. Ask the User
Prompt for basic personalization:
- **Assistant name**: What should your AI assistant be called? (default: "Assistant")
- **User name**: Your name
- **Notification channel**: How should the AI notify you? Options: `telegram`, `discord`, `slack`, `desktop`, `none`

### 6. Apply Personalization
Replace `{{ASSISTANT_NAME}}` in `~/.claude/cortex/identity/SOUL.md` with the chosen name.
Replace `{{USER_NAME}}` in `~/.claude/cortex/identity/USER.md` with the user's name.

### 7. Configure Notifications (if not `none`)
Tell the user which env vars to set:

| Channel | Required Env Vars |
|---------|------------------|
| telegram | `CORTEX_TELEGRAM_TOKEN`, `CORTEX_TELEGRAM_CHAT_ID` |
| discord | `CORTEX_DISCORD_WEBHOOK` |
| slack | `CORTEX_SLACK_WEBHOOK` |
| desktop | _none_ (uses native notifications) |

### 8. Offer Telegram Connection
Ask: **"Do you want to chat with your agent from Telegram?"**

If yes → run `/cortex:connect-telegram` (this installs NitroAgent as a background daemon that bridges Telegram to Claude Code).

If no → skip, they can always run `/cortex:connect-telegram` later.

### 9. Confirm
```
Cortex initialized at ~/.claude/cortex/

Created:
  memory/        — 6 memory files
  identity/      — SOUL.md + USER.md
  data/          — logs, reports, exports
  scripts/       — notify, system_status, awareness_scan, extract_transcripts, cron_runner

Your projects stay clean — all Cortex data lives in ~/.claude/cortex/

Next steps:
  1. Edit ~/.claude/cortex/identity/SOUL.md to customize personality
  2. Edit ~/.claude/cortex/identity/USER.md to tell your assistant about you
  3. Fill in ~/.claude/cortex/memory/context.md with current priorities
  4. Run /cortex:learn to absorb insights from existing Claude Code projects
  5. Run /cortex:connect-telegram to chat from your phone
  6. Run /cortex:status to verify everything works
```
