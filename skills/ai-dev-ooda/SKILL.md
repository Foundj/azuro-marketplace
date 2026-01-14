---
name: ai-dev-ooda
description: |
  This skill provides OODA Loop autonomous execution engine for AI development. It implements
  Observe-Orient-Decide-Act cycle with verification gates, reflexion learning, and attention management.
  Use this skill when the user mentions "autonomous loop", "OODA", "自动执行", "循环执行", "ai:loop",
  "ai:auto", or when executing tasks autonomously until completion with <promise>DONE</promise> signal.
version: 5.0.3
triggers:
  - autonomous loop
  - OODA loop
  - ai:loop
  - ai:auto
  - 自动执行
  - 循环执行
  - 自主完成
---

# OODA Loop Engine

> Autonomous execution engine implementing Observe-Orient-Decide-Act cycle with hard verification gates.

## Quick Start

```bash
/ai:loop "Build REST API"       # Start OODA loop for task
/ai:auto                        # Continue uncompleted tasks
/ai:cancel-loop                 # Cancel running loop
```

## Core Concept

OODA Loop enables autonomous task execution:

```
┌─────────────────────────────────────────────────────┐
│                    OODA CYCLE                        │
├─────────────────────────────────────────────────────┤
│  OBSERVE → Read tasks.md, state.json                │
│  ORIENT  → Analyze context, query knowledge         │
│  DECIDE  → Select next action                       │
│  ACT     → Execute, update checkboxes               │
│           ↓                                         │
│  Loop until all tasks ✅ → <promise>DONE</promise>  │
└─────────────────────────────────────────────────────┘
```

## Verification Gates (v4.0)

Tasks can specify verification commands that MUST pass before completion:

```markdown
## tasks.md example
- [ ] Implement login API
  - verify_with: `npm test -- --grep "login"`
  - success_criteria: All tests pass
```

**Blocking Mechanism**: Cannot output `<promise>DONE</promise>` until verification passes.

**Escape Hatch**: Use `verify_with: true` for tasks that can't be automatically tested.

## Reflexion System

Persistent learning from failures:

1. **Failure Detection**: Verification failure triggers analysis
2. **Solution Logging**: Error + solution saved to `solutions_learned.jsonl`
3. **Knowledge Query**: Before each task, query previous solutions
4. **Avoid Repeats**: Apply learned fixes proactively

```json
// solutions_learned.jsonl
{"error": "TypeError: undefined", "solution": "Add null check before access", "context": "API response handling"}
```

## Attention Management (v4.1)

> **Read Before Decide** — Refresh goals each iteration to prevent drift

**每次迭代必须**:

1. **OBSERVE 阶段**: 读取 `tasks.md` + `state.json` 刷新注意力
2. **重大决策前**: 读取 `design.md` + `requirements.md`
3. **每 5 次迭代**: 运行 `/focus` 强制刷新

**Lost in the Middle 预防**: 在 50+ iterations 后，原始目标可能被"遗忘"。周期性读取目标文件将其重新注入注意力窗口。

## Worker Sessions (v4.0)

Horizontal scaling for complex features:

```
Context reaches 80%
       ↓
┌──────────────────────┐
│  MANAGER SESSION     │
│  (current context)   │
│         ↓            │
│  Spawn WORKER        │
│  via handover.md     │
└──────────────────────┘
       ↓
┌──────────────────────┐
│  WORKER SESSION      │
│  (fresh context)     │
│  Max Depth = 2       │
└──────────────────────┘
```

**Handover Protocol**: Semantic context transfer via `handover.md` file.

## State Machine

```
┌─────────┐    start     ┌──────────┐
│  IDLE   │ ──────────→  │ RUNNING  │
└─────────┘              └────┬─────┘
     ↑                        │
     │    ┌───────────────────┼───────────────────┐
     │    │                   │                   │
     │    ↓                   ↓                   ↓
     │ ┌──────┐         ┌─────────┐         ┌─────────┐
     │ │PAUSED│         │VERIFYING│         │ ERROR   │
     │ └──────┘         └─────────┘         └─────────┘
     │    │                   │                   │
     │    └───────────────────┼───────────────────┘
     │                        │
     │                        ↓
     │                 ┌──────────┐
     └──────────────── │ COMPLETED│
                       └──────────┘
```

## Configuration

```json
// hooks/hooks.json
{
  "hooks": [{
    "id": "ooda-stop-hook",
    "type": "Stop",
    "script": "hooks/ooda-stop-hook.sh",
    "conditions": {
      "currentPhase": 4,
      "oodaEnabled": true
    }
  }],
  "config": {
    "completionPromise": "DONE",
    "maxIterations": 50
  }
}
```

## Ralph Loop Pattern (Self-Referential Iteration)

> 灵感来自 Anthropic 官方 ralph-loop 实现

### 核心机制

Ralph Loop 是一种自引用循环模式，通过 Stop Hook 实现任务的持续执行直到完成：

```
┌─────────────────────────────────────────────────────────┐
│                  RALPH LOOP MECHANISM                    │
├─────────────────────────────────────────────────────────┤
│  1. Claude 开始执行任务                                  │
│  2. Claude 尝试结束 (输出最终响应)                       │
│  3. Stop Hook 拦截退出                                  │
│  4. Hook 检查: 任务完成了吗?                            │
│     ├─ 否 → 返回相同提示词，Claude 继续执行              │
│     └─ 是 → 允许退出                                    │
│  5. 重复 1-4 直到完成                                   │
└─────────────────────────────────────────────────────────┘
```

### 完成承诺 (Completion Promise)

退出循环的唯一方式是输出完成承诺：

```xml
<promise>DONE</promise>
```

**规则**:
- 只有当所有任务 ✅ 完成后才能输出
- 验证门禁必须全部通过
- Stop Hook 会验证承诺的有效性

### Stop Hook 实现

```bash
#!/bin/bash
# ooda-stop-hook.sh

TASKS_FILE="codebox/changes/active/*/tasks.md"
COMPLETION_PROMISE="DONE"

# 检查是否有未完成的任务
if grep -q "^- \[ \]" $TASKS_FILE 2>/dev/null; then
    # 有未完成任务 → 阻止退出，返回相同提示
    echo "Tasks remaining. Continue execution."
    exit 1  # 阻止退出
fi

# 检查最后输出是否包含完成承诺
if [[ "$LAST_OUTPUT" != *"<promise>$COMPLETION_PROMISE</promise>"* ]]; then
    echo "Missing completion promise. Continue execution."
    exit 1
fi

# 所有检查通过，允许退出
exit 0
```

### 与传统循环的区别

| 方面 | 传统循环 | Ralph Loop |
|------|----------|------------|
| 控制 | 外部计数器 | 内部承诺 |
| 退出条件 | 达到次数限制 | 完成任务 + 输出承诺 |
| 上下文 | 每次迭代可能丢失 | Stop Hook 保持连续性 |
| 自主性 | 低 (被动执行) | 高 (主动承诺完成) |

### OODA + Ralph Loop 融合

我们的 OODA 实现结合了 Ralph Loop 的核心优势：

1. **Stop Hook 驱动**: 使用 `ooda-stop-hook.sh` 拦截退出
2. **任务驱动**: 基于 `tasks.md` 的 checkbox 状态判断完成
3. **验证门禁**: `verify_with` 确保质量
4. **注意力管理**: 周期性读取目标文件防止漂移
5. **承诺退出**: 只有 `<promise>DONE</promise>` 能真正退出

---

## Integration with ai-dev

This skill is used in **Phase 4 (Implementation)** of the 7-phase workflow:

1. Phase 3 generates `tasks.md`
2. Phase 4 activates OODA loop
3. OODA executes until all tasks complete
4. Output `<promise>DONE</promise>` to exit
5. Phase 5 begins quality validation

## References

See `references/ooda-loop.md` for complete specification including:
- State transitions
- Error recovery
- Iteration limits
- Context compression strategies

## Agent Collaboration

| Agent | Role |
|-------|------|
| `ai-dev` | Activates OODA in Phase 4 |
| `ai-dev-quality` | Runs after OODA completion |
| `@verification-agent` | Executes verify_with commands |
| `session-manager` | Saves OODA state for recovery |

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 4.2.6 | 2026-01-13 | Add agent collaboration, version history |
| 4.2.4 | 2026-01-10 | Add Ralph Loop pattern integration |
| 4.1.0 | 2026-01-08 | Add Attention Management |
| 4.0.0 | 2026-01-07 | Initial release with verification gates |

## References

See `references/state-machine.md` for state transition details.
