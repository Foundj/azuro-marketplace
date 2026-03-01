---
name: code-simplifier
description: |
  This skill should be used when the user wants to simplify, refine, or refactor code for clarity,
  consistency, and maintainability. It includes SOLID principles checking, complexity metrics analysis,
  and refactoring pattern recommendations. Use when the user mentions "simplify code", "refine code",
  "clean up code", "refactor", "reduce complexity", "technical debt", "代码简化", "代码重构", "优化",
  "技术债务", or after code review passes.
version: 6.0.7
status: ga
profile: review
triggers:
  - simplify code
  - refine code
  - clean up code
  - polish code
  - refactor
  - reduce complexity
  - technical debt
  - 代码简化
  - 代码优化
  - 代码重构
  - 技术债务
  - 重构
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
- Consistent naming conventions

### 3. Enhance Clarity
- Reduce unnecessary complexity and nesting
- Eliminate redundant code and abstractions
- Improve variable and function names
- Remove unnecessary comments

### 4. Maintain Balance
Avoid over-simplification that could:
- Reduce code clarity or maintainability
- Create overly clever solutions
- Prioritize "fewer lines" over readability

## Refinement Process

```
1. Read target files and understand current state
2. Check SOLID principles compliance
3. Analyze complexity metrics
4. Apply refactoring patterns
5. Verify behavior preservation (tests)
6. Output: Simplification Report
```

## Simplification Report Format

```markdown
# Code Simplification Report

## Summary
- Files analyzed: X
- Issues found: Y
- Simplifications applied: Z

## SOLID Violations Fixed
| File | Principle | Issue | Fix |
|------|-----------|-------|-----|
| ... | S | God class | Extract classes |

## Complexity Reduction
| File | Before | After | Change |
|------|--------|-------|--------|
| utils.ts | CC: 25 | CC: 12 | -52% |

## Recommendations
- [ ] Further refactoring suggestions
```

## When to Use

| Scenario | Action |
|----------|--------|
| After code review | Simplify flagged issues |
| Before commit | Polish recent changes |
| Technical debt cleanup | Refactor complex modules |
| Codebase health | Reduce complexity metrics |

## Model Recommendation

Uses **Opus** model for best results - requires nuanced understanding of code context.

## References

- **[solid-complexity.md](references/solid-complexity.md)** - SOLID principles and complexity metrics
- **[anti-ai-slop.md](references/anti-ai-slop.md)** - Anti-AI-Slop principles

## Agent Collaboration

| Agent | Role |
|-------|------|
| `code-reviewer` | Review first, then simplify |
| `oracle` | Complex refactoring decisions |

## Version History

| Version | Changes |
|---------|---------|
| 5.2.4 | Split detailed docs to references/ |
| 4.2.4 | Add Anti-AI-Slop principles |
| 4.0.0 | Initial release |