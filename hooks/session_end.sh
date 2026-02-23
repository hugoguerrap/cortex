#!/bin/bash
# session_end.sh - Log session end and duration
# Runs async on SessionEnd

set -uo pipefail

CORTEX_HOME="${CORTEX_HOME:-$HOME/.claude/cortex}"
LOG_DIR="$CORTEX_HOME/data/logs"
LOG_FILE="$LOG_DIR/sessions.log"

mkdir -p "$LOG_DIR"

# Read input from stdin
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null || echo "unknown")
REASON=$(echo "$INPUT" | jq -r '.reason // "unknown"' 2>/dev/null || echo "unknown")

# Calculate approximate duration from last SESSION_START
LAST_START=$(grep "SESSION_START" "$LOG_FILE" 2>/dev/null | tail -1 | grep -o '^\[.*\]' | tr -d '[]')
if [ -n "$LAST_START" ]; then
    if date -j &>/dev/null 2>&1; then
        START_EPOCH=$(date -j -f "%Y-%m-%d %H:%M:%S" "$LAST_START" "+%s" 2>/dev/null || echo "0")
    else
        START_EPOCH=$(date -d "$LAST_START" "+%s" 2>/dev/null || echo "0")
    fi
    NOW_EPOCH=$(date "+%s")
    if [ "$START_EPOCH" -gt 0 ]; then
        DURATION_SECS=$((NOW_EPOCH - START_EPOCH))
        DURATION_MIN=$((DURATION_SECS / 60))
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] SESSION_END reason=$REASON session=$SESSION_ID duration=${DURATION_MIN}m" >> "$LOG_FILE"
    else
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] SESSION_END reason=$REASON session=$SESSION_ID" >> "$LOG_FILE"
    fi
else
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] SESSION_END reason=$REASON session=$SESSION_ID" >> "$LOG_FILE"
fi

# Rotate sessions.log if > 1000 lines
LINE_COUNT=$(wc -l < "$LOG_FILE" 2>/dev/null || echo "0")
if [ "$LINE_COUNT" -gt 1000 ]; then
    tail -500 "$LOG_FILE" > "$LOG_FILE.tmp" && mv "$LOG_FILE.tmp" "$LOG_FILE"
fi

exit 0
