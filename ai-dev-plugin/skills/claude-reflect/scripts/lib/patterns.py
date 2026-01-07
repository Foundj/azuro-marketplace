#!/usr/bin/env python3
"""Pattern detection for claude-reflect learning extraction."""

import os
import re
from typing import Dict, Any, Optional, Tuple

from .timestamps import iso_timestamp

# Explicit marker patterns (highest confidence)
EXPLICIT_PATTERNS = [
    (r"remember:", "remember:", 0.90, 120),  # pattern, name, confidence, decay_days
]

# Positive feedback patterns
POSITIVE_PATTERNS = [
    (r"perfect!|exactly right|that's exactly", "perfect", 0.70, 90),
    (r"that's what I wanted|great approach", "great-approach", 0.70, 90),
    (r"keep doing this|love it|excellent|nailed it", "keep-doing", 0.70, 90),
]

# Correction patterns (conservative set to minimize false positives)
# Format: (regex_pattern, pattern_name, is_strong)
CORRECTION_PATTERNS = [
    (r"no[,. ]+use", "no,use", True),
    (r"don't use|do not use", "don't-use", True),
    (r"stop using|never use", "stop/never-use", True),
    (r"that's (wrong|incorrect)|that is (wrong|incorrect)", "that's-wrong", True),
    (r"not right|not correct", "not-right", False),
    (r"^actually[,. ]|[.!?] actually[,. ]", "actually", False),
    (r"I meant|I said", "I-meant/said", True),
    (r"I told you|I already told", "I-told-you", True),
    (r"you (should|need to|must) use", "you-should-use", False),
    (r"use .+ not|not .+, use", "use-X-not-Y", True),
]


def detect_patterns(text: str) -> Tuple[Optional[str], str, float, str, int]:
    """
    Detect patterns in text and return classification.

    Returns:
        Tuple of (type, matched_patterns, confidence, sentiment, decay_days)
        type: "explicit", "positive", "auto", or None
        matched_patterns: Space-separated pattern names
        confidence: 0.0 to 1.0
        sentiment: "correction" or "positive"
        decay_days: Number of days until decay
    """
    # Check for explicit "remember:"
    for pattern, name, confidence, decay in EXPLICIT_PATTERNS:
        if re.search(pattern, text, re.IGNORECASE):
            return ("explicit", name, confidence, "correction", decay)

    # Check for positive patterns
    matched_positive = []
    for pattern, name, confidence, decay in POSITIVE_PATTERNS:
        if re.search(pattern, text, re.IGNORECASE):
            matched_positive.append(name)

    if matched_positive:
        return ("positive", " ".join(matched_positive), 0.70, "positive", 90)

    # Check for correction patterns
    matched_corrections = []
    pattern_count = 0
    has_strong_pattern = False
    has_i_told_you = False

    for pattern, name, is_strong in CORRECTION_PATTERNS:
        if re.search(pattern, text, re.IGNORECASE):
            matched_corrections.append(name)
            pattern_count += 1
            if is_strong:
                has_strong_pattern = True
            if name == "I-told-you":
                has_i_told_you = True

    if matched_corrections:
        # Calculate confidence based on pattern count and type
        if has_i_told_you:
            confidence = 0.85
            decay_days = 120
        elif pattern_count >= 3:
            confidence = 0.85
            decay_days = 120
        elif pattern_count >= 2:
            confidence = 0.75
            decay_days = 90
        else:
            confidence = 0.60
            decay_days = 60

        return (
            "auto",
            " ".join(matched_corrections),
            confidence,
            "correction",
            decay_days,
        )

    return (None, "", 0.0, "correction", 90)


def create_queue_item(
    message: str,
    item_type: str,
    patterns: str,
    confidence: float,
    sentiment: str,
    decay_days: int,
    project: Optional[str] = None,
) -> Dict[str, Any]:
    """Create a properly formatted queue item."""
    return {
        "type": item_type,
        "message": message,
        "timestamp": iso_timestamp(),
        "project": project or os.getcwd(),
        "patterns": patterns,
        "confidence": confidence,
        "sentiment": sentiment,
        "decay_days": decay_days,
    }
