# AGENTS.md - AI 开发指南

> AI 编码代理在本仓库工作时的规范指南。
始终中文回答

## 项目概述

**类型**: Claude Code 插件市场 (Professional Suite 模式)  
**技术栈**: Markdown + Bash + JSON

```
azuro-marketplace/
├── .claude-plugin/marketplace.json  # 市场配置
├── agents/                          # Agent 定义 (标准目录)
├── commands/                        # 斜杠命令定义 (标准目录)
├── hooks/                           # 钩子配置及脚本
│   ├── hooks.json
│   └── scripts/
├── components/                      # 内部工具脚本
│   └── scripts/
├── skills/                          # 代理技能 (隔离)
├── docs/                            # 官方文档
├── bak/                             # 参考实现
└── README.md
```

## 构建/测试命令

```bash
# 版本递增（每次提交前必须执行）
bash hooks/scripts/bump.sh patch

# 技能质量审计（单个）
bash skills/skill-auditor/scripts/validate-skill.sh skills/<skill-name>

# 验证脚本可执行
chmod +x hooks/scripts/*.sh scripts/*.sh
```

## 代码风格

### LSP 优先原则 (v5.0.9)

**代码导航始终优先使用 LSP 工具：**

| 任务 | 优先使用 (LSP) | 降级方案 |
|------|----------------|----------|
| 跳转定义 | `LSP.goToDefinition` | Grep |
| 查找引用 | `LSP.findReferences` | Grep |
| 获取类型 | `LSP.hover` | Read |
| 查找实现 | `LSP.goToImplementation` | Grep |
| 调用层次 | `LSP.incomingCalls/outgoingCalls` | 手动追踪 |

**示例：**
```typescript
// ✅ 推荐：使用 LSP 进行精确导航
LSP({ operation: "goToDefinition", filePath: "src/auth.ts", line: 45, character: 12 })

// ❌ 避免：用 Grep 进行符号导航（不够精确）
Grep({ pattern: "function verifyToken", path: "src/" })
```

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
bash hooks/scripts/bump.sh patch
```

### 提交格式

```
<type>(<scope>): <description>

示例:
feat(skills): add thinking-toolbox standalone plugin
fix(hooks): update script paths for new directory structure
```

## 行为标记系统

本项目支持统一的行为标记 (FLAGS)，详见 **[core/FLAGS.md](core/FLAGS.md)**：

| 标记 | 作用 |
|------|------|
| `--think` | 启用扩展思考模式 |
| `--ultrathink` | 最大思考预算 |
| `--quick` | 跳过非必要阶段 |
| `--parallel` | 启用并行执行 |
| `--safe` | 保守模式，更多确认 |

## Browser Automation

使用 `agent-browser` 进行 Web 自动化测试。运行 `agent-browser --help` 查看所有命令。

**核心工作流**:
1. `agent-browser open <url>` - 打开页面
2. `agent-browser snapshot -i` - 获取可交互元素（带 ref 如 @e1, @e2）
3. `agent-browser click @e1` / `fill @e2 "text"` - 使用 ref 交互
4. 页面变化后重新 snapshot

**常用命令**:
```bash
agent-browser open https://example.com     # 打开页面
agent-browser snapshot -i                   # 获取元素列表
agent-browser click @e1                     # 点击元素
agent-browser fill @e2 "text"               # 填写输入框
agent-browser screenshot result.png         # 截图
agent-browser state save auth.json          # 保存登录状态
```

详见 [skills/agent-browser/SKILL.md](skills/agent-browser/SKILL.md)

## 重要约束

1. **勿修改** `bak/`、`docs/` 目录。
2. **组件位置** - agents/、commands/、hooks/、skills/ 在根目录（符合官方标准结构）。
3. **路径引用** - 在脚本中使用 `${CLAUDE_PLUGIN_ROOT}` 处理绝对路径。
4. **UTF-8 编码**, LF 换行符。

## Marketplace 设计原则 (v5.2.0)

遵循 superpowers 设计理念：**用户只需自然对话，技能自动激活**。

### 用户入口

marketplace.json 仅注册用户可见入口：

| 类型 | 数量 | 内容 |
|------|------|------|
| 技能 | 2 | ai-dev (编排), agent-browser (自动化) |
| 命令 | 6 | ai:dev, ai:fix, ai:status, ai:team, ai:session-save, ai:session-resume |

### 内部技能/命令

**重要**: 内部技能不注册并非功能不成熟，而是设计决策：
- 内部技能由工作流自动调用，用户无需记忆
- 所有内部命令标记 `internal: true`
- 技能标记 `status: ga` (稳定) 或 `status: experimental` (实验)

详见 [docs/INDEX.md](docs/INDEX.md) 设计原则章节。

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

## Agent Teams 协作开发

使用 Claude Code 原生 Agent Teams 进行多代理协作开发。

### 启用实验功能

```json
// ~/.claude/settings.json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

### 可用命令

| 命令 | 用途 |
|------|------|
| `/ai:team feature <功能>` | 功能开发模式 |
| `/ai:team review <路径>` | 代码审查模式 |
| `/ai:team debug <问题>` | 问题调查模式 |
| `/ai:dev --team <功能>` | 混合模式 |

### 运维脚本

```bash
# 健康检查
bash scripts/team-health-check.sh

# 状态恢复
bash scripts/team-recovery.sh <team-name>
```

### 相关文档

- [快速入门](docs/agent-teams-quickstart.md)
- [最佳实践](docs/agent-teams-best-practices.md)

## 调试

```bash
cat .claude-plugin/marketplace.json | jq .
claude --debug
```
