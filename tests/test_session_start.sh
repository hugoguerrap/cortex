#!/bin/bash
# Tests for session_start.sh
# Usage: bash tests/test_session_start.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PASS=0
FAIL=0
TOTAL=0

# Setup isolated test environment
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

echo "=== Tests: session_start.sh ==="
echo ""

# --- Test 1: First-time setup (no memory dir) ---
echo "Test 1: First-time setup prompt when no memory directory exists"
export CORTEX_HOME="$TEST_DIR/empty_cortex"
mkdir -p "$CORTEX_HOME"
OUTPUT=$(bash "$PROJECT_ROOT/hooks/session_start.sh" 2>/dev/null)
if echo "$OUTPUT" | grep -q "setup"; then
    log_result "PASS" "Shows setup prompt when memory dir missing"
else
    log_result "FAIL" "Shows setup prompt when memory dir missing" "Got: $OUTPUT"
fi

# --- Test 2: JSON output when jq available ---
echo "Test 2: JSON output format with jq"
export CORTEX_HOME="$TEST_DIR/empty_cortex2"
mkdir -p "$CORTEX_HOME"
if command -v jq &>/dev/null; then
    OUTPUT=$(bash "$PROJECT_ROOT/hooks/session_start.sh" 2>/dev/null)
    if echo "$OUTPUT" | jq -e '.hookSpecificOutput.hookEventName' &>/dev/null; then
        log_result "PASS" "Outputs valid JSON with hookSpecificOutput"
    else
        log_result "FAIL" "Outputs valid JSON with hookSpecificOutput" "Invalid JSON: $OUTPUT"
    fi
else
    log_result "PASS" "Skipped (jq not installed)"
fi

# --- Test 3: Identity injection ---
echo "Test 3: Injects identity files"
export CORTEX_HOME="$TEST_DIR/with_identity"
mkdir -p "$CORTEX_HOME/memory" "$CORTEX_HOME/identity" "$CORTEX_HOME/data/logs"
echo "# Test Context" > "$CORTEX_HOME/memory/context.md"
echo "# Test Soul" > "$CORTEX_HOME/identity/SOUL.md"
echo "# Test User" > "$CORTEX_HOME/identity/USER.md"
OUTPUT=$(bash "$PROJECT_ROOT/hooks/session_start.sh" 2>/dev/null)
if echo "$OUTPUT" | grep -q "Test Soul"; then
    log_result "PASS" "SOUL.md content injected"
else
    log_result "FAIL" "SOUL.md content injected" "SOUL.md not found in output"
fi
if echo "$OUTPUT" | grep -q "Test User"; then
    log_result "PASS" "USER.md content injected"
else
    log_result "FAIL" "USER.md content injected" "USER.md not found in output"
fi

# --- Test 4: Memory files injection ---
echo "Test 4: Injects memory files"
export CORTEX_HOME="$TEST_DIR/with_memory"
mkdir -p "$CORTEX_HOME/memory" "$CORTEX_HOME/identity" "$CORTEX_HOME/data/logs"
echo "Priority: ship v3" > "$CORTEX_HOME/memory/context.md"
echo "Goal: grow revenue" > "$CORTEX_HOME/memory/strategy.md"
echo "Lesson: always test" > "$CORTEX_HOME/memory/lessons.md"
echo "Session: did stuff" > "$CORTEX_HOME/memory/conversations.md"
OUTPUT=$(bash "$PROJECT_ROOT/hooks/session_start.sh" 2>/dev/null)
for keyword in "ship v3" "grow revenue" "always test" "did stuff"; do
    if echo "$OUTPUT" | grep -q "$keyword"; then
        log_result "PASS" "Memory content '$keyword' injected"
    else
        log_result "FAIL" "Memory content '$keyword' injected" "Not found in output"
    fi
done

# --- Test 5: Session gap calculation ---
echo "Test 5: Session gap detection"
export CORTEX_HOME="$TEST_DIR/with_gap"
mkdir -p "$CORTEX_HOME/memory" "$CORTEX_HOME/data/logs"
echo "# context" > "$CORTEX_HOME/memory/context.md"
# Write a session end 3 days ago
THREE_DAYS_AGO=$(date -d "3 days ago" '+%Y-%m-%d %H:%M:%S' 2>/dev/null || date -v-3d '+%Y-%m-%d %H:%M:%S' 2>/dev/null)
if [ -n "$THREE_DAYS_AGO" ]; then
    echo "[$THREE_DAYS_AGO] SESSION_END" > "$CORTEX_HOME/data/logs/sessions.log"
    OUTPUT=$(bash "$PROJECT_ROOT/hooks/session_start.sh" 2>/dev/null)
    if echo "$OUTPUT" | grep -q "hours ago"; then
        log_result "PASS" "Session gap hours calculated"
    else
        log_result "FAIL" "Session gap hours calculated" "Gap info not found"
    fi
    if echo "$OUTPUT" | grep -q "2 days"; then
        log_result "PASS" "Stale session warning shown (>48h)"
    else
        log_result "FAIL" "Stale session warning shown (>48h)" "Warning not found"
    fi
else
    log_result "PASS" "Skipped (date arithmetic not available)"
    log_result "PASS" "Skipped (date arithmetic not available)"
fi

# --- Test 6: Session start logged ---
echo "Test 6: Session start is logged"
export CORTEX_HOME="$TEST_DIR/logging"
mkdir -p "$CORTEX_HOME/memory" "$CORTEX_HOME/data/logs"
echo "# context" > "$CORTEX_HOME/memory/context.md"
bash "$PROJECT_ROOT/hooks/session_start.sh" >/dev/null 2>&1
if [ -f "$CORTEX_HOME/data/logs/sessions.log" ]; then
    if grep -q "SESSION_START" "$CORTEX_HOME/data/logs/sessions.log"; then
        log_result "PASS" "SESSION_START logged to sessions.log"
    else
        log_result "FAIL" "SESSION_START logged to sessions.log" "No SESSION_START entry"
    fi
else
    log_result "FAIL" "SESSION_START logged to sessions.log" "sessions.log not created"
fi

# --- Test 7: Cron failure detection ---
echo "Test 7: Cron failure detection"
export CORTEX_HOME="$TEST_DIR/cron_fail"
mkdir -p "$CORTEX_HOME/memory" "$CORTEX_HOME/data/logs"
echo "# context" > "$CORTEX_HOME/memory/context.md"
echo "exit code: 1" > "$CORTEX_HOME/data/logs/briefing_20260224.log"
touch "$CORTEX_HOME/data/logs/briefing_20260224.log"
OUTPUT=$(bash "$PROJECT_ROOT/hooks/session_start.sh" 2>/dev/null)
if echo "$OUTPUT" | grep -q "Cron Health\|briefing.*failed"; then
    log_result "PASS" "Cron failure detected and reported"
else
    log_result "FAIL" "Cron failure detected and reported" "Cron health section not found"
fi

# --- Test 8: Missing optional files don't crash ---
echo "Test 8: Graceful handling of missing optional files"
export CORTEX_HOME="$TEST_DIR/minimal"
mkdir -p "$CORTEX_HOME/memory" "$CORTEX_HOME/data/logs"
echo "# context" > "$CORTEX_HOME/memory/context.md"
# No identity files, no strategy, no lessons, no conversations
OUTPUT=$(bash "$PROJECT_ROOT/hooks/session_start.sh" 2>/dev/null)
EXIT_CODE=$?
if [ $EXIT_CODE -eq 0 ]; then
    log_result "PASS" "Exits cleanly with minimal files"
else
    log_result "FAIL" "Exits cleanly with minimal files" "Exit code: $EXIT_CODE"
fi

# --- Summary ---
echo ""
echo "=== Results: $PASS/$TOTAL passed ==="
if [ $FAIL -gt 0 ]; then
    echo "$FAIL test(s) failed"
    exit 1
fi
exit 0
