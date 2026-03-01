---
name: session-manager
description: |
  This skill should be used when the user wants to manage development sessions and restore
  project context across multiple Claude sessions. It automatically recovers progress,
  validates state, and suggests next steps. Use when the user mentions "continue", "resume",
  "status", "progress", "恢复会话", "继续", "进度", or when starting a new session.
  Critical for long-running project continuity.

  <example>
  Context: User opens a new Claude session and wants to pick up where they left off
  user: "continue，上次做到哪了？帮我恢复一下项目状态"
  assistant: "I'll use the session-manager skill to recover your project context, check progress, and recommend the next task to work on."
  <commentary>
  Trigger word "continue" combined with "上次做到哪了" clearly indicates session recovery intent.
  </commentary>
  </example>

  <example>
  Context: User wants a quick status check on overall project progress
  user: "status check 一下，这个项目现在完成了百分之多少，还有哪些 feature 没做"
  assistant: "I'll use the session-manager skill to analyze feature_list.json and progress.txt, then report completion percentage and remaining work."
  <commentary>
  Trigger word "status" with progress inquiry activates the session manager's status analysis workflow.
  </commentary>
  </example>

  <example>
  Context: User returns after a long break and needs full context restoration
  user: "resume this project, I haven't touched it in 2 weeks. What's the current state and what should I work on next?"
  assistant: "I'll use the session-manager skill to run the full 7-step recovery sequence, validate the environment, and suggest the highest priority next task."
  <commentary>
  Trigger "resume" with explicit need for context restoration and next-step recommendation activates full recovery.
  </commentary>
  </example>
version: 6.0.13
status: ga
profile: default
allowed-tools: Read, Bash, Grep, Glob
model: sonnet
triggers:
  - continue
  - resume
  - restore
  - status
  - progress
  - where was I
  - what's next
  - 恢复会话
  - 继续
  - 进度
  - 上次做到哪了
---

# Session Manager - 会话管理系统

## 🎯 一句话说明

**智能恢复项目上下文，确保跨 session 的连续性，就像从未中断过。**

## ⚡ 快速使用

### 简短触发词 ⭐ 推荐
```bash
"continue"         # 最简单，恢复并继续
"resume"           # 同 continue
"status"           # 查看状态
"progress"         # 查看进度
"what's next"      # 推荐下一步
```

### 自然语言触发
```bash
"恢复项目继续工作"
"项目进度如何？"
"上次做到哪了？"
"下一步做什么？"
```

## 🧠 核心功能

### 7步智能启动序列

```
Step 1: 确认位置 (pwd)
Step 2: 读取进度 (progress.txt 最近 50 行)
Step 3: 读取特性 (feature_list.json)
Step 4: 检查 Git (git log, git status)
Step 5: 启动环境 (./init.sh)
Step 6: 运行测试 (smoke tests)
Step 7: 分析推荐 (下一个特性)
```

### 智能状态分析
- **完成率计算**：42/150 (28%)
- **当前特性识别**：Feature #43
- **下一步推荐**：基于依赖和优先级
- **剩余时间估算**：约 15 天

### 环境验证
- ✅ 启动 init.sh
- ✅ 运行 smoke 测试
- ✅ 检查依赖完整性
- ✅ 验证 Git 状态

### 自动归档管理
- `progress.txt > 2000 行` → 归档
- `feature_list.json > 500 特性` → 提醒拆分

## 📋 恢复报告格式

```markdown
📊 Session Recovery Report
==================
Total: 150 features
Completed: 42 (28%)
Active: 3
Staged: 5

🔄 Current Feature: #43
- Description: User authentication
- Phase: 4 (Implementation)
- Progress: 6/10 tasks

📌 Next Recommended: #44
- Reason: Priority HIGH, no blockers
- Estimated: 4 hours
```

## Common Pitfalls

### Pitfall 1: 不在项目目录就运行恢复

**症状**: 在错误目录运行 `continue`，找不到 codebox/ 文件
**后果**: 恢复失败或生成错误的上下文，进入错误的项目状态
**修正**: 恢复前确认 `pwd` 在正确的项目根目录

### Pitfall 2: 长时间不更新进度

**症状**: 连续完成多个特性但不更新 progress.txt 和 feature_list.json
**后果**: 下次恢复时显示过时的进度，推荐已完成的任务
**修正**: 每个特性完成后立即更新状态（或使用 ai-dev 自动追踪）

### Pitfall 3: 进度文件无限增长

**症状**: progress.txt 超过 2000 行、feature_list.json 超过 500 条
**后果**: 恢复加载缓慢，上下文窗口被历史信息占满
**修正**: 定期归档旧记录（保留最近 1000 行），或触发自动归档机制

## 💡 使用技巧

1. **每个 session 开始时运行**：`continue` 或 `resume`
2. **定期更新进度**：完成任务后更新 tasks.md
3. **保持 Git 干净**：定期 commit codebox/

## ❌ 常见错误

1. 不在项目目录就运行 ❌
2. 长时间不更新状态 ❌
3. 让文件无限增长 ❌

## 📊 文件大小管理

```bash
progress.txt > 2000 行 → 归档最老的 sessions
feature_list.json > 500 特性 → 建议拆分项目
```

归档策略：
- **progress.txt**: 保留最近 1000 行
- **feature_list.json**: 保留未完成 + 最近30天完成
- **archive/**: 自动归档旧内容

## 🔗 与其他系统协作

| Agent | Role |
|-------|------|
| `project-initializer` | Creates files session-manager reads |
| `ai-dev` | Provides feature context for recovery |
| `context-bridge` | Lightweight alternative for quick resume |

## 📚 详细参考

- **[enhanced-recovery.md](references/enhanced-recovery.md)** - v2.0 增强恢复流程 (7步→10步)
- **[troubleshooting.md](references/troubleshooting.md)** - 故障排除指南

## ❓ 故障排除

**恢复失败？**
- 确保在正确的项目目录
- 检查 codebox/ 目录存在
- 验证文件格式：`jq . feature_list.json`

**环境启动失败？**
- 检查 init.sh 可执行权限
- 手动运行并查看错误

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 5.2.4 | 2026-02-28 | Split detailed docs to references/ |
| 4.2.6 | 2026-01-13 | Add third-person description, triggers |
| 4.2.0 | 2026-01-07 | Add v2.0-enhanced support |
| 4.0.0 | 2026-01-01 | Initial release |

---

**核心理念**: 让每个新 session 的开始就像从未中断过。完美的上下文恢复 = 持续的生产力。