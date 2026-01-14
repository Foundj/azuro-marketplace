#!/bin/bash
#
# spawn-worker.sh - Delegate tasks to sub-agent sessions (ai-dev v4.0)
#
# Usage: spawn-worker.sh <task_id> [options]
#
# Arguments:
#   task_id     - Task ID to delegate (e.g., "1.3")
#
# Options:
#   --dry-run   - Generate handover.md but don't spawn
#   --force     - Ignore depth limit (NOT recommended)
#
# Exit codes:
#   0 - Success
#   1 - Spawn failed
#   2 - Depth limit reached
#   3 - Invalid arguments
#   4 - Task not found

set -uo pipefail

# Initialize Logger
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_CONTEXT="Worker"
source "${SCRIPT_DIR}/logger.sh"

TASKS_FILE="tasks.md"
STATE_FILE="state.json"
TEMPLATES_DIR="${SCRIPT_DIR}/templates"
HANDOVER_FILE="handover.md"

PARSER="${SCRIPT_DIR}/parse-tasks.sh"

TASK_ID=""
DRY_RUN=false
FORCE=false

# Legacy logging functions now use the unified logger
# (Removed local definitions to use the sourced ones)

usage() {
    echo "Usage: spawn-worker.sh <task_id> [--dry-run] [--force]"
    exit 3
}

# Parse arguments
while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run) DRY_RUN=true; shift ;;
        --force) FORCE=true; shift ;;
        -*) echo "Unknown option: $1"; usage ;;
        *) if [[ -z "$TASK_ID" ]]; then TASK_ID="$1"; else usage; fi; shift ;;
    esac
done

if [[ -z "$TASK_ID" ]]; then usage; fi

# 1. Validate environment
# Auto-detect active change if not in CWD
if [[ ! -f "$STATE_FILE" || ! -f "$TASKS_FILE" ]]; then
    ACTIVE_CHANGE=$(find codebox/changes/active -maxdepth 1 -type d ! -name "active" 2>/dev/null | head -1)
    if [[ -n "$ACTIVE_CHANGE" ]]; then
        STATE_FILE="${ACTIVE_CHANGE}/state.json"
        TASKS_FILE="${ACTIVE_CHANGE}/tasks.md"
        HANDOVER_FILE="${ACTIVE_CHANGE}/handover.md"
        log_info "Detected active change at $ACTIVE_CHANGE"
    fi
fi

if [[ ! -f "$TASKS_FILE" ]]; then
    log_error "tasks.md not found at $TASKS_FILE"
    exit 4
fi

if [[ ! -f "$STATE_FILE" ]]; then
    log_error "state.json not found at $STATE_FILE"
    exit 1
fi

# 2. Parse task info
log_info "Parsing task $TASK_ID..."
TASK_JSON=$("$PARSER" "$TASKS_FILE" --task-id "$TASK_ID" --format json 2>/dev/null)
if [[ -z "$TASK_JSON" || "$(echo "$TASK_JSON" | jq '.stats.total')" == "0" ]]; then
    log_error "Task $TASK_ID not found in $TASKS_FILE"
    exit 4
fi

TASK_DESC=$(echo "$TASK_JSON" | jq -r '.tasks[0].description')
VERIFY_CMD=$(echo "$TASK_JSON" | jq -r '.tasks[0].metadata.verify_with // empty')

# 3. Check depth limit
DEPTH=$(jq -r '.workerHierarchy.depth // 0' "$STATE_FILE")
MAX_DEPTH=$(jq -r '.workerConfig.maxDepth // 2' "$STATE_FILE")

if [[ "$DEPTH" -ge "$MAX_DEPTH" ]] && [[ "$FORCE" == "false" ]]; then
    log_error "Max depth reached ($DEPTH/$MAX_DEPTH). Cannot spawn worker."
    exit 2
fi

# 4. Prepare handover.md
log_info "Generating handover context..."
mkdir -p "$TEMPLATES_DIR"
TEMPLATE="${TEMPLATES_DIR}/handover.md"

if [[ ! -f "$TEMPLATE" ]]; then
    # Create default template if missing
    cat > "$TEMPLATE" << 'EOF'
# Handover: Task ${TASK_ID}

## 1. Context
- **Parent Session**: ${PARENT_SESSION_ID}
- **Task ID**: ${TASK_ID}
- **Description**: ${TASK_DESC}
- **Depth**: ${NEXT_DEPTH}

## 2. Instructions
You are a worker agent delegated to complete this specific task.
1. Implement the requested feature.
2. Run verification: `${VERIFY_CMD}`
3. Once verified, mark the task as done in `tasks.md` and output `<promise>DONE</promise>`.

## 3. Constraints
- Stay within the scope of this task.
- Do not modify unrelated files.
EOF
fi

# Fill template
PARENT_SESSION_ID=$(jq -r '.workerHierarchy.sessionId // "parent"' "$STATE_FILE")
NEXT_DEPTH=$((DEPTH + 1))

# Simple substitution (using sed or variable replacement)
sed -e "s/\${TASK_ID}/$TASK_ID/g" \
    -e "s/\${TASK_DESC}/$TASK_DESC/g" \
    -e "s/\${VERIFY_CMD}/$VERIFY_CMD/g" \
    -e "s/\${PARENT_SESSION_ID}/$PARENT_SESSION_ID/g" \
    -e "s/\${NEXT_DEPTH}/$NEXT_DEPTH/g" \
    "$TEMPLATE" > "$HANDOVER_FILE"

# 5. Update state
WORKER_ID="worker-$(date +%s)-$RANDOM"
log_info "Registering worker $WORKER_ID..."

TMP_STATE="${STATE_FILE}.tmp"
jq --arg wid "$WORKER_ID" \
   --arg tid "$TASK_ID" \
   --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
   --arg depth "$NEXT_DEPTH" \
   '.workerSessions += [{
       "workerId": $wid,
       "taskId": $tid,
       "status": "spawning",
       "spawnedAt": $ts
   }] | .workerHierarchy.depth = ($depth | tonumber)' "$STATE_FILE" > "$TMP_STATE"
mv "$TMP_STATE" "$STATE_FILE"

# 6. Spawn (The actual Tool Call)
if [[ "$DRY_RUN" == "true" ]]; then
    log_info "DRY RUN: Handover generated at $HANDOVER_FILE"
    exit 0
fi

log_info "Initiating worker session via Task tool..."
# Note: The actual Tool invocation is handled by the LLM seeing this output
# We output a structured instruction that the Manager agent will act upon.

cat <<EOF

⚠️  ACTION REQUIRED: Spawn Worker Session
Please use the Task tool with the following parameters:
- subagent_type: ai-dev
- description: Worker for Task $TASK_ID
- prompt: I am a worker agent. Please read handover.md and complete the task defined there.

EOF

exit 0
