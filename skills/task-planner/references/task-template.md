# task.md 标准模板

本模板定义版本化任务看板的标准格式。task.md 是**唯一状态真相**，所有进度追踪仅在此文件维护。

---

```markdown
---
version: "{{VERSION}}"
name: {{NAME}}
status: pending
updated: {{DATE}}
baseline: {{BASELINE}}
discussion_source: {{DISCUSSION_SOURCE}}

# ════════════════════════════════════════════════════════
# 执行规则
# ════════════════════════════════════════════════════════
rules:
  - task.md 是唯一状态真相，plan.md 不含任何勾选状态
  - 每个 Sprint 完成后必须 review code 再进入下一 Sprint
  - 集成测试必须附带可复现的验证命令
  - Sprint 间存在 depends_on 依赖时必须顺序执行
  - "Git 提交格式: feat(v{{VERSION}}/s{N}): <description>"

# ════════════════════════════════════════════════════════
# 开发顺序与依赖（YAML 结构化描述）
#
# 字段说明：
#   id          - Sprint/Task 唯一标识，在看板区域引用
#   name        - 人类可读名称
#   depends_on  - 前置依赖（Sprint 级或 Task 级）
#   files       - 涉及的文件列表，对应 plan.md 中的文件变更清单
#   verify      - 完成后的验证命令（可复现）
# ════════════════════════════════════════════════════════
sprints:
  - id: sprint-1
    name: {{SPRINT_1_NAME}}
    depends_on: []
    tasks:
      - id: s1-1
        name: {{TASK_NAME}}
        files: [path/to/file]
        depends_on: []
        # verify: "bash test.sh"

      - id: s1-review
        name: Sprint 1 代码审查
        depends_on: [s1-1]

  # - id: sprint-2
  #   name: {{SPRINT_2_NAME}}
  #   depends_on: [sprint-1]
  #   tasks:
  #     - id: s2-1
  #       name: {{TASK_NAME}}
  #       files: [path/to/file]
---

# V{{VERSION}} 任务看板

<!--
  ┌───────────────────────────────────────────────────────────────┐
  │  本文件职责：唯一执行状态看板                                    │
  │  ✅ YAML 结构化开发顺序 + Markdown 打勾追踪 + 变更记录           │
  │  ❌ 不含技术方案、接口设计（这些在 plan.md）                      │
  │                                                               │
  │  来源：{{DISCUSSION_SOURCE}}                                    │
  │  设计文档：docs/tasks/v{{VERSION}}/plan.md                      │
  │                                                               │
  │  使用方式：                                                     │
  │  1. 阅读 YAML frontmatter 了解 Sprint/Task 依赖和执行顺序        │
  │  2. 在下方 Markdown 区域打勾追踪进度                              │
  │  3. 完成任务后在变更记录中补充条目                                 │
  │  4. Git 提交使用版本前缀：feat(v{{VERSION}}/s{N}): description   │
  └───────────────────────────────────────────────────────────────┘
-->

> **唯一状态真相**：所有任务状态仅在此文件维护。`plan.md` 只含需求与设计，不含勾选。

## 前置基线（V{{BASELINE}} 完成状态）

<!--
  列出上一版本的完成状态，作为本版本的起点
  已完成用 [x]，未完成用 [ ] 并注明是否阻塞本版本
  首次版本写「无前置基线」
-->

- [x] <!-- 已完成的前置项 -->

---

## Sprint 1：{{SPRINT_1_NAME}}

<!--
  每行格式：- [ ] `yaml-task-id` 任务描述 — 关键文件/备注
  Sprint 末尾固定一个 review 任务
-->

- [ ] `s1-1` {{TASK_DESCRIPTION}} — `path/to/file`
- [ ] `s1-review` Sprint 1 代码审查

<!--
## Sprint 2：{{SPRINT_2_NAME}}

- [ ] `s2-1` {{TASK_DESCRIPTION}}
- [ ] `s2-review` Sprint 2 代码审查
-->

## 全量验证

<!--
  所有 Sprint 完成后的最终验证，对应 plan.md 的成功标准
-->

- [ ] <全量验证命令或检查项>

---

## 变更记录

<!--
  每次状态变更都记录在此
  包括：任务完成、问题发现、方案调整、review 结论等
-->

| 日期 | 变更 | 原因 |
|------|------|------|
| {{DATE}} | 创建 V{{VERSION}} plan/task | 基于{{SOURCE_TYPE}}生成 |
```

---

## 模板使用说明

### 占位符

与 plan-template.md 共享相同的占位符体系。额外字段：

| 占位符 | 说明 |
|--------|------|
| `{{SPRINT_1_NAME}}` | Sprint 名称，如「基础架构」 |
| `{{TASK_NAME}}` | 具体任务名称 |
| `{{TASK_DESCRIPTION}}` | 任务描述，显示在看板中 |
| `{{SOURCE_TYPE}}` | 来源类型：讨论汇总 / 需求分析 / 用户指定 |

### 状态流转

task.md 的 `status` 字段遵循以下流转：

```
pending → in_progress → completed → archived
```

| status | 含义 | 触发条件 |
|--------|------|---------|
| `pending` | 待开始 | 刚生成 |
| `in_progress` | 进行中 | 首个 Sprint 开始工作时 |
| `completed` | 已完成 | 所有 Sprint + 全量验证通过 |
| `archived` | 已归档 | 执行归档操作后 |

### Sprint 看板格式

每行格式严格遵循：
```
- [ ] `task-id` 任务描述 — 关键文件/备注
```

完成后标记为：
```
- [x] `task-id` 任务描述 — 关键文件/备注
  > 完成备注（可选）
```

### 变更记录格式

每次状态变更都追加一行：
```
| YYYY-MM-DD | `task-id` 标记已完成 | 完成原因/方式 |
```

Review 结论记录：
```
| YYYY-MM-DD | `sN-review` 标记已完成 | 审查通过：X P0, Y P1(已修复), Z P2 |
```
