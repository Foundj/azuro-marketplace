#!/usr/bin/env python3
"""Path utilities for claude-reflect."""

from pathlib import Path


def get_queue_path() -> Path:
    """Get path to learnings queue file."""
    return Path.home() / ".claude" / "learnings-queue.json"


def get_backup_dir() -> Path:
    """Get path to learnings backup directory."""
    return Path.home() / ".claude" / "learnings-backups"


def get_claude_dir() -> Path:
    """Get path to .claude directory."""
    return Path.home() / ".claude"
