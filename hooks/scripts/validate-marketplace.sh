#!/usr/bin/env bash
#
# validate-marketplace.sh - Validate marketplace.json schema
#
# Based on official documentation: https://code.claude.com/docs/plugin-marketplaces
#
# Exit codes:
#   0 - Valid
#   1 - Invalid structure

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

MARKETPLACE_JSON="${1:-.claude-plugin/marketplace.json}"

if [[ ! -f "$MARKETPLACE_JSON" ]]; then
    echo -e "${RED}marketplace.json not found: $MARKETPLACE_JSON${NC}"
    exit 1
fi

# Check if valid JSON
if ! jq empty "$MARKETPLACE_JSON" 2>/dev/null; then
    echo -e "${RED}Invalid JSON syntax in $MARKETPLACE_JSON${NC}"
    exit 1
fi

errors=0

# === Required fields ===

# Check name (required, kebab-case)
name=$(jq -r '.name // empty' "$MARKETPLACE_JSON")
if [[ -z "$name" ]]; then
    echo -e "${RED}Missing required field: name${NC}"
    ((errors++))
elif [[ ! "$name" =~ ^[a-z0-9]+(-[a-z0-9]+)*$ ]]; then
    echo -e "${YELLOW}Warning: name should be kebab-case: $name${NC}"
fi

# Check owner (required)
if ! jq -e '.owner' "$MARKETPLACE_JSON" >/dev/null 2>&1; then
    echo -e "${RED}Missing required field: owner${NC}"
    ((errors++))
else
    # Check owner.name (required)
    owner_name=$(jq -r '.owner.name // empty' "$MARKETPLACE_JSON")
    if [[ -z "$owner_name" ]]; then
        echo -e "${RED}Missing required field: owner.name${NC}"
        ((errors++))
    fi

    # Check for unsupported owner fields
    owner_keys=$(jq -r '.owner | keys[]' "$MARKETPLACE_JSON" 2>/dev/null)
    for key in $owner_keys; do
        if [[ "$key" != "name" && "$key" != "email" ]]; then
            echo -e "${RED}Unsupported owner field: $key (only name and email allowed)${NC}"
            ((errors++))
        fi
    done
fi

# Check plugins array (required)
if ! jq -e '.plugins' "$MARKETPLACE_JSON" >/dev/null 2>&1; then
    echo -e "${RED}Missing required field: plugins${NC}"
    ((errors++))
else
    plugin_count=$(jq '.plugins | length' "$MARKETPLACE_JSON")

    for ((i=0; i<plugin_count; i++)); do
        plugin_name=$(jq -r ".plugins[$i].name // empty" "$MARKETPLACE_JSON")

        # Check plugin.name (required)
        if [[ -z "$plugin_name" ]]; then
            echo -e "${RED}plugins[$i]: Missing required field: name${NC}"
            ((errors++))
            continue
        fi

        # Check plugin.source (required)
        source=$(jq -r ".plugins[$i].source // empty" "$MARKETPLACE_JSON")
        if [[ -z "$source" ]]; then
            echo -e "${RED}plugins[$i] ($plugin_name): Missing required field: source${NC}"
            ((errors++))
        fi

        # Check for unsupported plugin fields
        plugin_keys=$(jq -r ".plugins[$i] | keys[]" "$MARKETPLACE_JSON" 2>/dev/null)
        valid_keys="name source strict description version author homepage repository license keywords category tags skills commands hooks mcpServers lspServers"

        for key in $plugin_keys; do
            if ! echo "$valid_keys" | grep -qw "$key"; then
                echo -e "${RED}plugins[$i] ($plugin_name): Unsupported field: $key${NC}"
                ((errors++))
            fi
        done

        # Check agents field (NOT supported in marketplace schema)
        if jq -e ".plugins[$i].agents" "$MARKETPLACE_JSON" >/dev/null 2>&1; then
            echo -e "${RED}plugins[$i] ($plugin_name): 'agents' field not supported in marketplace schema${NC}"
            echo -e "${YELLOW}  Hint: agents/ directory is auto-discovered when source=\"./\" and strict=false${NC}"
            ((errors++))
        fi

        # Check strict field for source="./"
        if [[ "$source" == "./" ]]; then
            strict=$(jq -r ".plugins[$i].strict // \"true\"" "$MARKETPLACE_JSON")
            if [[ "$strict" != "false" ]]; then
                echo -e "${YELLOW}plugins[$i] ($plugin_name): Consider setting strict=false for source=\"./\"${NC}"
            fi
        fi
    done
fi

# === Summary ===
if [[ $errors -gt 0 ]]; then
    echo -e "${RED}marketplace.json validation failed with $errors error(s)${NC}"
    exit 1
fi

echo -e "${GREEN}marketplace.json schema is valid${NC}"
exit 0
