---
name: ai:implement
description: AI-powered implementation - autonomous OODA loop execution
argument-hint: "<feature-description> [--from-design] [--quick]"
allowed-tools: Task, Read, Write, Edit, Grep, Glob, Bash
internal: true
---

Implement: $ARGUMENTS

**Goal**: Autonomous implementation using OODA loop until completion

**Step 1: Pre-Implementation Check (Phase 0)**

**CRITICAL**: Before any implementation, run knowledge pre-check:

```
/ai:check $ARGUMENTS
```

This validates:
1. **No Duplicates**: Check if feature already exists in `feature-index.json`
2. **Related Code**: Find existing implementations to reference
3. **Constraints**: Load coding patterns and conventions
4. **Conflicts**: Identify potential issues before starting

**If check returns warnings**:
- Review existing implementations
- Confirm with user before proceeding
- Decide: extend existing vs create new

**Step 2: Load Context**

1. Check for existing artifacts:
   - If `--from-design`: Load `proposal.md` and `design.md`
   - If `--quick`: Skip to direct implementation
   - Otherwise: Quick task analysis

2. Load project context:
   - `codebox/project-snapshot.json`
   - Relevant code files
   - Pre-check report (from Step 1)

**Step 3: Task Breakdown**

Generate `tasks.md`:

```markdown
# Implementation Tasks

## Prerequisites
- [ ] Task 0: Setup/preparation

## Core Implementation
- [ ] Task 1: [Description]
  - Subtask 1.1
  - Subtask 1.2
- [ ] Task 2: [Description]

## Integration
- [ ] Task 3: Wire up components

## Verification
- [ ] Task 4: Add/update tests
- [ ] Task 5: Manual verification
```

**Step 4: OODA Execution Loop**

Execute autonomous loop (max 50 iterations):

```
┌─────────────────────────────────────┐
│  OBSERVE: Check current state       │
│  - Read relevant files              │
│  - Check task progress              │
│  - Identify blockers                │
├─────────────────────────────────────┤
│  ORIENT: Analyze situation          │
│  - What's done vs remaining         │
│  - Dependencies satisfied?          │
│  - Any issues to resolve?           │
├─────────────────────────────────────┤
│  DECIDE: Choose next action         │
│  - Pick next task from tasks.md     │
│  - Determine implementation steps   │
├─────────────────────────────────────┤
│  ACT: Execute the change            │
│  - Write/edit code                  │
│  - Update task checkbox             │
│  - Commit checkpoint if significant │
└─────────────────────────────────────┘
         ↓
    All tasks done?
    ├── No → Continue loop
    └── Yes → <promise>DONE</promise>
```

**Step 5: Progress Tracking**

Update `tasks.md` checkboxes as completed:
- `[ ]` → `[x]` when done
- Add notes for complex tasks

**Step 6: Completion**

When all tasks complete:
1. Output `<promise>DONE</promise>`
2. Summary of changes:
   - Files modified
   - Tests added/updated
   - Any remaining TODOs

**Next Step**:
> 实现完成后，运行 `/ai:review` 进行代码审查。
