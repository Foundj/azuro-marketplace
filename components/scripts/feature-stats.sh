#!/bin/bash
# 生成特性完成统计

set -e

echo "📊 Feature Statistics"
echo "===================="
echo ""

# 检查文件存在
if [ ! -f "codebox/feature_list.json" ]; then
  echo "❌ ERROR: feature_list.json not found"
  exit 1
fi

# 基本统计
TOTAL=$(jq '.total_features' codebox/feature_list.json)
COMPLETED=$(jq '.completed_features' codebox/feature_list.json)

if [ "$TOTAL" -eq 0 ]; then
  echo "⚠️  No features found in feature_list.json"
  exit 0
fi

PERCENTAGE=$((COMPLETED * 100 / TOTAL))
REMAINING=$((TOTAL - COMPLETED))

echo "📈 Overall Progress"
echo "-------------------"
echo "Total Features: $TOTAL"
echo "Completed: $COMPLETED ($PERCENTAGE%)"
echo "Remaining: $REMAINING"
echo ""

# 按类别统计
echo "📂 By Category"
echo "-------------------"
jq -r '.features | group_by(.category) | .[] |
  "\(.[0].category): \(map(select(.passes == true)) | length)/\(length) (\((map(select(.passes == true)) | length) * 100 / length)%)"' \
  codebox/feature_list.json

echo ""

# 按优先级统计
echo "⭐ By Priority"
echo "-------------------"
jq -r '.features | group_by(.priority) | .[] |
  "\(.[0].priority): \(map(select(.passes == true)) | length)/\(length)"' \
  codebox/feature_list.json

echo ""

# 最近完成的特性
echo "✅ Recently Completed (Last 5)"
echo "-------------------"
jq -r '.features | map(select(.passes == true)) | .[-5:] | .[] |
  "#\(.id): \(.description)"' \
  codebox/feature_list.json

echo ""

# 下一个待完成的高优先级特性
echo "🎯 Next High Priority Features"
echo "-------------------"
jq -r '.features | map(select(.passes == false and .priority == "high")) | .[0:3] | .[] |
  "#\(.id): \(.description)"' \
  codebox/feature_list.json

echo ""
echo "===================="
echo "Use /status for full project report"
