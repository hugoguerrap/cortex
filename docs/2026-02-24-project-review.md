# Cortex — Project Status Review

**Date:** 2026-02-24
**Version:** 2.1.0
**Reviewer:** Claude (automated)

## Overview

Cortex is a Claude Code plugin that provides persistent memory, cross-project learning, auto-evolution, and remote access via Telegram. All user data lives at `~/.claude/cortex/`, keeping projects clean.

## Strengths

### 1. Differentiated concept
The "AI that builds itself" approach — creating scripts, skills, and cron jobs as it works — is genuinely novel compared to existing memory plugins (`claude-mem`, `supermemory`).

### 2. Clean architecture
Clear separation between plugin code (`CLAUDE_PLUGIN_ROOT`) and user data (`CORTEX_HOME`). Zero project pollution.

### 3. Well-designed hook lifecycle
`SessionStart → Stop → SessionEnd` covers the full session cycle. The Stop hook's selective evaluation prompt avoids blindly persisting everything.

### 4. Functional utility scripts
- `notify.sh`: Handles 4 channels with chunking for long messages and Markdown→plaintext fallback
- `awareness_scan.py`: Zero LLM cost, sensible rate limiting (5 alerts/day)
- `extract_transcripts.py`: Clean JSONL parser with noise filtering

### 5. Thorough command documentation
Each command `.md` is a step-by-step runbook. `connect-telegram.md` includes a troubleshooting table.

## Risks and Gaps

### 1. No tests
Zero unit, integration, or end-to-end tests. Key risks:
- `session_start.sh` fails silently without `jq` (fallback `echo -e` doesn't produce valid hook JSON)
- `extract_transcripts.py` assumes a specific JSONL format that could change
- `notify.sh` has no retry logic for network failures

### 2. Memory integrity
- Stop hook relies on model interpretation of a prompt to write structured memory — no validation or schema
- No versioning of memory files (no git in `CORTEX_HOME`)
- Corruption has no rollback mechanism

### 3. Platform assumptions
`connect-telegram.md` assumes macOS (`xcode-select`, `osascript`, `brew`, macOS daemon). No Linux path exists.

### 4. README vs reality
Claims like "self-installing integrations" and "builds its own tools" are CLAUDE.md instructions depending on emergent model behavior, not deterministic functionality.

### 5. No CI/CD
No GitHub Actions, shellcheck, mypy, or ruff. For a plugin running hooks on every Claude Code session, reliability should be verified automatically.

## Metrics

| Metric | Value |
|--------|-------|
| Source files | ~20 |
| Languages | Bash, Python, Markdown, JSON |
| Tests | 0 |
| CI/CD | None |
| Commits | 10 |
| Contributors | 1 |
| Age | 1 day (all commits on 2026-02-23) |
| License | MIT |

## Recommended Priorities

1. **Tests** for `session_start.sh`, `notify.sh`, and `extract_transcripts.py`
2. **Git init in `CORTEX_HOME`** to version memory files with auto-commits
3. **Validation/schema** for Stop hook memory writes
4. **CI pipeline** with shellcheck + ruff
5. **Linux support** in Telegram setup flow
