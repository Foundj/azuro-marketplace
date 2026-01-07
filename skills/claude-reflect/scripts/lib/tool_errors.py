#!/usr/bin/env python3
"""Tool error patterns and aggregation for claude-reflect."""

import re
from collections import Counter
from typing import List, Dict, Any

# EXCLUDE: Claude Code guardrails AND global Claude behavior (not project-specific)
TOOL_ERROR_EXCLUDE_PATTERNS = [
    # Claude Code guardrails - system enforcing its rules
    r"File has not been read yet",
    r"exceeds maximum allowed tokens",
    r"InputValidationError",
    r"not valid JSON",
    r"The user doesn't want to proceed",  # User rejections handled separately
    # Global Claude behavior issues - not project-specific
    r"unexpected EOF while looking for matching",  # Bash quoting
    r"EISDIR|illegal operation on a directory",  # File vs dir confusion
    r"syntax error.*eval",  # Bash syntax errors
]

# PROJECT-SPECIFIC error patterns that reveal env/config/structure issues
# Format: (error_type, regex_pattern, suggested_guideline_template)
PROJECT_SPECIFIC_ERROR_PATTERNS = [
    # Connection/service errors - often reveal env/config issues
    (
        "connection_refused",
        r"Connection refused|ECONNREFUSED|connect ECONNREFUSED",
        "Check .env for service URLs - don't assume localhost",
    ),
    (
        "env_undefined",
        r"(\w+_URL|DATABASE_URL|API_KEY|SECRET).*undefined|not set|is not defined",
        "Load .env file before accessing environment variables",
    ),
    # Database-specific errors
    (
        "supabase_error",
        r"supabase|Supabase|SUPABASE",
        "Check SUPABASE_URL and SUPABASE_KEY in .env",
    ),
    (
        "postgres_error",
        r"postgres|PostgreSQL|PGHOST|:5432|password authentication failed",
        "Check DATABASE_URL in .env for PostgreSQL connection",
    ),
    (
        "redis_error",
        r"redis|REDIS|:6379",
        "Check REDIS_URL in .env for Redis connection",
    ),
    # Path/module errors - reveal project structure
    (
        "module_not_found",
        r"ModuleNotFoundError|Cannot find module|No module named",
        "Check import paths - verify project structure",
    ),
    (
        "venv_not_found",
        r"venv.*No such file|activate: No such file|\.venv.*not found",
        "Check virtual environment location",
    ),
    # Port/service conflicts
    (
        "port_in_use",
        r"address already in use|EADDRINUSE|port.*already.*use",
        "Check if service is already running on this port",
    ),
]


def aggregate_tool_errors(
    errors: List[Dict[str, Any]], min_occurrences: int = 2
) -> List[Dict[str, Any]]:
    """
    Group errors by type and return those with multiple occurrences.

    Only repeated errors are valuable for CLAUDE.md - one-off errors are noise.

    Args:
        errors: List of error dicts from extract_tool_errors()
        min_occurrences: Minimum times an error type must occur

    Returns:
        List of aggregated errors with {error_type, count, suggested_guideline,
        confidence, sample_errors}
    """
    # Count by error type
    type_counts = Counter(e["error_type"] for e in errors)

    # Group errors by type
    errors_by_type: Dict[str, List[Dict]] = {}
    for error in errors:
        etype = error["error_type"]
        if etype not in errors_by_type:
            errors_by_type[etype] = []
        errors_by_type[etype].append(error)

    # Build aggregated results for types meeting threshold
    aggregated = []
    for error_type, count in type_counts.items():
        if count < min_occurrences:
            continue

        samples = errors_by_type[error_type][:3]
        suggested_guideline = samples[0].get("suggested_guideline") if samples else None

        # Higher confidence for more occurrences
        if count >= 5:
            confidence = 0.90
        elif count >= 3:
            confidence = 0.85
        else:
            confidence = 0.70

        aggregated.append(
            {
                "error_type": error_type,
                "count": count,
                "suggested_guideline": suggested_guideline,
                "confidence": confidence,
                "decay_days": 180,
                "sample_errors": [s["content"][:200] for s in samples],
            }
        )

    # Sort by count descending
    aggregated.sort(key=lambda x: x["count"], reverse=True)

    return aggregated
