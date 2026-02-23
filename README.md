# Cortex

A self-building AI cortex for [Claude Code](https://claude.ai/claude-code). Persistent memory, cross-project learning, auto-evolution, and automation that creates itself — without touching your projects.

**The key idea:** your AI doesn't just follow instructions — it builds its own tools. As you work together, it creates scripts, skills, and scheduled jobs that make future work faster.

**The killer feature:** `/cortex:learn` scans your conversation history across ALL your Claude Code projects and builds a cognitive profile — your coding style, decision patterns, recurring problems, technical preferences.

## What You Get

| Component | Description |
|-----------|-------------|
| **Persistent Memory** | 6 memory files that survive across sessions and projects |
| **Cross-Project Learning** | Scans all Claude Code transcripts and extracts patterns |
| **Auto-Evolution** | Hooks that evaluate every session and persist knowledge |
| **Identity System** | Customizable AI personality + user profile |
| **Telegram Access** | Chat with your agent from your phone via NitroAgent |
| **7 Commands** | `/setup`, `/status`, `/evolve`, `/briefing`, `/create-skill`, `/learn`, `/connect-telegram` |
| **Notifications** | Telegram, Discord, Slack, or desktop |
| **Cron Automation** | Scheduled briefings, awareness scans, summaries |
| **Zero Project Pollution** | All data at `~/.claude/cortex/`, your repos stay clean |

## Quick Start

### Install

```bash
claude plugin install cortex
```

### Initialize

```
/cortex:setup
```

Creates `~/.claude/cortex/` with memory, identity, and data directories.

### Learn From Your History

```
/cortex:learn
```

Scans all existing Claude Code conversations and builds a cognitive profile.

### Personalize

1. Edit `~/.claude/cortex/identity/SOUL.md` — assistant personality
2. Edit `~/.claude/cortex/identity/USER.md` — your profile
3. Fill in `~/.claude/cortex/memory/context.md` — current priorities

## How It Works

### Memory System

6 persistent files at `~/.claude/cortex/memory/`:

| File | What It Stores | Limit |
|------|---------------|-------|
| `context.md` | Active projects, priorities | 200 lines |
| `strategy.md` | Goals, opportunities, contacts | No limit |
| `lessons.md` | Technical insights, debugging patterns | Categorized |
| `preferences.md` | Your work preferences | 100 lines |
| `conversations.md` | Key session summaries | 30 days |
| `watchlist.md` | Monitored items | 50 items |

Memory is injected at session start and evaluated at session end — automatically.

### Cross-Project Learning

`/cortex:learn` works in two phases:

1. **Extraction** (zero LLM cost) — Python script scans `~/.claude/projects/` for transcripts
2. **Analysis** (uses Claude) — Patterns are extracted and merged into memory

### Auto-Evolution

1. **Hooks** — Every session: inject memory, evaluate what was learned, log duration
2. **`/cortex:evolve`** — Full audit: clean stale data, consolidate, archive
3. **Self-building** — When solving a problem: "Could this be needed again?" → save it

### Commands

| Command | Description |
|---------|-------------|
| `/cortex:setup` | Initialize `~/.claude/cortex/` |
| `/cortex:status` | Health dashboard |
| `/cortex:evolve` | Self-audit and memory cleanup |
| `/cortex:briefing` | Daily summary |
| `/cortex:create-skill` | Create a new skill |
| `/cortex:learn` | Scan all project transcripts for patterns |
| `/cortex:connect-telegram` | Chat with your agent from Telegram |

## Telegram Access

Talk to your Cortex agent from your phone. Powered by [NitroAgent](https://github.com/octaviusp/NitroAgent) — an open source Telegram-to-Claude Code bridge.

```
/cortex:connect-telegram
```

Or during `/cortex:setup`, answer "yes" when asked about Telegram.

This installs NitroAgent as a background service on your Mac. Once running, you can:
- Send text, voice, or photos from Telegram
- Get streaming responses with live progress
- Resume previous conversations
- Switch between safe and full tool modes

Requires: macOS, Rust toolchain, a Telegram bot token from [@BotFather](https://t.me/BotFather).

## Notifications

```bash
export CORTEX_NOTIFY_CHANNEL=telegram  # or: discord, slack, desktop, none
```

| Channel | Required Variables |
|---------|-------------------|
| Telegram | `CORTEX_TELEGRAM_TOKEN`, `CORTEX_TELEGRAM_CHAT_ID` |
| Discord | `CORTEX_DISCORD_WEBHOOK` |
| Slack | `CORTEX_SLACK_WEBHOOK` |
| Desktop | None |

## Cron Automation

After setup, run `/cortex:setup` which offers to install cron jobs automatically. Or install manually:

```
/cortex:briefing
``` Default schedule:
- **7:00 AM** — Morning briefing (~$0.01)
- **Every 15 min** — Awareness scan (zero LLM cost)
- **10:00 PM** — Daily summary (~$0.01)

## Where Data Lives

```
~/.claude/cortex/           ← All Cortex data (NOT in your project)
├── memory/                 ← 6 persistent memory files
├── identity/               ← SOUL.md + USER.md
├── data/
│   ├── logs/               ← Session and cron logs
│   ├── reports/            ← Generated reports
│   └── exports/            ← Archived conversations
├── scripts/                ← Utility scripts (auto-created too)
├── cron/                   ← Scheduled jobs (created by install_cron.sh)
└── nitro-agent/            ← Telegram bridge (created by /cortex:connect-telegram)
```

Your projects stay completely clean. No `memory/` directories. No `identity/` folders. No data files.

## Philosophy

1. **Self-building** — The AI creates its own tools as it works with you
2. **Cross-project intelligence** — Learns from all your Claude Code projects
3. **Zero pollution** — Your repos stay clean; all data at `~/.claude/cortex/`
4. **Bash first, Claude second** — Scripts for mechanical tasks, Claude for thinking
5. **Memory is selective** — Only durable, reusable knowledge gets persisted
6. **User is in control** — Destructive actions always require confirmation

## License

MIT
