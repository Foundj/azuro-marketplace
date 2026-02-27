#!/bin/bash
# quality-dashboard.sh - 技能质量仪表盘
# 在 git commit 门禁中显示项目健康状态摘要

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# 获取脚本所在目录
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# 统计技能
count_skills() {
    local ga_count=0
    local experimental_count=0
    local total_count=0

    for skill_dir in "$PROJECT_ROOT/skills"/*/; do
        if [[ -f "$skill_dir/SKILL.md" ]]; then
            total_count=$((total_count + 1))
            if grep -q "^status: ga" "$skill_dir/SKILL.md" 2>/dev/null; then
                ga_count=$((ga_count + 1))
            else
                experimental_count=$((experimental_count + 1))
            fi
        fi
    done

    echo "$ga_count:$experimental_count:$total_count"
}

# 计算平均质量分数
calculate_avg_score() {
    local total_score=0
    local count=0

    for skill_dir in "$PROJECT_ROOT/skills"/*/; do
        if [[ -f "$skill_dir/SKILL.md" ]]; then
            # 简化评分：基于文档长度和结构
            local word_count
            word_count=$(wc -w < "$skill_dir/SKILL.md" 2>/dev/null | tr -d '[:space:]')
            word_count=${word_count:-0}

            local has_version=0
            grep -q "^version:" "$skill_dir/SKILL.md" 2>/dev/null && has_version=1

            local has_triggers=0
            grep -q "^triggers:" "$skill_dir/SKILL.md" 2>/dev/null && has_triggers=1

            # 基础分 60
            local score=60

            # 文档完整性 (+20)
            if [[ "$word_count" -gt 300 ]]; then
                score=$((score + 10))
            fi
            if [[ "$word_count" -gt 500 ]]; then
                score=$((score + 10))
            fi

            # 版本字段 (+10)
            if [[ "$has_version" -eq 1 ]]; then
                score=$((score + 10))
            fi

            # 触发词 (+10)
            if [[ "$has_triggers" -eq 1 ]]; then
                score=$((score + 10))
            fi

            total_score=$((total_score + score))
            count=$((count + 1))
        fi
    done

    if [[ $count -gt 0 ]]; then
        echo $((total_score / count))
    else
        echo 0
    fi
}

# 统计命令
count_commands() {
    local user_commands=0
    local internal_commands=0
    local total_commands=0

    for cmd_file in "$PROJECT_ROOT/commands"/*.md; do
        if [[ -f "$cmd_file" ]]; then
            total_commands=$((total_commands + 1))
            if grep -q "^internal: true" "$cmd_file" 2>/dev/null; then
                internal_commands=$((internal_commands + 1))
            else
                user_commands=$((user_commands + 1))
            fi
        fi
    done

    echo "$user_commands:$internal_commands:$total_commands"
}

# 统计 agents
count_agents() {
    local count=0
    for agent_file in "$PROJECT_ROOT/agents"/*.md; do
        if [[ -f "$agent_file" ]]; then
            count=$((count + 1))
        fi
    done
    echo $count
}

# 主函数
main() {
    local skills_data
    skills_data=$(count_skills)

    local ga_count
    ga_count=$(echo "$skills_data" | cut -d: -f1)

    local exp_count
    exp_count=$(echo "$skills_data" | cut -d: -f2)

    local total_skills
    total_skills=$(echo "$skills_data" | cut -d: -f3)

    local ga_pct=0
    if [[ $total_skills -gt 0 ]]; then
        ga_pct=$((ga_count * 100 / total_skills))
    fi

    local avg_score
    avg_score=$(calculate_avg_score)

    local cmd_data
    cmd_data=$(count_commands)

    local user_cmds
    user_cmds=$(echo "$cmd_data" | cut -d: -f1)

    local internal_cmds
    internal_cmds=$(echo "$cmd_data" | cut -d: -f2)

    local agent_count
    agent_count=$(count_agents)

    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║               SKILL QUALITY DASHBOARD                       ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    printf "║  ${CYAN}GA Skills:${NC}           %-35s ║\n" "$ga_count ($ga_pct%)"
    printf "║  ${YELLOW}Experimental Skills:${NC} %-31s ║\n" "$exp_count"
    printf "║  ${GREEN}Total Skills:${NC}         %-35s ║\n" "$total_skills"
    echo "╠════════════════════════════════════════════════════════════╣"
    printf "║  ${BLUE}Avg Quality Score:${NC}    %-35s ║\n" "$avg_score/100"
    printf "║  User Commands:        %-35s ║\n" "$user_cmds"
    printf "║  Internal Commands:    %-35s ║\n" "$internal_cmds"
    printf "║  Agents:               %-35s ║\n" "$agent_count"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
}

# 如果直接运行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main
fi