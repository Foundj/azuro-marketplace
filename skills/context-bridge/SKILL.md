---
name: context-bridge
version: 6.0.18
status: ga
profile: default
description: |
  This skill should be used when managing cross-session context and in-session attention.
  Implements Manus "Read Before Decide" pattern. Auto Checkpoint at 90% context.

  **TRIGGERS**: save, resume, focus, progress, lite-save, 保存, 恢复, 继续, 存档, 进度, 上下文, 会话管理, 断点续传

  **Usage**: /focus (refresh goals), /ai:session-save (save progress), /ai:session-resume (continue),
  /lite-save (3-file save), /lite-resume (3-file restore), /progress (show status)

  <example>
  Context: User is about to end a long development session and wants to save progress
  user: "今天先到这吧，帮我保存一下进度，明天继续"
  assistant: "I'll use the context-bridge skill to save your session progress, generate a summary, and create next_steps.md for tomorrow's session."
  <commentary>
  User wanting to save progress before ending a session ("保存进度", "明天继续") triggers the session-save workflow.
  </commentary>
  </example>

  <example>
  Context: User starts a new session and wants to continue from where they left off
  user: "resume 昨天的工作，我们昨天做到哪了？"
  assistant: "I'll use the context-bridge skill to restore your previous session context and show the progress report."
  <commentary>
  "resume" combined with wanting to continue previous work triggers the session-resume flow.
  </commentary>
  </example>

  <example>
  Context: During a long conversation, user feels the agent is losing focus on the original goal
  user: "感觉你跑偏了，focus 一下，我们的目标是什么来着？"
  assistant: "I'll use the context-bridge skill to refresh the current goal into the attention window and show the progress status."
  <commentary>
  User requesting focus refresh when attention drifts triggers the /focus command to re-inject goals.
  </commentary>
  </example>
triggers:
  - save
  - resume
  - focus
  - progress
  - lite-save
  - lite-resume
  - 保存
  - 恢复
  - 继续
  - 存档
  - 进度
  - 上下文
  - 会话管理
  - 断点续传
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
---

# Context Bridge - 注意力管理器

> **保存当前进度 → 刷新目标焦点 → 新 Session 无缝继续。**

## 触发词

此技能触发于: "save", "resume", "focus", "保存", "恢复", "继续", "存档", "进度".

---

## 🧠 核心原则: Read Before Decide

在长对话中，原始目标会被 "遗忘"（Lost in the Middle 问题）。
解决方案：在重大决策前，重新读取目标文件，将目标刷新到注意力窗口末端。

### 何时刷新注意力

| 场景 | 动作 |
|------|------|
| 开始新 Phase 前 | Read `proposal.md` 或 `design.md` |
| OODA 每次迭代 | Read `tasks.md` |
| 重大架构决策前 | Read `requirements.md` + `design.md` |
| 上下文超过 50% | 运行 `/focus` |

---

## 🔄 Auto Checkpoint 机制

| 阈值 | 动作 | 说明 |
|------|------|------|
| **70%** | 💡 建议 `/focus` | 刷新目标 |
| **85%** | ⚠️ 警告保存 | 提示 `/ai:session-save` |
| **90%** | 🔴 自动保存 | Auto Checkpoint + 提示 /clear |

---

## ⚡ 核心命令

### `/focus` - 刷新目标

快速将目标刷新到注意力窗口末端：

```
━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Focus Refresh
━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Current Goal: Implement user auth
📊 Progress: 5/7 tasks completed
🔴 P0: Fix 4 failing tests
🟡 P1: Complete integration tests
━━━━━━━━━━━━━━━━━━━━━━━━━
```

### `/progress` - 显示详细进度

显示 Progress Check 详细报告。

### `/ai:session-save` - 保存进度

执行步骤：
1. 扫描 active changes 状态
2. 收集本次 session 完成的工作
3. 生成 `codebox/context/session_summary.md`
4. 更新 `codebox/context/next_steps.md`
5. 归档历史 session

### `/ai:session-resume` - 恢复并继续

执行步骤：
1. 读取 `next_steps.md` 和 `session_summary.md`
2. 验证 active changes 状态
3. 显示恢复报告
4. **自动开始执行第一个 P0 任务**

---

## 🔀 双模式架构

Context Bridge 自动检测当前环境：

| 模式 | 检测条件 | 特性 |
|------|----------|------|
| **Mode A: ai-dev** | `codebox/changes/active/*/state.json` 存在 | 读取 state.json, tasks.md, 7-Phase 集成 |
| **Mode B: 独立** | 无 codebox 或无 active changes | 从对话 + git 收集信息 |

两种模式统一输出到 `codebox/context/` 目录。

---

## 📁 文件结构

```
codebox/context/
├── session_summary.md    # 上次 session 摘要
├── next_steps.md         # 下一步任务 (新 session 入口)
├── current_focus.md      # 当前焦点 (可选)
└── sessions/             # 历史 session 归档
```

---

## 📦 Lite Mode — 3 文件极简模式

适用于简单任务、快速项目。

### 命令

| 命令 | 作用 |
|------|------|
| `/lite-save` | 生成 3 文件到 `codebox/context/` |
| `/lite-resume` | 从 3 文件恢复 |

### 3 文件结构

```
codebox/context/
├── tasks.md              # 任务进度
├── notes.md              # 研究笔记
└── session_summary.md    # Session 摘要
```

### Lite vs Full 对比

| 特性 | Lite Mode | Full Mode |
|------|-----------|-----------|
| 文件数 | 3 个 | 15+ 个 |
| 状态追踪 | checkbox | state.json |
| 工作流 | 4 步循环 | 7 阶段 + OODA |
| 适用场景 | 简单任务 | 复杂功能 |

---

## 📚 完整命令列表

| 命令 | 作用 | 场景 |
|------|------|------|
| `/focus` | 刷新目标到注意力窗口 | 随时可用 |
| `/progress` | 显示详细进度 | 检查状态 |
| `/ai:session-save` | 保存 session 进度 | Session 结束时 |
| `/ai:session-resume` | 恢复并自动继续 | 新 Session 开始时 |
| `/lite-save` | 3 文件极简保存 | 简单任务 |
| `/lite-resume` | 从 3 文件恢复 | 简单任务 |

---

## Common Pitfalls

### Pitfall 1: 频繁保存导致上下文文件膨胀

**症状**: 每完成一个小任务就 `/ai:session-save`
**后果**: session_summary.md 累积大量冗余信息，恢复时加载缓慢
**修正**: 在逻辑断点保存（完成一个 Phase、解决一个阻塞问题），而非每个小任务

### Pitfall 2: 恢复时不验证环境状态

**症状**: `/ai:session-resume` 后直接开始编码
**后果**: 依赖缺失、分支不对、测试基线已变化
**修正**: 恢复流程中包含环境验证：git status + npm test + 分支确认

### Pitfall 3: 手动编辑 context 文件

**症状**: 直接修改 next_steps.md 调整优先级
**后果**: 格式损坏导致自动恢复失败
**修正**: 通过命令（/focus, /progress）管理上下文，不直接编辑生成的文件

---

## 💡 最佳实践

✅ **推荐**：
- 每个 session 结束前运行 `/ai:session-save`
- 新 session 开始时直接 `/ai:session-resume`
- 遇到复杂问题时保存思路

❌ **避免**：
- 不保存就关闭 session
- 手动编辑 context 文件

---

## 📖 详细参考

- [templates.md](references/templates.md) - 完整模板
- [implementation.md](references/implementation.md) - 实现细节
- [hooks-guide.md](references/hooks-guide.md) - Hook 配置指南
- [context-engineering.md](references/context-engineering.md) - 上下文工程原则 (Research→Plan→Reset→Implement)

---

## 🤝 Agent 协作

| 协作 Agent | 关系 |
|------------|------|
| `session-manager` | 完整恢复（环境验证 + 测试），context-bridge 负责轻量恢复 |
| `ai-dev` | 读取 7-Phase 状态，保存/恢复 OODA 进度 |
| `knowledge-graph` | 保存时提取 learnings，更新知识库 |

---

## 📋 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| 4.2.12 | 2026-01-14 | 精简 SKILL.md（减少 82%），移动详细内容到 references/ |
| 4.2.0 | 2026-01-10 | Auto Checkpoint, 统一 Lite Mode 命名 |
| 4.1.0 | 2025-01-10 | 注意力管理升级, /focus, /progress, Lite Mode |
| 4.0.0 | 2025-01-07 | 初始发布，Manus 模式集成 |

---

## 🎯 核心理念

> **Context Bridge 是注意力管理器**：
> - **保存时** — 生成目标摘要
> - **恢复时** — 刷新注意力
> - **执行中** — 周期性提醒目标

**LLM 的注意力会随着 context 增长而衰减，解决方案就是周期性地把目标重新注入到注意力窗口末端。**

这就是 **"Read Before Decide"** 的本质。
