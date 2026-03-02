#!/usr/bin/env bash
# 根据执行器简写分发任务
# 用法: bash dispatch-task.sh <executor-shorthand> <prompt-file> <working-dir> [timeout]
#
# 解析执行器简写语法，路由到对应的执行方式：
#   self            → 输出 prompt 内容（由调用者在当前会话执行）
#   subagent[:<t>]  → 输出 subagent 调用指令
#   <tool>          → 调用 invoke-agent.sh
#   agent-team[:<t>]→ 输出 Agent Team 调用指令
#
# 已知 CLI 工具名: claude, codex, gemini, opencode, claudea, claudec, claudeg

set -euo pipefail

EXECUTOR="${1:?用法: dispatch-task.sh <executor> <prompt-file> <working-dir> [timeout]}"
PROMPT_FILE="${2:?请提供 prompt 文件路径}"
WORKING_DIR="${3:?请提供工作目录}"
TIMEOUT="${4:-300}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="${SCRIPT_DIR}/../../.."
INVOKE_AGENT="${PROJECT_ROOT}/skills/multi-agent-discussion/scripts/invoke-agent.sh"

# 已知 CLI 工具名集合
KNOWN_CLI_TOOLS="claude claudea claudec claudeg codex gemini opencode"

# 验证输入
if [ ! -f "$PROMPT_FILE" ]; then
  echo "错误: prompt 文件不存在: $PROMPT_FILE" >&2
  exit 1
fi

# 解析简写语法
parse_shorthand() {
  local input="$1"

  # self → 当前会话
  if [ "$input" = "self" ]; then
    echo "type=self"
    return
  fi

  # subagent / subagent:<type>
  if [[ "$input" == subagent* ]]; then
    local subtype="${input#subagent}"
    subtype="${subtype#:}"
    echo "type=subagent subtype=${subtype:-generalPurpose}"
    return
  fi

  # agent-team / agent-team:<template>
  if [[ "$input" == agent-team* ]]; then
    local template="${input#agent-team}"
    template="${template#:}"
    echo "type=agent-team template=${template:-feature-development}"
    return
  fi

  # 已知 CLI 工具名
  for tool in $KNOWN_CLI_TOOLS; do
    if [ "$input" = "$tool" ]; then
      echo "type=cli tool=$tool"
      return
    fi
  done

  echo "type=unknown input=$input"
}

PARSED=$(parse_shorthand "$EXECUTOR")
TYPE=$(echo "$PARSED" | sed -n 's/^type=\([^ ]*\).*/\1/p')

case "$TYPE" in
  self)
    echo '{"executor": "self", "action": "execute_in_session"}'
    echo "--- PROMPT ---"
    cat "$PROMPT_FILE"
    ;;

  subagent)
    SUBTYPE=$(echo "$PARSED" | sed -n 's/.*subtype=\([^ ]*\).*/\1/p')
    echo '{"executor": "subagent", "subagent_type": "'"$SUBTYPE"'", "prompt_file": "'"$PROMPT_FILE"'"}'
    ;;

  cli)
    TOOL=$(echo "$PARSED" | sed -n 's/.*tool=\([^ ]*\).*/\1/p')
    if ! command -v "$TOOL" &>/dev/null; then
      echo "警告: $TOOL 未安装，尝试降级..." >&2
      # 降级链: 指定工具 → claude → subagent
      if command -v claude &>/dev/null && [ "$TOOL" != "claude" ]; then
        echo "降级: $TOOL → claude" >&2
        TOOL="claude"
      else
        echo '{"executor": "subagent", "subagent_type": "generalPurpose", "degraded_from": "'"$TOOL"'"}'
        exit 0
      fi
    fi

    if [ ! -f "$INVOKE_AGENT" ]; then
      echo "错误: invoke-agent.sh 不存在: $INVOKE_AGENT" >&2
      echo "请确保 skills/multi-agent-discussion 已安装" >&2
      exit 1
    fi

    bash "$INVOKE_AGENT" "$TOOL" "$PROMPT_FILE" "$WORKING_DIR" "$TIMEOUT"
    ;;

  agent-team)
    TEMPLATE=$(echo "$PARSED" | sed -n 's/.*template=\([^ ]*\).*/\1/p')
    echo '{"executor": "agent-team", "template": "'"$TEMPLATE"'", "prompt_file": "'"$PROMPT_FILE"'"}'
    ;;

  *)
    echo "错误: 无法解析执行器简写: $EXECUTOR" >&2
    echo "支持: self, subagent[:<type>], <cli-tool>, agent-team[:<template>]" >&2
    exit 1
    ;;
esac
