#!/bin/bash
# Code Review Gate - 代码审查门禁
# 对暂存的更改执行自动化代码审查，确保代码质量

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 配置
MIN_CONFIDENCE=80
MAX_CRITICAL_ISSUES=0
MAX_IMPORTANT_ISSUES=5

# 获取暂存的文件
get_staged_files() {
    git diff --cached --name-only --diff-filter=ACMR | grep -E '\.(ts|tsx|js|jsx|py|sh|md)$' || true
}

# 检查危险模式
check_dangerous_patterns() {
    local files="$1"
    local issues=0

    if [[ -z "$files" ]]; then
        return 0
    fi

    echo -e "${BLUE}🔍 Checking for dangerous patterns...${NC}"

    # 检查硬编码密钥
    if echo "$files" | xargs grep -l -E "(password|secret|api_key|token)\s*=\s*['\"][^'\"]+['\"]" 2>/dev/null; then
        echo -e "${RED}   ⚠️  Potential hardcoded secrets detected${NC}"
        ((issues++))
    fi

    # 检查 console.log (生产代码)
    local non_test_files=$(echo "$files" | grep -v -E '(test|spec|\.test\.|\.spec\.)' || true)
    if [[ -n "$non_test_files" ]] && echo "$non_test_files" | xargs grep -l 'console\.log' 2>/dev/null; then
        echo -e "${YELLOW}   ⚠️  console.log found in production code${NC}"
    fi

    # 检查 TODO/FIXME
    local todo_count=$(echo "$files" | xargs grep -c -E '(TODO|FIXME|XXX|HACK)' 2>/dev/null | awk -F: '{sum+=$2} END {print sum}')
    if [[ "$todo_count" -gt 0 ]]; then
        echo -e "${YELLOW}   ℹ️  Found $todo_count TODO/FIXME comments${NC}"
    fi

    # 检查大文件
    for file in $files; do
        if [[ -f "$file" ]]; then
            local lines=$(wc -l < "$file")
            if [[ $lines -gt 500 ]]; then
                echo -e "${YELLOW}   ⚠️  Large file: $file ($lines lines)${NC}"
            fi
        fi
    done

    return $issues
}

# 检查代码风格
check_code_style() {
    local files="$1"

    if [[ -z "$files" ]]; then
        return 0
    fi

    echo -e "${BLUE}🔍 Checking code style...${NC}"

    # TypeScript/JavaScript 文件检查
    local ts_files=$(echo "$files" | grep -E '\.(ts|tsx|js|jsx)$' || true)
    if [[ -n "$ts_files" ]]; then
        # 检查 any 类型使用
        local any_count=$(echo "$ts_files" | xargs grep -c ': any' 2>/dev/null | awk -F: '{sum+=$2} END {print sum}')
        if [[ "$any_count" -gt 0 ]]; then
            echo -e "${YELLOW}   ⚠️  Found $any_count uses of 'any' type${NC}"
        fi

        # 检查空 catch 块
        if echo "$ts_files" | xargs grep -l 'catch\s*(\s*\w*\s*)\s*{\s*}' 2>/dev/null; then
            echo -e "${YELLOW}   ⚠️  Empty catch blocks detected${NC}"
        fi
    fi

    # Shell 脚本检查
    local sh_files=$(echo "$files" | grep -E '\.sh$' || true)
    if [[ -n "$sh_files" ]]; then
        for file in $sh_files; do
            if [[ -f "$file" ]]; then
                # 检查是否有 shebang
                if ! head -1 "$file" | grep -q '^#!'; then
                    echo -e "${YELLOW}   ⚠️  Missing shebang: $file${NC}"
                fi

                # 检查是否有 set -e
                if ! grep -q 'set -e' "$file"; then
                    echo -e "${YELLOW}   ℹ️  Consider adding 'set -e': $file${NC}"
                fi
            fi
        done
    fi

    return 0
}

# 检查 Markdown 命令文件
check_command_files() {
    local files="$1"
    local issues=0

    local cmd_files=$(echo "$files" | grep -E 'commands/.*\.md$' || true)
    if [[ -z "$cmd_files" ]]; then
        return 0
    fi

    echo -e "${BLUE}🔍 Checking command files...${NC}"

    for file in $cmd_files; do
        if [[ -f "$file" ]]; then
            # 检查必需的 frontmatter 字段
            if ! grep -q '^name:' "$file"; then
                echo -e "${RED}   ❌ Missing 'name' field: $file${NC}"
                ((issues++))
            fi

            if ! grep -q '^description:' "$file"; then
                echo -e "${RED}   ❌ Missing 'description' field: $file${NC}"
                ((issues++))
            fi

            # 检查内部命令是否有 internal: true
            local filename=$(basename "$file")
            # 已知的用户命令 (与 marketplace.json 一致)
            if [[ "$filename" != "ai:dev.md" ]] && \
               [[ "$filename" != "ai:fix.md" ]] && \
               [[ "$filename" != "ai:status.md" ]] && \
               [[ "$filename" != "ai:session-save.md" ]] && \
               [[ "$filename" != "ai:session-resume.md" ]] && \
               [[ "$filename" != "ai:team.md" ]]; then
                if ! grep -q '^internal: true' "$file"; then
                    echo -e "${YELLOW}   ⚠️  Internal command missing 'internal: true': $file${NC}"
                fi
            fi
        fi
    done

    return $issues
}

# 生成审查报告
generate_report() {
    local staged_files="$1"
    local file_count=$(echo "$staged_files" | wc -w)

    echo ""
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║                    CODE REVIEW SUMMARY                      ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    printf "║  Files reviewed: %-42s ║\n" "$file_count"
    echo "╚════════════════════════════════════════════════════════════╝"
}

# 显示质量仪表盘
show_quality_dashboard() {
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    if [[ -f "$script_dir/quality-dashboard.sh" ]]; then
        bash "$script_dir/quality-dashboard.sh"
    fi
}

# 主函数
main() {
    local quick_mode=false

    # 解析参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --quick|-q)
                quick_mode=true
                shift
                ;;
            *)
                shift
                ;;
        esac
    done

    local staged_files=$(get_staged_files)

    if [[ -z "$staged_files" ]]; then
        if [[ "$quick_mode" == "false" ]]; then
            echo -e "${GREEN}✅ No reviewable files staged${NC}"
        fi
        return 0
    fi

    if [[ "$quick_mode" == "true" ]]; then
        # Quick mode: 只检查危险模式，静默输出
        check_dangerous_patterns "$staged_files" > /dev/null 2>&1
        return $?
    fi

    echo -e "${YELLOW}🔍 Running code review gate...${NC}"

    local total_issues=0

    # 执行各项检查
    check_dangerous_patterns "$staged_files" || ((total_issues+=$?))
    check_code_style "$staged_files" || true
    check_command_files "$staged_files" || ((total_issues+=$?))

    # 生成报告
    generate_report "$staged_files"

    # 判断是否通过
    if [[ $total_issues -gt $MAX_CRITICAL_ISSUES ]]; then
        echo -e "${RED}❌ Code review failed: $total_issues critical issues found${NC}"
        echo -e "${YELLOW}Please fix the issues above before committing.${NC}"
        return 1
    fi

    echo -e "${GREEN}✅ Code review passed${NC}"

    # 显示质量仪表盘
    show_quality_dashboard

    return 0
}

# 如果直接运行
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
