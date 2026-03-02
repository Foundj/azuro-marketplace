#!/bin/bash
# 迁移 feature_list.json 从 v1 到 v2 schema

set -e

FEATURE_LIST=".agent/feature_list.json"
BACKUP_FILE=".agent/feature_list.v1.backup.json"

echo "🔄 开始迁移 feature_list.json schema (v1 → v2)..."

# 检查文件存在
if [ ! -f "$FEATURE_LIST" ]; then
  echo "❌ 错误: $FEATURE_LIST 不存在"
  exit 1
fi

# 备份原文件
echo "📦 备份原文件到 $BACKUP_FILE"
cp "$FEATURE_LIST" "$BACKUP_FILE"

# 检测当前版本
CURRENT_VERSION=$(jq -r '.version // "1.0"' "$FEATURE_LIST")
echo "📋 当前版本: $CURRENT_VERSION"

if [ "$CURRENT_VERSION" = "2.0-enhanced" ]; then
  echo "✅ 已经是 v2 schema，无需迁移"
  exit 0
fi

# 读取现有数据
PROJECT_NAME=$(jq -r '.project' "$FEATURE_LIST")
TECH_STACK=$(jq -r '.tech_stack' "$FEATURE_LIST")
CREATED=$(jq -r '.created' "$FEATURE_LIST")
TOTAL_FEATURES=$(jq -r '.total_features' "$FEATURE_LIST")
COMPLETED_FEATURES=$(jq -r '.completed_features' "$FEATURE_LIST")
CURRENT_SESSION=$(jq -r '.current_session // 1' "$FEATURE_LIST")
FEATURES=$(jq -c '.features' "$FEATURE_LIST")

echo "📊 迁移数据："
echo "  - 项目: $PROJECT_NAME"
echo "  - 总特性: $TOTAL_FEATURES"
echo "  - 已完成: $COMPLETED_FEATURES"

# 计算完成率
if [ "$TOTAL_FEATURES" -gt 0 ]; then
  COMPLETION_RATE=$(echo "scale=2; $COMPLETED_FEATURES * 100 / $TOTAL_FEATURES" | bc)
else
  COMPLETION_RATE=0
fi

# 生成迁移后的 JSON
cat > "$FEATURE_LIST" <<EOF
{
  "\$schema": "feature-list-schema-v2.0-enhanced",
  "project": "$PROJECT_NAME",
  "version": "2.0-enhanced",
  "created": "$CREATED",
  "tech_stack": $TECH_STACK,

  "changes": {
    "active": [],
    "staged": [],
    "archived_count": $COMPLETED_FEATURES
  },

  "features": $(echo "$FEATURES" | jq 'map(
    . + {
      "lifecycle": {
        "stage": (if .passes then "completed" else "pending" end),
        "phase": null,
        "workflow_id": null,
        "workflow_state": {
          "current_task": null,
          "completed_tasks": [],
          "pending_tasks": [],
          "completion_promise": null
        },
        "started_at": null,
        "completed_at": null,
        "estimated_duration": null,
        "actual_duration": null
      },
      "quality": {
        "confidence_scores": [],
        "issues": [],
        "test_coverage": 0,
        "build_status": "unknown",
        "lint_errors": 0,
        "type_errors": 0
      },
      "agents": {
        "primary": null,
        "supporting": [],
        "total_invocations": 0
      },
      "knowledge": {
        "related_patterns": [],
        "related_errors": [],
        "risk_level": "unknown",
        "prevention_measures_applied": []
      },
      "artifacts": {
        "proposal": null,
        "design": null,
        "tasks": null,
        "evidence": null,
        "phase0_context": null,
        "state": null
      },
      "archived": (.passes // false),
      "archived_path": null
    }
  )'),

  "ooda_loops": [],

  "statistics": {
    "total_features": $TOTAL_FEATURES,
    "completed_features": $COMPLETED_FEATURES,
    "completion_rate": $COMPLETION_RATE,
    "average_confidence": 0,
    "total_ooda_iterations": 0,
    "average_time_per_feature": null,
    "most_used_agent": null,
    "most_common_risk_level": null
  },

  "metadata": {
    "last_updated": "$(date -u +"%Y-%m-%d")",
    "current_session": $CURRENT_SESSION,
    "global_constraints_version": "1.0",
    "knowledge_base_entries": 0
  }
}
EOF

echo ""
echo "✅ 迁移完成！"
echo ""
echo "📋 迁移后统计："
echo "  - 版本: v2.0-enhanced"
echo "  - 总特性: $TOTAL_FEATURES"
echo "  - 已完成: $COMPLETED_FEATURES"
echo "  - 完成率: ${COMPLETION_RATE}%"
echo ""
echo "📦 备份文件: $BACKUP_FILE"
echo "💡 如需回滚: mv $BACKUP_FILE $FEATURE_LIST"
echo ""
echo "🎯 下一步："
echo "  1. 检查迁移后的数据: cat $FEATURE_LIST | jq '.'"
echo "  2. 验证数据完整性"
echo "  3. 删除备份文件（如果确认无误）: rm $BACKUP_FILE"
echo ""
