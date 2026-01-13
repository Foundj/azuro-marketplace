# Azuro 插件市场

[English](./README.md)

Azuro 是一个 Claude Code 插件市场，提供工业级的 AI 开发工具和工作流自动化扩展。

## 快速开始

### 1. 安装市场

```bash
# 从 GitHub
/plugin marketplace add Foundj/azuro-marketplace
```

### 2. 浏览并安装插件

```bash
# 浏览可用插件
/plugin

# 安装全量套件（推荐）
/plugin install ai-dev@azuro-marketplace

# 或安装特定独立插件
/plugin install context-bridge@azuro-marketplace
/plugin install skills-audit-toolkit@azuro-marketplace
```

### 3. 市场管理

```bash
# 更新市场（获取最新版本）
/plugin marketplace update azuro-marketplace

# 移除市场
/plugin marketplace remove azuro-marketplace

# 查看已安装插件
/plugin list
```

## 可用插件

**插件关系：**
- **ai-dev** 是完整套件，包含所有 skills、commands、agents 和 hooks
- 其他插件（context-bridge、skills-audit-toolkit 等）是针对特定功能的独立替代方案
- 安装 ai-dev 即包含所有功能，无需单独安装其他插件

<!-- BEGIN_PLUGIN_TABLE -->
| 插件 | 版本 | 描述 |
|------|------|------|
| **ai-dev** | 4.2.6 | Industrial-grade AI development orchestration with 7-phase gated workflow, OODA autonomous completion, knowledge management, and project context awareness |
| **self-learning** | 4.2.6 | Self-learning system that captures corrections during sessions and updates your project conventions |
| **thinking-toolbox** | 4.2.6 | Advanced reasoning and chain-of-thought engine for complex problem solving |
| **context-bridge** | 4.2.6 | Cross-session context management - save progress, restore and auto-continue tasks. Bridges Manus 3-file pattern with Azuro 7-phase workflow |
<!-- END_PLUGIN_TABLE -->

## 主插件 (ai-dev) 功能

### 核心命令

| 命令 | 描述 |
|------|------|
| `/ai:dev` | 启动 AI 开发工作流 (Phase 0-6) |
| `/ai:loop` | OODA 自主执行循环 |
| `/ai:auto` | 自动完成当前变更中的剩余任务 |
| `/ai:status` | 查看项目健康状况和代理进度 |
| `/ai:fix` | 带验证循环的智能 Bug 修复 |
| `/ai:review` | 多维度代码审查 |
| `/ai:skills-audit` | 专业技能质量验证 |

### 专业代理 (24个)

- **架构**: `code-architect`, `backend-architect`, `frontend-developer`
- **质量**: `code-reviewer`, `quality-guardian`, `confidence-scorer`
- **开发**: `javascript-pro`, `typescript-pro`, `quick-fixer`
- **调试**: `debugger`, `error-detective`, `project-doctor`
- **规划**: `requirement-analyzer`, `feature-planner`, `task-decomposer`

### 代理技能 (9个)

- `thinking-engine`: 思维链推理逻辑
- `claude-reflect`: 自学习反思系统
- `competitor-research`: 竞品分析工具
- `knowledge-graph`: 解决方案持久化
- `skill-auditor`: 专业审计工具

## 目录结构

本项目遵循 Claude Code 插件官方标准结构：

```
azuro-marketplace/
├── .claude-plugin/            # 市场配置
│   └── marketplace.json
├── agents/                    # 代理定义（标准位置）
├── commands/                  # 斜杠命令定义（标准位置）
├── hooks/                     # 事件钩子及脚本（标准位置）
│   ├── hooks.json
│   └── scripts/
├── skills/                    # 代理技能（隔离）
├── components/scripts/        # 内部工具脚本
├── docs/                      # 官方文档参考
└── README.md
```

## 开发指南

### 版本管理

市场强制执行版本门禁。在任何提交之前，你必须递增 `.claude-plugin/marketplace.json` 中的版本：

```bash
bash hooks/scripts/bump.sh patch   # patch: x.x.X
bash hooks/scripts/bump.sh minor   # minor: x.X.0
bash hooks/scripts/bump.sh major   # major: X.0.0
```

### 质量门禁

任何评分低于 80 的技能都将阻止提交。请手动运行审计：

```bash
/ai:skills-audit
```

## 许可证

MIT License | **作者**: [foundj](https://github.com/Foundj)
