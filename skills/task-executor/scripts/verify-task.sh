#!/usr/bin/env bash
# 运行任务验证命令
# 用法: bash verify-task.sh <verify-command> [working-dir]
#
# 执行 task.md 中任务的 verify 命令，报告通过/失败。
# 支持 verify 值为 "true"（跳过验证）。

set -euo pipefail

VERIFY_CMD="${1:?用法: verify-task.sh <verify-command> [working-dir]}"
WORKING_DIR="${2:-.}"

# 特殊值: "true" 表示跳过验证
if [ "$VERIFY_CMD" = "true" ]; then
  echo '{"status": "skipped", "reason": "verify set to true"}'
  exit 0
fi

# 空命令
if [ -z "$VERIFY_CMD" ]; then
  echo '{"status": "skipped", "reason": "no verify command"}'
  exit 0
fi

if [ ! -d "$WORKING_DIR" ]; then
  echo "错误: 工作目录不存在: $WORKING_DIR" >&2
  echo '{"status": "failed", "reason": "working directory not found"}'
  exit 1
fi

echo "=== 执行验证: $VERIFY_CMD ==="
echo "工作目录: $WORKING_DIR"
echo ""

START_TIME=$(date +%s)

# 在工作目录中执行验证命令，捕获输出和退出码
OUTPUT_FILE=$(mktemp)
ERR_FILE=$(mktemp)
trap "rm -f $OUTPUT_FILE $ERR_FILE" EXIT

set +e
(cd "$WORKING_DIR" && eval "$VERIFY_CMD") >"$OUTPUT_FILE" 2>"$ERR_FILE"
EXIT_CODE=$?
set -e

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# 输出结果
STDOUT=$(cat "$OUTPUT_FILE")
STDERR=$(cat "$ERR_FILE")

if [ $EXIT_CODE -eq 0 ]; then
  echo "✅ 验证通过 (${DURATION}s)"
  echo ""
  if [ -n "$STDOUT" ]; then
    echo "--- 输出 ---"
    echo "$STDOUT" | head -20
    LINES=$(echo "$STDOUT" | wc -l)
    if [ "$LINES" -gt 20 ]; then
      echo "... (共 $LINES 行，已截断)"
    fi
  fi
  echo ""
  echo '{"status": "passed", "exit_code": 0, "duration_seconds": '"$DURATION"'}'
else
  echo "❌ 验证失败 (exit code: $EXIT_CODE, ${DURATION}s)"
  echo ""
  if [ -n "$STDERR" ]; then
    echo "--- 错误 ---"
    echo "$STDERR" | head -20
  fi
  if [ -n "$STDOUT" ]; then
    echo "--- 输出 ---"
    echo "$STDOUT" | head -20
  fi
  echo ""
  echo '{"status": "failed", "exit_code": '"$EXIT_CODE"', "duration_seconds": '"$DURATION"'}'
  exit 1
fi
