---
name: git-worktree
description: |
  This skill should be used when starting feature work that needs isolation, before executing
  implementation plans, or when running parallel Claude sessions. It provides Git worktree management
  for isolated development. Triggers on "worktree", "isolated branch", "parallel development",
  "隔离开发", "并行分支", "worktree创建". Auto-triggers when ultrawork detects COMPLEX tasks (≥5 files).
version: 5.0.17
triggers:
  - worktree
  - isolated branch
  - parallel development
  - create worktree
  - 隔离开发
  - 并行分支
  - worktree创建
  - complex task isolation
---

# Git Worktree Management

> Create isolated workspaces for parallel development without branch switching conflicts.

## Auto-Trigger Rules (v5.1)

```
╔═══════════════════════════════════════════════════════════════╗
║                    AUTO-TRIGGER CONDITIONS                     ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║   ultrawork detects COMPLEX task (≥5 files affected)          ║
║           ↓                                                   ║
║   Auto-create worktree: .worktrees/<change-id>                ║
║           ↓                                                   ║
║   Install dependencies + verify baseline                      ║
║           ↓                                                   ║
║   Continue with isolated development                          ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

### Complexity Detection

```yaml
SIMPLE (no worktree):
  - 1-2 files affected
  - Bug fix with clear location
  - Config change

MEDIUM (worktree optional):
  - 3-4 files affected
  - New function/component

COMPLEX (worktree required):  # ← AUTO-TRIGGER
  - ≥5 files affected
  - New feature/module
  - Architecture changes
  - Multi-component work
```

## Quick Start

```bash
# Create worktree for feature
/worktree create feature/auth

# List all worktrees
/worktree list

# Remove worktree after completion
/worktree remove feature/auth
```

## Why Use Worktrees

| 问题 | 传统方案 | Worktree 方案 |
|------|----------|---------------|
| 多分支并行开发 | 频繁切换分支 | 独立目录，无需切换 |
| 多 Claude 会话 | 分支冲突风险 | 完全隔离，安全并行 |
| 保留 WIP 状态 | stash 或临时提交 | 原位保持，互不干扰 |
| 长期功能开发 | 主分支被占用 | 独立空间，主分支自由 |

## Directory Selection (Priority Order)

```
1. 检查现有目录: .worktrees/ 或 worktrees/
2. 检查 CLAUDE.md 配置
3. 询问用户选择
```

**默认推荐**: `.worktrees/` (项目本地，隐藏目录)

## Core Workflow

### 1. Create Worktree

```bash
# 基本创建
git worktree add .worktrees/feature-auth -b feature/auth

# 从特定分支创建
git worktree add .worktrees/hotfix -b hotfix/critical origin/main
```

### 2. Setup Environment

```bash
cd .worktrees/feature-auth

# 自动检测并安装依赖
[ -f package.json ] && npm install
[ -f Cargo.toml ] && cargo build
[ -f requirements.txt ] && pip install -r requirements.txt
[ -f go.mod ] && go mod download
```

### 3. Verify Baseline

```bash
# 运行测试确保干净起点
npm test  # 或 cargo test / pytest / go test
```

### 4. Work in Isolation

```bash
# 在 worktree 中正常开发
# 所有更改只影响该分支
```

### 5. Cleanup

```bash
# 合并后移除 worktree
git worktree remove .worktrees/feature-auth

# 如有未提交更改，强制移除
git worktree remove --force .worktrees/feature-auth
```

## Safety Checks

### Gitignore Verification

**关键**: 项目本地 worktree 目录必须被 gitignore

```bash
# 检查是否已忽略
git check-ignore -q .worktrees 2>/dev/null
echo $?  # 0 = 已忽略, 1 = 未忽略

# 如未忽略，自动修复
echo ".worktrees/" >> .gitignore
git add .gitignore
git commit -m "chore: add .worktrees to gitignore"
```

### Before Removal

```bash
# 检查未提交更改
cd .worktrees/feature-auth
git status --porcelain

# 如有更改，提示用户决定
```

## Integration with ai-dev

### Phase 2 (Design) 后自动创建

```yaml
Design 审批通过后:
  1. 自动创建 worktree: .worktrees/{change-id}
  2. 安装依赖
  3. 验证测试基线
  4. 进入 Phase 3 (Task Breakdown)
```

### Phase 6 (Finalization) 自动清理

```yaml
Finalization 完成后:
  1. 确认分支已合并
  2. 移除 worktree
  3. 删除远程分支 (可选)
```

## Commands

| 命令 | 描述 |
|------|------|
| `git worktree add <path> -b <branch>` | 创建新 worktree |
| `git worktree list` | 列出所有 worktree |
| `git worktree remove <path>` | 移除 worktree |
| `git worktree prune` | 清理无效 worktree 记录 |

## Scripts

### create-worktree.sh

```bash
#!/bin/bash
# Usage: ./create-worktree.sh <branch-name> [base-branch]
# 详见 scripts/create-worktree.sh
```

### cleanup-worktree.sh

```bash
#!/bin/bash
# Usage: ./cleanup-worktree.sh <branch-name>
# 详见 scripts/cleanup-worktree.sh
```

## Red Flags

**Never:**
- 在未验证 gitignore 的情况下创建项目本地 worktree
- 跳过测试基线验证
- 在有未提交更改时直接删除 worktree
- 同时在多个 worktree 修改同一文件

**Always:**
- 优先使用 `.worktrees/` (隐藏，不污染项目根目录)
- 创建前验证 gitignore
- 删除前检查未提交更改
- 合并后及时清理 worktree

## Agent Collaboration

| Agent | Role |
|-------|------|
| `ultrawork` | 检测 COMPLEX 任务时自动触发创建 |
| `ai-dev` | Phase 2 后触发创建，Phase 6 触发清理 |
| `session-manager` | 跨会话恢复 worktree 状态 |
| `context-bridge` | 保存 worktree 路径到上下文 |

## Integration with ultrawork

```yaml
ultrawork Phase 3 (ISOLATE):
  condition: complexity >= COMPLEX (≥5 files)
  action: |
    1. Check existing: ls -d .worktrees 2>/dev/null
    2. Verify gitignore: git check-ignore -q .worktrees
    3. Create worktree: git worktree add .worktrees/<feature-name> -b feature/<feature-name>
    4. Setup environment: npm install / pip install / cargo build
    5. Verify baseline: npm test / pytest / cargo test
    6. Continue to Phase 4 (PLAN)
```

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 5.0.13 | 2026-02-09 | Enhanced with auto-trigger for COMPLEX tasks |
| 5.0.7 | 2026-01-14 | Initial release, ported from Superpowers |
