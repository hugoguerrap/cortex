#!/usr/bin/env python3
"""
validate_memory_update.py - Validate memory file updates before writing.
Enforces file limits, format rules, and prevents corruption.

Usage:
  python3 validate_memory_update.py <file_path> <proposed_content>
  python3 validate_memory_update.py --check <file_path>

Exit codes:
  0 = valid
  1 = validation error (details on stderr)
"""

import os
import sys
from pathlib import Path

CORTEX_HOME = Path(os.environ.get("CORTEX_HOME", Path.home() / ".claude" / "cortex"))

# File limits and rules
MEMORY_RULES = {
    "context.md": {
        "max_lines": 200,
        "description": "Active priorities and projects",
    },
    "preferences.md": {
        "max_lines": 100,
        "description": "User preferences",
    },
    "watchlist.md": {
        "max_lines": 50,
        "description": "Monitored items",
    },
    "lessons.md": {
        "max_lines": None,  # no limit
        "description": "Technical insights",
    },
    "conversations.md": {
        "max_lines": None,
        "description": "Session summaries",
    },
    "strategy.md": {
        "max_lines": None,
        "description": "Goals and opportunities",
    },
}

VALID_FILES = set(MEMORY_RULES.keys())
MEMORY_DIR = CORTEX_HOME / "memory"


def validate_file_name(file_path: str) -> tuple[bool, str]:
    """Check that the target file is a known memory file."""
    name = Path(file_path).name
    if name not in VALID_FILES:
        return False, f"Unknown memory file: {name}. Valid files: {', '.join(sorted(VALID_FILES))}"
    return True, ""


def validate_content(file_name: str, content: str) -> tuple[bool, str]:
    """Validate proposed content against file rules."""
    rules = MEMORY_RULES.get(file_name, {})
    errors = []

    lines = content.splitlines()
    line_count = len(lines)

    # Check line limit
    max_lines = rules.get("max_lines")
    if max_lines and line_count > max_lines:
        errors.append(f"{file_name}: {line_count} lines exceeds limit of {max_lines}")

    # Check for empty content (likely corruption)
    if line_count == 0 or (line_count == 1 and not lines[0].strip()):
        errors.append(f"{file_name}: Content is empty — refusing to overwrite")

    # Check for potential secrets/tokens
    secret_patterns = [
        "sk-", "ghp_", "gho_", "xoxb-", "xoxp-",
        "AKIA", "-----BEGIN", "token:", "password:",
        "Bearer ", "api_key=", "apikey=",
    ]
    for i, line in enumerate(lines, 1):
        for pattern in secret_patterns:
            if pattern in line:
                errors.append(f"{file_name}:{i}: Possible secret detected (pattern: '{pattern}')")
                break

    if errors:
        return False, "\n".join(errors)
    return True, ""


def check_existing(file_path: str) -> tuple[bool, str]:
    """Check health of an existing memory file."""
    path = Path(file_path)
    if not path.exists():
        return True, f"{path.name}: does not exist yet (OK for new files)"

    content = path.read_text()
    return validate_content(path.name, content)


def main():
    if len(sys.argv) < 2:
        print("Usage: validate_memory_update.py [--check] <file_path> [content]", file=sys.stderr)
        sys.exit(1)

    if sys.argv[1] == "--check":
        if len(sys.argv) < 3:
            print("Usage: validate_memory_update.py --check <file_path>", file=sys.stderr)
            sys.exit(1)
        ok, msg = check_existing(sys.argv[2])
        if not ok:
            print(f"INVALID: {msg}", file=sys.stderr)
            sys.exit(1)
        print(f"OK: {msg}" if msg else "OK")
        sys.exit(0)

    file_path = sys.argv[1]

    # Read content from stdin if not provided as argument
    if len(sys.argv) >= 3:
        content = sys.argv[2]
    else:
        content = sys.stdin.read()

    ok, msg = validate_file_name(file_path)
    if not ok:
        print(f"INVALID: {msg}", file=sys.stderr)
        sys.exit(1)

    file_name = Path(file_path).name
    ok, msg = validate_content(file_name, content)
    if not ok:
        print(f"INVALID: {msg}", file=sys.stderr)
        sys.exit(1)

    print("OK")
    sys.exit(0)


if __name__ == "__main__":
    main()
