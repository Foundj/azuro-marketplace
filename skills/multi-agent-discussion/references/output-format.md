# 输出格式规范

讨论汇总阶段生成的 `plan.md` 和 `task.md` 格式模板。
学习自 multiClaw 模板的职责分离原则：**plan = 设计文档，task = 执行看板**。

## 输出路径规范

讨论产出与讨论过程分离，按版本号组织：

```
docs/
├── discussions/<topic>/          # 讨论过程（不变）
│   ├── discussion.md
│   ├── context.md
│   └── ...
└── tasks/<version>/              # 讨论产出
    ├── plan.md                   # WHY + WHAT + HOW（无复选框）
    ├── task.md                   # 唯一状态看板（复选框 + YAML 依赖）
    └── reports/                  # 可选：自动化验证报告
```

### 版本号确定规则

1. 用户指定：`/ai:discuss summarize <topic> --version 1.3`
2. 自动递增：扫描目标项目 `docs/tasks/` 下已有 `v*` 目录，取最大版本号 +0.1
3. 首次使用：默认 `v1.0`
4. 版本号格式：`v<major>.<minor>`（如 `v1.0`, `v1.3`, `v2.0`）

---

## plan.md 模板

```markdown
---
version: "{{VERSION}}"
name: {{NAME}}
date: {{DATE}}
baseline: {{BASELINE}}
status: draft
discussion_source: docs/discussions/{{TOPIC}}/discussion.md
---

# V{{VERSION}} 需求与设计：{{NAME}}

<!--
  ┌─────────────────────────────────────────────────────┐
  │  本文件职责：WHY + WHAT + HOW                        │
  │  ✅ 背景动机、现状分析、技术方案、接口设计、风险控制     │
  │  ❌ 不含任何复选框(checkbox)、任务状态、进度追踪        │
  │  状态追踪统一在 task.md                               │
  │                                                       │
  │  来源讨论：{{DISCUSSION_SOURCE}}                       │
  └─────────────────────────────────────────────────────┘
-->

## 背景与动机

<!-- 从讨论 Round 0 种子和各角色分析中提取 -->

| 模块 | 当前状态 | V{{VERSION}} 目标 |
|------|----------|-------------------|
| <模块名> | <现状描述> | <目标描述> |

### 信息来源

- 讨论记录: `{{DISCUSSION_SOURCE}}`
- 参与者: <角色列表及所用工具>
- 讨论轮次: <实际轮次数>
- 使用后端: <工具后端列表>

### 约束条件

<从讨论中识别的技术、业务、时间约束>

## 成功标准

硬验收条件（所有条件必须满足，编号散文，不用复选框）：

1. <从 @QA 和 @PM 的讨论中提取的具体验收标准>
2. <可量化的指标>
3. <边界条件覆盖>

## Sprint 1：{{SPRINT_1_NAME}}

### 1.1 {{STEP_NAME}}

**{{新建|修改}}** `{{FILE_PATH}}`

<!-- 技术方案描述：为什么这样做、关键设计决策、接口定义 -->

```
// 关键接口 / 数据结构（仅放设计级代码，不放完整实现）
```

<!-- 重复 1.2, 1.3... 按需添加更多 Step -->

---

## Sprint 2：{{SPRINT_2_NAME}}

<!-- 同上结构，Sprint 之间用 --- 分隔 -->

---

## 文件变更清单

<!--
  汇总所有 Sprint 涉及的文件，方便全局审视影响范围
-->

| 操作 | 文件 | 说明 |
|------|------|------|
| 新建 | `path/to/new-file` | <一句话说明> |
| 修改 | `path/to/existing-file` | <一句话说明> |

## 架构决策记录

从讨论中的 `> [!decision]` callout 和 `#consensus` 标签提取：

### ADR-1: <决策标题>

- **背景：** <为什么需要做这个决策>
- **方案选项：**
  - A: <方案 A 描述>（<支持者 @角色 Round N>）
  - B: <方案 B 描述>（<支持者 @角色 Round N>）
- **决策：** <最终选择的方案>
- **理由：** <选择原因，引用讨论中的论据>
- **后果：** <预期影响>

### ADR-2: <决策标题>

（同上结构）

## 信心度分析

| 维度 | 信心度 | 说明 |
|------|--------|------|
| 需求明确性 | 高/中/低 | <基于讨论共识程度> |
| 技术可行性 | 高/中/低 | <基于 @Architect 评估> |
| 工作量估计 | 高/中/低 | <基于讨论分歧程度> |
| 风险可控性 | 高/中/低 | <基于 @Security/@QA 评估> |

## 风险与控制

| 风险 | 影响 | 控制措施 |
|------|------|----------|
| <风险描述> | <影响范围> | <控制措施> |

## 开放问题

从讨论中未达成共识的 `#pending` 和 `#needs-input` 项提取（编号列表，不用复选框）：

1. <待解决问题 1>（来源：@角色 Round N）
2. <待解决问题 2>（来源：@角色 Round N）
```

---

## task.md 模板

```markdown
---
version: "{{VERSION}}"
name: {{NAME}}
status: pending
updated: {{DATE}}
baseline: {{BASELINE}}
discussion_source: docs/discussions/{{TOPIC}}/discussion.md

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
  │  来源讨论：{{DISCUSSION_SOURCE}}                                │
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
| {{DATE}} | 创建 V{{VERSION}} plan/task | 基于讨论汇总生成（讨论：{{TOPIC}}） |
```

---

## 生成规则

汇总时遵循以下规则：

1. **版本确定**：扫描目标项目 `docs/tasks/` 目录，自动递增版本号（用户可通过 `--version` 覆盖）
2. **输出路径**：生成到 `docs/tasks/v{{VERSION}}/plan.md` 和 `task.md`，自动创建目录
3. **讨论溯源**：plan.md 和 task.md 的 frontmatter 均含 `discussion_source` 字段指向源讨论
4. **决策提取**：扫描所有 `> [!decision]` callout 和 `#consensus` 标签，生成 ADR 记录
5. **冲突标注**：`#pending` 项在 plan.md 的「开放问题」中以编号列表列出（不用复选框）
6. **来源追溯**：每个 ADR 注明支持该决策的讨论轮次和角色
7. **任务拆解**：每个 Sprint 的任务从 plan.md 的文件变更清单推导，task ID 格式 `s{sprint}-{seq}`
8. **验收继承**：task.md 的验证命令从 plan.md 的成功标准推导
9. **Sprint 依赖**：task.md YAML frontmatter 中显式声明 Sprint 和 Task 级依赖
10. **Review Gate**：每个 Sprint 末尾自动添加 `sN-review` 代码审查任务
11. **Git 提交规则**：task.md rules 中定义 `feat(v{{VERSION}}/s{N}): <description>` 格式
12. **变更记录**：task.md 末尾初始化变更记录表格，首行记录创建来源
