#!/usr/bin/env bash
# 收敛评估 - 分析 discussion.md 讨论收敛状态
# 用法: bash evaluate-convergence.sh <discussion-file>
#
# 分析 discussion.md 中的标签和内容，输出收敛指标 JSON:
# {
#   "consensus_count":    N,   — #consensus 标签总数
#   "pending_count":      N,   — #pending 标签总数
#   "rejected_count":     N,   — #rejected 标签总数
#   "needs_input_count":  N,   — #needs-input 标签总数
#   "blocker_count":      N,   — #blocker 标签总数
#   "total_tags":         N,   — 状态标签总数
#   "consensus_ratio":    0.X, — consensus / (consensus + pending + needs-input)
#   "unresolved_mentions": N,  — 未回应的 @ 提及数（在 STATUS 面板中）
#   "current_round":      N,   — 当前轮次
#   "total_entries":      N,   — [Round N] 发言总数
#   "converged":          bool — 收敛判定
#   "recommendation":     "..."— 建议动作
# }

set -euo pipefail

DISCUSSION_FILE="${1:?用法: evaluate-convergence.sh <discussion-file>}"

if [ ! -f "$DISCUSSION_FILE" ]; then
  echo "错误: 讨论文件不存在: $DISCUSSION_FILE" >&2
  exit 1
fi

CONTENT=$(cat "$DISCUSSION_FILE")

# 统计各标签数量
count_tag() {
  local tag="$1"
  local count
  count=$(echo "$CONTENT" | grep -c "$tag" || true)
  echo "$count"
}

CONSENSUS_COUNT=$(count_tag '#consensus')
PENDING_COUNT=$(count_tag '#pending')
REJECTED_COUNT=$(count_tag '#rejected')
NEEDS_INPUT_COUNT=$(count_tag '#needs-input')
BLOCKER_COUNT=$(count_tag '#blocker')

TOTAL_TAGS=$((CONSENSUS_COUNT + PENDING_COUNT + REJECTED_COUNT + NEEDS_INPUT_COUNT + BLOCKER_COUNT))

# 计算共识率
# consensus / (consensus + pending + needs-input)
# 排除 rejected（已否决不影响收敛）
DENOMINATOR=$((CONSENSUS_COUNT + PENDING_COUNT + NEEDS_INPUT_COUNT))
if [ "$DENOMINATOR" -gt 0 ]; then
  # 使用 awk 做浮点除法
  CONSENSUS_RATIO=$(awk "BEGIN {printf \"%.2f\", $CONSENSUS_COUNT / $DENOMINATOR}")
else
  CONSENSUS_RATIO="0.00"
fi

# 统计未解决的 @ 提及（从 STATUS 面板的 mentions 字段）
UNRESOLVED_MENTIONS=$(echo "$CONTENT" | \
  sed -n '/<!-- STATUS/,/-->/p' | \
  { grep -c '^\s*- target:' || true; })

# 获取当前轮次（从 STATUS 面板）
CURRENT_ROUND=$(echo "$CONTENT" | \
  sed -n '/<!-- STATUS/,/-->/p' | \
  grep 'round:' | head -1 | \
  sed 's/.*round:\s*//' | tr -d ' ')
CURRENT_ROUND="${CURRENT_ROUND:-0}"

# 统计 [Round N] 发言总数
TOTAL_ENTRIES=$(echo "$CONTENT" | { grep -c '^\#\#\s*\[Round' || true; })

# 收敛判定:
# 1. consensus_ratio >= 0.7
# 2. blocker_count == 0
# 3. needs_input_count == 0
CONVERGED=false
if [ "$(awk "BEGIN {print ($CONSENSUS_RATIO >= 0.7)}")" = "1" ] && \
   [ "$BLOCKER_COUNT" -eq 0 ] && \
   [ "$NEEDS_INPUT_COUNT" -eq 0 ]; then
  CONVERGED=true
fi

# 生成建议
RECOMMENDATION=""
if [ "$CONVERGED" = true ]; then
  RECOMMENDATION="converged — 可以进入 summarize 阶段"
elif [ "$BLOCKER_COUNT" -gt 0 ]; then
  RECOMMENDATION="blocked — 存在 ${BLOCKER_COUNT} 个阻塞项，需优先解决"
elif [ "$NEEDS_INPUT_COUNT" -gt 0 ]; then
  RECOMMENDATION="waiting — 需要 ${NEEDS_INPUT_COUNT} 个角色提供输入"
elif [ "$PENDING_COUNT" -gt "$CONSENSUS_COUNT" ]; then
  RECOMMENDATION="diverging — 分歧较大，建议继续讨论"
else
  RECOMMENDATION="progressing — 讨论进展中，尚未完全收敛"
fi

# 输出 JSON
cat <<EOF
{
  "consensus_count": ${CONSENSUS_COUNT},
  "pending_count": ${PENDING_COUNT},
  "rejected_count": ${REJECTED_COUNT},
  "needs_input_count": ${NEEDS_INPUT_COUNT},
  "blocker_count": ${BLOCKER_COUNT},
  "total_tags": ${TOTAL_TAGS},
  "consensus_ratio": ${CONSENSUS_RATIO},
  "unresolved_mentions": ${UNRESOLVED_MENTIONS},
  "current_round": ${CURRENT_ROUND},
  "total_entries": ${TOTAL_ENTRIES},
  "converged": ${CONVERGED},
  "recommendation": "${RECOMMENDATION}"
}
EOF
