# Azuro 插件市场

[English](./README.md)

Azuro 是一个 Claude Code 插件市场，提供工业级的 AI 开发工具和工作流自动化扩展。

## 快速开始

### Claude Code

```bash
# 从 GitHub
/plugin marketplace add Foundj/azuro-marketplace
```

### Codex

告诉 Codex：
```
Fetch and follow instructions from https://raw.githubusercontent.com/Foundj/azuro-marketplace/refs/heads/main/.codex/INSTALL.md
```
**详细文档:** [.codex/INSTALL.md](.codex/INSTALL.md)

### OpenCode

告诉 OpenCode：
```
Fetch and follow instructions from https://raw.githubusercontent.com/Foundj/azuro-marketplace/refs/heads/main/.opencode/INSTALL.md
```
**详细文档:** [.opencode/INSTALL.md](.opencode/INSTALL.md)

---

### 浏览并安装插件 (Claude Code)

```bash
# 浏览可用插件
/plugin

# 安装全量套件（推荐）
/plugin install ai-dev@azuro-marketplace

# 或安装特定独立插件
/plugin install context-bridge@azuro-marketplace
/plugin install skills-audit-toolkit@azuro-marketplace
```

### 市场管理 (Claude Code)

```bash
# 更新市场（获取最新版本）
/plugin marketplace update azuro-marketplace

# 移除市场
/plugin marketplace remove azuro-marketplace

# 查看已安装插件
/plugin list
```

## AI 代理使用指南

### 直接对话

最简单的方式 - 直接告诉 Claude 你想要什么：

> "为我的应用实现用户认证"
> "修复登录按钮的 bug"
> "审查我的代码安全问题"

Claude 会自动使用市场中合适的技能和代理。

### 核心命令

| 命令 | 功能 |
|------|------|
| `/ai:dev <功能>` | 完整 7 阶段开发工作流 |
| `/ai:fix <bug>` | 带验证的快速 bug 修复 |
| `/ai:status` | 查看项目进度 |

### CLAUDE.md 集成

为了获得更一致的结果，将以下内容添加到项目的 CLAUDE.md：

```markdown
## AI 开发

使用 `/ai:dev` 进行功能开发。使用 `/ai:status` 查看进度。

核心工作流：
1. `/ai:dev "功能名称"` - 启动开发
2. 回答访谈问题
3. 审核设计方案
4. 让 AI 实现和验证
```

## 可用插件

**插件关系：**
- **ai-dev** 是完整套件，包含所有 skills、commands、agents 和 hooks
- 其他插件（context-bridge、skills-audit-toolkit 等）是针对特定功能的独立替代方案
- 安装 ai-dev 即包含所有功能，无需单独安装其他插件

<!-- BEGIN_PLUGIN_TABLE -->
| 插件 | 版本 | 描述 |
|------|------|------|
| **ai-dev** | 5.0.17 | Industrial-grade AI development orchestration with 7-phase gated workflow, OODA autonomous completion, knowledge management, and project context awareness |
| **self-learning** | 5.0.17 | Self-learning system that captures corrections during sessions and updates your project conventions |
| **thinking-toolbox** | 5.0.17 | Advanced reasoning and chain-of-thought engine for complex problem solving |
| **context-bridge** | 5.0.17 | Cross-session context management - save progress, restore and auto-continue tasks. Bridges Manus 3-file pattern with Azuro 7-phase workflow |
<!-- END_PLUGIN_TABLE -->

## 主插件 (ai-dev) 功能

### 核心命令

| 命令 | 描述 |
|------|------|
| `/ai:dev` | 启动 AI 开发工作流 (Phase 0-6) |
| `/ai:fix` | 带验证循环的智能 Bug 修复 |
| `/ai:status` | 查看项目健康状况和代理进度 |
| `/ai:session-save` | 保存当前会话进度和上下文 |
| `/ai:session-resume` | 恢复并继续之前的会话 |
| `/ai:skills-audit` | 专业技能质量验证 |
| `/ai:test-web` | Web 自动化和浏览器集成测试 |

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
├── scripts/                   # 内部工具脚本
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
