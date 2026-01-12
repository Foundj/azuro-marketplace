---
name: code-simplifier
description: |
  This skill simplifies and refines code for clarity, consistency, and maintainability while preserving
  all functionality. It should be used when the user mentions "simplify code", "refine code", "clean up code",
  "polish code", "improve readability", "代码简化", "代码优化", "整理代码", or after code review passes.
  Focuses on recently modified code unless instructed otherwise. Applies project-specific standards from CLAUDE.md.
version: 4.1.19
triggers:
  - simplify code
  - refine code
  - clean up code
  - polish code
  - improve readability
  - 代码简化
  - 代码优化
  - 整理代码
---

# Code Simplifier

> Expert code simplification focused on clarity, consistency, and maintainability.

## Quick Start

```bash
@code-simplifier review recent changes    # Simplify recently modified code
@code-simplifier refine src/api/          # Simplify specific directory
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

## Refinement Process

```
┌─────────────────────────────────────────────────────────┐
│              CODE SIMPLIFICATION FLOW                    │
├─────────────────────────────────────────────────────────┤
│  1. IDENTIFY recently modified code sections            │
│                    ↓                                    │
│  2. ANALYZE for improvement opportunities               │
│     - Complexity reduction                              │
│     - Consistency with project standards                │
│     - Readability improvements                          │
│                    ↓                                    │
│  3. APPLY refinements                                   │
│     - Follow CLAUDE.md standards                        │
│     - Keep functionality intact                         │
│                    ↓                                    │
│  4. VERIFY simplified code                              │
│     - Ensure behavior unchanged                         │
│     - Confirm improved maintainability                  │
│                    ↓                                    │
│  5. DOCUMENT significant changes                        │
└─────────────────────────────────────────────────────────┘
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
