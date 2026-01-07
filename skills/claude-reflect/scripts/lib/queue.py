#!/usr/bin/env python3
"""Queue operations for claude-reflect learnings."""

import json
from typing import List, Dict, Any

from .paths import get_queue_path


def load_queue() -> List[Dict[str, Any]]:
    """Load learnings queue from file."""
    path = get_queue_path()
    if not path.exists():
        return []
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, IOError):
        return []


def save_queue(items: List[Dict[str, Any]]) -> None:
    """Save learnings queue to file."""
    path = get_queue_path()
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(items, indent=2), encoding="utf-8")


def append_to_queue(item: Dict[str, Any]) -> None:
    """Append a single item to the queue."""
    items = load_queue()
    items.append(item)
    save_queue(items)
