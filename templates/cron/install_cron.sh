#!/bin/bash
# install_cron.sh - Install cron jobs for Cortex
# Usage: bash install_cron.sh
#
# Preserves existing crontab. Replaces Cortex entries on re-run.

set -euo pipefail

CORTEX_HOME="${CORTEX_HOME:-$HOME/.claude/cortex}"

# Create cron wrappers in CORTEX_HOME
mkdir -p "$CORTEX_HOME/cron"

cat > "$CORTEX_HOME/cron/briefing.sh" << CRONEOF
#!/bin/bash
export CORTEX_HOME="${CORTEX_HOME}"
"$CORTEX_HOME/scripts/cron_runner.sh" "briefing" "Generate a daily briefing. Read ~/.claude/cortex/memory/context.md and ~/.claude/cortex/memory/strategy.md for priorities. Send the result via ~/.claude/cortex/scripts/notify.sh."
CRONEOF
chmod +x "$CORTEX_HOME/cron/briefing.sh"

cat > "$CORTEX_HOME/cron/awareness_scan.sh" << CRONEOF
#!/bin/bash
export CORTEX_HOME="${CORTEX_HOME}"
python3 "$CORTEX_HOME/scripts/awareness_scan.py"
CRONEOF
chmod +x "$CORTEX_HOME/cron/awareness_scan.sh"

cat > "$CORTEX_HOME/cron/summary.sh" << CRONEOF
#!/bin/bash
export CORTEX_HOME="${CORTEX_HOME}"
"$CORTEX_HOME/scripts/cron_runner.sh" "summary" "Generate a brief end-of-day summary. Check what was accomplished today from ~/.claude/cortex/memory/conversations.md and ~/.claude/cortex/data/logs/sessions.log. Send via ~/.claude/cortex/scripts/notify.sh."
CRONEOF
chmod +x "$CORTEX_HOME/cron/summary.sh"

CRON_ENTRIES="
# === cortex START ===
# Morning briefing (7:00 AM daily)
0 7 * * * $CORTEX_HOME/cron/briefing.sh >> /dev/null 2>&1

# Awareness scan (every 15 minutes, 8am-11pm) — no LLM cost
*/15 8-23 * * * $CORTEX_HOME/cron/awareness_scan.sh >> /dev/null 2>&1

# Daily summary (10:00 PM daily)
0 22 * * * $CORTEX_HOME/cron/summary.sh >> /dev/null 2>&1
# === cortex END ===
"

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
