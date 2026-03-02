#!/usr/bin/env bash
# 质量评分引擎 - 自动评估 Agent 发言质量
# 用法: bash score-response.sh <response-text-file>
#
# 输入: Agent 发言文本文件
# 输出: JSON 格式的质量评分
# {
#   "quality_score": N,       — 总分 (0-5)
#   "quality_bonus": 1.XX,    — 权重加成因子
#   "dimensions": {
#     "code_reference": bool,  — 引用了代码/文档
#     "risk_identified": bool, — 识别了风险
#     "alternative_compared": bool, — 提供了替代方案对比
#     "peer_reference": bool,  — 引用了其他 Agent
#     "action_proposed": bool  — 提出了行动项
#   }
# }
#
# 质量加权公式:
#   quality_bonus = 1.0 + (quality_score × 0.05)
#   有效范围: 1.00 - 1.25

set -euo pipefail

RESPONSE_FILE="${1:?用法: score-response.sh <response-text-file>}"

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
# quality_bonus = 1.0 + (quality_score × 0.05)
quality_bonus=$(awk "BEGIN {printf \"%.2f\", 1.0 + ($quality_score * 0.05)}")

# === 输出 JSON ===
cat <<EOF
{
  "quality_score": ${quality_score},
  "quality_bonus": ${quality_bonus},
  "dimensions": {
    "code_reference": ${code_reference},
    "risk_identified": ${risk_identified},
    "alternative_compared": ${alternative_compared},
    "peer_reference": ${peer_reference},
    "action_proposed": ${action_proposed}
  }
}
EOF
