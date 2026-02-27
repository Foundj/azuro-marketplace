---
name: task-dependency-analyzer
description: |
  This skill should be used when analyzing task dependencies and determining optimal execution order.
  It builds a dependency graph from plan.md, identifies parallelizable tasks, and outputs execution
  recommendations. Use when the user mentions "dependencies", "parallel", "execution order", "任务依赖",
  "并行执行", or when planning multi-task implementation.
version: 5.1.13
status: experimental
triggers:
  - task dependencies
  - dependency analysis
  - parallel execution
  - execution order
  - 任务依赖
  - 并行执行
  - optimize tasks
  - dependency graph
---

# Task Dependency Analyzer

> Analyze task dependencies to maximize parallel execution efficiency.

## 触发词

此技能触发于: "task dependencies", "dependency analysis", "任务依赖", "并行执行", "execution order".

## Core Concept

```
┌─────────────────────────────────────────────────────────────┐
│                    DEPENDENCY ANALYSIS                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Tasks with NO dependencies → Execute in PARALLEL            │
│  Tasks with dependencies → Execute SEQUENTIALLY               │
│                                                              │
│  Input: plan.md with N tasks                                  │
│  Output: Optimal execution graph                              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Dependency Detection

### File-Based Dependencies

```yaml
# Detect dependencies from file mentions

Task 1: "Create src/types.ts"
  Files: +src/types.ts

Task 2: "Create src/utils.ts"
  Files: +src/utils.ts

Task 3: "Create src/api.ts using types and utils"
  Files: +src/api.ts
  Reads: src/types.ts, src/utils.ts  # Dependencies detected!

Dependency Graph:
  Task 1 ──┐
           ├──→ Task 3
  Task 2 ──┘

Parallel Execution:
  Wave 1: Task 1, Task 2 (parallel)
  Wave 2: Task 3 (after 1 and 2 complete)
```

### Import-Based Dependencies

```yaml
# Detect dependencies from import statements

Task 1: "Implement UserService"
  Code: import { User } from './types'

Task 2: "Implement types.ts"
  Files: +src/types.ts

Dependency: Task 1 depends on Task 2 (types.ts)
```

### Test Dependencies

```yaml
# Detect dependencies from test file references

Task 1: "Implement feature.ts"
  Files: +src/feature.ts

Task 2: "Test feature.ts"
  Files: +tests/feature.test.ts
  Reads: src/feature.ts

Dependency: Task 2 depends on Task 1
```

## Analysis Algorithm

### Step 1: Parse Plan.md

```markdown
# Extract from plan.md

### Task 1: Setup
**Files:** +package.json, +tsconfig.json

### Task 2: Types
**Files:** +src/types.ts

### Task 3: Utils
**Files:** +src/utils.ts

### Task 4: API
**Files:** +src/api.ts
**Dependencies:** types.ts, utils.ts
```

### Step 2: Build Dependency Graph (DAG)

```yaml
Nodes: [Task 1, Task 2, Task 3, Task 4]

Edges:
  Task 1 → Task 2 (implicit: Task 2 needs project setup)
  Task 1 → Task 3 (implicit: Task 3 needs project setup)
  Task 2 → Task 4 (explicit: api.ts uses types.ts)
  Task 3 → Task 4 (explicit: api.ts uses utils.ts)
```

### Step 3: Topological Sort

```yaml
Wave 1 (no dependencies):
  - Task 1: Setup

Wave 2 (depends on Wave 1):
  - Task 2: Types (can parallel with Task 3)
  - Task 3: Utils (can parallel with Task 2)

Wave 3 (depends on Wave 2):
  - Task 4: API (needs both Task 2 and Task 3)
```

### Step 4: Generate Execution Plan

```yaml
Execution Plan:
  ┌─────────────────────────────────────┐
  │  Wave 1: [Task 1]                    │
  │    ↓                                  │
  │  Wave 2: [Task 2, Task 3] (parallel) │
  │    ↓                                  │
  │  Wave 3: [Task 4]                    │
  │    ↓                                  │
  │  Wave 4: [Tests]                     │
  └─────────────────────────────────────┘

Estimated Time:
  - Sequential: 4 × avg_task_time
  - Parallel: 3 × avg_task_time (25% faster)
```

## Output Format

### Dependency Report

```
╔═══════════════════════════════════════════════════════════════╗
║                    DEPENDENCY ANALYSIS REPORT                    ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Total Tasks: 8                                                ║
║  Independent: 3 (can run in parallel)                         ║
║  Dependent: 5 (sequential dependencies)                       ║
║                                                               ║
║  PARALLELIZATION OPPORTUNITY:                                  ║
║  Sequential execution: 8 waves                                ║
║  Parallel execution: 4 waves (50% faster)                     ║
║                                                               ║
╠═══════════════════════════════════════════════════════════════╣
║                    EXECUTION WAVES                              ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Wave 1 (parallel):                                           ║
║    - Task 1: Setup (no deps)                                  ║
║                                                               ║
║  Wave 2 (parallel):                                           ║
║    - Task 2: Types (dep: Task 1)                              ║
║    - Task 3: Utils (dep: Task 1)                              ║
║    - Task 4: Config (dep: Task 1)                             ║
║                                                               ║
║  Wave 3 (parallel):                                           ║
║    - Task 5: API Core (dep: Task 2, 3)                        ║
║    - Task 6: API Routes (dep: Task 2, 4)                      ║
║                                                               ║
║  Wave 4 (sequential):                                         ║
║    - Task 7: Integration Tests (dep: Task 5, 6)              ║
║    - Task 8: Documentation (dep: Task 5, 6)                  ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

### Parallel Dispatch Example

```yaml
# Wave 1: Single task
Task({ description: "Task 1: Setup", subagent_type: "general-purpose" })

# Wait for Wave 1...

# Wave 2: Parallel dispatch (3 tasks at once)
Task({ description: "Task 2: Types", subagent_type: "general-purpose" })
Task({ description: "Task 3: Utils", subagent_type: "general-purpose" })
Task({ description: "Task 4: Config", subagent_type: "general-purpose" })

# Wait for all Wave 2 tasks...

# Wave 3: Parallel dispatch (2 tasks)
Task({ description: "Task 5: API Core", subagent_type: "general-purpose" })
Task({ description: "Task 6: API Routes", subagent_type: "general-purpose" })

# Wave 4: Sequential (or parallel if independent)
Task({ description: "Task 7: Tests", subagent_type: "general-purpose" })
Task({ description: "Task 8: Docs", subagent_type: "general-purpose" })
```

## Integration with Ultrawork

### Phase 4: Plan Generation Enhancement

```yaml
After generating plan.md:
  1. Run dependency analyzer on plan.md
  2. Identify parallel execution waves
  3. Update plan.md with execution order
  4. Use waves for Task dispatch in Phase 5
```

### Enhanced Plan.md Format

```markdown
### Task 1: Setup
**Files:** +package.json, +tsconfig.json
**Dependencies:** (none)
**Wave:** 1

### Task 2: Types
**Files:** +src/types.ts
**Dependencies:** Task 1
**Wave:** 2 (parallel with Task 3, 4)

### Task 3: Utils
**Files:** +src/utils.ts
**Dependencies:** Task 1
**Wave:** 2 (parallel with Task 2, 4)
```

## Dependency Patterns

### Common Patterns

```yaml
# Pattern 1: Linear Chain
Task A → Task B → Task C → Task D
Result: 4 sequential waves, no parallelization

# Pattern 2: Fan-Out
Task A → [Task B, Task C, Task D]
Result: 2 waves, 3 tasks in parallel

# Pattern 3: Fan-In
[Task A, Task B] → Task C
Result: 2 waves, 2 tasks in wave 1

# Pattern 4: Diamond
Task A → [Task B, Task C] → Task D
Result: 3 waves, B and C parallel

# Pattern 5: Independent
[Task A, Task B, Task C, Task D] (all independent)
Result: 1 wave, all parallel
```

## Red Flags

**Never:**
- Ignore explicit dependencies in task descriptions
- Run dependent tasks before their dependencies
- Assume all tasks are independent
- Skip dependency analysis for "simple" plans

**Always:**
- Parse file references in task descriptions
- Check import statements in code
- Verify test file dependencies
- Output parallel execution recommendations

## Integration with Other Skills

| Skill | Integration |
|-------|-------------|
| `ultrawork` | Use waves for Phase 5 dispatch |
| `task-templates` | Add dependency hints to templates |
| `subagent-driven-development` | Parallel dispatch by wave |
| `context-compressor` | Compress after each wave |

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 5.0.20 | 2026-02-27 | Added Chinese triggers and dependencies |
| 5.0.18 | 2026-02-26 | Initial release with DAG analysis and wave optimization |

---

## Dependencies

- Requires `plan.md` with task definitions
- Works with `ultrawork` for parallel dispatch
- Integrates with `subagent-driven-development`