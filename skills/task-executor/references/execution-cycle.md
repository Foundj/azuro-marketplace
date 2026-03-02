# 执行周期详细规范

> task-executor 的 4-phase 执行周期定义

## 周期概览

每个任务经过 4 个阶段。Review 在 Sprint 级触发（可通过 `scope: task` 改为任务级）。

```
For each Sprint (按 depends_on 排序):
  For each Task (按 depends_on 排序):
    Phase 1: UNDERSTAND
    Phase 2: IMPLEMENT
    Phase 3: TEST
  Phase 4: REVIEW (Sprint 级)
```

## Phase 1: UNDERSTAND（充分理解）

**目的**: 确保实现前充分理解需求，避免盲目编码。

**必做动作**:

1. 读取 `plan.md` 中对应 Sprint 的设计段落
2. 读取任务 `files` 字段列出的源文件
3. 读取任务 `context_files` 字段列出的额外文件（如果有）
4. 识别验收标准（从 plan.md 成功标准 + task verify 命令）
5. 评估需求清晰度

**清晰度判定**:

- 清晰 → 进入 Phase 2
- 不清晰 + `pause_on_unclear: true` → 暂停，列出问题请求用户澄清
- 不清晰 + `pause_on_unclear: false` → 基于最佳理解继续（不推荐）

**不清晰的信号**:

- 任务描述含歧义词（"可能"、"大概"、"类似"）
- `files` 字段为空且无法从上下文推断
- 依赖的前置任务产出不明确
- 技术方案在 plan.md 中未定义

## Phase 2: IMPLEMENT（实现）

**目的**: 执行具体的代码修改。

**执行器路由**:

按简写语法解析执行器，优先级：

```
task.executor → roles 匹配 → steps.implement → self
```

**TDD 流程**（当 `tdd_required != false`）:

```
1. RED    — 写失败的测试
2. RUN    — 确认测试确实失败
3. GREEN  — 写最小代码使测试通过
4. RUN    — 确认测试通过
5. COMMIT — 提交工作代码
6. REFACTOR — 可选重构（保持测试通过）
```

**CLI 执行模式**:

当执行器为 CLI 工具时：
1. 构建自包含 prompt（参考 `skills/multi-agent-discussion/references/cli-prompt-templates.md`）
2. 写入临时 prompt 文件
3. 调用 `invoke-agent.sh <tool> <prompt-file> <working-dir> [timeout]`
4. 解析返回结果

**Agent Team 执行模式**:

当执行器为 `agent-team` 时：
1. 从 `executors.agent-team.templates` 获取模板
2. 按 `tool_override` 为队友分配工具
3. 按 `blockedBy` 定义波次执行
4. 确保 `fileScope` 文件隔离

## Phase 3: TEST（阶段测试）

**目的**: 验证实现正确性。

**必做动作**:

1. 运行任务 `verify` 命令（如果有）
2. 检查回归：已通过的前置任务 verify 是否仍然通过
3. 检查 Git 状态：确保变更已暂存

**结果处理**:

- 全部通过 → 更新 task.md 标记 `[x]`，记录变更记录
- verify 失败 → 回到 Phase 2 重试（最多 3 次）
- 回归失败 → 优先修复回归，再重试当前任务
- 3 次失败 → 暂停，请求用户介入

## Phase 4: REVIEW（代码审查）

**目的**: 确保代码质量，在 Sprint 间设置质量门禁。

**触发时机**: 默认 Sprint 级（`scope: sprint`），可改为 `scope: task`。

**审查流程**:

1. 收集本 Sprint 所有已完成任务的变更
2. 路由到 review 执行器（`steps.review` 配置）
3. 按优先级分类发现：
   - P0: 阻塞性问题 — 必须修复
   - P1: 重要问题 — 必须修复
   - P2: 改进建议 — 记录到变更记录，不阻塞
4. 修复 P0/P1 后重新验证
5. 在 task.md 标记 `sN-review` 为 `[x]`

**Git 提交格式**: `feat(v{VERSION}/s{N}): <description>`

## 全量验证

所有 Sprint 完成后：

1. 运行 task.md「全量验证」区域的所有检查项
2. 逐项标记 `[x]`
3. 全部通过 → 更新 `status: completed`
4. 输出 `<promise>ALL_TASKS_DONE</promise>`
