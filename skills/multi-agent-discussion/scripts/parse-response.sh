#!/usr/bin/env bash
# 解析 Agent 响应，提取结构化发言
# 用法: bash parse-response.sh <role> <tool> <round> [response-file]
#
# 输入: 原始响应文本（stdin 或文件）
# 输出: 标准格式的讨论条目（stdout）
#
# 处理:
#   1. 去除 JSON 包装（opencode 的 JSON 输出）
#   2. 去除工具调用日志和元信息
#   3. 验证必需段落（分析、建议、决策倾向）
#   4. 包裹为标准 [Round N] 格式

set -euo pipefail

ROLE="${1:?用法: parse-response.sh <role> <tool> <round> [response-file]}"
TOOL="${2:?请提供工具名称}"
ROUND="${3:?请提供轮次号}"
RESPONSE_FILE="${4:-}"

# 读取响应
if [ -n "$RESPONSE_FILE" ] && [ -f "$RESPONSE_FILE" ]; then
  RAW_RESPONSE=$(cat "$RESPONSE_FILE")
elif [ -n "$RESPONSE_FILE" ]; then
  echo "错误: 响应文件不存在: $RESPONSE_FILE" >&2
  exit 1
else
  # 从 stdin 读取
  RAW_RESPONSE=$(cat)
fi

if [ -z "$RAW_RESPONSE" ]; then
  echo "错误: 响应内容为空" >&2
  exit 1
fi

# Step 1: 尝试从 JSON 中提取文本内容
# opencode run --format json 返回 JSON，需要提取 result/content
extract_from_json() {
  local input="$1"

  # 检查是否是 JSON 格式
  if echo "$input" | head -1 | grep -q '^\s*{'; then
    # 尝试用 jq 提取（如果可用）
    if command -v jq &>/dev/null; then
      local extracted
      # 尝试常见的 JSON 结构
      extracted=$(echo "$input" | jq -r '.result // .content // .response // .output // .message // .' 2>/dev/null || echo "$input")
      if [ -n "$extracted" ] && [ "$extracted" != "null" ]; then
        echo "$extracted"
        return
      fi
    fi
  fi

  # 不是 JSON 或解析失败，原样返回
  echo "$input"
}

RESPONSE=$(extract_from_json "$RAW_RESPONSE")

# Step 2: 清理工具调用日志
# 去除常见的 CLI 输出噪音
clean_response() {
  local input="$1"
  echo "$input" | \
    sed '/^⏺/d' | \
    sed '/^Running:/d' | \
    sed '/^Waiting for/d' | \
    sed '/^Reading file/d' | \
    sed '/^Writing to/d' | \
    sed '/^Edited file/d' | \
    sed '/^Created file/d' | \
    sed '/^⚠️.*Using Claude via/d' | \
    sed '/^$/N;/^\n$/d'  # 合并连续空行
}

CLEANED=$(clean_response "$RESPONSE")

# Step 3: 检查响应是否已包含标准格式头
has_round_header() {
  echo "$1" | grep -q "^\#\#\s*\[Round"
}

# Step 4: 构建输出
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')

if has_round_header "$CLEANED"; then
  # 响应已包含标准格式，直接输出
  echo "$CLEANED"
else
  # 包裹为标准格式
  cat <<EOF
## [Round ${ROUND}] ${ROLE} — ${TOOL}
> 时间: ${TIMESTAMP}

${CLEANED}

---
EOF
fi
