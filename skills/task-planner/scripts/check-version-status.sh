#!/bin/bash

# check-version-status.sh
# 扫描 docs/tasks/ 下所有版本的状态
# 用法: bash skills/task-planner/scripts/check-version-status.sh [project-root]

set -euo pipefail

PROJECT_ROOT="${1:-.}"
TASKS_DIR="${PROJECT_ROOT}/docs/tasks"

# 颜色
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m'

if [[ ! -d "$TASKS_DIR" ]]; then
    echo "No docs/tasks/ directory found at ${TASKS_DIR}"
    exit 0
fi

echo ""
echo -e "${CYAN}📋 版本状态概览${NC}"
echo "─────────────────────────────────────────────"

# 收集版本目录
versions=()
for dir in "$TASKS_DIR"/v*/; do
    [[ -d "$dir" ]] && versions+=("$(basename "$dir")")
done

if [[ ${#versions[@]} -eq 0 ]]; then
    echo "  No versions found."
    exit 0
fi

# 按版本号排序
IFS=$'\n' sorted=($(printf '%s\n' "${versions[@]}" | sed 's/^v//' | sort -t. -k1,1n -k2,2n | sed 's/^/v/')); unset IFS

for version in "${sorted[@]}"; do
    task_file="${TASKS_DIR}/${version}/task.md"

    if [[ ! -f "$task_file" ]]; then
        echo -e "  ${version}  ❓ no task.md"
        continue
    fi

    # 提取 status 和 name (从 YAML frontmatter)
    status=$(grep -m1 '^status:' "$task_file" | sed 's/status: *//' | tr -d '"' || echo "unknown")
    name=$(grep -m1 '^name:' "$task_file" | sed 's/name: *//' || echo "unnamed")

    # 计算任务进度 (统计 checkbox)
    total=$(grep -c '^\- \[[ x]\]' "$task_file" 2>/dev/null || echo "0")
    done_count=$(grep -c '^\- \[x\]' "$task_file" 2>/dev/null || echo "0")

    if [[ "$total" -gt 0 ]]; then
        pct=$((done_count * 100 / total))
    else
        pct=0
    fi

    # 状态图标
    case "$status" in
        archived)
            icon="✅"
            color=$GREEN
            ;;
        completed)
            icon="🏁"
            color=$GREEN
            ;;
        in_progress)
            icon="🔄"
            color=$YELLOW
            ;;
        pending)
            icon="⏳"
            color=$NC
            ;;
        *)
            icon="❓"
            color=$RED
            ;;
    esac

    printf "  %-8s %s %-14s %s (%d/%d, %d%%)\n" \
        "$version" "$icon" "$status" "$name" "$done_count" "$total" "$pct"
done

echo "─────────────────────────────────────────────"

# JSON 输出模式
if [[ "${2:-}" == "--json" ]]; then
    echo ""
    echo "{"
    echo "  \"versions\": ["
    first=true
    for version in "${sorted[@]}"; do
        task_file="${TASKS_DIR}/${version}/task.md"
        [[ ! -f "$task_file" ]] && continue

        status=$(grep -m1 '^status:' "$task_file" | sed 's/status: *//' | tr -d '"' || echo "unknown")
        name=$(grep -m1 '^name:' "$task_file" | sed 's/name: *//' || echo "unnamed")
        total=$(grep -c '^\- \[[ x]\]' "$task_file" 2>/dev/null || echo "0")
        done_count=$(grep -c '^\- \[x\]' "$task_file" 2>/dev/null || echo "0")

        [[ "$first" != "true" ]] && echo ","
        printf '    {"version": "%s", "name": "%s", "status": "%s", "done": %d, "total": %d}' \
            "$version" "$name" "$status" "$done_count" "$total"
        first=false
    done
    echo ""
    echo "  ]"
    echo "}"
fi
