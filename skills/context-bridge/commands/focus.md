---
name: focus
description: Refresh current goals into attention window to combat Lost in the Middle problem
internal: true
allowed-tools: Read, Grep, Glob
---

# /focus — 目标焦点刷新命令

## 命令格式

```bash
/focus                  # 刷新目标到注意力窗口
focus                   # 简写
刷新目标                 # 中文
焦点                    # 中文简写
```

## 目的

**解决 "Lost in the Middle" 问题**：在长对话中，原始目标会被遗忘。
`/focus` 命令通过重新读取目标文件，将目标刷新到上下文末端，获得高注意力权重。

## 执行流程

### Step 1: 检测运行模式

```bash
# 优先级顺序检测目标文件
if [ -f ".agent/context/next_steps.md" ]; then
  MODE="full"
  FOCUS_FILE=".agent/context/next_steps.md"
elif [ -f "task_plan.md" ]; then
  MODE="lite"
  FOCUS_FILE="task_plan.md"
elif [ -f ".agent/context/current_focus.md" ]; then
  MODE="full"
  FOCUS_FILE=".agent/context/current_focus.md"
else
  # 无目标文件，从 ai-dev 状态提取
  MODE="ai-dev"
fi
```

### Step 2: 读取并解析目标

#### Full Mode (next_steps.md)

```bash
# 读取 next_steps.md
# 提取 P0 和 P1 任务
# 提取当前 Change 状态
```

#### Lite Mode (task_plan.md)

```bash
# 读取 task_plan.md
# 提取 Goal
# 提取当前 Phase 和 Status
# 提取未完成的 checkbox
```

#### AI-Dev Mode

```bash
# 扫描 .agent/changes/active/*/state.json
# 提取 currentPhase, ooda.iterationCount
# 读取 tasks.md 获取未完成任务
```

### Step 3: 输出 Focus Report

```
━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Focus Refresh
━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Current Goal: {goal}
📊 Progress: {completed}/{total} tasks
🔴 P0: {highest_priority_task}
🟡 P1: {next_priority_task}
━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 输出格式详解

### Full Mode 输出

```
━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Focus Refresh
━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Current Goal: Implement user authentication system
📊 Progress: 5/7 tasks completed
📁 Active Change: 001-user-auth (Phase 4, OODA 6/10)

🔴 P0 - Blocking:
   Fix 4 failing tests in AuthService.test.ts

🟡 P1 - Should Complete:
   Complete integration tests (Task 6)

🟢 P2 - Ready:
   API documentation (Task 7)
━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Lite Mode 输出

```
━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Focus Refresh (Lite Mode)
━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Goal: {从 task_plan.md 提取}
📍 Status: Phase 2 - Researching

Phases:
  ✅ Phase 1: Planning
  🔄 Phase 2: Research (CURRENT)
  ⏳ Phase 3: Build
  ⏳ Phase 4: Deliver

Next Action: {从 Status 部分提取}
━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 无目标文件时

```
━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ No Focus File Found
━━━━━━━━━━━━━━━━━━━━━━━━━
建议:
1. 运行 /ai:session-save 生成 next_steps.md
2. 或运行 /lite-save 生成 task_plan.md
3. 或描述当前目标，我来创建焦点文件
━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 核心原则

> **Read Before Decide**
>
> `/focus` 的本质是将目标文件的内容重新注入到当前上下文末端。
> 这利用了 LLM 注意力机制的特性：最近的内容获得最高的注意力权重。

## 何时使用

**推荐使用场景**：
- 上下文使用超过 50%
- 准备做重大决策前
- 感觉偏离目标时
- 完成一个主要任务后
- 连续工作超过 1 小时

**自动提示**：
当 context usage 超过 50% 时，系统会建议运行 `/focus`。

## 与其他命令的关系

| 命令 | 用途 | 频率 |
|------|------|------|
| `/focus` | 刷新目标（轻量） | 随时，频繁使用 |
| `/progress` | 详细进度报告 | 检查点，偶尔使用 |
| `/ai:session-save` | 完整保存 | Session 结束时 |

## 实现示例

```
用户: "/focus"

Claude 执行:
1. 检测到 .agent/context/next_steps.md 存在
2. 读取 next_steps.md
3. 解析 P0/P1/P2 任务
4. 输出 Focus Report

输出:
━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Focus Refresh
━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Current Goal: Implement user authentication
📊 Progress: 5/7 tasks completed

🔴 P0: Fix 4 failing tests in AuthService.test.ts
🟡 P1: Complete integration tests

[目标已刷新到注意力窗口]
━━━━━━━━━━━━━━━━━━━━━━━━━

然后 Claude 继续工作，此时目标在注意力焦点中。
```

## 技术说明

`/focus` 命令的核心作用是**将目标内容放置在上下文末端**。

这不是魔法，而是利用了 Transformer 注意力机制的位置偏差：
- 最近的 tokens 获得更高的注意力权重
- 通过 Read 操作，目标内容出现在最近的 tool result 中
- 后续决策自然会更多关注这些刷新的目标

这就是 Manus $2B 价值的秘密之一。
