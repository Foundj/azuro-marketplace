#!/usr/bin/env bash
#
# validate-hooks.sh - Validate hooks.json structure
#
# Exit codes:
#   0 - Valid
#   1 - Invalid structure

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

HOOKS_JSON="${1:-components/hooks/hooks.json}"

if [[ ! -f "$HOOKS_JSON" ]]; then
    echo -e "${RED}❌ hooks.json not found: $HOOKS_JSON${NC}"
    exit 1
fi

# Check if valid JSON
if ! jq empty "$HOOKS_JSON" 2>/dev/null; then
    echo -e "${RED}❌ Invalid JSON syntax in $HOOKS_JSON${NC}"
    exit 1
fi

# Check for required "hooks" wrapper
if ! jq -e '.hooks' "$HOOKS_JSON" >/dev/null 2>&1; then
    echo -e "${RED}❌ hooks.json missing required 'hooks' wrapper object${NC}"
    echo ""
    echo "Expected structure:"
    echo '  { "hooks": { "Stop": [...], "PreToolUse": [...] } }'
    echo ""
    echo "Found:"
    jq 'keys' "$HOOKS_JSON"
    exit 1
fi

# Validate hook event types
VALID_EVENTS="PreToolUse PostToolUse Stop Notification SubagentStop"
for event in $(jq -r '.hooks | keys[]' "$HOOKS_JSON" 2>/dev/null); do
    if ! echo "$VALID_EVENTS" | grep -qw "$event"; then
        echo -e "${RED}❌ Unknown hook event type: $event${NC}"
        echo "Valid types: $VALID_EVENTS"
        exit 1
    fi
done

# Validate each hook has required fields
for event in $(jq -r '.hooks | keys[]' "$HOOKS_JSON" 2>/dev/null); do
    idx=0
    while jq -e ".hooks.$event[$idx]" "$HOOKS_JSON" >/dev/null 2>&1; do
        # Check matcher exists
        if ! jq -e ".hooks.$event[$idx].matcher" "$HOOKS_JSON" >/dev/null 2>&1; then
            echo -e "${RED}❌ hooks.$event[$idx] missing 'matcher' field${NC}"
            exit 1
        fi
        
        # Check hooks array exists
        if ! jq -e ".hooks.$event[$idx].hooks" "$HOOKS_JSON" >/dev/null 2>&1; then
            echo -e "${RED}❌ hooks.$event[$idx] missing 'hooks' array${NC}"
            exit 1
        fi
        
        ((idx++)) || true
    done
done

echo -e "${GREEN}✅ hooks.json structure is valid${NC}"
exit 0
