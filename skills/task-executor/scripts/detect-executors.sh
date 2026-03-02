#!/usr/bin/env bash
# 检测可用执行器
# 用法: bash detect-executors.sh [--json]
#
# 检测系统中安装的 CLI 工具，输出可用执行器列表。
# 复用 multi-agent-discussion 的 detect-cli-tools.sh 逻辑。

set -euo pipefail

FORMAT="${1:---text}"




# 检测 CLI 工具
TOOL_NAMES=(claude claudea claudec claudeg codex gemini opencode)

AVAILABLE_CLI=()
UNAVAILABLE_CLI=()

for name in "${TOOL_NAMES[@]}"; do
  if command -v "$name" &>/dev/null; then
    AVAILABLE_CLI+=("$name")
  else
    UNAVAILABLE_CLI+=("$name")
  fi
done

# 内置执行器（始终可用）
BUILTIN=("self" "subagent")

# Agent Teams 检测
AGENT_TEAMS_AVAILABLE=false
if [ -n "${CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS:-}" ] && [ "$CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" = "1" ]; then
  AGENT_TEAMS_AVAILABLE=true
fi

case "$FORMAT" in
  --json)
    # 构建 JSON 输出
    if [ ${#AVAILABLE_CLI[@]} -gt 0 ]; then
      CLI_JSON=$(printf '"%s",' "${AVAILABLE_CLI[@]}" | sed 's/,$//')
    else
      CLI_JSON=""
    fi
    if [ ${#UNAVAILABLE_CLI[@]} -gt 0 ]; then
      UNAVAIL_JSON=$(printf '"%s",' "${UNAVAILABLE_CLI[@]}" | sed 's/,$//')
    else
      UNAVAIL_JSON=""
    fi
    TEAM_COUNT=0
    [ "$AGENT_TEAMS_AVAILABLE" = true ] && TEAM_COUNT=1
    TOTAL=$((${#BUILTIN[@]} + ${#AVAILABLE_CLI[@]} + TEAM_COUNT))
    cat <<EOF
{
  "builtin": ["self", "subagent"],
  "cli_available": [${CLI_JSON}],
  "cli_unavailable": [${UNAVAIL_JSON}],
  "agent_teams": ${AGENT_TEAMS_AVAILABLE},
  "total_available": ${TOTAL}
}
EOF
    ;;

  --text|*)
    echo "=== 可用执行器 ==="
    echo ""
    echo "内置:"
    for b in "${BUILTIN[@]}"; do
      echo "  ✅ $b"
    done
    echo ""
    echo "CLI 工具:"
    for t in "${AVAILABLE_CLI[@]}"; do
      echo "  ✅ $t"
    done
    for t in "${UNAVAILABLE_CLI[@]}"; do
      echo "  ❌ $t (未安装)"
    done
    echo ""
    if [ "$AGENT_TEAMS_AVAILABLE" = true ]; then
      echo "Agent Teams: ✅ 已启用"
    else
      echo "Agent Teams: ❌ 未启用 (设置 CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1)"
    fi
    ;;
esac
