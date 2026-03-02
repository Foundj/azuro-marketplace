#!/bin/bash
#
# query-solutions.sh - Query Reflexion knowledge base for similar errors
#
# Usage: query-solutions.sh <error-pattern> [options]
#
# Options:
#   --limit <n>     Max results (default: 5)
#   --verified      Only show verified solutions
#   --format <fmt>  Output: text (default) or json
#
# Exit codes:
#   0 - Success (found matches)
#   1 - No matches found
#   2 - File not found

set -uo pipefail

AGENT_ROOT="${AGENT_ROOT:-./.agent}"
SOLUTIONS_FILE="${AGENT_ROOT}/knowledge/solutions_learned.jsonl"

PATTERN=""
LIMIT=5
VERIFIED_ONLY=false
FORMAT="text"

parse_args() {
    if [[ $# -lt 1 ]]; then
        echo "Usage: query-solutions.sh <error-pattern> [options]" >&2
        exit 2
    fi

    PATTERN="$1"
    shift

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --limit)
                LIMIT="$2"
                shift 2
                ;;
            --verified)
                VERIFIED_ONLY=true
                shift
                ;;
            --format)
                FORMAT="$2"
                shift 2
                ;;
            *)
                echo "ERROR: Unknown option: $1" >&2
                exit 2
                ;;
        esac
    done
}

query_solutions() {
    if [[ ! -f "$SOLUTIONS_FILE" ]]; then
        echo "INFO: No solutions database found: $SOLUTIONS_FILE" >&2
        exit 2
    fi

    local matches=()
    local count=0

    while IFS= read -r line || [[ -n "$line" ]]; do
        if ! echo "$line" | jq empty 2>/dev/null; then
            continue
        fi

        local error
        error=$(echo "$line" | jq -r '.error // ""')
        
        if [[ "$error" == *"$PATTERN"* ]] || [[ "$PATTERN" == *"$error"* ]]; then
            if [[ "$VERIFIED_ONLY" == "true" ]]; then
                local verified
                verified=$(echo "$line" | jq -r '.verified // false')
                if [[ "$verified" != "true" ]]; then
                    continue
                fi
            fi
            
            matches+=("$line")
            ((count++)) || true
            
            if [[ $count -ge $LIMIT ]]; then
                break
            fi
        fi
    done < "$SOLUTIONS_FILE"

    if [[ ${#matches[@]} -eq 0 ]]; then
        echo "No matching solutions found for: $PATTERN" >&2
        exit 1
    fi

    if [[ "$FORMAT" == "json" ]]; then
        echo "["
        local first=true
        for match in "${matches[@]}"; do
            if [[ "$first" == "true" ]]; then
                first=false
            else
                echo ","
            fi
            echo "  $match"
        done
        echo "]"
    else
        echo "Found ${#matches[@]} matching solution(s):"
        echo ""
        local idx=1
        for match in "${matches[@]}"; do
            local error solution context timestamp
            error=$(echo "$match" | jq -r '.error')
            solution=$(echo "$match" | jq -r '.solution')
            context=$(echo "$match" | jq -r '.context // "N/A"')
            timestamp=$(echo "$match" | jq -r '.timestamp')
            
            echo "[$idx] Error: $error"
            echo "    Solution: $solution"
            echo "    Context: $context"
            echo "    Recorded: $timestamp"
            echo ""
            ((idx++)) || true
        done
    fi

    exit 0
}

main() {
    parse_args "$@"
    query_solutions
}

main "$@"
