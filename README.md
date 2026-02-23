# Cortex

**Your AI that builds itself.**

A Claude Code plugin that turns your assistant into a persistent, cross-project intelligence that learns your patterns, grows its own tools, installs its own integrations, and lets you talk to it from Telegram while you're away from your desk.

```bash
claude plugin install cortex
```

```
/cortex:setup
```

That's it. Two commands. You now have a personal AI with memory, identity, and self-evolution.

---

## Why Cortex?

Most memory plugins record what happened. Cortex learns **how you think** — and then acts on it.

| | claude-mem | supermemory | Cortex |
|---|---|---|---|
| Session memory | Captures tool observations | Stores conversation turns | Evaluates what's **worth** remembering |
| Cross-project | No | User profile via cloud API | Scans ALL local transcripts, zero cloud |
| Storage | SQLite + Chroma (embeddings) | Cloud API (supermemory.ai) | Plain markdown files you can read and edit |
| Auto-evolution | No | No | Creates its own scripts, skills, and cron jobs |
| Self-installing integrations | No | No | Searches, installs and configures MCP servers on demand |
| Identity | No | No | Customizable personality + user profile |
| Self-audit | No | No | `/evolve` — cleans stale data, consolidates, archives |
| Telegram access | No | No | Chat from your phone via NitroAgent |
| Cron automation | No | No | Scheduled briefings, scans, summaries |
| Cloud dependency | No | Yes (supermemory.ai API) | No — 100% local |
| Project pollution | Writes to project | Writes to project | **Zero** — all data at `~/.claude/cortex/` |

**The fundamental difference:** other plugins add memory to Claude Code. Cortex adds **agency**. Your assistant doesn't just remember — it thinks about what to remember, builds tools when it spots patterns, installs new capabilities when you need them, and audits its own knowledge for staleness.

---

## What It Can Actually Do

Cortex is not just memory. It's a foundation for a personal AI that grows with you.

### Ask for any integration — it figures it out

You say: *"I want to read my Google emails"*

Your assistant:
1. Searches for a Google Workspace MCP server
2. Installs it with `claude mcp add`
3. Walks you through OAuth setup step by step — which URL to visit, which buttons to click
4. Tests the connection
5. Remembers the integration is available for future sessions

Same thing for Discord, Slack, GitHub, web browsing, crypto prices, calendar, drive — anything with an MCP server. **You don't need to know what MCP is.** You just ask for what you want and your assistant makes it happen.

### Chat from your phone

Powered by [NitroAgent](https://github.com/octaviusp/NitroAgent), you can message your agent from Telegram. You're on the bus with an idea? Send it. Your assistant executes it on your machine and streams back the result in real time — text, voice, photos.

```
/cortex:connect-telegram
```

The command guides you through everything: creating a bot, getting your ID, installing, testing. Zero prior knowledge needed.

### Learn from your entire history

```
/cortex:learn
```

One command scans every Claude Code conversation you've ever had — across all projects — and builds a cognitive profile. Your coding style, recurring decisions, debugging patterns, technology preferences. Knowledge that was trapped in individual sessions becomes available everywhere.

### Build its own tools

When your assistant solves something that might come up again, it saves the script. When it detects a multi-step workflow, it creates a skill. When it finds a useful cron pattern, it schedules it. You don't configure this — it just happens.

---

## What Happens When You Install It

### Day 1
You run `/cortex:setup`. It asks your name, what to call the assistant, and if you want Telegram access. Everything gets created at `~/.claude/cortex/`. Your projects stay untouched.

### Week 1
Every session, the Stop hook evaluates the conversation: "Did I learn something reusable?" Technical insights go to `lessons.md`. Your preferences go to `preferences.md`. Project context goes to `context.md`. You don't do anything — it happens automatically.

You say "I want to check my calendar" — it finds a calendar MCP, installs it, walks you through auth. Next session, it's just there.

### Week 2
You run `/cortex:learn`. It scans every Claude Code conversation you've ever had across all projects. It builds a cognitive profile. Knowledge that was locked in individual sessions is now available everywhere.

### Month 1
Your assistant knows your stack, your patterns, your priorities, and has the integrations you actually use. When you open a new project, it already understands how you work. When you hit a familiar bug, the lesson is there. When you need a new capability, it installs it.

### From Telegram
You're away from your desk with an idea. You message your bot: *"add rate limiting to the API."* Your assistant — running on your Mac — does it and streams back the result. You iterate from anywhere, anytime.

---

## Commands

```
/cortex:setup              → Memory, identity, scripts — ready in 60 seconds
/cortex:connect-telegram   → Guided Telegram setup — running in 5 min
/cortex:learn              → Scan ALL Claude Code history → cognitive profile
/cortex:evolve             → Self-audit: clean, consolidate, archive
/cortex:status             → Health dashboard
/cortex:briefing           → Daily summary
/cortex:create-skill       → Create new capabilities on the fly
```

## Memory System

6 persistent files at `~/.claude/cortex/memory/` — plain markdown, human-readable, git-friendly:

| File | Purpose | Limit |
|------|---------|-------|
| `context.md` | Active projects, priorities, installed integrations | 200 lines |
| `strategy.md` | Goals, opportunities, contacts | No limit |
| `lessons.md` | Technical insights, debugging patterns | Categorized |
| `preferences.md` | Learned work preferences | 100 lines |
| `conversations.md` | Key session summaries | 30 days |
| `watchlist.md` | Monitored items | 50 items |

Memory is **injected at session start** and **evaluated at session end** — automatically, via hooks.

## Identity System

Two files that define who your assistant is:

- `SOUL.md` — Personality, communication style, decision-making approach
- `USER.md` — Who you are, how you work, what you value

These aren't decorative. They're injected into every session so Claude acts consistently across projects and time.

---

## Telegram: Your Agent in Your Pocket

Powered by [NitroAgent](https://github.com/octaviusp/NitroAgent) — an open source Telegram-to-Claude Code bridge built in Rust by [Octavio Pavon](https://github.com/octaviusp).

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
- **Voice messages** → transcribed and executed
- **Photos** → Claude analyzes them
- **Streaming** → real-time progress with animated UI
- **Session memory** → resume conversations with `/resume`
- **Starts on login, restarts on crash** — always available

**Why this matters:** Your best ideas don't happen at your desk. With Telegram access you can iterate on anything, from anywhere, anytime. The feedback loop between "I have an idea" and "it's running" shrinks to seconds.

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

## Where This Is Going

Cortex today is a foundation. Here's where it can go — and where the community can take it:

- **Proactive intelligence** — alerts about things that matter without you asking
- **Shared skill library** — community-built skills anyone can install
- **More chat platforms** — WhatsApp, Discord, Slack as first-class interfaces
- **Smart MCP discovery** — automatic suggestions for integrations you might need
- **Team memory** — shared knowledge across collaborators on the same project

This is the base. PRs are welcome. Every developer who uses Claude Code daily has ideas about how their ideal assistant should work — let's build it together.

---

## Philosophy

1. **Never say "I can't"** — If a capability is missing, search for it, install it, configure it
2. **Self-building** — The AI creates its own tools as it works with you
3. **Cross-project intelligence** — Learns from all your Claude Code projects, not just the current one
4. **Zero pollution** — Your repos stay clean; all data at `~/.claude/cortex/`
5. **Plain text over databases** — Markdown files you can read, edit, and version control
6. **User is in control** — Destructive actions always require confirmation

---

## Credits

- **[NitroAgent](https://github.com/octaviusp/NitroAgent)** by [Octavio Pavon](https://github.com/octaviusp) — The Rust-based Telegram-to-Claude Code bridge that powers `/cortex:connect-telegram`. Multi-agent support, streaming UI, voice transcription, session management. An incredible piece of open source engineering that makes remote access to Claude Code possible.

- Built by [Hugo Guerra](https://github.com/hugoguerrap) — born from months of daily use building a personal AI assistant on Claude Code, then packaged so anyone can have the same experience. Inspired by the vision of [OpenClaw](https://github.com/openclaw/openclaw) — but native to the Claude Code ecosystem.

## Contributing

PRs are welcome. If you use Claude Code daily and have ideas for how a personal AI assistant should work, this is the place to build it. Check the [issues](https://github.com/hugoguerrap/cortex/issues) or open one with your idea.

## License

MIT
