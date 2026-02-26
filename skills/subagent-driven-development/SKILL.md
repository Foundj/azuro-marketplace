---
name: subagent-driven-development
description: |
  This skill should be used when implementing complex features that benefit from task isolation.
  It defines how to dispatch subagents for each task with self-review before handoff, two-stage
  review after completion, and structured reporting. Triggers on "subagent", "dispatch task",
  "子代理", "任务分发", "parallel implementation". Borrowed from Superpowers by obra.
version: 5.0.20
triggers:
  - subagent
  - dispatch task
  - 子代理
  - 任务分发
  - parallel implementation
  - task dispatch
  - agent per task
  - 子代理驱动
  - 任务派发
---

# Subagent-Driven Development

> **Adapted from Superpowers by obra** - One subagent per task with structured handoff.

## Core Principle

```
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   ONE TASK = ONE SUBAGENT                                     ║
║                                                               ║
║   Each task gets a fresh subagent with:                       ║
║   - Full task context (no file reading required)              ║
║   - Clear success criteria                                    ║
║   - Self-review before handoff                                ║
║   - Two-stage review after completion                         ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

## Why Subagent Per Task

| 问题 | 传统方案 | Subagent 方案 |
|------|----------|---------------|
| 上下文污染 | 累积历史干扰判断 | 每个任务干净起点 |
| 任务串扰 | 前任务影响后任务 | 完全隔离执行 |
| 责任模糊 | 难以追溯问题源 | 明确任务归属 |
| 重试成本 | 回滚整个上下文 | 只重试单个任务 |

## Task Dispatch Template

```yaml
Task Tool:
  subagent_type: "general-purpose"
  description: "Implement Task N: [name]"
  prompt: |
    You are implementing Task N: [name]

    ## FULL Task Description

    [PASTE COMPLETE task text here - do NOT make subagent read files]

    ## Context

    [Relevant code snippets, types, interfaces - provide directly]

    ## Before You Begin

    If you have ANY questions about:
    - Requirements interpretation
    - Technical approach
    - Assumptions you're making

    **ASK NOW.** Don't proceed with guesses.

    ## Your Job

    1. Follow TDD (test first, watch fail, implement, watch pass)
    2. Implement exactly what the task specifies
    3. Self-review before reporting
    4. Commit your work

    ## TDD Steps (MANDATORY)

    1. Write failing test
    2. Run test → verify it fails
    3. Write minimal code to pass
    4. Run test → verify it passes
    5. Refactor if needed
    6. Commit

    ## Self-Review Before Handoff

    Before reporting completion, verify:
    - [ ] Tests pass
    - [ ] Code is minimal (no over-engineering)
    - [ ] No extra features added
    - [ ] Follows existing patterns
    - [ ] No obvious bugs

    ## Report Format

    When done, report:

    ```markdown
    ## Task N Complete

    ### What I Implemented
    [Brief description]

    ### Test Results
    [Test output]

    ### Files Changed
    - `path/to/file.ts` - [what changed]

    ### Commits
    - `abc1234` - feat: add feature

    ### Self-Review
    - [x] Tests pass
    - [x] Code is minimal
    - [x] Follows patterns

    ### Concerns
    [Any issues or uncertainties]
    ```
```

## Two-Stage Review After Completion

```
╔═══════════════════════════════════════════════════════════════╗
║                    AFTER SUBAGENT COMPLETES                    ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║   Stage 1: spec-compliance-review                             ║
║   ─────────────────────────────────                           ║
║   CRITICAL: Do NOT trust the implementer's report!            ║
║   They finished suspiciously quickly.                         ║
║   Verify by reading actual code.                              ║
║                                                               ║
║   Check:                                                      ║
║   - Missing requirements?                                     ║
║   - Extra/unneeded work?                                      ║
║   - Misunderstandings?                                        ║
║                                                               ║
║   ↓ MUST PASS before Stage 2                                  ║
║                                                               ║
║   Stage 2: code-reviewer                                      ║
║   ──────────────────────────────────────                      ║
║   Code quality, security, maintainability                     ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

### Stage 1 Dispatch

```yaml
Task Tool:
  subagent_type: "ai-dev:spec-compliance-reviewer"
  description: "Review spec compliance for Task N"
  prompt: |
    ## What Was Requested

    [FULL TEXT of task requirements]

    ## What Implementer Claims They Built

    [From implementer's report]

    ## Files Changed

    [List of files to review]

    ## CRITICAL: Do Not Trust the Report

    The implementer finished suspiciously quickly. Their report may be
    incomplete, inaccurate, or optimistic.

    **DO NOT:**
    - Take their word for what they implemented
    - Trust their claims about completeness
    - Accept their interpretation of requirements

    **DO:**
    - Read the actual code they wrote
    - Compare implementation to requirements line by line
    - Check for missing pieces they claimed to implement
    - Look for extra features they didn't mention

    ## Report

    - ✅ Spec compliant (if everything matches)
    - ❌ Issues found: [list with file:line]
```

### Stage 2 Dispatch (only after Stage 1 passes)

```yaml
Task Tool:
  subagent_type: "ai-dev:code-reviewer"
  description: "Review code quality for Task N"
  prompt: |
    Review code quality for the following changes.

    [Files and changes to review]

    Check:
    - Code cleanliness
    - Test quality
    - Pattern adherence
    - No AI slop (unnecessary comments, over-engineering)

    Report all issues with file:line references.
```

## Review Loop

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   Subagent completes task                                   │
│           ↓                                                 │
│   Spec Compliance Review (Stage 1)                          │
│           ↓                                                 │
│   ┌─────────────────────────────────────────┐               │
│   │ Issues found?                           │               │
│   │   YES → Subagent fixes → Re-review      │──────┐        │
│   │   NO  → Proceed to Stage 2              │      │        │
│   └─────────────────────────────────────────┘      │        │
│           ↓                                        │        │
│   (loop until ✅ PASS)  ←──────────────────────────┘        │
│           ↓                                                 │
│   Code Quality Review (Stage 2)                             │
│           ↓                                                 │
│   ┌─────────────────────────────────────────┐               │
│   │ Critical issues?                        │               │
│   │   YES → Fix → Re-review                 │               │
│   │   NO  → Mark task complete              │               │
│   └─────────────────────────────────────────┘               │
│           ↓                                                 │
│   Next task (or <promise>DONE</promise>)                    │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Task Granularity

```
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   EACH TASK: 2-5 minutes of focused work                      ║
║                                                               ║
║   ✅ Good task granularity:                                   ║
║   - "Write failing test for X"                                ║
║   - "Implement minimal code to pass test"                     ║
║   - "Refactor to use existing pattern"                        ║
║                                                               ║
║   ❌ Bad task granularity:                                    ║
║   - "Implement the entire feature"                            ║
║   - "Add authentication system"                               ║
║   - "Fix all the bugs"                                        ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

## Red Flags

**Never:**
- Dispatch multiple tasks to same subagent (context pollution)
- Trust implementer's report without code verification
- Skip spec compliance review
- Proceed to Stage 2 with Stage 1 issues open
- Give vague task descriptions

**Always:**
- Provide full task context in dispatch prompt
- Include success criteria
- Require TDD
- Run two-stage review
- Verify by reading actual code

## Integration

**Used by:**
- `ultrawork` - Dispatches subagents in Phase 5 (EXECUTE)
- `ai-dev-ooda` - Task execution loop

**Pairs with:**
- `tdd-enforcement` - Subagents follow TDD
- `spec-compliance-review` - Stage 1 review
- `code-reviewer` - Stage 2 review

**Triggers:**
- `todo-continuation-enforcer` - Forces completion

## Parallel Execution Optimization

### Independent Tasks → Parallel Dispatch

When tasks have no dependencies, dispatch in parallel:

```yaml
# Dispatch multiple tasks in ONE message (parallel execution)
Task({ description: "Task 1: Setup", prompt: "...", subagent_type: "general-purpose" })
Task({ description: "Task 2: Utils", prompt: "...", subagent_type: "general-purpose" })
Task({ description: "Task 3: Config", prompt: "...", subagent_type: "general-purpose" })

# Wait for all to complete before Phase 6 (Review)
```

### Dependency Detection

```yaml
Task Dependency Analysis:
  Independent: Task A and B have no file overlap → Parallel
  Dependent: Task B needs Task A's output → Sequential

Example:
  Task 1: Create types.ts (no deps) → Can parallel with Task 2
  Task 2: Create utils.ts (no deps) → Can parallel with Task 1
  Task 3: Create api.ts (needs types.ts, utils.ts) → Must wait for 1 & 2
```

### Context Window Management

```yaml
Problem:
  - Each subagent gets fresh context (good for isolation)
  - But main agent context grows with each result (bad for long sessions)

Solution:
  1. Summarize subagent results (don't include full code)
  2. Archive completed task details to codebox/archive/
  3. Only keep summary in main context:
     - Task N: ✅ Complete (files: X, Y, Z)
     - Task N+1: 🔄 In progress

Pattern:
  After each task completion:
    1. Extract: What was implemented (1-2 sentences)
    2. Extract: Files changed (list only)
    3. Extract: Any concerns (if any)
    4. Archive: Full report to codebox/archive/task-N.md
    5. Keep: Only summary in active context
```

### Subagent Result Summarization

```markdown
# Good: Concise summary
Task 1: Calculator Core ✅
- Implemented: add, subtract, multiply, divide methods
- Files: src/calculator.js (117 lines)
- Tests: 4 passing
- Concerns: None

# Bad: Full context dump
Task 1: Calculator Core ✅
[300 lines of code]
[100 lines of test output]
[50 lines of implementation details]
```

## Performance Tips

1. **Batch independent tasks**: Dispatch 2-4 subagents in single message
2. **Summarize results**: Keep main context clean
3. **Archive details**: Move completed work to archive
4. **Use TaskUpdate**: Track progress without repeating details
5. **Minimize file reads**: Subagent has full context in prompt
