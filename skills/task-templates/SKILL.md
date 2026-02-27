---
name: task-templates
description: |
  This skill should be used when breaking down features into implementation tasks. It provides
  fine-grained task templates ensuring each task is 2-5 minutes of focused work. Triggers on
  "task breakdown", "create tasks", "任务分解", "task template", "granular tasks".
  Borrowed from Superpowers pattern of atomic TDD steps.
version: 5.1.11
status: experimental
triggers:
  - task breakdown
  - create tasks
  - 任务分解
  - task template
  - granular tasks
  - atomic tasks
  - fine-grained tasks
---

# Task Templates: Fine-Grained Implementation

> **Adapted from Superpowers by obra** - Each task should be 2-5 minutes of focused work.

## 触发词

此技能触发于: "task breakdown", "create tasks", "任务分解", "task template", "granular tasks".

## Core Principle

```
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   EACH TASK: 2-5 minutes of focused work                      ║
║                                                               ║
║   If a task takes longer → break it down further              ║
║   If a task seems trivial → it's probably right               ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

## Why Fine-Grained Tasks

| 问题 | 粗粒度任务 | 细粒度任务 |
|------|-----------|-----------|
| 进度追踪 | 难以衡量 | 清晰可见 |
| 错误定位 | 大范围回滚 | 精确修复 |
| 审查负担 | 大量代码一次审 | 小批量频繁审 |
| 上下文切换 | 思路容易断 | 完成一个再下一个 |
| TDD 纪律 | 容易跳过 | 强制执行 |

## Task Granularity Examples

### ❌ Bad: Too Coarse

```markdown
- [ ] Implement user authentication
- [ ] Add login page
- [ ] Create API endpoints
```

### ✅ Good: Fine-Grained

```markdown
### Feature: User Login

#### Task 1: Write failing test for login endpoint
- [ ] 1.1 Create test file `tests/api/login.test.ts`
- [ ] 1.2 Write test: valid credentials return JWT
- [ ] 1.3 Run test → verify it fails with "not found"

#### Task 2: Implement minimal login endpoint
- [ ] 2.1 Create route handler `app/api/login/route.ts`
- [ ] 2.2 Implement credential validation
- [ ] 2.3 Run test → verify it passes
- [ ] 2.4 Commit: "feat(auth): add login endpoint"

#### Task 3: Write failing test for invalid credentials
- [ ] 3.1 Add test: invalid password returns 401
- [ ] 3.2 Run test → verify it fails

#### Task 4: Handle invalid credentials
- [ ] 4.1 Add error handling for invalid password
- [ ] 4.2 Run test → verify it passes
- [ ] 4.3 Commit: "feat(auth): handle invalid credentials"
```

## Standard Task Templates

### Template 1: New Function/Method

```markdown
### Task N: Add [function-name] function

#### N.1 Write failing test
- [ ] Create test in `tests/[module].test.ts`
- [ ] Write test for happy path
- [ ] Run test → expect FAIL

#### N.2 Implement minimal code
- [ ] Create/update `src/[module].ts`
- [ ] Write minimum code to pass
- [ ] Run test → expect PASS

#### N.3 Add edge case tests
- [ ] Write test for edge case 1
- [ ] Run test → expect FAIL
- [ ] Implement handling
- [ ] Run test → expect PASS

#### N.4 Commit
- [ ] Stage changes
- [ ] Commit: "feat([scope]): add [description]"
```

### Template 2: Bug Fix

```markdown
### Task N: Fix [bug-description]

#### N.1 Reproduce with test
- [ ] Write test that exposes the bug
- [ ] Run test → expect FAIL (confirms bug exists)

#### N.2 Fix the bug
- [ ] Identify root cause in `[file]:[line]`
- [ ] Apply minimal fix
- [ ] Run test → expect PASS

#### N.3 Verify no regression
- [ ] Run full test suite
- [ ] All tests pass

#### N.4 Commit
- [ ] Commit: "fix([scope]): [description]"
```

### Template 3: Refactoring

```markdown
### Task N: Refactor [target]

#### N.1 Ensure test coverage
- [ ] Verify existing tests cover behavior
- [ ] Add missing tests if needed
- [ ] Run tests → all PASS

#### N.2 Refactor
- [ ] Apply refactoring in small steps
- [ ] Run tests after each step
- [ ] All tests must stay green

#### N.3 Commit
- [ ] Commit: "refactor([scope]): [description]"
```

### Template 4: API Endpoint

```markdown
### Task N: Add [endpoint] API

#### N.1 Write failing test for success case
- [ ] Create `tests/api/[endpoint].test.ts`
- [ ] Write test for 200 response
- [ ] Run test → FAIL

#### N.2 Implement endpoint
- [ ] Create `app/api/[endpoint]/route.ts`
- [ ] Implement handler
- [ ] Run test → PASS

#### N.3 Add validation test
- [ ] Write test for 400 on invalid input
- [ ] Run test → FAIL
- [ ] Add input validation
- [ ] Run test → PASS

#### N.4 Add auth test (if needed)
- [ ] Write test for 401 on unauthorized
- [ ] Run test → FAIL
- [ ] Add auth middleware
- [ ] Run test → PASS

#### N.5 Commit
- [ ] Commit: "feat(api): add [endpoint] endpoint"
```

### Template 5: UI Component

```markdown
### Task N: Create [component] component

#### N.1 Write component test
- [ ] Create `tests/components/[component].test.tsx`
- [ ] Write render test
- [ ] Run test → FAIL

#### N.2 Implement basic component
- [ ] Create `components/[component].tsx`
- [ ] Implement minimal JSX
- [ ] Run test → PASS

#### N.3 Add interaction test
- [ ] Write test for user interaction
- [ ] Run test → FAIL
- [ ] Implement interaction handler
- [ ] Run test → PASS

#### N.4 Style component
- [ ] Add Tailwind/CSS classes
- [ ] Visual verification

#### N.5 Commit
- [ ] Commit: "feat(ui): add [component] component"
```

## Task Breakdown Checklist

Before finalizing tasks, verify:

- [ ] **Each task is 2-5 minutes** - If longer, break down further
- [ ] **Each task has clear outcome** - Can verify success/failure
- [ ] **TDD steps are explicit** - Write test, run, implement, run, commit
- [ ] **Dependencies are linear** - Task N+1 depends on Task N
- [ ] **Commit points are defined** - Every 1-3 tasks has a commit

## Integration with ultrawork

```yaml
ultrawork Phase 4 (PLAN):
  input: Design approval
  output: tasks.md with fine-grained tasks

  steps:
    1. Identify major components from design
    2. Break each component into 2-5 minute tasks
    3. Add TDD steps to each task
    4. Define commit points
    5. Create tasks.md following templates above
```

## Red Flags

**Task too big:**
- "Implement the feature"
- "Add all validation"
- "Create the module"

**Task too vague:**
- "Make it work"
- "Fix the bug"
- "Improve performance"

**Missing TDD steps:**
- No "Write test" step
- No "Run test" step
- No explicit pass/fail expectations

## Agent Collaboration

| Agent | Role |
|-------|------|
| `ultrawork` | Uses templates in Phase 4 (PLAN) |
| `task-decomposer` | Applies templates to break down work |
| `subagent-driven-development` | Dispatches one subagent per task |

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 5.0.14 | 2026-02-09 | Initial release, borrowed from Superpowers |
