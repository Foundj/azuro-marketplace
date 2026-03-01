#!/usr/bin/env bash
# 检测所有可用的 CLI 工具后端
# 用法: bash detect-cli-tools.sh
#
# 检测: codex, opencode, gemini, claude, claudea, claudec, claudeg
# 输出: JSON 格式的工具可用性信息
#
# 返回的 JSON 结构:
# {
#   "tools": { ... },
#   "available_count": N,
#   "auto_mode_possible": true/false
# }

set -euo pipefail

# 检测单个工具
# 参数: $1=命令名, $2=非交互子命令/参数, $3=可选的 settings 文件
detect_tool() {
  local cmd="$1"
  local subcmd="${2:-}"
  local settings="${3:-}"
  local path=""
  local available=false
  local version=""

  path=$(command -v "$cmd" 2>/dev/null || true)

  if [ -n "$path" ]; then
    available=true
    # 尝试获取版本（静默失败）
    version=$("$cmd" --version 2>/dev/null | head -1 || echo "unknown")
  fi

  # 输出 JSON 片段
  printf '    "%s": {\n' "$cmd"
  printf '      "available": %s,\n' "$available"
  printf '      "path": "%s"' "${path:-}"

  if [ -n "$subcmd" ]; then
    printf ',\n      "subcmd": "%s"' "$subcmd"
  fi

  if [ -n "$settings" ]; then
    local settings_path
    settings_path="$HOME/.claude/$settings"
    local settings_exists=false
    if [ -f "$settings_path" ]; then
      settings_exists=true
    fi
    printf ',\n      "settings": "%s",\n' "$settings"
    printf '      "settings_exists": %s' "$settings_exists"
  fi

  if [ -n "$version" ]; then
    # 转义 JSON 中的特殊字符
    version=$(echo "$version" | sed 's/"/\\"/g' | tr -d '\n')
    printf ',\n      "version": "%s"' "$version"
  fi

  printf '\n    }'
}

# 开始输出 JSON
echo '{'
echo '  "tools": {'

# 检测每个工具
detect_tool "codex" "exec"
echo ','
detect_tool "opencode" "run"
echo ','
detect_tool "gemini" "-p"
echo ','
detect_tool "claude" "-p"
echo ','
detect_tool "claudea" "-p" "settings-proxy.json"
echo ','
detect_tool "claudec" "-p" "settings-cli.json"
echo ','
detect_tool "claudeg" "-p" "settings-google.json"
echo ''

echo '  },'

# 统计可用工具数
available_count=0
for cmd in codex opencode gemini claude claudea claudec claudeg; do
  if command -v "$cmd" &>/dev/null; then
    available_count=$((available_count + 1))
  fi
done

# 排除当前 claude 自身（编排器不能调用自己参与讨论）
# claude 本身作为编排器，不计入可用"外部"工具
external_count=0
for cmd in codex opencode gemini claudea claudec claudeg; do
  if command -v "$cmd" &>/dev/null; then
    external_count=$((external_count + 1))
  fi
done

# 检测是否在 Claude Code 嵌套环境中
in_claude_code=false
if [ "${CLAUDECODE:-}" = "1" ] || [ -n "${CLAUDE_CODE_ENTRYPOINT:-}" ]; then
  in_claude_code=true
fi

echo "  \"available_count\": $available_count,"
echo "  \"external_count\": $external_count,"
echo "  \"in_claude_code\": $in_claude_code,"

# 至少需要 1 个外部工具才能进入自动模式
# 注意: 在 Claude Code 内部，claude* 变体受嵌套限制，优先使用 codex/gemini
if [ "$external_count" -ge 1 ]; then
  echo '  "auto_mode_possible": true'
else
  echo '  "auto_mode_possible": false'
fi

echo '}'
