#!/bin/bash
# cleanup-worktree.sh - 清理 Git Worktree
# Usage: ./cleanup-worktree.sh <branch-name> [--force]

set -e

BRANCH_NAME="${1:-}"
FORCE_FLAG="${2:-}"
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
    log_error "Usage: $0 <branch-name> [--force]"
    echo "  branch-name: 分支名称 (如 feature/auth)"
    echo "  --force: 强制删除，即使有未提交更改"
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

log_info "Cleaning up worktree: $WORKTREE_PATH"

# 检查 worktree 是否存在
if [[ ! -d "$WORKTREE_PATH" ]]; then
    log_error "Worktree does not exist: $WORKTREE_PATH"
    echo ""
    echo "Available worktrees:"
    git worktree list
    exit 1
fi

# 检查未提交更改
cd "$WORKTREE_PATH"
if [[ -n $(git status --porcelain) ]]; then
    log_warn "Uncommitted changes detected:"
    git status --short
    echo ""

    if [[ "$FORCE_FLAG" != "--force" ]]; then
        log_error "Refusing to delete worktree with uncommitted changes"
        echo "Options:"
        echo "  1. Commit or stash your changes first"
        echo "  2. Use --force to delete anyway: $0 $BRANCH_NAME --force"
        exit 1
    else
        log_warn "Force flag set, proceeding with deletion..."
    fi
fi

# 回到项目根目录
cd "$PROJECT_ROOT"

# 删除 worktree
if [[ "$FORCE_FLAG" == "--force" ]]; then
    git worktree remove --force "$WORKTREE_PATH"
else
    git worktree remove "$WORKTREE_PATH"
fi

log_info "✅ Worktree removed successfully!"

# 询问是否删除分支
echo ""
read -p "Delete branch '$BRANCH_NAME'? (y/N): " -n 1 -r
echo ""
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # 检查分支是否已合并
    MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")

    if git branch --merged "$MAIN_BRANCH" | grep -q "$BRANCH_NAME"; then
        log_info "Branch is merged, safe to delete"
        git branch -d "$BRANCH_NAME"
        log_info "Local branch deleted"

        read -p "Delete remote branch? (y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git push origin --delete "$BRANCH_NAME" 2>/dev/null || log_warn "Remote branch not found or already deleted"
            log_info "Remote branch deleted"
        fi
    else
        log_warn "Branch is not merged into $MAIN_BRANCH"
        read -p "Force delete unmerged branch? (y/N): " -n 1 -r
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git branch -D "$BRANCH_NAME"
            log_info "Branch force deleted"
        fi
    fi
fi

# 清理无效 worktree 记录
git worktree prune

log_info "Cleanup complete!"
echo ""
echo "Remaining worktrees:"
git worktree list
