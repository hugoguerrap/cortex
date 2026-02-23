---
name: status
description: Health dashboard — shows memory freshness, cron health, session stats, and system metrics.
user-invocable: true
---

# Status

## When to Use
- To check if everything is working correctly
- After setup to verify initialization
- When something feels "off" and you want a quick diagnostic

## Data Location
All Cortex data is at `~/.claude/cortex/` (override with `CORTEX_HOME` env var).

## Steps

### 1. Check Directory Structure
Verify `~/.claude/cortex/` exists with:
- `memory/` (6 files expected)
- `identity/` (2 files expected)
- `data/logs/`
- `scripts/`

Report any missing directories or files.

### 2. Memory Freshness
For each memory file in `~/.claude/cortex/memory/`, check:
- Last modified date
- Line count
- Flag files not updated in > 7 days as "stale"

### 3. Session Stats
Read `~/.claude/cortex/data/logs/sessions.log` if it exists:
- Total sessions logged
- Last session date
- Average session duration

### 4. Cron Health
Check `~/.claude/cortex/data/logs/` for cron task logs:
- Any `*_*.log` files
- Check last entries for exit codes
- Flag failures in the last 24h

### 5. System Metrics
Run `~/.claude/cortex/scripts/system_status.sh` if it exists.

### 6. Present Dashboard
```
=== Cortex Status ===

Location: ~/.claude/cortex/

Memory Files:
  context.md       ✓ 45 lines    (updated 2h ago)
  strategy.md      ✓ 120 lines   (updated 1d ago)
  lessons.md       ✓ 30 lines    (updated 3d ago)
  preferences.md   ✓ 15 lines    (updated 5d ago)
  conversations.md ✓ 80 lines    (updated 1d ago)
  watchlist.md     ⚠ 0 lines     (stale — 14d ago)

Identity:
  SOUL.md          ✓ configured
  USER.md          ✓ configured

Sessions:
  Total: 47 | Last: 2h ago | Avg duration: 25m

Cron:
  Active jobs: 3 | Failures (24h): 0

System:
  Disk: 45% | Memory: 6.2/16 GB
```
