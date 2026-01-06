---
description: Quick bug fix - auto-selects quick-fixer or debugger based on complexity
argument-hint: <bug-description>
allowed-tools: Task, Read, Grep, Glob, Bash, Edit, Write
model: haiku
---

Fix bug: $ARGUMENTS

**Step 1: Analyze bug complexity**

Search for relevant code and error patterns:
!`grep -r "$ARGUMENTS" --include="*.ts" --include="*.tsx" --include="*.js" -l 2>/dev/null | head -5`

Assess complexity:
- **Simple** (≤30 min): Single file, clear fix, <50 lines change
- **Complex** (>30 min): Multiple files, root cause unclear, requires investigation

**Step 2: Execute appropriate fix strategy**

**For Simple Bugs → Quick Fix:**

Constraints:
- Time limit: ≤30 minutes
- File limit: ≤3 files
- Line limit: ≤50 lines modified

Process:
1. Locate the bug in code
2. Identify the fix
3. Apply minimal changes
4. Verify fix works

**For Complex Bugs → Deep Debug:**

Load debugger agent for thorough investigation:
1. Collect error context and stack traces
2. Perform root cause analysis
3. Trace execution flow
4. Identify fix with confidence score
5. Apply fix with comprehensive testing

**Step 3: Verify fix**

Run relevant tests: !`npm test 2>/dev/null || echo "No tests configured"`

Check for regressions:
- Related functionality still works
- No new errors introduced
- Edge cases handled

**Step 4: Report**

Provide fix summary:
- What was the bug
- Root cause
- What was changed
- Files modified
- Verification results
