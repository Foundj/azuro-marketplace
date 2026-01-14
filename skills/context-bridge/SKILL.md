---
name: context-bridge
version: 5.0.8
description: |
  This skill should be used when managing cross-session context and in-session attention.
  Implements Manus "Read Before Decide" pattern. Auto Checkpoint at 90% context.

  **TRIGGERS**: save, resume, focus, progress, lite-save, checkpoint, 保存, 恢复, 继续, 存档, 进度, 上下文, 会话管理, 断点续传

  **Usage**: /focus (refresh goals), /session:save (checkpoint), /session:resume (continue),
  /lite-save (3-file save), /lite-resume (3-file restore), /progress (show status)
triggers:
  - save
  - resume
  - focus
  - progress
  - checkpoint
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
| **85%** | ⚠️ 警告保存 | 提示 `/session:save` |
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

### `/session:save` - 保存进度

执行步骤：
1. 扫描 active changes 状态
2. 收集本次 session 完成的工作
3. 生成 `codebox/context/session_summary.md`
4. 更新 `codebox/context/next_steps.md`
5. 归档历史 session

### `/session:resume` - 恢复并继续

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
| `/session:save` | 保存 session 进度 | Session 结束时 |
| `/session:resume` | 恢复并自动继续 | 新 Session 开始时 |
| `/lite-save` | 3 文件极简保存 | 简单任务 |
| `/lite-resume` | 从 3 文件恢复 | 简单任务 |

---

## 💡 最佳实践

✅ **推荐**：
- 每个 session 结束前运行 `/session:save`
- 新 session 开始时直接 `/session:resume`
- 遇到复杂问题时保存思路

❌ **避免**：
- 不保存就关闭 session
- 手动编辑 context 文件

---

## 📖 详细参考

- [templates.md](references/templates.md) - 完整模板
- [implementation.md](references/implementation.md) - 实现细节
- [hooks-guide.md](references/hooks-guide.md) - Hook 配置指南

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
