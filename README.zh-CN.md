# Azuro Marketplace

[English](./README.md)

Azuro 是一个 Claude Code 插件市场，提供 AI 开发工具和工作流自动化扩展。

## 快速开始

### 安装 Marketplace

```bash
# 通过 GitHub
/plugin marketplace add Foundj/azuro-marketplace
```

### 安装插件

```bash
/plugin install ai-dev@azuro
```

## 可用插件

| 插件 | 版本 | 描述 |
|------|------|------|
| [ai-dev](./ai-dev-plugin/) | 3.2.0 | 工业级 AI 开发编排系统，包含 7 阶段工作流、OODA 自主循环、知识管理 |

## ai-dev 插件功能

### 命令 (25个)

| 命令 | 描述 |
|------|------|
| `/ai:dev` | 主入口 - 启动 AI 开发工作流 |
| `/ai:loop` | OODA 自主循环 |
| `/ai:auto` | 自动模式开发 |
| `/ai:check` | 代码检查 |
| `/ai:fix` | 快速修复 |
| `/ai:review` | 代码审查 |
| `/ai:design` | 设计阶段 |
| `/ai:implement` | 实现阶段 |
| `/ai:research` | 研究模式 |
| `/ai:interview` | 需求访谈 |
| `/ai:status` | 状态查看 |
| `/ai:archive` | 归档变更 |
| `/ai:update-constraints` | 更新约束 |
| `/ai:update-feature-index` | 更新功能索引 |
| `/skill-audit` | 审计项目所有技能 |
| `/skill-audit:one` | 审计单个技能 |
| `/dev` | 快捷开发命令 |
| `/fix` | 快捷修复命令 |
| `/research` | 快捷研究命令 |
| `/progress` | 进度查看 |
| `/feature-list` | 功能列表 |
| `/feature-show` | 显示功能详情 |
| `/feature-resume` | 恢复功能开发 |
| `/feature-archive` | 归档功能 |

### Agents (24个)

专业化代理，支持不同开发任务：

- **架构类**: code-architect, backend-architect, frontend-developer
- **质量类**: code-reviewer, quality-guardian, confidence-scorer
- **开发类**: javascript-pro, typescript-pro, quick-fixer
- **调试类**: debugger, error-detective, project-doctor
- **规划类**: feature-planner, task-decomposer, requirement-analyzer
- **测试类**: test-automator
- **其他**: api-helper, code-explorer, code-mentor, master-controller, ooda-manager, sprint-manager, task-orchestrator

### Skills (6个)

| Skill | 描述 |
|-------|------|
| ai-dev | 核心 AI 开发技能，7 阶段工作流 |
| claude-reflect | 会话学习和反思系统 |
| project-initializer | 项目初始化和长期开发模式 |
| session-manager | 会话管理和上下文恢复 |
| competitor-research | 竞品研究 |
| skill-auditor | 技能质量审计和验证 |

## 目录结构

```
azuro-marketplace/
├── .claude-plugin/
│   └── marketplace.json      # Marketplace 清单
├── ai-dev-plugin/            # AI Dev 插件
│   ├── .claude-plugin/
│   │   └── plugin.json       # 插件清单
│   ├── commands/             # 25 个命令
│   ├── agents/               # 24 个 agents
│   ├── skills/               # 6 个 skills
│   ├── hooks/                # 钩子配置
│   └── scripts/              # 自动化脚本
└── README.md
```

## 开发指南

### 添加新插件

1. 在 `azuro-marketplace/` 下创建插件目录
2. 创建 `.claude-plugin/plugin.json`
3. 添加 commands/, agents/, skills/ 等组件
4. 更新根目录的 `marketplace.json`

### 本地测试

```bash
# 添加本地 marketplace
/plugin marketplace add /path/to/azuro-marketplace

# 安装插件测试
/plugin install ai-dev@azuro

# 重启 Claude Code 生效
```

## 官方文档

- [插件](https://code.claude.com/docs/zh-CN/plugins)
- [插件市场](https://code.claude.com/docs/zh-CN/plugin-marketplaces)
- [插件参考](https://code.claude.com/docs/zh-CN/plugins-reference)
- [斜杠命令](https://code.claude.com/docs/zh-CN/slash-commands)
- [子代理](https://code.claude.com/docs/zh-CN/sub-agents)
- [Agent Skills](https://code.claude.com/docs/zh-CN/skills)
- [Hooks](https://code.claude.com/docs/zh-CN/hooks)
- [MCP](https://code.claude.com/docs/zh-CN/mcp)

## 许可证

MIT License

## 作者

foundj - https://github.com/Foundj
