#!/bin/bash

# Comment Checker Hook for ai-dev
# Type: PostToolUse
# Based on Superpowers pattern - Detects and warns about AI slop
# AI slop = unnecessary comments, over-engineering markers, meaningless TODOs

set -euo pipefail

LOG_PREFIX="🧹 AI-Slop"

# Read hook input from stdin
HOOK_INPUT=$(cat)

TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // ""' 2>/dev/null || echo "")
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.file_path // ""' 2>/dev/null || echo "")

# Only check Write/Edit operations
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "write" && "$TOOL_NAME" != "edit" ]]; then
    echo '{"continue": true}'
    exit 0
fi

# Skip non-code files
if [[ ! "$FILE_PATH" =~ \.(ts|tsx|js|jsx|py|go|rs|java|cpp|c|cs|rb|php|swift|kt)$ ]]; then
    echo '{"continue": true}'
    exit 0
fi

# Get the content
CONTENT=$(echo "$HOOK_INPUT" | jq -r '.content // ""' 2>/dev/null || echo "")

if [[ -z "$CONTENT" ]]; then
    echo '{"continue": true}'
    exit 0
fi

# ============================================================================
# AI Slop Detection Patterns (Enhanced from Superpowers)
# ============================================================================

SUSPICIOUS_COUNT=0
SUSPICIOUS_LINES=""

while IFS= read -r line; do
    # Skip empty lines
    [[ -z "$line" ]] && continue

    # Skip allowed patterns (TODO/FIXME/NOTE, JSDoc, docstrings, pragmas)
    if echo "$line" | grep -qiE '(TODO:|FIXME:|NOTE:|HACK:|@ts-|@eslint|prettier-ignore|istanbul)'; then
        continue
    fi
    if echo "$line" | grep -qE '^\s*\*|^\s*"""|^\s*'"'"'{3}'; then
        continue
    fi

    # Pattern 1: Comments that explain WHAT not WHY
    if echo "$line" | grep -qiE '(//|#)\s*(This|The|We|Here|Set|Get|Create|Initialize|Check|Return|Loop|If|Else|Add|Remove|Update|Delete|Call|Import|Export|Define|Declare)\s'; then
        SUSPICIOUS_COUNT=$((SUSPICIOUS_COUNT + 1))
        SUSPICIOUS_LINES="${SUSPICIOUS_LINES}\n  [WHAT not WHY] ${line}"
        continue
    fi

    # Pattern 2: Redundant type annotations in comments
    if echo "$line" | grep -qiE '(//|#)\s*(string|number|boolean|array|object|integer|float)\s*$'; then
        SUSPICIOUS_COUNT=$((SUSPICIOUS_COUNT + 1))
        SUSPICIOUS_LINES="${SUSPICIOUS_LINES}\n  [Redundant type] ${line}"
        continue
    fi

    # Pattern 3: AI confidence markers
    if echo "$line" | grep -qiE '(//|#)\s*(Note:|Important:|Remember:|Tip:|Warning:)\s'; then
        SUSPICIOUS_COUNT=$((SUSPICIOUS_COUNT + 1))
        SUSPICIOUS_LINES="${SUSPICIOUS_LINES}\n  [AI marker] ${line}"
        continue
    fi

    # Pattern 4: Step-by-step narration
    if echo "$line" | grep -qiE '(//|#)\s*(First,|Second,|Third,|Next,|Then,|Finally,|Step\s*[0-9])'; then
        SUSPICIOUS_COUNT=$((SUSPICIOUS_COUNT + 1))
        SUSPICIOUS_LINES="${SUSPICIOUS_LINES}\n  [Step narration] ${line}"
        continue
    fi

    # Pattern 5: Obvious code description
    if echo "$line" | grep -qiE '(//|#)\s*(returns?|calls?|creates?|updates?|deletes?|fetches?|saves?)\s+(the|a|an)\s'; then
        SUSPICIOUS_COUNT=$((SUSPICIOUS_COUNT + 1))
        SUSPICIOUS_LINES="${SUSPICIOUS_LINES}\n  [Obvious] ${line}"
        continue
    fi

done <<< "$CONTENT"

# Only warn if more than 2 suspicious comments (lowered threshold)
if [[ "$SUSPICIOUS_COUNT" -gt 2 ]]; then
    jq -n \
      --arg count "$SUSPICIOUS_COUNT" \
      --arg lines "$SUSPICIOUS_LINES" \
      '{
        "warning": true,
        "message": "🧹 AI Slop Detected: \($count) redundant comments\n\($lines)\n\nPrinciple: Comments should explain WHY, not WHAT.\nLet the code speak for itself.",
        "continue": true
      }'
else
    echo '{"continue": true}'
fi
