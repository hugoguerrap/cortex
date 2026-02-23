---
name: learn
description: Scan Claude Code conversation transcripts from all projects and extract cross-project patterns into memory.
user-invocable: true
---

# Learn

## What This Does
Scans your Claude Code conversation history across ALL projects (`~/.claude/projects/`) and extracts:
- **Coding style** — languages, patterns, naming conventions you prefer
- **Decision patterns** — how you choose between options, what you value
- **Recurring problems** — bugs and issues that come up repeatedly
- **Tool preferences** — which tools you use most, which you avoid
- **Communication style** — how you give instructions, level of detail you expect
- **Technical stack** — frameworks, libraries, services you use across projects

This builds a cognitive profile stored in `~/.claude/cortex/memory/`.

## When to Use
- After initial `/cortex:setup` to bootstrap knowledge from existing projects
- Periodically (monthly) to absorb new patterns
- When switching to a new project and wanting cross-project context

## Steps

### 1. Extract Transcripts
Run the extraction script (zero LLM cost, pure Python):

```bash
python3 ~/.claude/cortex/scripts/extract_transcripts.py --days 60 --max-files 80
```

### 2. Analyze Patterns
With the extracted data, analyze for:

**User Preferences:** Language preference, instruction style, reaction patterns, preferred output format.

**Technical Profile:** Most-used languages/frameworks, common project types, debugging approach, architecture preferences.

**Working Patterns:** Session frequency/duration, time of day, project switching, feature vs bugfix ratio.

**Recurring Themes:** Cross-project problems, frequently-used tools, knowledge gaps.

### 3. Update Memory Files
Based on analysis, update files in `~/.claude/cortex/memory/`:

- `preferences.md` — Coding style, communication style, tool preferences
- `lessons.md` — Cross-project technical insights
- `context.md` — Active projects discovered from transcripts
- `strategy.md` — Patterns suggesting goals or opportunities

### 4. Generate Learning Report
Save to `~/.claude/cortex/data/reports/YYYY-MM-DD-learn.md`.

### 5. Present Summary
Show the user what was learned and updated. Ask for corrections.

## Options

| Flag | Description |
|------|-------------|
| `--days N` | Look back N days (default: 60) |
| `--project NAME` | Only scan a specific project |
| `--dry-run` | Analyze but don't update memory files |

## Guidelines
- The Python extractor is free; only Claude analysis costs tokens
- Don't overwrite manually-written preferences — merge
- Flag uncertain findings and let the user confirm
- Never include raw conversation content in reports, only patterns
