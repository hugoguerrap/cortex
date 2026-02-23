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

## Steps

### 1. Check Directory Structure
Verify these directories exist:
- `memory/` (6 files expected)
- `identity/` (2 files expected)
- `data/logs/`
- `data/reports/`

Report any missing directories or files.

### 2. Memory Freshness
For each memory file, check:
- Last modified date (via `ls -la memory/`)
- Line count
- Flag files that haven't been updated in > 7 days as "stale"

### 3. Session Stats
Read `data/logs/sessions.log` if it exists:
- Total sessions logged
- Last session date
- Average session duration (from entries with duration)

### 4. Cron Health
Check `data/logs/` for cron task logs:
- Any files matching `*_*.log` pattern
- Check last entries for exit codes
- Flag any failures in the last 24h

### 5. System Metrics
Run `scripts/system_status.sh` if it exists:
- Disk usage
- Memory usage
- Docker containers (if applicable)

### 6. Present Dashboard
Format as a clean dashboard:

```
=== Personal AI OS Status ===

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

Scripts: 5 in scripts/
Skills: 2 in .claude/skills/
```
