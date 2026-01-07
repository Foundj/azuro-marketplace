"""Claude-reflect shared utilities.

Modular library for session parsing, pattern detection, and learning extraction.
"""

from .paths import get_queue_path, get_backup_dir, get_claude_dir
from .timestamps import iso_timestamp, backup_timestamp
from .queue import load_queue, save_queue, append_to_queue
from .patterns import (
    detect_patterns,
    create_queue_item,
    EXPLICIT_PATTERNS,
    POSITIVE_PATTERNS,
    CORRECTION_PATTERNS,
)
from .tool_errors import (
    TOOL_ERROR_EXCLUDE_PATTERNS,
    PROJECT_SPECIFIC_ERROR_PATTERNS,
    aggregate_tool_errors,
)
from .session import (
    extract_user_messages,
    extract_tool_rejections,
    extract_tool_errors,
)

__all__ = [
    # Paths
    "get_queue_path",
    "get_backup_dir",
    "get_claude_dir",
    # Timestamps
    "iso_timestamp",
    "backup_timestamp",
    # Queue
    "load_queue",
    "save_queue",
    "append_to_queue",
    # Patterns
    "detect_patterns",
    "create_queue_item",
    "EXPLICIT_PATTERNS",
    "POSITIVE_PATTERNS",
    "CORRECTION_PATTERNS",
    # Tool errors
    "TOOL_ERROR_EXCLUDE_PATTERNS",
    "PROJECT_SPECIFIC_ERROR_PATTERNS",
    "aggregate_tool_errors",
    # Session
    "extract_user_messages",
    "extract_tool_rejections",
    "extract_tool_errors",
]
