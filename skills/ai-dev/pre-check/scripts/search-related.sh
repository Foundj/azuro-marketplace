#!/bin/bash

# Search Related Code
# Searches codebase for code related to a given task
# Used in pre-implementation check

set -euo pipefail

log_info() {
    echo "🔍 Search: $1" >&2
}

# Extract keywords from task description
extract_keywords() {
    local task="$1"
    
    # Remove common words and extract meaningful terms
    echo "$task" | tr '[:upper:]' '[:lower:]' | \
        tr -cs '[:alnum:]' '\n' | \
        grep -vE '^(the|a|an|is|are|to|for|in|on|at|by|with|and|or|of|create|implement|add|update|fix|make|build|get|set)$' | \
        grep -E '.{3,}' | \
        head -10
}

# Search for related files
search_files() {
    local keywords="$1"
    local results=()
    
    for keyword in $keywords; do
        # Case-insensitive file name search
        local files=$(find . -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \) \
            -iname "*${keyword}*" 2>/dev/null | head -5)
        
        for file in $files; do
            results+=("$file")
        done
    done
    
    # Unique results
    printf '%s\n' "${results[@]}" | sort -u | head -10
}

# Search for related code content
search_content() {
    local keywords="$1"
    local pattern=""
    
    # Build regex pattern
    for keyword in $keywords; do
        if [[ -n "$pattern" ]]; then
            pattern="${pattern}|${keyword}"
        else
            pattern="$keyword"
        fi
    done
    
    if [[ -z "$pattern" ]]; then
        return
    fi
    
    # Search with grep
    grep -rlE "$pattern" --include="*.ts" --include="*.tsx" . 2>/dev/null | head -20
}

# Check feature index for similar features
check_feature_index() {
    local keywords="$1"
    local index_file="${AGENT_DIR:-.agent}/knowledge/feature-index.json"
    
    if [[ ! -f "$index_file" ]]; then
        return
    fi
    
    for keyword in $keywords; do
        jq -r --arg kw "$keyword" \
            '.features[] | select(.keywords[] | contains($kw)) | .files[]' \
            "$index_file" 2>/dev/null || true
    done | sort -u
}

# Main search function
search_related() {
    local task="$1"
    
    log_info "Extracting keywords from task..."
    local keywords=$(extract_keywords "$task")
    
    if [[ -z "$keywords" ]]; then
        echo "[]"
        return
    fi
    
    log_info "Searching for related files..."
    local file_matches=$(search_files "$keywords")
    
    log_info "Searching content..."
    local content_matches=$(search_content "$keywords")
    
    log_info "Checking feature index..."
    local index_matches=$(check_feature_index "$keywords")
    
    # Combine and deduplicate
    local all_matches=$(printf '%s\n%s\n%s' "$file_matches" "$content_matches" "$index_matches" | \
        grep -v '^$' | sort -u | head -15)
    
    # Output as JSON array
    if [[ -n "$all_matches" ]]; then
        echo "$all_matches" | jq -R . | jq -s .
    else
        echo "[]"
    fi
}

# Calculate relevance score for each file
score_results() {
    local task="$1"
    local files="$2"
    
    local keywords=$(extract_keywords "$task")
    local scored="[]"
    
    for file in $(echo "$files" | jq -r '.[]'); do
        local score=0
        local matches=""
        
        for keyword in $keywords; do
            if grep -qi "$keyword" "$file" 2>/dev/null; then
                score=$((score + 1))
                matches="${matches}${keyword},"
            fi
        done
        
        scored=$(echo "$scored" | jq --arg f "$file" --argjson s "$score" --arg m "$matches" \
            '. + [{"file": $f, "score": $s, "matches": $m}]')
    done
    
    # Sort by score descending
    echo "$scored" | jq 'sort_by(-.score)'
}

# CLI
main() {
    local task="${1:-}"
    local score_mode=false
    
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --score)
                score_mode=true
                shift
                ;;
            -h|--help)
                echo "Usage: $(basename "$0") <task-description> [--score]"
                echo "Searches for code related to the given task."
                exit 0
                ;;
            *)
                task="$1"
                shift
                ;;
        esac
    done
    
    if [[ -z "$task" ]]; then
        echo "Error: Task description required" >&2
        exit 1
    fi
    
    local results=$(search_related "$task")
    
    if [[ "$score_mode" == true ]]; then
        score_results "$task" "$results"
    else
        echo "$results"
    fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
