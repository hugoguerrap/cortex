# Cortex

**Your AI that builds itself.**

A Claude Code plugin that turns your assistant into a persistent, cross-project intelligence that learns your patterns, remembers everything, and grows its own tools — then lets you talk to it from Telegram while you're on the bus.

```bash
claude plugin install cortex
```

```
/cortex:setup
```

That's it. Two commands. You now have a personal AI with memory, identity, and self-evolution.

---

## Why Cortex?

Most memory plugins record what happened. Cortex learns **how you think**.

| | claude-mem | supermemory | Cortex |
|---|---|---|---|
| Session memory | Captures tool observations | Stores conversation turns | Evaluates what's **worth** remembering |
| Cross-project | No | User profile via cloud API | Scans ALL local transcripts, zero cloud |
| Storage | SQLite + Chroma (embeddings) | Cloud API (supermemory.ai) | Plain markdown files you can read and edit |
| Auto-evolution | No | No | Creates its own scripts, skills, and cron jobs |
| Identity | No | No | Customizable personality + user profile |
| Self-audit | No | No | `/evolve` — cleans stale data, consolidates, archives |
| Telegram access | No | No | Chat from your phone via NitroAgent |
| Cron automation | No | No | Scheduled briefings, scans, summaries |
| Cloud dependency | No | Yes (supermemory.ai API) | No — 100% local |
| Project pollution | Writes to project | Writes to project | **Zero** — all data at `~/.claude/cortex/` |

**The fundamental difference:** other plugins add memory to Claude Code. Cortex adds **agency**. Your assistant doesn't just remember — it thinks about what to remember, builds tools when it spots patterns, and audits its own knowledge for staleness.

---

## What Happens When You Install It

### Day 1
You run `/cortex:setup`. It asks your name, what to call the assistant, and if you want Telegram access. Everything gets created at `~/.claude/cortex/`. Your projects stay untouched.

### Week 1
Every session, the Stop hook evaluates the conversation: "Did I learn something reusable?" Technical insights go to `lessons.md`. Your preferences go to `preferences.md`. Project context goes to `context.md`. You don't do anything — it happens automatically.

### Week 2
You run `/cortex:learn`. It scans every Claude Code conversation you've ever had, across all projects. It builds a cognitive profile: your coding style, debugging patterns, technology preferences, recurring problems. Knowledge that was trapped in individual sessions is now available everywhere.

### Month 1
Your assistant knows your stack, your patterns, your priorities. When you open a new project, it already understands how you work. When you hit a bug similar to one you solved 3 weeks ago, the lesson is right there in context. When you solve something novel, it saves the script for next time.

### From Telegram
You're on the bus. You open Telegram, message your bot: "what's the status of the API migration?" Your assistant — running on your Mac at home — checks the codebase and streams back the answer in real time. You reply: "deploy it." It does.

---

## The Full Picture

```
/cortex:setup              → Memory, identity, scripts — ready in 60 seconds
/cortex:connect-telegram   → Guided setup: bot creation, install, running in 5 min
/cortex:learn              → Scan ALL Claude Code history → cognitive profile
/cortex:evolve             → Self-audit: clean, consolidate, archive
/cortex:status             → Health dashboard
/cortex:briefing           → Daily summary
/cortex:create-skill       → Create new capabilities on the fly
```

### Memory System

6 persistent files at `~/.claude/cortex/memory/` — plain markdown, human-readable, git-friendly:

| File | Purpose | Limit |
|------|---------|-------|
| `context.md` | Active projects, priorities | 200 lines |
| `strategy.md` | Goals, opportunities, contacts | No limit |
| `lessons.md` | Technical insights, debugging patterns | Categorized |
| `preferences.md` | Learned work preferences | 100 lines |
| `conversations.md` | Key session summaries | 30 days |
| `watchlist.md` | Monitored items | 50 items |

Memory is **injected at session start** and **evaluated at session end** — automatically, via hooks.

### Identity System

Two files that define who your assistant is:

- `SOUL.md` — Personality, communication style, decision-making approach
- `USER.md` — Who you are, how you work, what you value

These aren't decorative. They're injected into every session so Claude acts consistently across projects and time.

### Auto-Evolution

The system that makes Cortex different from a static config:

1. **Stop hook** — After every session, Claude evaluates: "Should I update memory?" Not everything gets saved. Only durable, reusable knowledge.
2. **Self-building** — When solving a problem: "Could this be needed again?" → saves the script. "Was this a multi-step workflow?" → creates a skill.
3. **`/cortex:evolve`** — Manual deep audit. Cleans stale entries, consolidates duplicates, archives old conversations, proposes identity updates.

### Cross-Project Learning

`/cortex:learn` works in two phases:

1. **Extraction** (zero LLM cost) — Python script scans `~/.claude/projects/` for conversation transcripts
2. **Analysis** (uses Claude) — Patterns extracted and merged into memory: coding style, debugging approaches, technology preferences, recurring decisions

This is how your assistant goes from "new to this project" to "knows how you think" in one command.

---

## Telegram: Your Agent in Your Pocket

Powered by [NitroAgent](https://github.com/octaviusp/NitroAgent), an open source Telegram-to-Claude Code bridge built in Rust.

```
/cortex:connect-telegram
```

The command guides you through **everything** — no prior knowledge needed:

1. Walks you through creating a bot via @BotFather
2. Helps you find your Telegram user ID
3. Clones, compiles, and installs NitroAgent as a macOS daemon
4. Sends you a test message to confirm it works

Once running:
- **Text** → Claude Code executes it in your workspace
- **Voice messages** → transcribed and executed (Moonshine STT)
- **Photos** → Claude analyzes them
- **Streaming** → real-time progress with animated UI
- **Session memory** → resume conversations with `/resume`
- **Starts on login, restarts on crash** — always available

**Why this matters:** You can iterate on ideas from anywhere. Waiting in line? "Add rate limiting to the API." On the couch? "What broke in today's deploy?" At 2 AM with an idea? Message your bot and it's building it before you fall asleep.

---

## Zero Project Pollution

```
~/.claude/cortex/              ← All Cortex data lives HERE
├── memory/                    ← 6 persistent memory files
├── identity/                  ← SOUL.md + USER.md
├── data/
│   ├── logs/                  ← Session and cron logs
│   ├── reports/               ← Generated reports
│   └── exports/               ← Archived conversations
├── scripts/                   ← Utility scripts (+ auto-created ones)
├── cron/                      ← Scheduled jobs
└── nitro-agent/               ← Telegram bridge (optional)
```

Your projects stay completely clean. No `memory/` directories. No config files. No data artifacts. Ever.

---

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

Optional scheduled jobs (installed during setup):
- **7:00 AM** — Morning briefing (~$0.01)
- **Every 15 min** — Awareness scan (zero LLM cost)
- **10:00 PM** — Daily summary (~$0.01)

---

## Philosophy

1. **Self-building** — The AI creates its own tools as it works with you
2. **Cross-project intelligence** — Learns from all your Claude Code projects, not just the current one
3. **Zero pollution** — Your repos stay clean; all data at `~/.claude/cortex/`
4. **Bash first, Claude second** — Scripts for mechanical tasks, Claude for thinking
5. **Memory is selective** — Only durable, reusable knowledge gets persisted
6. **Plain text over databases** — Markdown files you can read, edit, and version control
7. **User is in control** — Destructive actions always require confirmation

---

## Credits

- **[NitroAgent](https://github.com/octaviusp/NitroAgent)** by [Octavio Pavon](https://github.com/octaviusp) — The Rust-based Telegram-to-Claude Code bridge that powers `/cortex:connect-telegram`. Multi-agent support, streaming UI, voice transcription, session management. An incredible piece of engineering that makes remote access possible.

- Built by [Hugo Guerra](https://github.com/hugoguerrap) — born from months of daily use building a personal AI assistant on Claude Code, then packaged so anyone can have the same experience.

## License

MIT
