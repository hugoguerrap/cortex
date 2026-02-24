#!/usr/bin/env python3
"""Tests for extract_transcripts.py"""

import json
import os
import sys
import tempfile
import unittest
from datetime import datetime, timedelta
from pathlib import Path
from unittest.mock import patch

# Add scripts dir to path
sys.path.insert(0, str(Path(__file__).parent.parent / "scripts"))
import extract_transcripts as et


class TestFindTranscriptFiles(unittest.TestCase):
    """Tests for find_transcript_files()"""

    def setUp(self):
        self.tmpdir = tempfile.mkdtemp()
        self.mock_claude_dir = Path(self.tmpdir) / "projects"
        self.mock_claude_dir.mkdir(parents=True)

    def tearDown(self):
        import shutil
        shutil.rmtree(self.tmpdir)

    @patch.object(et, "CLAUDE_DIR")
    def test_returns_empty_when_no_projects(self, mock_dir):
        mock_dir.__class__ = type(self.mock_claude_dir)
        with patch.object(et, "CLAUDE_DIR", self.mock_claude_dir):
            files = et.find_transcript_files(days=30)
            self.assertEqual(files, [])

    @patch.object(et, "CLAUDE_DIR")
    def test_finds_recent_jsonl_files(self, mock_dir):
        project = self.mock_claude_dir / "my-project"
        project.mkdir()
        transcript = project / "conversation.jsonl"
        transcript.write_text('{"role":"user","content":"hello"}\n')

        with patch.object(et, "CLAUDE_DIR", self.mock_claude_dir):
            files = et.find_transcript_files(days=30)
            self.assertEqual(len(files), 1)
            self.assertEqual(files[0]["project"], "my-project")
            self.assertIn("conversation.jsonl", files[0]["path"])

    @patch.object(et, "CLAUDE_DIR")
    def test_respects_max_files_limit(self, mock_dir):
        project = self.mock_claude_dir / "proj"
        project.mkdir()
        for i in range(10):
            (project / f"conv_{i}.jsonl").write_text(f'{{"role":"user","content":"msg {i}"}}\n')

        with patch.object(et, "CLAUDE_DIR", self.mock_claude_dir):
            files = et.find_transcript_files(days=30, max_files=3)
            self.assertEqual(len(files), 3)

    @patch.object(et, "CLAUDE_DIR")
    def test_filters_by_project_pattern(self, mock_dir):
        for name in ["frontend-app", "backend-api", "docs"]:
            p = self.mock_claude_dir / name
            p.mkdir()
            (p / "conv.jsonl").write_text('{"role":"user","content":"x"}\n')

        with patch.object(et, "CLAUDE_DIR", self.mock_claude_dir):
            files = et.find_transcript_files(days=30, project_pattern="backend")
            self.assertEqual(len(files), 1)
            self.assertEqual(files[0]["project"], "backend-api")

    @patch.object(et, "CLAUDE_DIR")
    def test_sorted_by_modification_time(self, mock_dir):
        project = self.mock_claude_dir / "proj"
        project.mkdir()

        old = project / "old.jsonl"
        old.write_text('{"role":"user","content":"old"}\n')
        old_time = (datetime.now() - timedelta(days=2)).timestamp()
        os.utime(str(old), (old_time, old_time))

        new = project / "new.jsonl"
        new.write_text('{"role":"user","content":"new"}\n')

        with patch.object(et, "CLAUDE_DIR", self.mock_claude_dir):
            files = et.find_transcript_files(days=30)
            self.assertEqual(len(files), 2)
            self.assertIn("new.jsonl", files[0]["path"])
            self.assertIn("old.jsonl", files[1]["path"])


class TestExtractFromTranscript(unittest.TestCase):
    """Tests for extract_from_transcript()"""

    def setUp(self):
        self.tmpdir = tempfile.mkdtemp()

    def tearDown(self):
        import shutil
        shutil.rmtree(self.tmpdir)

    def _write_transcript(self, entries):
        path = Path(self.tmpdir) / "test.jsonl"
        with open(path, "w") as f:
            for entry in entries:
                f.write(json.dumps(entry) + "\n")
        return str(path)

    def test_extracts_user_messages(self):
        path = self._write_transcript([
            {"role": "user", "content": "How do I fix this bug?"},
            {"role": "assistant", "content": "Try this approach..."},
            {"role": "user", "content": "That worked, thanks!"},
        ])
        result = et.extract_from_transcript(path)
        self.assertEqual(result["message_count"], 2)
        self.assertIn("How do I fix this bug?", result["user_messages"])
        self.assertIn("That worked, thanks!", result["user_messages"])

    def test_filters_noise_messages(self):
        path = self._write_transcript([
            {"role": "user", "content": "yes"},
            {"role": "user", "content": "ok"},
            {"role": "user", "content": "y"},
            {"role": "user", "content": "thanks"},
            {"role": "user", "content": "Implement the auth module"},
        ])
        result = et.extract_from_transcript(path)
        self.assertEqual(result["message_count"], 1)
        self.assertEqual(result["user_messages"][0], "Implement the auth module")

    def test_truncates_long_messages(self):
        long_msg = "x" * 1000
        path = self._write_transcript([
            {"role": "user", "content": long_msg},
        ])
        result = et.extract_from_transcript(path)
        self.assertEqual(len(result["user_messages"][0]), 503)  # 500 + "..."
        self.assertTrue(result["user_messages"][0].endswith("..."))

    def test_extracts_tool_usage(self):
        path = self._write_transcript([
            {"role": "assistant", "content": [
                {"type": "tool_use", "name": "Read", "input": {}},
                {"type": "tool_use", "name": "Edit", "input": {}},
                {"type": "tool_use", "name": "Read", "input": {}},
            ]},
        ])
        result = et.extract_from_transcript(path)
        self.assertEqual(result["tool_usage"]["Read"], 2)
        self.assertEqual(result["tool_usage"]["Edit"], 1)

    def test_handles_list_content_blocks(self):
        path = self._write_transcript([
            {"role": "user", "content": [
                {"type": "text", "text": "Deploy to production"},
                {"type": "image", "source": "screenshot.png"},
            ]},
        ])
        result = et.extract_from_transcript(path)
        self.assertEqual(result["message_count"], 1)
        self.assertEqual(result["user_messages"][0], "Deploy to production")

    def test_handles_malformed_jsonl(self):
        path = Path(self.tmpdir) / "bad.jsonl"
        path.write_text('{"role":"user","content":"valid"}\nnot json\n{"broken\n')
        result = et.extract_from_transcript(str(path))
        self.assertEqual(result["message_count"], 1)

    def test_handles_empty_file(self):
        path = Path(self.tmpdir) / "empty.jsonl"
        path.write_text("")
        result = et.extract_from_transcript(str(path))
        self.assertEqual(result["message_count"], 0)
        self.assertEqual(result["user_messages"], [])

    def test_handles_nonexistent_file(self):
        result = et.extract_from_transcript("/nonexistent/file.jsonl")
        self.assertIn("error", result)


class TestNoisePatterns(unittest.TestCase):
    """Tests for the noise filtering regex patterns"""

    def _is_noise(self, msg):
        import re
        return any(re.match(p, msg, re.IGNORECASE) for p in et.NOISE_PATTERNS)

    def test_single_word_confirmations_filtered(self):
        for word in ["y", "n", "yes", "no", "ok", "okay", "sure", "thanks", "thx", "ty", "k", "lgtm"]:
            self.assertTrue(self._is_noise(word), f"'{word}' should be filtered")

    def test_real_messages_not_filtered(self):
        real = [
            "Fix the authentication bug",
            "yes please add error handling too",
            "The okay button is broken",
        ]
        for msg in real:
            self.assertFalse(self._is_noise(msg), f"'{msg}' should NOT be filtered")

    def test_system_reminders_filtered(self):
        self.assertTrue(self._is_noise("<system-reminder>some content"))


if __name__ == "__main__":
    unittest.main()
