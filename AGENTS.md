# AGENTS.md - AI 开发指南

> AI 编码代理在本仓库工作时的规范指南。

## 项目概述

**类型**: Claude Code 插件市场 (模式 A - 单插件直接结构)  
**技术栈**: Markdown + Bash + JSON

```
azuro-marketplace/
├── .claude-plugin/marketplace.json  # 市场+插件配置合一
├── agents/              # Agent (24个)
├── commands/            # 命令 (27个)
├── skills/              # 技能 (9个)
├── hooks/               # 事件钩子
├── scripts/             # 工具脚本
├── docs/                # 官方文档（勿修改）
├── bak/                 # 参考项目（勿修改）
└── README.md
```

## 构建/测试命令

```bash
# 版本递增（每次提交前必须执行）
bash hooks/scripts/bump.sh patch   # 修复
bash hooks/scripts/bump.sh minor   # 新功能
bash hooks/scripts/bump.sh major   # 重大变更

# 技能质量审计（单个）
bash skills/skill-auditor/scripts/validate-skill.sh skills/<skill-name>

# 技能质量审计（全部）
for skill in skills/*/; do
  bash skills/skill-auditor/scripts/validate-skill.sh "$skill"
done

# 验证脚本可执行
chmod +x hooks/scripts/*.sh scripts/*.sh
```

## 代码风格

### Markdown 组件格式

```markdown
---
name: kebab-case-name
description: |
  第三人称描述（"此技能..."）
  **触发词**: keyword1, keyword2
version: x.x.x
---

# 标题
正文...
```

### Frontmatter 必需字段

| 组件 | 必需字段 |
|-----|---------|
| Agent | `name`, `description`, `tools`, `category` |
| Skill | `name`, `description`, `version` |
| Command | `description`, `argument-hint`, `allowed-tools` |

### 命名约定

- **目录/文件**: kebab-case (`code-reviewer.md`)
- **命令文件**: 带冒号前缀 (`ai:dev.md`)
- **函数名**: snake_case

### Shell 脚本规范

```bash
#!/bin/bash
set -euo pipefail  # 必须

RED='\033[0;31m'; GREEN='\033[0;32m'; NC='\033[0m'
log_info() { echo -e "${GREEN}✅ $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}" >&2; }

main() { ... }
main "$@"
```

## 质量要求

### 技能质量标准 (目标: 85+/100)

| 维度 | 权重 | 检查项 |
|-----|-----|--------|
| 结构 | 25% | SKILL.md存在、frontmatter完整、kebab-case目录 |
| 文档 | 25% | 第三人称描述(≥200字)、代码示例、<1000词 |
| 可发现性 | 20% | 触发词、命令绑定、同义词 |
| 可维护性 | 15% | 语义版本、依赖文档 |
| 集成 | 15% | 工作流集成、Agent协作 |

### 描述规范

```markdown
# ✅ 正确（第三人称）
description: 此技能帮助开发者分析代码质量...

# ❌ 错误
description: 我帮你分析...  # 第一人称
description: 你可以使用...  # 第二人称
```

## 版本控制

### Pre-commit Hook

项目已配置版本门禁，提交前必须递增版本号：

```bash
bash hooks/scripts/bump.sh patch
```

### 提交格式

```
<type>(<scope>): <description>

类型: fix | feat | docs | refactor | chore

示例:
fix(skills): improve thinking-engine quality score
feat(agents): add code-mentor agent
```

## 重要约束

1. **勿修改** `bak/`、`docs/` 目录
2. **勿跳过版本递增** - hook 会阻止
3. **勿用绝对路径** - 用 `${CLAUDE_PLUGIN_ROOT}`
4. **UTF-8 编码**, LF 换行符

## 工作流

### 添加 Agent
1. 创建 `agents/agent-name.md`
2. 添加 frontmatter
3. `bump.sh patch` → 提交

### 添加 Skill
1. 创建 `skills/skill-name/SKILL.md`
2. 运行审计确认 ≥85 分
3. `bump.sh patch` → 提交

### 添加 Command
1. 创建 `commands/namespace:action.md`
2. `bump.sh patch` → 提交

## 调试

```bash
cat .claude-plugin/marketplace.json | jq .  # 检查 JSON
head -20 skills/*/SKILL.md                  # 检查 frontmatter
ls {agents,skills,commands}/                # 列出组件
```
