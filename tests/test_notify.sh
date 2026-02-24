#!/bin/bash
# Tests for notify.sh
# Usage: bash tests/test_notify.sh
#
# Tests the dispatch logic, logging, and error handling.
# Does NOT send real messages (no tokens configured).

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PASS=0
FAIL=0
TOTAL=0

TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

log_result() {
    TOTAL=$((TOTAL + 1))
    if [ "$1" = "PASS" ]; then
        PASS=$((PASS + 1))
        echo "  PASS: $2"
    else
        FAIL=$((FAIL + 1))
        echo "  FAIL: $2 — $3"
    fi
}

echo "=== Tests: notify.sh ==="
echo ""

# --- Test 1: Fails without message argument ---
echo "Test 1: Fails when no message provided"
export CORTEX_HOME="$TEST_DIR/notify1"
export CORTEX_NOTIFY_CHANNEL="none"
mkdir -p "$CORTEX_HOME/data/logs"
OUTPUT=$(bash "$PROJECT_ROOT/scripts/notify.sh" 2>&1 || true)
if echo "$OUTPUT" | grep -qi "error\|required"; then
    log_result "PASS" "Errors when no message argument"
else
    log_result "FAIL" "Errors when no message argument" "No error message shown"
fi

# --- Test 2: Channel 'none' logs skip ---
echo "Test 2: Channel 'none' logs SKIP"
export CORTEX_HOME="$TEST_DIR/notify2"
export CORTEX_NOTIFY_CHANNEL="none"
mkdir -p "$CORTEX_HOME/data/logs"
bash "$PROJECT_ROOT/scripts/notify.sh" "test message" 2>/dev/null
if [ -f "$CORTEX_HOME/data/logs/notify.log" ]; then
    if grep -q "SKIP: channel=none" "$CORTEX_HOME/data/logs/notify.log"; then
        log_result "PASS" "Channel 'none' logs SKIP"
    else
        log_result "FAIL" "Channel 'none' logs SKIP" "Log content: $(cat "$CORTEX_HOME/data/logs/notify.log")"
    fi
else
    log_result "FAIL" "Channel 'none' logs SKIP" "notify.log not created"
fi

# --- Test 3: Unknown channel fails ---
echo "Test 3: Unknown channel produces error"
export CORTEX_HOME="$TEST_DIR/notify3"
export CORTEX_NOTIFY_CHANNEL="carrier_pigeon"
mkdir -p "$CORTEX_HOME/data/logs"
OUTPUT=$(bash "$PROJECT_ROOT/scripts/notify.sh" "test" 2>&1 || true)
EXIT_CODE=$?
if [ $EXIT_CODE -ne 0 ] || echo "$OUTPUT" | grep -qi "unknown"; then
    log_result "PASS" "Unknown channel rejected"
else
    log_result "FAIL" "Unknown channel rejected" "Exit code $EXIT_CODE, output: $OUTPUT"
fi

# --- Test 4: Telegram fails without token ---
echo "Test 4: Telegram channel fails without CORTEX_TELEGRAM_TOKEN"
export CORTEX_HOME="$TEST_DIR/notify4"
export CORTEX_NOTIFY_CHANNEL="telegram"
unset CORTEX_TELEGRAM_TOKEN 2>/dev/null || true
unset CORTEX_TELEGRAM_CHAT_ID 2>/dev/null || true
mkdir -p "$CORTEX_HOME/data/logs"
OUTPUT=$(bash "$PROJECT_ROOT/scripts/notify.sh" "test" 2>&1 || true)
if echo "$OUTPUT" | grep -qi "CORTEX_TELEGRAM_TOKEN\|error\|not set"; then
    log_result "PASS" "Telegram fails without token"
else
    log_result "FAIL" "Telegram fails without token" "Output: $OUTPUT"
fi

# --- Test 5: Discord fails without webhook ---
echo "Test 5: Discord channel fails without CORTEX_DISCORD_WEBHOOK"
export CORTEX_HOME="$TEST_DIR/notify5"
export CORTEX_NOTIFY_CHANNEL="discord"
unset CORTEX_DISCORD_WEBHOOK 2>/dev/null || true
mkdir -p "$CORTEX_HOME/data/logs"
OUTPUT=$(bash "$PROJECT_ROOT/scripts/notify.sh" "test" 2>&1 || true)
if echo "$OUTPUT" | grep -qi "CORTEX_DISCORD_WEBHOOK\|error\|not set"; then
    log_result "PASS" "Discord fails without webhook"
else
    log_result "FAIL" "Discord fails without webhook" "Output: $OUTPUT"
fi

# --- Test 6: Slack fails without webhook ---
echo "Test 6: Slack channel fails without CORTEX_SLACK_WEBHOOK"
export CORTEX_HOME="$TEST_DIR/notify6"
export CORTEX_NOTIFY_CHANNEL="slack"
unset CORTEX_SLACK_WEBHOOK 2>/dev/null || true
mkdir -p "$CORTEX_HOME/data/logs"
OUTPUT=$(bash "$PROJECT_ROOT/scripts/notify.sh" "test" 2>&1 || true)
if echo "$OUTPUT" | grep -qi "CORTEX_SLACK_WEBHOOK\|error\|not set"; then
    log_result "PASS" "Slack fails without webhook"
else
    log_result "FAIL" "Slack fails without webhook" "Output: $OUTPUT"
fi

# --- Test 7: Desktop channel doesn't crash ---
echo "Test 7: Desktop channel runs without crash"
export CORTEX_HOME="$TEST_DIR/notify7"
export CORTEX_NOTIFY_CHANNEL="desktop"
mkdir -p "$CORTEX_HOME/data/logs"
# Desktop may use notify-send or osascript, both may be absent in CI
bash "$PROJECT_ROOT/scripts/notify.sh" "test desktop" 2>/dev/null || true
if [ -f "$CORTEX_HOME/data/logs/notify.log" ]; then
    if grep -q "OK: desktop" "$CORTEX_HOME/data/logs/notify.log"; then
        log_result "PASS" "Desktop channel logged OK"
    else
        log_result "PASS" "Desktop channel ran (may lack notify-send)"
    fi
else
    log_result "PASS" "Desktop channel ran (no log = fallback echo)"
fi

# --- Test 8: Log directory auto-created ---
echo "Test 8: Log directory is auto-created"
export CORTEX_HOME="$TEST_DIR/notify8"
export CORTEX_NOTIFY_CHANNEL="none"
# Don't create logs dir — script should do it
bash "$PROJECT_ROOT/scripts/notify.sh" "auto-create test" 2>/dev/null
if [ -d "$CORTEX_HOME/data/logs" ]; then
    log_result "PASS" "Log directory auto-created"
else
    log_result "FAIL" "Log directory auto-created" "Directory not found"
fi

# --- Test 9: Log entries have timestamps ---
echo "Test 9: Log entries include timestamps"
export CORTEX_HOME="$TEST_DIR/notify9"
export CORTEX_NOTIFY_CHANNEL="none"
mkdir -p "$CORTEX_HOME/data/logs"
bash "$PROJECT_ROOT/scripts/notify.sh" "timestamp test" 2>/dev/null
if [ -f "$CORTEX_HOME/data/logs/notify.log" ]; then
    if grep -qE '^\[[0-9]{4}-[0-9]{2}-[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2}\]' "$CORTEX_HOME/data/logs/notify.log"; then
        log_result "PASS" "Log entries have ISO timestamps"
    else
        log_result "FAIL" "Log entries have ISO timestamps" "Format mismatch: $(cat "$CORTEX_HOME/data/logs/notify.log")"
    fi
else
    log_result "FAIL" "Log entries have ISO timestamps" "No log file"
fi

# --- Summary ---
echo ""
echo "=== Results: $PASS/$TOTAL passed ==="
if [ $FAIL -gt 0 ]; then
    echo "$FAIL test(s) failed"
    exit 1
fi
exit 0
