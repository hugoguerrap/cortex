---
name: memory-ops
description: Auto-invoked skill for persistent memory operations — read, write, consolidate, and archive memory files at ~/.claude/cortex/.
user-invocable: false
---

# Memory Operations

## Data Location
All memory files at `~/.claude/cortex/memory/`. Override with `CORTEX_HOME` env var.

## Operations

### Read Context
Load all memory files to build situational awareness:
1. `~/.claude/cortex/memory/context.md` — current priorities
2. `~/.claude/cortex/memory/strategy.md` — goals and opportunities
3. `~/.claude/cortex/memory/lessons.md` (last 30 lines) — recent insights
4. `~/.claude/cortex/memory/conversations.md` (last 20 lines) — recent sessions
5. `~/.claude/cortex/memory/preferences.md` — user preferences
6. `~/.claude/cortex/memory/watchlist.md` — monitored items

### Write Memory
1. Determine the correct file based on content type
2. Read current content
3. Add new entry in the appropriate section
4. Verify file stays within limits

### Consolidate
Periodically merge and deduplicate entries.

### Archive
Move old conversation entries (> 30 days) to `~/.claude/cortex/data/exports/conversations-YYYY-MM.md`.

## Memory File Limits

| File | Max | Action When Exceeded |
|------|-----|---------------------|
| context.md | 200 lines | Remove completed/stale items |
| preferences.md | 100 lines | Consolidate similar entries |
| watchlist.md | 50 items | Remove items no longer tracked |
| lessons.md | No limit | Categorize and consolidate |
| conversations.md | 30 days | Archive to data/exports/ |
| strategy.md | No limit | Review for staleness |
