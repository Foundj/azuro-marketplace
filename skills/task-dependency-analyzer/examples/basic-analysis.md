# Dependency Analysis Example

## Scenario: API Module Implementation

Given a plan.md with the following tasks:

```markdown
### Task 1: Create types.ts
**Files:** +src/types.ts
**Dependencies:** None

### Task 2: Create utils.ts
**Files:** +src/utils.ts
**Dependencies:** None

### Task 3: Create api.ts
**Files:** +src/api.ts
**Dependencies:** types.ts, utils.ts
**Imports:**
```typescript
import { User, Post } from './types';
import { formatDate, parseJSON } from './utils';
```

### Task 4: Create routes.ts
**Files:** +src/routes.ts
**Dependencies:** api.ts
**Imports:**
```typescript
import { fetchUsers, fetchPosts } from './api';
```

### Task 5: Create tests
**Files:** +tests/api.test.ts
**Dependencies:** api.ts
```

## Analysis Process

### Step 1: Extract File Dependencies

```yaml
Task 1: Creates types.ts
  Output files: [types.ts]
  Input files: []

Task 2: Creates utils.ts
  Output files: [utils.ts]
  Input files: []

Task 3: Creates api.ts
  Output files: [api.ts]
  Input files: [types.ts, utils.ts]  # From imports

Task 4: Creates routes.ts
  Output files: [routes.ts]
  Input files: [api.ts]  # From imports

Task 5: Creates tests
  Output files: [tests/api.test.ts]
  Input files: [api.ts]  # Tests need the module
```

### Step 2: Build Dependency Graph (DAG)

```
     Task 1 ────────┐
        │            │
        └──→ Task 3 ←┘
             │
     Task 2 ────────┘
        │
        └──→ Task 3
             │
             └──→ Task 4
                    │
                    └──→ Task 5
```

### Step 3: Topological Sort

```
Wave 1 (no dependencies):
  - Task 1: types.ts
  - Task 2: utils.ts

Wave 2 (depends on Wave 1):
  - Task 3: api.ts

Wave 3 (depends on Wave 2):
  - Task 4: routes.ts
  - Task 5: tests/api.test.ts

Wave 4 (depends on Wave 3):
  - (none, all complete)
```

### Step 4: Execution Plan

```yaml
Parallel Execution:
  Wave 1:
    - Run Task 1 and Task 2 in parallel (no dependencies)
    - Wait for both to complete

  Wave 2:
    - Run Task 3 (needs Task 1 and Task 2)
    - Wait for completion

  Wave 3:
    - Run Task 4 and Task 5 in parallel (both need Task 3)
    - Wait for both to complete

Estimated Time:
  Sequential: 5 × avg_task_time
  Parallel: 3 × avg_task_time (40% faster)
```

## Dependency Patterns

### Pattern 1: Linear Chain
```
A → B → C → D
Result: 4 sequential waves
```

### Pattern 2: Fan-Out
```
    A
   /|\
  B C D
Result: 2 waves (A, then B/C/D parallel)
```

### Pattern 3: Fan-In
```
B C D
 \|/
  A
Result: 2 waves (B/C/D parallel, then A)
```

### Pattern 4: Diamond
```
    A
   / \
  B   C
   \ /
    D
Result: 3 waves (A, B/C parallel, D)
```

### Pattern 5: Independent
```
A B C D (no connections)
Result: 1 wave (all parallel)
```

## Output Format

```
╔═══════════════════════════════════════════════════════════════╗
║                    DEPENDENCY ANALYSIS REPORT                         ║
╠═══════════════════════════════════════════════════════════════╣
║                                                                   ║
║  Total Tasks: 5                                                    ║
║  Independent: 2 (can run in parallel)                             ║
║  Dependent: 3 (sequential dependencies)                           ║
║                                                                   ║
║  PARALLELIZATION OPPORTUNITY:                                       ║
║  Sequential execution: 5 waves                                    ║
║  Parallel execution: 3 waves (40% faster)                          ║
║                                                                   ║
╠═══════════════════════════════════════════════════════════════╣
║                    EXECUTION WAVES                                   ║
╠═══════════════════════════════════════════════════════════════╣
║                                                                   ║
║  Wave 1 (parallel):                                               ║
║    - Task 1: Create types.ts                                       ║
║    - Task 2: Create utils.ts                                       ║
║                                                                   ║
║  Wave 2 (sequential):                                             ║
║    - Task 3: Create api.ts (needs types.ts, utils.ts)             ║
║                                                                   ║
║  Wave 3 (parallel):                                               ║
║    - Task 4: Create routes.ts (needs api.ts)                       ║
║    - Task 5: Create tests (needs api.ts)                           ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════╝
```