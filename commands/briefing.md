---
name: briefing
description: Generate a daily briefing — current context, priorities, pending items, and system health.
user-invocable: true
---

# Briefing

## When to Use
- When the user asks for a briefing, summary, or "what's going on"
- Can be called automatically via cron

## Data Location
All memory files at `~/.claude/cortex/memory/` (override with `CORTEX_HOME`).

## Steps

### 1. Gather Context
Read memory files:
- `~/.claude/cortex/memory/context.md` — active priorities
- `~/.claude/cortex/memory/strategy.md` — goals and opportunities
- `~/.claude/cortex/memory/watchlist.md` — monitored items
- `~/.claude/cortex/memory/conversations.md` (last 5 entries)

### 2. Check System Health
Run `~/.claude/cortex/scripts/system_status.sh`.
Check `~/.claude/cortex/data/logs/` for failed cron jobs.

### 3. Check Pending Items
From strategy.md: unchecked followups, approaching deadlines, stale opportunities.

### 4. Format Briefing
```
=== Daily Briefing ===

Priorities:
- [from context.md — top 3]

Pending Followups:
- [unchecked items from strategy.md]

System:
- Last session: Xh ago
- Cron: [X active, Y failures]

What should we work on?
```

### 5. Deliver
- **Interactive**: Present in conversation
- **Automated**: Send via `~/.claude/cortex/scripts/notify.sh`

## Guidelines
- Keep it concise (< 1500 chars for notifications)
- Skip empty sections
