# Context Compression Example

## Scenario: Complex Feature with Multiple Subagents

You're implementing a Calculator module with 8 tasks. After Task 3 completes, context is bloating.

### Before Compression

```
Main Context Contains:
- Task 1 result: 200 lines (setup details)
- Task 2 result: 300 lines (utils implementation)
- Task 3 result: 250 lines (core implementation)
- Current task: Task 4 in progress

Total: ~750 lines of completed work
```

### Trigger Compression

```
User: "compress context"

or automatic trigger after 3 subagents complete
```

### After Compression

```markdown
## Completed Tasks (Archived)

### Task 1: Setup ✅
**Files**: `package.json`, `src/index.ts`
**Changes**: Added decimal.js dependency, created project structure
**Tests**: N/A (setup only)
**Archive**: `codebox/archive/task-1.md`

### Task 2: Utils Implementation ✅
**Files**: `src/utils.ts`
**Changes**: Implemented precise(), toNumber(), round() functions using decimal.js
**Tests**: 4/4 passing
**Archive**: `codebox/archive/task-2.md`

### Task 3: Core Implementation ✅
**Files**: `src/calculator.ts`
**Changes**: Implemented Calculator class with add, subtract, multiply, divide, modulo
**Tests**: 10/10 passing
**Archive**: `codebox/archive/task-3.md`

## Current Task
Task 4: Error Handling (in progress)
```

### Result

- Before: 750 lines
- After: 30 lines
- Reduction: 96%
- Full details preserved in archive files

## Archive File Example

```markdown
# codebox/archive/task-2.md

## Task 2: Utils Implementation

### Full Implementation

```typescript
import Decimal from 'decimal.js';

export function precise(value: number): Decimal {
    return new Decimal(value);
}

export function toNumber(decimal: Decimal): number {
    return decimal.toNumber();
}

export function round(value: Decimal | number, decimals: number): number {
    const d = value instanceof Decimal ? value : new Decimal(value);
    return d.toDecimalPlaces(decimals).toNumber();
}
```

### Test Output

```
✓ precise(0.1).plus(0.2).toNumber() === 0.3
✓ round(3.14159, 2) === 3.14
✓ round(3.14159, 4) === 3.1416
✓ toNumber(precise(100)) === 100

Tests: 4 passed, 0 failed
```

### Timestamp
2026-02-26T15:30:00Z
```

## Integration with Ultrawork

In Phase 5 (Execute), after each subagent completes:

1. **Immediate**: Extract 1-2 sentence summary
2. **Archive**: Write full result to `codebox/archive/task-N.md`
3. **Update**: Mark task complete in `active.md` with summary only
4. **Continue**: Next subagent gets clean context

This keeps the main context focused on current work, not past history.