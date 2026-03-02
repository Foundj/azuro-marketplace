# README.md 配置 Schema

> docs/tasks/README.md 和 docs/tasks/vX.Y/README.md 的 YAML frontmatter 配置规范

## 概述

README.md 的 YAML frontmatter 是 task-executor 的配置源。分为全局（`docs/tasks/README.md`）和版本级（`docs/tasks/vX.Y/README.md`）两层，版本级优先。

## 完整 Schema

### 1. execution — 引擎级开关

```yaml
execution:
  engine: task-executor          # 固定值
  mode: autonomous               # autonomous | supervised
  max_iterations: 50             # Ralph Loop 最大迭代次数
  pause_on_unclear: true         # 需求不清时暂停
  completion_promise: "ALL_TASKS_DONE"  # 完成承诺文本
```

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `engine` | string | `task-executor` | 使用的执行引擎 |
| `mode` | enum | `autonomous` | `autonomous` 自主 / `supervised` 每步确认 |
| `max_iterations` | int | `50` | Ralph Loop 最大迭代次数 |
| `pause_on_unclear` | bool | `true` | 需求不清时暂停 |
| `completion_promise` | string | `ALL_TASKS_DONE` | 完成承诺文本 |

### 2. steps — 执行周期

```yaml
steps:
  understand: self
  implement: self
  test: self
  review: self
```

**简写语法**: 直接填写执行器简写值（见下方简写语法表）。

**展开语法**: 需要额外选项时使用。

```yaml
steps:
  review:
    executor: claude
    scope: sprint              # sprint | task
```

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `understand` | shorthand | `self` | 理解阶段执行器 |
| `implement` | shorthand | `self` | 实现阶段执行器 |
| `test` | shorthand | `self` | 测试阶段执行器 |
| `review` | shorthand / object | `self` | 审查阶段执行器 |
| `review.scope` | enum | `sprint` | 审查粒度: sprint 或 task |

### 3. executors — 执行器参数

```yaml
executors:
  subagent:
    type: generalPurpose

  cli:
    timeout: 300
    claude: { flags: "..." }
    codex: { flags: "..." }
    gemini: { flags: "..." }
    opencode: { flags: "..." }

  agent-team:
    fallback: subagent
    default_template: feature-development
    templates:
      <name>:
        ref: team-collaboration#TEMPLATE_NAME
        tool_override: { <teammate>: <tool> }
```

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `subagent.type` | string | `generalPurpose` | subagent 类型 |
| `cli.timeout` | int | `300` | CLI 调用超时(秒) |
| `cli.<tool>.flags` | string | 见预设 | CLI 工具命令行参数 |
| `cli.<tool>.allowed_tools` | string | - | Claude CLI 允许的工具 |
| `cli.<tool>.reasoning` | string | - | Codex 推理等级 |
| `agent-team.fallback` | shorthand | `subagent` | 不可用时降级 |
| `agent-team.default_template` | string | `feature-development` | 默认模板 |
| `agent-team.templates.<name>.ref` | string | - | team-collaboration 模板引用 |
| `agent-team.templates.<name>.tool_override` | map | `{}` | 队友工具覆盖 |

### 4. roles — 角色路由

```yaml
# 简写
roles:
  frontend: gemini

# 展开
roles:
  frontend:
    match: { tags: [frontend, ui, design] }
    implement: gemini
    review: claude
    team_template: feature-development
```

| 字段 | 类型 | 默认值 | 说明 |
|------|------|--------|------|
| `<role>` | shorthand / object | - | 简写时全部步骤用同一执行器 |
| `<role>.match` | object | - | 匹配规则 |
| `<role>.match.tags` | string[] | - | 按任务 tags 匹配 |
| `<role>.match.id` | string | - | 按任务 ID 通配匹配 |
| `<role>.implement` | shorthand | 继承 steps | 实现执行器 |
| `<role>.review` | shorthand | 继承 steps | 审查执行器 |
| `<role>.team_template` | string | - | Agent Team 模板 |

### 5. rules — 全局规则

```yaml
rules:
  - "规则文本"
  - "规则文本"
```

人类可读的约束规则列表。task-executor 在执行前读取并遵循。

## 简写语法解析规则

解析引擎按以下逻辑处理简写值：

```
输入值
  ├─ "self"           → 当前会话
  ├─ "subagent"       → subagent, type = executors.subagent.type
  ├─ "subagent:<t>"   → subagent, type = <t>
  ├─ "<known-tool>"   → CLI, tool = <known-tool>, params = executors.cli.<known-tool>
  ├─ "agent-team"     → Agent Team, template = executors.agent-team.default_template
  └─ "agent-team:<t>" → Agent Team, template = <t>
```

已知 CLI 工具名: `claude`, `codex`, `gemini`, `opencode`, `claudea`, `claudec`, `claudeg`

## 版本级覆盖

`docs/tasks/vX.Y/README.md` 存在时自动与全局配置合并，无需显式声明。只需声明差异部分：

```yaml
---
steps:
  implement: codex             # 覆盖全局

roles:
  frontend: gemini             # 覆盖全局
---
```

**合并规则**: 浅合并（由 `resolve-config.sh` 通过 `yq eval-all` 实现）。版本级中出现的键覆盖全局同名键，未出现的键继承全局值。
