#!/bin/bash
# session_start.sh - Inject memory context + analysis into new sessions
# Reads memory files, analyzes staleness/urgency, returns additionalContext

set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
LOG_DIR="$PROJECT_DIR/data/logs"
mkdir -p "$LOG_DIR"

CONTEXT=""

# === MEMORY FILES ===

# Check if setup has been run
if [ ! -d "$PROJECT_DIR/memory" ] || [ ! -f "$PROJECT_DIR/memory/context.md" ]; then
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

# Read current priorities
if [ -f "$PROJECT_DIR/memory/context.md" ]; then
    CONTEXT_MD=$(cat "$PROJECT_DIR/memory/context.md" 2>/dev/null || true)
    CONTEXT="## Current Context\n$CONTEXT_MD"
fi

# Read strategy (goals, opportunities, contacts)
if [ -f "$PROJECT_DIR/memory/strategy.md" ]; then
    STRATEGY=$(cat "$PROJECT_DIR/memory/strategy.md" 2>/dev/null || true)
    CONTEXT="$CONTEXT\n\n## Strategy & Opportunities\n$STRATEGY"
fi

# Read lessons (last 30 lines)
if [ -f "$PROJECT_DIR/memory/lessons.md" ]; then
    LESSONS=$(tail -30 "$PROJECT_DIR/memory/lessons.md" 2>/dev/null || true)
    CONTEXT="$CONTEXT\n\n## Recent Lessons\n$LESSONS"
fi

# Read recent conversations (last 20 lines)
if [ -f "$PROJECT_DIR/memory/conversations.md" ]; then
    CONVOS=$(tail -20 "$PROJECT_DIR/memory/conversations.md" 2>/dev/null || true)
    CONTEXT="$CONTEXT\n\n## Recent Conversations\n$CONVOS"
fi

# === ANALYSIS: Time since last session ===
SESSION_LOG="$LOG_DIR/sessions.log"
if [ -f "$SESSION_LOG" ]; then
    LAST_END=$(grep "SESSION_END" "$SESSION_LOG" 2>/dev/null | tail -1 | grep -o '^\[.*\]' | tr -d '[]')
    if [ -n "$LAST_END" ]; then
        # Cross-platform date calculation
        if date -j &>/dev/null 2>&1; then
            # macOS
            LAST_EPOCH=$(date -j -f "%Y-%m-%d %H:%M:%S" "$LAST_END" "+%s" 2>/dev/null || echo "0")
        else
            # Linux
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

# Log session start
echo "[$(date '+%Y-%m-%d %H:%M:%S')] SESSION_START" >> "$LOG_DIR/sessions.log"

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
