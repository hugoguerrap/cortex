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

This builds a cognitive profile that makes the assistant smarter — not just within this project, but informed by everything you've ever worked on with Claude Code.

## When to Use
- After initial `/cortex:setup` to bootstrap knowledge from existing projects
- Periodically (monthly) to absorb new patterns
- When switching to a new project and wanting cross-project context

## Steps

### 1. Extract Transcripts
Run the extraction script (zero LLM cost, pure Python):

```bash
python3 scripts/extract_transcripts.py --days 60 --max-files 80
```

This outputs JSON with:
- List of projects found
- Sample user messages from each project
- Tool usage statistics
- Representative messages across all projects

### 2. Analyze Patterns
With the extracted data, analyze for:

**User Preferences:**
- Language preference (English/Spanish/mixed?)
- Instruction style (terse commands vs detailed specs?)
- Reaction patterns (what triggers frustration vs satisfaction?)
- Preferred output format (code-first? explanations? bullets?)

**Technical Profile:**
- Most-used languages and frameworks
- Common project types (web apps, CLI tools, automation, games?)
- Debugging approach (logs? breakpoints? print statements?)
- Architecture preferences (monolith? microservices? scripts?)

**Working Patterns:**
- Session frequency and duration
- Time of day patterns
- Project switching frequency
- Ratio of new features vs bugfixes vs exploration

**Recurring Themes:**
- Problems that appear across multiple projects
- Tools or techniques the user keeps reaching for
- Knowledge gaps that cause repeated questions

### 3. Update Memory Files
Based on the analysis, update the appropriate memory files:

- **`memory/preferences.md`** — Coding style, communication style, tool preferences
- **`memory/lessons.md`** — Cross-project technical insights
- **`memory/context.md`** — Active projects discovered from transcripts
- **`memory/strategy.md`** — Patterns that suggest goals or opportunities

### 4. Generate Learning Report
Save a report to `data/reports/YYYY-MM-DD-learn.md`:

```markdown
# Cortex Learning Report — YYYY-MM-DD

## Scan Summary
- Projects scanned: N
- Transcripts analyzed: N
- Date range: [oldest] to [newest]

## Cognitive Profile

### Communication Style
- [findings]

### Technical Stack
- [languages, frameworks, tools]

### Working Patterns
- [session patterns, project types]

### Preferences Discovered
- [new preferences extracted]

### Cross-Project Insights
- [patterns that apply everywhere]

## Memory Updates Made
- preferences.md: [what was added/updated]
- lessons.md: [what was added]
- context.md: [what was updated]
```

### 5. Present Summary
Show the user a concise summary of what was learned and what was updated. Ask if any corrections are needed.

## Options

| Flag | Description |
|------|-------------|
| `--days N` | Look back N days (default: 60) |
| `--project NAME` | Only scan a specific project |
| `--dry-run` | Analyze but don't update memory files |

## Guidelines
- First run may take a moment — there could be hundreds of transcript files
- The extraction script (Python) is free; only the Claude analysis costs tokens
- Don't overwrite manually-written preferences — merge new findings
- Flag uncertain findings with "?" and let the user confirm
- Respect privacy: never include raw conversation content in reports, only patterns
