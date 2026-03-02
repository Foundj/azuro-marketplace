#!/bin/bash

# Archive Version Script
# Checks archive conditions and archives a completed version

set -euo pipefail

# ============================================================================
# Configuration
# ============================================================================

TASKS_DIR="docs/tasks"

# ============================================================================
# Helper Functions
# ============================================================================

log_info() {
    echo "[INFO] Archive: $1"
}

log_error() {
    echo "[ERROR] Archive: $1" >&2
}

log_warn() {
    echo "[WARN] Archive: $1"
}

# ============================================================================
# Archive Condition Checks
# ============================================================================

check_tasks_complete() {
    local task_file="$1"

    # Count unchecked tasks (excluding comments and template lines)
    local unchecked
    unchecked=$(grep -c '^\s*- \[ \]' "$task_file" 2>/dev/null || echo "0")

    if [[ "$unchecked" -gt 0 ]]; then
        log_error "Found $unchecked unchecked tasks in $task_file"
        return 1
    fi

    log_info "All tasks completed"
    return 0
}

check_status_completed() {
    local task_file="$1"

    # Extract status from YAML frontmatter (robust: stop at second ---)
    local status
    status=$(awk '/^---$/{if(++c==2)exit}c==1 && /^status:/{print $2}' "$task_file" | tr -d '"')

    if [[ "$status" == "archived" ]]; then
        log_info "Version is already archived"
        return 1
    fi

    if [[ "$status" != "completed" ]]; then
        log_error "Task status is '$status', expected 'completed'"
        return 1
    fi

    log_info "Status is 'completed'"
    return 0
}

check_git_clean() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        log_warn "Not a git repository, skipping git check"
        return 0
    fi

    local dirty
    dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')

    if [[ "$dirty" -gt 0 ]]; then
        log_error "Git has $dirty uncommitted changes"
        return 1
    fi

    log_info "Git working tree is clean"
    return 0
}

# ============================================================================
# Archive Operations
# ============================================================================

generate_archived_md() {
    local version="$1"
    local version_dir="${TASKS_DIR}/${version}"
    local task_file="${version_dir}/task.md"
    local plan_file="${version_dir}/plan.md"
    local archive_file="${version_dir}/ARCHIVED.md"
    local date
    date=$(date +%Y-%m-%d)

    # Extract name from frontmatter (robust: stop at second ---)
    local name
    name=$(awk '/^---$/{if(++c==2)exit}c==1 && /^name:/{sub(/^name: */, ""); print}' "$task_file")

    # Count tasks (unified regex: match "- [ ]" or "- [x]" with optional indent)
    local total
    total=$(grep -c '^\s*- \[[ x]\]' "$task_file" 2>/dev/null || echo "0")
    local done
    done=$(grep -c '^\s*- \[x\]' "$task_file" 2>/dev/null || echo "0")

    # Count sprints
    local sprints
    sprints=$(grep -c '^## Sprint' "$task_file" 2>/dev/null || echo "0")

    # Count change log entries
    local entries
    entries=$(grep -c '^|' "$task_file" 2>/dev/null || echo "0")
    entries=$((entries > 2 ? entries - 2 : 0))  # Subtract header rows

    cat > "$archive_file" <<EOF
# V${version#v} 归档摘要

- **版本**: ${version}
- **名称**: ${name}
- **归档日期**: ${date}

## 完成概况

- Sprint 数量: ${sprints}
- 任务数量: ${total} (已完成: ${done})
- 变更记录条目: ${entries}

## 关键成果

<!-- 从 task.md 变更记录中提取的关键条目 -->

## 学习要点

<!-- 从 plan.md ADR 和 task.md review 结论中提取 -->
EOF

    log_info "Generated $archive_file"
}

generate_knowledge_md() {
    local version="$1"
    local version_dir="${TASKS_DIR}/${version}"
    local knowledge_file="${version_dir}/knowledge.md"
    local date
    date=$(date +%Y-%m-%d)

    # Extract name from frontmatter (robust: stop at second ---)
    local task_file="${version_dir}/task.md"
    local name
    name=$(awk '/^---$/{if(++c==2)exit}c==1 && /^name:/{sub(/^name: */, ""); print}' "$task_file")

    cat > "$knowledge_file" <<EOF
# V${version#v} 知识提取

## 版本概要

- 名称: ${name}
- 归档日期: ${date}

## 关键决策

<!-- 从 plan.md 的 ADR 记录提取 -->

## 发现的模式

<!-- 从 task.md review 中发现的可复用模式 -->

## 项目特征变化

<!-- 本版本带来的项目能力变化、技术栈更新等 -->

## 教训

<!-- 从 P1/P2 修复中提取的经验教训 -->
EOF

    log_info "Generated $knowledge_file"
}

update_task_status() {
    local version="$1"
    local task_file="${TASKS_DIR}/${version}/task.md"

    # Update status in frontmatter from completed to archived
    if [[ "$(uname)" == "Darwin" ]]; then
        sed -i '' 's/^status: completed$/status: archived/' "$task_file"
    else
        sed -i 's/^status: completed$/status: archived/' "$task_file"
    fi

    log_info "Updated task.md status to 'archived'"
}

# ============================================================================
# Main
# ============================================================================

usage() {
    cat <<EOF
Usage: $(basename "$0") [--dry-run] [--force] <version>

Archive a completed version in docs/tasks/.

Arguments:
    version      Version to archive (e.g., v1.0)

Options:
    --dry-run    Check conditions only, don't archive
    --force      Skip git clean check

Examples:
    $(basename "$0") --dry-run v1.0     # Check if v1.0 can be archived
    $(basename "$0") v1.0               # Archive v1.0
    $(basename "$0") --force v1.0       # Archive without git check
EOF
}

main() {
    local dry_run=false
    local force=false
    local version=""

    while [[ $# -gt 0 ]]; do
        case "$1" in
            --dry-run) dry_run=true; shift ;;
            --force) force=true; shift ;;
            -h|--help) usage; exit 0 ;;
            v*) version="$1"; shift ;;
            [0-9]*) version="v$1"; shift ;;
            *) log_error "Unknown argument: $1"; usage; exit 1 ;;
        esac
    done

    if [[ -z "$version" ]]; then
        log_error "Version is required"
        usage
        exit 1
    fi

    local version_dir="${TASKS_DIR}/${version}"
    local task_file="${version_dir}/task.md"

    # Check directory exists
    if [[ ! -d "$version_dir" ]]; then
        log_error "Version directory not found: $version_dir"
        exit 1
    fi

    if [[ ! -f "$task_file" ]]; then
        log_error "task.md not found: $task_file"
        exit 1
    fi

    echo "=== Archive Check: ${version} ==="
    echo ""

    # Run condition checks
    local failed=0

    check_tasks_complete "$task_file" || ((failed++))
    check_status_completed "$task_file" || ((failed++))

    if [[ "$force" == false ]]; then
        check_git_clean || ((failed++))
    else
        log_warn "Skipping git clean check (--force)"
    fi

    echo ""

    if [[ "$failed" -gt 0 ]]; then
        log_error "Archive conditions not met ($failed check(s) failed)"
        exit 1
    fi

    log_info "All archive conditions met"

    if [[ "$dry_run" == true ]]; then
        echo ""
        log_info "Dry run complete. Use without --dry-run to archive."
        exit 0
    fi

    echo ""
    echo "=== Archiving ${version} ==="
    echo ""

    generate_archived_md "$version"
    generate_knowledge_md "$version"
    update_task_status "$version"

    echo ""
    log_info "Archive complete: ${version_dir}/"
    log_info "Generated files:"
    log_info "  - ${version_dir}/ARCHIVED.md"
    log_info "  - ${version_dir}/knowledge.md"
    log_info "  - task.md status → archived"
}

main "$@"
