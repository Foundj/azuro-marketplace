#!/bin/bash

# Quality Gate - 快速质量检查脚本
# 用于 ai-dev quality-gate skill

# 不使用 set -e，让脚本能处理 grep 无结果的情况
# set -e

PROJECT_DIR="${1:-.}"
OUTPUT_FORMAT="${2:-text}"  # text | json

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 初始化分数
SECURITY_SCORE=100
CODE_QUALITY_SCORE=100
DOCUMENTATION_SCORE=100
ARCHITECTURE_SCORE=100

SECURITY_ISSUES=()
CODE_ISSUES=()
DOC_ISSUES=()
ARCH_ISSUES=()

# ============================================================================
# 安全检查 (40%)
# ============================================================================

check_security() {
    echo -e "${BLUE}[1/4] 安全检查...${NC}"
    
    # 检查硬编码密钥 (限制匹配数量以提高性能)
    local secrets=$(grep -rn -m 10 --include="*.js" --include="*.ts" --include="*.jsx" --include="*.tsx" --include="*.py" --include="*.go" --include="*.java" --include="*.rb" \
        -E "(password|secret|api_key|apikey|token|credential)\s*[:=]\s*['\"][^'\"]+['\"]" \
        "$PROJECT_DIR" 2>/dev/null | grep -v node_modules | grep -v ".min." | head -5)
    
    if [[ -n "$secrets" ]]; then
        SECURITY_ISSUES+=("发现硬编码敏感信息")
        SECURITY_SCORE=$((SECURITY_SCORE - 30))
    fi
    
    # 检查 .env 是否被忽略
    if [[ -f "$PROJECT_DIR/.env" ]] && [[ -f "$PROJECT_DIR/.gitignore" ]]; then
        if ! grep -q "^\.env$" "$PROJECT_DIR/.gitignore" 2>/dev/null; then
            SECURITY_ISSUES+=(".env 文件未在 .gitignore 中")
            SECURITY_SCORE=$((SECURITY_SCORE - 15))
        fi
    fi
    
    # 检查 SQL 注入风险 (简单检测，限制匹配数量)
    local sql_concat=$(grep -rn -m 5 --include="*.js" --include="*.ts" --include="*.py" --include="*.go" --include="*.java" --include="*.php" \
        -E "(SELECT|INSERT|UPDATE|DELETE).*\+.*\$|f['\"].*SELECT" \
        "$PROJECT_DIR" 2>/dev/null | grep -v node_modules | head -3)
    
    if [[ -n "$sql_concat" ]]; then
        SECURITY_ISSUES+=("可能存在 SQL 注入风险")
        SECURITY_SCORE=$((SECURITY_SCORE - 20))
    fi
    
    # 确保分数不低于 0
    [[ $SECURITY_SCORE -lt 0 ]] && SECURITY_SCORE=0
}

# ============================================================================
# 代码质量检查 (30%)
# ============================================================================

check_code_quality() {
    echo -e "${BLUE}[2/4] 代码质量检查...${NC}"
    
    # 检查 TODO/FIXME (限制匹配数量)
    local todos=$(grep -rn -m 20 --include="*.js" --include="*.ts" --include="*.jsx" --include="*.tsx" --include="*.py" --include="*.go" --include="*.java" --include="*.rb" \
        -E "(TODO|FIXME|XXX|HACK):" "$PROJECT_DIR" 2>/dev/null | \
        grep -v node_modules | wc -l | tr -d ' ')
    
    if [[ $todos -gt 5 ]]; then
        CODE_ISSUES+=("存在 $todos 个 TODO/FIXME 待处理")
        CODE_QUALITY_SCORE=$((CODE_QUALITY_SCORE - 10))
    fi
    
    # 检查超长文件 (> 500 行)
    local long_files=$(find "$PROJECT_DIR" \( -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.go" \) \
        -not -path "*/node_modules/*" -not -name "*.min.*" \
        -exec wc -l {} \; 2>/dev/null | awk '$1 > 500 {print}' | wc -l | tr -d ' ')
    
    if [[ $long_files -gt 0 ]]; then
        CODE_ISSUES+=("$long_files 个文件超过 500 行")
        CODE_QUALITY_SCORE=$((CODE_QUALITY_SCORE - 15))
    fi
    
    # 检查 console.log / print 调试语句 (限制匹配数量)
    local debug_logs=$(grep -rn -m 20 --include="*.js" --include="*.ts" --include="*.jsx" --include="*.tsx" \
        "console\.log" "$PROJECT_DIR" 2>/dev/null | \
        grep -v node_modules | wc -l | tr -d ' ')
    
    if [[ $debug_logs -gt 10 ]]; then
        CODE_ISSUES+=("存在 $debug_logs 个 console.log 调试语句")
        CODE_QUALITY_SCORE=$((CODE_QUALITY_SCORE - 10))
    fi
    
    [[ $CODE_QUALITY_SCORE -lt 0 ]] && CODE_QUALITY_SCORE=0
}

# ============================================================================
# 文档检查 (20%)
# ============================================================================

check_documentation() {
    echo -e "${BLUE}[3/4] 文档检查...${NC}"
    
    # 检查 README 存在
    if [[ ! -f "$PROJECT_DIR/README.md" ]] && [[ ! -f "$PROJECT_DIR/readme.md" ]]; then
        DOC_ISSUES+=("缺少 README.md")
        DOCUMENTATION_SCORE=$((DOCUMENTATION_SCORE - 30))
    fi
    
    # 检查 package.json 描述 (Node.js 项目)
    if [[ -f "$PROJECT_DIR/package.json" ]]; then
        local has_desc=$(grep -c '"description"' "$PROJECT_DIR/package.json" 2>/dev/null || echo "0")
        if [[ $has_desc -eq 0 ]]; then
            DOC_ISSUES+=("package.json 缺少 description")
            DOCUMENTATION_SCORE=$((DOCUMENTATION_SCORE - 10))
        fi
    fi
    
    # 检查主要源文件是否有注释
    local source_files=$(find "$PROJECT_DIR" \( -name "*.js" -o -name "*.ts" -o -name "*.py" \) \
        -not -path "*/node_modules/*" -not -name "*.test.*" \
        -not -name "*.spec.*" 2>/dev/null | head -10)
    
    local files_without_comments=0
    for file in $source_files; do
        local comment_lines=$(grep -c "^[[:space:]]*//" "$file" 2>/dev/null | tr -d '\n' || echo "0")
        # 确保是有效数字
        [[ ! "$comment_lines" =~ ^[0-9]+$ ]] && comment_lines=0
        if [[ $comment_lines -lt 3 ]]; then
            files_without_comments=$((files_without_comments + 1))
        fi
    done
    
    if [[ $files_without_comments -gt 3 ]]; then
        DOC_ISSUES+=("$files_without_comments 个文件缺少注释")
        DOCUMENTATION_SCORE=$((DOCUMENTATION_SCORE - 20))
    fi
    
    [[ $DOCUMENTATION_SCORE -lt 0 ]] && DOCUMENTATION_SCORE=0
}

# ============================================================================
# 架构检查 (10%)
# ============================================================================

check_architecture() {
    echo -e "${BLUE}[4/4] 架构检查...${NC}"
    
    # 检查目录结构
    local has_src=$(test -d "$PROJECT_DIR/src" && echo "1" || echo "0")
    local has_lib=$(test -d "$PROJECT_DIR/lib" && echo "1" || echo "0")
    local has_tests="0"
    if [[ -d "$PROJECT_DIR/tests" ]] || [[ -d "$PROJECT_DIR/__tests__" ]] || [[ -d "$PROJECT_DIR/test" ]]; then
        has_tests="1"
    fi
    
    if [[ "$has_src" == "0" ]] && [[ "$has_lib" == "0" ]]; then
        ARCH_ISSUES+=("缺少标准目录结构 (src/ 或 lib/)")
        ARCHITECTURE_SCORE=$((ARCHITECTURE_SCORE - 20))
    fi
    
    if [[ "$has_tests" == "0" ]]; then
        ARCH_ISSUES+=("缺少测试目录")
        ARCHITECTURE_SCORE=$((ARCHITECTURE_SCORE - 15))
    fi
    
    # 检查配置分离 (限制匹配数量)
    local config_in_code=$(grep -rn -m 5 --include="*.js" --include="*.ts" --include="*.py" \
        -E "^(const|let|var)\s+\w*(config|Config|CONFIG)\w*\s*=\s*\{" \
        "$PROJECT_DIR" 2>/dev/null | grep -v node_modules | grep -v "\.config\." | head -3)
    
    if [[ -n "$config_in_code" ]]; then
        ARCH_ISSUES+=("配置可能未分离到独立文件")
        ARCHITECTURE_SCORE=$((ARCHITECTURE_SCORE - 10))
    fi
    
    [[ $ARCHITECTURE_SCORE -lt 0 ]] && ARCHITECTURE_SCORE=0
}

# ============================================================================
# 计算总分并输出
# ============================================================================

calculate_and_report() {
    # 加权计算
    local weighted_security=$((SECURITY_SCORE * 40 / 100))
    local weighted_code=$((CODE_QUALITY_SCORE * 30 / 100))
    local weighted_doc=$((DOCUMENTATION_SCORE * 20 / 100))
    local weighted_arch=$((ARCHITECTURE_SCORE * 10 / 100))
    
    local total_score=$((weighted_security + weighted_code + weighted_doc + weighted_arch))
    
    # 判断状态
    local status="PASSED"
    local status_icon="✅"
    
    if [[ $total_score -lt 70 ]]; then
        status="FAILED"
        status_icon="❌"
    elif [[ $SECURITY_SCORE -lt 85 ]]; then
        status="FAILED"
        status_icon="🚨"
    fi
    
    if [[ "$OUTPUT_FORMAT" == "json" ]]; then
        # 处理空数组
        local sec_issues="[]"
        local code_issues="[]"
        local doc_issues="[]"
        local arch_issues="[]"
        
        if [[ ${#SECURITY_ISSUES[@]} -gt 0 ]]; then
            sec_issues=$(printf '%s\n' "${SECURITY_ISSUES[@]}" | jq -R . | jq -s .)
        fi
        if [[ ${#CODE_ISSUES[@]} -gt 0 ]]; then
            code_issues=$(printf '%s\n' "${CODE_ISSUES[@]}" | jq -R . | jq -s .)
        fi
        if [[ ${#DOC_ISSUES[@]} -gt 0 ]]; then
            doc_issues=$(printf '%s\n' "${DOC_ISSUES[@]}" | jq -R . | jq -s .)
        fi
        if [[ ${#ARCH_ISSUES[@]} -gt 0 ]]; then
            arch_issues=$(printf '%s\n' "${ARCH_ISSUES[@]}" | jq -R . | jq -s .)
        fi
        
        cat <<EOF
{
  "total_score": $total_score,
  "status": "$status",
  "dimensions": {
    "security": {"score": $SECURITY_SCORE, "weight": 40, "weighted": $weighted_security},
    "code_quality": {"score": $CODE_QUALITY_SCORE, "weight": 30, "weighted": $weighted_code},
    "documentation": {"score": $DOCUMENTATION_SCORE, "weight": 20, "weighted": $weighted_doc},
    "architecture": {"score": $ARCHITECTURE_SCORE, "weight": 10, "weighted": $weighted_arch}
  },
  "issues": {
    "security": $sec_issues,
    "code_quality": $code_issues,
    "documentation": $doc_issues,
    "architecture": $arch_issues
  }
}
EOF
    else
        echo ""
        echo "╔════════════════════════════════════════════════════════════╗"
        echo "║                    QUALITY GATE REPORT                     ║"
        echo "╠════════════════════════════════════════════════════════════╣"
        printf "║  %-16s │ %6s │ %6s │ %8s │ %-8s ║\n" "Dimension" "Score" "Weight" "Weighted" "Status"
        echo "╠═══════════════════╪════════╪════════╪══════════╪══════════╣"
        
        local sec_status=$([[ $SECURITY_SCORE -ge 85 ]] && echo "✅ PASS" || echo "❌ FAIL")
        local code_status=$([[ $CODE_QUALITY_SCORE -ge 60 ]] && echo "✅ PASS" || echo "⚠️ WARN")
        local doc_status=$([[ $DOCUMENTATION_SCORE -ge 50 ]] && echo "✅ PASS" || echo "⚠️ WARN")
        local arch_status=$([[ $ARCHITECTURE_SCORE -ge 50 ]] && echo "✅ PASS" || echo "⚠️ WARN")
        
        printf "║  🔒 %-13s │ %3d/100│   %2d%%  │   %5.1f  │ %-8s ║\n" "Security" $SECURITY_SCORE 40 $weighted_security "$sec_status"
        printf "║  📝 %-13s │ %3d/100│   %2d%%  │   %5.1f  │ %-8s ║\n" "Code Quality" $CODE_QUALITY_SCORE 30 $weighted_code "$code_status"
        printf "║  📖 %-13s │ %3d/100│   %2d%%  │   %5.1f  │ %-8s ║\n" "Documentation" $DOCUMENTATION_SCORE 20 $weighted_doc "$doc_status"
        printf "║  🏗️ %-13s │ %3d/100│   %2d%%  │   %5.1f  │ %-8s ║\n" "Architecture" $ARCHITECTURE_SCORE 10 $weighted_arch "$arch_status"
        
        echo "╠═══════════════════╧════════╧════════╧══════════╧══════════╣"
        printf "║  TOTAL SCORE: %d/100                                       ║\n" $total_score
        printf "║  STATUS: %s %-47s ║\n" "$status_icon" "$status"
        echo "╚════════════════════════════════════════════════════════════╝"
        
        # 显示问题详情
        if [[ ${#SECURITY_ISSUES[@]} -gt 0 ]] || [[ ${#CODE_ISSUES[@]} -gt 0 ]] || \
           [[ ${#DOC_ISSUES[@]} -gt 0 ]] || [[ ${#ARCH_ISSUES[@]} -gt 0 ]]; then
            echo ""
            echo "Issues Found:"
            
            for issue in "${SECURITY_ISSUES[@]}"; do
                echo "  🔒 [Security] $issue"
            done
            for issue in "${CODE_ISSUES[@]}"; do
                echo "  📝 [Code] $issue"
            done
            for issue in "${DOC_ISSUES[@]}"; do
                echo "  📖 [Doc] $issue"
            done
            for issue in "${ARCH_ISSUES[@]}"; do
                echo "  🏗️ [Arch] $issue"
            done
        fi
    fi
    
    # 返回状态码
    [[ "$status" == "PASSED" ]] && exit 0 || exit 1
}

# ============================================================================
# 主流程
# ============================================================================

main() {
    echo "═══════════════════════════════════════════════════════════════"
    echo "  Quality Gate Check - $(basename "$PROJECT_DIR")"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
    
    check_security
    check_code_quality
    check_documentation
    check_architecture
    
    calculate_and_report
}

main
