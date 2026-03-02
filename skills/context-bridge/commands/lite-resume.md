---
name: lite-resume
description: Restore session from 3-file minimal checkpoint (tasks.md, notes.md, session_summary.md)
internal: true
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
---

# /lite-resume — 从 3 文件恢复 (v4.2.0 统一命名)

## 命令格式

```bash
/lite-resume            # 从 .agent/context/ 恢复
lite-resume             # 简写
简单恢复                 # 中文
继续 lite               # 中文
```

## 目的

从 Lite Mode 的 3 个文件恢复上下文，并**自动开始执行**下一个任务。

核心：**Read Before Decide** — 先读取 tasks.md，将目标刷新到注意力窗口。

**v4.2.0 变更**：文件位置统一到 `.agent/context/`，与 Full Mode 共享目录。

## 执行流程

### Step 1: 读取 .agent/context/tasks.md (最重要!)

```bash
# 这是核心步骤 - 将目标刷新到注意力窗口
Read .agent/context/tasks.md
```

提取：
- Goal（目标）
- 当前 Phase
- 未完成的 checkbox
- Status（当前状态）

### Step 2: 读取 .agent/context/notes.md

```bash
Read .agent/context/notes.md
```

提取：
- 已有的研究发现
- 做出的决策

### Step 3: 读取 .agent/context/session_summary.md (如果存在)

```bash
if [ -f ".agent/context/session_summary.md" ]; then
  Read .agent/context/session_summary.md
fi
```

提取：
- 上次 session 的进度
- Next Steps

### Step 4: 输出恢复报告

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Lite Mode Resume
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Location: .agent/context/

🎯 Goal: {从 tasks.md 提取}

📊 Progress:
  Phase 1: ✅ Completed
  Phase 2: 🔄 In Progress (CURRENT)
  Phase 3: ⏳ Pending
  Phase 4: ⏳ Pending

📝 Last Session:
  {从 session_summary.md 提取的摘要}

🎯 Next Action:
  {从 Status 或 Next Steps 提取}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Auto-starting...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 5: 自动开始执行

**关键**: `/lite-resume` 不仅显示信息，还**自动开始执行**下一个任务。

```
# 解析 tasks.md 中的第一个未完成 Phase
# 或解析 session_summary.md 中的 Next Steps
# 自动开始执行
```

## 详细输出格式

### 成功恢复

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Lite Mode Resume
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Location: .agent/context/

Files Found:
  ✅ tasks.md
  ✅ notes.md
  ✅ session_summary.md

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 Goal: Research TypeScript best practices and create summary

📊 Progress:
  ✅ Phase 1: Plan and setup
  🔄 Phase 2: Research/gather information (CURRENT)
  ⏳ Phase 3: Execute/build
  ⏳ Phase 4: Review and deliver

📝 From Last Session:
  - Completed initial research
  - Found 3 good sources
  - Started notes

🎯 Current Status:
  **Currently in Phase 2** - Gathering more sources

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Auto-starting Phase 2...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Claude 继续执行 Phase 2 的研究工作...]
```

### 部分文件存在

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Lite Mode Resume (Partial)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Location: .agent/context/

Files Found:
  ✅ tasks.md
  ⚠️ notes.md (not found - will create)
  ⚠️ session_summary.md (not found)

Continuing from tasks.md only...

🎯 Goal: {goal}
📍 Status: {status}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Auto-starting...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 无文件可恢复

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ No Lite Mode Files Found
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Looked for in .agent/context/:
  ❌ tasks.md
  ❌ notes.md
  ❌ session_summary.md

Suggestions:
1. Run /lite-save first to create the files
2. Or run /ai:session-resume for Full Mode
3. Or describe your task to start fresh

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 核心原则

> **Read Before Decide**
>
> `/lite-resume` 的第一步是读取 tasks.md。
> 这将目标刷新到上下文末端，获得最高注意力权重。
> 然后再开始执行，确保不会偏离目标。

## 与 /ai:session-resume 的关系 (v4.2.0)

由于文件位置统一，两个命令现在可以互换使用：

| 特性 | /lite-resume | /ai:session-resume |
|------|-------------|-----------------|
| 读取位置 | .agent/context/ | .agent/context/ |
| 核心文件 | tasks.md, notes.md, session_summary.md | 同 + next_steps.md |
| 状态来源 | checkbox | state.json (如果有) |
| 适用场景 | 简单任务 | 复杂项目 |
| ai-dev 集成 | 检测并建议升级 | 完整集成 |

**兼容性**：
- `/ai:session-resume` 如果没有检测到 ai-dev 状态，会回退到 Lite Mode 行为
- `/lite-resume` 如果检测到 ai-dev 状态，会建议使用 `/ai:session-resume`

## 示例

```
用户: "/lite-resume"

Claude 执行:
📖 Reading .agent/context/tasks.md...
  Goal: Research TypeScript best practices
  Phase: 2 (Research)
  Status: Gathering sources

📖 Reading .agent/context/notes.md...
  Found: 3 sources, 5 key findings

📖 Reading .agent/context/session_summary.md...
  Last session: 2025-01-09
  Next: Continue research on advanced types

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Lite Mode Resume
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Location: .agent/context/

🎯 Goal: Research TypeScript best practices

📊 Progress: Phase 2/4 | 1 phase done

🎯 Next: Continue research on advanced types

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🚀 Auto-starting...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

[Claude 开始研究 TypeScript advanced types...]
```

## 4 步循环恢复

Lite Mode 遵循 Manus 的 4 步循环：

```
Loop 1: Create → 创建 tasks.md
Loop 2: Research → 更新 notes.md
Loop 3: Build → 创建交付物
Loop 4: Deliver → 完成任务
```

`/lite-resume` 会：
1. 读取 tasks.md 确定当前在哪个 Loop
2. 读取 notes.md 恢复研究上下文
3. 自动继续当前 Loop 的工作

## 从 Lite Mode 检测到 Full Mode

如果检测到 `.agent/changes/active/` 目录存在 state.json：

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📦 Lite Mode Resume
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

⚠️ Detected ai-dev workflow state

Found:
  - .agent/context/tasks.md (Lite Mode)
  - .agent/changes/active/001/state.json (Full Mode)

Recommendation:
  Use /ai:session-resume for Full Mode features
  Or continue with /lite-resume for simple mode

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
