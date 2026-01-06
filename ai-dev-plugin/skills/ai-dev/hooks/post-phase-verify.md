# Post-Phase Verification Hook

> **Trigger**: After any coding agent completes in Phase 2-5
> **Purpose**: Automatically verify phase completion before proceeding
> **Reference**: https://code.claude.com/docs/en/hooks-guide

---

## 🎯 Hook Configuration

### Basic Info

```yaml
name: post-phase-verify
type: stop_hook
trigger: agent_stop
priority: high
blocking: true
```

### Trigger Conditions

This hook triggers when **ALL** conditions are met:

```yaml
conditions:
  # Only trigger for coding/implementation agents
  - agent_name:
      matches: "^(code-|ralph-wiggum|task-executor)"

  # Only in implementation and quality phases
  - current_phase:
      in: [2, 3, 4, 5]

  # Skip for verification agents to avoid recursion
  - agent_name:
      not_matches: "verification-agent|quality-guardian"

  # Only if agent completed successfully (not errored)
  - agent_status:
      equals: "completed"
```

### Actions

```yaml
actions:
  - name: Verify Phase Completion
    agent: verification-agent
    model: haiku  # Fast verification with haiku
    blocking: true
    timeout: 120000  # 120 seconds (increased for thorough checks)

    prompt: |
      🔍 **Automatic Phase Verification**

      An agent just completed in Phase {{ current_phase }}. Verify completion before proceeding.

      **Agent Info**:
      - Agent: {{ agent_name }}
      - Phase: {{ current_phase }}
      - Change ID: {{ change_id }}

      **Verification Checklist**:

      {% if current_phase == 2 %}
      ## Phase 2 (Discovery) Verification

      1. **evidence.md exists** and contains:
         - Existing code patterns found
         - Similar features analyzed
         - Architecture insights
         - Constraints discovered

      2. **Files discovered** are documented:
         - Key files listed with purpose
         - Dependencies identified
         - Integration points noted

      3. **State.json updated**:
         - Phase 2 entry in phaseHistory
         - discoveryComplete = true
         - filesAnalyzed list populated

      {% elsif current_phase == 3 %}
      ## Phase 3 (Planning) Verification

      1. **design.md exists** and contains:
         - 3 implementation approaches (minimal, clean, pragmatic)
         - Each with time estimate and tradeoffs
         - Clear recommendation marked
         - User selection recorded (if applicable)

      2. **Approach selected**:
         - selectedApproach in state.json (1, 2, or 3)
         - Selection reasoning documented

      3. **Files to modify** listed:
         - Create: [list]
         - Modify: [list]
         - Delete: [list] (if any)

      4. **State.json updated**:
         - Phase 3 entry in phaseHistory
         - designComplete = true
         - selectedApproach set

      {% elsif current_phase == 4 %}
      ## Phase 4 (Implementation) Verification

      1. **tasks.md completion promise**:
         - Check for `<promise>DONE</promise>` tag
         - All checkboxes marked [x]
         - No pending tasks remaining

      2. **Tests passing**:
         - Run: `npm test`
         - Expected: All tests pass (exit code 0)
         - If failed: List which tests failed

      3. **Build succeeds**:
         - Run: `npm run build`
         - Expected: Build successful (exit code 0)
         - If failed: Show build errors

      4. **Linter clean**:
         - Run: `npm run lint`
         - Expected: 0 errors (exit code 0)
         - Warnings acceptable

      5. **TypeScript clean**:
         - Run: `npm run type-check` or `tsc --noEmit`
         - Expected: 0 type errors
         - If failed: Show type errors

      6. **State.json updated**:
         - Phase 4 entry in phaseHistory
         - implementationComplete = true
         - oodaIterations logged

      {% elsif current_phase == 5 %}
      ## Phase 5 (Quality Validation) Verification

      1. **Issues reviewed**:
         - issues-scored.json exists
         - All ≥80 confidence issues addressed OR
         - User explicitly accepted remaining issues

      2. **Fixes validated**:
         - If issues were fixed, tests still pass
         - Build still succeeds
         - No new issues introduced

      3. **Quality gate decision**:
         - User decision recorded in state.json:
           - "fix_all" → All issues fixed
           - "fix_critical" → Only ≥95 fixed
           - "accept_risk" → Proceeded with issues

      4. **State.json updated**:
         - Phase 5 entry in phaseHistory
         - qualityValidationComplete = true
         - issuesResolved count
         - issuesAccepted count (if any)

      {% endif %}

      ---

      **Output Format**:

      If verification **PASSES**:
      ```
      ✅ Phase {{ current_phase }} Verification: PASSED

      All checks completed successfully:
      - [✓] Check 1: [description]
      - [✓] Check 2: [description]
      - [✓] Check 3: [description]

      Safe to proceed to Phase {{ current_phase + 1 }}.
      ```

      If verification **FAILS**:
      ```
      ⚠️ Phase {{ current_phase }} Verification: FAILED

      Issues found:
      - [✗] Check 1: [specific issue]
      - [✗] Check 2: [specific issue]

      Required actions:
      1. [Specific fix needed]
      2. [Specific fix needed]

      BLOCKING: Cannot proceed until issues resolved.
      ```

      If verification **ERRORS**:
      ```
      ❌ Phase {{ current_phase }} Verification: ERROR

      Verification could not complete:
      - Error: [error message]

      User intervention required.
      ```
```

---

## 📋 Implementation Details

### How It Works

1. **Trigger Detection**
   ```
   Agent completes → Hook system checks conditions → Conditions match → Hook triggers
   ```

2. **Quality Guardian Execution**
   ```
   Hook → Spawn quality-guardian agent → Run verification checklist → Return result
   ```

3. **Flow Control**
   ```
   If PASSED → Continue to next phase
   If FAILED → Block transition, show issues to user
   If ERROR → Halt, request user intervention
   ```

### State Machine Integration

The hook integrates with the state machine:

```typescript
// state.json structure
{
  "phaseHistory": [
    {
      "phase": 4,
      "enteredAt": "2024-01-04T10:00:00Z",
      "exitedAt": "2024-01-04T11:30:00Z",
      "status": "completed",
      "verificationStatus": "passed",  // Added by hook
      "verificationTime": "2024-01-04T11:30:05Z",
      "verificationIssues": []  // Empty if passed
    }
  ]
}
```

### Recursion Prevention

**Critical**: The hook MUST NOT trigger on verification agents themselves!

```yaml
# In conditions
- agent_name:
    not_matches: "verification-agent|quality-guardian"
```

Otherwise: `agent → hook → verification-agent → hook → verification-agent → ∞`

---

## 🔧 Verification Logic (quality-guardian)

### Phase 2 Checks

```typescript
async function verifyPhase2(changeId: string): Promise<VerificationResult> {
  const changeDir = `changes/active/${changeId}`;

  // Check 1: evidence.md exists
  const discoveryExists = await fileExists(`${changeDir}/evidence.md`);
  if (!discoveryExists) {
    return { passed: false, issue: "evidence.md not found" };
  }

  // Check 2: Content is substantive
  const discovery = await Read({ file_path: `${changeDir}/evidence.md` });
  if (discovery.length < 500) {
    return { passed: false, issue: "evidence.md too short (< 500 chars)" };
  }

  // Check 3: State updated
  const state = JSON.parse(await Read({ file_path: `${changeDir}/state.json` }));
  if (!state.discoveryComplete) {
    return { passed: false, issue: "state.json: discoveryComplete = false" };
  }

  return { passed: true };
}
```

### Phase 3 Checks

```typescript
async function verifyPhase3(changeId: string): Promise<VerificationResult> {
  const changeDir = `changes/active/${changeId}`;

  // Check 1: design.md exists
  const designExists = await fileExists(`${changeDir}/design.md`);
  if (!designExists) {
    return { passed: false, issue: "design.md not found" };
  }

  // Check 2: Contains 3 approaches
  const design = await Read({ file_path: `${changeDir}/design.md` });
  const approachCount = (design.match(/## Approach \d:/g) || []).length;
  if (approachCount < 3) {
    return { passed: false, issue: `Only ${approachCount} approaches found (need 3)` };
  }

  // Check 3: Approach selected
  const state = JSON.parse(await Read({ file_path: `${changeDir}/state.json` }));
  if (!state.selectedApproach || ![1, 2, 3].includes(state.selectedApproach)) {
    return { passed: false, issue: "No valid approach selected (must be 1, 2, or 3)" };
  }

  return { passed: true };
}
```

### Phase 4 Checks

```typescript
async function verifyPhase4(changeId: string): Promise<VerificationResult> {
  const changeDir = `changes/active/${changeId}`;

  // Check 1: tasks.md marked DONE
  const tasks = await Read({ file_path: `${changeDir}/tasks.md` });
  if (!tasks.includes('<promise>DONE</promise>')) {
    return { passed: false, issue: "tasks.md: Completion promise not found" };
  }

  // Check 2: All checkboxes marked
  const uncheckedTasks = (tasks.match(/- \[ \] /g) || []).length;
  if (uncheckedTasks > 0) {
    return { passed: false, issue: `${uncheckedTasks} tasks still unchecked` };
  }

  // Check 3: Tests pass
  const testResult = await Bash({ command: 'npm test', timeout: 120000 });
  if (testResult.exitCode !== 0) {
    return { passed: false, issue: `Tests failed:\n${testResult.stderr}` };
  }

  // Check 4: Build succeeds
  const buildResult = await Bash({ command: 'npm run build', timeout: 180000 });
  if (buildResult.exitCode !== 0) {
    return { passed: false, issue: `Build failed:\n${buildResult.stderr}` };
  }

  // Check 5: Lint clean (errors only, warnings OK)
  const lintResult = await Bash({ command: 'npm run lint', timeout: 60000 });
  if (lintResult.exitCode !== 0 && lintResult.stderr.includes('error')) {
    return { passed: false, issue: `Lint errors found:\n${lintResult.stderr}` };
  }

  // Check 6: TypeScript clean
  const tscResult = await Bash({
    command: 'npm run type-check || tsc --noEmit',
    timeout: 60000
  });
  if (tscResult.exitCode !== 0) {
    return { passed: false, issue: `TypeScript errors:\n${tscResult.stderr}` };
  }

  return { passed: true };
}
```

### Phase 5 Checks

```typescript
async function verifyPhase5(changeId: string): Promise<VerificationResult> {
  const changeDir = `changes/active/${changeId}`;

  // Check 1: issues-scored.json exists
  const issuesScored = await fileExists(`${changeDir}/issues-scored.json`);
  if (!issuesScored) {
    return { passed: false, issue: "issues-scored.json not found" };
  }

  // Check 2: User decision recorded
  const state = JSON.parse(await Read({ file_path: `${changeDir}/state.json` }));
  if (!state.qualityGateDecision) {
    return { passed: false, issue: "No quality gate decision recorded in state.json" };
  }

  // Check 3: If issues were fixed, tests still pass
  if (state.qualityGateDecision === 'fix_all' || state.qualityGateDecision === 'fix_critical') {
    const testResult = await Bash({ command: 'npm test', timeout: 120000 });
    if (testResult.exitCode !== 0) {
      return { passed: false, issue: `Tests failed after fixes:\n${testResult.stderr}` };
    }
  }

  return { passed: true };
}
```

---

## 🚦 Example Scenarios

### Scenario 1: Phase 4 Verification SUCCESS

```
[Agent ralph-wiggum completes Phase 4]
  ↓
[Hook triggers: post-phase-verify]
  ↓
[quality-guardian runs verification]
  ↓
Checks:
  ✓ tasks.md: <promise>DONE</promise> found
  ✓ All checkboxes marked [x]
  ✓ npm test: exit code 0
  ✓ npm run build: exit code 0
  ✓ npm run lint: 0 errors
  ✓ tsc --noEmit: 0 type errors
  ↓
[Hook returns: ✅ PASSED]
  ↓
[Workflow proceeds to Phase 5]
```

### Scenario 2: Phase 4 Verification FAILURE

```
[Agent ralph-wiggum completes Phase 4]
  ↓
[Hook triggers: post-phase-verify]
  ↓
[quality-guardian runs verification]
  ↓
Checks:
  ✓ tasks.md: <promise>DONE</promise> found
  ✓ All checkboxes marked [x]
  ✗ npm test: exit code 1 (3 tests failed)
  ↓
[Hook returns: ⚠️ FAILED]
  ↓
User sees:
  "⚠️ Phase 4 Verification: FAILED

   Issues found:
   - [✗] Tests: 3 tests failed:
     - AuthService.test.ts: login with invalid password
     - AuthService.test.ts: signup with duplicate email
     - UserRepository.test.ts: findByEmail with null

   Required actions:
   1. Fix failing tests
   2. Re-run verification

   BLOCKING: Cannot proceed to Phase 5 until tests pass."
  ↓
[Workflow HALTS - user must fix and retry]
```

### Scenario 3: Phase 3 Verification - Missing Approach

```
[Agent architect completes Phase 3]
  ↓
[Hook triggers: post-phase-verify]
  ↓
[quality-guardian runs verification]
  ↓
Checks:
  ✓ design.md exists
  ✗ Only 2 approaches found (need 3)
  ↓
[Hook returns: ⚠️ FAILED]
  ↓
User sees:
  "⚠️ Phase 3 Verification: FAILED

   Issues found:
   - [✗] design.md: Only 2 approaches found (need 3)

   Required actions:
   1. Add missing approach to design.md
   2. Ensure all 3 approaches have time estimates

   BLOCKING: Cannot proceed to user approval gate."
  ↓
[Workflow HALTS - agent must add missing approach]
```

---

## ⚠️ Important Notes

### DO:
- ✅ Use `blocking: true` to prevent bad phases from continuing
- ✅ Use `haiku` model for fast verification (cost-effective)
- ✅ Prevent recursion with `not_matches: "verification-agent"`
- ✅ Provide specific, actionable error messages
- ✅ Update state.json with verification results
- ✅ Run actual commands (npm test, build, lint)

### DON'T:
- ❌ Skip verification in any phase 2-5
- ❌ Use `blocking: false` (defeats the purpose)
- ❌ Trigger on verification agents (infinite loop)
- ❌ Return vague errors ("something wrong")
- ❌ Trust state.json blindly (verify with actual files)
- ❌ Use slow models (opus/sonnet) for simple checks

---

## 📚 References

- **Hooks Guide**: https://code.claude.com/docs/en/hooks-guide
- **quality-guardian agent**: (to be created in verification-agent.md)
- **State Machine Spec**: `${CLAUDE_PLUGIN_ROOT}/skills/ai-dev/references/state-machine-spec.md`
- **7-Phase Workflow**: `${CLAUDE_PLUGIN_ROOT}/skills/ai-dev/references/7-phase-workflow.md`

---

**End of Post-Phase Verification Hook**
