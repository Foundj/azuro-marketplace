# AGENTS.md - AI 开发指南

> AI 编码代理在本仓库工作时的规范指南。
始终中文回答

## 项目概述

**类型**: Claude Code 插件市场 (Professional Suite 模式)  
**技术栈**: Markdown + Bash + JSON

```
azuro-marketplace/
├── .claude-plugin/marketplace.json  # 市场配置
├── components/                      # 核心组件 (共享)
│   ├── agents/                      # Agent 定义
│   ├── commands/                    # 斜杠命令定义
│   ├── hooks/                       # 钩子配置及脚本
│   └── scripts/                     # 内部工具脚本
├── skills/                          # 代理技能 (隔离)
├── docs/                            # 官方文档
├── bak/                             # 参考实现
└── README.md
```

## 构建/测试命令

```bash
# 版本递增（每次提交前必须执行）
bash components/hooks/scripts/bump.sh patch

# 技能质量审计（单个）
bash skills/skill-auditor/scripts/validate-skill.sh skills/<skill-name>

# 验证脚本可执行
chmod +x components/hooks/scripts/*.sh components/scripts/*.sh
```

## 代码风格

### Frontmatter 必需字段

| 组件 | 必需字段 |
|-----|---------|
| Agent | `name`, `description`, `capabilities` |
| Skill | `name`, `description`, `version` |
| Command | `name`, `description`, `argument-hint`, `allowed-tools` |

### 命名约定

- **目录/文件**: kebab-case (`code-reviewer.md`)
- **命令文件**: 带冒号前缀 (`ai:dev.md`)
- **JSON 字段**: camelCase

## 质量要求

### 技能质量标准 (目标: 85+/100)

| 维度 | 权重 | 检查项 |
|-----|-----|--------|
| 结构 | 25% | SKILL.md 存在、frontmatter 完整 |
| 文档 | 25% | 第三人称描述 (≥200字)、代码示例 |
| 可发现性 | 20% | 触发词、命令绑定 |
| 可维护性 | 15% | 语义版本、脚本权限 |
| 集成 | 15% | 工作流集成、Agent 协作 |

## 版本控制

### Pre-commit Hook

项目已配置强制版本门禁和质量审计。提交前必须递增版本号并确保所有技能评分 ≥80。

```bash
bash components/hooks/scripts/bump.sh patch
```

### 提交格式

```
<type>(<scope>): <description>

示例:
feat(skills): add thinking-toolbox standalone plugin
fix(hooks): update script paths for new directory structure
```

## 重要约束

1. **勿修改** `bak/`、`docs/` 目录。
2. **勿直接在根目录创建组件** - 必须使用 `components/` 或 `skills/` 子目录。
3. **路径引用** - 在脚本中使用 `${CLAUDE_PLUGIN_ROOT}` 处理绝对路径。
4. **UTF-8 编码**, LF 换行符。

## 文档参考

开发 Skills 和 Plugins 时，请参考 `docs/` 目录下的文档：

| 文档 | 用途 |
|-----|------|
| **[skill-plugin-development-guide.md](docs/skill-plugin-development-guide.md)** | **核心开发指南** - 开发 Skills/Plugins 的权威指南，包含完整的结构模板、最佳实践、常见错误及修复方案。**开发前必读。** |
| [plugins.md](docs/plugins.md) | 官方插件教程 - 插件基础概念、创建流程、安装管理 |
| [plugins-reference.md](docs/plugins-reference.md) | 官方技术参考 - 完整的组件规范、清单模式、目录结构 |
| [plugin-marketplaces.md](docs/plugin-marketplaces.md) | 市场指南 - 创建和管理插件市场、分发插件 |

### 开发 Skills 快速参考

1. **必读**: `docs/skill-plugin-development-guide.md`
2. **结构**: 
   ```
   skills/skill-name/
   ├── SKILL.md          # 必需：核心技能文件
   ├── references/       # 可选：详细文档
   ├── examples/         # 可选：工作示例
   └── scripts/          # 可选：工具脚本
   ```
3. **Frontmatter**: 使用第三人称描述 + 具体触发短语
4. **正文**: 使用祈使句/不定式形式
5. **质量门禁**: 评分 ≥ 80 才能提交

## 调试

```bash
cat .claude-plugin/marketplace.json | jq .
claude --debug
```
