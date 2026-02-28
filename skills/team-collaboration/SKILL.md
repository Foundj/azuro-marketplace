---
name: team-collaboration
description: |
  This skill should be used when the user wants to set up multi-agent team collaboration.
  It provides scenario templates, team configuration guides, and collaboration best practices
  using Claude Code native Agent Teams capabilities. Use when the user mentions "团队协作",
  "team collaboration", "多代理", "并行开发", "agent teams", or wants parallel development.
version: 5.3.2
status: ga
triggers:
  - team collaboration
  - 团队协作
  - agent teams
  - 多代理协作
  - 并行开发
---

# Team Collaboration Skill

> **核心原则**: 使用 Claude Code 原生 Agent Teams 实现多代理协作，让复杂任务变得简单。

## 快速开始

```
"创建一个团队并行开发用户认证功能：
- 前端做登录页面
- 后端做认证API
- 测试工程师写测试"
```

**系统自动完成团队配置和执行!**

## 场景模板库

| 场景 | 触发词 | 团队组成 |
|------|--------|----------|
| 功能开发 | "功能", "feature" | 前端 + 后端 + 测试 |
| 代码审查 | "审查", "review" | 安全 + 性能 + 风格 |
| 问题调查 | "调查", "debug" | 错误追踪 + 代码探索 + 根因分析 |
| 架构设计 | "架构", "architecture" | 架构师 + 安全专家 + 技术顾问 |

## 团队创建流程

```
Step 1: TeamCreate - 创建团队
Step 2: Task (spawn teammates) - 生成队友
Step 3: TaskCreate - 创建任务
Step 4: TaskUpdate - 监控执行
Step 5: TeamDelete - 完成闭环
```

## 最佳实践

| 维度 | 建议 |
|------|------|
| 团队规模 | 2-5 个队友 |
| 文件隔离 | 每个队友有独立 fileScope |
| 通信策略 | 单播优先，广播慎用 |
| 任务粒度 | 每个任务 2-5 分钟 |

## Common Pitfalls

### Pitfall 1: 团队过大

**症状**: 创建 5+ 个队友处理简单任务
**后果**: 通信开销超过并行收益，任务协调混乱，idle 通知频繁干扰主流程
**修正**: 保持 2-3 人团队。只有明确独立的工作单元才增加队友

### Pitfall 2: 文件作用域重叠

**症状**: 多个队友修改同一文件（如都修改 `src/index.ts`）
**后果**: 合并冲突、覆盖彼此的更改，最终结果不可预测
**修正**: 每个队友分配独立的 `fileScope`，确保无重叠。共享文件由单一队友负责

### Pitfall 3: 缺少任务依赖定义

**症状**: 所有任务同时启动，不考虑先后顺序
**后果**: 依赖前置任务的队友因缺少上下文而产出错误结果（如测试先于实现启动）
**修正**: 使用 `blockedBy` 定义依赖关系，按波次（Wave）调度任务

### Pitfall 4: 用广播代替单播

**症状**: 每条消息都用 `broadcast` 发送给全部队友
**后果**: 每个队友都被唤醒处理不相关消息，浪费 API 资源和上下文窗口
**修正**: 默认使用 `message`（单播），仅在阻塞性问题需要全员注意时才广播

## 相关命令

- `/ai:team` - 团队协作开发入口
- `/ai:team review` - 团队代码审查
- `/ai:dev --team` - 混合模式

## References

- **[templates.md](references/templates.md)** - 场景模板库详细配置

## 版本历史

| Version | Changes |
|---------|---------|
| 5.2.4 | Split detailed docs to references/ |
| 1.0.0 | 初始版本 |