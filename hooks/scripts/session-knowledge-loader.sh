#!/bin/bash

# Session Knowledge Loader — SessionStart Hook
# Loads recent active knowledge and pending next steps at session start.
# Token budget: ~1500 tokens (10 items * ~150 tokens each)

set -euo pipefail

# Find project root (walk up from pwd looking for .claude-project or .git)
find_project_root() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.claude-project" ]] || [[ -d "$dir/.git" ]]; then
            echo "$dir"
            return 0
        fi
        dir=$(dirname "$dir")
    done
    echo "$PWD"
}

PROJECT_ROOT=$(find_project_root)
KNOWLEDGE_DIR="$PROJECT_ROOT/.claude-project/knowledge"
NODES_FILE="$KNOWLEDGE_DIR/nodes.json"
NEXT_STEPS="$PROJECT_ROOT/codebox/context/next_steps.md"

MAX_ITEMS=10
OUTPUT=""

# Load knowledge nodes (if available)
if [[ -f "$NODES_FILE" ]] && command -v jq &> /dev/null; then
    # Get active nodes, sorted by created_at descending, limited to MAX_ITEMS
    ACTIVE_NODES=$(jq -r --argjson max "$MAX_ITEMS" '
        [.[] | select(.status == "active" or (.status == null))]
        | sort_by(.created_at) | reverse
        | .[:$max]
        | .[]
        | "- [\(.type)] \(.title) (\(.project)) — \(.description // "no desc")[tags: \(.tags | join(", "))]"
    ' "$NODES_FILE" 2>/dev/null || echo "")

    if [[ -n "$ACTIVE_NODES" ]]; then
        NODE_COUNT=$(echo "$ACTIVE_NODES" | wc -l | tr -d ' ')
        OUTPUT+="[Knowledge Graph] ${NODE_COUNT} active records loaded:
${ACTIVE_NODES}
"
    fi
fi

# Load next steps (if available)
if [[ -f "$NEXT_STEPS" ]]; then
    # Read first 20 lines to stay within token budget
    STEPS=$(head -20 "$NEXT_STEPS" 2>/dev/null || echo "")
    if [[ -n "$STEPS" ]]; then
        OUTPUT+="
[Next Steps] From previous session:
${STEPS}
"
    fi
fi

# Only output if there's something to report
if [[ -n "$OUTPUT" ]]; then
    echo "$OUTPUT"
fi

exit 0
