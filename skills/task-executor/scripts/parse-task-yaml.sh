#!/usr/bin/env bash
# 解析 task.md YAML frontmatter
# 用法: bash parse-task-yaml.sh <task-file> [--json | --sprints | --tasks | --status | --rules]
#
# 从 task.md 的 YAML frontmatter 中提取结构化信息。
# 默认输出完整 YAML（去掉分隔符），可通过选项指定输出格式。
#
# 依赖: awk, sed; python3 + PyYAML (仅 --json 模式)

set -euo pipefail

TASK_FILE="${1:?用法: parse-task-yaml.sh <task-file> [--json|--sprints|--tasks|--status|--rules]}"
MODE="${2:---yaml}"

if [ ! -f "$TASK_FILE" ]; then
  echo "错误: 文件不存在: $TASK_FILE" >&2
  exit 1
fi

# 提取 YAML frontmatter（两个 --- 之间的内容）
extract_frontmatter() {
  awk '/^---$/ { count++; next } count == 1 { print } count >= 2 { exit }' "$1"
}

YAML=$(extract_frontmatter "$TASK_FILE")

if [ -z "$YAML" ]; then
  echo "错误: 未找到 YAML frontmatter" >&2
  exit 1
fi

case "$MODE" in
  --yaml)
    echo "$YAML"
    ;;

  --json)
    if ! command -v python3 &>/dev/null; then
      echo "错误: --json 模式需要 python3 (含 PyYAML 或 pyyaml)" >&2
      exit 1
    fi
    echo "$YAML" | python3 -c "
import sys, json
try:
    import yaml
    data = yaml.safe_load(sys.stdin.read())
    print(json.dumps(data, ensure_ascii=False, indent=2))
except ImportError:
    print(json.dumps({'error': 'PyYAML not installed. Run: pip install pyyaml'}))
    sys.exit(1)
"
    ;;

  --status)
    echo "$YAML" | grep -E '^(version|name|status|updated):' | sed 's/^/  /'
    ;;

  --rules)
    echo "$YAML" | awk '/^rules:/{found=1; next} found && /^[^ ]/{exit} found{print}'
    ;;

  --sprints)
    echo "$YAML" | awk '/^sprints:/{found=1; print; next} found && /^[^ ]/{exit} found{print}'
    ;;

  --tasks)
    # 输出所有任务 ID 和名称，带完成状态
    echo "# 任务列表 (来自 $TASK_FILE)"
    echo ""
    awk '/^---$/{ count++; next } count >= 2' "$TASK_FILE" | { grep -E '^- \[(x| )\]' || true; } | while IFS= read -r line; do
      if [ -z "$line" ]; then continue; fi
      if echo "$line" | grep -q '\[x\]'; then
        STATUS="done"
      else
        STATUS="todo"
      fi
      TASK_ID=$(echo "$line" | grep -oE '`[^`]+`' | head -1 | tr -d '`' || true)
      DESC=$(echo "$line" | sed 's/^- \[[ x]\] //' | sed 's/`[^`]*` //')
      printf "  [%s] %-12s %s\n" "$STATUS" "${TASK_ID:-unknown}" "$DESC"
    done
    ;;

  --next)
    # 找到下一个未完成的任务（必须包含 `task-id` 格式）
    NEXT=$(awk '/^---$/{ count++; next } count >= 2' "$TASK_FILE" | grep -E '^- \[ \] `[^`]+`' | head -1 || true)
    if [ -z "$NEXT" ]; then
      echo "ALL_DONE"
    else
      TASK_ID=$(echo "$NEXT" | grep -oE '`[^`]+`' | head -1 | tr -d '`' || true)
      echo "${TASK_ID:-UNKNOWN}"
    fi
    ;;

  *)
    echo "错误: 未知模式 $MODE" >&2
    echo "可用模式: --yaml, --json, --sprints, --tasks, --status, --rules, --next" >&2
    exit 1
    ;;
esac
