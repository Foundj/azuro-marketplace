#!/usr/bin/env bash
# 质量评分引擎 - 自动评估 Agent 发言质量 + 工具维度评分
# 用法: bash score-response.sh <response-text-file> [tool-name] [topic-type]
#
# 输入:
#   response-text-file: Agent 发言文本文件
#   tool-name: 可选，工具名（codex/claude/gemini/cursor），用于计算 tool_score
#   topic-type: 可选，主题类型（code-review/architecture/requirement/security/default）
#
# 输出 JSON:
# {
#   "quality_score": N,       — 总分 (0-5)
#   "quality_bonus": 1.XX,    — 权重加成因子
#   "tool_score": 0.XX,       — 工具维度评分（无工具名时为 1.0）
#   "dimensions": { ... },    — 质量维度明细
#   "tool_dimensions": { ... } — 工具维度明细（无工具名时省略）
# }

set -euo pipefail

RESPONSE_FILE="${1:?用法: score-response.sh <response-text-file> [tool-name] [topic-type]}"
TOOL_NAME="${2:-}"
TOPIC_TYPE="${3:-default}"

if [ ! -f "$RESPONSE_FILE" ]; then
  echo "错误: 响应文件不存在: $RESPONSE_FILE" >&2
  exit 1
fi

RESPONSE=$(cat "$RESPONSE_FILE")

if [ -z "$RESPONSE" ]; then
  cat <<EOF
{
  "quality_score": 0,
  "quality_bonus": 1.00,
  "tool_score": 1.00,
  "dimensions": {
    "code_reference": false,
    "risk_identified": false,
    "alternative_compared": false,
    "peer_reference": false,
    "action_proposed": false
  }
}
EOF
  exit 0
fi

# === 规则检测 ===
quality_score=0

# 维度1: 引用了代码/文档（包含代码块、文件路径或文档引用）
code_reference=false
if echo "$RESPONSE" | grep -qE '```|`[^`]+`' || \
   echo "$RESPONSE" | grep -qE '[a-zA-Z0-9_/-]+\.(ts|js|py|sh|md|json|yaml|yml)' || \
   echo "$RESPONSE" | grep -qE '(src|lib|components|scripts|docs)/' ; then
  code_reference=true
  quality_score=$((quality_score + 1))
fi

# 维度2: 识别了风险（包含风险、安全、性能等关键词）
risk_identified=false
if echo "$RESPONSE" | grep -qi '#risk' || \
   echo "$RESPONSE" | grep -qiE '(风险|安全|漏洞|性能瓶颈|缺陷|隐患|vulnerability|security risk|bottleneck)' || \
   echo "$RESPONSE" | grep -qE '\[!warning\]|\[!caution\]'; then
  risk_identified=true
  quality_score=$((quality_score + 1))
fi

# 维度3: 提供了替代方案对比
alternative_compared=false
if echo "$RESPONSE" | grep -qiE '(方案.*vs|方案.*对比|option.*vs|alternative|compared to|相比|优劣)' || \
   echo "$RESPONSE" | grep -qE '方案[[:space:]]*[A-Z].*方案[[:space:]]*[A-Z]' || \
   echo "$RESPONSE" | grep -qiE '(pros|cons|trade-?off|权衡)'; then
  alternative_compared=true
  quality_score=$((quality_score + 1))
fi

# 维度4: 引用了其他 Agent 的发言
peer_reference=false
if echo "$RESPONSE" | grep -qE '@[A-Z][a-zA-Z]+' || \
   echo "$RESPONSE" | grep -qiE '(同意.*的|赞同.*观点|如.*所述|正如.*提到)'; then
  peer_reference=true
  quality_score=$((quality_score + 1))
fi

# 维度5: 提出了行动项
action_proposed=false
if echo "$RESPONSE" | grep -qi '#action' || \
   echo "$RESPONSE" | grep -qiE '(建议|应该|需要|TODO|action item|下一步|next step)' || \
   echo "$RESPONSE" | grep -qE '^\s*-\s*\[[ x]\]'; then
  action_proposed=true
  quality_score=$((quality_score + 1))
fi

# === 计算质量加成因子 ===
quality_bonus=$(awk "BEGIN {printf \"%.2f\", 1.0 + ($quality_score * 0.05)}")

# === 计算工具维度评分 ===
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${SCRIPT_DIR}/../data"
tool_score="1.00"
tool_dims_json=""

if [ -n "$TOOL_NAME" ] && command -v jq &>/dev/null; then
  PROFILES_FILE="${DATA_DIR}/tool-profiles.json"
  WEIGHTS_FILE="${DATA_DIR}/topic-weights.json"

  if [ -f "$PROFILES_FILE" ] && [ -f "$WEIGHTS_FILE" ]; then
    # Resolve alias
    resolved_tool=$(jq -r --arg t "$TOOL_NAME" '
      (.aliases[$t] // $t) as $rt |
      if .profiles[$rt] then $rt else empty end
    ' "$PROFILES_FILE" 2>/dev/null || echo "")

    if [ -n "$resolved_tool" ]; then
      tool_score=$(jq -r --arg t "$resolved_tool" --arg tt "$TOPIC_TYPE" '
        . as $profiles |
        input as $weights |
        ($weights.topics[$tt] // $weights.topics["default"]) as $tw |
        $profiles.profiles[$t] |
        (.thoroughness * $tw.thoroughness) +
        (.accuracy * $tw.accuracy) +
        (.creativity * $tw.creativity) +
        (.execution * $tw.execution) |
        . * 100 | round / 100 | tostring
      ' "$PROFILES_FILE" "$WEIGHTS_FILE" 2>/dev/null || echo "1.00")

      tool_dims_json=$(jq -r --arg t "$resolved_tool" '
        .profiles[$t] | 
        ",\n  \"tool_dimensions\": " + tojson
      ' "$PROFILES_FILE" 2>/dev/null || echo "")
    fi
  fi
fi

# === 输出 JSON ===
cat <<EOF
{
  "quality_score": ${quality_score},
  "quality_bonus": ${quality_bonus},
  "tool_score": ${tool_score},
  "dimensions": {
    "code_reference": ${code_reference},
    "risk_identified": ${risk_identified},
    "alternative_compared": ${alternative_compared},
    "peer_reference": ${peer_reference},
    "action_proposed": ${action_proposed}
  }${tool_dims_json}
}
EOF
