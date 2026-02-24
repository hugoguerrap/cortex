#!/usr/bin/env python3
"""Tests for validate_memory_update.py"""

import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).parent.parent / "scripts"))
import validate_memory_update as vm


class TestValidateFileName(unittest.TestCase):
    """Tests for validate_file_name()"""

    def test_valid_memory_files(self):
        for name in ["context.md", "preferences.md", "watchlist.md",
                      "lessons.md", "conversations.md", "strategy.md"]:
            ok, msg = vm.validate_file_name(name)
            self.assertTrue(ok, f"{name} should be valid")

    def test_rejects_unknown_file(self):
        ok, msg = vm.validate_file_name("secrets.md")
        self.assertFalse(ok)
        self.assertIn("Unknown memory file", msg)

    def test_accepts_full_path(self):
        ok, msg = vm.validate_file_name("/home/user/.claude/cortex/memory/context.md")
        self.assertTrue(ok)

    def test_rejects_non_memory_file(self):
        ok, msg = vm.validate_file_name("README.md")
        self.assertFalse(ok)


class TestValidateContent(unittest.TestCase):
    """Tests for validate_content()"""

    def test_valid_content_within_limits(self):
        content = "# Context\n- Project A: in progress\n- Project B: planning\n"
        ok, msg = vm.validate_content("context.md", content)
        self.assertTrue(ok)

    def test_rejects_exceeding_line_limit(self):
        content = "\n".join([f"- Item {i}" for i in range(250)])
        ok, msg = vm.validate_content("context.md", content)
        self.assertFalse(ok)
        self.assertIn("exceeds limit", msg)

    def test_allows_unlimited_files(self):
        content = "\n".join([f"- Lesson {i}" for i in range(500)])
        ok, msg = vm.validate_content("lessons.md", content)
        self.assertTrue(ok)

    def test_rejects_empty_content(self):
        ok, msg = vm.validate_content("context.md", "")
        self.assertFalse(ok)
        self.assertIn("empty", msg)

    def test_rejects_whitespace_only(self):
        ok, msg = vm.validate_content("context.md", "   ")
        self.assertFalse(ok)
        self.assertIn("empty", msg)

    def test_detects_api_keys(self):
        content = "# Config\napi_key=sk-abc123xyz\n"
        ok, msg = vm.validate_content("context.md", content)
        self.assertFalse(ok)
        self.assertIn("secret", msg.lower())

    def test_detects_github_tokens(self):
        content = "# Auth\ntoken: ghp_xxxxxxxxxxxxxxxxxxxx\n"
        ok, msg = vm.validate_content("strategy.md", content)
        self.assertFalse(ok)
        self.assertIn("secret", msg.lower())

    def test_detects_bearer_tokens(self):
        content = "Authorization: Bearer eyJhbGciOiJIUzI1NiJ9\n"
        ok, msg = vm.validate_content("context.md", content)
        self.assertFalse(ok)

    def test_detects_private_keys(self):
        content = "-----BEGIN RSA PRIVATE KEY-----\nMIIE...\n"
        ok, msg = vm.validate_content("lessons.md", content)
        self.assertFalse(ok)

    def test_watchlist_line_limit(self):
        content = "\n".join([f"- Watch {i}" for i in range(60)])
        ok, msg = vm.validate_content("watchlist.md", content)
        self.assertFalse(ok)
        self.assertIn("50", msg)

    def test_preferences_line_limit(self):
        content = "\n".join([f"- Pref {i}" for i in range(110)])
        ok, msg = vm.validate_content("preferences.md", content)
        self.assertFalse(ok)
        self.assertIn("100", msg)


class TestCheckExisting(unittest.TestCase):
    """Tests for check_existing()"""

    def test_nonexistent_file_is_ok(self):
        ok, msg = vm.check_existing("/tmp/does_not_exist_12345.md")
        self.assertTrue(ok)

    def test_valid_existing_file(self):
        with tempfile.NamedTemporaryFile(mode="w", suffix=".md", prefix="context",
                                          delete=False, dir="/tmp") as f:
            f.write("# Context\n- Active project\n")
            path = f.name
        try:
            # Rename to match a valid memory file name
            valid_path = Path(path).parent / "context.md"
            os.rename(path, str(valid_path))
            ok, msg = vm.check_existing(str(valid_path))
            self.assertTrue(ok)
        finally:
            valid_path.unlink(missing_ok=True)


if __name__ == "__main__":
    unittest.main()
