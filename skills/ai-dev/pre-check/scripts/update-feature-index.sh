#!/bin/bash

# Update Feature Index
# Adds a new feature entry to the feature index after change completion
# Used during archive process

set -euo pipefail

AGENT_DIR="${AGENT_DIR:-.agent}"
INDEX_FILE="${AGENT_DIR}/knowledge/feature-index.json"

log_info() {
    echo "📚 Feature Index: $1"
}

# Initialize empty feature index if not exists
init_index() {
    if [[ ! -f "$INDEX_FILE" ]]; then
        mkdir -p "$(dirname "$INDEX_FILE")"
        cat > "$INDEX_FILE" <<'EOF'
{
  "version": "1.0",
  "last_updated": "",
  "features": [],
  "patterns": []
}
EOF
        log_info "Initialized new feature index"
    fi
}

# Extract keywords from file content
extract_keywords_from_files() {
    local files="$1"
    local keywords=()
    
    for file in $files; do
        if [[ -f "$file" ]]; then
            # Extract function/class names
            local names=$(grep -oE '(function|class|interface|type|const|export)\s+[A-Za-z_][A-Za-z0-9_]*' "$file" 2>/dev/null | \
                awk '{print $2}' | head -10)
            
            for name in $names; do
                # Convert to searchable keywords
                local lower=$(echo "$name" | sed 's/\([A-Z]\)/ \1/g' | tr '[:upper:]' '[:lower:]' | tr -s ' ')
                keywords+=($lower)
            done
        fi
    done
    
    # Unique and format as JSON array
    printf '%s\n' "${keywords[@]}" | sort -u | head -20 | jq -R . | jq -s .
}

# Add a feature to the index
add_feature() {
    local change_id="$1"
    local feature_name="$2"
    local description="$3"
    local files="$4"  # Space-separated list of files
    
    init_index
    
    # Convert files to array
    local files_json=$(echo "$files" | tr ' ' '\n' | grep -v '^$' | jq -R . | jq -s .)
    
    # Extract keywords from files
    local keywords=$(extract_keywords_from_files "$files")
    
    # Find entry point (first file)
    local entry_point=$(echo "$files" | tr ' ' '\n' | head -1)
    
    # Build feature entry
    local feature=$(jq -n \
        --arg name "$feature_name" \
        --arg desc "$description" \
        --argjson keywords "$keywords" \
        --argjson files "$files_json" \
        --arg entry "$entry_point" \
        --arg created "$(date +%Y-%m-%d)" \
        --arg change_id "$change_id" \
        '{
            name: $name,
            description: $desc,
            keywords: $keywords,
            files: $files,
            entry_point: $entry,
            created: $created,
            change_id: $change_id
        }')
    
    # Check if feature already exists
    local existing=$(jq --arg id "$change_id" '.features[] | select(.change_id == $id)' "$INDEX_FILE")
    
    if [[ -n "$existing" ]]; then
        # Update existing
        log_info "Updating existing feature: $change_id"
        jq --arg id "$change_id" --argjson feature "$feature" \
            '.features = [.features[] | if .change_id == $id then $feature else . end]' \
            "$INDEX_FILE" > "${INDEX_FILE}.tmp"
    else
        # Add new
        log_info "Adding new feature: $feature_name"
        jq --argjson feature "$feature" \
            '.features += [$feature]' \
            "$INDEX_FILE" > "${INDEX_FILE}.tmp"
    fi
    
    # Update timestamp and save
    jq --arg ts "$(date -Iseconds)" '.last_updated = $ts' "${INDEX_FILE}.tmp" > "$INDEX_FILE"
    rm -f "${INDEX_FILE}.tmp"
    
    log_info "Feature index updated"
}

# Remove a feature from the index
remove_feature() {
    local change_id="$1"
    
    if [[ ! -f "$INDEX_FILE" ]]; then
        log_info "No feature index found"
        return
    fi
    
    jq --arg id "$change_id" '.features = [.features[] | select(.change_id != $id)]' \
        "$INDEX_FILE" > "${INDEX_FILE}.tmp"
    mv "${INDEX_FILE}.tmp" "$INDEX_FILE"
    
    log_info "Removed feature: $change_id"
}

# Search features by keyword
search_features() {
    local keyword="$1"
    
    if [[ ! -f "$INDEX_FILE" ]]; then
        echo "[]"
        return
    fi
    
    jq --arg kw "$keyword" \
        '[.features[] | select(.keywords[] | contains($kw))]' \
        "$INDEX_FILE"
}

# List all features
list_features() {
    if [[ ! -f "$INDEX_FILE" ]]; then
        echo "No feature index found"
        return
    fi
    
    jq -r '.features[] | "\(.change_id): \(.name) - \(.description)"' "$INDEX_FILE"
}

# CLI
usage() {
    cat <<EOF
Usage: $(basename "$0") <command> [options]

Commands:
    add <change_id> <name> <description> <files...>  Add/update a feature
    remove <change_id>                                Remove a feature
    search <keyword>                                  Search features by keyword
    list                                              List all features
    init                                              Initialize empty index

Examples:
    $(basename "$0") add 001-user-auth "UserAuthentication" "Login system" src/services/AuthService.ts
    $(basename "$0") search auth
    $(basename "$0") list
EOF
}

main() {
    local command="${1:-}"
    shift || true
    
    case "$command" in
        add)
            if [[ $# -lt 4 ]]; then
                echo "Error: add requires change_id, name, description, and files" >&2
                exit 1
            fi
            local change_id="$1"
            local name="$2"
            local desc="$3"
            shift 3
            local files="$*"
            add_feature "$change_id" "$name" "$desc" "$files"
            ;;
        remove)
            remove_feature "${1:-}"
            ;;
        search)
            search_features "${1:-}"
            ;;
        list)
            list_features
            ;;
        init)
            init_index
            ;;
        -h|--help|"")
            usage
            ;;
        *)
            echo "Unknown command: $command" >&2
            usage
            exit 1
            ;;
    esac
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
