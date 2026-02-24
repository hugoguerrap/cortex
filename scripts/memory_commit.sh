#!/bin/bash
# memory_commit.sh - Version memory files with git auto-commits
# Usage: memory_commit.sh [commit message]
#
# Initializes a git repo in CORTEX_HOME if none exists,
# then commits any changes to memory/ and identity/ files.
# Called automatically by the Stop hook after memory updates.

set -uo pipefail

CORTEX_HOME="${CORTEX_HOME:-$HOME/.claude/cortex}"
COMMIT_MSG="${1:-Auto-save memory updates}"

# Only version these directories
TRACKED_DIRS=("memory" "identity")

cd "$CORTEX_HOME" || exit 0

# Initialize git repo if needed
if [ ! -d ".git" ]; then
    git init -q
    # Ignore everything except memory and identity
    cat > .gitignore << 'GITIGNORE'
# Track only memory and identity
*
!.gitignore
!memory/
!memory/**
!identity/
!identity/**
GITIGNORE
    git add .gitignore
    for dir in "${TRACKED_DIRS[@]}"; do
        [ -d "$dir" ] && git add "$dir/" 2>/dev/null
    done
    git commit -q -m "Initialize memory versioning" 2>/dev/null || true
fi

# Stage changes in tracked directories
CHANGED=false
for dir in "${TRACKED_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        git add "$dir/" 2>/dev/null
        if ! git diff --cached --quiet -- "$dir/" 2>/dev/null; then
            CHANGED=true
        fi
    fi
done

# Commit if there are changes
if [ "$CHANGED" = true ]; then
    git commit -q -m "$COMMIT_MSG" 2>/dev/null
fi
