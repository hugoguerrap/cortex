# Personal AI OS

A self-building personal AI assistant for [Claude Code](https://claude.ai/claude-code). It starts as a scaffold and grows into a full operating system for your AI — with persistent memory, auto-evolution, and automation that creates itself.

**The key idea:** your AI doesn't just follow instructions — it builds its own tools. As you work together, it creates scripts, skills, and scheduled jobs that make future work faster. Every problem solved is a building block.

## What You Get

| Component | Description |
|-----------|-------------|
| **Persistent Memory** | 6 memory files (context, strategy, lessons, preferences, conversations, watchlist) that survive across sessions |
| **Auto-Evolution** | Hooks that evaluate every session and persist knowledge automatically |
| **Identity System** | Customizable AI personality (SOUL.md) and user profile (USER.md) |
| **5 Commands** | `/setup`, `/status`, `/evolve`, `/briefing`, `/create-skill` |
| **Notification System** | Pluggable alerts via Telegram, Discord, Slack, or desktop |
| **Cron Automation** | Scheduled briefings, awareness scans, and daily summaries |
| **Self-Building** | The AI creates new scripts and skills as it works with you |

## Quick Start

### Install

```bash
claude /install-plugin hugoguerrap/personal-ai-os
```

### Initialize

Open Claude Code in your project and run:

```
/personal-ai-os:setup
```

This creates your memory, identity, and data directories with starter templates.

### Personalize

1. Edit `identity/SOUL.md` — give your assistant a name and personality
2. Edit `identity/USER.md` — tell your assistant about yourself
3. Fill in `memory/context.md` — your current priorities

That's it. Your AI assistant will learn and evolve from here.

## How It Works

### Memory System

Your AI has persistent memory stored in 6 files:

| File | What It Stores | Limit |
|------|---------------|-------|
| `memory/context.md` | Active projects, priorities, blockers | 200 lines |
| `memory/strategy.md` | Goals, opportunities, contacts, metrics | No limit |
| `memory/lessons.md` | Technical insights and debugging patterns | Categorized |
| `memory/preferences.md` | Your observed work preferences | 100 lines |
| `memory/conversations.md` | Key session summaries | 30 days |
| `memory/watchlist.md` | Items being monitored | 50 items |

Memory is injected automatically at the start of every session via the SessionStart hook. At the end of each session, the Stop hook evaluates whether anything worth persisting was learned.

### Auto-Evolution

The system evolves in three ways:

1. **Automatic (hooks)** — Every session, the AI evaluates what was learned and updates memory
2. **On-demand (`/evolve`)** — Full audit of all memory files with cleanup and consolidation
3. **Organic (self-building)** — When the AI solves a problem, it asks itself: "Could this be needed again?" If yes, it saves the solution as a reusable script or skill

### Hooks

| Hook | Event | What It Does |
|------|-------|-------------|
| SessionStart | New session opens | Injects all memory files as context + analyzes session gap, cron health |
| Stop | Session about to end | Evaluates if knowledge should be persisted to memory |
| SessionEnd | Session closes | Logs session duration for analytics |

### Commands

| Command | Description |
|---------|-------------|
| `/personal-ai-os:setup` | Initialize directories and templates |
| `/personal-ai-os:status` | Health dashboard — memory freshness, cron health, system metrics |
| `/personal-ai-os:evolve` | Self-audit — review memory, propose updates, clean stale data |
| `/personal-ai-os:briefing` | Daily summary — priorities, pending items, system health |
| `/personal-ai-os:create-skill` | Create a new skill from scratch |

## Notifications

Configure notifications by setting an environment variable:

```bash
export PAIOS_NOTIFY_CHANNEL=telegram  # or: discord, slack, desktop, none
```

| Channel | Required Variables |
|---------|-------------------|
| Telegram | `PAIOS_TELEGRAM_TOKEN`, `PAIOS_TELEGRAM_CHAT_ID` |
| Discord | `PAIOS_DISCORD_WEBHOOK` |
| Slack | `PAIOS_SLACK_WEBHOOK` |
| Desktop | None (uses native OS notifications) |

## Cron Automation

Install scheduled jobs:

```bash
export CLAUDE_PROJECT_DIR="$(pwd)"
bash templates/cron/install_cron.sh
```

Default schedule:
- **7:00 AM** — Morning briefing (uses Claude, ~$0.01/run)
- **Every 15 min (8am-11pm)** — Awareness scan (zero LLM cost, pure Python)
- **10:00 PM** — Daily summary (uses Claude, ~$0.01/run)

## Project Structure

All user data lives in **your project**, not in the plugin:

```
your-project/
├── memory/              ← Persistent memory (6 files)
├── identity/            ← SOUL.md + USER.md
├── data/
│   ├── logs/            ← Session and cron logs
│   ├── reports/         ← Generated reports
│   └── exports/         ← Archived conversations
├── scripts/             ← Auto-created reusable scripts
├── cron/                ← Scheduled automation
└── .claude/skills/      ← Auto-created skills
```

The plugin provides the framework; your project stores the data.

## Philosophy

1. **Self-building** — The AI creates its own tools as it works with you
2. **Bash first, Claude second** — Mechanical tasks run as scripts (zero LLM cost). Claude is invoked only when thinking is needed
3. **Memory is selective** — Not everything is worth remembering. Only durable, reusable knowledge gets persisted
4. **Simplest approach that works** — No premature abstractions, no over-engineering
5. **The user is in control** — Destructive actions always require confirmation. The AI has opinions but respects yours

## Inspired By

This plugin is a genericized version of [Senku](https://x.com/hugoguerrap), a personal AI assistant built on Claude Code that manages projects, monitors markets, sends notifications, and evolves itself — all from a single project directory.

## License

MIT
