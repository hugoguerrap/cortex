#!/bin/bash
# init_data_dirs.sh - Create Cortex data directories idempotently
# All data lives in ~/.claude/cortex/, not in the user's project

set -euo pipefail

CORTEX_HOME="${CORTEX_HOME:-$HOME/.claude/cortex}"

mkdir -p "$CORTEX_HOME/data/logs"
mkdir -p "$CORTEX_HOME/data/reports"
mkdir -p "$CORTEX_HOME/data/exports"
mkdir -p "$CORTEX_HOME/memory"
mkdir -p "$CORTEX_HOME/identity"
mkdir -p "$CORTEX_HOME/scripts"
