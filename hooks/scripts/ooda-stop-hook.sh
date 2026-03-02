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

AGENT_DIR=".agent"
CHANGES_DIR="${AGENT_DIR}/changes/active"
COMPLETION_PROMISE="DONE"
MAX_ITERATIONS=50
LOG_PREFIX="🔄 OODA"
DEFAULT_VERIFY_TIMEOUT=120
SCRIPTS_DIR="${SCRIPT_DIR}/../../scripts"

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
# Verification Gate Functions (Hard Gates - v4.0)
# See Draft 18 & Draft 19 for specification
# ============================================================================

# Get current in-progress task from tasks.md
get_current_task() {
    local tasks_file="$1"
    
    if [[ ! -x "${SCRIPTS_DIR}/parse-tasks.sh" ]]; then
        log_warn "parse-tasks.sh not found or not executable, skipping verification"
        return 1
    fi
    
    # Find the first pending task (not yet completed)
    local task_json
    task_json=$("${SCRIPTS_DIR}/parse-tasks.sh" "$tasks_file" --format json 2>/dev/null) || return 1
    
    # Get first pending task
    echo "$task_json" | jq -r '.tasks[] | select(.status == "pending") | @json' | head -1
}

# Extract verify_with command from task JSON
get_verify_command() {
    local task_json="$1"
    echo "$task_json" | jq -r '.metadata.verify_with // empty'
}

# Extract timeout from task JSON (default: 120 seconds)
get_verify_timeout() {
    local task_json="$1"
    local timeout
    timeout=$(echo "$task_json" | jq -r '.metadata.timeout // empty')
    if [[ -z "$timeout" ]] || [[ ! "$timeout" =~ ^[0-9]+$ ]]; then
        timeout="$DEFAULT_VERIFY_TIMEOUT"
    fi
    echo "$timeout"
}

# Run verification command with timeout
# Returns: 0=passed, 1=failed, 2=timeout, 3=command not found
run_verification() {
    local verify_cmd="$1"
    local timeout_sec="$2"
    local work_dir="$3"
    
    # Handle escape hatch: verify_with: true
    if [[ "$verify_cmd" == "true" ]]; then
        log_info "Verification escape hatch: verify_with: true"
        return 0
    fi
    
    # Extract main command (first word)
    local main_cmd
    main_cmd=$(echo "$verify_cmd" | awk '{print $1}')
    
    # Check if command exists
    if ! command -v "$main_cmd" &>/dev/null; then
        log_error "Verification command not found: $main_cmd"
        return 3
    fi
    
    # Run with timeout (use gtimeout on macOS if available)
    local timeout_cmd="timeout"
    if ! command -v timeout &>/dev/null && command -v gtimeout &>/dev/null; then
        timeout_cmd="gtimeout"
    fi
    
    local exit_code
    if $timeout_cmd "$timeout_sec" bash -c "cd '$work_dir' && $verify_cmd" 2>&1; then
        exit_code=0
    else
        exit_code=$?
    fi
    
    # 124 = timeout command's timeout exit code
    if [[ $exit_code -eq 124 ]]; then
        return 2
    elif [[ $exit_code -ne 0 ]]; then
        return 1
    fi
    
    return 0
}

# Display verification failure and get user choice
# Returns user choice: 1=retry, 2=override, 3=edit, 4=abort
handle_verification_failure() {
    local task_id="$1"
    local verify_cmd="$2"
    local exit_code="$3"
    local failure_type="$4"  # "failed", "timeout", "not_found"
    local work_dir="$5"
    
    echo ""
    
    case "$failure_type" in
        "not_found")
            local main_cmd
            main_cmd=$(echo "$verify_cmd" | awk '{print $1}')
            echo "❌ Verification command '$main_cmd' not found in PATH"
            echo ""
            echo "Task $task_id"
            echo "Verification: $verify_cmd"
            echo ""
            echo "Options:"
            echo "  1. Skip verification for this task (allow DONE)"
            echo "  2. Edit tasks.md to fix verify_with command"
            echo "  3. Install $main_cmd and retry"
            echo "  4. Abort OODA Loop"
            ;;
        "timeout")
            echo "⏱️  Verification timed out after ${exit_code} seconds"
            echo "Command: $verify_cmd"
            echo ""
            echo "Possible causes:"
            echo "  - Command waiting for user input"
            echo "  - Tests hanging (infinite loop, deadlock)"
            echo "  - Very slow test suite"
            echo ""
            echo "Options:"
            echo "  1. Increase timeout (edit tasks.md: | _timeout: 300_)"
            echo "  2. Skip verification"
            echo "  3. Abort"
            ;;
        "failed")
            echo "❌ Verification failed"
            echo "Command: $verify_cmd"
            echo "Exit code: $exit_code"
            echo ""

            # Integrated Reflexion: Query for similar solutions
            if [[ -x "${SCRIPTS_DIR}/query-solutions.sh" ]]; then
                echo "🔍 Searching Reflexion knowledge base for solutions..."
                "${SCRIPTS_DIR}/query-solutions.sh" "$verify_cmd" --limit 3 || echo "No similar solutions found yet."
                echo ""
            fi

            echo "--- Verification Output (last 20 lines) ---"
            # Re-run to capture output (with short timeout to avoid hang)
            timeout 30 bash -c "cd '$work_dir' && $verify_cmd" 2>&1 | tail -n 20 || true
            echo "--- End of Output ---"
            echo ""
            echo "Options:"
            echo "  1. Fix the issues and retry"
            echo "  2. Override verification (DONE anyway)"
            echo "  3. Edit verify_with command"
            echo "  4. Abort"
            ;;
    esac
    
    echo ""
}

# Log verification override to Reflexion system
log_verification_override() {
    local task_id="$1"
    local verify_cmd="$2"
    local reason="$3"
    
    local knowledge_dir="${ACTIVE_CHANGE}/../../knowledge"
    mkdir -p "$knowledge_dir"
    
    local override_file="${knowledge_dir}/verification_overrides.jsonl"
    
    local entry
    entry=$(jq -n \
        --arg task "$task_id" \
        --arg cmd "$verify_cmd" \
        --arg reason "$reason" \
        --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{task: $task, verify_cmd: $cmd, reason: $reason, timestamp: $ts, overridden: true}')
    
    echo "$entry" >> "$override_file"
    log_warn "Override logged to verification_overrides.jsonl"
}

# Main verification gate - blocks completion if verification fails
# Returns: 0=allow completion, 1=block completion (retry), 2=abort
verify_task_completion() {
    local tasks_file="$1"
    local work_dir="$2"
    
    # Get current task
    local task_json
    task_json=$(get_current_task "$tasks_file") || {
        # Parser not available or failed - allow completion (backward compatible)
        log_info "Task parsing unavailable, allowing completion (v3.2 mode)"
        return 0
    }
    
    if [[ -z "$task_json" ]]; then
        log_info "No pending tasks found"
        return 0
    fi
    
    local task_id
    task_id=$(echo "$task_json" | jq -r '.id')
    
    local verify_cmd
    verify_cmd=$(get_verify_command "$task_json")
    
    # No verify_with - allow completion (backward compatible)
    if [[ -z "$verify_cmd" ]]; then
        log_info "No verification required for task $task_id (backward compatible mode)"
        return 0
    fi
    
    log_info "Running verification for task $task_id: $verify_cmd"
    
    local timeout_sec
    timeout_sec=$(get_verify_timeout "$task_json")
    
    local verify_result
    run_verification "$verify_cmd" "$timeout_sec" "$work_dir"
    verify_result=$?
    
    case $verify_result in
        0)
            log_info "✅ Verification passed for task $task_id"
            return 0
            ;;
        1)
            handle_verification_failure "$task_id" "$verify_cmd" "$?" "failed" "$work_dir"
            echo "Your choice [1-4]: "
            read -r choice </dev/tty || choice="4"
            case $choice in
                1) return 1 ;;  # Retry
                2) 
                    log_verification_override "$task_id" "$verify_cmd" "User override - false positive"
                    return 0  # Allow completion
                    ;;
                3) return 1 ;;  # Edit and retry
                4|*) return 2 ;;  # Abort
            esac
            ;;
        2)
            handle_verification_failure "$task_id" "$verify_cmd" "$timeout_sec" "timeout" "$work_dir"
            echo "Your choice [1-3]: "
            read -r choice </dev/tty || choice="3"
            case $choice in
                1) return 1 ;;  # Increase timeout
                2) 
                    log_verification_override "$task_id" "$verify_cmd" "User override - timeout"
                    return 0  # Allow completion
                    ;;
                3|*) return 2 ;;  # Abort
            esac
            ;;
        3)
            handle_verification_failure "$task_id" "$verify_cmd" "0" "not_found" "$work_dir"
            echo "Your choice [1-4]: "
            read -r choice </dev/tty || choice="4"
            case $choice in
                1) 
                    log_verification_override "$task_id" "$verify_cmd" "User skip - command not found"
                    return 0  # Allow completion
                    ;;
                2|3) return 1 ;;  # Edit/install
                4|*) return 2 ;;  # Abort
            esac
            ;;
    esac
    
    return 1
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
    
    # Run verification gate (Hard Gate - v4.0)
    # This blocks completion if verify_with command fails
    verify_result=0
    if [[ -f "$TASKS_FILE" ]]; then
        verify_task_completion "$TASKS_FILE" "$(dirname "$TASKS_FILE")"
        verify_result=$?
    fi
    
    case $verify_result in
        0)
            # Verification passed or not required - allow completion
            TMP_FILE="${STATE_FILE}.tmp.$$"
            jq '.ooda.active = false | 
                .ooda.completedAt = (now | tostring) |
                .implementationComplete = true |
                .phaseHistory += [{"phase": 4, "completedAt": (now | tostring), "oodaIterations": .ooda.iteration}]' \
                "$STATE_FILE" > "$TMP_FILE"
            mv "$TMP_FILE" "$STATE_FILE"
            exit 0
            ;;
        1)
            # Verification failed, user chose to retry
            log_warn "Verification failed, continuing OODA loop for retry"
            # Don't exit - fall through to continue OODA loop
            ;;
        2)
            # User aborted
            log_info "User aborted OODA loop"
            cleanup_and_exit "$STATE_FILE"
            ;;
    esac
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
