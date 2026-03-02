#!/usr/bin/env bash
# 更新 task.md 中任务的勾选状态
# 用法: bash update-task-status.sh <task-file> <task-id> <action> [note]
#
# action:
#   check    — 标记为已完成 [x]
#   uncheck  — 标记为未完成 [ ]
#   status   — 更新 frontmatter status 字段
#
# 示例:
#   bash update-task-status.sh docs/tasks/v1.0/task.md s1-1 check
#   bash update-task-status.sh docs/tasks/v1.0/task.md s1-1 check "Profile 配置完成"
#   bash update-task-status.sh docs/tasks/v1.0/task.md in_progress status
#   （status 模式下第 2 参数是新状态值，第 3 参数固定为 "status"）

set -euo pipefail

TASK_FILE="${1:?用法: update-task-status.sh <task-file> <task-id> <action> [note]}"
TASK_ID="${2:?请提供任务 ID}"
ACTION="${3:?请提供操作: check | uncheck | status}"
NOTE="${4:-}"

if [ ! -f "$TASK_FILE" ]; then
  echo "错误: 文件不存在: $TASK_FILE" >&2
  exit 1
fi

# macOS/Linux 兼容的 sed in-place
sed_inplace() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

case "$ACTION" in
  check)
    # 将 - [ ] `task-id` 改为 - [x] `task-id`
    if grep -q "^\- \[ \] \`${TASK_ID}\`" "$TASK_FILE"; then
      sed_inplace "s/^\- \[ \] \`${TASK_ID}\`/- [x] \`${TASK_ID}\`/" "$TASK_FILE"
      echo "✅ ${TASK_ID} 标记为已完成"

      # 追加变更记录
      if [ -n "$NOTE" ]; then
        DATE=$(date '+%Y-%m-%d')
        RECORD="| ${DATE} | \`${TASK_ID}\` 标记已完成 | ${NOTE} |"
        if grep -q "^| .* | .* | .* |$" "$TASK_FILE"; then
          LAST_LINE=$(grep -n "^| .* | .* | .* |$" "$TASK_FILE" | tail -1 | cut -d: -f1)
          { head -n "$LAST_LINE" "$TASK_FILE"; echo "$RECORD"; tail -n +$((LAST_LINE + 1)) "$TASK_FILE"; } > "${TASK_FILE}.tmp" && mv "${TASK_FILE}.tmp" "$TASK_FILE"
        fi
      fi
    else
      echo "警告: 未找到未完成的任务 ${TASK_ID}" >&2
      if grep -q "\`${TASK_ID}\`" "$TASK_FILE"; then
        echo "任务已标记为完成或 ID 不匹配" >&2
      else
        echo "任务 ID 不存在" >&2
      fi
      exit 1
    fi
    ;;

  uncheck)
    # 将 - [x] `task-id` 改为 - [ ] `task-id`
    if grep -q "^\- \[x\] \`${TASK_ID}\`" "$TASK_FILE"; then
      sed_inplace "s/^\- \[x\] \`${TASK_ID}\`/- [ ] \`${TASK_ID}\`/" "$TASK_FILE"
      echo "⬜ ${TASK_ID} 标记为未完成"
    else
      echo "警告: 未找到已完成的任务 ${TASK_ID}" >&2
      exit 1
    fi
    ;;

  status)
    # 更新 frontmatter 中的 status 字段
    NEW_STATUS="$TASK_ID"  # 在 status 模式下，第二个参数是新状态值
    VALID_STATUSES="pending in_progress completed archived"
    if ! echo "$VALID_STATUSES" | grep -qw "$NEW_STATUS"; then
      echo "错误: 无效状态 '$NEW_STATUS'" >&2
      echo "有效状态: $VALID_STATUSES" >&2
      exit 1
    fi
    sed_inplace "s/^status: .*/status: ${NEW_STATUS}/" "$TASK_FILE"
    echo "📋 status 更新为 ${NEW_STATUS}"

    # 更新 updated 日期
    DATE=$(date '+%Y-%m-%d')
    sed_inplace "s/^updated: .*/updated: ${DATE}/" "$TASK_FILE"
    ;;

  *)
    echo "错误: 未知操作 '$ACTION'" >&2
    echo "可用操作: check, uncheck, status" >&2
    exit 1
    ;;
esac
