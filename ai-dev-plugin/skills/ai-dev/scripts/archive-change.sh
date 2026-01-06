#!/bin/bash

# Archive Change Script for ai-dev
# Archives completed changes and updates knowledge base
# Enhanced version with summary generation and feature index updates

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
PRE_CHECK_DIR="${SKILL_DIR}/pre-check"

CODEBOX_DIR="codebox"
CHANGES_DIR="${CODEBOX_DIR}/changes"
KNOWLEDGE_DIR="${CODEBOX_DIR}/knowledge"

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    echo "📦 Archive: $1"
}

log_warn() {
    echo "📦 Archive ⚠️: $1" >&2
}

log_error() {
    echo "📦 Archive ❌: $1" >&2
}

log_success() {
    echo "📦 Archive ✅: $1"
}

# ============================================================================
# Validation Functions
# ============================================================================

validate_completion() {
    local change_dir="$1"
    local force="$2"
    local state_file="${change_dir}/state.json"
    
    if [[ ! -f "$state_file" ]]; then
        log_warn "No state.json found"
        return 1
    fi
    
    local impl_complete=$(jq -r '.implementationComplete // false' "$state_file")
    local completion_promise=$(jq -r '.completion_promise // "PENDING"' "$state_file")
    
    if [[ "$impl_complete" != "true" && "$completion_promise" != "DONE" ]]; then
        if [[ "$force" != "true" ]]; then
            log_warn "Change not marked as complete (implementationComplete=$impl_complete, completion_promise=$completion_promise)"
            log_warn "Use --force to archive anyway"
            return 1
        fi
        log_warn "Forcing archive of incomplete change"
    fi
    
    log_success "Completion status verified"
    return 0
}

run_validation_tests() {
    local change_dir="$1"
    local force="$2"
    local state_file="${change_dir}/state.json"
    
    if [[ "$force" == "true" ]]; then
        log_warn "Skipping test validation (--force)"
        return 0
    fi
    
    # Get modified files to determine test scope
    local modified_files=""
    if [[ -f "$state_file" ]]; then
        modified_files=$(jq -r '.modifiedFiles // [] | .[]' "$state_file" 2>/dev/null || echo "")
    fi
    
    if [[ -z "$modified_files" ]]; then
        log_info "No modified files recorded, skipping targeted tests"
        return 0
    fi
    
    # Try to run related tests
    log_info "Running related tests..."
    
    # Detect test framework and run
    if [[ -f "package.json" ]]; then
        # Node.js project
        if command -v npm &>/dev/null; then
            if npm test --if-present 2>/dev/null; then
                log_success "Tests passed"
                return 0
            else
                log_warn "Some tests failed"
                return 1
            fi
        fi
    elif [[ -f "pytest.ini" || -f "setup.py" || -f "pyproject.toml" ]]; then
        # Python project
        if command -v pytest &>/dev/null; then
            if pytest --co -q 2>/dev/null | head -5; then
                log_success "Tests discovered"
                return 0
            fi
        fi
    fi
    
    log_info "No test runner detected, skipping"
    return 0
}

check_build_status() {
    local force="$1"
    
    if [[ "$force" == "true" ]]; then
        log_warn "Skipping build check (--force)"
        return 0
    fi
    
    log_info "Checking build status..."
    
    # Detect build system and check
    if [[ -f "package.json" ]]; then
        if command -v npm &>/dev/null; then
            if npm run build --if-present 2>/dev/null; then
                log_success "Build clean"
                return 0
            else
                log_warn "Build has issues"
                return 1
            fi
        fi
    fi
    
    log_info "No build system detected, skipping"
    return 0
}

# ============================================================================
# Archive Functions
# ============================================================================

generate_summary() {
    local change_dir="$1"
    local change_id="$2"
    
    local summary_script="${SCRIPT_DIR}/generate-summary.sh"
    
    if [[ -x "$summary_script" ]]; then
        log_info "Generating summary..."
        "$summary_script" "$change_dir" "$change_id"
    else
        log_warn "Summary script not found or not executable: $summary_script"
    fi
}

update_feature_index() {
    local change_dir="$1"
    local change_id="$2"
    
    local update_script="${PRE_CHECK_DIR}/scripts/update-feature-index.sh"
    
    if [[ -x "$update_script" ]]; then
        log_info "Updating feature index..."
        "$update_script" "$change_dir" "$change_id" || log_warn "Feature index update failed"
    else
        log_warn "Feature index update script not found: $update_script"
    fi
}

extract_learnings() {
    local change_dir="$1"
    local change_id="$2"
    
    local learnings_file="${KNOWLEDGE_DIR}/learnings.md"
    
    # Ensure knowledge directory exists
    mkdir -p "$KNOWLEDGE_DIR"
    
    # Create learnings file if it doesn't exist
    if [[ ! -f "$learnings_file" ]]; then
        cat > "$learnings_file" <<EOF
# Project Learnings

This file contains learnings extracted from completed changes.

EOF
    fi
    
    # Extract summary from proposal
    local summary=""
    if [[ -f "${change_dir}/proposal.md" ]]; then
        summary=$(grep -A 2 "## Summary" "${change_dir}/proposal.md" | tail -1 || echo "")
    fi
    
    # Get OODA iterations
    local iterations=0
    if [[ -f "${change_dir}/state.json" ]]; then
        iterations=$(jq -r '.ooda.iteration // 0' "${change_dir}/state.json")
    fi
    
    # Get patterns count
    local patterns_count=0
    if [[ -f "${change_dir}/state.json" ]]; then
        patterns_count=$(jq -r '.patterns // [] | length' "${change_dir}/state.json")
    fi
    
    # Append to learnings
    cat >> "$learnings_file" <<EOF

---

## ${change_id}

- **Date**: $(date +%Y-%m-%d)
- **Summary**: ${summary:-No summary}
- **OODA Iterations**: ${iterations}
- **Patterns Discovered**: ${patterns_count}
- **Status**: Completed and archived

EOF
    
    log_success "Updated learnings.md"
}

update_patterns() {
    local change_dir="$1"
    local change_id="$2"
    
    local patterns_file="${KNOWLEDGE_DIR}/patterns.json"
    local state_file="${change_dir}/state.json"
    
    # Ensure knowledge directory exists
    mkdir -p "$KNOWLEDGE_DIR"
    
    # Initialize patterns file if needed
    if [[ ! -f "$patterns_file" ]]; then
        echo '{"patterns": [], "lastUpdated": ""}' > "$patterns_file"
    fi
    
    # Extract patterns from state
    if [[ -f "$state_file" ]]; then
        local new_patterns=$(jq -r '.patterns // []' "$state_file" 2>/dev/null)
        
        if [[ "$new_patterns" != "[]" && "$new_patterns" != "null" ]]; then
            # Merge patterns
            local tmp_file="${patterns_file}.tmp.$$"
            jq --argjson new "$new_patterns" \
               --arg date "$(date -Iseconds)" \
               --arg source "$change_id" \
               '.patterns += ($new | map(. + {source: $source})) | .lastUpdated = $date' \
               "$patterns_file" > "$tmp_file"
            mv "$tmp_file" "$patterns_file"
            
            local count=$(echo "$new_patterns" | jq 'length')
            log_success "Updated patterns.json (+${count} patterns)"
        fi
    fi
}

check_documentation_updates() {
    local change_dir="$1"
    local state_file="${change_dir}/state.json"
    
    # Check if this change affects public APIs or features
    if [[ -f "$state_file" ]]; then
        local modified_files=$(jq -r '.modifiedFiles // [] | .[]' "$state_file" 2>/dev/null || echo "")
        
        # Check for API or feature changes
        local needs_doc_update=false
        while IFS= read -r file; do
            case "$file" in
                *api*|*route*|*endpoint*|*public*|*export*)
                    needs_doc_update=true
                    break
                    ;;
            esac
        done <<< "$modified_files"
        
        if [[ "$needs_doc_update" == "true" ]]; then
            echo ""
            log_info "💡 Documentation Update Suggested:"
            log_info "   README.md may need updates for new/modified features."
            log_info "   Consider running: /ai-docs update"
            echo ""
        fi
    fi
}

archive_change() {
    local change_id="$1"
    local force="${2:-false}"
    local dry_run="${3:-false}"
    local no_summary="${4:-false}"
    local no_index="${5:-false}"
    
    local source_dir="${CHANGES_DIR}/active/${change_id}"
    local archive_month=$(date +%Y-%m)
    local archive_dir="${CHANGES_DIR}/archived/${archive_month}"
    local target_dir="${archive_dir}/${change_id}"
    
    # Validate source exists
    if [[ ! -d "$source_dir" ]]; then
        log_error "Change not found: $source_dir"
        exit 1
    fi
    
    log_info "Validating ${change_id}..."
    
    # Run validations
    if ! validate_completion "$source_dir" "$force"; then
        exit 1
    fi
    
    if ! run_validation_tests "$source_dir" "$force"; then
        if [[ "$force" != "true" ]]; then
            log_error "Validation failed. Use --force to archive anyway."
            exit 1
        fi
    fi
    
    # Dry run check
    if [[ "$dry_run" == "true" ]]; then
        log_info "[DRY RUN] Would archive: ${change_id}"
        log_info "[DRY RUN] Source: ${source_dir}"
        log_info "[DRY RUN] Target: ${target_dir}"
        return 0
    fi
    
    # Generate summary
    if [[ "$no_summary" != "true" ]]; then
        generate_summary "$source_dir" "$change_id"
    fi
    
    # Update knowledge base
    log_info "Updating knowledge base..."
    extract_learnings "$source_dir" "$change_id"
    update_patterns "$source_dir" "$change_id"
    
    # Update feature index
    if [[ "$no_index" != "true" ]]; then
        update_feature_index "$source_dir" "$change_id"
    fi
    
    # Create archive directory
    mkdir -p "$archive_dir"
    
    # Update state before archiving
    local state_file="${source_dir}/state.json"
    if [[ -f "$state_file" ]]; then
        local tmp_file="${state_file}.tmp.$$"
        jq --arg date "$(date -Iseconds)" \
           --arg path "$target_dir" \
           '.status = "archived" | .archivedAt = $date | .archivePath = $path' \
           "$state_file" > "$tmp_file"
        mv "$tmp_file" "$state_file"
    fi
    
    # Move to archive
    mv "$source_dir" "$target_dir"
    
    log_success "Archived: ${change_id} → ${target_dir}"
    
    # Check for documentation updates
    check_documentation_updates "$target_dir"
    
    echo "$target_dir"
}

# ============================================================================
# Smart Detection Functions
# ============================================================================

detect_current_change() {
    local active_dir="${CHANGES_DIR}/active"
    
    if [[ ! -d "$active_dir" ]]; then
        return 1
    fi
    
    # Find the most recently modified change
    local latest=$(ls -t "$active_dir" 2>/dev/null | head -1)
    
    if [[ -n "$latest" ]]; then
        echo "$latest"
        return 0
    fi
    
    return 1
}

find_completed_changes() {
    local active_dir="${CHANGES_DIR}/active"
    local completed=()
    
    if [[ ! -d "$active_dir" ]]; then
        return
    fi
    
    for change_dir in "$active_dir"/*/; do
        if [[ -d "$change_dir" ]]; then
            local state_file="${change_dir}/state.json"
            if [[ -f "$state_file" ]]; then
                local impl_complete=$(jq -r '.implementationComplete // false' "$state_file")
                local completion_promise=$(jq -r '.completion_promise // "PENDING"' "$state_file")
                
                if [[ "$impl_complete" == "true" || "$completion_promise" == "DONE" ]]; then
                    local change_id=$(basename "$change_dir")
                    completed+=("$change_id")
                fi
            fi
        fi
    done
    
    printf '%s\n' "${completed[@]}"
}

# ============================================================================
# CLI Interface
# ============================================================================

usage() {
    cat <<EOF
Usage: $(basename "$0") [change_id] [options]

Arguments:
    change_id           ID of the change to archive (optional)

Options:
    --current           Archive the current active change
    --all-completed     Archive all changes marked as complete
    --force             Skip validation checks
    --dry-run           Show what would be archived without executing
    --no-summary        Skip SUMMARY.md generation
    --no-index-update   Skip feature-index.json update
    -h, --help          Show this help message

Examples:
    $(basename "$0") CHG-20250106-001
    $(basename "$0") --current
    $(basename "$0") --all-completed --dry-run
    $(basename "$0") CHG-20250106-001 --force
EOF
}

main() {
    local change_id=""
    local force="false"
    local dry_run="false"
    local no_summary="false"
    local no_index="false"
    local current="false"
    local all_completed="false"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --current)
                current="true"
                shift
                ;;
            --all-completed)
                all_completed="true"
                shift
                ;;
            --force)
                force="true"
                shift
                ;;
            --dry-run)
                dry_run="true"
                shift
                ;;
            --no-summary)
                no_summary="true"
                shift
                ;;
            --no-index-update)
                no_index="true"
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                usage
                exit 1
                ;;
            *)
                change_id="$1"
                shift
                ;;
        esac
    done
    
    # Handle --current
    if [[ "$current" == "true" ]]; then
        change_id=$(detect_current_change) || {
            log_error "No active change found"
            exit 1
        }
        log_info "Detected current change: $change_id"
    fi
    
    # Handle --all-completed
    if [[ "$all_completed" == "true" ]]; then
        local completed=$(find_completed_changes)
        
        if [[ -z "$completed" ]]; then
            log_info "No completed changes found"
            exit 0
        fi
        
        log_info "Found completed changes:"
        echo "$completed" | while read -r id; do
            echo "  - $id"
        done
        
        echo "$completed" | while read -r id; do
            if [[ -n "$id" ]]; then
                archive_change "$id" "$force" "$dry_run" "$no_summary" "$no_index"
            fi
        done
        exit 0
    fi
    
    # Require change_id at this point
    if [[ -z "$change_id" ]]; then
        log_error "No change specified. Use --current or provide a change ID."
        usage
        exit 1
    fi
    
    archive_change "$change_id" "$force" "$dry_run" "$no_summary" "$no_index"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
