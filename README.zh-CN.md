# Azuro 插件市场

[English](./README.md)

Azuro 是一个 Claude Code 插件市场，提供 AI 开发工具和工作流自动化扩展。

## 快速开始

### 安装市场

```bash
# 从 GitHub
/plugin marketplace add Foundj/azuro-marketplace
```

### 安装插件

```bash
/plugin install ai-dev@azuro-marketplace
```

## 可用插件

| 插件 | 版本 | 描述 |
|------|------|------|
| ai-dev | 3.4.9 | 工业级 AI 开发编排系统，包含 7 阶段工作流、OODA 自主循环、知识管理 |

## ai-dev 插件功能

### 命令 (27个)

| 命令 | 描述 |
|------|------|
| `/ai:dev` | 主入口 - 启动 AI 开发工作流 |
| `/ai:loop` | OODA 自主循环 |
| `/ai:auto` | 自动完成剩余任务 |
| `/ai:check` | 预实现检查 |
| `/ai:fix` | 快速修复 |
| `/ai:review` | 代码审查 |
| `/ai:design` | 设计阶段 |
| `/ai:implement` | 实现阶段 |
| `/ai:research` | 调研模式 |
| `/ai:interview` | 需求收集 |
| `/ai:status` | 查看状态 |
| `/ai:archive` | 归档变更 |
| `/ai:quality` | 质量门禁检查 |
| `/skill-audit` | 审计项目中所有技能 |
| `/skill-audit:one` | 审计单个技能 |
| `/dev` | 快速开发别名 |
| `/fix` | 快速修复别名 |
| `/research` | 快速调研别名 |

### 代理 (24个)

用于不同开发任务的专业代理：

- **架构**: code-architect, backend-architect, frontend-developer
- **质量**: code-reviewer, quality-guardian, confidence-scorer
- **开发**: javascript-pro, typescript-pro, quick-fixer
- **调试**: debugger, error-detective, project-doctor
- **规划**: feature-planner, task-decomposer, requirement-analyzer
- **测试**: test-automator

### 技能 (9个)

| 技能 | 描述 |
|------|------|
| ai-dev | 核心 AI 开发技能，7 阶段工作流 |
| claude-reflect | 会话学习和反思系统 |
| project-initializer | 项目初始化和长期开发模式 |
| session-manager | 会话管理和上下文恢复 |
| competitor-research | 竞品调研 |
| skill-auditor | 技能质量审计和验证 |
| thinking-engine | 扩展思考和推理 |
| knowledge-graph | 知识图谱管理 |
| quality-gate | 代码质量门禁检查 |

## 目录结构

```
azuro-marketplace/
├── .claude-plugin/
│   └── marketplace.json      # 市场清单（包含插件配置）
├── agents/                   # 24 个代理
├── commands/                 # 27 个命令
├── skills/                   # 9 个技能
├── hooks/                    # 钩子配置
├── scripts/                  # 工具脚本
├── docs/                     # 文档参考
├── bak/                      # 参考项目
└── README.md
```

## 开发指南

### 本地测试

```bash
# 添加本地市场
/plugin marketplace add /path/to/azuro-marketplace

# 安装插件进行测试
/plugin install ai-dev@azuro

# 重启 Claude Code 以应用
```

### 版本管理

```bash
# 提交前递增版本
bash hooks/scripts/bump.sh patch   # 3.4.0 → 3.4.1
bash hooks/scripts/bump.sh minor   # 3.4.0 → 3.5.0
bash hooks/scripts/bump.sh major   # 3.4.0 → 4.0.0
```

### 技能质量审计

```bash
# 审计单个技能
bash skills/skill-auditor/scripts/validate-skill.sh skills/<skill-name>

# 审计所有技能
for skill in skills/*/; do
  bash skills/skill-auditor/scripts/validate-skill.sh "$skill"
done
```

## 文档

- [插件](https://code.claude.com/docs/zh-CN/plugins)
- [插件市场](https://code.claude.com/docs/zh-CN/plugin-marketplaces)
- [插件参考](https://code.claude.com/docs/zh-CN/plugins-reference)

## 许可证

MIT License

## 作者

foundj - https://github.com/Foundj
