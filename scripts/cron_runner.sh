#!/bin/bash
# cron_runner.sh - Wrapper for running Claude Code from cron
# Usage: cron_runner.sh <task_name> <prompt>
#
# Features:
#   - PID lock to prevent concurrent runs
#   - Logs to ~/.claude/cortex/data/logs/
#   - Sends error notification if task fails
#   - Log rotation (> 7 days)

set -uo pipefail

CORTEX_HOME="${CORTEX_HOME:-$HOME/.claude/cortex}"
TASK_NAME="${1:?Error: task_name required as first argument}"
PROMPT="${2:?Error: prompt required as second argument}"

LOG_DIR="$CORTEX_HOME/data/logs"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
LOG_FILE="$LOG_DIR/${TASK_NAME}_${TIMESTAMP}.log"
PID_FILE="$LOG_DIR/${TASK_NAME}.pid"

mkdir -p "$LOG_DIR"

# Check for concurrent execution
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(cat "$PID_FILE")
    if kill -0 "$OLD_PID" 2>/dev/null; then
        echo "[$(date)] SKIP: $TASK_NAME already running (PID $OLD_PID)" >> "$LOG_FILE"
        exit 0
    fi
    rm -f "$PID_FILE"
fi

# Write PID
echo $$ > "$PID_FILE"
trap 'rm -f "$PID_FILE"' EXIT

echo "[$(date)] START: $TASK_NAME" >> "$LOG_FILE"

# Invoke Claude Code (runs from home dir, plugin is loaded globally)
cd "$HOME"

claude --print \
    --model sonnet \
    --dangerously-skip-permissions \
    "$PROMPT" \
    >> "$LOG_FILE" 2>&1

EXIT_CODE=$?

echo "[$(date)] END: $TASK_NAME (exit code: $EXIT_CODE)" >> "$LOG_FILE"

# Notify on failure
if [ $EXIT_CODE -ne 0 ]; then
    NOTIFY_SCRIPT="$CORTEX_HOME/scripts/notify.sh"
    if [ -f "$NOTIFY_SCRIPT" ]; then
        "$NOTIFY_SCRIPT" "Cron error: $TASK_NAME failed (code $EXIT_CODE). Check logs." 2>/dev/null || true
    fi
fi

# Rotate old logs (> 7 days)
find "$LOG_DIR" -name "${TASK_NAME}_*.log" -mtime +7 -delete 2>/dev/null || true
