---
name: lite-save
description: Save session progress to 3 minimal files (tasks.md, notes.md, session_summary.md)
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# /lite-save — 3 文件极简保存 (v4.2.0 统一命名)

## 命令格式

```bash
/lite-save              # 生成 3 个文件到 codebox/context/
lite-save               # 简写
简单存档                 # 中文
极简保存                 # 中文
```

## 目的

实现 Manus 原始的 3 文件模式，为简单任务提供极简的上下文持久化。

不需要 ai-dev 的完整工作流，只需要 3 个 markdown 文件即可跨 session 恢复。

**v4.2.0 变更**：Lite Mode 现在是 Full Mode 的**子集**，使用统一的文件命名和位置。

## 生成的文件

```
codebox/context/              # 统一位置 (与 Full Mode 相同)
├── tasks.md                  # 任务进度追踪 (原 task_plan.md)
├── notes.md                  # 研究笔记和发现
└── session_summary.md        # Session 摘要 (原 session.md)
```

**统一优势**：
- `/ai:session-resume` 同时支持 Lite Mode 和 Full Mode
- 从 Lite Mode 升级到 Full Mode 无需迁移文件
- 学习成本为零：Lite Mode 就是 Full Mode 的简化版

## 执行流程

### Step 1: 创建目录并分析当前工作

```bash
# 1. 确保目录存在
mkdir -p codebox/context

# 2. 从对话上下文提取：
#    - 当前任务的目标
#    - 已完成的工作
#    - 进行中的任务
#    - 遇到的问题和解决方案
#    - 下一步计划

# 3. 从 git 获取：
#    - 最近的 commits
#    - 文件变更
```

### Step 2: 生成/更新 codebox/context/tasks.md

**如果文件不存在**，创建新文件：

```markdown
# Tasks: {从对话提取的任务描述}

## Goal
{一句话描述最终目标}

## Phases
- [x] Phase 1: Plan and setup
- [ ] Phase 2: Research/gather information
- [ ] Phase 3: Execute/build
- [ ] Phase 4: Review and deliver

## Key Questions
1. {从对话提取的关键问题}

## Decisions Made
- {决策}: {理由}

## Errors Encountered

| Time | Error | Root Cause | Resolution |
|------|-------|------------|------------|
| {time} | {error} | {cause} | {resolution} |

## Status
**Currently in Phase X** - {当前正在做什么}
```

**如果文件已存在**，更新：
- 更新 Phases 的 checkbox 状态
- 追加新的 Decisions
- 追加新的 Errors
- 更新 Status 部分

### Step 3: 生成/更新 codebox/context/notes.md

**如果文件不存在**，创建新文件：

```markdown
# Notes: {任务主题}

## Sources

### Source 1: {名称}
- URL: {链接}
- Key points:
  - {发现}

## Synthesized Findings

### {类别}
- {发现}

## Decisions
- {决策}: {理由}
```

**如果文件已存在**，追加新内容（保留历史）。

### Step 4: 生成 codebox/context/session_summary.md

每次 `/lite-save` 都覆盖 session_summary.md：

```markdown
# Session Summary

**Date**: {当前日期}
**Mode**: Lite (3-file pattern)
**Generated**: {timestamp}

## What We Worked On
{从对话提取的主题描述}

## Progress
- Phase 1: ✅ Completed
- Phase 2: 🔄 In Progress
- Phase 3: ⏳ Pending
- Phase 4: ⏳ Pending

## Key Accomplishments
- {从对话提取的成就}

## Errors Encountered

| Error | Resolution |
|-------|------------|
| {error} | {resolution} |

## Files Changed
{git diff --stat 输出}

## Git Commits
{git log --oneline -5 输出}

## Next Steps
1. {下一步 1}
2. {下一步 2}

---

Resume with: `/lite-resume` or `/ai:session-resume`
```

### Step 5: 输出保存报告

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Lite Mode Save Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Location: codebox/context/

Files:
  ✅ tasks.md           (updated)
  ✅ notes.md           (updated)
  ✅ session_summary.md (created)

Progress:
  Phase: 2 (Research)
  Completed: Phase 1
  Next: Continue research

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Resume with: /lite-resume or /ai:session-resume
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 与 Full Mode 的关系 (v4.2.0)

| 特性 | Lite Mode | Full Mode |
|------|-----------|-----------|
| 文件位置 | `codebox/context/` | `codebox/context/` + `codebox/changes/` |
| 核心文件 | tasks.md, notes.md, session_summary.md | 同 + state.json, design.md 等 |
| 文件数 | 3 | 15+ |
| 状态追踪 | checkbox | state.json |
| 工作流 | 4 步循环 | 7 阶段 + OODA |
| 知识积累 | 无 | patterns + errors |
| 升级路径 | 可无缝升级到 Full Mode | — |

## 使用场景

**推荐使用 Lite Mode**：
- 单次研究任务
- 简单 bug 修复
- 快速原型
- 探索性工作
- 不需要跨多个 session 的任务

## 示例

```
用户: "/lite-save"

Claude 执行:
📊 Analyzing current context...
  - Goal: Research TypeScript best practices
  - Phase: 2 (Research)
  - Completed: Initial setup

📝 Generating files to codebox/context/...
  - tasks.md (created)
  - notes.md (created)
  - session_summary.md (created)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Lite Mode Save Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Location: codebox/context/

Files:
  ✅ tasks.md
  ✅ notes.md
  ✅ session_summary.md

Progress: Phase 2 (Research) | 1/4 phases done

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Resume with: /lite-resume or /ai:session-resume
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 从 Lite Mode 升级到 Full Mode

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

## 核心原则

> **Store, Don't Stuff**
>
> 大内容存储在文件中，而不是塞满上下文。
> Lite Mode 的 3 个文件是 "工作记忆的磁盘延伸"。

## 错误处理

如果无法从对话提取足够信息，会询问用户：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ Need More Information
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Please describe:
1. What is the current goal?
2. What phase are you in?
3. What are the next steps?
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
