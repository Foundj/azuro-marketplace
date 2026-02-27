---
name: ai-dev-quality
description: |
  This skill provides code quality validation system with multi-perspective review, confidence scoring,
  and automated verification. It includes code-reviewer, confidence-scorer, and verification-agent.
  Use this skill when the user mentions "code review", "quality check", "ai:review", "ai:quality",
  "代码审查", "质量检查", or during Phase 5 of the development workflow.
version: 5.2.1
status: ga
triggers:
  - code review
  - quality check
  - 代码审查
  - 质量检查
  - 代码质量
---

# Quality Validation System

> Multi-perspective code review with confidence-based filtering and automated verification.

## 触发词

此技能触发于: "code review", "quality check", "代码审查", "质量检查", "ai:review", "ai:quality".

## Quick Start

```bash
/ai:review                    # Review current changes
/ai:quality                   # Run full quality gate
@code-reviewer analyze src/   # Direct agent call
```

## Architecture

```
┌─────────────────────────────────────────────────────────┐
│                 QUALITY PIPELINE                         │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   │
│  │ code-       │   │ code-       │   │ code-       │   │
│  │ reviewer #1 │   │ reviewer #2 │   │ reviewer #3 │   │
│  │ (security)  │   │ (bugs)      │   │ (maintain)  │   │
│  └──────┬──────┘   └──────┬──────┘   └──────┬──────┘   │
│         │                 │                 │           │
│         └────────────────┬┴─────────────────┘           │
│                          ↓                              │
│              ┌───────────────────────┐                  │
│              │  confidence-scorer    │                  │
│              │  Filter: score ≥ 80   │                  │
│              └───────────┬───────────┘                  │
│                          ↓                              │
│              ┌───────────────────────┐                  │
│              │  verification-agent   │                  │
│              │  Tests, Build, Lint   │                  │
│              └───────────────────────┘                  │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Agents

### code-reviewer

Multi-perspective code review specialist.

**Perspectives**:
- Security: Vulnerabilities, injection, auth issues
- Bugs: Logic errors, edge cases, race conditions
- Maintainability: Complexity, naming, structure

**Output**: List of issues with descriptions and locations.

### confidence-scorer

Objective issue severity scoring.

**Scoring Criteria** (0-100):
| Factor | Weight | Description |
|--------|--------|-------------|
| Evidence | 40% | Concrete proof vs speculation |
| Impact | 30% | Severity if issue occurs |
| Likelihood | 20% | Probability of occurrence |
| Fixability | 10% | Effort to resolve |

**Filter**: Only issues ≥80 are reported to users.

### verification-agent

Automated verification execution.

**Checks**:
- `npm test` / `pytest` - Unit tests
- `npm run build` - Build verification
- `npm run lint` - Linting
- Custom commands from `verify_with`

## Quality Gate Dimensions

| Dimension | Weight | Checks |
|-----------|--------|--------|
| Security | 40% | OWASP Top 10, secrets, auth |
| Code Quality | 30% | Complexity, duplication, naming |
| Documentation | 20% | Comments, README, API docs |
| Architecture | 10% | Patterns, coupling, cohesion |

**Pass Threshold**: Overall score ≥ 80

### Detailed Checks

**Security (40%)**:
- No hardcoded secrets/passwords
- SQL parameterized queries
- XSS/CSRF protection
- Auth/authz correctly implemented

**Code Quality (30%)**:
- Function length < 50 lines
- Cyclomatic complexity < 10
- No duplicate code blocks (> 10 lines)
- Naming follows project conventions

**Documentation (20%)**:
- Public functions documented
- README updated
- API docs (if applicable)

**Architecture (10%)**:
- Single responsibility
- Correct dependency direction
- No circular dependencies

## Usage Modes

### Automatic (Phase 5)

In the 7-phase workflow, quality validation runs automatically after implementation:

```
Phase 4 Complete → Phase 5 Triggers:
1. Launch 3 code-reviewers in parallel (different perspectives)
2. Aggregate issues
3. confidence-scorer filters to ≥80
4. verification-agent runs tests
5. Report results
```

### Manual Review

```bash
# Review specific files
/ai:review src/api/auth.ts

# Full quality gate
/ai:quality

# Direct agent calls
@code-reviewer security focus on src/
@verification-agent run all checks
```

## Integration with code-simplifier

When enabled, code-simplifier runs after quality validation to refine approved code:

```
Quality Gate Pass
       ↓
code-simplifier
  - Apply project standards
  - Reduce complexity
  - Improve readability
  - Preserve functionality
       ↓
Final Commit Ready
```

## Configuration

```json
// codebox/config.json
{
  "quality": {
    "confidenceThreshold": 80,
    "parallelReviewers": 3,
    "perspectives": ["security", "bugs", "maintainability"],
    "autoSimplify": true
  }
}
```

## Output: quality-report.md

```markdown
# Quality Report

## Summary
- Issues Found: 15
- Issues Reported (≥80 confidence): 3
- Tests: ✅ Passed (42/42)
- Build: ✅ Success
- Lint: ✅ Clean

## High Confidence Issues

### 1. SQL Injection Risk (Confidence: 95)
**File**: src/api/users.ts:42
**Issue**: User input directly concatenated to SQL query
**Fix**: Use parameterized queries

### 2. Missing Null Check (Confidence: 88)
**File**: src/utils/format.ts:15
**Issue**: response.data accessed without null check
**Fix**: Add optional chaining or guard clause

## Verification Results
- Unit Tests: 42/42 passed
- Integration Tests: 8/8 passed
- Build Time: 12.3s
- Bundle Size: 245KB (within limit)
```

## Integration with ai-dev

This skill is used in **Phase 5 (Quality Validation)** of the 7-phase workflow:

1. Phase 4 completes implementation
2. **Phase 5 activates quality system**
3. Issues ≥80 confidence must be resolved
4. All verifications must pass
5. **code-simplifier runs** (if autoSimplify enabled)
6. Phase 6 begins finalization

## Quality Report Output

```
╔════════════════════════════════════════════════════════════╗
║                    QUALITY GATE REPORT                     ║
╠════════════════════════════════════════════════════════════╣
║  Dimension        │ Score  │ Weight │ Weighted │ Status   ║
╠═══════════════════╪════════╪════════╪══════════╪══════════╣
║  🔒 Security      │  90/100│   40%  │   36.0   │ ✅ PASS  ║
║  📝 Code Quality  │  75/100│   30%  │   22.5   │ ✅ PASS  ║
║  📖 Documentation │  65/100│   20%  │   13.0   │ ✅ PASS  ║
║  🏗️ Architecture  │  80/100│   10%  │    8.0   │ ✅ PASS  ║
╠═══════════════════╧════════╧════════╧══════════╧══════════╣
║  TOTAL SCORE: 79.5/100                                     ║
║  STATUS: ✅ PASSED                                         ║
╚════════════════════════════════════════════════════════════╝
```

## Note

This skill replaces the legacy `quality-gate` skill with enhanced multi-perspective review.

## Agent Collaboration

| Agent | Role |
|-------|------|
| `ai-dev` | Triggers quality in Phase 5 |
| `ai-dev-ooda` | Provides implementation to review |
| `code-simplifier` | Runs after quality passes |
| `@code-reviewer` | Multi-perspective code review |
| `@verification-agent` | Runs tests, build, lint |

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 4.2.6 | 2026-01-13 | Add agent collaboration, version history |
| 4.0.0 | 2026-01-07 | Initial release replacing quality-gate |

## References

See `references/scoring-criteria.md` for confidence scoring rules.
