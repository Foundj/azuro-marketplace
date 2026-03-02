---
name: task-executor
description: |
  This skill provides autonomous task execution engine for versioned task plans in docs/tasks/.
  It reads task.md YAML frontmatter, resolves hierarchical configuration (version README > global README),
  routes tasks to appropriate executors (self/subagent/CLI/Agent Team), and drives execution through
  a 4-phase cycle: understand → implement → test → review.

  <example>
  Context: User has a task.md ready and wants autonomous execution
  user: "docs/tasks/v2.0 的任务准备好了，自动执行吧"
  assistant: "I'll use the task-executor skill to parse the task plan, resolve execution config, and run all tasks through the understand → implement → test → review cycle."
  <commentary>
  User has a prepared task.md and requests autonomous execution, directly triggering this skill.
  </commentary>
  </example>

  <example>
  Context: User wants to execute tasks with a specific CLI tool
  user: "用 gemini 执行 v1.1 的前端任务"
  assistant: "I'll use the task-executor skill with executor override to route frontend-tagged tasks to Gemini CLI."
  <commentary>
  User specifies a CLI tool for a subset of tasks, triggering executor routing logic.
  </commentary>
  </example>

  <example>
  Context: User wants supervised execution with confirmation at each step
  user: "执行 v2.0 的任务，每步确认下"
  assistant: "I'll use the task-executor skill in supervised mode, pausing for confirmation after each task."
  <commentary>
  User requests supervised mode, changing execution.mode from autonomous to supervised.
  </commentary>
  </example>
version: 6.0.24
status: ga
profile: dev
triggers:
  - execute tasks
  - run tasks
  - 执行任务
  - 自动执行
  - 跑任务
  - docs/tasks
  - task-executor
---

# Task Executor

> 自动执行 `docs/tasks/` 中的版本化任务计划，驱动 **充分理解 → 实现 → 阶段测试 → Code Review → 下一 Sprint** 的完整循环。

## 触发词

此技能触发于: "execute tasks", "run tasks", "执行任务", "自动执行", "跑任务", 或引用 `docs/tasks/`。

## Quick Start

```
"执行 docs/tasks/v2.0 的所有任务"              # 自主模式
"用 supervised 模式执行 v1.1 的任务"            # 每步确认
"用 gemini 执行 v2.0 的前端任务"               # 指定执行器
```

也可通过 Ralph Loop 实现持续自主执行：

```bash
/ralph-loop "执行 docs/tasks/v2.0 的所有任务" \
  --completion-promise "ALL_TASKS_DONE" --max-iterations 50
```

## 执行周期

每个任务经过 4 个阶段，每个 Sprint 结束时强制 Review：

```
┌─────────────────────────────────────────────────────────────┐
│                     EXECUTION CYCLE                          │
├─────────────────────────────────────────────────────────────┤
│  Phase 1: UNDERSTAND — 读 plan.md + 相关源文件 + 验收标准     │
│  Phase 2: IMPLEMENT  — TDD 编写 + 实现 + 本地测试             │
│  Phase 3: TEST       — 运行 verify 命令 + 回归检查            │
│  Phase 4: REVIEW     — Sprint 级代码审查 + 修复 P0/P1         │
│           ↓                                                  │
│  Loop until all Sprints ✅ → <promise>ALL_TASKS_DONE</promise>│
└─────────────────────────────────────────────────────────────┘
```

## 统一简写语法

所有配置层级（steps、roles、executors、task.md）共用同一套简写：

| 简写 | 解析为 | 说明 |
|------|--------|------|
| `self` | 当前会话 | 默认值 |
| `subagent` | subagent (generalPurpose) | |
| `subagent:<type>` | 指定类型 subagent | 如 `subagent:frontend-developer` |
| `gemini` | CLI gemini | 已知工具名自动识别 |
| `codex` | CLI codex | |
| `claude` | CLI claude | |
| `opencode` | CLI opencode | |
| `agent-team` | Agent Team 默认模板 | |
| `agent-team:<template>` | Agent Team 指定模板 | 如 `agent-team:code-review` |

已知 CLI 工具名: `claude`, `codex`, `gemini`, `opencode`, `claudea`, `claudec`, `claudeg`

## 配置层级

执行器解析优先级（高→低）：

```
task.md 单任务 executor: gemini       ← 最高
  ↓
roles: { frontend: gemini }
  ↓
docs/tasks/vX.Y/README.md
  ↓
docs/tasks/README.md
  ↓
steps: { implement: self }
  ↓
self                                  ← 兜底默认
```

## 执行流程

### Step 1: 解析配置

1. 读取 `docs/tasks/README.md` YAML frontmatter（全局配置）
2. 若 `docs/tasks/vX.Y/README.md` 存在，合并（版本级优先）
3. 检测可用执行器（哪些 CLI 工具已安装）

```bash
bash skills/task-executor/scripts/resolve-config.sh <version> [project-root]
```

### Step 2: 解析任务

读取 `docs/tasks/vX.Y/task.md` YAML frontmatter，构建 Sprint/Task 依赖图。

```bash
bash skills/task-executor/scripts/parse-task-yaml.sh <task-file>
```

### Step 3: 遍历 Sprint（按 depends_on 排序）

对每个 Sprint 中的每个 Task：

**Phase 1 — 充分理解**
- 读取 plan.md 中对应 Sprint 的设计段落
- 读取任务的 `files` 和 `context_files` 引用的源文件
- 识别验收标准和 verify 命令
- 若需求不清 → 暂停，向用户请求澄清

**Phase 2 — 实现**
- 路由到匹配的执行器（解析 executor 简写）
- 若 `tdd_required != false`，先写测试再写实现
- 对于 CLI 执行器，构建自包含 prompt 并调用 invoke-agent.sh
- 对于 Agent Team，引用 team-collaboration 模板并按 blockedBy 波次执行

```bash
bash skills/task-executor/scripts/dispatch-task.sh <tool> <prompt-file> <working-dir> [timeout]
```

**Phase 3 — 阶段测试**
- 运行任务的 `verify` 命令
- 检查回归（是否破坏了已通过的验证）
- 测试失败 → 回到 Phase 2 重试

```bash
bash skills/task-executor/scripts/verify-task.sh <verify-command>
```

**Phase 4 — Sprint Review**（Sprint 级）
- 运行代码审查（使用 review 步骤配置的执行器）
- 修复 P0/P1 问题
- 记录 P2 到变更记录
- 通过 → 进入下一 Sprint

### Step 4: 全量验证

所有 Sprint 完成后，运行 task.md 中的「全量验证」检查项。

### Step 5: 完成

更新 task.md `status: completed`，输出完成承诺：

```xml
<promise>ALL_TASKS_DONE</promise>
```

## 状态管理

瞬态状态保存在 `.claude/task-executor.local.md`：

```yaml
---
active: true
version: 6.0.24
current_sprint: sprint-1
current_task: s1-2
current_phase: implement
iteration: 3
started_at: "2026-03-02T10:00:00Z"
---
```

用于 Ralph Loop 迭代间恢复上下文，或会话中断后续接。

## 需求不清处理

当 `execution.pause_on_unclear: true`（默认）时：

1. 理解阶段发现需求不清 → 暂停执行
2. 列出不清楚的点，请求用户澄清
3. 用户回复后继续
4. 若在 Ralph Loop 中，通过 Stop Hook 保持循环等待

不会猜测需求，不会跳过不清楚的任务。

## CLI Prompt 构建

对于 CLI 执行器，按 multi-agent-discussion 的自包含原则构建 prompt：

- 任务 ID、名称、验收标准
- plan.md 中对应 Sprint 的设计摘要
- 涉及文件列表和当前状态
- 验证命令
- 输出格式要求

底层复用 `skills/multi-agent-discussion/scripts/invoke-agent.sh`。

## Agent Team 编排

对于 `agent-team` 执行器，引用 `skills/team-collaboration` 的模板体系：

- 从 `executors.agent-team.templates` 获取模板引用
- 使用 `selectTeamTemplate()` 选择匹配模板
- 按 `Teammate.blockedBy` 定义执行波次
- 通过 `fileScope` 确保文件隔离
- 不可用时降级为 `executors.agent-team.fallback`（默认 subagent）
- `tool_override` 可为每个队友指定不同 CLI 工具

## 与其他技能的关系

| 技能 | 关系 | 说明 |
|------|------|------|
| task-planner | 上游 | 生成 plan.md + task.md，task-executor 消费 |
| ai-dev-ooda | 互补 | OODA 提供 Ralph Loop 模式，task-executor 提供结构化执行 |
| team-collaboration | 引用 | Agent Team 模板来源 |
| multi-agent-discussion | 复用 | invoke-agent.sh CLI 调用基础设施 |
| ai-dev-quality | 下游 | Sprint Review 阶段可调用 |

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-03-02 | 初始版本: 4-phase 执行周期、统一简写语法、分层配置 |
