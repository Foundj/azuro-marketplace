#!/usr/bin/env python3
"""Tests for helper functions in semantic_detector.

Run with: python -m pytest tests/test_semantic_helpers.py -v
"""

import sys
import unittest
from pathlib import Path

# Add scripts directory to path
sys.path.insert(0, str(Path(__file__).parent.parent / "scripts"))

from lib.semantic_detector import (
    _extract_json_from_text,
    _validate_response,
    ANALYSIS_PROMPT,
)


class TestExtractJsonFromText(unittest.TestCase):
    """Tests for _extract_json_from_text helper."""

    def test_extract_simple_json(self):
        """Test extraction of simple JSON object."""
        text = '{"is_learning": true, "confidence": 0.8}'
        result = _extract_json_from_text(text)
        self.assertIsNotNone(result)
        self.assertTrue(result["is_learning"])

    def test_extract_json_with_prefix(self):
        """Test extraction when JSON has prefix text."""
        text = 'Here is the result: {"is_learning": true}'
        result = _extract_json_from_text(text)
        self.assertIsNotNone(result)
        self.assertTrue(result["is_learning"])

    def test_extract_json_with_suffix(self):
        """Test extraction when JSON has suffix text."""
        text = '{"is_learning": false} and some more text'
        result = _extract_json_from_text(text)
        self.assertIsNotNone(result)
        self.assertFalse(result["is_learning"])

    def test_extract_nested_json(self):
        """Test extraction of nested JSON object."""
        text = 'Result: {"data": {"is_learning": true}, "meta": {}}'
        result = _extract_json_from_text(text)
        self.assertIsNotNone(result)
        self.assertIn("data", result)

    def test_no_json_found(self):
        """Test when no JSON is in text."""
        text = "This is just plain text without any JSON"
        result = _extract_json_from_text(text)
        self.assertIsNone(result)

    def test_invalid_json(self):
        """Test when JSON is malformed."""
        text = '{"is_learning": true, missing_quote: value}'
        result = _extract_json_from_text(text)
        self.assertIsNone(result)


class TestValidateResponse(unittest.TestCase):
    """Tests for _validate_response helper."""

    def test_valid_learning_response(self):
        """Test validation of complete valid response."""
        content = {
            "is_learning": True,
            "type": "correction",
            "confidence": 0.85,
            "reasoning": "User correction",
            "extracted_learning": "Use Python",
        }
        result = _validate_response(content)
        self.assertIsNotNone(result)
        self.assertTrue(result["is_learning"])
        self.assertEqual(result["type"], "correction")
        self.assertEqual(result["confidence"], 0.85)

    def test_missing_is_learning_field(self):
        """Test that missing is_learning field returns None."""
        content = {
            "type": "correction",
            "confidence": 0.85,
        }
        result = _validate_response(content)
        self.assertIsNone(result)

    def test_string_boolean_true(self):
        """Test normalization of string 'true' to boolean."""
        content = {
            "is_learning": "true",
            "type": "correction",
            "confidence": 0.8,
        }
        result = _validate_response(content)
        self.assertIsNotNone(result)
        self.assertTrue(result["is_learning"])

    def test_string_boolean_false(self):
        """Test normalization of string 'false' to boolean."""
        content = {
            "is_learning": "false",
            "type": None,
            "confidence": 0.1,
        }
        result = _validate_response(content)
        self.assertIsNotNone(result)
        self.assertFalse(result["is_learning"])

    def test_confidence_clamping_high(self):
        """Test that confidence > 1.0 is clamped to 1.0."""
        content = {
            "is_learning": True,
            "type": "correction",
            "confidence": 1.5,
        }
        result = _validate_response(content)
        self.assertEqual(result["confidence"], 1.0)

    def test_confidence_clamping_low(self):
        """Test that confidence < 0.0 is clamped to 0.0."""
        content = {
            "is_learning": True,
            "type": "correction",
            "confidence": -0.5,
        }
        result = _validate_response(content)
        self.assertEqual(result["confidence"], 0.0)

    def test_invalid_type_normalized(self):
        """Test that invalid type is normalized to None."""
        content = {
            "is_learning": True,
            "type": "invalid_type",
            "confidence": 0.8,
        }
        result = _validate_response(content)
        self.assertIsNone(result["type"])

    def test_non_dict_input(self):
        """Test that non-dict input returns None."""
        result = _validate_response("not a dict")
        self.assertIsNone(result)

        result = _validate_response(["list", "items"])
        self.assertIsNone(result)

    def test_extracted_learning_only_when_is_learning(self):
        """Test that extracted_learning is None when is_learning is False."""
        content = {
            "is_learning": False,
            "type": "correction",
            "confidence": 0.1,
            "extracted_learning": "This should be ignored",
        }
        result = _validate_response(content)
        self.assertIsNone(result["type"])
        self.assertIsNone(result["extracted_learning"])


class TestAnalysisPrompt(unittest.TestCase):
    """Tests for the analysis prompt template."""

    def test_prompt_contains_key_instructions(self):
        """Test that prompt contains essential instructions."""
        self.assertIn("is_learning", ANALYSIS_PROMPT)
        self.assertIn("correction", ANALYSIS_PROMPT)
        self.assertIn("positive", ANALYSIS_PROMPT)
        self.assertIn("explicit", ANALYSIS_PROMPT)
        self.assertIn("confidence", ANALYSIS_PROMPT)
        self.assertIn("ANY language", ANALYSIS_PROMPT)

    def test_prompt_format_string(self):
        """Test that prompt can be formatted with text."""
        formatted = ANALYSIS_PROMPT.format(text="test message")
        self.assertIn("test message", formatted)


if __name__ == "__main__":
    unittest.main()
