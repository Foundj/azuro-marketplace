---
name: ai:fix
description: AI-powered fix with review-fix-verify cycle - runs as subagent to preserve main context
argument-hint: "<bug-description> [--deep] [--no-verify] [--max-retries N]"
allowed-tools: Task, Read, Write, Edit, Grep, Glob, Bash
execution-mode: subagent
---

# AI Fix Command (Subagent Mode)

**Goal**: Smart bug fix with automatic verification loop, executed as subagent to preserve main session context.

## Execution Flow

```
/ai:fix "login button not working"
    ↓
Launch Task tool with subagent:
  - subagent_type: "ai-dev:quick-fixer" or "ai-dev:debugger"
  - Isolated context execution
    ↓
Subagent executes:
  - Complexity detection → Quick/Standard/Deep strategy
  - OODA mini-loop (max 3 iterations)
  - Review-Fix-Verify cycle
    ↓
Returns Fix Report to main session
```

**Advantage**: Does not consume main session context tokens.

---

## Step 1: Parse Options & Analyze Complexity

**Options**:
- `--deep`: Force deep debugging mode
- `--no-verify`: Skip verification loop (quick fix only)
- `--max-retries N`: Max fix attempts (default: 3)

**Complexity Detection**:

```
Search for relevant code:
grep -r "$ARGUMENTS" --include="*.ts" --include="*.tsx" --include="*.js" -l 2>/dev/null | head -10
```

**Complexity Score**:
| Factor | Simple (1) | Medium (2) | Complex (3) |
|--------|------------|------------|-------------|
| Files affected | 1-2 | 3-5 | 6+ |
| Error clarity | Obvious | Needs trace | Root cause unclear |
| Test coverage | Has tests | Partial | No tests |
| Time estimate | <30min | 30-60min | >60min |

- Score 1-4: **Quick Fix** → Use quick-fixer agent
- Score 5-8: **Standard Fix** → OODA mini-loop
- Score 9-12: **Deep Debug** → Use debugger agent with 5-Whys

---

## Step 2: Execute Fix Strategy

### Strategy A: Quick Fix (Score 1-4)

**Constraints**: ≤30 min, ≤3 files, ≤50 lines

```
1. Locate bug in code
2. Identify root cause
3. Apply minimal fix
4. Run tests: npm test
5. If pass → Done
   If fail → Escalate to Standard Fix
```

### Strategy B: Standard Fix with OODA Mini-Loop (Score 5-8)

**OODA Mini-Loop** (max 3 iterations):

```
┌─────────────────────────────────────┐
│  OBSERVE                            │
│  - Read error logs/stack trace      │
│  - Check related test failures      │
│  - Review recent changes (git diff) │
├─────────────────────────────────────┤
│  ORIENT                             │
│  - Identify affected components     │
│  - Map error to code location       │
│  - Check for similar past fixes     │
├─────────────────────────────────────┤
│  DECIDE                             │
│  - Choose fix approach              │
│  - Estimate risk level              │
├─────────────────────────────────────┤
│  ACT                                │
│  - Apply fix                        │
│  - Update tests if needed           │
│  - Run verification                 │
└─────────────────────────────────────┘
         ↓
    Tests pass?
    ├── Yes → Verify → Done
    └── No → Iterate (max 3x)
```

### Strategy C: Deep Debug (Score 9-12)

Load debugger agent for thorough investigation:

```
1. Information Gathering (5 min)
   - Collect error messages, stack traces
   - Understand reproduction steps
   - Identify environment details

2. Hypothesis Generation
   - Generate 3-5 possible root causes
   - Prioritize by likelihood

3. Root Cause Analysis (5-Whys)
   Problem: [Symptom]
   1. Why? → [Immediate cause]
   2. Why? → [Underlying cause]
   3. Why? → [Deeper cause]
   4. Why? → [Systemic cause]
   5. Why? → [Root cause]

4. Fix with Prevention
   - Apply fix
   - Add regression test
   - Document for knowledge base
```

---

## Step 3: Review-Fix-Verify Cycle

**Unless `--no-verify` is set, run verification loop**:

```
┌──────────────────────────────────────────────────┐
│  REVIEW-FIX-VERIFY CYCLE (max 3 iterations)      │
├──────────────────────────────────────────────────┤
│                                                  │
│  1. APPLY FIX                                    │
│     - Implement the fix                          │
│     - Minimal changes only                       │
│                                                  │
│  2. RUN TESTS                                    │
│     - npm test (or project test command)         │
│     - Check for regressions                      │
│                                                  │
│  3. BUILD CHECK                                  │
│     - npm run build                              │
│     - TypeScript/ESLint clean                    │
│                                                  │
│  4. MINI CODE REVIEW                             │
│     - Check fix quality (confidence score)       │
│     - Verify no new issues introduced            │
│     - Security check for sensitive code          │
│                                                  │
│  5. VERIFY ORIGINAL BUG FIXED                    │
│     - Reproduce original issue → Should fail    │
│     - Run specific test for the bug              │
│                                                  │
│  Tests pass + Build clean + Bug fixed?           │
│  ├── YES → ✅ Complete                          │
│  └── NO  → Iterate (analyze what failed)        │
│                                                  │
└──────────────────────────────────────────────────┘
```

---

## Step 4: Generate Fix Report

```markdown
## 🔧 Fix Report

### Summary
- **Bug**: [Description]
- **Root Cause**: [What was wrong]
- **Fix**: [What was changed]
- **Strategy Used**: Quick/Standard/Deep
- **Iterations**: X/3

### Changes Made
| File | Lines Changed | Description |
|------|---------------|-------------|
| src/auth.ts | +5, -2 | Fixed null check |

### Verification Results
- ✅ Tests: 42/42 passing
- ✅ Build: Clean
- ✅ Lint: 0 errors
- ✅ Original bug: Fixed

### Regression Check
- ✅ No new test failures
- ✅ No performance regression

### Confidence Score
- Fix correctness: 92/100
- Risk of regression: Low

### Prevention (if applicable)
- [ ] Added regression test
- [ ] Updated error handling
- [ ] Documented in knowledge base
```

---

## Step 5: Knowledge Capture

**If fix was non-trivial, capture for future**:

```bash
# Add to knowledge base
echo '{
  "type": "bug_fix",
  "pattern": "[error pattern]",
  "root_cause": "[cause]",
  "fix": "[solution]",
  "files": ["file1.ts"],
  "date": "YYYY-MM-DD"
}' >> .agent/knowledge/errors.json
```

---

## Usage Examples

```bash
# Auto-detect complexity
/ai:fix login button not responding

# Force deep debug
/ai:fix --deep intermittent auth failures

# Quick fix without verification
/ai:fix --no-verify typo in header

# Limit retry attempts
/ai:fix --max-retries 5 complex race condition
```

---

## Escalation

If fix fails after max retries:

```
❌ Cannot auto-fix after 3 attempts.

Last error: [error message]
Files modified: [list]
Attempts made: [summary]

Options:
1. Increase max retries: /ai:fix --max-retries 5 [bug]
2. Deep debug mode: /ai:fix --deep [bug]
3. Manual investigation needed
4. Rollback changes: git reset --hard HEAD~N
```
