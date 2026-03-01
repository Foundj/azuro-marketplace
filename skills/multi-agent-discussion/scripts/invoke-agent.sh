#!/usr/bin/env bash
# 统一 Agent 调用封装
# 用法: bash invoke-agent.sh <tool> <prompt-file> <working-dir> [timeout]
#
# 根据 tool 类型选择对应 CLI 命令调用 agent。
# 读取 prompt-file 内容作为提示词，在 working-dir 下执行。
#
# 支持的 tool:
#   codex    → codex exec
#   opencode → opencode run
#   gemini   → gemini -p
#   claude   → claude -p
#   claudea  → claudea -p
#   claudec  → claudec -p
#   claudeg  → claudeg -p
#
# 返回: agent 的文本响应（stdout）
# 错误: 超时或调用失败时返回 exit 1 + 错误信息（stderr）

set -euo pipefail

TOOL="${1:?用法: invoke-agent.sh <tool> <prompt-file> <working-dir> [timeout]}"
PROMPT_FILE="${2:?请提供 prompt 文件路径}"
WORKING_DIR="${3:?请提供工作目录}"
TIMEOUT="${4:-300}"  # 默认 300 秒超时

# 验证输入
if [ ! -f "$PROMPT_FILE" ]; then
  echo "错误: prompt 文件不存在: $PROMPT_FILE" >&2
  exit 1
fi

if [ ! -d "$WORKING_DIR" ]; then
  echo "错误: 工作目录不存在: $WORKING_DIR" >&2
  exit 1
fi

# 读取 prompt 内容
PROMPT=$(cat "$PROMPT_FILE")

if [ -z "$PROMPT" ]; then
  echo "错误: prompt 文件为空: $PROMPT_FILE" >&2
  exit 1
fi

# 执行工具调用
# 使用 timeout 命令（macOS 需要 coreutils 的 gtimeout 或使用内置方案）
run_with_timeout() {
  local cmd=("$@")

  if command -v gtimeout &>/dev/null; then
    gtimeout "${TIMEOUT}s" "${cmd[@]}"
  elif command -v timeout &>/dev/null; then
    timeout "${TIMEOUT}s" "${cmd[@]}"
  else
    # 无 timeout 命令，直接执行（后台 + wait + kill）
    "${cmd[@]}" &
    local pid=$!
    local count=0
    while kill -0 "$pid" 2>/dev/null; do
      sleep 1
      count=$((count + 1))
      if [ "$count" -ge "$TIMEOUT" ]; then
        kill "$pid" 2>/dev/null || true
        wait "$pid" 2>/dev/null || true
        echo "错误: 调用超时 (${TIMEOUT}s)" >&2
        return 1
      fi
    done
    wait "$pid"
    return $?
  fi
}

# claude* 变体需要清除所有嵌套 session 环境变量
# 因为编排器本身运行在 Claude Code 内部
# CLAUDECODE、CLAUDE_CODE_ENTRYPOINT 及其他 CLAUDE_CODE_* 都可能触发嵌套检测
# 构建 env -u 参数列表，清除所有 CLAUDE 相关环境变量
CLAUDE_ENV_UNSET_ARGS=()
while IFS= read -r varname; do
  CLAUDE_ENV_UNSET_ARGS+=(-u "$varname")
done < <(env | grep -o '^CLAUDE[A-Z_]*' || true)

# 辅助函数：在干净环境中运行 claude* 命令
# 注意: 从 Claude Code 内部调用 claude* 存在嵌套限制，可能挂起或返回空
# 建议优先使用 codex/gemini 后端，claude* 适合从普通终端调用
run_claude_clean() {
  if [ ${#CLAUDE_ENV_UNSET_ARGS[@]} -gt 0 ]; then
    echo "警告: 检测到 Claude Code 嵌套环境，claude* 后端可能不稳定" >&2
  fi
  run_with_timeout env "${CLAUDE_ENV_UNSET_ARGS[@]}" "$@"
}

case "$TOOL" in
  codex)
    if ! command -v codex &>/dev/null; then
      echo "错误: codex 未安装" >&2
      exit 1
    fi
    run_with_timeout codex exec "$PROMPT" \
      --full-auto \
      --ephemeral \
      -c model_reasoning_effort="xhigh" \
      -C "$WORKING_DIR"
    ;;

  opencode)
    if ! command -v opencode &>/dev/null; then
      echo "错误: opencode 未安装" >&2
      exit 1
    fi
    # opencode 需要在工作目录下运行
    cd "$WORKING_DIR"
    run_with_timeout opencode run "$PROMPT" --format json
    ;;

  gemini)
    if ! command -v gemini &>/dev/null; then
      echo "错误: gemini 未安装" >&2
      exit 1
    fi
    run_with_timeout gemini -p "$PROMPT" \
      --sandbox \
      -o text \
      --approval-mode yolo \
      --include-directories "$WORKING_DIR"
    ;;

  claude)
    if ! command -v claude &>/dev/null; then
      echo "错误: claude 未安装" >&2
      exit 1
    fi
    run_claude_clean claude -p "$PROMPT" \
      --output-format text \
      --no-session-persistence \
      --max-turns 5 \
      --allowedTools "Read,Write,Edit,Glob,Grep"
    ;;

  claudea)
    if ! command -v claudea &>/dev/null; then
      echo "错误: claudea 未安装" >&2
      exit 1
    fi
    run_claude_clean claudea -p "$PROMPT" \
      --output-format text \
      --no-session-persistence \
      --max-turns 5 \
      --allowedTools "Read,Write,Edit,Glob,Grep"
    ;;

  claudec)
    if ! command -v claudec &>/dev/null; then
      echo "错误: claudec 未安装" >&2
      exit 1
    fi
    run_claude_clean claudec -p "$PROMPT" \
      --output-format text \
      --no-session-persistence \
      --max-turns 5 \
      --allowedTools "Read,Write,Edit,Glob,Grep"
    ;;

  claudeg)
    if ! command -v claudeg &>/dev/null; then
      echo "错误: claudeg 未安装" >&2
      exit 1
    fi
    run_claude_clean claudeg -p "$PROMPT" \
      --output-format text \
      --no-session-persistence \
      --max-turns 5 \
      --allowedTools "Read,Write,Edit,Glob,Grep"
    ;;

  *)
    echo "错误: 不支持的工具类型: $TOOL" >&2
    echo "支持的工具: codex, opencode, gemini, claude, claudea, claudec, claudeg" >&2
    exit 1
    ;;
esac
