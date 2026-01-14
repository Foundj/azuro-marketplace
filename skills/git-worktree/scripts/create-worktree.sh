#!/bin/bash
# create-worktree.sh - 创建 Git Worktree 用于隔离开发
# Usage: ./create-worktree.sh <branch-name> [base-branch]

set -e

BRANCH_NAME="${1:-}"
BASE_BRANCH="${2:-HEAD}"
WORKTREE_DIR="${WORKTREE_ROOT:-.worktrees}"

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# 参数检查
if [[ -z "$BRANCH_NAME" ]]; then
    log_error "Usage: $0 <branch-name> [base-branch]"
    echo "  branch-name: 新分支名称 (如 feature/auth)"
    echo "  base-branch: 基础分支 (默认: HEAD)"
    exit 1
fi

# 确保在 git 仓库中
if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    log_error "Not inside a git repository"
    exit 1
fi

# 获取项目根目录
PROJECT_ROOT=$(git rev-parse --show-toplevel)
WORKTREE_PATH="$PROJECT_ROOT/$WORKTREE_DIR/${BRANCH_NAME//\//-}"

log_info "Creating worktree for branch: $BRANCH_NAME"
log_info "Base branch: $BASE_BRANCH"
log_info "Worktree path: $WORKTREE_PATH"

# 检查 worktree 目录是否已存在
if [[ -d "$WORKTREE_PATH" ]]; then
    log_error "Worktree already exists at: $WORKTREE_PATH"
    exit 1
fi

# 检查分支是否已存在
if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
    log_warn "Branch '$BRANCH_NAME' already exists, using existing branch"
    git worktree add "$WORKTREE_PATH" "$BRANCH_NAME"
else
    log_info "Creating new branch '$BRANCH_NAME' from '$BASE_BRANCH'"
    git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME" "$BASE_BRANCH"
fi

# 验证 gitignore
GITIGNORE_FILE="$PROJECT_ROOT/.gitignore"
if ! git check-ignore -q "$WORKTREE_DIR" 2>/dev/null; then
    log_warn "$WORKTREE_DIR is not in .gitignore, adding..."
    echo "$WORKTREE_DIR/" >> "$GITIGNORE_FILE"
    log_info "Added $WORKTREE_DIR/ to .gitignore"
fi

# 进入 worktree 并安装依赖
cd "$WORKTREE_PATH"

log_info "Detecting project type and installing dependencies..."

# 自动检测并安装依赖
if [[ -f "package.json" ]]; then
    log_info "Node.js project detected"
    if [[ -f "package-lock.json" ]]; then
        npm ci
    elif [[ -f "yarn.lock" ]]; then
        yarn install --frozen-lockfile
    elif [[ -f "pnpm-lock.yaml" ]]; then
        pnpm install --frozen-lockfile
    else
        npm install
    fi
elif [[ -f "Cargo.toml" ]]; then
    log_info "Rust project detected"
    cargo build
elif [[ -f "requirements.txt" ]]; then
    log_info "Python project detected"
    pip install -r requirements.txt
elif [[ -f "go.mod" ]]; then
    log_info "Go project detected"
    go mod download
elif [[ -f "Gemfile" ]]; then
    log_info "Ruby project detected"
    bundle install
fi

# 验证测试基线
log_info "Verifying test baseline..."
if [[ -f "package.json" ]] && grep -q '"test"' package.json; then
    log_info "Running npm test..."
    npm test || log_warn "Some tests failed - review before continuing"
elif [[ -f "Cargo.toml" ]]; then
    cargo test || log_warn "Some tests failed - review before continuing"
elif [[ -f "pytest.ini" ]] || [[ -f "setup.py" ]]; then
    pytest || log_warn "Some tests failed - review before continuing"
fi

log_info "✅ Worktree created successfully!"
echo ""
echo "Next steps:"
echo "  cd $WORKTREE_PATH"
echo "  # Start working on your feature"
echo ""
echo "When done:"
echo "  git worktree remove $WORKTREE_PATH"
