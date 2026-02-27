#!/bin/bash
#
# team-health-check.sh - Agent Teams 健康检查脚本
#
# 用途: 检查活跃团队、任务状态、清理孤立资源
# 用法: bash scripts/team-health-check.sh [--cleanup]
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

# 参数
CLEANUP=false
if [[ "$1" == "--cleanup" ]]; then
    CLEANUP=true
fi

echo ""
echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║           Agent Teams 健康检查                           ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
echo ""

# ============================================================================
# 检查活跃团队
# ============================================================================
check_active_teams() {
    echo -e "${YELLOW}📊 活跃团队检查${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ -d "$TEAMS_DIR" ]; then
        local team_count=$(find "$TEAMS_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')

        if [ "$team_count" -eq 0 ]; then
            echo -e "  ${GREEN}✓${NC} 无活跃团队"
        else
            echo -e "  活跃团队数: ${BLUE}$team_count${NC}"
            echo ""

            for team in "$TEAMS_DIR"/*; do
                if [ -d "$team" ]; then
                    local team_name=$(basename "$team")
                    local config="$team/config.json"

                    if [ -f "$config" ]; then
                        local member_count=$(jq '.members | length' "$config" 2>/dev/null || echo "0")
                        local created=$(jq -r '.createdAt // "unknown"' "$config" 2>/dev/null || echo "unknown")

                        echo -e "  ${BLUE}└─${NC} $team_name"
                        echo -e "     ${GREEN}✓${NC} 队友: $member_count 人"
                        echo -e "     ${GREEN}✓${NC} 创建时间: $created"
                    else
                        echo -e "  ${RED}✗${NC} $team_name (无配置文件)"
                    fi
                fi
            done
        fi
    else
        echo -e "  ${GREEN}✓${NC} 无活跃团队 (目录不存在)"
    fi

    echo ""
}

# ============================================================================
# 检查任务状态
# ============================================================================
check_tasks() {
    echo -e "${YELLOW}📋 任务状态检查${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if [ -d "$TASKS_DIR" ]; then
        local task_dirs=$(find "$TASKS_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)

        if [ -z "$task_dirs" ]; then
            echo -e "  ${GREEN}✓${NC} 无任务"
        else
            for task_dir in $task_dirs; do
                local team_name=$(basename "$task_dir")
                local task_count=$(find "$task_dir" -name "*.json" 2>/dev/null | wc -l | tr -d ' ')

                if [ "$task_count" -gt 0 ]; then
                    local completed=$(find "$task_dir" -name "*.json" -exec jq -r 'select(.status == "completed") | .id' {} \; 2>/dev/null | wc -l | tr -d ' ')
                    local in_progress=$(find "$task_dir" -name "*.json" -exec jq -r 'select(.status == "in_progress") | .id' {} \; 2>/dev/null | wc -l | tr -d ' ')
                    local pending=$(find "$task_dir" -name "*.json" -exec jq -r 'select(.status == "pending") | .id' {} \; 2>/dev/null | wc -l | tr -d ' ')

                    echo -e "  ${BLUE}└─${NC} $team_name"
                    echo -e "     总计: $task_count | ${GREEN}完成: $completed${NC} | ${YELLOW}进行中: $in_progress${NC} | ${BLUE}待处理: $pending${NC}"
                fi
            done
        fi
    else
        echo -e "  ${GREEN}✓${NC} 无任务 (目录不存在)"
    fi

    echo ""
}

# ============================================================================
# 检查孤立资源
# ============================================================================
check_orphaned() {
    echo -e "${YELLOW}🧹 孤立资源检查${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local orphaned_found=false

    # 检查无配置的团队目录
    if [ -d "$TEAMS_DIR" ]; then
        for team in "$TEAMS_DIR"/*; do
            if [ -d "$team" ] && [ ! -f "$team/config.json" ]; then
                orphaned_found=true
                local team_name=$(basename "$team")
                echo -e "  ${RED}✗${NC} 孤立团队目录: $team_name"

                if [ "$CLEANUP" = true ]; then
                    rm -rf "$team"
                    echo -e "     ${GREEN}✓${NC} 已清理"
                fi
            fi
        done
    fi

    # 检查无团队的任务目录
    if [ -d "$TASKS_DIR" ]; then
        for task_dir in "$TASKS_DIR"/*; do
            if [ -d "$task_dir" ]; then
                local team_name=$(basename "$task_dir")
                if [ ! -d "$TEAMS_DIR/$team_name" ]; then
                    orphaned_found=true
                    echo -e "  ${RED}✗${NC} 孤立任务目录: $team_name"

                    if [ "$CLEANUP" = true ]; then
                        rm -rf "$task_dir"
                        echo -e "     ${GREEN}✓${NC} 已清理"
                    fi
                fi
            fi
        done
    fi

    if [ "$orphaned_found" = false ]; then
        echo -e "  ${GREEN}✓${NC} 无孤立资源"
    fi

    echo ""
}

# ============================================================================
# 健康评分
# ============================================================================
calculate_health() {
    echo -e "${YELLOW}💚 健康评分${NC}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    local score=100
    local issues=""

    # 检查团队数量
    if [ -d "$TEAMS_DIR" ]; then
        local team_count=$(find "$TEAMS_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
        if [ "$team_count" -gt 5 ]; then
            score=$((score - 10))
            issues="$issues\n  - 活跃团队过多 ($team_count > 5)"
        fi
    fi

    # 检查孤立资源
    local orphaned_count=0
    if [ -d "$TEAMS_DIR" ]; then
        orphaned_count=$(find "$TEAMS_DIR" -mindepth 1 -maxdepth 1 -type d ! -exec test -f '{}/config.json' \; -print 2>/dev/null | wc -l | tr -d ' ')
    fi
    if [ "$orphaned_count" -gt 0 ]; then
        score=$((score - orphaned_count * 10))
        issues="$issues\n  - 孤立资源: $orphaned_count"
    fi

    # 检查被阻塞的任务
    if [ -d "$TASKS_DIR" ]; then
        local blocked=$(find "$TASKS_DIR" -name "*.json" -exec jq -r 'select(.blockedBy | length > 0) | .id' {} \; 2>/dev/null | wc -l | tr -d ' ')
        if [ "$blocked" -gt 0 ]; then
            score=$((score - 5))
            issues="$issues\n  - 被阻塞任务: $blocked"
        fi
    fi

    # 显示评分
    if [ "$score" -ge 90 ]; then
        echo -e "  ${GREEN}●${NC} 健康评分: ${GREEN}$score/100${NC}"
    elif [ "$score" -ge 70 ]; then
        echo -e "  ${YELLOW}●${NC} 健康评分: ${YELLOW}$score/100${NC}"
    else
        echo -e "  ${RED}●${NC} 健康评分: ${RED}$score/100${NC}"
    fi

    if [ -n "$issues" ]; then
        echo ""
        echo -e "  ${YELLOW}问题:${NC}$issues"
    fi

    echo ""
}

# ============================================================================
# 主函数
# ============================================================================
main() {
    check_active_teams
    check_tasks
    check_orphaned
    calculate_health

    echo -e "${BLUE}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║           ✅ 健康检查完成                                ║${NC}"

    if [ "$CLEANUP" = true ]; then
        echo -e "${BLUE}║           🧹 已清理孤立资源                             ║${NC}"
    else
        echo -e "${BLUE}║           💡 使用 --cleanup 清理孤立资源                ║${NC}"
    fi

    echo -e "${BLUE}╚════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

main "$@"