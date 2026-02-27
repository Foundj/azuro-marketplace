#!/bin/bash
#
# team-recovery.sh - Agent Teams 状态恢复脚本
#
# 用途: 检查团队配置和任务状态，提供恢复建议
# 用法: bash scripts/team-recovery.sh <team-name>
#

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 目录
TEAMS_DIR="$HOME/.claude/teams"
TASKS_DIR="$HOME/.claude/tasks"

# 参数检查
TEAM_NAME="$1"

if [ -z "$TEAM_NAME" ]; then
    echo ""
    echo -e "${RED}用法: team-recovery.sh <team-name>${NC}"
    echo ""
    echo "可用团队:"
    if [ -d "$TEAMS_DIR" ]; then
        for team in "$TEAMS_DIR"/*; do
            if [ -d "$team" ]; then
                echo -e "  - $(basename "$team")"
            fi
        done
    else
        echo "  (无活跃团队)"
    fi
    echo ""
    exit 1
fi

TEAM_DIR="$TEAMS_DIR/$TEAM_NAME"
TEAM_TASKS_DIR="$TASKS_DIR/$TEAM_NAME"

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║         Agent Teams 状态恢复: $TEAM_NAME${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
# 检查团队配置
# ============================================================================
check_team_config() {
    echo -e "${YELLOW}📁 团队配置检查${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ -f "$TEAM_DIR/config.json" ]; then
        echo -e "  ${GREEN}✓${NC} 团队配置存在"
        echo ""

        # 显示配置信息
        local agent_type=$(jq -r '.agentType // "unknown"' "$TEAM_DIR/config.json" 2>/dev/null || echo "unknown")
        local created=$(jq -r '.createdAt // "unknown"' "$TEAM_DIR/config.json" 2>/dev/null || echo "unknown")
        local description=$(jq -r '.description // "无描述"' "$TEAM_DIR/config.json" 2>/dev/null || echo "无描述")

        echo -e "  ${BLUE}Agent 类型:${NC} $agent_type"
        echo -e "  ${BLUE}创建时间:${NC} $created"
        echo -e "  ${BLUE}描述:${NC} $description"
        echo ""

        # 显示成员
        local members=$(jq -r '.members[] | "  - \(.name) (\(.agentType))"' "$TEAM_DIR/config.json" 2>/dev/null || echo "  (无成员)")
        echo -e "  ${BLUE}成员列表:${NC}"
        echo "$members"
    else
        echo -e "  ${RED}✗${NC} 团队配置缺失"
        echo ""
        return 1
    fi

    echo ""
}

# ============================================================================
# 检查任务状态
# ============================================================================
check_tasks() {
    echo -e "${YELLOW}📋 任务状态检查${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ -d "$TEAM_TASKS_DIR" ]; then
        local task_files=$(find "$TEAM_TASKS_DIR" -name "*.json" 2>/dev/null | sort)

        if [ -z "$task_files" ]; then
            echo -e "  ${YELLOW}!${NC} 无任务文件"
        else
            for task_file in $task_files; do
                local task_id=$(basename "$task_file" .json)
                local status=$(jq -r '.status // "unknown"' "$task_file" 2>/dev/null || echo "unknown")
                local owner=$(jq -r '.owner // "unassigned"' "$task_file" 2>/dev/null || echo "unassigned")
                local subject=$(jq -r '.subject // "无标题"' "$task_file" 2>/dev/null || echo "无标题")
                local blocked_by=$(jq -r '.blockedBy | join(", ") // "-"' "$task_file" 2>/dev/null || echo "-")

                # 状态颜色
                local status_color
                case "$status" in
                    completed) status_color="${GREEN}" ;;
                    in_progress) status_color="${YELLOW}" ;;
                    pending) status_color="${BLUE}" ;;
                    *) status_color="${RED}" ;;
                esac

                echo -e "  ${status_color}●${NC} Task $task_id: ${status_color}$status${NC}"
                echo -e "     标题: $subject"
                echo -e "     负责人: $owner"
                echo -e "     依赖: $blocked_by"
                echo ""
            done
        fi
    else
        echo -e "  ${RED}✗${NC} 任务目录缺失"
    fi

    echo ""
}

# ============================================================================
# 诊断问题
# ============================================================================
diagnose_issues() {
    echo -e "${YELLOW}🔍 问题诊断${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local issues=()

    # 检查配置
    if [ ! -f "$TEAM_DIR/config.json" ]; then
        issues+=("团队配置文件缺失")
    fi

    # 检查任务
    if [ -d "$TEAM_TASKS_DIR" ]; then
        # 检查卡住的任务 (in_progress 超过 1 小时)
        local stale_tasks=$(find "$TEAM_TASKS_DIR" -name "*.json" -exec jq -r 'select(.status == "in_progress") | .id' {} \; 2>/dev/null || echo "")
        if [ -n "$stale_tasks" ]; then
            issues+=("有任务长时间处于 in_progress 状态")
        fi

        # 检查被阻塞的任务
        local blocked=$(find "$TEAM_TASKS_DIR" -name "*.json" -exec jq -r 'select(.blockedBy | length > 0) | .id' {} \; 2>/dev/null | wc -l | tr -d ' ')
        if [ "$blocked" -gt 0 ]; then
            issues+=("有 $blocked 个任务被阻塞")
        fi
    fi

    # 检查孤立成员
    if [ -f "$TEAM_DIR/config.json" ]; then
        local member_count=$(jq '.members | length' "$TEAM_DIR/config.json" 2>/dev/null || echo "0")
        if [ "$member_count" -eq 0 ]; then
            issues+=("团队没有成员")
        fi
    fi

    # 显示问题
    if [ ${#issues[@]} -eq 0 ]; then
        echo -e "  ${GREEN}✓${NC} 未发现明显问题"
    else
        for issue in "${issues[@]}"; do
            echo -e "  ${RED}✗${NC} $issue"
        done
    fi

    echo ""
}

# ============================================================================
# 恢复建议
# ============================================================================
recovery_suggestions() {
    echo -e "${YELLOW}💡 恢复建议${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    echo "  1. 唤醒队友:"
    echo "     SendMessage({ type: \"message\", recipient: \"<teammate>\", content: \"请更新进度\" })"
    echo ""
    echo "  2. 解除阻塞任务:"
    echo "     TaskUpdate({ taskId: \"<id>\", addBlockedBy: [] })"
    echo ""
    echo "  3. 重新分配任务:"
    echo "     TaskUpdate({ taskId: \"<id>\", owner: \"<teammate>\" })"
    echo ""
    echo "  4. 重建团队 (最后手段):"
    echo "     TeamDelete() → 重新创建团队"
    echo ""

    echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║           ✅ 恢复检查完成                                ║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# ============================================================================
# 主函数
# ============================================================================
main() {
    check_team_config
    check_tasks
    diagnose_issues
    recovery_suggestions
}

main "$@"