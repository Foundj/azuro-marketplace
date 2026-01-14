#!/bin/bash
#
# sync-docs.sh - Documentation synchronization for azuro-marketplace
#
# This script:
# 1. Extracts the global version from .claude-plugin/marketplace.json
# 2. Syncs this version to all SKILL.md frontmatter
# 3. Regenerates the plugin comparison table in README.md and README.zh-CN.md
#

set -e

# Setup logger
export LOG_CONTEXT="DocSync"
# Use absolute path for logger if possible, or relative to script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/logger.sh"

MARKETPLACE_JSON="${SCRIPT_DIR}/../.claude-plugin/marketplace.json"
README_EN="${SCRIPT_DIR}/../README.md"
README_ZH="${SCRIPT_DIR}/../README.zh-CN.md"

if [[ ! -f "$MARKETPLACE_JSON" ]]; then
    log_error "marketplace.json not found at $MARKETPLACE_JSON"
    exit 1
fi

# Extract global version
GLOBAL_VERSION=$(jq -r '.metadata.version' "$MARKETPLACE_JSON")
log_info "Syncing documentation to version: ${GLOBAL_VERSION}"

# 1. Sync version to SKILL.md files
log_info "Updating version in SKILL.md files..."
find "${SCRIPT_DIR}/../skills" -name "SKILL.md" | while read -r skill_file; do
    # Only update if the version line exists
    if grep -q "^version:" "$skill_file"; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            sed -i '' "s/^version: .*/version: ${GLOBAL_VERSION}/" "$skill_file"
        else
            sed -i "s/^version: .*/version: ${GLOBAL_VERSION}/" "$skill_file"
        fi
    fi
done

# 2. Generate Plugin Tables
generate_table() {
    local lang="$1" # "en" or "zh"
    local table="| Plugin | Version | Description |\n|--------|---------|-------------|"
    if [[ "$lang" == "zh" ]]; then
        table="| 插件 | 版本 | 描述 |\n|------|------|------|"
    fi

    # Read plugins from JSON
    local plugins_count=$(jq '.plugins | length' "$MARKETPLACE_JSON")
    for ((i=0; i<$plugins_count; i++)); do
        local name=$(jq -r ".plugins[$i].name" "$MARKETPLACE_JSON")
        local ver=$(jq -r ".plugins[$i].version" "$MARKETPLACE_JSON")
        local desc=$(jq -r ".plugins[$i].description" "$MARKETPLACE_JSON")

        # If we had translations in marketplace.json, we'd use them here.
        # For now, we use English descriptions but maintain the Chinese headers in ZH README.
        table="${table}\n| **${name}** | ${ver} | ${desc} |"
    done
    echo -e "$table"
}

update_readme() {
    local file="$1"
    local lang="$2"

    if [[ ! -f "$file" ]]; then
        log_warn "Skip: $file not found"
        return
    fi

    log_info "Updating plugin table in $(basename "$file")..."
    local new_table=$(generate_table "$lang")

    # Use perl for multi-line replacement between markers
    # Using a temporary file to avoid issues with large strings in sed/perl commands
    local tmp_file=$(mktemp)

    # Escape special characters in the table for perl
    # local escaped_table=$(echo "$new_table" | sed 's/[\/&]/\\&/g')

    # More robust way: Use markers and a temp file
    perl -0777 -pe "s/<!-- BEGIN_PLUGIN_TABLE -->.*?<!-- END_PLUGIN_TABLE -->/<!-- BEGIN_PLUGIN_TABLE -->\n$new_table\n<!-- END_PLUGIN_TABLE -->/s" "$file" > "$tmp_file"
    mv "$tmp_file" "$file"
}

update_readme "$README_EN" "en"
update_readme "$README_ZH" "zh"

log_success "Documentation sync complete for v${GLOBAL_VERSION}"
