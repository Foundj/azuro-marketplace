#!/usr/bin/env bash
# 并行集成投票 - 多 Agent 并行分析关键决策点，加权投票聚合
# 用法: bash ensemble-vote.sh <question-file> <tool-assignments-json> <working-dir> [timeout]
#
# 借鉴 MiroFlow 集成策略(Ensemble Strategy):
# 同一决策问题，多个 Agent 用差异化 prompt 并行分析，通过加权投票聚合结果。
#
# 输入:
#   question-file: 包含决策问题的文本文件
#   tool-assignments-json: Agent 分配 JSON
#   {
#     "agents": [
#       {"tool": "codex", "perspective": "性能和可扩展性", "weight": 0.9},
#       {"tool": "gemini", "perspective": "可维护性和开发效率", "weight": 0.85},
#       {"tool": "claudea", "perspective": "成本和风险", "weight": 0.8}
#     ]
#   }
#   working-dir: 项目工作目录
#   timeout: 每个 Agent 的超时秒数（默认 180）
#
# 输出 JSON:
# {
#   "decision": "方案名",
#   "confidence": 0.X,
#   "votes": [...],
#   "needs_discussion": bool,
#   "summary": "..."
# }

set -euo pipefail

QUESTION_FILE="${1:?用法: ensemble-vote.sh <question-file> <tool-assignments-json> <working-dir> [timeout]}"
ASSIGNMENTS_JSON="${2:?请提供 Agent 分配 JSON 文件}"
WORKING_DIR="${3:?请提供工作目录}"
AGENT_TIMEOUT="${4:-180}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ ! -f "$QUESTION_FILE" ]; then
  echo "错误: 问题文件不存在: $QUESTION_FILE" >&2
  exit 1
fi

if [ ! -f "$ASSIGNMENTS_JSON" ]; then
  echo "错误: 分配文件不存在: $ASSIGNMENTS_JSON" >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "错误: 需要安装 jq" >&2
  exit 1
fi

QUESTION=$(cat "$QUESTION_FILE")
AGENT_COUNT=$(jq '.agents | length' "$ASSIGNMENTS_JSON")

if [ "$AGENT_COUNT" -lt 2 ]; then
  echo "错误: 至少需要 2 个 Agent 进行并行集成" >&2
  exit 1
fi

echo "=== 并行集成投票: $AGENT_COUNT 个 Agent ===" >&2

# 创建临时目录存储各 Agent 的响应
ENSEMBLE_DIR=$(mktemp -d)
trap "rm -rf $ENSEMBLE_DIR" EXIT

# === 构建差异化 Prompt 并并行调用 ===
PIDS=()
for i in $(seq 0 $((AGENT_COUNT - 1))); do
  TOOL=$(jq -r ".agents[$i].tool" "$ASSIGNMENTS_JSON")
  PERSPECTIVE=$(jq -r ".agents[$i].perspective" "$ASSIGNMENTS_JSON")

  # 构建差异化 prompt
  PROMPT_FILE="${ENSEMBLE_DIR}/prompt-${i}.md"
  cat > "$PROMPT_FILE" <<PROMPT_EOF
你是一个决策分析专家。请从【${PERSPECTIVE}】的角度分析以下决策问题。

## 决策问题

${QUESTION}

## 输出要求

1. 分析各候选方案在【${PERSPECTIVE}】维度的优劣
2. 明确推荐一个方案（用 #recommend(方案名) 标记）
3. 给出你的信心程度 [confidence: 0.X]（0.0-1.0）
4. 简要说明理由（100字以内）

请直接输出分析，不要重复问题。
PROMPT_EOF

  RESPONSE_FILE="${ENSEMBLE_DIR}/response-${i}.txt"

  # 并行调用（后台进程）
  (
    if [ -f "${SCRIPT_DIR}/invoke-agent.sh" ]; then
      bash "${SCRIPT_DIR}/invoke-agent.sh" "$TOOL" "$PROMPT_FILE" "$WORKING_DIR" "$AGENT_TIMEOUT" > "$RESPONSE_FILE" 2>/dev/null
    else
      echo "Agent $i ($TOOL): 工具不可用" > "$RESPONSE_FILE"
    fi
  ) &
  PIDS+=($!)
  echo "  已启动 Agent-${i} ($TOOL, 视角: $PERSPECTIVE)" >&2
done

# 等待所有并行调用完成
echo "  等待所有 Agent 完成..." >&2
for pid in "${PIDS[@]}"; do
  wait "$pid" 2>/dev/null || true
done
echo "  所有 Agent 已完成" >&2

# === 收集和解析结果 ===
# 提取各 Agent 的推荐和置信度
VOTES_JSON="["
RECOMMENDATIONS=()
WEIGHTS=()
CONFIDENCES=()

for i in $(seq 0 $((AGENT_COUNT - 1))); do
  TOOL=$(jq -r ".agents[$i].tool" "$ASSIGNMENTS_JSON")
  PERSPECTIVE=$(jq -r ".agents[$i].perspective" "$ASSIGNMENTS_JSON")
  BASE_WEIGHT=$(jq -r ".agents[$i].weight" "$ASSIGNMENTS_JSON")
  RESPONSE_FILE="${ENSEMBLE_DIR}/response-${i}.txt"

  if [ ! -s "$RESPONSE_FILE" ]; then
    echo "  警告: Agent-${i} ($TOOL) 无响应" >&2
    continue
  fi

  RESPONSE=$(cat "$RESPONSE_FILE")

  # 提取推荐方案
  RECOMMEND=$(echo "$RESPONSE" | { grep -oE '#recommend\([^)]+\)' || true; } | head -1 | sed 's/#recommend(//;s/)//')
  if [ -z "$RECOMMEND" ]; then
    # 降级提取：查找"推荐"/"建议"后的关键词
    RECOMMEND=$(echo "$RESPONSE" | { grep -oiE '(推荐|建议|选择).{0,5}方案[[:space:]]*[^,，。.;；[:space:]]+' || true; } | head -1 | sed 's/.*方案[[:space:]]*/方案/')
  fi
  RECOMMEND="${RECOMMEND:-未明确}"

  # 提取置信度
  CONFIDENCE=$(echo "$RESPONSE" | { grep -oE '\[confidence:[[:space:]]*[0-9.]+\]' || true; } | head -1 | { grep -oE '[0-9.]+' || true; })
  CONFIDENCE="${CONFIDENCE:-0.7}"

  RECOMMENDATIONS+=("$RECOMMEND")
  WEIGHTS+=("$BASE_WEIGHT")
  CONFIDENCES+=("$CONFIDENCE")

  # 构建 JSON（转义双引号防止 JSON 注入）
  SAFE_TOOL=$(echo "$TOOL" | sed 's/"/\\"/g')
  SAFE_PERSP=$(echo "$PERSPECTIVE" | sed 's/"/\\"/g')
  SAFE_REC=$(echo "$RECOMMEND" | sed 's/"/\\"/g')
  [ "$i" -gt 0 ] && VOTES_JSON+=","
  VOTES_JSON+="{\"agent\":${i},\"tool\":\"${SAFE_TOOL}\",\"perspective\":\"${SAFE_PERSP}\",\"recommendation\":\"${SAFE_REC}\",\"confidence\":${CONFIDENCE},\"weight\":${BASE_WEIGHT}}"
done
VOTES_JSON+="]"

# === 加权投票聚合 ===
# 统计每个方案的加权得分
DECISION=""
MAX_WEIGHTED_SCORE=0
NEEDS_DISCUSSION=false
TOTAL_WEIGHT=0

# 使用 awk 进行投票聚合
AGGREGATION=$(printf '%s\n' "${RECOMMENDATIONS[@]}" | sort | uniq -c | sort -rn)

# 计算加权得分
declare -A SCHEME_SCORES 2>/dev/null || true

# 简单实现：找出票数最多的方案及其加权得分
if [ ${#RECOMMENDATIONS[@]} -gt 0 ]; then
  DECISION_RESULT=$(
    for i in $(seq 0 $((${#RECOMMENDATIONS[@]} - 1))); do
      echo "${RECOMMENDATIONS[$i]}|${WEIGHTS[$i]}|${CONFIDENCES[$i]}"
    done | awk -F'|' '
    {
      scheme = $1
      w = $2 + 0
      c = $3 + 0
      eff = w * c
      scores[scheme] += eff
      counts[scheme]++
      total += eff
    }
    END {
      max_score = 0
      best = ""
      for (s in scores) {
        if (scores[s] > max_score) {
          max_score = scores[s]
          best = s
        }
      }
      # 检查是否有多数一致
      majority = 0
      for (s in counts) {
        if (counts[s] > NR/2) majority = 1
      }
      if (total > 0) {
        conf = max_score / total
      } else {
        conf = 0
      }
      printf "%s|%.2f|%d\n", best, conf, majority
    }
  ')

  DECISION=$(echo "$DECISION_RESULT" | cut -d'|' -f1)
  OVERALL_CONFIDENCE=$(echo "$DECISION_RESULT" | cut -d'|' -f2)
  HAS_MAJORITY=$(echo "$DECISION_RESULT" | cut -d'|' -f3)

  [ "$HAS_MAJORITY" -eq 0 ] && NEEDS_DISCUSSION=true
fi

# 生成摘要
if [ "$NEEDS_DISCUSSION" = true ]; then
  SUMMARY="无多数一致，加权得分最高: ${DECISION} (confidence: ${OVERALL_CONFIDENCE})，标记 #needs-discussion"
else
  SUMMARY="多数一致推荐: ${DECISION} (confidence: ${OVERALL_CONFIDENCE})"
fi

# === 输出 JSON ===
cat <<EOF
{
  "decision": "${DECISION}",
  "confidence": ${OVERALL_CONFIDENCE:-0},
  "votes": ${VOTES_JSON},
  "needs_discussion": ${NEEDS_DISCUSSION},
  "summary": "${SUMMARY}"
}
EOF
