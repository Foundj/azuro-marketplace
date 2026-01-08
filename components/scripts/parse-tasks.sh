#!/bin/bash
#
# parse-tasks.sh - Backward-compatible tasks.md parser for ai-dev v4.0
#
# Supports both legacy format (v3.2) and enhanced format (v4.0)
# See Draft 18 for specification details
#
# Usage:
#   parse-tasks.sh <tasks.md> [options]
#
# Options:
#   --task-id <id>   Parse specific task only
#   --format <fmt>   Output format: text (default) or json
#   --validate       Validate format only, don't parse
#
# Exit codes:
#   0 - Success
#   1 - File not found or empty
#   2 - Invalid arguments
#   3 - Parse error (with --validate)

set -uo pipefail

SCRIPT_NAME="$(basename "$0")"
TASKS_FILE=""
TASK_ID=""
FORMAT="text"
VALIDATE_ONLY=false
WARNINGS=()

usage() {
    cat <<EOF
Usage: $SCRIPT_NAME <tasks.md> [options]

Options:
  --task-id <id>   Parse specific task only
  --format <fmt>   Output format: text (default) or json
  --validate       Validate format only
  -h, --help       Show this help

Examples:
  $SCRIPT_NAME tasks.md
  $SCRIPT_NAME tasks.md --format json
  $SCRIPT_NAME tasks.md --task-id 1.3
EOF
    exit 0
}

log_warning() {
    WARNINGS+=("$1")
    echo "WARNING: $1" >&2
}

log_error() {
    echo "ERROR: $1" >&2
}

parse_args() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --task-id)
                TASK_ID="$2"
                shift 2
                ;;
            --format)
                FORMAT="$2"
                shift 2
                ;;
            --validate)
                VALIDATE_ONLY=true
                shift
                ;;
            -h|--help)
                usage
                ;;
            -*)
                log_error "Unknown option: $1"
                exit 2
                ;;
            *)
                if [[ -z "$TASKS_FILE" ]]; then
                    TASKS_FILE="$1"
                else
                    log_error "Unexpected argument: $1"
                    exit 2
                fi
                shift
                ;;
        esac
    done

    if [[ -z "$TASKS_FILE" ]]; then
        log_error "tasks.md file required"
        usage
    fi
}

validate_file() {
    if [[ ! -f "$TASKS_FILE" ]]; then
        log_error "File not found: $TASKS_FILE"
        exit 1
    fi

    if [[ ! -s "$TASKS_FILE" ]]; then
        log_error "File is empty: $TASKS_FILE"
        exit 1
    fi

    if ! file "$TASKS_FILE" 2>/dev/null | grep -q "text\|ASCII\|UTF-8"; then
        log_error "File is not a text file (possibly corrupted): $TASKS_FILE"
        exit 1
    fi
}

trim() {
    local var="$1"
    var="${var#"${var%%[![:space:]]*}"}"
    var="${var%"${var##*[![:space:]]}"}"
    echo "$var"
}

auto_fix_metadata() {
    local meta="$1"
    local original="$meta"
    
    meta="${meta//：/:}"
    meta="$(trim "$meta")"
    meta="${meta#_}"
    meta="${meta%_}"
    
    if [[ "$meta" != "$original" ]]; then
        log_warning "Auto-fixed metadata: '$original' -> '$meta'"
    fi
    
    echo "$meta"
}

parse_metadata_field() {
    local meta="$1"
    local key=""
    local value=""
    
    meta="$(auto_fix_metadata "$meta")"
    
    if [[ "$meta" =~ ^([a-z_]+):[[:space:]]*(.+)$ ]]; then
        key="${BASH_REMATCH[1]}"
        value="${BASH_REMATCH[2]}"
        echo "$key|$value"
        return 0
    else
        log_warning "Invalid metadata format: '$meta'"
        return 1
    fi
}

output_task_text() {
    local id="$1"
    local status="$2"
    local desc="$3"
    local indent="$4"
    shift 4
    
    local prefix=""
    for ((i=0; i<indent; i++)); do prefix+="  "; done
    
    echo "${prefix}TASK: $id"
    echo "${prefix}  status: $status"
    echo "${prefix}  description: $desc"
    
    while [[ $# -gt 0 ]]; do
        local kv="$1"
        local k="${kv%%|*}"
        local v="${kv#*|}"
        echo "${prefix}  $k: $v"
        shift
    done
    echo ""
}

escape_json() {
    local s="$1"
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    # Escape control characters (U+0000 to U+001F)
    # Using printf to handle non-printable characters
    s=$(echo -n "$s" | perl -pe 's/([\x00-\x1f])/sprintf("\\u%04x", ord($1))/ge')
    echo -n "$s"
}

output_task_json() {
    local id="$1"
    local status="$2"
    local desc="$3"
    local indent="$4"
    shift 4

    local desc_escaped
    desc_escaped=$(escape_json "$desc")

    echo "    {"
    echo "      \"id\": \"$id\","
    echo "      \"status\": \"$status\","
    echo "      \"description\": \"$desc_escaped\","
    echo "      \"indent\": $indent,"
    echo "      \"metadata\": {"

    local first=true
    while [[ $# -gt 0 ]]; do
        local kv="$1"
        local k="${kv%%|*}"
        local v="${kv#*|}"
        local v_escaped
        v_escaped=$(escape_json "$v")

        if [[ "$first" == "true" ]]; then
            first=false
        else
            echo ","
        fi
        echo -n "        \"$k\": \"$v_escaped\""
        shift
    done

    if [[ "$first" == "false" ]]; then
        echo ""
    fi
    echo "      }"
    echo -n "    }"
}

parse_tasks() {
    local file="$1"
    local task_count=0
    local enhanced_count=0
    local legacy_count=0
    local first_task=true
    
    if [[ "$FORMAT" == "json" ]]; then
        echo "{"
        echo "  \"tasks\": ["
    fi
    
    while IFS= read -r line || [[ -n "$line" ]]; do
        if [[ ! "$line" =~ ^([[:space:]]*)-[[:space:]]\[(.)\][[:space:]]+(.+) ]]; then
            continue
        fi

        local indent_str="${BASH_REMATCH[1]}"
        local check="${BASH_REMATCH[2]}"
        local rest="${BASH_REMATCH[3]}"
        local indent=$((${#indent_str} / 2))

        local status="pending"
        [[ "$check" == "x" ]] && status="completed"

        local task_id=""
        local description=""

        if [[ "$rest" =~ ^([0-9]+(\.[0-9]+)*)[[:space:]]+(.+) ]]; then
            task_id="${BASH_REMATCH[1]}"
            description="${BASH_REMATCH[3]}"
        else
            # Try to match ID without following description
            if [[ "$rest" =~ ^([0-9]+(\.[0-9]+)*)[[:space:]]*$ ]]; then
                task_id="${BASH_REMATCH[1]}"
                description=""
            else
                log_warning "Cannot parse task ID from: $line"
                continue
            fi
        fi
        
        if [[ -n "$TASK_ID" ]] && [[ "$task_id" != "$TASK_ID" ]]; then
            continue
        fi
        
        ((task_count++)) || true
        
        local metadata=()
        
        if [[ "$description" =~ \| ]]; then
            ((enhanced_count++)) || true
            
            IFS='|' read -ra parts <<< "$description"
            description="$(trim "${parts[0]}")"
            
            for ((i=1; i<${#parts[@]}; i++)); do
                local meta="${parts[$i]}"
                local kv
                if kv=$(parse_metadata_field "$meta"); then
                    metadata+=("$kv")
                fi
            done
        else
            ((legacy_count++)) || true
        fi
        
        if [[ "$FORMAT" == "json" ]]; then
            if [[ "$first_task" == "true" ]]; then
                first_task=false
            else
                echo ","
            fi
            output_task_json "$task_id" "$status" "$description" "$indent" "${metadata[@]+"${metadata[@]}"}"
        else
            output_task_text "$task_id" "$status" "$description" "$indent" "${metadata[@]+"${metadata[@]}"}"
        fi
        
    done < "$file"
    
    if [[ "$FORMAT" == "json" ]]; then
        if [[ "$first_task" == "false" ]]; then
            echo ""
        fi
        echo "  ],"
        echo "  \"stats\": {"
        echo "    \"total\": $task_count,"
        echo "    \"enhanced\": $enhanced_count,"
        echo "    \"legacy\": $legacy_count,"
        echo "    \"warnings\": ${#WARNINGS[@]}"
        echo "  }"
        echo "}"
    else
        echo "---"
        echo "STATS: total=$task_count, enhanced=$enhanced_count, legacy=$legacy_count, warnings=${#WARNINGS[@]}"
    fi
}

main() {
    parse_args "$@"
    validate_file
    
    if [[ "$VALIDATE_ONLY" == "true" ]]; then
        echo "File validation passed: $TASKS_FILE"
        exit 0
    fi
    
    parse_tasks "$TASKS_FILE"
}

main "$@"
