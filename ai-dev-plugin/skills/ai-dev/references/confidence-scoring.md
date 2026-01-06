# Confidence Scoring Reference - Objective Quality Filtering

> **Purpose**: Filter code review noise by scoring issues 0-100, reporting only high-confidence problems (≥80)
> **Philosophy**: Quality over quantity - surface real issues, hide subjective opinions
> **Integration**: Phase 5 (Quality Validation) - after parallel code reviewers, before user presentation

---

## 📖 Table of Contents

1. [Overview](#overview)
2. [The Problem](#the-problem)
3. [The Solution](#the-solution)
4. [Scoring Methodology](#scoring-methodology)
5. [The 80-Point Threshold](#the-80-point-threshold)
6. [Issue Categories](#issue-categories)
7. [Scoring Examples](#scoring-examples)
8. [Integration Workflow](#integration-workflow)
9. [Calibration Guide](#calibration-guide)
10. [Best Practices](#best-practices)

---

## Overview

### What is Confidence Scoring?

**Confidence scoring** assigns a **0-100 numerical score** to each code review issue based on:
- **Certainty**: How sure are we this is a real problem?
- **Impact**: What's the worst-case consequence?
- **Evidence**: Can we prove it with code, specs, or documentation?

### Why Confidence Scoring?

**Traditional code review**:
```
Code Reviewer → 50 issues (security + bugs + style + opinions)
  ↓
User → Overwhelmed, ignores important issues
  ↓
Result: ❌ Alert fatigue, real bugs missed
```

**With confidence scoring**:
```
Code Reviewer → 50 issues
  ↓
Confidence Scorer → Score each issue (0-100)
  ↓
Filter → Keep only issues ≥80
  ↓
User → 5-10 high-confidence, actionable issues
  ↓
Result: ✅ Focused, real issues surfaced
```

---

## The Problem

### Alert Fatigue

**Scenario**: Junior developer implements authentication

**Traditional code review output** (25 issues):
```
1. ❌ CRITICAL: SQL injection on line 45
2. ❌ CRITICAL: XSS vulnerability on line 78
3. ⚠️ Style: Use const instead of let
4. ⚠️ Opinion: I prefer early returns
5. ⚠️ Nitpick: Add extra blank line here
6. ⚠️ Maybe: Consider using lodash
7. ⚠️ Style: Rename variable to be more descriptive
... 18 more issues ...
```

**Developer reaction**:
- 😫 Overwhelmed by 25 issues
- 🤷 Can't distinguish critical from trivial
- ⏭️ Skips review, ignores all issues
- 💥 Ships SQL injection to production

### Subjectivity Problem

**Question**: Is "function too long" a real issue?

**Answer**: It depends...

- **If global constraint says "functions ≤30 lines"** → ✅ Yes (violation)
- **If no constraint, just reviewer's opinion** → ❌ No (subjective)

**Without scoring**, both get equal weight. **With scoring**, constraint violation scores 80, opinion scores 40 (filtered).

---

## The Solution

### Objective, Evidence-Based Scoring

**Core Principle**: Only surface issues with **strong evidence** and **clear impact**

**Evidence Pyramid**:
```
Level 4: Proven vulnerability (CWE-89, CVE-XXX)         → Score: 95-100
Level 3: Violates documented constraint                 → Score: 80-90
Level 2: Likely bug with code evidence                  → Score: 75-85
Level 1: Possible issue, weak evidence                  → Score: 50-70 (FILTERED)
Level 0: Personal opinion, no evidence                  → Score: 0-40 (FILTERED)
```

### The 3-Question Test

For every issue, ask:

1. **Can we PROVE it?**
   - ✅ Yes, with code → High certainty (+20 points)
   - ⚠️ Maybe, with assumptions → Medium certainty (0 points)
   - ❌ No, just opinion → Low certainty (-20 points)

2. **What's the WORST-CASE impact?**
   - 🔴 Critical: Security breach, data loss → +30 points
   - 🟠 High: Functional bug, incorrect behavior → +20 points
   - 🟡 Medium: Performance issue, maintainability → +10 points
   - 🟢 Low: Style, preference → 0 points

3. **Is there DOCUMENTED evidence?**
   - ✅ Global constraint violation → +10 points
   - ✅ CWE/CVE reference → +5 points
   - ❌ No documentation → 0 points

**Base Score** = 50 (neutral)
**Final Score** = Base + Question 1 + Question 2 + Question 3

---

## Scoring Methodology

### Formula (Heuristic)

```
Base Score = 50 (neutral starting point)

Evidence Bonus:
  + 20: Proven with code (certainty 100%)
  + 10: Strong evidence (certainty 80-90%)
  + 0:  Weak evidence (certainty 50-70%)
  - 10: No evidence, assumption (certainty <50%)

Impact Bonus:
  + 30: Critical (security, data loss, crash)
  + 20: High (functional bug, correctness)
  + 10: Medium (performance, maintainability)
  + 0:  Low (style, preference)

Documentation Bonus:
  + 10: Global constraint violation (requirements.md, CLAUDE.md)
  + 5:  CWE/CVE reference (proven vulnerability class)
  + 0:  No documentation

Mitigation Penalty:
  - 10: Safeguards exist (e.g., input validation elsewhere)
  - 20: Already handled (e.g., error boundary catches issue)

Final Score = Base + Evidence + Impact + Documentation - Mitigation
Final Score = clamp(Final Score, 0, 100)
```

### Example Calculation

**Issue**: "SQL injection via string concatenation on line 45"

```
Base Score:        50
Evidence Bonus:    +20 (proven with code: `db.query(`SELECT * FROM users WHERE id = ${id}`)`)
Impact Bonus:      +30 (critical: database compromise)
Documentation:     +5  (CWE-89: SQL Injection)
Mitigation:        -0  (no safeguards)

Final Score = 50 + 20 + 30 + 5 - 0 = 105 → clamped to 100
```

**Result**: Score 100 → **Report to user** (≥80)

---

**Issue**: "Consider using lodash for array manipulation"

```
Base Score:        50
Evidence Bonus:    -10 (no evidence, just suggestion)
Impact Bonus:      +0  (low: optional optimization)
Documentation:     +0  (no constraint requires lodash)
Mitigation:        -0  (n/a)

Final Score = 50 - 10 + 0 + 0 - 0 = 40
```

**Result**: Score 40 → **Filter out** (<80)

---

## The 80-Point Threshold

### Why 80?

**Research-backed threshold** from software quality studies:
- Issues ≥80: **High confidence**, actionable, worth developer time
- Issues 50-79: **Medium confidence**, possibly useful, but often noise
- Issues <50: **Low confidence**, subjective opinions, ignore

### Calibration Over Time

**Initial deployment**: Start with threshold = 80

**After 10 reviews**:
- If users say "these aren't real issues" → **Increase to 85**
- If users say "you missed critical bugs" → **Lower to 75**

**Goal**: 5-10 high-confidence issues per review

### Threshold by Issue Category

| Category | Threshold | Rationale |
|----------|-----------|-----------|
| Security | 70 | Lower threshold (more sensitive) - better to over-report security issues |
| Bugs     | 80 | Standard threshold |
| Performance | 85 | Higher threshold - only report proven performance problems |
| Maintainability | 80 | Standard threshold |
| Style    | 95 | Very high threshold - only report if explicit constraint violation |

---

## Issue Categories

### 1. Security (Highest Priority)

**Characteristics**:
- Exploitable vulnerabilities
- CWE/CVE references
- OWASP Top 10
- Data exposure

**Typical Scores**: 90-100

**Examples**:
- SQL Injection (CWE-89): 100
- XSS (CWE-79): 98
- Hardcoded secrets: 95
- Missing authentication: 90

---

### 2. Bugs (Correctness)

**Characteristics**:
- Incorrect behavior
- Logic errors
- Unhandled edge cases
- Race conditions

**Typical Scores**: 80-95

**Examples**:
- Unhandled async rejection: 95
- Race condition: 90
- Off-by-one error: 85
- Missing null check: 80

---

### 3. Constraint Violations

**Characteristics**:
- Violates global requirements.md
- Violates global design.md patterns
- Violates CLAUDE.md code rules
- Violates constraints.md quality rules

**Typical Scores**: 80-90

**Examples**:
- Function >30 lines (CLAUDE.md): 80
- Uses `any` type (CLAUDE.md): 80
- Violates API spec (requirements.md): 85
- Missing tests (constraints.md): 80

---

### 4. Performance

**Characteristics**:
- Proven slow queries
- Memory leaks
- Inefficient algorithms
- N+1 query problems

**Typical Scores**: 70-85 (only report if proven)

**Examples**:
- Memory leak (proven): 85
- N+1 query (proven): 80
- Potential performance issue (unproven): 60 (filtered)

---

### 5. Maintainability

**Characteristics**:
- Code complexity
- Missing documentation
- Unclear naming
- Duplicate code

**Typical Scores**: 50-75 (mostly filtered, unless constraint violation)

**Examples**:
- Cyclomatic complexity >15: 75 (filtered)
- Missing JSDoc: 60 (filtered)
- Duplicate code (3+ instances): 70 (filtered)
- Poor variable naming: 50 (filtered)

---

### 6. Style / Preference

**Characteristics**:
- Formatting
- Personal preferences
- Micro-optimizations
- Nitpicks

**Typical Scores**: 0-50 (all filtered)

**Examples**:
- "Use early return": 40 (filtered)
- "Add blank line": 10 (filtered)
- "I prefer const over let": 30 (filtered)

---

## Scoring Examples

### Example 1: SQL Injection (Score: 100)

**Code**:
```typescript
// src/lib/db/users.ts:45
const getUserByEmail = (email: string) => {
  const query = `SELECT * FROM users WHERE email = '${email}'`;
  return db.execute(query);
};
```

**Issue Report**:
```json
{
  "title": "SQL Injection Vulnerability",
  "category": "security",
  "severity": "critical",
  "description": "User input is directly interpolated into SQL query without parameterization"
}
```

**Scoring**:
```
Base: 50
Evidence: +20 (proven with code - direct string interpolation)
Impact: +30 (critical - database compromise, data theft)
Documentation: +5 (CWE-89: SQL Injection)
Mitigation: -0 (no safeguards)

Final: 50 + 20 + 30 + 5 = 105 → clamped to 100
```

**Output**:
```json
{
  "issue_id": "ISS-001",
  "confidence": 100,
  "category": "security",
  "severity": "critical",
  "reasoning": "SQL injection vulnerability (CWE-89) on line 45. Email parameter is directly interpolated into SQL string. Attacker can inject arbitrary SQL (e.g., email=' OR '1'='1). Impact: full database access. Certainty: 100% - proven.",
  "recommendation": "MUST FIX - Use parameterized query: db.query.users.findFirst({ where: eq(users.email, email) })"
}
```

**User sees**: ✅ Reported (100 ≥ 80)

---

### Example 2: Unhandled Async Rejection (Score: 95)

**Code**:
```typescript
// src/app/api/users/route.ts:120
export async function GET() {
  const users = await db.query.users.findMany();
  return Response.json(users);
}
```

**Issue Report**:
```json
{
  "title": "Unhandled Promise Rejection",
  "category": "bug",
  "severity": "critical",
  "description": "Async function has no try-catch block for error handling"
}
```

**Scoring**:
```
Base: 50
Evidence: +20 (proven - no try-catch visible)
Impact: +30 (critical - server crash on DB error)
Documentation: +0 (no specific constraint, but best practice)
Mitigation: -5 (Next.js may have top-level error handler)

Final: 50 + 20 + 30 + 0 - 5 = 95
```

**Output**:
```json
{
  "issue_id": "ISS-002",
  "confidence": 95,
  "category": "bug",
  "severity": "critical",
  "reasoning": "Unhandled promise rejection on line 120. No try-catch for DB query. If query fails, uncaught exception will crash Node.js process. Impact: service downtime. Certainty: 95%.",
  "recommendation": "MUST FIX - Wrap in try-catch"
}
```

**User sees**: ✅ Reported (95 ≥ 80)

---

### Example 3: Race Condition (Score: 90)

**Code**:
```typescript
// src/lib/services/CounterService.ts:200
async increment() {
  const current = await this.getCount();
  await this.setCount(current + 1);
}
```

**Issue Report**:
```json
{
  "title": "Race Condition in Increment",
  "category": "bug",
  "severity": "high",
  "description": "Non-atomic read-modify-write operation allows race condition"
}
```

**Scoring**:
```
Base: 50
Evidence: +20 (proven - visible race window)
Impact: +20 (high - incorrect counter values)
Documentation: +0 (no specific constraint)
Mitigation: -0 (no safeguards)

Final: 50 + 20 + 20 + 0 = 90
```

**Output**:
```json
{
  "issue_id": "ISS-003",
  "confidence": 90,
  "category": "bug",
  "severity": "high",
  "reasoning": "Race condition on line 200-201. Read-modify-write not atomic. Concurrent calls will cause lost updates. Impact: incorrect state. Certainty: 90% - race window confirmed.",
  "recommendation": "SHOULD FIX - Use atomic increment"
}
```

**User sees**: ✅ Reported (90 ≥ 80)

---

### Example 4: Constraint Violation - Long Function (Score: 80)

**Code**:
```typescript
// src/lib/parsers/user.ts:30
function parseUserData(input: any): User {
  // ... 75 lines of parsing logic ...
}
```

**Issue Report**:
```json
{
  "title": "Function Exceeds Length Limit",
  "category": "constraint",
  "severity": "medium",
  "description": "Function is 75 lines, violates CLAUDE.md limit of ≤30 lines"
}
```

**Scoring**:
```
Base: 50
Evidence: +10 (proven - line count = 75)
Impact: +10 (medium - maintainability issue)
Documentation: +10 (CLAUDE.md constraint violation)
Mitigation: -0 (no mitigation)

Final: 50 + 10 + 10 + 10 = 80
```

**Output**:
```json
{
  "issue_id": "ISS-004",
  "confidence": 80,
  "category": "constraint",
  "severity": "high",
  "reasoning": "Function is 75 lines, violates CLAUDE.md constraint (≤30 lines). Impact: hard to maintain and test. Certainty: 80% - clear violation.",
  "evidence": {
    "constraint_violation": "CLAUDE.md: Functions ≤30 lines"
  },
  "recommendation": "SHOULD FIX - Split into smaller functions"
}
```

**User sees**: ✅ Reported (80 ≥ 80, exactly at threshold)

---

### Example 5: Potential N+1 Query (Score: 70 - FILTERED)

**Code**:
```typescript
// src/lib/services/PostService.ts:150
const users = await db.query.users.findMany();
const posts = await Promise.all(
  users.map(u => db.query.posts.findMany({ where: eq(posts.userId, u.id) }))
);
```

**Issue Report**:
```json
{
  "title": "Potential N+1 Query Pattern",
  "category": "performance",
  "severity": "medium",
  "description": "Possible N+1 query - consider using JOIN"
}
```

**Scoring**:
```
Base: 50
Evidence: +10 (pattern visible, but no proof of slowness)
Impact: +10 (medium - may be slow with large N)
Documentation: +0 (no constraint)
Mitigation: -0 (might be acceptable for small N)

Final: 50 + 10 + 10 + 0 = 70
```

**Output**: None (filtered, 70 < 80)

**Internal reasoning**: "Potential N+1 pattern, but no evidence of actual performance problem. Score 70 < 80. Not reported."

**User sees**: ❌ Not reported (70 < 80)

---

### Example 6: Missing JSDoc (Score: 60 - FILTERED)

**Code**:
```typescript
// src/lib/utils/format.ts:10
function formatCurrency(amount: number, locale: string): string {
  return new Intl.NumberFormat(locale, { style: 'currency', currency: 'USD' }).format(amount);
}
```

**Issue Report**:
```json
{
  "title": "Missing JSDoc Comment",
  "category": "maintainability",
  "severity": "low",
  "description": "Public function should have JSDoc documentation"
}
```

**Scoring**:
```
Base: 50
Evidence: +0 (true, but types are self-documenting)
Impact: +10 (medium - docs help, but types exist)
Documentation: +0 (no constraint requires JSDoc)
Mitigation: -0 (n/a)

Final: 50 + 0 + 10 + 0 = 60
```

**Output**: None (filtered, 60 < 80)

**User sees**: ❌ Not reported (60 < 80)

---

### Example 7: Style Preference (Score: 40 - FILTERED)

**Code**:
```typescript
// src/lib/utils/helpers.ts:20
function getUser(id: string): User | null {
  if (!id) {
    return null;
  } else {
    return db.findUser(id);
  }
}
```

**Issue Report**:
```json
{
  "title": "Prefer Early Return",
  "category": "style",
  "severity": "low",
  "description": "Use early return instead of else block"
}
```

**Scoring**:
```
Base: 50
Evidence: -10 (subjective opinion, both styles valid)
Impact: +0 (low - no functional difference)
Documentation: +0 (no constraint)
Mitigation: -0 (n/a)

Final: 50 - 10 + 0 + 0 = 40
```

**Output**: None (filtered, 40 < 80)

**User sees**: ❌ Not reported (40 < 80)

---

## Integration Workflow

### Phase 5: Quality Validation Flow

```
┌─────────────────────────────────────────────────────┐
│           Phase 5: Quality Validation               │
├─────────────────────────────────────────────────────┤
│                                                     │
│  Step 1: Parallel Code Review (3 reviewers)        │
│    - code-reviewer #1 → 15 issues                  │
│    - code-reviewer #2 → 20 issues                  │
│    - code-reviewer #3 → 18 issues                  │
│    Total: 53 raw issues                            │
│                                                     │
│  Step 2: Merge & Deduplicate                       │
│    53 issues → 38 unique issues                    │
│                                                     │
│  Step 3: Confidence Scoring (confidence-scorer)    │
│    For each issue:                                 │
│      - Read actual code                            │
│      - Check global constraints                    │
│      - Assess certainty + impact                   │
│      - Calculate score (0-100)                     │
│                                                     │
│  Step 4: Filter by Threshold                       │
│    38 issues → Filter (≥80) → 6 high-confidence    │
│                                                     │
│  Step 5: Sort by Confidence                        │
│    1. ISS-001 (Score 100) - SQL injection         │
│    2. ISS-002 (Score 95)  - Unhandled rejection   │
│    3. ISS-003 (Score 90)  - Race condition        │
│    4. ISS-004 (Score 85)  - Memory leak           │
│    5. ISS-005 (Score 82)  - Constraint violation  │
│    6. ISS-006 (Score 80)  - Missing validation    │
│                                                     │
│  Step 6: Present to User                           │
│    "Found 6 high-confidence issues"                │
│    [Detailed report with evidence]                 │
│                                                     │
└─────────────────────────────────────────────────────┘
```

### ai-dev Integration

```typescript
// Phase 5 implementation in ai-dev

async function phase5_qualityValidation(changeId: string) {
  // Step 1: Launch 3 parallel code reviewers
  const [review1, review2, review3] = await Promise.all([
    launchAgent('code-reviewer', { perspective: 'security' }),
    launchAgent('code-reviewer', { perspective: 'bugs' }),
    launchAgent('code-reviewer', { perspective: 'maintainability' })
  ]);

  // Step 2: Merge issues
  const rawIssues = [...review1.issues, ...review2.issues, ...review3.issues];
  const uniqueIssues = deduplicateIssues(rawIssues);
  console.log(`Found ${uniqueIssues.length} unique issues`);

  // Step 3: Confidence scoring
  const scoredIssues = await launchAgent('confidence-scorer', {
    issues: uniqueIssues
  });

  // Step 4: Filter ≥80
  const highConfidenceIssues = scoredIssues.filter(issue => issue.confidence >= 80);
  console.log(`${highConfidenceIssues.length} high-confidence issues (≥80)`);

  // Step 5: Sort by confidence (highest first)
  highConfidenceIssues.sort((a, b) => b.confidence - a.confidence);

  // Step 6: Present to user
  if (highConfidenceIssues.length === 0) {
    console.log('✅ No high-confidence issues found. Quality check passed.');
    return { approved: true };
  } else {
    console.log(`⚠️ Found ${highConfidenceIssues.length} high-confidence issues:`);
    highConfidenceIssues.forEach(issue => {
      console.log(`- [${issue.confidence}] ${issue.title} (${issue.file}:${issue.line})`);
    });

    // User decision
    const decision = await askUser('Fix these issues before proceeding?', ['Yes', 'No', 'Review']);

    if (decision === 'Yes') {
      // Go back to Phase 4 (OODA loop) to fix
      return { approved: false, action: 'fix_issues', issues: highConfidenceIssues };
    } else if (decision === 'No') {
      // User accepts risk, proceed
      return { approved: true };
    } else {
      // User wants to review manually
      return { approved: false, action: 'manual_review' };
    }
  }
}
```

---

## Calibration Guide

### Initial Calibration (Week 1-2)

**Step 1: Start with threshold = 80**

**Step 2: Collect data from 10 reviews**
```
Review 1: 8 issues (≥80) → User: "All valid"
Review 2: 12 issues (≥80) → User: "3 are nitpicks"
Review 3: 5 issues (≥80) → User: "All valid"
... (continue)
```

**Step 3: Analyze feedback**
```
Total reviews: 10
Total issues reported: 75
User said "valid": 68 (90.7%)
User said "nitpick": 7 (9.3%)

Precision: 90.7% ✅ Good
```

**Step 4: Adjust if needed**
- If precision <80% → Increase threshold to 85
- If users say "missed bugs" → Review filtered issues (70-79 range)

---

### Ongoing Calibration (Monthly)

**Step 1: Review metrics**
```
Month 1:
  - Average issues reported: 7.2
  - User satisfaction: 92%
  - False positive rate: 8%
```

**Step 2: Adjust category thresholds**
```
If security false positives:
  security_threshold = 75 (lower, more sensitive)

If style issues leaking through:
  style_threshold = 95 (higher, more strict)
```

**Step 3: Update scoring formula**
```
If users say "this should be higher priority":
  Impact(critical) = +35 (was +30)

If users say "you're over-reporting X":
  Evidence penalty for category X = -5
```

---

### Warning Signs

**Too many issues reported** (>15 per review):
- ✅ Increase threshold to 85
- ✅ Tighten evidence requirements

**Too few issues reported** (<3 per review):
- ✅ Lower threshold to 75
- ✅ Review filtered issues (70-79)
- ✅ Check if code quality is genuinely high

**User says "these aren't real issues"**:
- ✅ Increase threshold by 5
- ✅ Add more mitigation penalties
- ✅ Review scoring formula

**User says "you missed critical bugs"**:
- ✅ Lower threshold by 5
- ✅ Review filtered issues
- ✅ Add more evidence bonuses

---

## Best Practices

### For confidence-scorer Agent

1. **Always read actual code**
   - Don't score based on issue description alone
   - Verify claims with actual code

2. **Check global constraints**
   - requirements.md, design.md, CLAUDE.md, constraints.md
   - Violations get automatic +10 points

3. **Cite evidence**
   - CWE/CVE numbers
   - Line numbers
   - Code snippets

4. **Be conservative with high scores**
   - Score 100: Only for definite vulnerabilities
   - Score 95-99: High certainty bugs
   - Score 80-94: Likely issues with evidence

5. **Don't inflate scores**
   - Helping user ≠ inflating scores
   - Trust the threshold system

### For code-reviewer Agents

1. **Report all issues, don't self-filter**
   - confidence-scorer will filter
   - Your job: find issues
   - Scorer's job: prioritize

2. **Provide detailed descriptions**
   - Help scorer assess impact
   - Include code snippets
   - Explain why it's an issue

3. **Categorize correctly**
   - Security vs bug vs maintainability
   - Helps scorer apply right criteria

### For Users

1. **Trust the threshold**
   - Issues ≥80 are worth your time
   - Issues <80 are intentionally filtered

2. **Provide feedback**
   - "This isn't a real issue" → Threshold too low
   - "You missed X" → Threshold too high

3. **Review calibration monthly**
   - Adjust threshold based on precision
   - Target: 90%+ precision (valid issues)

---

## Summary

### Key Takeaways

1. **Confidence scoring filters noise**
   - 0-100 score per issue
   - Report only ≥80
   - Result: 5-10 actionable issues instead of 50

2. **Evidence-based, not opinion-based**
   - Proven with code → High score
   - Global constraint violation → High score
   - Personal preference → Low score (filtered)

3. **Calibrate over time**
   - Start with threshold = 80
   - Adjust based on user feedback
   - Target: 90%+ precision

4. **Integration with Phase 5**
   - After parallel code reviewers
   - Before user presentation
   - Sorted by confidence (highest first)

---

**End of Confidence Scoring Reference**
