#!/bin/bash
# Pre-Commit Check - Git Commit 前的代码审查
# 在 Bash 工具执行 git commit 前触发完整代码审查

set -e

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 获取即将执行的命令 (通过环境变量或参数)
BASH_COMMAND="${TOOL_INPUT_command:-$1}"

# 只在 git commit 命令时触发
if [[ "$BASH_COMMAND" =~ git[[:space:]]+commit ]]; then
    echo -e "${YELLOW}🔍 Pre-commit code review triggered...${NC}"

    # 获取脚本所在目录
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

    # 运行完整的代码审查
    if ! bash "$SCRIPT_DIR/code-review-gate.sh"; then
        echo -e "${RED}❌ Pre-commit review failed. Please fix issues before committing.${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Pre-commit review passed${NC}"
fi

# 允许命令继续执行
exit 0
