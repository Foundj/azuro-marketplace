#!/usr/bin/env python3
"""Tests for semantic_analyze function.

Run with: python -m pytest tests/test_semantic_analyze.py -v
"""

import json
import subprocess
import sys
import unittest
from pathlib import Path
from unittest.mock import patch, MagicMock

# Add scripts directory to path
sys.path.insert(0, str(Path(__file__).parent.parent / "scripts"))

from lib.semantic_detector import semantic_analyze


class TestSemanticAnalyze(unittest.TestCase):
    """Tests for semantic_analyze function."""

    def _mock_claude_response(self, response_dict):
        """Create a mock subprocess result with Claude-like JSON output."""
        mock_result = MagicMock()
        mock_result.returncode = 0
        mock_result.stdout = json.dumps(response_dict)
        mock_result.stderr = ""
        return mock_result

    @patch("lib.semantic_detector.subprocess.run")
    def test_successful_correction_detection(self, mock_run):
        """Test successful detection of a correction."""
        mock_run.return_value = self._mock_claude_response(
            {
                "is_learning": True,
                "type": "correction",
                "confidence": 0.85,
                "reasoning": "User is correcting the AI to use a different approach",
                "extracted_learning": "Use Python instead of JavaScript for this task",
            }
        )

        result = semantic_analyze("no, use Python instead of JavaScript")

        self.assertIsNotNone(result)
        self.assertTrue(result["is_learning"])
        self.assertEqual(result["type"], "correction")
        self.assertEqual(result["confidence"], 0.85)
        self.assertIn("Python", result["extracted_learning"])

    @patch("lib.semantic_detector.subprocess.run")
    def test_successful_positive_detection(self, mock_run):
        """Test successful detection of positive feedback."""
        mock_run.return_value = self._mock_claude_response(
            {
                "is_learning": True,
                "type": "positive",
                "confidence": 0.75,
                "reasoning": "User affirming the approach",
                "extracted_learning": "Continue using async/await pattern",
            }
        )

        result = semantic_analyze("perfect! that's exactly what I wanted")

        self.assertIsNotNone(result)
        self.assertTrue(result["is_learning"])
        self.assertEqual(result["type"], "positive")

    @patch("lib.semantic_detector.subprocess.run")
    def test_successful_explicit_detection(self, mock_run):
        """Test successful detection of explicit remember marker."""
        mock_run.return_value = self._mock_claude_response(
            {
                "is_learning": True,
                "type": "explicit",
                "confidence": 0.95,
                "reasoning": "User explicitly asking to remember",
                "extracted_learning": "Always use gpt-5.1 for reasoning tasks",
            }
        )

        result = semantic_analyze("remember: always use gpt-5.1 for reasoning tasks")

        self.assertIsNotNone(result)
        self.assertTrue(result["is_learning"])
        self.assertEqual(result["type"], "explicit")
        self.assertGreaterEqual(result["confidence"], 0.90)

    @patch("lib.semantic_detector.subprocess.run")
    def test_not_a_learning(self, mock_run):
        """Test detection of non-learning message."""
        mock_run.return_value = self._mock_claude_response(
            {
                "is_learning": False,
                "type": None,
                "confidence": 0.1,
                "reasoning": "This is just a greeting, not a reusable learning",
                "extracted_learning": None,
            }
        )

        result = semantic_analyze("Hello, how are you?")

        self.assertIsNotNone(result)
        self.assertFalse(result["is_learning"])
        self.assertIsNone(result["type"])

    @patch("lib.semantic_detector.subprocess.run")
    def test_multi_language_spanish(self, mock_run):
        """Test detection works for Spanish messages."""
        mock_run.return_value = self._mock_claude_response(
            {
                "is_learning": True,
                "type": "correction",
                "confidence": 0.80,
                "reasoning": "User is correcting in Spanish - asking to use Python",
                "extracted_learning": "Use Python instead of JavaScript",
            }
        )

        result = semantic_analyze("no, usa Python en vez de JavaScript")

        self.assertIsNotNone(result)
        self.assertTrue(result["is_learning"])
        self.assertEqual(result["type"], "correction")

    @patch("lib.semantic_detector.subprocess.run")
    def test_multi_language_french(self, mock_run):
        """Test detection works for French messages."""
        mock_run.return_value = self._mock_claude_response(
            {
                "is_learning": True,
                "type": "correction",
                "confidence": 0.78,
                "reasoning": "User correcting in French",
                "extracted_learning": "Use async functions",
            }
        )

        result = semantic_analyze("non, utilise les fonctions async")

        self.assertIsNotNone(result)
        self.assertTrue(result["is_learning"])

    @patch("lib.semantic_detector.subprocess.run")
    def test_multi_language_russian(self, mock_run):
        """Test detection works for Russian messages."""
        mock_run.return_value = self._mock_claude_response(
            {
                "is_learning": True,
                "type": "correction",
                "confidence": 0.82,
                "reasoning": "User correcting in Russian - don't use global variables",
                "extracted_learning": "Avoid global variables",
            }
        )

        result = semantic_analyze("нет, не используй глобальные переменные")

        self.assertIsNotNone(result)
        self.assertTrue(result["is_learning"])

    @patch("lib.semantic_detector.subprocess.run")
    def test_timeout_returns_none(self, mock_run):
        """Test that timeout returns None for graceful fallback."""
        mock_run.side_effect = subprocess.TimeoutExpired(cmd="claude", timeout=30)

        result = semantic_analyze("some text")

        self.assertIsNone(result)

    @patch("lib.semantic_detector.subprocess.run")
    def test_claude_not_installed(self, mock_run):
        """Test graceful handling when Claude CLI is not installed."""
        mock_run.side_effect = FileNotFoundError("claude not found")

        result = semantic_analyze("some text")

        self.assertIsNone(result)

    @patch("lib.semantic_detector.subprocess.run")
    def test_claude_cli_error(self, mock_run):
        """Test handling of Claude CLI returning non-zero exit code."""
        mock_result = MagicMock()
        mock_result.returncode = 1
        mock_result.stdout = ""
        mock_result.stderr = "Error: API key not found"
        mock_run.return_value = mock_result

        result = semantic_analyze("some text")

        self.assertIsNone(result)

    @patch("lib.semantic_detector.subprocess.run")
    def test_empty_output(self, mock_run):
        """Test handling of empty output from Claude."""
        mock_result = MagicMock()
        mock_result.returncode = 0
        mock_result.stdout = ""
        mock_result.stderr = ""
        mock_run.return_value = mock_result

        result = semantic_analyze("some text")

        self.assertIsNone(result)

    @patch("lib.semantic_detector.subprocess.run")
    def test_invalid_json_output(self, mock_run):
        """Test handling of invalid JSON in output."""
        mock_result = MagicMock()
        mock_result.returncode = 0
        mock_result.stdout = "This is not JSON at all"
        mock_result.stderr = ""
        mock_run.return_value = mock_result

        result = semantic_analyze("some text")

        self.assertIsNone(result)

    @patch("lib.semantic_detector.subprocess.run")
    def test_wrapped_json_response(self, mock_run):
        """Test handling of JSON wrapped in 'result' field."""
        mock_result = MagicMock()
        mock_result.returncode = 0
        mock_result.stdout = json.dumps(
            {
                "result": {
                    "is_learning": True,
                    "type": "correction",
                    "confidence": 0.80,
                    "reasoning": "User correction",
                    "extracted_learning": "Use pytest",
                }
            }
        )
        mock_result.stderr = ""
        mock_run.return_value = mock_result

        result = semantic_analyze("no, use pytest not unittest")

        self.assertIsNotNone(result)
        self.assertTrue(result["is_learning"])

    @patch("lib.semantic_detector.subprocess.run")
    def test_json_with_markdown_wrapper(self, mock_run):
        """Test extraction of JSON from markdown code block."""
        mock_result = MagicMock()
        mock_result.returncode = 0
        mock_result.stdout = """Here is the analysis:
```json
{
  "is_learning": true,
  "type": "correction",
  "confidence": 0.75,
  "reasoning": "User wants different approach",
  "extracted_learning": "Use type hints"
}
```
"""
        mock_result.stderr = ""
        mock_run.return_value = mock_result

        result = semantic_analyze("you should use type hints")

        self.assertIsNotNone(result)
        self.assertTrue(result["is_learning"])

    def test_empty_text_input(self):
        """Test that empty text returns None without calling Claude."""
        result = semantic_analyze("")
        self.assertIsNone(result)

        result = semantic_analyze("   ")
        self.assertIsNone(result)

    @patch("lib.semantic_detector.subprocess.run")
    def test_custom_timeout(self, mock_run):
        """Test that custom timeout is passed to subprocess."""
        mock_run.return_value = self._mock_claude_response(
            {
                "is_learning": False,
                "type": None,
                "confidence": 0.1,
                "reasoning": "Not a learning",
                "extracted_learning": None,
            }
        )

        semantic_analyze("test", timeout=60)

        mock_run.assert_called_once()
        call_kwargs = mock_run.call_args[1]
        self.assertEqual(call_kwargs["timeout"], 60)

    @patch("lib.semantic_detector.subprocess.run")
    def test_custom_model(self, mock_run):
        """Test that custom model is passed to Claude CLI."""
        mock_run.return_value = self._mock_claude_response(
            {
                "is_learning": False,
                "type": None,
                "confidence": 0.1,
                "reasoning": "Not a learning",
                "extracted_learning": None,
            }
        )

        semantic_analyze("test", model="haiku")

        mock_run.assert_called_once()
        call_args = mock_run.call_args[0][0]
        self.assertIn("--model", call_args)
        self.assertIn("haiku", call_args)


if __name__ == "__main__":
    unittest.main()
