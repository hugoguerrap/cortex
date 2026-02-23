#!/bin/bash
# install_cron.sh - Install cron jobs for Cortex
# Usage: bash cron/install_cron.sh
#
# Preserves existing crontab. Replaces Cortex entries on re-run.
# Requires CLAUDE_PROJECT_DIR to be set.

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:?Error: Set CLAUDE_PROJECT_DIR to your project directory}"

# Validate scripts exist
for script in briefing.sh awareness_scan.sh; do
    if [ ! -f "$PROJECT_DIR/cron/${script}" ]; then
        echo "Warning: Missing $PROJECT_DIR/cron/${script} — will create template"
    fi
done

# Create cron scripts if they don't exist
mkdir -p "$PROJECT_DIR/cron"

if [ ! -f "$PROJECT_DIR/cron/briefing.sh" ]; then
    cat > "$PROJECT_DIR/cron/briefing.sh" << 'CRONEOF'
#!/bin/bash
# Morning briefing via Claude Code
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
export CLAUDE_PROJECT_DIR="$PROJECT_DIR"
"$PROJECT_DIR/scripts/cron_runner.sh" "briefing" "Generate a daily briefing. Read memory/context.md and memory/strategy.md for priorities. Send the result via scripts/notify.sh."
CRONEOF
    chmod +x "$PROJECT_DIR/cron/briefing.sh"
fi

if [ ! -f "$PROJECT_DIR/cron/awareness_scan.sh" ]; then
    cat > "$PROJECT_DIR/cron/awareness_scan.sh" << 'CRONEOF'
#!/bin/bash
# Awareness scan (no LLM, pure Python)
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
export CLAUDE_PROJECT_DIR="$PROJECT_DIR"
python3 "$PROJECT_DIR/scripts/awareness_scan.py"
CRONEOF
    chmod +x "$PROJECT_DIR/cron/awareness_scan.sh"
fi

if [ ! -f "$PROJECT_DIR/cron/summary.sh" ]; then
    cat > "$PROJECT_DIR/cron/summary.sh" << 'CRONEOF'
#!/bin/bash
# Daily summary via Claude Code
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
export CLAUDE_PROJECT_DIR="$PROJECT_DIR"
"$PROJECT_DIR/scripts/cron_runner.sh" "summary" "Generate a brief end-of-day summary. Check what was accomplished today from memory/conversations.md and data/logs/sessions.log. Send via scripts/notify.sh."
CRONEOF
    chmod +x "$PROJECT_DIR/cron/summary.sh"
fi

CRON_ENTRIES="
# === cortex START ===
# Morning briefing (7:00 AM daily)
0 7 * * * $PROJECT_DIR/cron/briefing.sh >> /dev/null 2>&1

# Awareness scan (every 15 minutes, 8am-11pm) — no LLM cost
*/15 8-23 * * * $PROJECT_DIR/cron/awareness_scan.sh >> /dev/null 2>&1

# Daily summary (10:00 PM daily)
0 22 * * * $PROJECT_DIR/cron/summary.sh >> /dev/null 2>&1
# === cortex END ===
"

# Remove old entries and add new ones
EXISTING=$(crontab -l 2>/dev/null | sed '/=== cortex START ===/,/=== cortex END ===/d' || true)

echo "${EXISTING}${CRON_ENTRIES}" | crontab -

echo "Cortex cron jobs installed!"
echo ""
echo "Jobs:"
echo "  0 7  * * *       Morning briefing"
echo "  */15 8-23 * * *  Awareness scan (no LLM cost)"
echo "  0 22 * * *       Daily summary"
echo ""
echo "Verify: crontab -l"
echo "Remove: crontab -l | sed '/cortex START/,/cortex END/d' | crontab -"
