#!/bin/bash
# Context Bridge - Mode Detection Script
# Detects whether to run in ai-dev mode or standalone mode
#
# Usage: ./detect-mode.sh
# Output: "ai-dev" or "standalone"

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Default mode
MODE="standalone"
CONTEXT_DIR="codebox/context"

detect_mode() {
    # Check if codebox/changes/active directory exists
    if [ -d "codebox/changes/active" ]; then
        # Count active changes
        local active_count
        active_count=$(find codebox/changes/active -maxdepth 1 -type d 2>/dev/null | tail -n +2 | wc -l | tr -d ' ')

        if [ "$active_count" -gt 0 ]; then
            # Check if any change has a valid state.json
            for dir in codebox/changes/active/*/; do
                if [ -f "${dir}state.json" ]; then
                    # Validate state.json has required fields
                    if command -v jq &> /dev/null; then
                        if jq -e '.changeId' "${dir}state.json" > /dev/null 2>&1; then
                            MODE="ai-dev"
                            return 0
                        fi
                    else
                        # Without jq, just check file exists and is not empty
                        if [ -s "${dir}state.json" ]; then
                            MODE="ai-dev"
                            return 0
                        fi
                    fi
                fi
            done
        fi
    fi

    MODE="standalone"
    return 0
}

# Ensure context directory exists
ensure_context_dir() {
    mkdir -p "$CONTEXT_DIR/sessions"
}

# Get active change info (ai-dev mode only)
get_active_changes() {
    if [ "$MODE" != "ai-dev" ]; then
        echo "[]"
        return
    fi

    local changes="["
    local first=true

    for dir in codebox/changes/active/*/; do
        if [ -f "${dir}state.json" ]; then
            if [ "$first" = true ]; then
                first=false
            else
                changes+=","
            fi

            if command -v jq &> /dev/null; then
                local change_id phase ooda_count
                change_id=$(jq -r '.changeId // "unknown"' "${dir}state.json")
                phase=$(jq -r '.currentPhase // 0' "${dir}state.json")
                ooda_count=$(jq -r '.ooda.iterationCount // 0' "${dir}state.json")
                changes+="{\"id\":\"$change_id\",\"phase\":$phase,\"ooda\":$ooda_count}"
            fi
        fi
    done

    changes+="]"
    echo "$changes"
}

# Check context files exist
check_context_files() {
    local status=0

    if [ -f "$CONTEXT_DIR/next_steps.md" ]; then
        echo -e "${GREEN}✓${NC} next_steps.md found"
    else
        echo -e "${YELLOW}○${NC} next_steps.md not found"
        status=1
    fi

    if [ -f "$CONTEXT_DIR/session_summary.md" ]; then
        echo -e "${GREEN}✓${NC} session_summary.md found"
    else
        echo -e "${YELLOW}○${NC} session_summary.md not found"
    fi

    return $status
}

# Main execution
main() {
    local command="${1:-detect}"

    case "$command" in
        detect)
            detect_mode
            echo "$MODE"
            ;;
        info)
            detect_mode
            ensure_context_dir
            echo "Mode: $MODE"
            echo "Context Dir: $CONTEXT_DIR"
            echo ""
            echo "Context Files:"
            check_context_files || true
            echo ""
            if [ "$MODE" = "ai-dev" ]; then
                echo "Active Changes:"
                get_active_changes
            fi
            ;;
        check)
            detect_mode
            ensure_context_dir
            check_context_files
            ;;
        *)
            echo "Usage: $0 [detect|info|check]"
            echo ""
            echo "Commands:"
            echo "  detect  - Output mode (ai-dev or standalone)"
            echo "  info    - Show detailed mode information"
            echo "  check   - Check context files exist"
            exit 1
            ;;
    esac
}

main "$@"
