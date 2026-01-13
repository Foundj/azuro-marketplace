---
name: code-simplifier
description: |
  This skill simplifies and refines code for clarity, consistency, and maintainability while preserving
  all functionality. It includes SOLID principles checking, complexity metrics analysis, and refactoring
  pattern recommendations. Use when the user mentions "simplify code", "refine code", "clean up code",
  "refactor", "reduce complexity", "technical debt", "代码简化", "代码重构", "技术债务", or after code review passes.
version: 4.2.1
triggers:
  - simplify code
  - refine code
  - clean up code
  - polish code
  - improve readability
  - refactor
  - reduce complexity
  - technical debt
  - 代码简化
  - 代码优化
  - 整理代码
  - 代码重构
  - 技术债务
---

# Code Simplifier & Refactoring Expert

> Expert code simplification with SOLID principles, complexity metrics, and refactoring patterns.

## Quick Start

```bash
@code-simplifier review recent changes    # Simplify recently modified code
@code-simplifier refine src/api/          # Simplify specific directory
@code-simplifier solid-check src/         # Check SOLID principles compliance
@code-simplifier metrics src/utils.ts     # Analyze complexity metrics
```

## Core Principles

### 1. Preserve Functionality
- Never change what the code does - only how it does it
- All original features, outputs, and behaviors must remain intact

### 2. Apply Project Standards
Follow established coding standards from CLAUDE.md:
- ES modules with proper import sorting
- Prefer `function` keyword over arrow functions
- Explicit return type annotations
- Proper React component patterns
- Consistent naming conventions

### 3. Enhance Clarity
- Reduce unnecessary complexity and nesting
- Eliminate redundant code and abstractions
- Improve variable and function names
- Remove unnecessary comments
- **Avoid nested ternaries** - prefer switch/if-else

### 4. Maintain Balance
Avoid over-simplification that could:
- Reduce code clarity or maintainability
- Create overly clever solutions
- Combine too many concerns
- Remove helpful abstractions
- Prioritize "fewer lines" over readability

---

## SOLID Principles Checking

### S - Single Responsibility Principle
```yaml
check: Does each class/function have one reason to change?
symptoms:
  - Class with multiple unrelated methods
  - Function doing more than one thing
  - God objects with too many responsibilities
fix: Extract into focused, cohesive units
```

### O - Open/Closed Principle
```yaml
check: Is code open for extension but closed for modification?
symptoms:
  - Switch statements on type
  - Repeated if-else chains checking type
  - Modifying existing code to add features
fix: Use polymorphism, strategy pattern, or composition
```

### L - Liskov Substitution Principle
```yaml
check: Can subtypes replace their base types?
symptoms:
  - Subclass overrides breaking parent behavior
  - Empty method implementations in subclasses
  - Type checks before method calls
fix: Redesign inheritance hierarchy or use composition
```

### I - Interface Segregation Principle
```yaml
check: Are interfaces focused and minimal?
symptoms:
  - Interfaces with many unrelated methods
  - Implementing classes with empty methods
  - "Fat" interfaces
fix: Split into smaller, role-specific interfaces
```

### D - Dependency Inversion Principle
```yaml
check: Do high-level modules depend on abstractions?
symptoms:
  - Direct instantiation of dependencies
  - Hardcoded concrete class references
  - Tight coupling between modules
fix: Inject dependencies, depend on interfaces
```

---

## Complexity Metrics

### Cyclomatic Complexity
```
Target: < 10 per function

Calculation:
- Start with 1
- +1 for each: if, else if, for, while, case, catch, &&, ||, ?:

Levels:
  1-5   : ✅ Simple, easy to test
  6-10  : 🟡 Moderate, consider splitting
  11-20 : 🟠 Complex, should refactor
  21+   : 🔴 Very complex, must refactor
```

### Cognitive Complexity
```
Target: < 15 per function

Factors:
- Nesting depth (exponential penalty)
- Control flow breaks (continue, break, goto)
- Recursion
- Boolean logic complexity
```

### Function Length
```
Target: < 50 lines

Guidelines:
  < 20 lines : ✅ Ideal
  20-50 lines: 🟡 Acceptable
  50+ lines  : 🔴 Too long, extract methods
```

### Code Duplication
```
Target: No duplicate blocks > 10 lines

Detection:
- Exact duplicates
- Near-duplicates (renamed variables)
- Structural duplicates (same logic, different types)
```

---

## Refactoring Patterns Catalog

### Extract Method
```
When: Function too long, code block with comment
Before: Large function with multiple responsibilities
After: Multiple focused functions with descriptive names
```

### Replace Conditional with Polymorphism
```
When: Switch on type, repeated type checks
Before: switch(type) { case 'A': ...; case 'B': ... }
After: type.execute() using interface/abstract class
```

### Introduce Parameter Object
```
When: Function has > 3 related parameters
Before: function(x, y, width, height)
After: function(rect: Rectangle)
```

### Replace Temp with Query
```
When: Temp variable used once after calculation
Before: const total = price * qty; return total;
After: return calculateTotal(price, qty);
```

### Decompose Conditional
```
When: Complex boolean condition
Before: if (date.before(SUMMER_START) || date.after(SUMMER_END))
After: if (isNotSummer(date))
```

### Replace Magic Number with Constant
```
When: Literal number in code
Before: if (age >= 18)
After: if (age >= LEGAL_ADULT_AGE)
```

## Refinement Process

```
┌─────────────────────────────────────────────────────────┐
│           ENHANCED SIMPLIFICATION FLOW                   │
├─────────────────────────────────────────────────────────┤
│  1. IDENTIFY target code                                │
│     - Recently modified files (git diff)                │
│     - Specified directories/files                       │
│                    ↓                                    │
│  2. MEASURE complexity metrics                          │
│     - Cyclomatic complexity per function                │
│     - Cognitive complexity score                        │
│     - Function length analysis                          │
│     - Duplication detection                             │
│                    ↓                                    │
│  3. CHECK SOLID principles                              │
│     - Single Responsibility violations                  │
│     - Open/Closed compliance                            │
│     - Dependency Inversion issues                       │
│                    ↓                                    │
│  4. APPLY refactoring patterns                          │
│     - Select appropriate patterns                       │
│     - Preserve functionality                            │
│     - Follow project standards                          │
│                    ↓                                    │
│  5. VERIFY and REPORT                                   │
│     - Before/after metrics comparison                   │
│     - Behavior validation                               │
│     - Generate improvement report                       │
└─────────────────────────────────────────────────────────┘
```

---

## Output: Simplification Report

```markdown
# Code Simplification Report

## Metrics Summary
| File | Before CC | After CC | Δ | Status |
|------|-----------|----------|---|--------|
| src/api/users.ts | 15 | 8 | -7 | ✅ Improved |
| src/utils/format.ts | 22 | 10 | -12 | ✅ Improved |

## SOLID Violations Fixed
1. **SRP**: Extracted `validateUser()` from `createUser()`
2. **DIP**: Introduced `IUserRepository` interface

## Refactoring Applied
- Extract Method: 3 instances
- Decompose Conditional: 2 instances
- Replace Magic Number: 5 instances

## Technical Debt Reduced
- Lines removed: 45
- Duplication eliminated: 2 blocks
- Complexity reduction: 35%
```

## Integration with ai-dev Workflow

Runs after Phase 5 (Quality Validation) when quality gate passes:

```
Phase 5: Quality Validation
         ↓
    Gate Pass?
    ├── No → Fix issues, re-run Phase 5
    └── Yes ↓

code-simplifier (Optional)
  - Refine approved code
  - Apply final polish
  - Ensure consistency
         ↓

Phase 6: Finalization
  - Commit ready code
```

## Configuration

Enable auto-simplification in `codebox/config.json`:

```json
{
  "quality": {
    "autoSimplify": true,
    "simplifyScope": "recent",  // "recent" | "changed" | "all"
    "preserveComments": false
  }
}
```

## Examples

### Before
```typescript
const getUserData = async (id: string) => {
  try {
    const response = await fetch(`/api/users/${id}`);
    if (response.ok) {
      const data = await response.json();
      return data;
    } else {
      throw new Error('Failed');
    }
  } catch (e) {
    console.error(e);
    return null;
  }
};
```

### After
```typescript
async function getUserData(id: string): Promise<User | null> {
  const response = await fetch(`/api/users/${id}`);
  if (!response.ok) return null;
  return response.json();
}
```

## When to Use

| Scenario | Recommendation |
|----------|----------------|
| After implementing feature | ✅ Run to polish |
| After fixing bug | ✅ Clean up fix |
| Before major commit | ✅ Ensure consistency |
| During code review | ✅ Suggest improvements |
| Legacy code refactor | ⚠️ Be careful with scope |

## Model Recommendation

Uses **Opus** model for best results - requires nuanced understanding of code context and project-specific patterns.
