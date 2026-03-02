#!/bin/bash
#
# log-solution.sh - Log verified solutions to Reflexion knowledge base
#
# Usage: log-solution.sh --error "error message" --solution "solution" [options]
#
# Options:
#   --error <msg>      Error message that was fixed
#   --solution <msg>   Solution that fixed the error  
#   --context <ctx>    Context (e.g., "Phase 4 - OODA Loop")
#   --task-id <id>     Related task ID
#   --verified         Mark as verified (default: true)
#
# Exit codes:
#   0 - Success
#   1 - Invalid arguments
#   2 - File rotation performed

set -uo pipefail

AGENT_ROOT="${AGENT_ROOT:-./.agent}"
SOLUTIONS_FILE="${AGENT_ROOT}/knowledge/solutions_learned.jsonl"
MAX_SIZE=$((10 * 1024 * 1024))

ERROR_MSG=""
SOLUTION_MSG=""
CONTEXT=""
TASK_ID=""
VERIFIED="true"

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --error)
                ERROR_MSG="$2"
                shift 2
                ;;
            --solution)
                SOLUTION_MSG="$2"
                shift 2
                ;;
            --context)
                CONTEXT="$2"
                shift 2
                ;;
            --task-id)
                TASK_ID="$2"
                shift 2
                ;;
            --verified)
                VERIFIED="true"
                shift
                ;;
            --not-verified)
                VERIFIED="false"
                shift
                ;;
            *)
                echo "ERROR: Unknown option: $1" >&2
                exit 1
                ;;
        esac
    done

    if [[ -z "$ERROR_MSG" ]] || [[ -z "$SOLUTION_MSG" ]]; then
        echo "ERROR: --error and --solution are required" >&2
        exit 1
    fi
}

escape_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    echo "$s"
}

rotate_if_needed() {
    if [[ ! -f "$SOLUTIONS_FILE" ]]; then
        return 0
    fi

    local current_size
    if [[ "$(uname)" == "Darwin" ]]; then
        current_size=$(stat -f%z "$SOLUTIONS_FILE" 2>/dev/null || echo "0")
    else
        current_size=$(stat -c%s "$SOLUTIONS_FILE" 2>/dev/null || echo "0")
    fi

    if [[ $current_size -ge $MAX_SIZE ]]; then
        echo "INFO: Rotating solutions_learned.jsonl (size: $current_size bytes)" >&2
        
        local timestamp
        timestamp=$(date +%Y%m%d-%H%M%S)
        local total_lines
        total_lines=$(wc -l < "$SOLUTIONS_FILE")
        local keep_lines=$((total_lines / 2))
        
        head -n $((total_lines - keep_lines)) "$SOLUTIONS_FILE" | gzip > "${SOLUTIONS_FILE%.jsonl}.$timestamp.jsonl.gz"
        tail -n $keep_lines "$SOLUTIONS_FILE" > "${SOLUTIONS_FILE}.new"
        mv "${SOLUTIONS_FILE}.new" "$SOLUTIONS_FILE"
        
        echo "INFO: Kept $keep_lines lines, archived $((total_lines - keep_lines)) lines" >&2
        return 2
    fi
    
    return 0
}

log_solution() {
    mkdir -p "$(dirname "$SOLUTIONS_FILE")"
    
    rotate_if_needed
    local rotate_status=$?
    
    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    
    local error_escaped
    error_escaped=$(escape_json "$ERROR_MSG")
    local solution_escaped
    solution_escaped=$(escape_json "$SOLUTION_MSG")
    local context_escaped
    context_escaped=$(escape_json "$CONTEXT")
    
    local json="{\"timestamp\":\"$timestamp\",\"error\":\"$error_escaped\",\"solution\":\"$solution_escaped\""
    
    if [[ -n "$CONTEXT" ]]; then
        json+=",\"context\":\"$context_escaped\""
    fi
    
    if [[ -n "$TASK_ID" ]]; then
        json+=",\"taskId\":\"$TASK_ID\""
    fi
    
    json+=",\"verified\":$VERIFIED}"
    
    echo "$json" >> "$SOLUTIONS_FILE"
    
    echo "OK: Logged solution to $SOLUTIONS_FILE" >&2
    
    return $rotate_status
}

main() {
    parse_args "$@"
    log_solution
}

main "$@"
