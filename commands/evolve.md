---
name: evolve
description: Self-audit and evolution — reviews all memory files, proposes updates, identifies stale data, suggests new scripts/skills.
user-invocable: true
---

# Evolve

## When to Use
- Periodically (weekly recommended) to keep the system fresh
- After a series of productive sessions
- When the assistant feels "out of sync" with current priorities

## Data Location
All memory files are at `~/.claude/cortex/memory/` (override with `CORTEX_HOME` env var).

## Process

### 1. Audit Memory Files
Read and evaluate each file in `~/.claude/cortex/memory/`:

| File | Check | Limit |
|------|-------|-------|
| `context.md` | Are priorities current? Completed items still listed? | < 200 lines |
| `preferences.md` | Contradictions? Missing observed preferences? | < 100 lines |
| `watchlist.md` | Items user stopped caring about? | < 50 items |
| `lessons.md` | Duplicates? Items to consolidate? | Categorized |
| `conversations.md` | Entries older than 30 days? Archive to `data/exports/` | Last 30 days |
| `strategy.md` | Goals still active? Metrics up to date? | Current |

### 2. Review Session Logs
Read `~/.claude/cortex/data/logs/sessions.log`:
- Session frequency and duration
- Usage patterns

### 3. Check Recent Work
Look for recently modified files in `~/.claude/cortex/scripts/`:
- Ad-hoc scripts that should be kept
- Patterns worth automating

### 4. Present Evolution Report
```markdown
## Evolution Report — YYYY-MM-DD

### Memory Audit
- context.md: [current/stale] — [proposed changes]
- preferences.md: [current/stale] — [proposed changes]
- (etc.)

### Proposed Updates
1. [change] — [file]

### Stale Items to Remove
- [item] from [file]
```

### 5. Execute Changes (with approval)
After user approves, update files in `~/.claude/cortex/memory/`.

### 6. Log Evolution
Append to `~/.claude/cortex/memory/conversations.md`:
```
## YYYY-MM-DD - Self-Evolution
- [summary of changes made]
```

## Guidelines
- Never delete information without user approval
- Consolidate rather than remove
- Keep the report concise
