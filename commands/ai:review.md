---
description: AI-powered code review - comprehensive quality analysis with confidence scoring
argument-hint: [files...] [--staged] [--diff <branch>]
allowed-tools: Task, Read, Grep, Glob, Bash
---

Code review: $ARGUMENTS

**Goal**: Comprehensive code review with actionable findings and confidence scores

**Step 1: Determine Scope**

Parse arguments:
- No args: Review recent changes (git diff HEAD~1)
- `--staged`: Review staged changes (git diff --cached)
- `--diff <branch>`: Review changes vs branch
- `files...`: Review specific files

Get changed files:
```bash
git diff --name-only HEAD~1  # or appropriate diff command
```

**Step 2: Multi-Perspective Review**

Launch parallel review agents:

### 2.1 Code Quality Review
- Code style consistency
- Naming conventions
- Code complexity (cyclomatic)
- DRY violations
- Magic numbers/strings

### 2.2 Logic Review
- Algorithm correctness
- Edge case handling
- Error handling
- Null/undefined checks
- Race conditions

### 2.3 Security Review
- Input validation
- SQL injection
- XSS vulnerabilities
- Secrets/credentials exposure
- Authentication/authorization

### 2.4 Performance Review
- N+1 queries
- Unnecessary re-renders
- Memory leaks
- Inefficient algorithms
- Missing indexes

### 2.5 Test Coverage
- New code coverage
- Edge case tests
- Integration tests
- Mock appropriateness

**Step 3: Confidence Scoring**

Rate each finding:

| Score | Meaning | Action |
|-------|---------|--------|
| 90-100 | Critical, certain | Must fix |
| 80-89 | Important, high confidence | Should fix |
| 70-79 | Moderate, likely issue | Consider fixing |
| <70 | Low confidence | Optional/discuss |

**Only report findings with confidence ≥80**

**Step 4: Generate Report**

```markdown
## Code Review Report

### Summary
- Files reviewed: X
- Critical issues: X
- Important issues: X
- Suggestions: X

### Critical Issues (Must Fix)
| # | File | Line | Issue | Confidence |
|---|------|------|-------|------------|
| 1 | file.ts | 42 | Description | 95 |

### Important Issues (Should Fix)
| # | File | Line | Issue | Confidence |
|---|------|------|-------|------------|

### Suggestions (Optional)
- Suggestion 1
- Suggestion 2

### Positive Observations
- Good pattern 1
- Good pattern 2
```

**Step 5: User Decision**

Present findings and ask:
> 请选择要修复的问题 (all/critical/选择编号)，或跳过 (skip)。

If user selects issues to fix:
- Apply fixes automatically
- Re-run affected checks
