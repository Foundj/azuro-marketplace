#!/bin/bash

# Context Window Monitor Hook for ai-dev
# Type: PostToolUse
# Monitors context window usage and provides guidance at 85% threshold
# Implements Context Window Anxiety Management pattern from agentic-patterns.com

set -euo pipefail

LOG_PREFIX="📊 Context"

# Configuration
THRESHOLD_WARN=85

# Read hook input from stdin
HOOK_INPUT=$(cat)

# Extract context usage info from hook input
# Note: The actual field names depend on the hook system implementation
CONTEXT_USED=$(echo "$HOOK_INPUT" | jq -r '.context_used // .tokens_used // 0' 2>/dev/null || echo "0")
CONTEXT_MAX=$(echo "$HOOK_INPUT" | jq -r '.context_max // .max_tokens // 0' 2>/dev/null || echo "0")

# If context info not available, try alternative sources
if [[ "$CONTEXT_MAX" -eq 0 ]]; then
    # Try to read from session state if available
    SESSION_STATE=$(echo "$HOOK_INPUT" | jq -r '.session // empty' 2>/dev/null || echo "")
    if [[ -n "$SESSION_STATE" ]]; then
        CONTEXT_USED=$(echo "$SESSION_STATE" | jq -r '.context_used // 0' 2>/dev/null || echo "0")
        CONTEXT_MAX=$(echo "$SESSION_STATE" | jq -r '.context_max // 0' 2>/dev/null || echo "0")
    fi
fi

# If still no context info, exit without action
if [[ "$CONTEXT_MAX" -eq 0 ]]; then
    exit 0
fi

# Ensure numeric values
CONTEXT_USED=${CONTEXT_USED//[^0-9]/}
CONTEXT_MAX=${CONTEXT_MAX//[^0-9]/}

if [[ -z "$CONTEXT_USED" ]] || [[ -z "$CONTEXT_MAX" ]]; then
    exit 0
fi

# Calculate percentage
USAGE_PCT=$((CONTEXT_USED * 100 / CONTEXT_MAX))

# Check if above threshold
if [[ "$USAGE_PCT" -ge "$THRESHOLD_WARN" ]]; then
    # Calculate remaining tokens
    REMAINING=$((CONTEXT_MAX - CONTEXT_USED))
    REMAINING_K=$((REMAINING / 1000))
    
    # Determine severity and message
    if [[ "$USAGE_PCT" -ge 95 ]]; then
        SEVERITY="critical"
        MESSAGE="🔴 上下文使用率: ${USAGE_PCT}% (剩余 ${REMAINING_K}K tokens)

紧急建议:
1. 立即完成当前任务
2. 考虑使用 /compact 压缩会话
3. 保存重要上下文到文件

当前操作可能因上下文溢出而失败。"
    elif [[ "$USAGE_PCT" -ge 90 ]]; then
        SEVERITY="high"
        MESSAGE="🟠 上下文使用率: ${USAGE_PCT}% (剩余 ${REMAINING_K}K tokens)

建议:
1. 尽快完成当前任务
2. 避免读取大文件
3. 准备压缩上下文"
    else
        SEVERITY="medium"
        MESSAGE="🟡 上下文使用率: ${USAGE_PCT}% (剩余 ${REMAINING_K}K tokens)

提示:
- 上下文空间充足，不需要着急
- 如需继续大量操作，可考虑拆分任务"
    fi
    
    # Log warning
    echo "${LOG_PREFIX}: Warning - ${USAGE_PCT}% context usage" >&2
    
    # Output JSON with warning
    jq -n \
      --arg pct "$USAGE_PCT" \
      --arg remaining "$REMAINING_K" \
      --arg severity "$SEVERITY" \
      --arg message "$MESSAGE" \
      '{
        "decision": "allow",
        "systemMessage": $message,
        "metadata": {
          "contextUsage": ($pct | tonumber),
          "remainingTokensK": ($remaining | tonumber),
          "severity": $severity,
          "hook": "context-window-monitor"
        }
      }'
    exit 0
fi

# Below threshold - no action needed
exit 0
