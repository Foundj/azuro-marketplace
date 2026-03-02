#!/usr/bin/env bash
# 历史权重更新 - 讨论结束后更新 Agent 历史表现数据
# 用法: bash update-history.sh <discussion-file> <history-file>
#
# 基于讨论结果更新 agent-history.json:
# - 统计每个 Agent 的质量得分
# - 计算与最终共识的对齐度
# - 更新权重修正因子
#
# 历史数据结构:
# {
#   "toolname:RoleName": {
#     "discussions": N,
#     "avg_quality_score": X.X,
#     "consensus_alignment": 0.XX,
#     "weight_modifier": X.XX
#   }
# }

set -euo pipefail

DISCUSSION_FILE="${1:?用法: update-history.sh <discussion-file> <history-file>}"
HISTORY_FILE="${2:?请提供历史数据文件路径}"

if [ ! -f "$DISCUSSION_FILE" ]; then
  echo "错误: 讨论文件不存在: $DISCUSSION_FILE" >&2
  exit 1
fi

if ! command -v jq &>/dev/null; then
  echo "错误: 需要安装 jq" >&2
  exit 1
fi

# 如果历史文件不存在，创建初始结构
if [ ! -f "$HISTORY_FILE" ]; then
  echo '{"_meta":{"description":"Agent history","version":"1.0","last_updated":""}}' > "$HISTORY_FILE"
fi

CONTENT=$(cat "$DISCUSSION_FILE")
TIMESTAMP=$(date '+%Y-%m-%d %H:%M')

# === 提取各 Agent 的发言数据 ===
# 使用 awk 提取每个 Agent 的角色、工具、投票和质量维度
AGENT_DATA=$(echo "$CONTENT" | awk '
  function tolower_custom(s) {
    # 简单的小写转换
    return s
  }

  /^## \[Round [0-9]+\]/ {
    # 提交上一个 Agent 的数据
    if (cur_role != "" && cur_tool != "") {
      printf "%s:%s|%s|%d\n", cur_tool, cur_role, vote_tag, qscore
    }

    # 跳过失败条目
    if (index($0, "\350\260\203\347\224\250\345\244\261\350\264\245") > 0) { cur_role = ""; next }

    # 提取角色和工具
    s = $0
    sub(/^## \[Round [0-9]+\] */, "", s)
    # 移除 confidence 标记
    sub(/\[confidence:[^]]*\]/, "", s)
    # 格式: @Role — tool 或 Role — tool
    split(s, parts, " — ")
    cur_role = parts[1]
    sub(/^ */, "", cur_role)
    sub(/ *$/, "", cur_role)
    cur_tool = parts[2]
    sub(/^ */, "", cur_tool)
    sub(/ *$/, "", cur_tool)

    vote_tag = "none"
    qscore = 0
    qd1=0; qd2=0; qd3=0; qd4=0; qd5=0
    next
  }

  cur_role != "" {
    # 投票标签
    if (index($0, "#consensus") > 0) vote_tag = "consensus"
    else if (index($0, "#rejected") > 0) vote_tag = "rejected"
    else if (index($0, "#pending") > 0) vote_tag = "pending"

    # 质量维度（简化检测）
    if (qd1 == 0 && (index($0, "```") > 0 || index($0, "`") > 0)) { qscore++; qd1=1 }
    if (qd2 == 0 && (index($0, "#risk") > 0 || index($0, "\351\243\216\351\231\251") > 0)) { qscore++; qd2=1 }
    if (qd3 == 0 && (index($0, "vs") > 0 || index($0, "\345\257\271\346\257\224") > 0)) { qscore++; qd3=1 }
    if (qd4 == 0 && $0 ~ /@[A-Z]/) { qscore++; qd4=1 }
    if (qd5 == 0 && (index($0, "#action") > 0 || index($0, "\345\273\272\350\256\256") > 0)) { qscore++; qd5=1 }
  }

  END {
    if (cur_role != "" && cur_tool != "") {
      printf "%s:%s|%s|%d\n", cur_tool, cur_role, vote_tag, qscore
    }
  }
')

if [ -z "$AGENT_DATA" ]; then
  echo "警告: 讨论文件中未找到有效的 Agent 发言" >&2
  exit 0
fi

# === 统计最终共识方向 ===
# 最终共识 = 最后一轮中 #consensus 的数量 > #rejected
FINAL_CONSENSUS=$(echo "$CONTENT" | awk '
  /^## \[Round/ { round = $0 }
  /#consensus/ { cons++ }
  /#rejected/ { rej++ }
  END { print (cons > rej) ? "consensus" : "rejected" }
')

# === 更新历史数据 ===
HISTORY=$(cat "$HISTORY_FILE")

while IFS='|' read -r agent_key vote_tag qscore; do
  [ -z "$agent_key" ] && continue

  # 清理 agent_key（移除空格和特殊字符）
  agent_key=$(echo "$agent_key" | tr -d ' ' | sed 's/[()]//g')

  # 获取现有数据
  OLD_DISCUSSIONS=$(echo "$HISTORY" | jq -r ".\"$agent_key\".discussions // 0")
  OLD_AVG_QUALITY=$(echo "$HISTORY" | jq -r ".\"$agent_key\".avg_quality_score // 0")
  OLD_ALIGNMENT=$(echo "$HISTORY" | jq -r ".\"$agent_key\".consensus_alignment // 0.5")

  # 计算新值
  NEW_DISCUSSIONS=$((OLD_DISCUSSIONS + 1))

  # 更新平均质量分（移动平均）
  NEW_AVG_QUALITY=$(awk "BEGIN {printf \"%.2f\", ($OLD_AVG_QUALITY * $OLD_DISCUSSIONS + $qscore) / $NEW_DISCUSSIONS}")

  # 更新共识对齐度
  ALIGNED=0
  if [ "$vote_tag" = "consensus" ] && [ "$FINAL_CONSENSUS" = "consensus" ]; then
    ALIGNED=1
  elif [ "$vote_tag" = "rejected" ] && [ "$FINAL_CONSENSUS" = "rejected" ]; then
    ALIGNED=1
  fi
  NEW_ALIGNMENT=$(awk "BEGIN {printf \"%.2f\", ($OLD_ALIGNMENT * $OLD_DISCUSSIONS + $ALIGNED) / $NEW_DISCUSSIONS}")

  # 计算权重修正因子
  # weight_modifier = 0.8 + (avg_quality × 0.04) + (alignment × 0.2)
  # 范围限制 [0.6, 1.4]
  WEIGHT_MODIFIER=$(awk "BEGIN {
    wm = 0.8 + ($NEW_AVG_QUALITY * 0.04) + ($NEW_ALIGNMENT * 0.2)
    if (wm < 0.6) wm = 0.6
    if (wm > 1.4) wm = 1.4
    printf \"%.2f\", wm
  }")

  # 更新 JSON
  HISTORY=$(echo "$HISTORY" | jq \
    --arg key "$agent_key" \
    --argjson disc "$NEW_DISCUSSIONS" \
    --arg avg "$NEW_AVG_QUALITY" \
    --arg align "$NEW_ALIGNMENT" \
    --arg wm "$WEIGHT_MODIFIER" \
    '.[$key] = {
      "discussions": $disc,
      "avg_quality_score": ($avg | tonumber),
      "consensus_alignment": ($align | tonumber),
      "weight_modifier": ($wm | tonumber)
    }')

done <<< "$AGENT_DATA"

# 更新元数据
HISTORY=$(echo "$HISTORY" | jq --arg ts "$TIMESTAMP" '._meta.last_updated = $ts')

# 写入文件
echo "$HISTORY" | jq '.' > "$HISTORY_FILE"

echo "=== 历史权重已更新 ==="
echo "更新文件: $HISTORY_FILE"
echo "$HISTORY" | jq 'del(._meta)'
