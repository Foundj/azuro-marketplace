---
name: team-collaboration
description: |
  Agent Teams 团队协作技能。提供场景模板库、团队配置指南、协作最佳实践。
  使用 Claude Code 原生 Agent Teams 能力实现多代理并行协作。
  触发词: "团队协作", "team collaboration", "多代理", "并行开发", "agent teams"
version: 5.2.7
status: experimental
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