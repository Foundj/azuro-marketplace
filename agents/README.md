# Agents 索引

> AI 开发工作流中的专业化代理定义

## 概述

本目录包含 21 个专业化 Agent，按职能分为以下类别：

## 核心协调

| Agent | 描述 | 触发场景 |
|-------|------|----------|
| [master-controller](master-controller.md) | 智能调度系统主控制器 | 任务自动分析和 Agent 编排 |
| [ooda-manager](ooda-manager.md) | OODA 循环管理器 | 快速迭代执行 |
| [sprint-manager](sprint-manager.md) | Sprint 周期管理 | 21天迭代规划 |

## 需求与规划

| Agent | 描述 | 触发场景 |
|-------|------|----------|
| [requirement-analyzer](requirement-analyzer.md) | 需求分析专家 | Phase 1 需求理解 |
| [task-orchestrator-v2](task-orchestrator-v2.md) | Sequential Thinking 版本 | 深度任务规划 |
| [task-decomposer](task-decomposer.md) | 任务分解专家 | 子任务拆分 |

## 架构与设计

| Agent | 描述 | 触发场景 |
|-------|------|----------|
| [code-architect](code-architect.md) | 实现方案设计 | Phase 3 方案设计 |
| [code-explorer](code-explorer.md) | 代码库探索 | Phase 2 资源发现 |
| [backend-architect](backend-architect.md) | 后端架构设计 | API/微服务/数据库设计 |

## 开发实现

| Agent | 描述 | 触发场景 |
|-------|------|----------|
| [frontend-developer](frontend-developer.md) | 前端开发专家 | React/UI 组件开发 |
| [api-helper](api-helper.md) | API 开发助手 | Hono/RESTful API 实现 |
| [javascript-pro](javascript-pro.md) | JavaScript 专家 | ES6+/Node.js 最佳实践 |
| [typescript-pro](typescript-pro.md) | TypeScript 专家 | 高级类型和类型安全 |

## 质量保障

| Agent | 描述 | 触发场景 |
|-------|------|----------|
| [code-reviewer](code-reviewer.md) | 代码审查专家 | Phase 5 代码审查 |
| [confidence-scorer](confidence-scorer.md) | 问题严重性评分 | 客观过滤审查结果 |
| [quality-guardian](quality-guardian.md) | 质量保障专家 | 全面质量检查 |
| [test-automator](test-automator.md) | 自动化测试专家 | 测试策略和覆盖率 |

## 调试与诊断

| Agent | 描述 | 触发场景 |
|-------|------|----------|
| [debugger](debugger.md) | 调试专家 (含根因分析) | 错误/测试失败时主动触发 |
| [project-doctor](project-doctor.md) | 项目健康诊断 | 配置/依赖/性能问题 |

## 辅助工具

| Agent | 描述 | 触发场景 |
|-------|------|----------|
| [code-mentor](code-mentor.md) | 代码指导专家 | 教学和能力提升 |
| [quick-fixer](quick-fixer.md) | 快速问题解决 | 简单 bug 修复 |

## 使用方式

Agents 通过 `Task` 工具调用：

```
Task tool with subagent_type: "ai-dev:code-reviewer"
```

或由 `master-controller` 自动编排。

## 与 Skills 的关系

- **Agents**: 执行具体任务的专业化代理
- **Skills**: 提供知识、流程和指导的技能包

Agents 可以被 Skills 调用，Skills 为 Agents 提供上下文知识。
