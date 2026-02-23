---
name: briefing
description: Generate a daily briefing — current context, priorities, pending items, and system health.
user-invocable: true
---

# Briefing

## When to Use
- When the user asks for a briefing, summary, or "what's going on"
- Can be called automatically via cron

## Steps

### 1. Gather Context
Read memory files for current state:
- `memory/context.md` — active priorities
- `memory/strategy.md` — goals and opportunities
- `memory/watchlist.md` — monitored items
- `memory/conversations.md` (last 5 entries) — recent sessions

### 2. Check System Health
Run `scripts/system_status.sh` for system metrics.

Check `data/logs/sessions.log` for:
- Last session timestamp
- Recent session frequency

Check `data/logs/` for any failed cron jobs in the last 24h.

### 3. Check Pending Items
From `memory/strategy.md`:
- Unchecked followup items (`- [ ]`)
- Goals with approaching deadlines
- Stale opportunities (not updated in > 7 days)

### 4. Format Briefing
Compose a concise summary:

```
=== Daily Briefing ===

Priorities:
- [from context.md — top 3]

Pending Followups:
- [unchecked items from strategy.md]

System:
- Last session: Xh ago
- Cron: [X active, Y failures]
- Disk: X% | Memory: X GB

Stale Items:
- [anything not updated in > 7 days that should be]

What should we work on?
```

### 5. Deliver
- **Interactive mode**: Present in the conversation
- **Automated mode**: Send via `scripts/notify.sh`

## Guidelines
- Keep it concise — target < 1500 chars for notifications
- Only include sections with actionable information
- Skip empty sections entirely
- If nothing needs attention, say so briefly
