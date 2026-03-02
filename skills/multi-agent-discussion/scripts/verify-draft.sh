#!/usr/bin/env bash
# Draft 校验器 - 迭代式生成-校验循环
# 用法: bash verify-draft.sh <discussion-file> <draft-text-file> [max-rounds]
#
# 校验 Draft 阶段的方案草案，评估 4 个维度并给出 1-10 分数:
# - 完整性: 是否覆盖了所有 #consensus 议题
# - 一致性: 是否与讨论达成的共识一致
# - 可行性: 技术方案是否可执行
# - 风险覆盖: 是否回应了 @Critic 提出的问题
#
# 输出 JSON:
# {
#   "score": N,           — 总分 (1-10)
#   "pass": bool,         — 是否通过 (>= 7)
#   "round": N,           — 当前校验轮次
#   "dimensions": { ... },— 各维度评分
#   "feedback": "..."     — 改进建议（不通过时）
# }

set -euo pipefail

DISCUSSION_FILE="${1:?用法: verify-draft.sh <discussion-file> <draft-text-file> [max-rounds]}"
DRAFT_FILE="${2:?请提供 Draft 文本文件}"
MAX_ROUNDS="${3:-3}"

if [ ! -f "$DISCUSSION_FILE" ]; then
  echo "错误: 讨论文件不存在: $DISCUSSION_FILE" >&2
  exit 1
fi

if [ ! -f "$DRAFT_FILE" ]; then
  echo "错误: Draft 文件不存在: $DRAFT_FILE" >&2
  exit 1
fi

DISCUSSION=$(cat "$DISCUSSION_FILE")
DRAFT=$(cat "$DRAFT_FILE")

# === 维度1: 完整性 — 是否覆盖了所有 #consensus 议题 ===
# 提取所有 #consensus(topic) 中的 topic
evaluate_completeness() {
  local score=0
  local topics
  topics=$(echo "$DISCUSSION" | { grep -oE '#consensus\([^)]+\)' || true; } | sed 's/#consensus(//;s/)//' | sort -u)
  local total_topics
  total_topics=$(echo "$topics" | grep -c '.' || true)

  if [ "$total_topics" -eq 0 ]; then
    # 无具体 topic 的 #consensus，检查 Draft 是否有实质内容
    if [ ${#DRAFT} -gt 200 ]; then
      echo "8"
    else
      echo "5"
    fi
    return
  fi

  local covered=0
  while IFS= read -r topic; do
    [ -z "$topic" ] && continue
    # 检查 Draft 中是否提及该 topic（固定字符串匹配，避免正则问题）
    local search_term
    search_term=$(echo "$topic" | head -c 30)
    if [ -n "$search_term" ] && echo "$DRAFT" | grep -qiF "$search_term"; then
      covered=$((covered + 1))
    fi
  done <<< "$topics"

  if [ "$total_topics" -gt 0 ]; then
    score=$(awk "BEGIN {printf \"%d\", 10 * $covered / $total_topics}")
  fi
  [ "$score" -lt 1 ] && score=1
  echo "$score"
}

# === 维度2: 一致性 — 是否与讨论共识一致 ===
evaluate_consistency() {
  local score=5  # 基线分

  # 检查是否引用了讨论内容
  local ref_count=0
  # 检查是否提及了参与讨论的角色
  echo "$DRAFT" | grep -qE '@[A-Z][a-zA-Z]+' && ref_count=$((ref_count + 2))
  # 检查是否引用了关键决策
  echo "$DRAFT" | grep -qiE '(共识|决策|讨论结果|agreed|consensus|decided)' && ref_count=$((ref_count + 2))
  # 检查是否包含 #rejected 的内容（不应包含已否决的方案）
  local rejected_topics
  rejected_topics=$(echo "$DISCUSSION" | grep -oE '#rejected\([^)]+\)' | sed 's/#rejected(//;s/)//' 2>/dev/null || true)
  if [ -n "$rejected_topics" ]; then
    while IFS= read -r rtopic; do
      [ -z "$rtopic" ] && continue
      if echo "$DRAFT" | grep -qi "$rtopic"; then
        ref_count=$((ref_count - 3))  # 包含已否决内容扣分
      fi
    done <<< "$rejected_topics"
  fi

  score=$((score + ref_count))
  [ "$score" -gt 10 ] && score=10
  [ "$score" -lt 1 ] && score=1
  echo "$score"
}

# === 维度3: 可行性 — 技术方案是否可执行 ===
evaluate_feasibility() {
  local score=5

  # 检查是否包含具体实现细节
  echo "$DRAFT" | grep -qE '```' && score=$((score + 1))
  echo "$DRAFT" | grep -qE '[a-zA-Z0-9_/-]+\.(ts|js|py|sh|json)' && score=$((score + 1))
  # 检查是否有步骤/清单
  echo "$DRAFT" | grep -qE '^\s*(1\.|步骤|Step)' && score=$((score + 1))
  echo "$DRAFT" | grep -qE '^\s*-\s*\[' && score=$((score + 1))
  # 检查篇幅（过短可能不够具体）
  local length=${#DRAFT}
  [ "$length" -gt 500 ] && score=$((score + 1))

  [ "$score" -gt 10 ] && score=10
  echo "$score"
}

# === 维度4: 风险覆盖 — 是否回应了 @Critic 的问题 ===
evaluate_risk_coverage() {
  local score=5

  # 提取 @Critic 提出的关键词/问题
  local critic_content
  critic_content=$(echo "$DISCUSSION" | awk '
    /^## \[Round.*@Critic/ { found=1; next }
    /^## \[Round/ { found=0 }
    found { print }
  ')

  if [ -z "$critic_content" ]; then
    # 无 Critic 发言，给中等分
    echo "7"
    return
  fi

  # 检查 Draft 是否回应了 Critic 的关注点
  echo "$DRAFT" | grep -qiE '(风险|安全|性能|缺陷)' && score=$((score + 1))
  echo "$DRAFT" | grep -qiE '(缓解|措施|解决|应对|mitigation)' && score=$((score + 2))
  echo "$DRAFT" | grep -qi '@Critic' && score=$((score + 1))
  echo "$DRAFT" | grep -qiE '(补偿|降级|回退|fallback)' && score=$((score + 1))

  [ "$score" -gt 10 ] && score=10
  echo "$score"
}

# === 执行评估 ===
completeness=$(evaluate_completeness)
consistency=$(evaluate_consistency)
feasibility=$(evaluate_feasibility)
risk_coverage=$(evaluate_risk_coverage)

# 计算总分（加权平均）
# 完整性 30% + 一致性 30% + 可行性 20% + 风险覆盖 20%
total_score=$(awk "BEGIN {printf \"%d\", $completeness * 0.3 + $consistency * 0.3 + $feasibility * 0.2 + $risk_coverage * 0.2 + 0.5}")
[ "$total_score" -gt 10 ] && total_score=10
[ "$total_score" -lt 1 ] && total_score=1

# 通过判定
pass=false
[ "$total_score" -ge 7 ] && pass=true

# 生成反馈
feedback=""
if [ "$pass" = false ]; then
  feedback_items=()
  [ "$completeness" -lt 7 ] && feedback_items+=("completeness: 未覆盖所有共识议题，请检查遗漏")
  [ "$consistency" -lt 7 ] && feedback_items+=("consistency: 与讨论共识不够一致，请对齐决策")
  [ "$feasibility" -lt 7 ] && feedback_items+=("feasibility: 方案缺少具体实现细节，请补充代码和步骤")
  [ "$risk_coverage" -lt 7 ] && feedback_items+=("risk_coverage: 未充分回应 @Critic 的风险问题")

  feedback=$(printf '%s; ' "${feedback_items[@]}" | sed 's/; $//')
fi

# === 输出 JSON ===
cat <<EOF
{
  "score": ${total_score},
  "pass": ${pass},
  "max_rounds": ${MAX_ROUNDS},
  "dimensions": {
    "completeness": ${completeness},
    "consistency": ${consistency},
    "feasibility": ${feasibility},
    "risk_coverage": ${risk_coverage}
  },
  "feedback": "${feedback}"
}
EOF
