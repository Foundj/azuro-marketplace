#!/bin/bash

# Project Scanner Script for ai-dev
# Performs deep scan during initialization, incremental scan for daily use
# Generates project-snapshot.json for context awareness

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

CODEBOX_DIR="codebox"
SNAPSHOT_FILE="${CODEBOX_DIR}/project-snapshot.json"
MAX_FILE_SIZE=100000  # 100KB max for content reading

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    echo "🔍 Scanner: $1"
}

log_warn() {
    echo "🔍 Scanner ⚠️: $1" >&2
}

# ============================================================================
# Deep Scan Functions (for initialization)
# ============================================================================

# Detect tech stack from package.json, Cargo.toml, etc.
detect_tech_stack() {
    local tech_stack=()
    
    # Node.js / JavaScript
    if [[ -f "package.json" ]]; then
        local deps=$(jq -r '.dependencies // {} | keys[]' package.json 2>/dev/null || echo "")
        local devDeps=$(jq -r '.devDependencies // {} | keys[]' package.json 2>/dev/null || echo "")
        
        # Frameworks
        [[ "$deps" == *"next"* ]] && tech_stack+=("next.js")
        [[ "$deps" == *"react"* ]] && tech_stack+=("react")
        [[ "$deps" == *"vue"* ]] && tech_stack+=("vue")
        [[ "$deps" == *"express"* ]] && tech_stack+=("express")
        [[ "$deps" == *"hono"* ]] && tech_stack+=("hono")
        
        # ORMs
        [[ "$deps" == *"drizzle"* ]] && tech_stack+=("drizzle")
        [[ "$deps" == *"prisma"* ]] && tech_stack+=("prisma")
        
        # TypeScript
        [[ -f "tsconfig.json" ]] && tech_stack+=("typescript")
        
        # Styling
        [[ "$devDeps" == *"tailwindcss"* ]] && tech_stack+=("tailwind")
        
        # Testing
        [[ "$devDeps" == *"vitest"* ]] && tech_stack+=("vitest")
        [[ "$devDeps" == *"jest"* ]] && tech_stack+=("jest")
        [[ "$devDeps" == *"playwright"* ]] && tech_stack+=("playwright")
    fi
    
    # Rust
    if [[ -f "Cargo.toml" ]]; then
        tech_stack+=("rust")
    fi
    
    # Python
    if [[ -f "requirements.txt" || -f "pyproject.toml" ]]; then
        tech_stack+=("python")
    fi
    
    # Go
    if [[ -f "go.mod" ]]; then
        tech_stack+=("go")
    fi
    
    printf '%s\n' "${tech_stack[@]}" | jq -R . | jq -s .
}

# Detect architectural patterns
detect_patterns() {
    local patterns=()
    
    # Check for common patterns
    [[ -d "src/repositories" || -d "src/lib/repositories" ]] && patterns+=("repository")
    [[ -d "src/services" || -d "src/lib/services" ]] && patterns+=("service-layer")
    [[ -d "src/controllers" ]] && patterns+=("mvc")
    [[ -d "src/components" ]] && patterns+=("component-based")
    [[ -d "src/hooks" ]] && patterns+=("custom-hooks")
    [[ -d "src/stores" || -d "src/store" ]] && patterns+=("state-management")
    [[ -d "src/api" || -d "src/app/api" ]] && patterns+=("api-routes")
    
    printf '%s\n' "${patterns[@]}" | jq -R . | jq -s .
}

# Scan directory structure
scan_modules() {
    local modules=()
    
    # Common module directories
    for dir in src/app src/pages src/features src/modules; do
        if [[ -d "$dir" ]]; then
            for subdir in "$dir"/*/; do
                if [[ -d "$subdir" ]]; then
                    local name=$(basename "$subdir")
                    # Skip common non-feature dirs
                    [[ "$name" == "api" || "$name" == "lib" || "$name" == "utils" ]] && continue
                    modules+=("$name")
                fi
            done
        fi
    done
    
    printf '%s\n' "${modules[@]}" | jq -R . | jq -s .
}

# Get entry points
get_entry_points() {
    local entries=()
    
    # Next.js
    [[ -d "src/app" ]] && entries+=("src/app/")
    [[ -d "src/pages" ]] && entries+=("src/pages/")
    
    # General
    [[ -d "src/lib" ]] && entries+=("src/lib/")
    [[ -d "src/components" ]] && entries+=("src/components/")
    
    # API
    [[ -d "src/app/api" ]] && entries+=("src/app/api/")
    [[ -d "api" ]] && entries+=("api/")
    
    printf '%s\n' "${entries[@]}" | jq -R . | jq -s .
}

# Count files by type
count_files() {
    local counts="{}"
    
    counts=$(echo "$counts" | jq --arg ts "$(find . -name '*.ts' -o -name '*.tsx' 2>/dev/null | wc -l | tr -d ' ')" '.typescript = ($ts | tonumber)')
    counts=$(echo "$counts" | jq --arg js "$(find . -name '*.js' -o -name '*.jsx' 2>/dev/null | wc -l | tr -d ' ')" '.javascript = ($js | tonumber)')
    counts=$(echo "$counts" | jq --arg md "$(find . -name '*.md' 2>/dev/null | wc -l | tr -d ' ')" '.markdown = ($md | tonumber)')
    counts=$(echo "$counts" | jq --arg json "$(find . -name '*.json' 2>/dev/null | wc -l | tr -d ' ')" '.json = ($json | tonumber)')
    
    echo "$counts"
}

# Full deep scan
deep_scan() {
    log_info "Starting deep scan..."
    
    local start_time=$(date +%s)
    
    local tech_stack=$(detect_tech_stack)
    local patterns=$(detect_patterns)
    local modules=$(scan_modules)
    local entry_points=$(get_entry_points)
    local file_counts=$(count_files)
    
    local end_time=$(date +%s)
    local duration=$((end_time - start_time))
    
    # Generate snapshot
    jq -n \
        --argjson tech_stack "$tech_stack" \
        --argjson patterns "$patterns" \
        --argjson modules "$modules" \
        --argjson entry_points "$entry_points" \
        --argjson file_counts "$file_counts" \
        --arg scan_date "$(date -Iseconds)" \
        --arg scan_duration "${duration}s" \
        --arg scan_type "deep" \
        '{
            tech_stack: $tech_stack,
            patterns: $patterns,
            modules: $modules,
            entry_points: $entry_points,
            file_counts: $file_counts,
            scan_date: $scan_date,
            scan_duration: $scan_duration,
            scan_type: $scan_type
        }'
}

# ============================================================================
# Incremental Scan Functions (for daily use)
# ============================================================================

# Get recent changes from git
get_git_changes() {
    local commits="${1:-10}"
    
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "[]"
        return
    fi
    
    # Get changed files
    local changed_files=$(git diff HEAD~"$commits" --name-only 2>/dev/null | head -50)
    
    # Get recent commits
    local recent_commits=$(git log --oneline -"$commits" 2>/dev/null | head -20)
    
    jq -n \
        --arg files "$changed_files" \
        --arg commits "$recent_commits" \
        '{
            changed_files: ($files | split("\n") | map(select(length > 0))),
            recent_commits: ($commits | split("\n") | map(select(length > 0)))
        }'
}

# Quick incremental scan
incremental_scan() {
    log_info "Starting incremental scan..."
    
    local git_changes=$(get_git_changes 10)
    
    # Check if snapshot exists
    if [[ ! -f "$SNAPSHOT_FILE" ]]; then
        log_warn "No snapshot found, performing deep scan"
        deep_scan
        return
    fi
    
    # Get snapshot age
    local snapshot_date=$(jq -r '.scan_date // empty' "$SNAPSHOT_FILE")
    if [[ -z "$snapshot_date" ]]; then
        log_warn "Invalid snapshot, performing deep scan"
        deep_scan
        return
    fi
    
    # Merge incremental changes with existing snapshot
    local existing=$(cat "$SNAPSHOT_FILE")
    
    echo "$existing" | jq \
        --argjson git_changes "$git_changes" \
        --arg incremental_scan_date "$(date -Iseconds)" \
        '. + {
            incremental_scan_date: $incremental_scan_date,
            git_changes: $git_changes
        }'
}

# ============================================================================
# Utility Functions
# ============================================================================

# Check if deep scan is needed
needs_deep_scan() {
    # No snapshot exists
    [[ ! -f "$SNAPSHOT_FILE" ]] && return 0
    
    # Snapshot is too old (> 7 days)
    local snapshot_date=$(jq -r '.scan_date // empty' "$SNAPSHOT_FILE")
    if [[ -n "$snapshot_date" ]]; then
        local snapshot_ts=$(date -d "$snapshot_date" +%s 2>/dev/null || date -j -f "%Y-%m-%dT%H:%M:%S" "$snapshot_date" +%s 2>/dev/null || echo 0)
        local now_ts=$(date +%s)
        local age_days=$(( (now_ts - snapshot_ts) / 86400 ))
        
        [[ "$age_days" -gt 7 ]] && return 0
    fi
    
    return 1
}

# Save snapshot
save_snapshot() {
    local content="$1"
    
    mkdir -p "$(dirname "$SNAPSHOT_FILE")"
    echo "$content" > "$SNAPSHOT_FILE"
    
    log_info "Saved: $SNAPSHOT_FILE"
}

# ============================================================================
# CLI Interface
# ============================================================================

usage() {
    cat <<EOF
Usage: $(basename "$0") <command> [options]

Commands:
    deep              Perform full deep scan (for initialization)
    incremental       Perform quick incremental scan (daily use)
    auto              Auto-detect: deep if needed, incremental otherwise
    status            Show current snapshot status

Options:
    -o, --output      Output to stdout instead of file
    -h, --help        Show this help

Examples:
    $(basename "$0") deep           # Full project scan
    $(basename "$0") incremental    # Quick git-based scan
    $(basename "$0") auto           # Auto-detect scan type
    $(basename "$0") status         # Show snapshot info
EOF
}

main() {
    local command="${1:-auto}"
    local output_to_file=true
    
    # Parse flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -o|--output)
                output_to_file=false
                shift
                ;;
            -h|--help)
                usage
                exit 0
                ;;
            *)
                command="$1"
                shift
                ;;
        esac
    done
    
    case "$command" in
        deep)
            local result=$(deep_scan)
            if [[ "$output_to_file" == true ]]; then
                save_snapshot "$result"
            else
                echo "$result"
            fi
            ;;
            
        incremental)
            local result=$(incremental_scan)
            if [[ "$output_to_file" == true ]]; then
                save_snapshot "$result"
            else
                echo "$result"
            fi
            ;;
            
        auto)
            if needs_deep_scan; then
                log_info "Deep scan needed"
                local result=$(deep_scan)
            else
                log_info "Incremental scan sufficient"
                local result=$(incremental_scan)
            fi
            
            if [[ "$output_to_file" == true ]]; then
                save_snapshot "$result"
            else
                echo "$result"
            fi
            ;;
            
        status)
            if [[ -f "$SNAPSHOT_FILE" ]]; then
                log_info "Snapshot exists:"
                jq '{
                    scan_date,
                    scan_type,
                    scan_duration,
                    tech_stack_count: (.tech_stack | length),
                    modules_count: (.modules | length),
                    patterns_count: (.patterns | length)
                }' "$SNAPSHOT_FILE"
            else
                log_warn "No snapshot found. Run 'deep' to create one."
                exit 1
            fi
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
