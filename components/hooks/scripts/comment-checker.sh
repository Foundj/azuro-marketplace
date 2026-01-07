#!/bin/bash

# Comment Checker Hook for ai-dev
# Type: PostToolUse
# Checks AI-generated code for excessive/redundant comments
# Warns but does not block

set -euo pipefail

LOG_PREFIX="💬 Comment"

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

# Patterns to ALLOW (don't count these as suspicious)
# - TODO/FIXME/NOTE/HACK
# - @ts-ignore, @eslint-disable, prettier-ignore
# - JSDoc (/**)
# - Python docstrings (''' or """)
# - License headers

# Patterns that indicate REDUNDANT comments
# These describe WHAT code does, not WHY
SUSPICIOUS_COUNT=0
SUSPICIOUS_LINES=""

while IFS= read -r line; do
    # Skip empty lines
    [[ -z "$line" ]] && continue
    
    # Skip allowed patterns
    echo "$line" | grep -qiE '(TODO|FIXME|NOTE|HACK|@ts-|@eslint|prettier-ignore|istanbul|^\s*\*|^\s*"""|\x27\x27\x27)' && continue
    
    # Check for suspicious patterns (comments that explain WHAT not WHY)
    if echo "$line" | grep -qiE '(//|#)\s*(This|The|We|Here|Set|Get|Create|Initialize|Check|Return|Loop|If|Else|Add|Remove|Update|Delete|Call|Import|Export|Define|Declare)\s'; then
        SUSPICIOUS_COUNT=$((SUSPICIOUS_COUNT + 1))
        SUSPICIOUS_LINES="${SUSPICIOUS_LINES}\n  ${line}"
    fi
done <<< "$CONTENT"

# Only warn if more than 3 suspicious comments
if [[ "$SUSPICIOUS_COUNT" -gt 3 ]]; then
    jq -n \
      --arg count "$SUSPICIOUS_COUNT" \
      --arg lines "$SUSPICIOUS_LINES" \
      '{
        "warning": true,
        "message": "💬 Comment Checker: 检测到 \($count) 个可能冗余的注释\n\($lines)\n\n建议: 注释应说明 WHY 而不是 WHAT。考虑移除描述代码行为的注释。",
        "continue": true
      }'
else
    echo '{"continue": true}'
fi
