---
name: setup
description: Initialize Cortex in the current project — creates memory, identity, and data directories with starter templates.
user-invocable: true
---

# Setup

## When to Use
- First time using Cortex in a project
- To re-initialize missing directories (idempotent — won't overwrite existing files)

## Steps

### 1. Create Directory Structure
Create the required directories in the user's project:
```bash
mkdir -p memory identity data/logs data/reports data/exports scripts
```

### 2. Copy Memory Templates
For each template, copy from the plugin to the user's project **only if it doesn't already exist**.

The plugin templates are at `${CLAUDE_PLUGIN_ROOT}/templates/`. Read each template file and write it to the user's project:

Memory files to create in `memory/`:
- `context.md` — from `${CLAUDE_PLUGIN_ROOT}/templates/memory/context.md`
- `strategy.md` — from `${CLAUDE_PLUGIN_ROOT}/templates/memory/strategy.md`
- `lessons.md` — from `${CLAUDE_PLUGIN_ROOT}/templates/memory/lessons.md`
- `preferences.md` — from `${CLAUDE_PLUGIN_ROOT}/templates/memory/preferences.md`
- `conversations.md` — from `${CLAUDE_PLUGIN_ROOT}/templates/memory/conversations.md`
- `watchlist.md` — from `${CLAUDE_PLUGIN_ROOT}/templates/memory/watchlist.md`

### 3. Copy Identity Templates
Identity files to create in `identity/`:
- `SOUL.md` — from `${CLAUDE_PLUGIN_ROOT}/templates/identity/SOUL.md`
- `USER.md` — from `${CLAUDE_PLUGIN_ROOT}/templates/identity/USER.md`

### 4. Copy Utility Scripts
Copy reusable scripts from the plugin to the user's project:
- `scripts/notify.sh` — from `${CLAUDE_PLUGIN_ROOT}/scripts/notify.sh`
- `scripts/system_status.sh` — from `${CLAUDE_PLUGIN_ROOT}/scripts/system_status.sh`
- `scripts/cron_runner.sh` — from `${CLAUDE_PLUGIN_ROOT}/scripts/cron_runner.sh`
- `scripts/awareness_scan.py` — from `${CLAUDE_PLUGIN_ROOT}/scripts/awareness_scan.py`
- `scripts/extract_transcripts.py` — from `${CLAUDE_PLUGIN_ROOT}/scripts/extract_transcripts.py`

Make all scripts executable: `chmod +x scripts/*.sh scripts/*.py`

### 5. Ask the User
Prompt for basic personalization:
- **Assistant name**: What should your AI assistant be called? (default: "Assistant")
- **User name**: Your name
- **Notification channel**: How should the AI notify you? Options: `telegram`, `discord`, `slack`, `desktop`, `none`

### 6. Apply Personalization
Replace `{{ASSISTANT_NAME}}` in `identity/SOUL.md` with the chosen name.
Replace `{{USER_NAME}}` in `identity/USER.md` with the user's name.

### 7. Configure Notifications (if not `none`)
Based on the chosen channel, tell the user which env vars to set:

| Channel | Required Env Vars |
|---------|------------------|
| telegram | `CORTEX_TELEGRAM_TOKEN`, `CORTEX_TELEGRAM_CHAT_ID` |
| discord | `CORTEX_DISCORD_WEBHOOK` |
| slack | `CORTEX_SLACK_WEBHOOK` |
| desktop | _none_ (uses native notifications) |

### 8. Create .gitignore entries
Append to the project's `.gitignore` if not already present:
```
data/logs/
data/exports/
*.pid
```

### 9. Confirm
Print a summary:
```
Cortex initialized!

Created:
  memory/        — 6 memory files (context, strategy, lessons, preferences, conversations, watchlist)
  identity/      — SOUL.md (assistant personality) + USER.md (your profile)
  data/logs/     — Session and cron logs
  data/reports/  — Generated reports
  data/exports/  — Archived conversations
  scripts/       — Utility scripts (notify, system_status, cron_runner, awareness_scan, extract_transcripts)

Next steps:
  1. Edit identity/SOUL.md to customize your assistant's personality
  2. Edit identity/USER.md to tell your assistant about yourself
  3. Fill in memory/context.md with your current priorities
  4. Run /cortex:learn to absorb insights from your existing Claude Code projects
  5. Run /cortex:status to verify everything works

Your AI assistant will learn and evolve from here.
```
