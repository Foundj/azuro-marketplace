#!/bin/bash
#
# check-dependencies.sh - 检查 ai-dev 的外部依赖
#
# 用法: ./check-dependencies.sh
#
# 检查项目:
#   - 外部 skills 是否存在
#   - 必要命令是否可用
#   - 模板文件是否完整
#

# 不使用 set -e，因为某些检查预期会失败

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 基础路径
SKILLS_DIR="${HOME}/.claude/skills"
AI_ORCH_DIR="${SKILLS_DIR}/ai-dev"

# 计数器
PASSED=0
FAILED=0
WARNED=0

# 打印函数
print_check() {
    echo -n "检查 $1... "
}

print_pass() {
    echo -e "${GREEN}✓ 通过${NC}"
    ((PASSED++))
}

print_fail() {
    echo -e "${RED}✗ 失败${NC}: $1"
    ((FAILED++))
}

print_warn() {
    echo -e "${YELLOW}⚠ 警告${NC}: $1"
    ((WARNED++))
}

echo "=========================================="
echo "  AI-Dev v3.0 依赖检查"
echo "=========================================="
echo ""

# ========== 1. 外部 Skills 检查 ==========
echo "📦 外部 Skills"
echo "-------------------------------------------"

# competitor-research
print_check "competitor-research skill"
if [ -f "${SKILLS_DIR}/competitor-research/SKILL.md" ]; then
    print_pass
else
    print_fail "未找到 competitor-research/SKILL.md"
fi

# project-initializer
print_check "project-initializer skill"
if [ -f "${SKILLS_DIR}/project-initializer/SKILL.md" ]; then
    print_pass
else
    print_fail "未找到 project-initializer/SKILL.md"
fi

# session-manager
print_check "session-manager skill"
if [ -f "${SKILLS_DIR}/session-manager/SKILL.md" ]; then
    print_pass
else
    print_fail "未找到 session-manager/SKILL.md"
fi

echo ""

# ========== 2. 命令可用性检查 ==========
echo "🔧 命令可用性"
echo "-------------------------------------------"

# MCP 检查 (可选增强)
print_check "MCP Context7"
echo -e "    ${YELLOW}可选${NC} (增强文档查询)"

print_check "MCP Tavily"
echo -e "    ${YELLOW}可选${NC} (增强深度研究)"

# jq (推荐)
print_check "jq 命令"
if command -v jq &> /dev/null; then
    print_pass
else
    print_warn "未安装 (建议安装以处理 JSON)"
fi

# git (必须)
print_check "git 命令"
if command -v git &> /dev/null; then
    print_pass
else
    print_fail "未安装 git"
fi

echo ""

# ========== 3. 内部文件检查 ==========
echo "📄 内部文件"
echo "-------------------------------------------"

# SKILL.md
print_check "SKILL.md"
if [ -f "${AI_ORCH_DIR}/SKILL.md" ]; then
    print_pass
else
    print_fail "未找到 SKILL.md"
fi

# 核心脚本
SCRIPTS=("scan-project.sh" "query-knowledge.sh" "init-version.sh" "archive-version.sh")
for script in "${SCRIPTS[@]}"; do
    print_check "scripts/${script}"
    if [ -x "${AI_ORCH_DIR}/scripts/${script}" ]; then
        print_pass
    else
        print_fail "未找到或不可执行"
    fi
done

# Hook 脚本
print_check "hooks/ooda-stop-hook.sh"
if [ -x "${AI_ORCH_DIR}/hooks/ooda-stop-hook.sh" ]; then
    print_pass
else
    print_fail "未找到或不可执行"
fi

echo ""

# ========== 4. 模板文件检查 ==========
echo "📁 .agent 工具层模板 (保留层)"
echo "-------------------------------------------"

TEMPLATES=(
    "config.json"
    "requirements.md"
    "design.md"
    "CLAUDE.md"
    "constraints.md"
)

for template in "${TEMPLATES[@]}"; do
    print_check "templates/agent-dir/${template}"
    if [ -f "${AI_ORCH_DIR}/templates/agent-dir/${template}" ]; then
        print_pass
    else
        print_fail "未找到"
    fi
done

# 子目录 (工具层保留 knowledge, 任务管理已迁移到 docs/tasks/)
SUBDIRS=("knowledge" "research")
for subdir in "${SUBDIRS[@]}"; do
    print_check "templates/agent-dir/${subdir}/"
    if [ -d "${AI_ORCH_DIR}/templates/agent-dir/${subdir}" ]; then
        print_pass
    else
        print_fail "目录不存在"
    fi
done

echo ""

# ========== 5. Agent 文件检查 ==========
echo "🤖 Agent 文件"
echo "-------------------------------------------"

AGENTS=(
    "requirement-interviewer.md"
    "requirement-analyzer.md"
    "code-explorer.md"
    "code-architect.md"
    "task-decomposer.md"
    "research-coordinator.md"
    "learning-coordinator.md"
    "verification-agent.md"
    "quick-fixer.md"
    "debugger.md"
    "api-helper.md"
    "test-automator.md"
    "quality/code-reviewer.md"
    "quality/confidence-scorer.md"
)

for agent in "${AGENTS[@]}"; do
    print_check "agents/${agent}"
    if [ -f "${AI_ORCH_DIR}/agents/${agent}" ]; then
        print_pass
    else
        print_fail "未找到"
    fi
done

echo ""

# ========== 汇总 ==========
echo "=========================================="
echo "  检查结果汇总"
echo "=========================================="
echo ""
echo -e "  ${GREEN}✓ 通过${NC}: ${PASSED}"
echo -e "  ${YELLOW}⚠ 警告${NC}: ${WARNED}"
echo -e "  ${RED}✗ 失败${NC}: ${FAILED}"
echo ""

if [ $FAILED -eq 0 ]; then
    if [ $WARNED -eq 0 ]; then
        echo -e "${GREEN}🎉 所有依赖检查通过！${NC}"
        exit 0
    else
        echo -e "${YELLOW}⚠️ 有警告项，但核心功能可用${NC}"
        exit 0
    fi
else
    echo -e "${RED}❌ 有 ${FAILED} 个依赖缺失，请修复后再使用${NC}"
    exit 1
fi
