#!/bin/bash
# session_start.sh - Inject memory context + analysis into new sessions
# Reads memory files from CORTEX_HOME, returns additionalContext

set -uo pipefail

CORTEX_HOME="${CORTEX_HOME:-$HOME/.claude/cortex}"
LOG_DIR="$CORTEX_HOME/data/logs"
mkdir -p "$LOG_DIR"

CONTEXT=""

# === CHECK SETUP ===

if [ ! -d "$CORTEX_HOME/memory" ] || [ ! -f "$CORTEX_HOME/memory/context.md" ]; then
    CONTEXT="## First Time Setup\nRun \`/cortex:setup\` to initialize Cortex."
    if command -v jq &>/dev/null; then
        jq -n --arg ctx "$CONTEXT" '{
            "hookSpecificOutput": {
                "hookEventName": "SessionStart",
                "additionalContext": $ctx
            }
        }'
    else
        echo -e "$CONTEXT"
    fi
    exit 0
fi

# === IDENTITY ===

if [ -f "$CORTEX_HOME/identity/SOUL.md" ]; then
    SOUL=$(cat "$CORTEX_HOME/identity/SOUL.md" 2>/dev/null || true)
    CONTEXT="## Assistant Identity\n$SOUL"
fi

if [ -f "$CORTEX_HOME/identity/USER.md" ]; then
    USER_PROFILE=$(cat "$CORTEX_HOME/identity/USER.md" 2>/dev/null || true)
    CONTEXT="$CONTEXT\n\n## User Profile\n$USER_PROFILE"
fi

# === MEMORY FILES ===

if [ -f "$CORTEX_HOME/memory/context.md" ]; then
    CONTEXT_MD=$(cat "$CORTEX_HOME/memory/context.md" 2>/dev/null || true)
    CONTEXT="$CONTEXT\n\n## Current Context\n$CONTEXT_MD"
fi

if [ -f "$CORTEX_HOME/memory/strategy.md" ]; then
    STRATEGY=$(cat "$CORTEX_HOME/memory/strategy.md" 2>/dev/null || true)
    CONTEXT="$CONTEXT\n\n## Strategy & Opportunities\n$STRATEGY"
fi

if [ -f "$CORTEX_HOME/memory/lessons.md" ]; then
    LESSONS=$(tail -30 "$CORTEX_HOME/memory/lessons.md" 2>/dev/null || true)
    CONTEXT="$CONTEXT\n\n## Recent Lessons\n$LESSONS"
fi

if [ -f "$CORTEX_HOME/memory/conversations.md" ]; then
    CONVOS=$(tail -20 "$CORTEX_HOME/memory/conversations.md" 2>/dev/null || true)
    CONTEXT="$CONTEXT\n\n## Recent Conversations\n$CONVOS"
fi

# === ANALYSIS: Time since last session ===
SESSION_LOG="$LOG_DIR/sessions.log"
if [ -f "$SESSION_LOG" ]; then
    LAST_END=$(grep "SESSION_END" "$SESSION_LOG" 2>/dev/null | tail -1 | grep -o '^\[.*\]' | tr -d '[]')
    if [ -n "$LAST_END" ]; then
        if date -j &>/dev/null 2>&1; then
            LAST_EPOCH=$(date -j -f "%Y-%m-%d %H:%M:%S" "$LAST_END" "+%s" 2>/dev/null || echo "0")
        else
            LAST_EPOCH=$(date -d "$LAST_END" "+%s" 2>/dev/null || echo "0")
        fi
        NOW_EPOCH=$(date "+%s")
        if [ "$LAST_EPOCH" -gt 0 ]; then
            HOURS_SINCE=$(( (NOW_EPOCH - LAST_EPOCH) / 3600 ))
            CONTEXT="$CONTEXT\n\n## Session Gap\n- Last session ended: $LAST_END ($HOURS_SINCE hours ago)"
            if [ "$HOURS_SINCE" -gt 48 ]; then
                CONTEXT="$CONTEXT\n- Note: More than 2 days since last session — check for stale items"
            fi
        fi
    fi
fi

# === ANALYSIS: Failed cron jobs (last 24h) ===
CRON_ERRORS=""
for logfile in "$LOG_DIR"/*_*.log; do
    [ -f "$logfile" ] || continue
    if find "$logfile" -mtime -1 -print 2>/dev/null | grep -q .; then
        if grep -q "exit code: [1-9]" "$logfile" 2>/dev/null; then
            TASK=$(basename "$logfile" | sed 's/_[0-9].*//; s/.log$//')
            CRON_ERRORS="$CRON_ERRORS\n- $TASK failed (check $logfile)"
        fi
    fi
done
if [ -n "$CRON_ERRORS" ]; then
    CONTEXT="$CONTEXT\n\n## Cron Health (last 24h)$CRON_ERRORS"
fi

# Inject current project path so the assistant knows where it's working
CONTEXT="$CONTEXT\n\n## Current Project\n- Working directory: ${CLAUDE_PROJECT_DIR:-.}"
CONTEXT="$CONTEXT\n- Cortex home: $CORTEX_HOME"

# Log session start
echo "[$(date '+%Y-%m-%d %H:%M:%S')] SESSION_START project=${CLAUDE_PROJECT_DIR:-.}" >> "$LOG_DIR/sessions.log"

# Output as JSON with additionalContext
if command -v jq &>/dev/null; then
    jq -n --arg ctx "$CONTEXT" '{
        "hookSpecificOutput": {
            "hookEventName": "SessionStart",
            "additionalContext": $ctx
        }
    }'
else
    echo -e "$CONTEXT"
fi
