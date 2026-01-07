#!/usr/bin/env python3
"""Session file utilities for claude-reflect."""

import json
import re
from pathlib import Path
from typing import List, Dict, Any

from .tool_errors import TOOL_ERROR_EXCLUDE_PATTERNS, PROJECT_SPECIFIC_ERROR_PATTERNS


def extract_user_messages(
    session_file: Path, corrections_only: bool = False
) -> List[str]:
    """
    Extract user messages from a Claude Code session file (JSONL format).

    Args:
        session_file: Path to the session JSONL file
        corrections_only: If True, only return messages matching correction patterns

    Returns:
        List of user message texts
    """
    if not session_file.exists():
        return []

    messages = []

    try:
        with open(session_file, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue

                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    continue

                # Filter: type=user, not isMeta
                if entry.get("type") != "user":
                    continue
                if entry.get("isMeta"):
                    continue

                # Extract text from content array
                content = entry.get("message", {}).get("content", [])
                if isinstance(content, list):
                    for item in content:
                        if isinstance(item, dict) and item.get("type") == "text":
                            text = item.get("text", "")
                            if text:
                                # Apply filters (same as bash script)
                                if _should_include_message(text):
                                    messages.append(text)
    except IOError:
        return []

    if corrections_only:
        # Filter for correction patterns
        correction_pattern = (
            r"(no,? use|don't use|stop using|never use|that's wrong|that's incorrect|"
            r"not right|not correct|actually[,. ]|I meant|I said|I told you|"
            r"I already told|you should use|you need to use|use .+ not|not .+, use|remember:)"
        )
        messages = [
            m for m in messages if re.search(correction_pattern, m, re.IGNORECASE)
        ]

    return messages


def _should_include_message(text: str) -> bool:
    """Check if a message should be included (apply filters from bash script)."""
    # Skip empty lines
    if not text.strip():
        return False

    # Skip lines starting with certain patterns
    skip_patterns = [
        r"^<",  # XML tags
        r"^\[",  # Brackets
        r"^\{",  # JSON
        r"tool_result",
        r"tool_use_id",
        r"<command-",
        r"This session is being continued",
        r"^Analysis:",
        r"^\*\*",  # Bold text
        r"^   -",  # Indented lists
    ]

    for pattern in skip_patterns:
        if re.search(pattern, text):
            return False

    return True


def extract_tool_rejections(session_file: Path) -> List[str]:
    """
    Extract user corrections from tool rejections in session files.

    Args:
        session_file: Path to the session JSONL file

    Returns:
        List of user correction texts from tool rejections
    """
    if not session_file.exists():
        return []

    rejections = []

    try:
        with open(session_file, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue

                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    continue

                # Must be a user entry
                if entry.get("type") != "user":
                    continue

                # Get message.content array
                content = entry.get("message", {}).get("content", [])
                if not isinstance(content, list):
                    continue

                # Look for tool_result items in content array
                for item in content:
                    if not isinstance(item, dict):
                        continue

                    if item.get("type") != "tool_result":
                        continue

                    if not item.get("is_error"):
                        continue

                    tool_content = item.get("content", "")
                    if not isinstance(tool_content, str):
                        continue

                    if "The user doesn't want to proceed" not in tool_content:
                        continue

                    # Extract text after "the user said:"
                    lower_content = tool_content.lower()
                    if "the user said:" in lower_content:
                        idx = lower_content.find("the user said:")
                        after_marker = tool_content[idx + len("the user said:") :]
                        lines = after_marker.strip().split("\n")
                        if lines and lines[0].strip():
                            rejections.append(lines[0].strip())

    except IOError:
        return []

    return rejections


def extract_tool_errors(
    session_file: Path, project_specific_only: bool = True
) -> List[Dict[str, Any]]:
    """
    Extract tool execution errors from session files.

    Args:
        session_file: Path to the session JSONL file
        project_specific_only: If True, only return errors matching project-specific patterns

    Returns:
        List of dicts with {error_type, content, project, timestamp, suggested_guideline}
    """
    if not session_file.exists():
        return []

    errors = []

    try:
        with open(session_file, "r", encoding="utf-8") as f:
            for line in f:
                line = line.strip()
                if not line:
                    continue

                try:
                    entry = json.loads(line)
                except json.JSONDecodeError:
                    continue

                if entry.get("type") != "user":
                    continue

                content = entry.get("message", {}).get("content", [])
                if not isinstance(content, list):
                    continue

                for item in content:
                    if not isinstance(item, dict):
                        continue

                    if item.get("type") != "tool_result":
                        continue

                    if not item.get("is_error"):
                        continue

                    tool_content = item.get("content", "")
                    if not isinstance(tool_content, str):
                        continue

                    # Skip if matches exclude patterns
                    should_exclude = False
                    for exclude_pattern in TOOL_ERROR_EXCLUDE_PATTERNS:
                        if re.search(exclude_pattern, tool_content, re.IGNORECASE):
                            should_exclude = True
                            break

                    if should_exclude:
                        continue

                    # If project_specific_only, check for matching patterns
                    error_type = "unknown"
                    suggested_guideline = None

                    for etype, pattern, guideline in PROJECT_SPECIFIC_ERROR_PATTERNS:
                        if re.search(pattern, tool_content, re.IGNORECASE):
                            error_type = etype
                            suggested_guideline = guideline
                            break

                    if project_specific_only and error_type == "unknown":
                        continue

                    errors.append(
                        {
                            "error_type": error_type,
                            "content": tool_content[:500],
                            "project": str(session_file.parent.name),
                            "timestamp": entry.get("timestamp", ""),
                            "suggested_guideline": suggested_guideline,
                        }
                    )

    except IOError:
        return []

    return errors
