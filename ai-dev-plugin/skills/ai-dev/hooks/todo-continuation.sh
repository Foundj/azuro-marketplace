#!/bin/bash

# Todo Continuation Hook for ai-dev
# Type: Stop
# Forces agent to complete all TODOs before stopping
# Works alongside OODA hook but for non-OODA scenarios

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/check-tasks.sh" 2>/dev/null || true

LOG_PREFIX="📋 TODO"

log_info() {
    echo "${LOG_PREFIX}: $1"
}

log_warn() {
    echo "${LOG_PREFIX} ⚠️: $1" >&2
}

# Read hook input from stdin
HOOK_INPUT=$(cat)

# Extract last assistant message
LAST_OUTPUT=$(echo "$HOOK_INPUT" | jq -r '.last_assistant_message // ""' 2>/dev/null || echo "")

# Try to find tasks.md in common locations
TASKS_FILE=""
for loc in "codebox/changes/active/*/tasks.md" "tasks.md" ".claude/tasks.md"; do
    found=$(ls $loc 2>/dev/null | head -1)
    if [[ -n "$found" && -f "$found" ]]; then
        TASKS_FILE="$found"
        break
    fi
done

# If no tasks file found, allow exit
if [[ -z "$TASKS_FILE" ]]; then
    exit 0
fi

# Count tasks
TOTAL=$(grep -cE '^\s*-\s*\[' "$TASKS_FILE" 2>/dev/null || echo 0)
DONE=$(grep -cE '^\s*-\s*\[x\]' "$TASKS_FILE" 2>/dev/null || echo 0)
REMAINING=$((TOTAL - DONE))

# If no tasks or all complete, allow exit
if [[ "$TOTAL" -eq 0 ]] || [[ "$REMAINING" -eq 0 ]]; then
    exit 0
fi

# Check if agent is trying to stop with incomplete tasks
if echo "$LAST_OUTPUT" | grep -qiE '(完成|done|finished|结束|that.s all|已完成|任务完成)'; then
    log_warn "Agent claims done but $REMAINING/$TOTAL tasks remaining"
    
    # Get remaining tasks list
    REMAINING_LIST=$(grep -E '^\s*-\s*\[\s*\]' "$TASKS_FILE" | head -5 | sed 's/^/  /')
    
    jq -n \
      --arg remaining "$REMAINING" \
      --arg total "$TOTAL" \
      --arg tasks "$REMAINING_LIST" \
      '{
        "decision": "block",
        "reason": "⚠️ 还有 \($remaining)/\($total) 个任务未完成:\n\($tasks)\n\n请继续执行剩余任务。",
        "systemMessage": "📋 TODO Continuation: 检测到 \($remaining) 个未完成任务，请继续执行。"
      }'
    exit 0
fi

# Allow exit for other cases
exit 0
