#!/bin/bash

# TODO Continuation Enforcer Hook
# Based on Superpowers "Sisyphus rolls the boulder" pattern
# Prevents session exit when there are uncompleted tasks
# This is the Iron Law: Work is not done until <promise>DONE</promise>

set -euo pipefail

LOG_PREFIX="🪨 TODO"

log_info() {
    echo "${LOG_PREFIX}: $1"
}

# ============================================================================
# Read Hook Input
# ============================================================================

HOOK_INPUT=$(cat)

# Get transcript path
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // empty')

if [[ -z "$TRANSCRIPT_PATH" || ! -f "$TRANSCRIPT_PATH" ]]; then
    # No transcript - allow exit
    exit 0
fi

# ============================================================================
# Check for Completion Promise
# ============================================================================

# Extract last assistant message
LAST_LINE=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" 2>/dev/null | tail -1 || echo "")

if [[ -z "$LAST_LINE" ]]; then
    # No assistant messages - allow exit
    exit 0
fi

LAST_OUTPUT=$(echo "$LAST_LINE" | jq -r '
  .message.content |
  map(select(.type == "text")) |
  map(.text) |
  join("\n")
' 2>/dev/null || echo "")

# Check for explicit completion signal
if echo "$LAST_OUTPUT" | grep -q '<promise>DONE</promise>'; then
    log_info "Completion promise found - allowing exit"
    exit 0
fi

# ============================================================================
# Check TodoList Status (Claude Code built-in)
# ============================================================================

# Try to find tasks from various sources
PENDING_TASKS=0
PENDING_LIST=""

# Check 1: Claude Code TodoList (if accessible via state)
# The Task tool stores tasks in ~/.claude/tasks/
TASKS_DIR="${HOME}/.claude/tasks"
if [[ -d "$TASKS_DIR" ]]; then
    # Find all task files and count pending
    for task_file in "$TASKS_DIR"/*/*.json 2>/dev/null; do
        if [[ -f "$task_file" ]]; then
            status=$(jq -r '.status // "pending"' "$task_file" 2>/dev/null || echo "unknown")
            if [[ "$status" == "pending" || "$status" == "in_progress" ]]; then
                subject=$(jq -r '.subject // "Unknown task"' "$task_file" 2>/dev/null || echo "Unknown")
                PENDING_TASKS=$((PENDING_TASKS + 1))
                PENDING_LIST="${PENDING_LIST}\n  - ${subject}"
            fi
        fi
    done
fi

# Check 2: codebox tasks.md (project-specific)
CODEBOX_TASKS="codebox/changes/active"
if [[ -d "$CODEBOX_TASKS" ]]; then
    ACTIVE_CHANGE=$(find "$CODEBOX_TASKS" -maxdepth 1 -type d ! -name "active" 2>/dev/null | head -1)
    if [[ -n "$ACTIVE_CHANGE" && -f "${ACTIVE_CHANGE}/tasks.md" ]]; then
        TASKS_FILE="${ACTIVE_CHANGE}/tasks.md"
        UNCHECKED=$(grep -cE '^\s*-\s*\[\s*\]' "$TASKS_FILE" 2>/dev/null || echo 0)
        if [[ "$UNCHECKED" -gt 0 ]]; then
            PENDING_TASKS=$((PENDING_TASKS + UNCHECKED))
            TASK_PREVIEW=$(grep -E '^\s*-\s*\[\s*\]' "$TASKS_FILE" | head -3 | sed 's/^\s*-\s*\[\s*\]/  -/')
            PENDING_LIST="${PENDING_LIST}\n${TASK_PREVIEW}"
        fi
    fi
fi

# ============================================================================
# Enforce Continuation
# ============================================================================

if [[ "$PENDING_TASKS" -eq 0 ]]; then
    # No pending tasks detected - allow exit
    # But warn if no completion promise was given
    if ! echo "$LAST_OUTPUT" | grep -qiE '(完成|done|finished|complete)'; then
        log_info "No pending tasks found, allowing exit"
    fi
    exit 0
fi

# ============================================================================
# Block Exit - Sisyphus Mode
# ============================================================================

log_info "⚠️  Detected $PENDING_TASKS pending tasks - blocking exit"

# Build continuation message
CONTINUATION_MSG=$(cat <<EOF
╔═══════════════════════════════════════════════════════════════╗
║                    🪨 SISYPHUS MODE                            ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║   Work is NOT done until <promise>DONE</promise>              ║
║                                                               ║
║   Pending tasks detected: $PENDING_TASKS
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝

Remaining tasks:
$(echo -e "$PENDING_LIST")

Please continue executing the remaining tasks.
When ALL tasks are complete, output: <promise>DONE</promise>
EOF
)

# Output block decision
jq -n \
  --arg reason "$CONTINUATION_MSG" \
  '{
    "decision": "block",
    "reason": $reason,
    "systemMessage": "🪨 TODO Continuation Enforcer: Blocking exit until all tasks complete"
  }'

exit 0
