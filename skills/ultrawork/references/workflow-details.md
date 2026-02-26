# Ultrawork Autonomous Workflow Reference

## Codebox Structure

```
codebox/
├── spec.md              # Requirements specification
├── plan.md              # Implementation plan with tasks
└── changes/
    ├── active.md        # Current progress tracking
    └── completed.md     # Archive of completed work
```

## Phase Overview

| Phase | Name | Purpose | Output |
|-------|------|---------|--------|
| 0 | Confidence Gate | Pre-execution confidence check | ≥90% to proceed |
| 1 | Analyze | Detect task complexity | SIMPLE/MEDIUM/COMPLEX |
| 2 | Clarify | Ask questions if ambiguous | Clear requirements |
| 3 | Isolate | Create worktree + codebox | Isolated environment |
| 4 | Plan | Generate atomic tasks | plan.md, TaskCreate |
| 5 | Execute | Dispatch subagents | Implementation |
| 6 | Review | Two-stage review | Spec + Quality pass |
| 7 | Continue | Enforce completion | TaskUpdate, active.md |
| 8 | Finish | Merge and cleanup | Clean merge |
| 9 | Done | Output promise | `<promise>DONE</promise>` |

## File Purposes

### spec.md (Requirements)

- **Purpose**: Single source of truth for what needs to be built
- **Created**: Phase 3 (Worktree Setup)
- **Updated**: Never (requirements locked after clarification)
- **Used by**: Phase 6 (Spec Compliance Review)

### plan.md (Implementation Plan)

- **Purpose**: Task breakdown with TDD steps
- **Created**: Phase 4 (Plan Generation)
- **Updated**: As tasks are refined
- **Used by**: Phase 5 (Subagent Execution)

### active.md (Progress Tracking)

- **Purpose**: Real-time task status
- **Created**: Phase 3 (Codebox Setup)
- **Updated**: After each task completion
- **Used by**: Phase 7 (Continuation Enforcement)

### completed.md (Archive)

- **Purpose**: Historical record of completed work
- **Created**: Phase 8 (Finishing)
- **Updated**: Once at completion
- **Used by**: Phase 9 (Summary)

## Task Tracking Integration

### Using Task Tool

```yaml
# Phase 4: Create tasks
TaskCreate(subject: "Task 1: Setup")
TaskCreate(subject: "Task 2: Implement")

# Phase 5: During execution
TaskUpdate(taskId: "1", status: "in_progress")
# ... do work ...
TaskUpdate(taskId: "1", status: "completed")

# Phase 7: Check remaining
TaskList()  # Returns pending tasks
```

### Using active.md

```markdown
# Active Tasks

## Current Sprint

### In Progress
- [ ] Task 3: History Tracking ← current task

### Pending
- [ ] Task 4: Error Handling
- [ ] Task 5: Documentation

### Completed
- [x] Task 1: Setup ✅
- [x] Task 2: Core Implementation ✅

---
Status: IN_PROGRESS
Last Updated: 2026-02-26T15:30:00
```

## Hook Integration

### todo-continuation-enforcer.sh

The Stop hook checks:
1. Is there a `<promise>DONE</promise>` in last output?
2. Are there pending tasks in TaskList?
3. Are there unchecked items in codebox/changes/active.md?

If any tasks are incomplete:
- Block exit with Sisyphus message
- Force continuation until all complete

## Best Practices

### 1. Lock Requirements Early
- Complete Phase 2 thoroughly
- Don't change spec.md after Phase 4
- If requirements change, restart from Phase 2

### 2. Atomic Tasks
- Each task: 2-5 minutes
- Single file or tightly coupled files
- Clear success criteria
- Independent where possible

### 3. Parallel Execution
- Tasks without dependencies → run in parallel
- Use multiple Task Tool calls in single message
- Wait for all before Phase 6

### 4. Review Before Merge
- Always run both review stages
- Fix CRITICAL issues before merge
- IMPORTANT issues → user choice

### 5. Clean Completion
- Update all active.md checkboxes
- Fill completed.md summary
- Output `<promise>DONE</promise>`
- Allow Stop hook to pass