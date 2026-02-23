# Changelog

## [2.0.0] - 2026-02-23

### Changed
- **Breaking**: All data now lives at `~/.claude/cortex/` instead of the user's project directory
- Scripts, memory, identity, logs — everything moved to `CORTEX_HOME` (`~/.claude/cortex/`)
- User projects are never modified by Cortex (zero pollution)
- Hook scripts use `CORTEX_HOME` for data, `CLAUDE_PLUGIN_ROOT` for plugin code
- Cron jobs write to `~/.claude/cortex/cron/` and `~/.claude/cortex/data/logs/`
- Stop hook prompt uses absolute paths to `~/.claude/cortex/memory/`
- SessionStart hook injects current project path for context awareness

## [1.1.0] - 2026-02-23

### Added
- `/cortex:learn` command — cross-project learning from Claude Code transcripts
- `scripts/extract_transcripts.py` — zero-LLM transcript extractor

### Changed
- Renamed from `personal-ai-os` to `cortex`
- All env vars: `PAIOS_*` → `CORTEX_*`
- All commands: `/personal-ai-os:*` → `/cortex:*`

## [1.0.0] - 2026-02-23

### Added
- Initial release with 5 commands, 3 hooks, memory system, notifications, cron
