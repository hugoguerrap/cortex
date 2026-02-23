# Changelog

## [1.0.0] - 2026-02-23

### Added
- Initial release
- 5 commands: setup, status, evolve, briefing, create-skill
- 3 hooks: SessionStart (context injection), Stop (memory evaluation), SessionEnd (session logging)
- Memory system with 6 file types: context, strategy, lessons, preferences, conversations, watchlist
- Identity templates: SOUL.md (assistant personality) + USER.md (user profile)
- Pluggable notification script supporting Telegram, Discord, Slack, and desktop
- Cron system with PID locking, log rotation, and failure alerts
- Awareness scanner (zero LLM cost) for cron health, memory freshness, and followup tracking
- Memory manager agent for consolidation and archival
- Auto-evolution philosophy: the AI creates scripts, skills, and cron jobs as it works with you
