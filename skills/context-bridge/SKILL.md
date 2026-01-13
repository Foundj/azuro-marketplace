---
name: context-bridge
version: 4.2.1
description: |
  This skill should be used when managing cross-session context and in-session attention.
  Implements Manus "Read Before Decide" pattern. Auto Checkpoint at 90% context.

  **TRIGGERS**: save, resume, focus, progress, lite-save, checkpoint, 保存, 恢复, 继续

  **Usage**: /focus (refresh goals), /session:save (checkpoint), /session:resume (continue),
  /lite-save (3-file save), /lite-resume (3-file restore), /progress (show status)
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
---

# Context Bridge - 注意力管理器

## 🎯 一句话说明

**保存当前进度 → 刷新目标焦点 → 新 Session 无缝继续。**

---

## 🧠 注意力管理规则 (CRITICAL)

> **核心原则：Read Before Decide**
>
> 在长对话中，原始目标会被 "遗忘"（Lost in the Middle 问题）。
> 解决方案：在重大决策前，重新读取目标文件，将目标刷新到注意力窗口末端。

### 何时刷新注意力

**必须刷新**（在以下情况前先 Read 目标文件）：

1. **开始新的 Phase 前** → Read `proposal.md` 或 `design.md`
2. **OODA 每次迭代开始** → Read `tasks.md`
3. **做重大架构决策前** → Read `requirements.md` + `design.md`
4. **完成主要任务后** → Read `next_steps.md` 确认方向
5. **上下文超过 50%** → 运行 `/focus` 刷新目标

### 建议刷新

- 连续工作超过 1 小时
- 完成一个复杂任务后
- 遇到困惑或不确定时

---

## 🔄 Auto Checkpoint 机制 (v4.2.0)

> **核心原则**：在 context 耗尽前自动保存，避免丢失进度

### 多级阈值系统

| 阈值 | 动作 | 说明 |
|------|------|------|
| **70%** | 💡 建议 `/focus` | "Context 70%. Consider /focus to refresh goals." |
| **85%** | ⚠️ 警告 + 建议保存 | "Context 85%. Run /session:save soon." |
| **90%** | 🔴 **Auto Checkpoint** | 自动执行保存并提示 /clear |

### 90% Auto Checkpoint 流程

当检测到 context 达到 90% 时，**自动执行**：

```
1. 自动运行 /session:save (保存到 codebox/context/)
2. 输出 Auto Checkpoint 报告：

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔴 Auto Checkpoint (Context 90%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Progress saved to codebox/context/
   - session_summary.md (updated)
   - next_steps.md (updated)

📊 Current Status:
   - Phase: 4 (Implementation)
   - Tasks: 5/7 completed
   - Blockers: None

🔄 To continue with fresh context:
   1. Run: /clear
   2. Then: resume

⚠️ If you continue without /clear, context may overflow.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 任务完成时自动提示

当检测到 **所有任务完成** 时，自动提示保存：

```
━━━━━━━━━━━━━━━━━━━━━━━━━
✅ All Tasks Completed!
━━━━━━━━━━━━━━━━━━━━━━━━━
🎉 7/7 tasks done

Save session? Run: /session:save
Or archive feature: /feature-archive
━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Hook 配置

在 `.claude/settings.local.json` 中配置 Auto Checkpoint：

```json
{
  "hooks": {
    "auto-checkpoint": {
      "enabled": true,
      "thresholds": {
        "focus_suggest": 70,
        "save_warning": 85,
        "auto_save": 90
      }
    }
  }
}
```

---

### /focus 命令

快速刷新目标到注意力窗口：

```bash
/focus                  # 读取并显示 next_steps.md 的 P0/P1 任务
```

输出格式：
```
━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Focus Refresh
━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Current Goal: Implement user auth
📊 Progress: 5/7 tasks completed
🔴 P0: Fix 4 failing tests in AuthService.test.ts
🟡 P1: Complete integration tests
━━━━━━━━━━━━━━━━━━━━━━━━━
```

### /progress 命令

显示详细进度 Progress Check：

```bash
/progress               # 显示完整进度报告
```

输出格式：
```
━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Progress Check (Task 5/7)
━━━━━━━━━━━━━━━━━━━━━━━━━
Goal: Implement user authentication system
Phase: 4 (Implementation) | OODA: 5/10

Done:
  ✅ Task 1: Create User model
  ✅ Task 2: Create UserRepository
  ✅ Task 3: Create AuthService
  ✅ Task 4: Create login API
  ✅ Task 5: Add validation

Next:
  🔄 Task 6: Integration tests
  ⏳ Task 7: API documentation

Blockers:
  ⚠️ 4 failing tests in AuthService.test.ts
━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## ⚡ 核心命令

### 1. `/session:save` - 保存进度 (Session 结束时)

```bash
# 触发词
"/session:save"     # 最简单
"save session"      # 保存
"save progress"     # 保存进度
"存档"              # 中文
"保存进度"          # 中文
```

**执行步骤**:
1. 扫描当前 active changes 状态
2. 收集本次 session 完成的工作
3. 生成 `codebox/context/session_summary.md`
4. 更新 `codebox/context/next_steps.md`
5. 输出摘要供用户确认

### 2. `/session:resume` - 恢复并继续 (新 Session 开始时)

```bash
# 触发词
"/session:resume"   # 恢复
"resume session"    # 继续
"继续"              # 中文
"恢复"              # 中文
"接着做"            # 中文
```

**执行步骤**:
1. 读取 `codebox/context/next_steps.md`
2. 读取 `codebox/context/session_summary.md` (上次摘要)
3. 验证 active changes 状态
4. 显示推荐的下一步任务
5. **自动开始执行第一个任务** (无需用户再次输入)

---

## 🔀 双模式架构 (重要)

Context Bridge 支持两种运行模式，**自动检测**当前环境：

### Mode A: ai-dev 集成模式

**检测条件**: `codebox/changes/active/` 目录存在且有 state.json

```
✅ 检测到 ai-dev 工作流
   - 读取 codebox/changes/active/*/state.json
   - 读取 codebox/changes/active/*/tasks.md
   - 提取 Phase, OODA iteration, blockers
   - 与 7-Phase workflow 深度集成
```

**数据源**:
- `state.json` → changeId, currentPhase, ooda.iterationCount
- `tasks.md` → 任务完成状态
- `progress.txt` → 进度日志
- `git log` → 提交历史

**输出位置**: `codebox/context/`

### Mode B: 独立模式 (Standalone)

**检测条件**: 无 codebox 目录，或无 active changes

```
📦 独立模式
   - 从对话上下文提取任务信息
   - 读取 git log 获取变更历史
   - 用户手动描述当前进度
```

**数据源**:
- 对话上下文 → 本次讨论的任务、决策
- `git log` → 最近提交
- `git diff --stat` → 文件变更
- 用户描述 → 当前进度和下一步

**输出位置**: `codebox/context/` (与 Mode A 统一)

### 模式检测逻辑

```bash
# Step 0: 检测运行模式
detect_mode() {
  if [ -d "codebox/changes/active" ]; then
    active_count=$(ls codebox/changes/active/ 2>/dev/null | wc -l)
    if [ "$active_count" -gt 0 ]; then
      # 检查是否有有效的 state.json
      for dir in codebox/changes/active/*/; do
        if [ -f "${dir}state.json" ]; then
          echo "ai-dev"  # Mode A
          return
        fi
      done
    fi
  fi
  echo "standalone"  # Mode B
}

MODE=$(detect_mode)
# 统一使用 codebox/context/ 目录
CONTEXT_DIR="codebox/context"
mkdir -p "$CONTEXT_DIR/sessions"
```

### 模式对比

| 特性 | Mode A (ai-dev) | Mode B (独立) |
|------|-----------------|---------------|
| 任务来源 | state.json + tasks.md | 对话上下文 + git |
| Phase 追踪 | ✅ 自动 | ❌ 无 |
| OODA 状态 | ✅ 自动 | ❌ 无 |
| 输出目录 | codebox/context/ | codebox/context/ |
| 恢复精度 | 高 (结构化数据) | 中 (文本描述) |

---

## 📁 Context 文件结构

两种模式统一使用 `codebox/context/` 目录：

```
codebox/context/
├── session_summary.md    # 上次 session 摘要
├── next_steps.md         # 下一步任务 (新 session 入口)
├── current_focus.md      # 当前焦点 (可选，实时更新)
└── sessions/             # 历史 session 归档
    ├── session-001.md
    ├── session-002.md
    └── ...
```

---

## 💾 /session:save 实现流程

### Step 0: 检测运行模式

```bash
# 首先检测当前模式，统一使用 codebox/context/ 目录
MODE="standalone"  # 默认独立模式
CONTEXT_DIR="codebox/context"

if [ -d "codebox/changes/active" ]; then
  for dir in codebox/changes/active/*/; do
    if [ -f "${dir}state.json" ]; then
      MODE="ai-dev"
      break
    fi
  done
fi

mkdir -p "$CONTEXT_DIR/sessions"
echo "📍 Running in $MODE mode, output to $CONTEXT_DIR"
```

### Step 1: 收集状态信息

#### Mode A (ai-dev): 从结构化文件收集

```bash
# 1. 扫描 active changes
active_changes=$(ls codebox/changes/active/ 2>/dev/null)

# 2. 读取每个 change 的 state.json
for change in $active_changes; do
  state=$(cat "codebox/changes/active/$change/state.json")
  # 提取: changeId, currentPhase, ooda iteration, tasks 完成情况
  change_id=$(echo "$state" | jq -r '.changeId')
  phase=$(echo "$state" | jq -r '.currentPhase')
  ooda_count=$(echo "$state" | jq -r '.ooda.iterationCount // 0')
  ooda_max=$(echo "$state" | jq -r '.ooda.maxIterations // 10')

  # 读取 tasks.md 统计完成情况
  tasks_file="codebox/changes/active/$change/tasks.md"
  if [ -f "$tasks_file" ]; then
    completed=$(grep -c "^\s*- \[x\]" "$tasks_file" 2>/dev/null || echo "0")
    pending=$(grep -c "^\s*- \[ \]" "$tasks_file" 2>/dev/null || echo "0")
  fi
done

# 3. 读取 progress.txt 最近条目
recent_progress=$(tail -50 codebox/progress.txt 2>/dev/null)
```

#### Mode B (独立模式): 从对话和 git 收集

```bash
# 1. 从 git 获取最近变更
recent_commits=$(git log --oneline -10 2>/dev/null)
files_changed=$(git diff --stat HEAD~5..HEAD 2>/dev/null || git diff --stat)

# 2. 从对话上下文提取 (Claude 需要分析对话)
# - 本次讨论的主题
# - 已完成的工作
# - 遇到的问题
# - 下一步计划

# 3. 询问用户确认 (如果信息不足)
# "请简要描述当前进度和下一步计划"
```

### Step 2: 生成 session_summary.md

#### Mode A (ai-dev) 模板

```markdown
# Session Summary - #{session_number}

**Date**: {date}
**Duration**: {start_time} - {end_time}
**Mode**: ai-dev (7-Phase Workflow)

## Completed This Session
- ✅ {task_1}
- ✅ {task_2}
- 🔄 {task_3} (in progress)

## Active Changes Status
| Change ID | Phase | Progress | Blockers |
|-----------|-------|----------|----------|
| 001-user-auth | Phase 4 | 6/10 OODA | 4 failing tests |
| 002-analytics | Phase 2 | Exploring | None |

## Key Decisions Made
- {decision_1}
- {decision_2}

## Issues Encountered
- {issue_1} → {resolution_1}

## Files Changed
- `src/auth/AuthService.ts` (created)
- `src/routes/api.ts` (modified)

## Git Commits
- abc1234 feat: implement login API
- def5678 fix: password validation

## Context for Next Session
{summary_of_current_state}

## Blockers to Address
- ⚠️ {blocker_1}
- ⚠️ {blocker_2}
```

#### Mode B (独立模式) 模板

```markdown
# Session Summary - #{session_number}

**Date**: {date}
**Mode**: Standalone

## What We Worked On
{从对话上下文提取的主题描述}

## Completed This Session
- ✅ {task_1}
- ✅ {task_2}

## In Progress
- 🔄 {current_task}

## Key Decisions
- {decision_1}

## Files Changed
{git diff --stat 输出}

## Git Commits
{git log --oneline -10 输出}

## Issues & Solutions
- {issue_1} → {solution_1}

## Context for Next Session
{对话摘要，包含关键上下文}

## Next Steps
- {next_step_1}
- {next_step_2}
```

### Step 3: 生成 next_steps.md

```markdown
# Next Steps 📋

> Generated: {timestamp}
> Last Session: #{session_number}

## Quick Resume Command
\`\`\`bash
resume  # 或直接说 "继续"
\`\`\`

## Immediate Tasks (按优先级)

### 🔴 P0 - 必须立即处理
1. **修复 4 个 failing tests** in AuthService.test.ts
   - File: `src/auth/__tests__/AuthService.test.ts`
   - Issues: token refresh timeout, missing error handling
   - Command: `ai fix the failing tests in AuthService.test.ts`

### 🟡 P1 - 本次应完成
2. **完成 Task 6**: Integration tests
   - Change: 001-user-auth
   - Phase: 4 (Implementation)
   - OODA: 6/10

### 🟢 P2 - 可以开始
3. **开始 Task 7**: API documentation
   - Depends on: Task 6 ✅

## Active Changes Overview
| Change | Phase | Next Action |
|--------|-------|-------------|
| 001-user-auth | 4 | Fix tests → continue OODA |
| 002-analytics | 2 | Wait for explorer |

## Ready-to-Execute Commands
\`\`\`bash
# 修复测试 (最高优先级)
ai fix the 4 failing tests in AuthService.test.ts

# 或继续当前任务
ai continue 001-user-auth

# 或查看详情
/feature-show 001-user-auth
\`\`\`

## Session Continuity
- Previous session ended: {end_time}
- Recommended focus: {primary_task}
- Estimated time to complete current task: ~{estimate}
```

### Step 4: 归档历史 Session

```bash
# 如果存在旧的 session_summary.md，移动到 sessions/ 目录
session_count=$(ls codebox/context/sessions/ 2>/dev/null | wc -l)
next_session=$((session_count + 1))
mv codebox/context/session_summary.md \
   codebox/context/sessions/session-$(printf "%03d" $next_session).md
```

---

## 🔄 /session:resume 实现流程

### Step 1: 读取上下文文件

```bash
# 1. 读取 next_steps.md
next_steps=$(cat codebox/context/next_steps.md)

# 2. 读取上次 session 摘要
last_summary=$(cat codebox/context/session_summary.md)

# 3. 验证 active changes 状态
for change in codebox/changes/active/*/state.json; do
  # 验证 state.json 有效
  # 检查 resumability.canResume
done
```

### Step 2: 显示恢复报告

```markdown
# 🔄 Session Resumed

## Last Session Recap
- Date: {last_session_date}
- Completed: {completed_count} tasks
- In Progress: {in_progress_task}

## Current State Validation
- ✅ codebox/context/next_steps.md found
- ✅ Active changes: 2
- ✅ State files valid

## Recommended Next Action
{first_priority_task}

## Starting...
```

### Step 3: 自动执行下一步

**关键**: `/session:resume` 不仅显示信息，还**自动开始执行**第一个任务。

```
# 解析 next_steps.md 中的第一个 P0 任务
# 提取 command 或 task description
# 自动触发执行
```

例如：
```
📍 Resuming Session...

Last session: #5 (2025-01-09 18:30)
Completed: 2 tasks | In progress: Task 6

🎯 Auto-starting first priority task:
"修复 AuthService.test.ts 中的 4 个 failing tests"

[开始执行...]
```

---

## 📋 使用示例

### 示例 1: Session 结束时保存

```
你: "/session:save"

Context Bridge 执行:
📊 Scanning active changes...
  - 001-user-auth: Phase 4, OODA 6/10
  - 002-analytics: Phase 2, exploring

📝 Generating session summary...
  - Completed: 2 tasks
  - In progress: 1 task
  - Commits: 3

✅ Session Summary saved to:
   codebox/context/session_summary.md

📋 Next Steps generated:
   codebox/context/next_steps.md

🔖 Session #5 archived to:
   codebox/context/sessions/session-005.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Session #5 Summary
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Completed: Task 4, Task 5
In Progress: Task 6 (4 failing tests)
Next Priority: Fix failing tests

下次开始时输入 "/session:resume" 即可继续
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 示例 2: 新 Session 恢复并继续

```
你: "/session:resume"

Context Bridge 执行:
📖 Reading context files...
  ✅ next_steps.md found
  ✅ session_summary.md found (Session #5)

🔍 Validating state...
  ✅ 001-user-auth: resumable
  ✅ 002-analytics: resumable

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Session #6 Starting
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Last session: #5 (2025-01-09 18:30)
Time since: 14 hours ago

📊 Quick Recap:
- Completed: Task 4, 5
- In Progress: Task 6 (Integration tests)
- Blocker: 4 failing tests

🎯 First Priority (P0):
修复 AuthService.test.ts 中的 4 个 failing tests

🚀 Auto-starting...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Claude 自动开始分析并修复 failing tests...]
```

---

## 🔗 与现有系统集成

### 与 session-manager 协作

```
session-manager (完整恢复)     context-bridge (轻量恢复)
        │                              │
        │  10步完整验证                 │  快速读取 context/
        │  环境启动                     │  直接继续任务
        │  测试运行                     │
        ▼                              ▼
   适合: 长时间中断后              适合: 短时间中断
         环境可能变化                   只需继续任务
```

### 与 ai-dev workflow 协作

```
/session:save → 保存 Phase/OODA 状态
/session:resume → 恢复并继续 Phase/OODA
```

### 与 knowledge-graph 协作

```
/session:save 时:
- 提取本次 session 的 learnings
- 更新 knowledge/learnings.md
```

---

## 📦 Lite Mode — 3 文件极简模式 (v4.2.0 统一命名)

> **适用场景**：简单任务、快速项目、不需要 ai-dev 完整工作流
>
> **v4.2.0 变更**：Lite Mode 现在是 Full Mode 的**子集**，使用统一的文件命名和位置

Lite Mode 实现 Manus 原始的 3 文件模式，极简高效。

### 3 文件结构 (统一命名)

```
codebox/context/              # 统一位置 (与 Full Mode 相同)
├── tasks.md                  # 任务进度追踪 (原 task_plan.md)
├── notes.md                  # 研究笔记和发现
└── session_summary.md        # Session 摘要 (原 session.md)
```

**统一优势**：
- `/session:resume` 同时支持 Lite Mode 和 Full Mode
- 从 Lite Mode 升级到 Full Mode 无需迁移文件
- 学习成本为零：Lite Mode 就是 Full Mode 的简化版

### `/lite-save` — 极简保存

```bash
/lite-save                  # 生成 3 个文件到 codebox/context/
"简单存档"                   # 中文触发
```

执行步骤：
1. 创建 `codebox/context/` 目录（如果不存在）
2. 生成/更新 `tasks.md` — 任务阶段和 checkbox
3. 生成/更新 `notes.md` — 研究发现和决策
4. 生成 `session_summary.md` — 本次 session 摘要

**tasks.md 模板** (Lite Mode 简化版)：
```markdown
# Tasks: {简短描述}

## Goal
{一句话目标}

## Phases
- [x] Phase 1: 规划和准备
- [ ] Phase 2: 研究/收集信息
- [ ] Phase 3: 执行/构建
- [ ] Phase 4: 审查和交付

## Key Decisions
- {决策}: {理由}

## Errors Encountered
| Time | Error | Root Cause | Resolution |
|------|-------|------------|------------|
| {time} | {error} | {cause} | {resolution} |

## Status
**Currently in Phase X** - {正在做什么}
```

### `/lite-resume` — 极简恢复

```bash
/lite-resume                # 从 codebox/context/ 恢复
"简单恢复"                   # 中文触发
```

执行步骤：
1. **Read codebox/context/tasks.md** — 刷新目标到注意力窗口（核心！）
2. Read codebox/context/notes.md — 恢复研究上下文
3. Read codebox/context/session_summary.md — 获取上次进度
4. 自动继续第一个未完成的 Phase

### Lite Mode vs Full Mode 对比

| 特性 | Lite Mode | Full Mode (ai-dev) |
|------|-----------|-------------------|
| 文件位置 | `codebox/context/` | `codebox/context/` + `codebox/changes/` |
| 文件数 | 3 个 | 15+ 个 |
| 核心文件 | tasks.md, notes.md, session_summary.md | 同 + state.json, design.md 等 |
| 状态追踪 | checkbox | state.json |
| 工作流 | 4 步循环 | 7 阶段 + OODA |
| 上手难度 | ⭐ 即开即用 | ⭐⭐⭐⭐ 需要学习 |
| 适用场景 | 简单任务、快速项目 | 复杂功能、长期项目 |
| 知识积累 | ❌ 无 | ✅ patterns + errors |
| 升级路径 | 可无缝升级到 Full Mode | — |

### 何时使用 Lite Mode

**使用 Lite Mode**：
- 单次任务，不需要跨多个 session
- 简单 bug 修复或小功能
- 研究任务或探索性工作
- 快速原型

**使用 Full Mode**：
- 复杂功能开发
- 需要 7 阶段质量控制
- 多人协作项目
- 需要知识积累

### 从 Lite Mode 升级到 Full Mode

如果任务变复杂，可以无缝升级：

```bash
# 1. 当前在 Lite Mode，发现任务复杂
/lite-save                    # 保存当前进度

# 2. 初始化 ai-dev 工作流
/ai:dev "继续当前任务"          # 会读取 codebox/context/tasks.md

# 3. ai-dev 会自动：
#    - 检测到现有的 tasks.md
#    - 询问是否基于现有任务继续
#    - 创建完整的 change 结构
```

---

## ⚙️ 配置选项

### Auto Checkpoint 阈值 (v4.2.0)

| 阈值 | 动作 | 触发条件 |
|------|------|----------|
| **70%** | 💡 建议 `/focus` | Context 使用率 |
| **85%** | ⚠️ 警告 + 建议保存 | Context 使用率 |
| **90%** | 🔴 **自动保存** | Context 使用率 |
| — | ✅ 提示保存/归档 | 所有任务完成 |
| — | 💡 建议保存 | 连续工作 2+ 小时 |

### Session 归档策略

```yaml
archive:
  max_sessions: 50          # 保留最近 50 个 session
  compress_after: 30        # 30天后压缩
  auto_cleanup: true        # 自动清理
```

---

## 💡 最佳实践

### ✅ 推荐做法

1. **每个 session 结束前运行 /session:save**
2. **新 session 开始时直接 /session:resume**
3. **遇到复杂问题时 /session:save 保存思路**
4. **定期归档历史 sessions**

### ❌ 避免

1. 不保存就关闭 session ❌
2. 手动编辑 context 文件 ❌
3. 让 sessions/ 目录无限增长 ❌

---

## 🆚 与 Planning-with-Files 对比

| 功能 | Planning-with-Files | Context Bridge |
|------|---------------------|----------------|
| 目标追踪 | task_plan.md | next_steps.md |
| 笔记存储 | notes.md | session_summary.md |
| 恢复方式 | 手动读取 | **自动执行** |
| 状态来源 | 手动维护 | **从 state.json 自动提取** |
| 与工作流集成 | 无 | **与 7-Phase/OODA 深度集成** |

**核心优势**: Context Bridge 不仅保存，还能**自动继续执行**。

---

## 📚 完整命令列表

| 命令 | 作用 | 场景 |
|------|------|------|
| `/focus` | 刷新目标到注意力窗口 | 工作中随时可用 |
| `/progress` | 显示详细进度 Progress Check | 检查当前状态 |
| `/session:save` | 保存当前 session 进度 (Full Mode) | Session 结束时 |
| `/session:resume` | 恢复并自动继续 (Full Mode) | 新 Session 开始时 |
| `/session:show` | 仅显示 next_steps.md (不执行) | 查看下一步 |
| `/lite-save` | 3 文件极简保存 | 简单任务存档 |
| `/lite-resume` | 从 3 文件恢复 | 简单任务恢复 |

---

## 📦 Dependencies

**Required**:
- `jq` - JSON processing (for state.json parsing)
- `bash` - Script execution (POSIX compatible)
- `git` - Version history and commit tracking

**Optional**:
- `codebox/` - ai-dev workflow integration (auto-detected)

**Skill Dependencies**:
- `ai-dev` - 7-Phase workflow integration (optional, enhances Mode A)
- `session-manager` - Full recovery fallback (optional)
- `knowledge-graph` - Learning extraction on save (optional)

---

## 🪝 Hooks Configuration

Context Bridge can be configured to auto-trigger through Claude Code hooks.

### Auto-Checkpoint Suggestion Hook

When context usage exceeds threshold, suggest saving:

```json
// .claude/settings.local.json
{
  "hooks": {
    "context-warning": {
      "trigger": "context_usage > 70%",
      "action": "suggest",
      "message": "💡 Context 70%+ used. Consider running /session:save to checkpoint progress."
    }
  }
}
```

### Pre-Exit Hook

Remind to save before ending session:

```json
{
  "hooks": {
    "pre-exit": {
      "trigger": "session_end",
      "action": "prompt",
      "message": "📋 Session ending. Run /session:save to preserve progress?"
    }
  }
}
```

### Auto-Resume on Start

Automatically resume if context files exist:

```json
{
  "hooks": {
    "post-init": {
      "trigger": "session_start",
      "condition": "file_exists('codebox/context/next_steps.md')",
      "action": "suggest",
      "message": "🔄 Previous session found. Resume with /session:resume?"
    }
  }
}
```

### Auto Checkpoint Hooks (v4.2.0)

Multi-level threshold hooks for automatic checkpoint:

```json
{
  "hooks": {
    "attention-refresh-70": {
      "trigger": "context_usage > 70%",
      "action": "suggest",
      "message": "💡 Context 70%. Consider /focus to refresh goals."
    },
    "save-warning-85": {
      "trigger": "context_usage > 85%",
      "action": "warn",
      "message": "⚠️ Context 85%. Run /session:save soon."
    },
    "auto-checkpoint-90": {
      "trigger": "context_usage > 90%",
      "action": "auto_execute",
      "command": "/session:save",
      "message": "🔴 Context 90%. Auto-saving progress..."
    },
    "task-completion": {
      "trigger": "all_tasks_completed",
      "action": "suggest",
      "message": "✅ All tasks completed! Run /session:save or /feature-archive"
    }
  }
}
```

---

## 📋 Version History

| Version | Date | Changes |
|---------|------|---------|
| 4.2.0 | 2026-01-10 | **Auto Checkpoint**: Multi-level thresholds (70%/85%/90%), unified Lite Mode naming (codebox/context/), task completion detection |
| 4.1.0 | 2025-01-10 | **Attention Manager upgrade**: Added "Read Before Decide" rules, /focus, /progress, Lite Mode (3-file pattern) |
| 4.0.2 | 2025-01-09 | Added hooks config, dependencies, improved triggers |
| 4.0.1 | 2025-01-08 | Dual-mode architecture (ai-dev / standalone) |
| 4.0.0 | 2025-01-07 | Initial release with Manus pattern integration |

---

## 🎯 核心理念

> **Context Bridge 是注意力管理器**：
>
> - **保存时** — 不仅存储状态，还生成目标摘要
> - **恢复时** — 不仅读取状态，还刷新注意力
> - **执行中** — 周期性提醒目标，防止 "lost in the middle"
> - **两种模式** — Lite (3 文件) 和 Full (ai-dev 集成)

Manus 的价值不在于复杂的系统设计，而在于理解了一个简单的事实：
**LLM 的注意力会随着 context 增长而衰减，解决方案就是周期性地把目标重新注入到注意力窗口末端。**

这就是 **"Read Before Decide"** 的本质。
