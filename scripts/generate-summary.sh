#!/bin/bash

# Generate Summary Script for ai-dev
# Creates comprehensive SUMMARY.md for archived changes

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATES_DIR="${SKILL_DIR}/templates"
TEMPLATE_FILE="${TEMPLATES_DIR}/archive-summary.md"

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    echo "📝 Summary: $1"
}

log_warn() {
    echo "📝 Summary ⚠️: $1" >&2
}

log_error() {
    echo "📝 Summary ❌: $1" >&2
}

# ============================================================================
# Data Extraction Functions
# ============================================================================

extract_title() {
    local change_dir="$1"
    local proposal="${change_dir}/proposal.md"
    
    if [[ -f "$proposal" ]]; then
        # Extract first heading or summary line
        grep -m 1 "^#" "$proposal" | sed 's/^#* *//' || echo "Untitled Change"
    else
        echo "Untitled Change"
    fi
}

extract_dates() {
    local change_dir="$1"
    local state_file="${change_dir}/state.json"
    
    if [[ -f "$state_file" ]]; then
        local created=$(jq -r '.createdAt // "unknown"' "$state_file")
        local completed=$(date -Iseconds)
        echo "${created}|${completed}"
    else
        echo "unknown|$(date -Iseconds)"
    fi
}

extract_ooda_count() {
    local change_dir="$1"
    local state_file="${change_dir}/state.json"
    
    if [[ -f "$state_file" ]]; then
        jq -r '.ooda.iteration // 0' "$state_file"
    else
        echo "0"
    fi
}

extract_file_changes() {
    local change_dir="$1"
    local state_file="${change_dir}/state.json"
    
    # Try to get from state.json
    if [[ -f "$state_file" ]]; then
        local files=$(jq -r '.modifiedFiles // [] | .[]' "$state_file" 2>/dev/null)
        if [[ -n "$files" ]]; then
            echo "$files"
            return
        fi
    fi
    
    # Fallback: try git diff if in a git repo
    if git rev-parse --git-dir &>/dev/null; then
        # Get files changed in recent commits (heuristic)
        git diff --name-only HEAD~5 2>/dev/null || echo ""
    fi
}

extract_decisions() {
    local change_dir="$1"
    local decision_log="${change_dir}/decision-log.md"
    
    if [[ -f "$decision_log" ]]; then
        # Extract decision entries
        grep -E "^##|^- \*\*Decision\*\*:|^Decision:" "$decision_log" | head -10
    else
        echo "No decisions recorded"
    fi
}

extract_patterns() {
    local change_dir="$1"
    local state_file="${change_dir}/state.json"
    
    if [[ -f "$state_file" ]]; then
        jq -r '.patterns // [] | .[] | "- \(.name): \(.description // "No description")"' "$state_file" 2>/dev/null || echo ""
    fi
}

extract_learnings() {
    local change_dir="$1"
    local proposal="${change_dir}/proposal.md"
    local state_file="${change_dir}/state.json"
    
    # Check for explicit learnings in state
    if [[ -f "$state_file" ]]; then
        local learnings=$(jq -r '.learnings // [] | .[]' "$state_file" 2>/dev/null)
        if [[ -n "$learnings" ]]; then
            echo "$learnings"
            return
        fi
    fi
    
    # Default learnings based on OODA count
    local ooda_count=$(extract_ooda_count "$change_dir")
    if (( ooda_count > 3 )); then
        echo "- Required multiple iterations (${ooda_count}) - consider breaking down similar changes"
    elif (( ooda_count <= 1 )); then
        echo "- Completed efficiently in ${ooda_count} iteration(s)"
    fi
}

# ============================================================================
# Summary Generation
# ============================================================================

generate_summary() {
    local change_dir="$1"
    local change_id="$2"
    local output_file="${change_dir}/SUMMARY.md"
    
    log_info "Generating summary for $change_id..."
    
    # Extract data
    local title=$(extract_title "$change_dir")
    local dates=$(extract_dates "$change_dir")
    local created_date=$(echo "$dates" | cut -d'|' -f1)
    local completed_date=$(echo "$dates" | cut -d'|' -f2)
    local ooda_count=$(extract_ooda_count "$change_dir")
    
    # Calculate duration (simplified)
    local duration="N/A"
    if [[ "$created_date" != "unknown" ]]; then
        # Try to calculate duration in hours/days
        duration="See timestamps"
    fi
    
    # Generate summary content
    cat > "$output_file" <<EOF
# Change Summary: ${change_id}

## Overview

| Field | Value |
|-------|-------|
| **Title** | ${title} |
| **Change ID** | ${change_id} |
| **Created** | ${created_date} |
| **Completed** | ${completed_date} |
| **Duration** | ${duration} |
| **OODA Iterations** | ${ooda_count} |

## Files Changed

EOF

    # Add file changes
    local files=$(extract_file_changes "$change_dir")
    if [[ -n "$files" ]]; then
        echo "| File | Action |" >> "$output_file"
        echo "|------|--------|" >> "$output_file"
        while IFS= read -r file; do
            if [[ -n "$file" ]]; then
                echo "| \`${file}\` | Modified |" >> "$output_file"
            fi
        done <<< "$files"
    else
        echo "_No file changes recorded_" >> "$output_file"
    fi
    
    cat >> "$output_file" <<EOF

## Key Decisions

EOF

    # Add decisions
    local decisions=$(extract_decisions "$change_dir")
    if [[ -n "$decisions" ]]; then
        echo "$decisions" >> "$output_file"
    else
        echo "_No decisions recorded_" >> "$output_file"
    fi

    cat >> "$output_file" <<EOF

## Patterns Identified

EOF

    # Add patterns
    local patterns=$(extract_patterns "$change_dir")
    if [[ -n "$patterns" ]]; then
        echo "$patterns" >> "$output_file"
    else
        echo "_No new patterns identified_" >> "$output_file"
    fi

    cat >> "$output_file" <<EOF

## Learnings

EOF

    # Add learnings
    local learnings=$(extract_learnings "$change_dir")
    if [[ -n "$learnings" ]]; then
        echo "$learnings" >> "$output_file"
    else
        echo "_No specific learnings recorded_" >> "$output_file"
    fi

    cat >> "$output_file" <<EOF

## References

- **Proposal**: [proposal.md](./proposal.md)
- **State**: [state.json](./state.json)
- **Decision Log**: [decision-log.md](./decision-log.md)

---
_Generated: $(date -Iseconds)_
EOF

    log_info "Summary saved to: $output_file"
    echo "$output_file"
}

# ============================================================================
# CLI Interface
# ============================================================================

usage() {
    cat <<EOF
Usage: $(basename "$0") <change_dir> <change_id>

Arguments:
    change_dir    Path to the change directory
    change_id     ID of the change (e.g., CHG-20250106-001)

Output:
    Creates SUMMARY.md in the change directory

Examples:
    $(basename "$0") .agent/changes/active/CHG-20250106-001 CHG-20250106-001
EOF
}

main() {
    local change_dir="${1:-}"
    local change_id="${2:-}"
    
    if [[ -z "$change_dir" || -z "$change_id" || "$change_dir" == "-h" || "$change_dir" == "--help" ]]; then
        usage
        exit 0
    fi
    
    if [[ ! -d "$change_dir" ]]; then
        log_error "Change directory not found: $change_dir"
        exit 1
    fi
    
    generate_summary "$change_dir" "$change_id"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
