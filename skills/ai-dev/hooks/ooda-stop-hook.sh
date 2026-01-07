#!/bin/bash

# OODA Stop Hook for ai-dev
# Based on ralph-wiggum stop-hook.sh pattern
# Prevents session exit during Phase 4 (Implementation)
# Feeds Claude's output back as input for autonomous OODA loop
# Enhanced with smart completion detection and TODO continuation

set -euo pipefail

# ============================================================================
# Load Libraries
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/check-completion.sh" 2>/dev/null || true
source "$SCRIPT_DIR/lib/check-tasks.sh" 2>/dev/null || true

# ============================================================================
# Configuration
# ============================================================================

CODEBOX_DIR="codebox"
CHANGES_DIR="${CODEBOX_DIR}/changes/active"
COMPLETION_PROMISE="DONE"
MAX_ITERATIONS=50
LOG_PREFIX="🔄 OODA"

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    echo "${LOG_PREFIX}: $1"
}

log_warn() {
    echo "${LOG_PREFIX} ⚠️: $1" >&2
}

log_error() {
    echo "${LOG_PREFIX} ❌: $1" >&2
}

cleanup_and_exit() {
    local state_file="$1"
    if [[ -f "$state_file" ]]; then
        # Update state to mark OODA complete
        local tmp_file="${state_file}.tmp.$$"
        jq '.ooda.active = false | .ooda.completedAt = now' "$state_file" > "$tmp_file" 2>/dev/null || true
        mv "$tmp_file" "$state_file" 2>/dev/null || true
    fi
    exit 0
}

# ============================================================================
# Main Logic
# ============================================================================

# Read hook input from stdin
HOOK_INPUT=$(cat)

# Find active change directory
ACTIVE_CHANGE=$(find "$CHANGES_DIR" -maxdepth 1 -type d ! -name "active" 2>/dev/null | head -1)

if [[ -z "$ACTIVE_CHANGE" || ! -d "$ACTIVE_CHANGE" ]]; then
    # No active change - allow exit
    exit 0
fi

STATE_FILE="${ACTIVE_CHANGE}/state.json"
TASKS_FILE="${ACTIVE_CHANGE}/tasks.md"

if [[ ! -f "$STATE_FILE" ]]; then
    # No state file - allow exit
    exit 0
fi

# Read state
STATE=$(cat "$STATE_FILE")

# Check if OODA is active
OODA_ACTIVE=$(echo "$STATE" | jq -r '.ooda.active // false')
if [[ "$OODA_ACTIVE" != "true" ]]; then
    # OODA not active - allow exit
    exit 0
fi

# Check current phase
CURRENT_PHASE=$(echo "$STATE" | jq -r '.currentPhase // 0')
if [[ "$CURRENT_PHASE" != "4" ]]; then
    # Not in implementation phase - allow exit
    log_info "Not in Phase 4 (current: $CURRENT_PHASE), allowing exit"
    exit 0
fi

# Get iteration count
ITERATION=$(echo "$STATE" | jq -r '.ooda.iteration // 0')
MAX_ITER=$(echo "$STATE" | jq -r '.ooda.maxIterations // 50')

# Validate iteration
if [[ ! "$ITERATION" =~ ^[0-9]+$ ]]; then
    log_error "Invalid iteration value: $ITERATION"
    cleanup_and_exit "$STATE_FILE"
fi

# Check max iterations
if [[ "$MAX_ITER" -gt 0 ]] && [[ "$ITERATION" -ge "$MAX_ITER" ]]; then
    log_info "Max iterations ($MAX_ITER) reached"
    cleanup_and_exit "$STATE_FILE"
fi

# Get transcript path from hook input
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // empty')

if [[ -z "$TRANSCRIPT_PATH" || ! -f "$TRANSCRIPT_PATH" ]]; then
    log_warn "Transcript not found: $TRANSCRIPT_PATH"
    cleanup_and_exit "$STATE_FILE"
fi

# Extract last assistant message from transcript (JSONL format)
if ! grep -q '"role":"assistant"' "$TRANSCRIPT_PATH"; then
    log_warn "No assistant messages in transcript"
    cleanup_and_exit "$STATE_FILE"
fi

LAST_LINE=$(grep '"role":"assistant"' "$TRANSCRIPT_PATH" | tail -1)
if [[ -z "$LAST_LINE" ]]; then
    log_warn "Failed to extract last assistant message"
    cleanup_and_exit "$STATE_FILE"
fi

# Parse JSON to get text content
LAST_OUTPUT=$(echo "$LAST_LINE" | jq -r '
  .message.content |
  map(select(.type == "text")) |
  map(.text) |
  join("\n")
' 2>/dev/null || echo "")

if [[ -z "$LAST_OUTPUT" ]]; then
    log_warn "No text content in assistant message"
    cleanup_and_exit "$STATE_FILE"
fi

# Check for completion promise
# Extract text from <promise> tags
PROMISE_TEXT=$(echo "$LAST_OUTPUT" | perl -0777 -pe 's/.*?<promise>(.*?)<\/promise>.*/$1/s; s/^\s+|\s+$//g; s/\s+/ /g' 2>/dev/null || echo "")

if [[ -n "$PROMISE_TEXT" ]] && [[ "$PROMISE_TEXT" == "$COMPLETION_PROMISE" ]]; then
    log_info "Completion promise detected: <promise>$COMPLETION_PROMISE</promise>"
    
    # Update state to mark implementation complete
    TMP_FILE="${STATE_FILE}.tmp.$$"
    jq '.ooda.active = false | 
        .ooda.completedAt = (now | tostring) |
        .implementationComplete = true |
        .phaseHistory += [{"phase": 4, "completedAt": (now | tostring), "oodaIterations": .ooda.iteration}]' \
        "$STATE_FILE" > "$TMP_FILE"
    mv "$TMP_FILE" "$STATE_FILE"
    
    exit 0
fi

# ============================================================================
# Smart Completion Detection (Enhanced)
# ============================================================================

# Check task completion status
if [[ -f "$TASKS_FILE" ]]; then
    TOTAL_TASKS=$(grep -cE '^\s*-\s*\[' "$TASKS_FILE" 2>/dev/null || echo 0)
    DONE_TASKS=$(grep -cE '^\s*-\s*\[x\]' "$TASKS_FILE" 2>/dev/null || echo 0)
    REMAINING_TASKS=$((TOTAL_TASKS - DONE_TASKS))
    
    # If all tasks are checked and build passes, allow completion
    if [[ "$REMAINING_TASKS" -eq 0 ]] && [[ "$TOTAL_TASKS" -gt 0 ]]; then
        log_info "All tasks completed ($DONE_TASKS/$TOTAL_TASKS)"
        
        # Verify build and tests
        if npm test --silent 2>/dev/null && npm run build --silent 2>/dev/null; then
            log_info "Build and tests pass - marking complete"
            
            TMP_FILE="${STATE_FILE}.tmp.$$"
            jq '.ooda.active = false | 
                .ooda.completedAt = (now | tostring) |
                .implementationComplete = true' \
                "$STATE_FILE" > "$TMP_FILE"
            mv "$TMP_FILE" "$STATE_FILE"
            
            exit 0
        else
            log_warn "Tasks complete but build/tests failing"
        fi
    fi
    
    # Detect false completion claims
    if echo "$LAST_OUTPUT" | grep -qiE '(完成|done|finished|all tasks complete|已完成|结束)'; then
        if [[ "$REMAINING_TASKS" -gt 0 ]]; then
            log_warn "False completion detected! $REMAINING_TASKS tasks remaining"
            
            REMAINING_LIST=$(grep -E '^\s*-\s*\[\s*\]' "$TASKS_FILE" | head -5)
            
            jq -n \
              --arg remaining "$REMAINING_TASKS" \
              --arg tasks "$REMAINING_LIST" \
              '{
                "decision": "block",
                "reason": "⚠️ 你声称完成了，但还有 \($remaining) 个任务未完成:\n\($tasks)\n\n请继续执行剩余任务，完成后输出 <promise>DONE</promise>",
                "systemMessage": "🔄 TODO Continuation: 检测到未完成任务"
              }'
            exit 0
        fi
    fi
fi

# ============================================================================
# Continue OODA Loop
# ============================================================================

# Not complete - continue OODA loop
NEXT_ITERATION=$((ITERATION + 1))

log_info "Continuing loop (iteration $NEXT_ITERATION/$MAX_ITER)"

# Read tasks.md as the prompt
if [[ ! -f "$TASKS_FILE" ]]; then
    log_error "Tasks file not found: $TASKS_FILE"
    cleanup_and_exit "$STATE_FILE"
fi

PROMPT_TEXT=$(cat "$TASKS_FILE")

if [[ -z "$PROMPT_TEXT" ]]; then
    log_error "Tasks file is empty"
    cleanup_and_exit "$STATE_FILE"
fi

# Update iteration in state
TMP_FILE="${STATE_FILE}.tmp.$$"
jq ".ooda.iteration = $NEXT_ITERATION | .ooda.lastUpdated = (now | tostring)" "$STATE_FILE" > "$TMP_FILE"
mv "$TMP_FILE" "$STATE_FILE"

# Build system message
SYSTEM_MSG="${LOG_PREFIX} iteration $NEXT_ITERATION/$MAX_ITER | Complete all tasks, then output <promise>$COMPLETION_PROMISE</promise>"

# Output JSON to block stop and feed prompt back
jq -n \
  --arg prompt "$PROMPT_TEXT" \
  --arg msg "$SYSTEM_MSG" \
  '{
    "decision": "block",
    "reason": $prompt,
    "systemMessage": $msg
  }'

exit 0
