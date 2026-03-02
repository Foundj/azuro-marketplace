---
name: task-planner
description: >
  This skill provides versioned task planning and project management. It generates standardized
  plan.md (design doc) and task.md (execution board) in docs/tasks/v<VERSION>/ with YAML
  frontmatter, Sprint dependencies, and Git commit conventions. This skill should be used when
  the user asks to "create a plan", "generate tasks", "plan a feature", "break down requirements",
  "create a version", or when multi-agent-discussion or ai-dev need to produce structured task
  output. Also triggers when user mentions "docs/tasks", "版本计划", "任务看板", "Sprint规划",
  or wants to archive a completed version.
version: 6.0.21
status: ga
---

# Task Planner

将需求、讨论产出或功能描述转化为版本化的标准任务计划。生成的 plan.md 和 task.md 遵循 multiClaw v6 规范，支持 Sprint 依赖、Review Gate 和 Git 提交约定。

## 核心职责

1. **意图提取** — 从非结构化内容（讨论记录、需求访谈、功能描述）中识别决策点、验收标准和技术约束
2. **可行性评估** — 调用 requirement-analyzer 评估复杂度、时间和风险
3. **版本管理** — 自动递增版本号，判定 major/minor，必要时建议拆分
4. **模板渲染** — 生成标准化的 plan.md（WHY/WHAT/HOW）和 task.md（执行看板）
5. **归档管理** — 检查归档条件并执行版本归档

## 使用场景

<example>
Context: 用户完成了多代理讨论并要求生成任务计划
user: "把刚才讨论的结果生成 plan 和 task"
assistant: "我来使用 task-planner 技能为讨论产出生成版本化的任务计划。"
</example>

<example>
Context: 用户描述了一个新功能需求
user: "我想给项目加一个用户权限管理模块，帮我规划下任务"
assistant: "我来使用 task-planner 技能评估需求并生成任务计划。"
</example>

<example>
Context: 用户想归档已完成的版本
user: "v1.0 已经全部完成了，帮我归档"
assistant: "我来使用 task-planner 技能检查归档条件并执行归档。"
</example>

## 生成流程

### Step 1: 确定输入来源

识别输入类型并提取关键信息：

| 输入来源 | 提取内容 | 触发方式 |
|---------|---------|---------|
| 讨论记录 (`discussion.md`) | `[!decision]` callout, `#consensus` 标签 | multi-agent-discussion Phase 4 调用 |
| 需求访谈 (`proposal.md`) | 用户故事、验收标准、技术约束 | ai-dev Phase 3 调用 |
| 自然语言描述 | 功能要点、业务目标 | 用户直接对话 |

### Step 2: 调用 requirement-analyzer 评估

在生成计划前，调用 requirement-analyzer agent 进行可行性评估：

```
评估维度：
- 复杂度评分 (1-10): technical + business + integration
- 时间估算: minEstimate / likelyEstimate / maxEstimate
- 风险等级: low / medium / high / critical
- 可行性建议: accept / simplify / split / defer
```

评估结果的处理：
- **accept** → 正常生成 plan.md + task.md
- **simplify** → 在 plan.md 中标注简化建议，与用户确认后生成
- **split** → 生成拆分方案（详见 `references/versioning.md`），用户确认后按拆分生成多个版本
- **defer** → 在 plan.md 开头标注警告，建议用户重新评估

### Step 3: 确定版本号

读取 `references/versioning.md` 获取完整版本号决策规则。核心逻辑：

1. 用户显式指定 `--version X.Y` → 直接使用
2. Requirement-analyzer 建议 → 基于破坏性变更判定 major/minor
3. 自动递增 → 扫描目标项目 `docs/tasks/` 下已有 `v*` 目录，取最大版本号递增
4. 首次使用 → 默认 `v1.0`

可执行版本状态检查脚本：
```bash
bash skills/task-planner/scripts/check-version-status.sh [project-root]
```

### Step 4: 生成 plan.md

读取 `references/plan-template.md` 获取完整模板。关键原则：

- plan.md 是**设计文档**（WHY + WHAT + HOW），**不含任何复选框**
- 注入 requirement-analyzer 的评估结果到「信心度分析」和「风险与控制」章节
- 从讨论中提取的 ADR（架构决策记录）保留原始角色引用
- `discussion_source` 字段指向源讨论文件
- 验收标准使用编号散文（不用 `- [ ]`）

### Step 5: 生成 task.md

读取 `references/task-template.md` 获取完整模板。关键原则：

- task.md 是**唯一状态看板**，所有进度追踪仅在此文件维护
- YAML frontmatter 包含 sprints 依赖结构、执行规则、Git 提交格式
- 每个 Sprint 末尾强制 `sN-review` 代码审查任务
- 变更记录表格记录每次状态变更

### Step 6: 输出交付摘要

生成完成后输出：

```
📋 任务计划已生成

版本: v{{VERSION}}
名称: {{NAME}}
评估: 复杂度 {{SCORE}}/10 | 时间 {{DAYS}}天 | 风险 {{LEVEL}}

输出文件:
  📄 docs/tasks/v{{VERSION}}/plan.md  (设计文档)
  📋 docs/tasks/v{{VERSION}}/task.md  (执行看板)

Sprint 概览:
  Sprint 1: {{S1_NAME}} ({{S1_TASKS}} 个任务)
  Sprint 2: {{S2_NAME}} ({{S2_TASKS}} 个任务)

Git 提交格式: feat(v{{VERSION}}/s{N}): <description>
```

## 归档管理

当用户请求归档已完成的版本时，读取 `references/archive-rules.md` 获取归档条件和流程。

核心归档条件：
1. task.md 所有 Sprint 任务 `[x]` 完成
2. 全量验证项全部通过
3. task.md `status: completed`
4. Git 无未提交变更

归档脚本：
```bash
bash scripts/archive-version.sh [--dry-run] <version>
```

## 与其他技能的关系

| 技能 | 关系 | 说明 |
|------|------|------|
| multi-agent-discussion | 上游调用方 | Phase 4 Summarize 时调用 task-planner 生成产出 |
| ai-dev | 上游调用方 | Phase 3 设计完成后调用 task-planner 生成版本化任务 |
| requirement-analyzer | 被调用 | Step 2 中评估可行性 |
| task-templates | 可选配合 | 需要更细粒度的 TDD 任务拆解时调用 |
| task-dependency-analyzer | 可选配合 | 分析 Sprint/Task 间的依赖关系 |
| knowledge-graph | 归档时交互 | 归档时创建 version_release 节点 |
