#!/bin/bash
# init_data_dirs.sh - Create required data directories idempotently
# Called by session_start.sh and /setup

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"

mkdir -p "$PROJECT_DIR/data/logs"
mkdir -p "$PROJECT_DIR/data/reports"
mkdir -p "$PROJECT_DIR/data/exports"
mkdir -p "$PROJECT_DIR/memory"
mkdir -p "$PROJECT_DIR/identity"
mkdir -p "$PROJECT_DIR/scripts"
