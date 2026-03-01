#!/usr/bin/env bash
# 单轮编排 - 协调一轮讨论中所有角色的发言
# 用法: bash orchestrate-round.sh <discussion-dir> <assignments-file> [round]
#
# assignments-file 格式（JSON）:
# {
#   "assignments": [
#     {"role": "@PM", "tool": "codex", "prompt_file": "prompts/pm-prompt.md"},
#     {"role": "@Architect", "tool": "gemini", "prompt_file": "prompts/architect-prompt.md"}
#   ]
# }
#
# 工作流:
#   1. 读取角色分配
#   2. 按顺序执行每个角色（轮内顺序，保证后续角色能看到前序发言）
#   3. 每次调用后 parse-response.sh 解析并追加到 discussion.md
#   4. 全部完成后 evaluate-convergence.sh 评估收敛
#   5. 输出本轮结果摘要

set -euo pipefail

DISCUSSION_DIR="${1:?用法: orchestrate-round.sh <discussion-dir> <assignments-file> [round]}"
ASSIGNMENTS_FILE="${2:?请提供角色分配文件}"
ROUND="${3:-}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISCUSSION_FILE="${DISCUSSION_DIR}/discussion.md"

# 验证输入
if [ ! -d "$DISCUSSION_DIR" ]; then
  echo "错误: 讨论目录不存在: $DISCUSSION_DIR" >&2
  exit 1
fi

if [ ! -f "$DISCUSSION_FILE" ]; then
  echo "错误: discussion.md 不存在: $DISCUSSION_FILE" >&2
  exit 1
fi

if [ ! -f "$ASSIGNMENTS_FILE" ]; then
  echo "错误: 分配文件不存在: $ASSIGNMENTS_FILE" >&2
  exit 1
fi

# 检查 jq 是否可用
if ! command -v jq &>/dev/null; then
  echo "错误: 需要安装 jq 来解析 JSON" >&2
  exit 1
fi

# 获取当前轮次（从 STATUS 面板或参数）
if [ -z "$ROUND" ]; then
  ROUND=$(sed -n '/<!-- STATUS/,/-->/p' "$DISCUSSION_FILE" | \
    grep 'round:' | head -1 | \
    sed 's/.*round:\s*//' | tr -d ' ')
  ROUND=$((ROUND + 1))  # 进入下一轮
fi

# 获取项目工作目录（讨论目录的祖先项目目录）
# discussion-dir 通常是 <project-root>/docs/discussions/<topic>/
WORKING_DIR=$(cd "$DISCUSSION_DIR/../../.." && pwd)

echo "=== 开始 Round ${ROUND} 编排 ==="
echo "讨论目录: ${DISCUSSION_DIR}"
echo "工作目录: ${WORKING_DIR}"
echo ""

# 读取分配
ASSIGNMENT_COUNT=$(jq '.assignments | length' "$ASSIGNMENTS_FILE")
SUCCESS_COUNT=0
FAIL_COUNT=0

for i in $(seq 0 $((ASSIGNMENT_COUNT - 1))); do
  ROLE=$(jq -r ".assignments[$i].role" "$ASSIGNMENTS_FILE")
  TOOL=$(jq -r ".assignments[$i].tool" "$ASSIGNMENTS_FILE")
  PROMPT_FILE=$(jq -r ".assignments[$i].prompt_file" "$ASSIGNMENTS_FILE")

  echo "--- ${ROLE} via ${TOOL} ---"

  # 验证 prompt 文件
  if [ ! -f "$PROMPT_FILE" ]; then
    echo "警告: prompt 文件不存在: $PROMPT_FILE，跳过 ${ROLE}" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))
    continue
  fi

  # 调用 agent
  RESPONSE_FILE=$(mktemp)
  trap "rm -f $RESPONSE_FILE" EXIT

  if bash "${SCRIPT_DIR}/invoke-agent.sh" "$TOOL" "$PROMPT_FILE" "$WORKING_DIR" 300 > "$RESPONSE_FILE" 2>&1; then
    echo "  调用成功，解析响应..."

    # 解析响应并追加到 discussion.md
    PARSED=$(bash "${SCRIPT_DIR}/parse-response.sh" "$ROLE" "$TOOL" "$ROUND" "$RESPONSE_FILE" 2>&1) || {
      echo "  警告: 响应解析失败，使用原始响应" >&2
      PARSED=$(cat "$RESPONSE_FILE")
    }

    # 追加到 discussion.md
    echo "" >> "$DISCUSSION_FILE"
    echo "$PARSED" >> "$DISCUSSION_FILE"

    SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    echo "  已追加到 discussion.md"
  else
    echo "  错误: ${TOOL} 调用失败，${ROLE} 的发言将跳过" >&2
    FAIL_COUNT=$((FAIL_COUNT + 1))

    # 记录失败到 discussion.md
    cat >> "$DISCUSSION_FILE" <<EOF

## [Round ${ROUND}] ${ROLE} — ${TOOL} (调用失败)
> 时间: $(date '+%Y-%m-%d %H:%M')
> 状态: 工具调用失败，请使用手动模式补充此角色的发言

---
EOF
  fi

  rm -f "$RESPONSE_FILE"
  echo ""
done

# 评估收敛
echo "=== 收敛评估 ==="
CONVERGENCE=$(bash "${SCRIPT_DIR}/evaluate-convergence.sh" "$DISCUSSION_FILE" 2>&1) || {
  echo "警告: 收敛评估失败" >&2
  CONVERGENCE='{"converged": false, "recommendation": "evaluation_failed"}'
}

echo "$CONVERGENCE" | jq . 2>/dev/null || echo "$CONVERGENCE"

# 输出摘要
echo ""
echo "=== Round ${ROUND} 摘要 ==="
echo "  成功: ${SUCCESS_COUNT}/${ASSIGNMENT_COUNT}"
echo "  失败: ${FAIL_COUNT}/${ASSIGNMENT_COUNT}"
CONVERGED=$(echo "$CONVERGENCE" | jq -r '.converged' 2>/dev/null || echo "unknown")
RECOMMENDATION=$(echo "$CONVERGENCE" | jq -r '.recommendation' 2>/dev/null || echo "unknown")
echo "  收敛: ${CONVERGED}"
echo "  建议: ${RECOMMENDATION}"
