# Verification Workflow - Complete Quality Assurance Flow

> **Purpose**: 完整描述ai-dev从Phase 0→6的所有验证点和自我检查机制
> **Version**: 2.0-enhanced (with Ralph-Wiggum self-completion)

---

## 📖 Overview

**Verification Workflow** 确保ai-dev在每个关键点都进行质量检查，实现：
- ✅ 早期发现问题（在成本低时修复）
- ✅ 防止错误传播（阻止有问题的phase进入下一阶段）
- ✅ 自主修复（Ralph-Wiggum模式自动解决问题）
- ✅ 用户信心（通过多重验证确保质量）

**核心原则**: **Defense in Depth**（纵深防御）
- 第1层：User Approval Gates（用户确认理解正确）
- 第2层：Quality Gates（自动验证技术质量）
- 第3层：Stop Hooks（agent完成后自动检查）
- 第4层：Ralph-Wiggum Self-Healing（失败后自主修复）

---

## 🔄 Complete Verification Flow (Phase 0-6)

```
Phase 0 (Knowledge Check)
  ↓
  🔍 Verification Point #1: Knowledge Base Query
  ├─ Check: patterns.json, errors.json, learnings.md exist
  ├─ Check: Previous similar changes documented
  └─ Result: Historical context for better decisions
  ↓
Phase 1 (Requirements)
  ↓
  🔍 Verification Point #2: Proposal Quality Check
  ├─ Check: proposal.md完整性（summary, tech stack, constraints, time estimate）
  ├─ Check: 引用全局约束（requirements.md, design.md, CLAUDE.md）
  └─ Check: 用户审批 (User Approval Gate #1: yes/no/refine)
  ↓
  ✅ Gate #1: User Approval (Phase 1)
  ├─ If "Yes" → Proceed to Phase 2
  ├─ If "Refine" → Loop back with feedback (max 3 attempts)
  └─ If "No" → Cancel change
  ↓
Phase 2 (Discovery)
  ↓
  🔍 Verification Point #3: Discovery Completeness
  ├─ Check: evidence.md exists
  ├─ Check: Key files identified
  ├─ Check: Patterns documented
  └─ Hook: post-phase-verify (optional for Phase 2)
  ↓
Phase 3 (Planning)
  ↓
  🔍 Verification Point #4: Design Quality Check
  ├─ Check: design.md contains 3 approaches
  ├─ Check: Each approach has time estimate & tradeoffs
  ├─ Check: Recommendation marked
  └─ Check: 用户选择 (User Approval Gate #2: 1/2/3)
  ↓
  ✅ Gate #2: User Approval (Phase 3)
  ├─ User selects approach (1-minimal / 2-clean / 3-pragmatic)
  └─ Record in state.json: selectedApproach
  ↓
Phase 4 (Implementation)
  ↓
  🔄 Ralph-Wiggum OODA Loop (Self-Completion)
  ├─ Iteration 1:
  │   ├─ Implement Task 1
  │   ├─ VERIFY: Assertions pass?
  │   ├─ VERIFY: Tests pass?
  │   ├─ VERIFY: No regressions?
  │   └─ If fail → Self-heal (debugger agent)
  ├─ Iteration 2...
  ├─ ...
  └─ Iteration N: <promise>DONE</promise> marked
  ↓
  🔍 Verification Point #5: OODA Completion Check
  ├─ Check: tasks.md all checkboxes marked [x]
  ├─ Check: <promise>DONE</promise> present
  ├─ Hook: post-phase-verify triggered (automatic)
  └─ Result: Triggers Phase 4 Quality Gate
  ↓
  ✅ Gate #3: Phase 4 Quality Gate (Automated)
  ├─ Launch: verification-agent (haiku model)
  ├─ Check: npm test (all pass)
  ├─ Check: npm run build (success)
  ├─ Check: npm run lint (0 errors)
  ├─ Check: npm run type-check (0 type errors)
  ├─ Check: state.json updated (implementationComplete = true)
  ├─ If PASS → Proceed to Phase 5
  └─ If FAIL → Block, return to Phase 4 with specific issues
  ↓
Phase 5 (Quality Validation)
  ↓
  🔍 Verification Point #6: Code Review
  ├─ Launch: 3x code-reviewer (parallel, different perspectives)
  ├─ Merge & deduplicate issues
  ├─ Launch: confidence-scorer
  ├─ Filter: Keep only ≥80 confidence issues
  └─ Result: High-confidence issues list
  ↓
  🔍 Verification Point #7: User Decision on Issues
  ├─ Present: Sorted issues (highest confidence first)
  └─ Check: 用户决策 (User Approval Gate #3: fix-all/fix-critical/accept-risk)
  ↓
  ✅ Gate #4: User Approval (Phase 5)
  ├─ If "Fix All" → Fix all ≥80 issues
  ├─ If "Fix Critical" → Fix only ≥95 issues
  └─ If "Accept Risk" → Proceed with issues (documented)
  ↓
  (If fixes were made)
  🔍 Verification Point #8: Post-Fix Verification
  ├─ Check: Tests still pass after fixes
  ├─ Check: Build still succeeds
  ├─ Check: No new issues introduced
  └─ Hook: post-phase-verify triggered (automatic)
  ↓
  ✅ Gate #5: Phase 5 Quality Gate (Automated)
  ├─ Launch: verification-agent (haiku model)
  ├─ Check: issues-scored.json exists
  ├─ Check: Quality gate decision recorded
  ├─ Check: Tests still passing (if fixes made)
  ├─ Check: state.json updated (qualityValidationComplete = true)
  ├─ If PASS → Proceed to Step 5 (Frontend Acceptance)
  └─ If FAIL → Block, return to Phase 5
  ↓
  🔍 Verification Point #8.5: Frontend Acceptance Testing (Step 5)
  ├─ Check: Application has frontend components
  ├─ Check: Base URL accessible (localhost:3000 or deployed)
  ├─ If frontend exists:
  │   ├─ Run: /ai:acceptance <url> --change <changeId> --report
  │   ├─ Validate: All pages load correctly
  │   ├─ Capture: Screenshots for evidence
  │   ├─ Generate: Markdown + HTML reports
  │   └─ Store: codebox/acceptance/{date}/{changeId}/
  ├─ If no frontend:
  │   └─ Skip this verification point
  └─ Result: Acceptance evidence collected
  ↓
  ✅ Gate #5.5: Frontend Acceptance Gate (Conditional)
  ├─ Check: acceptance state.json exists (if frontend)
  ├─ Check: All pages passed (if frontend)
  ├─ Check: Screenshots captured (if frontend)
  ├─ If PASS → Proceed to Phase 5.5 (Code Simplification)
  ├─ If FAIL → Report issues, allow user decision
  └─ If NO_FRONTEND → Skip to Phase 5.5
  ↓
Phase 5.5 (Code Simplification)
  ↓
  🔍 Verification Point #8.6: Code Simplification (Optional)
  ├─ Check: autoSimplify enabled in config
  ├─ If enabled: Apply code simplification
  └─ If disabled: Skip to Phase 6
  ↓
Phase 6 (Finalization)
  ↓
  🔍 Verification Point #9: Commit Readiness
  ├─ Check: All phases completed
  ├─ Check: No pending issues
  ├─ Check: Knowledge base updated
  └─ Check: User ready to commit
  ↓
  ✅ Complete
```

---

## 🚪 Verification Gates Summary

| Gate # | Type | Phase | Trigger | Decision | Blocking |
|--------|------|-------|---------|----------|----------|
| 1 | User Approval | 1 | proposal.md完成 | yes/no/refine | Yes |
| 2 | User Approval | 3 | design.md完成 | 1/2/3 approach | Yes |
| 3 | Quality Gate | 4 | OODA标记DONE | auto (pass/fail) | Yes |
| 4 | User Approval | 5 | issues发现 | fix-all/critical/accept | Yes |
| 5 | Quality Gate | 5 | 修复完成 | auto (pass/fail) | Yes |
| 5.5 | Acceptance Gate | 5 | 前端验收 (Step 5) | auto (pass/fail/skip) | Conditional |

**Total Gates**: 6个
**User Approval Gates**: 3个 (Phase 1, 3, 5)
**Quality Gates**: 2个 (Phase 4, 5)
**Acceptance Gates**: 1个 (Phase 5 Step 5, conditional on frontend)

---

## 🛡️ Defense in Depth Layers

### Layer 1: User Approval Gates

**Purpose**: Ensure AI understanding matches user intent

**Implementation**:
```typescript
// ai-dev/SKILL.md
async function phase1ApprovalGate(changeId: string) {
  const response = await AskUserQuestion({
    questions: [{
      question: "需求理解是否正确？",
      options: ["Yes - 继续", "Refine - 修正", "No - 取消"]
    }]
  });

  // Record in state.json
  state.userDecisions.phase1Approval = {
    decision: response.answer,
    timestamp: new Date().toISOString()
  };
}
```

**Catches**:
- ❌ Misunderstood requirements
- ❌ Wrong technical approach
- ❌ Scope creep
- ❌ Missing constraints

---

### Layer 2: Quality Gates (Automated)

**Purpose**: Verify technical quality automatically

**Implementation**:
```typescript
// ai-dev/SKILL.md
async function validatePhase4Completion(changeId: string) {
  const result = await Task({
    subagent_type: 'verification-agent',
    prompt: `Verify Phase 4 completion...`,
    model: 'haiku'
  });

  if (!result.passed) {
    return { action: 'retry', phase: 4, issues: result.failedChecks };
  }

  return { action: 'proceed', phase: 5 };
}
```

**Catches**:
- ❌ Failing tests
- ❌ Build errors
- ❌ Type errors
- ❌ Lint errors
- ❌ Incomplete tasks

---

### Layer 3: Stop Hooks (Automatic Triggers)

**Purpose**: Catch issues immediately after agent completes

**Implementation**:
```yaml
# ai-dev/hooks/post-phase-verify.md
trigger: agent_stop
conditions:
  - agent_name matches "code-|ralph-wiggum"
  - current_phase in [4, 5]
actions:
  - agent: verification-agent
    blocking: true
```

**Catches**:
- ❌ Agents claiming completion without verification
- ❌ State machine not updated
- ❌ Missing output files

---

### Layer 4: Ralph-Wiggum Self-Healing

**Purpose**: Auto-fix issues without user intervention

**Implementation**:
```typescript
// ai-dev/references/ooda-loop.md
async function ralphWiggumOODALoop(config) {
  for (let iteration = 1; iteration <= maxIterations; iteration++) {
    await implementTask(nextTask);

    // VERIFY: Assertions
    if (!assertionsPassed) {
      await selfHealTask(nextTask);  // Auto-fix!
      continue;
    }

    // VERIFY: Regression
    if (regressionDetected) {
      await fixRegressions();  // Auto-fix!
      continue;
    }
  }
}
```

**Catches & Fixes**:
- ✅ Failing assertions → Debug & retry
- ✅ Test regressions → Fix automatically
- ✅ Performance regressions → Optimize
- ✅ Build failures → Rollback & alternative approach

---

## 📊 Verification Points Detail

### Point #1: Knowledge Base Query (Phase 0)

**What**: Check if similar changes exist in knowledge base

**Files Checked**:
- `knowledge/patterns.json` - Design patterns used before
- `knowledge/errors.json` - Common errors and solutions
- `knowledge/learnings.md` - Lessons learned

**Benefits**:
- Learn from past mistakes
- Reuse successful patterns
- Avoid known pitfalls

---

### Point #2: Proposal Quality (Phase 1)

**What**: Verify requirement-analyzer produced complete proposal

**Checks**:
- ✅ proposal.md exists
- ✅ Contains: summary, tech stack, constraints, time estimate
- ✅ References global constraints (requirements.md, CLAUDE.md)
- ✅ User approval obtained

---

### Point #3: Discovery Completeness (Phase 2)

**What**: Ensure code-explorer found all relevant code

**Checks**:
- ✅ evidence.md exists
- ✅ Key files listed
- ✅ Patterns documented
- ✅ Dependencies identified

---

### Point #4: Design Quality (Phase 3)

**What**: Verify code-architect produced 3 valid approaches

**Checks**:
- ✅ design.md exists
- ✅ 3 approaches present (minimal, clean, pragmatic)
- ✅ Each has time estimate
- ✅ Tradeoffs documented
- ✅ User selected approach

---

### Point #5: OODA Completion (Phase 4)

**What**: Verify OODA loop truly completed all tasks

**Checks**:
- ✅ tasks.md: all checkboxes [x]
- ✅ <promise>DONE</promise> present
- ✅ Hook triggered automatically

**Trigger**: OODA loop marks `<promise>DONE</promise>`

---

### Point #6: Code Review (Phase 5)

**What**: Parallel code review with confidence filtering

**Process**:
1. Launch 3x code-reviewer (security, bugs, maintainability)
2. Merge & deduplicate issues
3. Launch confidence-scorer
4. Filter: Keep ≥80 confidence
5. Sort: Highest confidence first

**Output**: 5-10 high-confidence, actionable issues

---

### Point #7: User Issue Decision (Phase 5)

**What**: User decides how to handle found issues

**Options**:
- **Fix All**: Fix all ≥80 issues (recommended)
- **Fix Critical**: Fix only ≥95 issues (acceptable)
- **Accept Risk**: Proceed with issues (not recommended)

---

### Point #8: Post-Fix Verification (Phase 5)

**What**: Ensure fixes didn't break anything

**Checks**:
- ✅ Tests still pass
- ✅ Build still succeeds
- ✅ No new issues introduced (regression check)

---

### Point #8.5: Frontend Acceptance Testing (Phase 5.5)

**What**: Validate frontend functionality in real browser

**When to Run**:
- Project has frontend components (React, Vue, Angular, etc.)
- Changes affect UI/UX
- End-to-end testing required
- Visual regression testing needed

**Process**:

```yaml
frontend_acceptance:
  # Step 1: Check prerequisites
  prerequisites:
    - agent-browser installed
    - Application running (localhost:3000 or deployed URL)
    - Change ID available

  # Step 2: Determine acceptance mode
  mode_selection:
    full: "Version release, major changes"
    quick: "CI/CD, quick verification"
    regression: "Bug fixes, targeted changes"
    smoke: "Deployment health check"

  # Step 3: Execute acceptance
  execution:
    command: /ai:acceptance <url> --change <changeId> --report
    options:
      - "--pages <list>" for specific pages
      - "--quick" for quick mode
      - "--headed" for debugging

  # Step 4: Collect evidence
  evidence:
    screenshots: codebox/acceptance/{date}/{changeId}/screenshots/
    state: codebox/acceptance/{date}/{changeId}/state.json
    report_md: codebox/acceptance/{date}/{changeId}/report.md
    report_html: codebox/acceptance/{date}/{changeId}/report.html

  # Step 5: Update change state
  update:
    file: codebox/changes/active/{changeId}/state.json
    field: acceptance
    value:
      latestId: ACC-xxx
      status: passed/failed
      reportPath: codebox/acceptance/...
```

**Output Files**:

| File | Format | Purpose |
|------|--------|---------|
| `state.json` | JSON | Machine-readable acceptance state |
| `report.md` | Markdown | Version control, documentation |
| `report.html` | HTML | Sharing, offline viewing |
| `screenshots/*.png` | PNG | Visual evidence |

**Skip Conditions**:
- Backend-only projects (APIs, CLIs, libraries)
- No UI changes in the commit
- User explicitly skips

---

### Point #9: Commit Readiness (Phase 6)

**What**: Final check before commit

**Checks**:
- ✅ All phases completed
- ✅ No pending TODOs
- ✅ Knowledge base updated
- ✅ User confirmed ready

---

## 🔄 Self-Healing OODA Integration

### Ralph-Wiggum Enhancements

**Phase 4 OODA Loop with Self-Healing**:

```typescript
for (let iteration = 1; iteration <= 10; iteration++) {
  // ACT: Implement next task
  await implementTask(nextTask);

  // VERIFY: Multi-layer verification
  const verifications = [
    await verifyAssertions(nextTask),      // Layer 1
    await verifyTests(),                   // Layer 2
    await verifyRegressions(baseline),     // Layer 3
    await verifyPerformance(baseline)      // Layer 4
  ];

  // AUTO-FIX: Self-healing on failure
  for (const verification of verifications) {
    if (!verification.passed) {
      console.log(`🔧 Auto-fixing: ${verification.issue}`);
      await autoFix(verification);

      // Re-verify
      const retry = await verification.recheck();
      if (!retry.passed) {
        // Escalate if auto-fix failed
        return { success: false, reason: 'auto_fix_failed' };
      }
    }
  }

  console.log(`✅ Iteration ${iteration} complete and verified`);
}
```

**Benefits**:
- 🔄 Autonomous completion (no user intervention)
- ⚡ Faster iteration (immediate fixes)
- 🎯 Higher success rate (multiple retry attempts)
- 📊 Better quality (continuous verification)

---

## 📚 References

- **User Approval Gates**: `${CLAUDE_PLUGIN_ROOT}/skills/ai-dev/SKILL.md` (🚪 User Approval Gates section)
- **Phase Quality Gates**: `${CLAUDE_PLUGIN_ROOT}/skills/ai-dev/SKILL.md` (🔒 Phase Quality Gates section)
- **Stop Hook**: `${CLAUDE_PLUGIN_ROOT}/skills/ai-dev/hooks/post-phase-verify.md`
- **Verification Agent**: `${CLAUDE_PLUGIN_ROOT}/skills/ai-dev/agents/verification-agent.md`
- **Ralph-Wiggum OODA**: `${CLAUDE_PLUGIN_ROOT}/skills/ai-dev/references/ooda-loop.md` (Ralph-Wiggum Self-Completion section)
- **7-Phase Workflow**: `${CLAUDE_PLUGIN_ROOT}/skills/ai-dev/references/7-phase-workflow.md`
- **Frontend Acceptance**: `${CLAUDE_PLUGIN_ROOT}/commands/ai:acceptance.md`
- **Acceptance Reporter**: `${CLAUDE_PLUGIN_ROOT}/skills/acceptance-reporter/SKILL.md`
- **Agent Browser**: `${CLAUDE_PLUGIN_ROOT}/skills/agent-browser/SKILL.md`
- **Acceptance Patterns**: `${CLAUDE_PLUGIN_ROOT}/skills/agent-browser/references/acceptance-patterns.md`

---

**End of Verification Workflow**
