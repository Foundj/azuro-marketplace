---
name: ultrawork
description: |
  This skill should be used when the user wants autonomous end-to-end task completion.
  It provides a one-word trigger for a complete development workflow, orchestrating
  requirement clarification, worktree isolation, TDD implementation, two-stage review,
  and continuous execution until <promise>DONE</promise>.
version: 6.0.2
status: ga
triggers:
  - ultrawork
  - ulw
  - 自动完成
  - 全自动
  - autonomous
  - just do it
  - 帮我搞定
  - 一键开发
  - 自动实现
  - 任务闭环
  - team mode
  - 团队模式
---

# Ultrawork: Autonomous Development Mode

> **Philosophy**: Human intervention during agentic work is a failure signal. The system should complete work without requiring babysitting.

## Core Principle

```
Human Intent → Agent Execution → Verified Result
      ↑                              ↓
      └──────── Minimum ─────────────┘
         (intervention only on true failure)
```

## Trigger Detection

Activate when user prompt contains:
- `ultrawork` or `ulw`
- `自动完成` or `全自动`
- `autonomous` or `just do it`
- `帮我搞定` or `一键开发`

## The Ultrawork Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    ULTRAWORK MODE                            │
├─────────────────────────────────────────────────────────────┤
│  0. CHECK      Confidence Gate (≥90% proceed)               │
│  1. ANALYZE    Detect task complexity                       │
│  2. CLARIFY    If ambiguous → Ask 1-3 questions             │
│  3. ISOLATE    Complex task → Auto-create worktree          │
│  4. PLAN       Generate bite-sized tasks (2-5 min each)     │
│  5. EXECUTE    Dispatch subagent per task                   │
│  6. REVIEW     Stage 1: Spec + Stage 2: Quality             │
│  7. CONTINUE   Check TodoList, loop if incomplete           │
│  8. FINISH     Run tests, offer merge/PR/discard            │
│  9. DONE       Output <promise>DONE</promise>               │
└─────────────────────────────────────────────────────────────┘
```

## Phase Summary

| Phase | Name | Key Action |
|-------|------|------------|
| 0 | Confidence Gate | ≥90% proceed, <70% ask questions |
| 1 | Task Analysis | Detect SIMPLE/MEDIUM/COMPLEX |
| 2 | Clarification | Max 3 questions if ambiguous |
| 3 | Isolation | Worktree for COMPLEX tasks |
| 4 | Planning | Atomic 2-5 min tasks with TDD |
| 5 | Execution | One subagent per task |
| 6 | Review | Spec compliance + Code quality |
| 7 | Continuation | Loop until complete |
| 8-9 | Finishing | Tests, merge/cleanup |

## Red Flags - STOP and Ask

- Requirements fundamentally unclear after 3 questions
- Tests fail repeatedly with no progress
- Subagent stuck in loop

## Common Pitfalls

### Pitfall 1: Ultrawork for Trivial Tasks
**Symptom:** User triggers ultrawork for a one-line fix or config change.
**Consequence:** 9-phase overhead (worktree, TDD, two-stage review) for 30 seconds of work. Wastes tokens and time.
**Fix:** Phase 1 (Task Analysis) should detect SIMPLE and auto-downgrade to quick-fix mode.

### Pitfall 2: Infinite Subagent Loop
**Symptom:** Subagent retries the same failing approach repeatedly without progress.
**Consequence:** Burns through max iterations (50) without producing working code.
**Fix:** After 3 consecutive failures on the same task, stop and escalate to user. This is a Red Flag.

### Pitfall 3: Skipping Review Under Time Pressure
**Symptom:** Agent marks tasks as done without running Phase 6 review because "it looks correct."
**Consequence:** Silent bugs, spec drift, technical debt accumulates.
**Fix:** Review is non-negotiable. Spec compliance + code quality are always executed.

## Dependencies

| Skill | Phase | Purpose |
|-------|-------|---------|
| `confidence-gate` | 0 | Pre-execution confidence check |
| `tdd-enforcement` | 4-5 | TDD discipline |
| `spec-compliance-review` | 6 | Stage 1 review |
| `code-reviewer` | 6 | Stage 2 review |
| `git-worktree` | 3 | Task isolation |
| `task-templates` | 4 | Fine-grained planning |
| `subagent-driven-development` | 5 | Atomic task execution |
| `mcp-integration` | 0 | Context7/Tavily for research |

## References

- **[phase-details.md](references/phase-details.md)** - Detailed phase implementation

## Version History

| Version | Changes |
|---------|---------|
| 5.2.4 | Split detailed docs to references/ |
| 5.2.0 | Added Agent Teams integration |
| 5.0.0 | Initial release with 9-phase workflow |