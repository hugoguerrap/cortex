#!/usr/bin/env python3
"""
awareness_scan.py - Lightweight peripheral awareness scanner
Zero LLM cost. Pure Python.
Checks: cron health, memory freshness, strategy followups.
Sends notification only if something needs attention. Silent otherwise.
"""

import json
import os
import subprocess
import sys
from datetime import datetime, timedelta
from pathlib import Path

PROJECT_DIR = Path(os.environ.get("CLAUDE_PROJECT_DIR", "."))
DATA_DIR = PROJECT_DIR / "data"
LOG_DIR = DATA_DIR / "logs"
SCAN_LOG = LOG_DIR / "awareness_scan.log"
SCAN_STATE = DATA_DIR / "awareness_state.json"


def log(msg):
    LOG_DIR.mkdir(parents=True, exist_ok=True)
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    with open(SCAN_LOG, "a") as f:
        f.write(f"[{timestamp}] {msg}\n")
    # Rotate if > 500 lines
    if SCAN_LOG.exists():
        lines = SCAN_LOG.read_text().splitlines()
        if len(lines) > 500:
            SCAN_LOG.write_text("\n".join(lines[-250:]) + "\n")


def notify(message):
    """Send notification via notify.sh"""
    notify_script = PROJECT_DIR / "scripts" / "notify.sh"
    if notify_script.exists():
        try:
            subprocess.run(
                [str(notify_script), message],
                timeout=15,
                capture_output=True,
            )
        except Exception as e:
            log(f"ERROR sending notification: {e}")
    else:
        log("WARN: scripts/notify.sh not found")


def load_state():
    if SCAN_STATE.exists():
        try:
            return json.loads(SCAN_STATE.read_text())
        except Exception:
            pass
    return {"last_scan": None, "last_alert": None, "alert_count_today": 0}


def save_state(state):
    DATA_DIR.mkdir(parents=True, exist_ok=True)
    SCAN_STATE.write_text(json.dumps(state, indent=2))


def check_cron_health():
    """Check if any cron jobs failed in the last hour"""
    failures = []
    if LOG_DIR.exists():
        one_hour_ago = datetime.now() - timedelta(hours=1)
        for logfile in LOG_DIR.glob("*_*.log"):
            try:
                if logfile.name in ("awareness_scan.log", "notify.log"):
                    continue
                mtime = datetime.fromtimestamp(logfile.stat().st_mtime)
                if mtime > one_hour_ago:
                    content = logfile.read_text()
                    for line in content.splitlines():
                        if "exit code:" in line and "exit code: 0" not in line:
                            task = logfile.name.split("_")[0]
                            failures.append(task)
                            break
            except Exception:
                continue
    return failures


def check_memory_freshness():
    """Check if memory files are getting stale"""
    stale = []
    memory_dir = PROJECT_DIR / "memory"
    if not memory_dir.exists():
        return stale

    seven_days_ago = datetime.now() - timedelta(days=7)
    for md_file in memory_dir.glob("*.md"):
        try:
            mtime = datetime.fromtimestamp(md_file.stat().st_mtime)
            if mtime < seven_days_ago:
                days_old = (datetime.now() - mtime).days
                stale.append(f"{md_file.name} ({days_old}d old)")
        except Exception:
            continue
    return stale


def check_strategy_followups():
    """Check strategy.md for unchecked followups"""
    strategy = PROJECT_DIR / "memory" / "strategy.md"
    if not strategy.exists():
        return []
    content = strategy.read_text()
    overdue = []
    for line in content.splitlines():
        if "[ ]" in line and line.strip().startswith("- [ ]"):
            overdue.append(line.strip().replace("- [ ] ", ""))
    return overdue[:3]


def main():
    state = load_state()

    # Rate limit: max 5 alerts per day
    today = datetime.now().strftime("%Y-%m-%d")
    if state.get("last_alert_date") != today:
        state["alert_count_today"] = 0
        state["last_alert_date"] = today

    if state["alert_count_today"] >= 5:
        log("SKIP: Daily alert limit reached (5)")
        save_state(state)
        return

    # Run checks
    cron_failures = check_cron_health()
    stale_memory = check_memory_freshness()
    followups = check_strategy_followups()

    # Build alert
    alerts = []

    if cron_failures:
        alerts.append(f"Cron failures: {', '.join(cron_failures)}")

    if stale_memory:
        alerts.append(f"Stale memory: {', '.join(stale_memory)}")

    # Followups: only alert once per day
    if followups:
        last_followup_alert = state.get("last_followup_alert")
        if not last_followup_alert or (
            datetime.now() - datetime.fromisoformat(last_followup_alert)
        ).total_seconds() > 86400:
            alerts.append(
                "Pending followups:\n" + "\n".join(f"  - {f}" for f in followups)
            )
            state["last_followup_alert"] = datetime.now().isoformat()

    if alerts:
        message = "Awareness Scan\n\n" + "\n\n".join(alerts)
        notify(message)
        state["alert_count_today"] = state.get("alert_count_today", 0) + 1
        state["last_alert"] = datetime.now().isoformat()
        log(f"ALERT sent: {len(alerts)} items")
    else:
        log("OK: Nothing urgent")

    state["last_scan"] = datetime.now().isoformat()
    save_state(state)


if __name__ == "__main__":
    main()
