#!/bin/bash
# notify.sh - Pluggable notification script
# Reads PAIOS_NOTIFY_CHANNEL to determine delivery method.
#
# Usage: notify.sh "message"
#
# Supported channels:
#   telegram  - requires PAIOS_TELEGRAM_TOKEN + PAIOS_TELEGRAM_CHAT_ID
#   discord   - requires PAIOS_DISCORD_WEBHOOK
#   slack     - requires PAIOS_SLACK_WEBHOOK
#   desktop   - uses native OS notifications (no deps)
#   none      - silent (default)

set -euo pipefail

MESSAGE="${1:?Error: message required as first argument}"
CHANNEL="${PAIOS_NOTIFY_CHANNEL:-none}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOG_DIR="$PROJECT_DIR/data/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/notify.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# === TELEGRAM ===
send_telegram() {
    local token="${PAIOS_TELEGRAM_TOKEN:?Error: PAIOS_TELEGRAM_TOKEN not set}"
    local chat_id="${PAIOS_TELEGRAM_CHAT_ID:?Error: PAIOS_TELEGRAM_CHAT_ID not set}"
    local api_url="https://api.telegram.org/bot${token}"

    # Split long messages (Telegram limit: 4096 chars)
    if [ ${#MESSAGE} -le 4096 ]; then
        local response
        response=$(curl -s -X POST "${api_url}/sendMessage" \
            -H "Content-Type: application/json" \
            -d "$(jq -n --arg cid "$chat_id" --arg txt "$MESSAGE" \
                '{chat_id: $cid, text: $txt, parse_mode: "Markdown"}')")

        local ok
        ok=$(echo "$response" | jq -r '.ok')
        if [ "$ok" = "true" ]; then
            log "OK: telegram (${#MESSAGE} chars)"
        else
            # Retry without Markdown
            curl -s -X POST "${api_url}/sendMessage" \
                -H "Content-Type: application/json" \
                -d "$(jq -n --arg cid "$chat_id" --arg txt "$MESSAGE" \
                    '{chat_id: $cid, text: $txt}')" > /dev/null
            log "OK: telegram plain (${#MESSAGE} chars)"
        fi
    else
        local part=1
        local total=$(( (${#MESSAGE} + 3999) / 4000 ))
        local remaining="$MESSAGE"
        while [ -n "$remaining" ]; do
            local chunk="${remaining:0:4000}"
            remaining="${remaining:4000}"
            curl -s -X POST "${api_url}/sendMessage" \
                -H "Content-Type: application/json" \
                -d "$(jq -n --arg cid "$chat_id" --arg txt "[$part/$total] $chunk" \
                    '{chat_id: $cid, text: $txt}')" > /dev/null
            part=$((part + 1))
            sleep 0.5
        done
        log "OK: telegram ($total parts)"
    fi
}

# === DISCORD ===
send_discord() {
    local webhook="${PAIOS_DISCORD_WEBHOOK:?Error: PAIOS_DISCORD_WEBHOOK not set}"

    # Discord limit: 2000 chars
    if [ ${#MESSAGE} -le 2000 ]; then
        curl -s -X POST "$webhook" \
            -H "Content-Type: application/json" \
            -d "$(jq -n --arg content "$MESSAGE" '{content: $content}')" > /dev/null
        log "OK: discord (${#MESSAGE} chars)"
    else
        local remaining="$MESSAGE"
        while [ -n "$remaining" ]; do
            local chunk="${remaining:0:2000}"
            remaining="${remaining:2000}"
            curl -s -X POST "$webhook" \
                -H "Content-Type: application/json" \
                -d "$(jq -n --arg content "$chunk" '{content: $content}')" > /dev/null
            sleep 0.5
        done
        log "OK: discord (split)"
    fi
}

# === SLACK ===
send_slack() {
    local webhook="${PAIOS_SLACK_WEBHOOK:?Error: PAIOS_SLACK_WEBHOOK not set}"

    curl -s -X POST "$webhook" \
        -H "Content-Type: application/json" \
        -d "$(jq -n --arg text "$MESSAGE" '{text: $text}')" > /dev/null
    log "OK: slack (${#MESSAGE} chars)"
}

# === DESKTOP ===
send_desktop() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        osascript -e "display notification \"$MESSAGE\" with title \"Personal AI OS\""
    elif command -v notify-send &>/dev/null; then
        notify-send "Personal AI OS" "$MESSAGE"
    else
        echo "[NOTIFICATION] $MESSAGE"
    fi
    log "OK: desktop"
}

# === DISPATCH ===
case "$CHANNEL" in
    telegram)
        send_telegram
        ;;
    discord)
        send_discord
        ;;
    slack)
        send_slack
        ;;
    desktop)
        send_desktop
        ;;
    none)
        log "SKIP: channel=none"
        ;;
    *)
        log "ERROR: Unknown channel '$CHANNEL'"
        echo "Error: Unknown notification channel '$CHANNEL'" >&2
        echo "Supported: telegram, discord, slack, desktop, none" >&2
        exit 1
        ;;
esac
