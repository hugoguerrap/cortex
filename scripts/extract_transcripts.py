#!/usr/bin/env python3
"""
extract_transcripts.py - Extract user messages from Claude Code conversation transcripts
Zero LLM cost. Pre-filters content before Claude analyzes it.

Scans ~/.claude/projects/ for JSONL transcript files and extracts:
- User messages (what the user says/asks)
- Tool usage patterns (what tools the AI uses)
- Project names and working directories
- Recurring topics and themes

Usage:
  python3 extract_transcripts.py [--days N] [--max-files N] [--project PATTERN]

Output: JSON to stdout with extracted data ready for Claude to analyze.
"""

import json
import os
import re
import sys
from collections import Counter
from datetime import datetime, timedelta
from pathlib import Path


CLAUDE_DIR = Path.home() / ".claude" / "projects"

# Skip these in user messages (not useful for learning)
NOISE_PATTERNS = [
    r"^(y|n|yes|no|ok|okay|sure|thanks|thx|ty|k|lgtm)$",
    r"^/$",  # bare slash commands
    r"^<system-reminder>",
]


def find_transcript_files(days=30, max_files=50, project_pattern=None):
    """Find recent JSONL transcript files across all projects."""
    if not CLAUDE_DIR.exists():
        print(json.dumps({"error": f"Claude projects dir not found: {CLAUDE_DIR}"}))
        sys.exit(1)

    cutoff = datetime.now() - timedelta(days=days)
    files = []

    for project_dir in CLAUDE_DIR.iterdir():
        if not project_dir.is_dir():
            continue

        # Optional project filter
        if project_pattern and project_pattern.lower() not in project_dir.name.lower():
            continue

        for jsonl_file in project_dir.glob("*.jsonl"):
            try:
                mtime = datetime.fromtimestamp(jsonl_file.stat().st_mtime)
                if mtime >= cutoff:
                    size = jsonl_file.stat().st_size
                    files.append({
                        "path": str(jsonl_file),
                        "project": project_dir.name,
                        "modified": mtime.isoformat(),
                        "size": size,
                    })
            except Exception:
                continue

    # Sort by most recent, limit count
    files.sort(key=lambda f: f["modified"], reverse=True)
    return files[:max_files]


def extract_from_transcript(filepath):
    """Extract useful data from a single JSONL transcript."""
    user_messages = []
    tool_usage = Counter()
    topics = []
    working_dir = None

    try:
        with open(filepath, "r") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue
                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    continue

                role = entry.get("role", "")

                # Extract user messages
                if role == "user":
                    content = entry.get("content", "")
                    if isinstance(content, str):
                        msg = content.strip()
                        # Filter noise
                        if msg and not any(re.match(p, msg, re.IGNORECASE) for p in NOISE_PATTERNS):
                            # Truncate very long messages
                            if len(msg) > 500:
                                msg = msg[:500] + "..."
                            user_messages.append(msg)
                    elif isinstance(content, list):
                        for block in content:
                            if isinstance(block, dict) and block.get("type") == "text":
                                msg = block.get("text", "").strip()
                                if msg and not any(re.match(p, msg, re.IGNORECASE) for p in NOISE_PATTERNS):
                                    if len(msg) > 500:
                                        msg = msg[:500] + "..."
                                    user_messages.append(msg)

                # Extract tool usage from assistant messages
                elif role == "assistant":
                    content = entry.get("content", "")
                    if isinstance(content, list):
                        for block in content:
                            if isinstance(block, dict) and block.get("type") == "tool_use":
                                tool_name = block.get("name", "unknown")
                                tool_usage[tool_name] += 1

    except Exception as e:
        return {"error": str(e)}

    return {
        "user_messages": user_messages,
        "tool_usage": dict(tool_usage),
        "message_count": len(user_messages),
    }


def main():
    import argparse

    parser = argparse.ArgumentParser(description="Extract Claude Code transcripts")
    parser.add_argument("--days", type=int, default=30, help="Look back N days (default: 30)")
    parser.add_argument("--max-files", type=int, default=50, help="Max transcript files (default: 50)")
    parser.add_argument("--project", type=str, default=None, help="Filter by project name pattern")
    parser.add_argument("--summary-only", action="store_true", help="Only output stats, not full messages")
    args = parser.parse_args()

    files = find_transcript_files(
        days=args.days,
        max_files=args.max_files,
        project_pattern=args.project,
    )

    if not files:
        print(json.dumps({"error": "No transcript files found", "searched": str(CLAUDE_DIR)}))
        sys.exit(0)

    results = {
        "scan_date": datetime.now().isoformat(),
        "files_scanned": len(files),
        "projects": list(set(f["project"] for f in files)),
        "transcripts": [],
    }

    all_user_messages = []
    total_tool_usage = Counter()

    for file_info in files:
        extracted = extract_from_transcript(file_info["path"])
        if "error" in extracted:
            continue

        all_user_messages.extend(extracted["user_messages"])
        total_tool_usage.update(extracted["tool_usage"])

        transcript_entry = {
            "project": file_info["project"],
            "modified": file_info["modified"],
            "message_count": extracted["message_count"],
        }

        if not args.summary_only:
            # Include a sample of user messages (not all, to keep output manageable)
            transcript_entry["sample_messages"] = extracted["user_messages"][:20]

        results["transcripts"].append(transcript_entry)

    # Global stats
    results["stats"] = {
        "total_user_messages": len(all_user_messages),
        "total_projects": len(results["projects"]),
        "top_tools": dict(total_tool_usage.most_common(15)),
    }

    # If not summary-only, include a representative sample of messages across all projects
    if not args.summary_only:
        # Take up to 100 messages spread across all transcripts
        step = max(1, len(all_user_messages) // 100)
        results["representative_messages"] = all_user_messages[::step][:100]

    print(json.dumps(results, indent=2, ensure_ascii=False))


if __name__ == "__main__":
    main()
