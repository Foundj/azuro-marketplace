#!/bin/bash

# Query Knowledge Script for ai-dev
# Integrates with mem0 for Phase 0 knowledge pre-check
# Queries patterns, errors, and learnings before making changes

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
COMMON_LIB="${HOME}/.claude/common/lib"
MEM0_SCRIPT="${COMMON_LIB}/mem0-integration.sh"
CODEBOX_DIR="codebox"
KNOWLEDGE_DIR="${CODEBOX_DIR}/knowledge"

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    echo "📚 Knowledge: $1"
}

log_warn() {
    echo "📚 Knowledge ⚠️: $1" >&2
}

# ============================================================================
# Main Functions
# ============================================================================

# Query local knowledge base (patterns.json, errors.json)
query_local_knowledge() {
    local query="$1"
    local result=""
    
    # Query patterns
    if [[ -f "${KNOWLEDGE_DIR}/patterns.json" ]]; then
        local patterns=$(jq -r --arg q "$query" '
            .patterns[] |
            select(.keywords | any(. | test($q; "i"))) |
            "PATTERN: \(.name) - \(.description)"
        ' "${KNOWLEDGE_DIR}/patterns.json" 2>/dev/null || echo "")
        
        if [[ -n "$patterns" ]]; then
            result+="## Related Patterns\n$patterns\n\n"
        fi
    fi
    
    # Query errors
    if [[ -f "${KNOWLEDGE_DIR}/errors.json" ]]; then
        local errors=$(jq -r --arg q "$query" '
            .errors[] |
            select(.keywords | any(. | test($q; "i"))) |
            "ERROR: \(.title) - Prevention: \(.prevention)"
        ' "${KNOWLEDGE_DIR}/errors.json" 2>/dev/null || echo "")
        
        if [[ -n "$errors" ]]; then
            result+="## Historical Errors\n$errors\n\n"
        fi
    fi
    
    echo -e "$result"
}

# Query mem0 if available
query_mem0() {
    local project_dir="$1"
    local query="$2"
    local result=""
    
    if [[ -f "$MEM0_SCRIPT" ]]; then
        source "$MEM0_SCRIPT"
        
        # Retrieve pattern memories
        local patterns=$(retrieve_memories "$project_dir" "$query" "pattern" 5 2>/dev/null || echo "")
        if [[ -n "$patterns" && "$patterns" != "[]" ]]; then
            result+="## mem0 Patterns\n"
            result+=$(echo "$patterns" | jq -r '.[] | "- \(.content)"' 2>/dev/null || echo "")
            result+="\n\n"
        fi
        
        # Retrieve decision memories
        local decisions=$(retrieve_memories "$project_dir" "$query" "decision" 3 2>/dev/null || echo "")
        if [[ -n "$decisions" && "$decisions" != "[]" ]]; then
            result+="## mem0 Decisions\n"
            result+=$(echo "$decisions" | jq -r '.[] | "- \(.content)"' 2>/dev/null || echo "")
            result+="\n\n"
        fi
    fi
    
    echo -e "$result"
}

# Generate Phase 0 context file
generate_phase0_context() {
    local change_dir="$1"
    local query="$2"
    local project_dir="${3:-$(pwd)}"
    
    local output_file="${change_dir}/phase0-context.md"
    
    {
        echo "# Phase 0: Knowledge Pre-Check"
        echo ""
        echo "> Generated: $(date -Iseconds)"
        echo "> Query: $query"
        echo ""
        
        # Local knowledge
        local local_result=$(query_local_knowledge "$query")
        if [[ -n "$local_result" ]]; then
            echo "$local_result"
        else
            echo "## Local Knowledge"
            echo "No relevant patterns or errors found."
            echo ""
        fi
        
        # mem0 knowledge
        local mem0_result=$(query_mem0 "$project_dir" "$query")
        if [[ -n "$mem0_result" ]]; then
            echo "$mem0_result"
        fi
        
        # Recommendations
        echo "## Recommendations"
        echo ""
        echo "Based on knowledge query:"
        echo "- Review any related patterns before implementation"
        echo "- Apply prevention measures for historical errors"
        echo "- Consider past decisions for consistency"
        echo ""
        
    } > "$output_file"
    
    log_info "Generated: $output_file"
    echo "$output_file"
}

# Check for blocking issues
check_blocking_issues() {
    local query="$1"
    local blocking=""
    
    # Check for critical errors that should block
    if [[ -f "${KNOWLEDGE_DIR}/errors.json" ]]; then
        blocking=$(jq -r --arg q "$query" '
            .errors[] |
            select(.severity == "critical") |
            select(.keywords | any(. | test($q; "i"))) |
            "🔴 BLOCKING: \(.title) - \(.prevention)"
        ' "${KNOWLEDGE_DIR}/errors.json" 2>/dev/null || echo "")
    fi
    
    if [[ -n "$blocking" ]]; then
        echo "$blocking"
        return 1
    fi
    
    return 0
}

# ============================================================================
# CLI Interface
# ============================================================================

usage() {
    cat <<EOF
Usage: $(basename "$0") <command> [options]

Commands:
    query <search_term>           Query knowledge base for relevant info
    generate <change_dir> <query> Generate phase0-context.md for a change
    check <search_term>           Check for blocking issues

Options:
    -p, --project <dir>           Project directory (default: current)
    -h, --help                    Show this help

Examples:
    $(basename "$0") query "user authentication"
    $(basename "$0") generate codebox/changes/active/CHG-001 "login feature"
    $(basename "$0") check "password storage"
EOF
}

main() {
    local command="${1:-}"
    shift || true
    
    case "$command" in
        query)
            local query="${1:-}"
            if [[ -z "$query" ]]; then
                echo "Error: query term required" >&2
                exit 1
            fi
            
            log_info "Querying: $query"
            echo ""
            
            local local_result=$(query_local_knowledge "$query")
            if [[ -n "$local_result" ]]; then
                echo -e "$local_result"
            else
                echo "No results found in local knowledge base."
            fi
            ;;
            
        generate)
            local change_dir="${1:-}"
            local query="${2:-}"
            local project_dir="${3:-$(pwd)}"
            
            if [[ -z "$change_dir" || -z "$query" ]]; then
                echo "Error: change_dir and query required" >&2
                exit 1
            fi
            
            generate_phase0_context "$change_dir" "$query" "$project_dir"
            ;;
            
        check)
            local query="${1:-}"
            if [[ -z "$query" ]]; then
                echo "Error: query term required" >&2
                exit 1
            fi
            
            if check_blocking_issues "$query"; then
                log_info "No blocking issues found"
                exit 0
            else
                exit 1
            fi
            ;;
            
        -h|--help|help)
            usage
            exit 0
            ;;
            
        *)
            echo "Error: Unknown command '$command'" >&2
            usage
            exit 1
            ;;
    esac
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
