---
name: memory-ops
description: Auto-invoked skill for persistent memory operations — read, write, consolidate, and archive memory files.
user-invocable: false
---

# Memory Operations

## When to Use
This skill is auto-invoked by the assistant when it needs to interact with the memory system. It provides structured operations for memory management.

## Operations

### Read Context
Load all memory files at session start to build situational awareness:
1. Read `memory/context.md` — current priorities
2. Read `memory/strategy.md` — goals and opportunities
3. Read `memory/lessons.md` (last 30 lines) — recent insights
4. Read `memory/conversations.md` (last 20 lines) — recent sessions
5. Read `memory/preferences.md` — user preferences
6. Read `memory/watchlist.md` — monitored items

### Write Memory
When persisting new knowledge:
1. Determine the correct file based on content type:
   - Project status → `context.md`
   - Goals/opportunities/contacts → `strategy.md`
   - Technical insight → `lessons.md`
   - User preference → `preferences.md`
   - Session summary → `conversations.md`
   - Monitored item → `watchlist.md`
2. Read the current file content
3. Add the new entry in the appropriate section
4. Verify file stays within its line limit

### Consolidate
Periodically merge and deduplicate entries:
1. Check line counts against limits
2. Merge similar lessons
3. Remove outdated context entries
4. Archive old conversations to `data/exports/`

### Archive
Move old conversation entries to exports:
1. Identify entries older than 30 days in `conversations.md`
2. Create `data/exports/conversations-YYYY-MM.md`
3. Move old entries to the archive file
4. Update `conversations.md`

## Memory File Limits

| File | Max Lines | Action When Exceeded |
|------|-----------|---------------------|
| context.md | 200 | Remove completed/stale items |
| preferences.md | 100 | Consolidate similar entries |
| watchlist.md | 50 items | Remove items user stopped tracking |
| lessons.md | No hard limit | Categorize and consolidate |
| conversations.md | 30 days | Archive to data/exports/ |
| strategy.md | No hard limit | Review for staleness |

## Format Conventions
- Dates: `YYYY-MM-DD`
- Lessons: `- YYYY-MM-DD: Description`
- Conversations: `## YYYY-MM-DD - Topic`
- Watchlist: `SYMBOL | alert_above | alert_below`
