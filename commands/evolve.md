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

## Process

### 1. Audit Memory Files
Read and evaluate each memory file:

| File | Check | Limit |
|------|-------|-------|
| `memory/context.md` | Are priorities current? Completed items still listed? | < 200 lines |
| `memory/preferences.md` | Contradictions? Missing observed preferences? | < 100 lines |
| `memory/watchlist.md` | Items user stopped caring about? | < 50 items |
| `memory/lessons.md` | Duplicates? Items to consolidate? | Categorized |
| `memory/conversations.md` | Entries older than 30 days? Archive to `data/exports/` | Last 30 days |
| `memory/strategy.md` | Goals still active? Metrics up to date? | Current |

For each file, check:
- Last modified date
- Line count vs limit
- Stale or outdated entries

### 2. Review Session Logs
Read `data/logs/sessions.log`:
- How often the user opens sessions
- Average session duration
- Usage patterns (time of day, frequency)

### 3. Check Recent Work
Look for recently modified files across the project:
- Ad-hoc scripts that should be saved permanently to `scripts/`
- Patterns that should become skills
- Recurring solutions worth automating

### 4. Present Evolution Report
```markdown
## Evolution Report — YYYY-MM-DD

### Memory Audit
- context.md: [current/stale] — [proposed changes]
- preferences.md: [current/stale] — [proposed changes]
- watchlist.md: [current/stale] — [proposed changes]
- lessons.md: [entries count] — [consolidation needed?]
- conversations.md: [entries to archive]
- strategy.md: [goals still active?]

### Proposed Updates
1. [change] — [file]
2. [change] — [file]

### New Scripts/Skills Candidates
- [description] — based on [pattern observed]

### Identity Review
- [any updates to SOUL.md or USER.md]

### Stale Items to Remove
- [item] from [file]
```

### 5. Execute Changes (with approval)
After the user approves:
- Update memory files
- Create new scripts with `chmod +x`
- Create new skills if warranted
- Archive old conversations to `data/exports/`
- Log evolution to `memory/conversations.md`

### 6. Log Evolution
Append to `memory/conversations.md`:
```
## YYYY-MM-DD - Self-Evolution
- [summary of changes made]
```

## Guidelines
- Never delete information without user approval
- Consolidate rather than remove
- Keep the report concise — action over analysis
- Suggest changes, don't assume (unless told "just do it")
