#!/bin/bash
# system_status.sh - System metrics (cross-platform)
# Usage: ./system_status.sh

set -euo pipefail

echo "=== System Status ==="
echo "Time: $(date)"
echo "Uptime: $(uptime | sed 's/.*up //' | sed 's/,.*//')"
echo ""

# Disk
echo "## Disk Usage"
df -h / | tail -1 | awk '{print "Used: " $3 "/" $2 " (" $5 ")"}'
echo ""

# Memory
echo "## Memory"
if [[ "$OSTYPE" == "darwin"* ]]; then
    vm_stat 2>/dev/null | awk '
    /Pages free/ {free=$3}
    /Pages active/ {active=$3}
    /Pages inactive/ {inactive=$3}
    /Pages wired/ {wired=$3}
    END {
        gsub(/\./,"",free); gsub(/\./,"",active); gsub(/\./,"",inactive); gsub(/\./,"",wired);
        total=(free+active+inactive+wired)*4096/1073741824;
        used=(active+wired)*4096/1073741824;
        printf "Used: %.1f GB / %.1f GB\n", used, total
    }' || echo "N/A"
elif [ -f /proc/meminfo ]; then
    awk '/MemTotal/{total=$2} /MemAvailable/{avail=$2} END{
        used=(total-avail)/1048576; total=total/1048576;
        printf "Used: %.1f GB / %.1f GB\n", used, total
    }' /proc/meminfo
else
    echo "N/A"
fi
echo ""

# Docker (if available)
if command -v docker &>/dev/null && docker info &>/dev/null 2>&1; then
    echo "## Docker Containers"
    RUNNING=$(docker ps -q | wc -l | tr -d ' ')
    echo "Running: $RUNNING"
    if [ "$RUNNING" -gt 0 ]; then
        docker ps --format "- {{.Names}}: {{.Status}}" 2>/dev/null
    fi
else
    echo "## Docker: not running"
fi
