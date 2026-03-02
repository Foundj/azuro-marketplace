#!/usr/bin/env bash
# 收敛评估 - 分析 discussion.md 讨论收敛状态（五因子加权投票版）
# 用法: bash evaluate-convergence.sh <discussion-file>
#
# 五因子公式:
#   effective_weight = role_weight × confidence × quality_bonus × tool_score × history_modifier
#
# 依赖数据文件（均在 ../data/ 下，缺失时优雅降级为 1.0）:
#   tool-profiles.json   — 工具多维度评分（thoroughness/accuracy/creativity/execution）
#   topic-weights.json   — 主题类型对应的维度权重分配
#   agent-history.json   — Agent 历史表现数据
#
# 输出 JSON:
# {
#   "consensus_count":       N,   — #consensus 标签总数
#   "pending_count":         N,   — #pending 标签总数
#   "rejected_count":        N,   — #rejected 标签总数
#   "needs_input_count":     N,   — #needs-input 标签总数
#   "blocker_count":         N,   — #blocker 标签总数
#   "total_tags":            N,   — 状态标签总数
#   "consensus_ratio":       0.X, — 简单共识率（向后兼容）
#   "weighted_consensus":    0.X, — 五因子加权共识值
#   "topic_type":            "...",— 推断的主题类型
#   "unresolved_mentions":   N,   — 未回应的 @ 提及数
#   "current_round":         N,   — 当前轮次
#   "total_entries":         N,   — [Round N] 发言总数
#   "converged":             bool — 收敛判定
#   "recommendation":        "..."— 建议动作
# }

set -euo pipefail

DISCUSSION_FILE="${1:?用法: evaluate-convergence.sh <discussion-file>}"

if [ ! -f "$DISCUSSION_FILE" ]; then
  echo "错误: 讨论文件不存在: $DISCUSSION_FILE" >&2
  exit 1
fi

CONTENT=$(cat "$DISCUSSION_FILE")

# === 角色基础权重表 ===
# 用法: get_role_weight <role>
get_role_weight() {
  local role="$1"
  case "$role" in
    @Architect|Architect)     echo "0.90" ;;
    @Engineer|Engineer)       echo "0.85" ;;
    @Backend|Backend)         echo "0.85" ;;
    @Frontend|Frontend)       echo "0.85" ;;
    @PM|PM)                   echo "0.80" ;;
    @Security|Security)       echo "0.80" ;;
    @QA|QA)                   echo "0.80" ;;
    @DevOps|DevOps)           echo "0.80" ;;
    @UserAdvocate|UserAdvocate) echo "0.75" ;;
    @Critic|Critic)           echo "0.70" ;;
    @Coordinator|Coordinator) echo "0.85" ;;
    *)                        echo "0.75" ;;  # 自定义角色默认权重
  esac
}

# === 统计标签数量 ===
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

# === 简单共识率（向后兼容）===
DENOMINATOR=$((CONSENSUS_COUNT + PENDING_COUNT + NEEDS_INPUT_COUNT))
if [ "$DENOMINATOR" -gt 0 ]; then
  CONSENSUS_RATIO=$(awk "BEGIN {printf \"%.2f\", $CONSENSUS_COUNT / $DENOMINATOR}")
else
  CONSENSUS_RATIO="0.00"
fi

# === 加权共识计算 ===
# 从每个 [Round N] 条目中提取角色、置信度和投票标签
# 格式: ## [Round N] @Role — tool 或 ## [Round N] @Role [confidence: 0.85] — tool
# 支持历史权重修正（如果 agent-history.json 存在）

# 加载外部数据
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DATA_DIR="${SCRIPT_DIR}/../data"

# 历史权重修正
HISTORY_FILE="${DATA_DIR}/agent-history.json"
HISTORY_DATA=""
if [ -f "$HISTORY_FILE" ] && command -v jq &>/dev/null; then
  HISTORY_DATA=$(cat "$HISTORY_FILE")
fi

# 工具多维度评分
TOOL_PROFILES_FILE="${DATA_DIR}/tool-profiles.json"
TOOL_PROFILES_DATA=""
if [ -f "$TOOL_PROFILES_FILE" ] && command -v jq &>/dev/null; then
  TOOL_PROFILES_DATA=$(cat "$TOOL_PROFILES_FILE")
fi

# 主题维度权重
TOPIC_WEIGHTS_FILE="${DATA_DIR}/topic-weights.json"
TOPIC_WEIGHTS_DATA=""
if [ -f "$TOPIC_WEIGHTS_FILE" ] && command -v jq &>/dev/null; then
  TOPIC_WEIGHTS_DATA=$(cat "$TOPIC_WEIGHTS_FILE")
fi

# 从 STATUS 面板提取 preset，推断 topic 类型
PRESET=$(echo "$CONTENT" | sed -n '/<!-- STATUS/,/-->/p' | { grep 'preset:' || true; } | head -1 | sed 's/.*preset:\s*//' | tr -d ' ')
PRESET="${PRESET:-custom}"

TOPIC_TYPE="default"
if [ -n "$TOPIC_WEIGHTS_DATA" ]; then
  MAPPED=$(echo "$TOPIC_WEIGHTS_DATA" | jq -r ".preset_mapping.\"$PRESET\" // \"default\"" 2>/dev/null)
  TOPIC_TYPE="${MAPPED:-default}"
fi

calculate_weighted_consensus() {
  local weighted_sum=0
  local weight_total=0
  local entry_count=0

  # 预提取历史权重修正数据为 awk 可用格式: "key1=val1,key2=val2"
  local history_modifiers=""
  if [ -n "$HISTORY_DATA" ]; then
    history_modifiers=$(echo "$HISTORY_DATA" | jq -r '
      to_entries | map(select(.key != "_meta")) |
      map(.key + "=" + (.value.weight_modifier | tostring)) |
      join(",")
    ' 2>/dev/null || echo "")
  fi

  # 预提取工具评分为 awk 可用格式: "tool:dim=val,..."
  # 同时解析 aliases
  local tool_scores_str=""
  if [ -n "$TOOL_PROFILES_DATA" ]; then
    tool_scores_str=$(echo "$TOOL_PROFILES_DATA" | jq -r '
      (.aliases // {}) as $aliases |
      .profiles | to_entries | map(
        .key as $tool |
        .value | to_entries | map($tool + ":" + .key + "=" + (.value | tostring))
      ) | flatten | join(",")
    ' 2>/dev/null || echo "")
    # 追加 alias 映射: "alias>canonical,..."
    local alias_str=""
    alias_str=$(echo "$TOOL_PROFILES_DATA" | jq -r '
      (.aliases // {}) | to_entries | map(.key + ">" + .value) | join(",")
    ' 2>/dev/null || echo "")
  fi

  # 预提取当前 topic 的维度权重: "dim=weight,..."
  local topic_weights_str=""
  if [ -n "$TOPIC_WEIGHTS_DATA" ]; then
    topic_weights_str=$(echo "$TOPIC_WEIGHTS_DATA" | jq -r --arg tt "$TOPIC_TYPE" '
      (.topics[$tt] // .topics["default"]) |
      to_entries | map(.key + "=" + (.value | tostring)) | join(",")
    ' 2>/dev/null || echo "")
  fi

  # 使用 awk 一次性完成所有条目的解析和加权计算（五因子）
  # effective_weight = role_weight × confidence × quality_bonus × tool_score × history_modifier
  local result
  result=$(echo "$CONTENT" | awk -v hist="$history_modifiers" \
    -v tscores="$tool_scores_str" -v aliases="${alias_str:-}" \
    -v tweights="$topic_weights_str" '

    function get_weight(role) {
      sub(/^@/, "", role)
      if (role == "Architect") return 0.90
      if (role == "Engineer" || role == "Backend" || role == "Frontend") return 0.85
      if (role == "Coordinator") return 0.85
      if (role == "PM") return 0.80
      if (role == "Security" || role == "QA" || role == "DevOps") return 0.80
      if (role == "UserAdvocate") return 0.75
      if (role == "Critic") return 0.70
      return 0.75
    }

    function flush_entry() {
      if (cur_role == "" || !has_tag) return
      qb = 1.0 + (qscore * 0.05)
      hm = get_history_mod(cur_tool, cur_role)
      ts = get_tool_score(cur_tool)
      ew = base_w * conf * qb * ts * hm
      ws += ew * vote
      wt += ew
      ec++
    }

    function get_history_mod(tool, role) {
      key = tool ":" role
      if (key in hist_map) return hist_map[key]
      return 1.0
    }

    # tool_score = Σ(dimension_value × topic_weight) 对每个维度
    function get_tool_score(tool) {
      # 解析 alias
      if (tool in alias_map) tool = alias_map[tool]
      score = 0
      dims[1] = "thoroughness"; dims[2] = "accuracy"
      dims[3] = "creativity"; dims[4] = "execution"
      has_data = 0
      for (d = 1; d <= 4; d++) {
        key = tool ":" dims[d]
        if (key in tscore_map) {
          tw_key = dims[d]
          tw = (tw_key in tweight_map) ? tweight_map[tw_key] : 0.25
          score += tscore_map[key] * tw
          has_data = 1
        }
      }
      return has_data ? score : 1.0
    }

    BEGIN {
      n = split(hist, pairs, ",")
      for (i = 1; i <= n; i++) {
        split(pairs[i], kv, "=")
        if (kv[1] != "") hist_map[kv[1]] = kv[2] + 0
      }
      # 工具评分: "tool:dim=val,..."
      n = split(tscores, pairs, ",")
      for (i = 1; i <= n; i++) {
        split(pairs[i], kv, "=")
        if (kv[1] != "") tscore_map[kv[1]] = kv[2] + 0
      }
      # Alias: "alias>canonical,..."
      n = split(aliases, pairs, ",")
      for (i = 1; i <= n; i++) {
        split(pairs[i], kv, ">")
        if (kv[1] != "") alias_map[kv[1]] = kv[2]
      }
      # 主题权重: "dim=weight,..."
      n = split(tweights, pairs, ",")
      for (i = 1; i <= n; i++) {
        split(pairs[i], kv, "=")
        if (kv[1] != "") tweight_map[kv[1]] = kv[2] + 0
      }
    }

    /^## \[Round [0-9]+\]/ {
      flush_entry()

      # 跳过失败条目
      if (index($0, "\350\260\203\347\224\250\345\244\261\350\264\245") > 0) { cur_role = ""; next }

      # 提取角色
      cur_role = ""
      cur_tool = ""
      s = $0
      sub(/^## \[Round [0-9]+\] */, "", s)
      split(s, parts, " ")
      if (length(parts) > 0) cur_role = parts[1]
      sub(/\[.*/, "", cur_role)

      # 提取工具名（在 " — " 之后）
      if (index($0, " — ") > 0) {
        t = $0
        sub(/.* — /, "", t)
        sub(/ .*/, "", t)
        cur_tool = t
      }

      # 提取置信度
      conf = 1.0
      if (index($0, "[confidence:") > 0) {
        s2 = $0
        sub(/.*\[confidence: */, "", s2)
        sub(/\].*/, "", s2)
        c = s2 + 0
        if (c > 0 && c <= 1) conf = c
      }

      base_w = get_weight(cur_role)
      vote = 0
      has_tag = 0
      qscore = 0    # 质量得分重置
      qd1=0; qd2=0; qd3=0; qd4=0; qd5=0  # 质量维度标记重置
      next
    }

    cur_role != "" {
      # 投票标签检测
      if (index($0, "#consensus") > 0) { vote = 1.0; has_tag = 1 }
      else if (index($0, "#rejected") > 0) { vote = -0.5; has_tag = 1 }
      else if (index($0, "#pending") > 0) { vote = 0.0; has_tag = 1 }

      # 质量维度检测（累加，最多5分）
      line = tolower($0)
      # 维度1: 代码引用
      if (qd1 == 0 && (index($0, "```") > 0 || $0 ~ /[a-zA-Z0-9_\/-]+\.(ts|js|py|sh|md|json)/ || index($0, "`") > 0)) {
        qscore++; qd1 = 1
      }
      # 维度2: 风险识别
      if (qd2 == 0 && (index($0, "#risk") > 0 || index(line, "风险") > 0 || index(line, "安全") > 0 || index(line, "漏洞") > 0 || index(line, "vulnerability") > 0 || index(line, "bottleneck") > 0)) {
        qscore++; qd2 = 1
      }
      # 维度3: 方案对比
      if (qd3 == 0 && ($0 ~ /方案.*vs/ || index(line, "trade-off") > 0 || index(line, "权衡") > 0 || index(line, "对比") > 0 || index(line, "pros") > 0)) {
        qscore++; qd3 = 1
      }
      # 维度4: 引用他人
      if (qd4 == 0 && ($0 ~ /@[A-Z][a-zA-Z]+/ || index(line, "同意") > 0 || index(line, "赞同") > 0)) {
        qscore++; qd4 = 1
      }
      # 维度5: 行动项
      if (qd5 == 0 && (index($0, "#action") > 0 || index(line, "建议") > 0 || index(line, "todo") > 0 || index(line, "next step") > 0 || index(line, "下一步") > 0)) {
        qscore++; qd5 = 1
      }
    }

    END {
      flush_entry()
      printf "%.4f %.4f %d\n", ws, wt, ec
    }
  ')

  local weighted_sum weight_total entry_count
  weighted_sum=$(echo "$result" | awk '{print $1}')
  weight_total=$(echo "$result" | awk '{print $2}')
  entry_count=$(echo "$result" | awk '{print $3}')

  # 计算加权共识值
  if [ "$entry_count" -gt 0 ] && [ "$(awk "BEGIN {print ($weight_total > 0)}")" = "1" ]; then
    awk "BEGIN {printf \"%.2f\", $weighted_sum / $weight_total}"
  else
    # 无加权数据时退回简单比率
    echo "$CONSENSUS_RATIO"
  fi
}

WEIGHTED_CONSENSUS=$(calculate_weighted_consensus)

# === 统计未解决的 @ 提及 ===
UNRESOLVED_MENTIONS=$(echo "$CONTENT" | \
  sed -n '/<!-- STATUS/,/-->/p' | \
  { grep -c '^\s*- target:' || true; })

# === 获取当前轮次 ===
CURRENT_ROUND=$(echo "$CONTENT" | \
  sed -n '/<!-- STATUS/,/-->/p' | \
  { grep 'round:' || true; } | head -1 | \
  sed 's/.*round:\s*//' | tr -d ' ')
CURRENT_ROUND="${CURRENT_ROUND:-0}"

# === 统计发言总数 ===
TOTAL_ENTRIES=$(echo "$CONTENT" | { grep -c '^\#\#\s*\[Round' || true; })

# === 收敛判定（加权版本）===
# 条件:
# 1. weighted_consensus >= 0.65（加权门槛）
# 2. blocker_count == 0
# 3. needs_input_count == 0
# 向后兼容：同时检查简单比率
CONVERGED=false
if [ "$(awk "BEGIN {print ($WEIGHTED_CONSENSUS >= 0.65)}")" = "1" ] && \
   [ "$BLOCKER_COUNT" -eq 0 ] && \
   [ "$NEEDS_INPUT_COUNT" -eq 0 ]; then
  CONVERGED=true
fi

# === 生成建议 ===
RECOMMENDATION=""
if [ "$CONVERGED" = true ]; then
  RECOMMENDATION="converged — 可以进入 summarize 阶段"
elif [ "$BLOCKER_COUNT" -gt 0 ]; then
  RECOMMENDATION="blocked — 存在 ${BLOCKER_COUNT} 个阻塞项，需优先解决"
elif [ "$NEEDS_INPUT_COUNT" -gt 0 ]; then
  RECOMMENDATION="waiting — 需要 ${NEEDS_INPUT_COUNT} 个角色提供输入"
elif [ "$(awk "BEGIN {print ($WEIGHTED_CONSENSUS < 0.3)}")" = "1" ]; then
  RECOMMENDATION="diverging — 加权共识 ${WEIGHTED_CONSENSUS}，分歧较大，建议继续讨论"
else
  RECOMMENDATION="progressing — 加权共识 ${WEIGHTED_CONSENSUS}，讨论进展中"
fi

# === 输出 JSON ===
cat <<EOF
{
  "consensus_count": ${CONSENSUS_COUNT},
  "pending_count": ${PENDING_COUNT},
  "rejected_count": ${REJECTED_COUNT},
  "needs_input_count": ${NEEDS_INPUT_COUNT},
  "blocker_count": ${BLOCKER_COUNT},
  "total_tags": ${TOTAL_TAGS},
  "consensus_ratio": ${CONSENSUS_RATIO},
  "weighted_consensus": ${WEIGHTED_CONSENSUS},
  "topic_type": "${TOPIC_TYPE}",
  "unresolved_mentions": ${UNRESOLVED_MENTIONS},
  "current_round": ${CURRENT_ROUND},
  "total_entries": ${TOTAL_ENTRIES},
  "converged": ${CONVERGED},
  "recommendation": "${RECOMMENDATION}"
}
EOF
