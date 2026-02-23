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
Run the init script:
```bash
bash "$CLAUDE_PROJECT_DIR/scripts/init_data_dirs.sh"
```

### 2. Copy Memory Templates
For each template file in `templates/memory/`, copy it to `memory/` **only if it doesn't already exist**:

```bash
PLUGIN_DIR="<path to cortex plugin>"
for template in context.md strategy.md lessons.md preferences.md conversations.md watchlist.md; do
    if [ ! -f "memory/$template" ]; then
        cp "$PLUGIN_DIR/templates/memory/$template" "memory/$template"
    fi
done
```

### 3. Copy Identity Templates
Same for identity files:
```bash
for template in SOUL.md USER.md; do
    if [ ! -f "identity/$template" ]; then
        cp "$PLUGIN_DIR/templates/identity/$template" "identity/$template"
    fi
done
```

### 4. Ask the User
Prompt for basic personalization:
- **Assistant name**: What should your AI assistant be called? (default: "Assistant")
- **User name**: Your name
- **Notification channel**: How should the AI notify you? Options: `telegram`, `discord`, `slack`, `desktop`, `none`

### 5. Apply Personalization
Replace `{{ASSISTANT_NAME}}` in `identity/SOUL.md` with the chosen name.
Replace `{{USER_NAME}}` in `identity/USER.md` with the user's name.

### 6. Configure Notifications (if not `none`)
Based on the chosen channel, tell the user which env vars to set:

| Channel | Required Env Vars |
|---------|------------------|
| telegram | `CORTEX_TELEGRAM_TOKEN`, `CORTEX_TELEGRAM_CHAT_ID` |
| discord | `CORTEX_DISCORD_WEBHOOK` |
| slack | `CORTEX_SLACK_WEBHOOK` |
| desktop | _none_ (uses native notifications) |

### 7. Create .gitignore entries
Append to the project's `.gitignore` if not already present:
```
data/logs/
data/exports/
*.pid
```

### 8. Confirm
Print a summary:
```
Cortex initialized!

Created:
  memory/        — 6 memory files (context, strategy, lessons, preferences, conversations, watchlist)
  identity/      — SOUL.md (assistant personality) + USER.md (your profile)
  data/logs/     — Session and cron logs
  data/reports/  — Generated reports
  data/exports/  — Archived conversations

Next steps:
  1. Edit identity/SOUL.md to customize your assistant's personality
  2. Edit identity/USER.md to tell your assistant about yourself
  3. Fill in memory/context.md with your current priorities
  4. Run /cortex:learn to absorb insights from your existing Claude Code projects
  5. Run /cortex:status to verify everything works

Your AI assistant will learn and evolve from here.
```
