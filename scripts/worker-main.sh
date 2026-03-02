#!/bin/bash
set -euo pipefail
#
# worker-main.sh - Worker session lifecycle management (ai-dev v4.0)
#
# Usage: worker-main.sh [options]
#
# Options:
#   --init      Initialize worker environment and sync state
#   --status    Show current worker status
#   --complete  Finalize task and signal parent
#   --fail      Log failure and signal parent
#

set -uo pipefail

# Initialize Logger
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_CONTEXT="Worker-Core"
source "${SCRIPT_DIR}/logger.sh"

STATE_FILE="state.json"
HANDOVER_FILE="handover.md"
TASKS_FILE="tasks.md"

# Auto-detect active change if not in CWD
if [[ ! -f "$STATE_FILE" || ! -f "$TASKS_FILE" || ! -f "$HANDOVER_FILE" ]]; then
    ACTIVE_CHANGE=$(find .agent/changes/active -maxdepth 1 -type d ! -name "active" 2>/dev/null | head -1)
    if [[ -n "$ACTIVE_CHANGE" ]]; then
        STATE_FILE="${ACTIVE_CHANGE}/state.json"
        TASKS_FILE="${ACTIVE_CHANGE}/tasks.md"
        HANDOVER_FILE="${ACTIVE_CHANGE}/handover.md"
        log_info "Detected active change at $ACTIVE_CHANGE"
    fi
fi

init_worker() {
    log_info "Initializing worker session..."

    if [[ ! -f "$HANDOVER_FILE" ]]; then
        log_error "handover.md not found at $HANDOVER_FILE. Are you in a worker session?"
        exit 1
    fi

    # Extract task info from handover.md
    TASK_ID=$(grep "Task ID" -A 1 "$HANDOVER_FILE" | tail -n 1 | tr -d ' ')

    if [[ -z "$TASK_ID" ]]; then
        log_error "Could not determine Task ID from handover.md"
        exit 1
    fi

    log_info "Synchronizing state for Task $TASK_ID..."

    # Ensure state matches current worker role
    if [[ -f "$STATE_FILE" ]]; then
        # Update current task in OODA state
        TMP_STATE="${STATE_FILE}.tmp"
        jq --arg tid "$TASK_ID" '.ooda.currentTask = $tid' "$STATE_FILE" > "$TMP_STATE"
        mv "$TMP_STATE" "$STATE_FILE"
    fi

    log_info "Initialization complete. Ready to work on Task $TASK_ID."
}

complete_task() {
    TASK_ID=$(jq -r '.ooda.currentTask // empty' "$STATE_FILE")
    if [[ -z "$TASK_ID" ]]; then
        log_error "Current task not found in state.json"
        exit 1
    fi

    log_info "Marking task $TASK_ID as completed..."

    # 1. Update tasks.md
    sed -i '' "s/- \[ \] $TASK_ID/- [x] $TASK_ID/" "$TASKS_FILE" 2>/dev/null || \
    sed -i "s/- \[ \] $TASK_ID/- [x] $TASK_ID/" "$TASKS_FILE"

    # 2. Update state.json
    TMP_STATE="${STATE_FILE}.tmp"
    jq --arg tid "$TASK_ID" \
       '.workerSessions |= map(if .taskId == $tid then .status = "completed" else . end)' \
       "$STATE_FILE" > "$TMP_STATE"
    mv "$TMP_STATE" "$STATE_FILE"

    log_info "Task $TASK_ID finalized. Sending signal to parent..."
    echo "<promise>DONE</promise>"
}

fail_task() {
    TASK_ID=$(jq -r '.ooda.currentTask // empty' "$STATE_FILE")
    log_error "Worker failed on task $TASK_ID"

    # Update state
    TMP_STATE="${STATE_FILE}.tmp"
    jq --arg tid "$TASK_ID" \
       '.workerSessions |= map(if .taskId == $tid then .status = "failed" else . end)' \
       "$STATE_FILE" > "$TMP_STATE"
    mv "$TMP_STATE" "$STATE_FILE"

    echo "Worker failed. Please check errors.md for details."
}

# Main routing
case "${1:-}" in
    --init) init_worker ;;
    --complete) complete_task ;;
    --fail) fail_task ;;
    --status)
        log_info "Status for $(jq -r '.ooda.currentTask' "$STATE_FILE")"
        ;;
    *)
        echo "Usage: worker-main.sh [--init|--complete|--fail|--status]"
        exit 1
        ;;
esac
