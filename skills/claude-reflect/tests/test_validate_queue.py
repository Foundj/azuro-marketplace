#!/usr/bin/env python3
"""Tests for validate_queue_items function.

Run with: python -m pytest tests/test_validate_queue.py -v
"""

import sys
import unittest
from pathlib import Path
from unittest.mock import patch

# Add scripts directory to path
sys.path.insert(0, str(Path(__file__).parent.parent / "scripts"))

from lib.semantic_detector import validate_queue_items


class TestValidateQueueItems(unittest.TestCase):
    """Tests for validate_queue_items function."""

    def _mock_semantic_result(self, is_learning, confidence=0.8):
        """Create a mock semantic analysis result."""
        return {
            "is_learning": is_learning,
            "type": "correction" if is_learning else None,
            "confidence": confidence,
            "reasoning": "Mock reasoning",
            "extracted_learning": "Mock learning" if is_learning else None,
        }

    @patch("lib.semantic_detector.semantic_analyze")
    def test_filters_non_learnings(self, mock_analyze):
        """Test that non-learnings are filtered out."""
        mock_analyze.side_effect = [
            self._mock_semantic_result(True, 0.8),
            self._mock_semantic_result(False, 0.2),
            self._mock_semantic_result(True, 0.9),
        ]

        items = [
            {"message": "no, use Python", "confidence": 0.6},
            {"message": "Hello world", "confidence": 0.6},
            {"message": "remember: use async", "confidence": 0.9},
        ]

        result = validate_queue_items(items)

        self.assertEqual(len(result), 2)
        self.assertEqual(result[0]["message"], "no, use Python")
        self.assertEqual(result[1]["message"], "remember: use async")

    @patch("lib.semantic_detector.semantic_analyze")
    def test_updates_confidence(self, mock_analyze):
        """Test that confidence is updated from semantic analysis."""
        mock_analyze.return_value = self._mock_semantic_result(True, 0.95)

        items = [{"message": "test", "confidence": 0.6}]

        result = validate_queue_items(items)

        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]["confidence"], 0.95)

    @patch("lib.semantic_detector.semantic_analyze")
    def test_keeps_original_if_semantic_higher_confidence(self, mock_analyze):
        """Test that original confidence is kept if higher than semantic."""
        mock_analyze.return_value = self._mock_semantic_result(True, 0.5)

        items = [{"message": "test", "confidence": 0.8}]

        result = validate_queue_items(items)

        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]["confidence"], 0.8)

    @patch("lib.semantic_detector.semantic_analyze")
    def test_adds_semantic_fields(self, mock_analyze):
        """Test that semantic analysis fields are added to items."""
        mock_analyze.return_value = {
            "is_learning": True,
            "type": "explicit",
            "confidence": 0.9,
            "reasoning": "Explicit remember marker",
            "extracted_learning": "Always use pytest",
        }

        items = [{"message": "remember: use pytest", "confidence": 0.9}]

        result = validate_queue_items(items)

        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]["semantic_type"], "explicit")
        self.assertEqual(result[0]["semantic_confidence"], 0.9)
        self.assertIn("semantic_reasoning", result[0])
        self.assertEqual(result[0]["extracted_learning"], "Always use pytest")

    @patch("lib.semantic_detector.semantic_analyze")
    def test_fallback_on_semantic_failure(self, mock_analyze):
        """Test that items are kept if semantic analysis fails."""
        mock_analyze.return_value = None

        items = [{"message": "test", "confidence": 0.7}]

        result = validate_queue_items(items)

        self.assertEqual(len(result), 1)
        self.assertEqual(result[0]["confidence"], 0.7)

    @patch("lib.semantic_detector.semantic_analyze")
    def test_skips_empty_messages(self, mock_analyze):
        """Test that items with empty messages are skipped."""
        items = [
            {"message": "", "confidence": 0.6},
            {"message": "valid message", "confidence": 0.7},
        ]

        mock_analyze.return_value = self._mock_semantic_result(True, 0.8)

        result = validate_queue_items(items)

        self.assertEqual(mock_analyze.call_count, 1)

    def test_empty_items_list(self):
        """Test with empty items list."""
        result = validate_queue_items([])
        self.assertEqual(result, [])


if __name__ == "__main__":
    unittest.main()
