---
name: ai-dev-ooda
description: |
  This skill provides OODA Loop autonomous execution engine for AI development. It implements
  Observe-Orient-Decide-Act cycle with verification gates, reflexion learning, and attention management.
  Use this skill when the user mentions "autonomous loop", "OODA", "自动执行", "循环执行", "ai:loop",
  "ai:auto", or when executing tasks autonomously until completion with <promise>DONE</promise> signal.
version: 4.1.21
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
