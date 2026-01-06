# Optimization Plan: 92 → 95+ Score

> **Goal**: 提升ai-dev v2.0质量分数从92到95+
> **Current**: 92/100
> **Target**: 95+/100
> **Strategy**: 修复Medium Priority问题 + 完善文档

---

## 📊 Current Score Breakdown

| Category | Current | Target | Gap | Priority |
|----------|---------|--------|-----|----------|
| Completeness | 98/100 | 98/100 | 0 | - |
| Correctness | 95/100 | 98/100 | +3 | High |
| Integration | 90/100 | 95/100 | +5 | Medium |
| Code Quality | 92/100 | 96/100 | +4 | High |
| Documentation | 96/100 | 98/100 | +2 | Low |
| Consistency | 90/100 | 95/100 | +5 | Medium |

**Total**: 92 → **95+** (+3-5分)

---

## 🎯 Optimization Tasks

### Task 1: Add Error Handling (Correctness +3, Code Quality +2)

**Current Issue**:
- SKILL.md中的approval gates缺少error handling
- AskUserQuestion可能timeout或fail
- state.json write可能失败

**Fix**:

```typescript
// BEFORE (SKILL.md)
const response = await AskUserQuestion({...});
await recordPhase1Approval(changeId, response.answer);

// AFTER
async function phase1ApprovalGate(changeId: string): Promise<'yes' | 'no' | 'refine'> {
  const MAX_RETRIES = 3;
  const TIMEOUT = 300000; // 5 minutes

  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
    try {
      const response = await AskUserQuestion({
        questions: [{
          question: "需求理解是否正确？",
          header: "Phase 1 Approval",
          multiSelect: false,
          options: [...]
        }],
        timeout: TIMEOUT
      });

      const decision = response.answers["Phase 1 Approval"];

      // Validate decision
      if (!['yes', 'no', 'refine'].includes(decision)) {
        throw new Error(`Invalid decision: ${decision}`);
      }

      // Record decision with retry
      await retryWriteState(changeId, {
        userDecisions: {
          phase1Approval: {
            decision,
            timestamp: new Date().toISOString(),
            attempt
          }
        }
      }, maxRetries: 3);

      return decision;

    } catch (error) {
      console.error(`Approval gate attempt ${attempt}/${MAX_RETRIES} failed: ${error.message}`);

      if (attempt === MAX_RETRIES) {
        console.error('❌ Cannot proceed without user approval');
        throw new Error('Phase 1 approval gate failed after 3 attempts');
      }

      console.log(`Retrying in 5 seconds...`);
      await sleep(5000);
    }
  }
}

// Helper: Retry write with exponential backoff
async function retryWriteState(
  changeId: string,
  updates: Partial<ChangeState>,
  maxRetries: number = 3
): Promise<void> {
  for (let i = 0; i < maxRetries; i++) {
    try {
      await writeState(changeId, updates);
      return;
    } catch (error) {
      if (i === maxRetries - 1) throw error;
      const delay = Math.pow(2, i) * 1000; // Exponential backoff
      console.log(`State write failed, retrying in ${delay}ms...`);
      await sleep(delay);
    }
  }
}
```

**Files to modify**:
- `ai-dev/SKILL.md` (3 approval gates)
- Add helper functions section

**Impact**: +3 Correctness, +2 Code Quality

---

### Task 2: Add Flaky Test Retry Logic (Code Quality +2)

**Current Issue**:
- verification-agent.md直接运行测试，不处理flaky tests
- 偶尔会有1-2%的测试不稳定

**Fix**:

```typescript
// Add to verification-agent.md

async function runTestsWithRetry(options: {
  maxRetries?: number;
  retryDelay?: number;
} = {}): Promise<TestResult> {
  const { maxRetries = 2, retryDelay = 5000 } = options;

  let lastError: any;
  const failedTests: string[] = [];

  for (let attempt = 1; attempt <= maxRetries + 1; attempt++) {
    console.log(`Running tests (attempt ${attempt}/${maxRetries + 1})...`);

    const result = await Bash({
      command: 'npm test -- --json --outputFile=test-results.json',
      timeout: 180000,
      description: 'Run test suite with retry logic'
    });

    if (result.exitCode === 0) {
      console.log('✅ All tests passed');
      return {
        passed: true,
        totalTests: 0, // populated from JSON
        passingTests: 0,
        failedTests: []
      };
    }

    // Parse test results
    const testResults = JSON.parse(await Read({ file_path: 'test-results.json' }));
    const currentFailedTests = testResults.testResults
      .filter(t => t.status === 'failed')
      .map(t => t.name);

    // Check if same tests are failing (flaky) or different tests (real issue)
    if (attempt > 1) {
      const newFailures = currentFailedTests.filter(
        name => !failedTests.includes(name)
      );

      if (newFailures.length > 0) {
        // New failures detected - this is a real issue, stop retrying
        console.log(`❌ New test failures detected, stopping retry`);
        lastError = result;
        break;
      }
    }

    failedTests.push(...currentFailedTests);
    lastError = result;

    if (attempt <= maxRetries) {
      console.log(`⚠️ ${currentFailedTests.length} tests failed, retrying in ${retryDelay}ms...`);
      await sleep(retryDelay);
    }
  }

  // All retries exhausted
  return {
    passed: false,
    totalTests: testResults.numTotalTests,
    passingTests: testResults.numPassedTests,
    failedTests: [...new Set(failedTests)]
  };
}
```

**Files to modify**:
- `agents/verification-agent.md`

**Impact**: +2 Code Quality

---

### Task 3: Add State.json Validation (Correctness +2, Consistency +3)

**Current Issue**:
- state.json没有runtime validation
- 损坏的state.json可能导致系统crash

**Fix**:

```typescript
// Create: schemas/state-schema.json

{
  "$schema": "http://json-schema.org/draft-07/schema#",
  "title": "Change State",
  "type": "object",
  "required": ["changeId", "currentPhase", "status"],
  "properties": {
    "changeId": {
      "type": "string",
      "pattern": "^[0-9]{3}-[a-z0-9-]+$"
    },
    "currentPhase": {
      "type": "integer",
      "minimum": 0,
      "maximum": 6
    },
    "status": {
      "type": "string",
      "enum": ["active", "completed", "cancelled"]
    },
    "userDecisions": {
      "type": "object",
      "properties": {
        "phase1Approval": {
          "type": "string",
          "enum": ["yes", "no", "refine"]
        },
        "phase3SelectedApproach": {
          "type": "integer",
          "minimum": 1,
          "maximum": 3
        },
        "phase5IssueDecision": {
          "type": "string",
          "enum": ["fix-all", "fix-critical", "accept"]
        }
      }
    }
  }
}
```

```typescript
// Add to state-machine-spec.md

import Ajv from 'ajv';

const ajv = new Ajv();
const stateSchema = JSON.parse(
  await Read({ file_path: 'schemas/state-schema.json' })
);
const validateState = ajv.compile(stateSchema);

async function readState(changeId: string): Promise<ChangeState | null> {
  try {
    const content = await Read({ file_path: `changes/active/${changeId}/state.json` });
    const state = JSON.parse(content);

    // Validate against schema
    if (!validateState(state)) {
      console.error('❌ Invalid state.json:');
      console.error(validateState.errors);

      // Attempt auto-repair
      const repaired = attemptAutoRepair(state, validateState.errors);
      if (repaired) {
        console.log('✅ State auto-repaired');
        await writeState(changeId, repaired);
        return repaired;
      }

      throw new Error('State validation failed');
    }

    return state;
  } catch (error) {
    console.error(`Cannot read state for ${changeId}: ${error.message}`);
    return null;
  }
}

function attemptAutoRepair(state: any, errors: any[]): ChangeState | null {
  // Common repairs
  const repairs = {
    missingCurrentPhase: () => state.currentPhase = 0,
    missingStatus: () => state.status = 'active',
    invalidPhase: () => state.currentPhase = Math.min(6, Math.max(0, state.currentPhase))
  };

  for (const error of errors) {
    if (error.keyword === 'required' && error.params.missingProperty === 'currentPhase') {
      repairs.missingCurrentPhase();
    }
    // ... more repair strategies
  }

  // Re-validate
  if (validateState(state)) {
    return state;
  }

  return null;
}
```

**Files to create**:
- `schemas/state-schema.json`

**Files to modify**:
- `references/state-machine-spec.md`

**Impact**: +2 Correctness, +3 Consistency

---

### Task 4: Improve Safety (Code Quality +2, Consistency +2)

**Current Issue**:
- Rollback uses destructive `git reset --hard`
- No file size limits in code-reviewer
- No safeguards against infinite loops

**Fix 1: Safer Rollback**

```typescript
// Update ooda-loop.md

async function safeRollback(task: Task): Promise<void> {
  console.log(`⏪ Rolling back Task ${task.number}...`);

  // 1. Create backup first
  const backupName = `pre-rollback-task-${task.number}-${Date.now()}`;
  await Bash({
    command: `git stash push -m "${backupName}"`,
    description: 'Create backup before rollback'
  });

  // 2. Soft reset (preserves changes as uncommitted)
  const resetResult = await Bash({
    command: 'git reset --soft HEAD~1',
    description: 'Soft reset to previous commit'
  });

  if (resetResult.exitCode !== 0) {
    // Restore from backup
    await Bash({ command: `git stash pop` });
    throw new Error('Rollback failed');
  }

  console.log(`✅ Rolled back. Backup saved as stash: ${backupName}`);
  console.log(`💡 To restore: git stash apply stash@{0}`);
}

// Add self-healing loop detection
const MAX_CONSECUTIVE_FAILURES = 5;
let consecutiveFailures = 0;

if (consecutiveFailures >= MAX_CONSECUTIVE_FAILURES) {
  console.log(`🛑 Too many consecutive failures (${consecutiveFailures})`);
  console.log(`Possible infinite loop detected. Escalating to user.`);

  await AskUserQuestion({
    questions: [{
      question: `Task ${currentTask.number} failed ${consecutiveFailures} times. How to proceed?`,
      header: "Self-Healing Loop Detected",
      multiSelect: false,
      options: [
        { label: "Skip Task", description: "Skip this task and continue" },
        { label: "Manual Fix", description: "Let me fix it manually" },
        { label: "Cancel Change", description: "Cancel the entire change" }
      ]
    }]
  });
}
```

**Fix 2: File Size Limits**

```typescript
// Add to code-reviewer.md

const MAX_FILE_SIZE = 1024 * 1024; // 1MB
const BINARY_EXTENSIONS = ['.png', '.jpg', '.pdf', '.zip', '.tar.gz'];

async function shouldReviewFile(filePath: string): Promise<boolean> {
  // Check extension
  const ext = path.extname(filePath);
  if (BINARY_EXTENSIONS.includes(ext)) {
    console.log(`⏭️ Skipping binary file: ${filePath}`);
    return false;
  }

  // Check file size
  try {
    const stats = await Bash({
      command: `stat -f%z "${filePath}" 2>/dev/null || stat -c%s "${filePath}"`,
      description: 'Get file size'
    });

    const size = parseInt(stats.stdout.trim());

    if (size > MAX_FILE_SIZE) {
      console.log(`⏭️ Skipping large file: ${filePath} (${Math.round(size / 1024)}KB > 1MB)`);
      return false;
    }
  } catch (error) {
    // File doesn't exist or stat failed - skip
    return false;
  }

  return true;
}
```

**Files to modify**:
- `references/ooda-loop.md`
- `agents/quality/code-reviewer.md`

**Impact**: +2 Code Quality, +2 Consistency

---

### Task 5: Complete Documentation (Documentation +2)

**Current Issue**:
- issue-interface.json缺少一些validation rules
- templates/tasks-template.md缺少rendering说明
- 一些cross-reference不完整

**Fix 1: Enhance issue-interface.json**

```json
{
  "properties": {
    "line": {
      "type": "integer",
      "minimum": 1,
      "description": "Line number where issue occurs (≥1)"
    },
    "column": {
      "type": "integer",
      "minimum": 1,
      "description": "Optional column number for precise location"
    },
    "auto_fixable": {
      "type": "boolean",
      "default": false,
      "description": "Whether this issue can be automatically fixed"
    },
    "references": {
      "type": "array",
      "items": {
        "type": "string",
        "pattern": "^https?://.+",
        "description": "URL references (must be valid HTTP/HTTPS)"
      }
    }
  }
}
```

**Fix 2: Add Template Rendering Guide**

```markdown
<!-- Add to tasks-template.md -->

## 📖 How to Use This Template

### Method 1: Manual Replacement (Simple)

```bash
# Copy template
cp templates/tasks-template.md changes/active/001-user-login/tasks.md

# Replace placeholders
sed -i '' 's/{{CHANGE_ID}}/001-user-login/g' changes/active/001-user-login/tasks.md
sed -i '' 's/{{CURRENT_ITERATION}}/1/g' changes/active/001-user-login/tasks.md
sed -i '' 's/{{MAX_ITERATIONS}}/10/g' changes/active/001-user-login/tasks.md
```

### Method 2: Template Engine (Programmatic)

```typescript
import Mustache from 'mustache';

const template = await Read({
  file_path: 'templates/tasks-template.md'
});

const rendered = Mustache.render(template, {
  CHANGE_ID: '001-user-login',
  CURRENT_ITERATION: 1,
  MAX_ITERATIONS: 10,
  START_TIME: new Date().toISOString(),
  LAST_UPDATE: new Date().toISOString()
});

await Write({
  file_path: 'changes/active/001-user-login/tasks.md',
  content: rendered
});
```
```

**Fix 3: Add Cross-Reference Index**

```markdown
<!-- Create: references/cross-reference-index.md -->

# Cross-Reference Index

Quick lookup for which files reference each other.

## By Component

### State Machine
- **Defined in**: `references/state-machine-spec.md`
- **Used by**:
  - `SKILL.md` (read/write state)
  - `session-manager/SKILL.md` (restore state)
  - `agents/verification-agent.md` (check state)
  - `hooks/post-phase-verify.md` (update state)

### Knowledge Base
- **Defined in**: `references/knowledge-base-schema.md`
- **Used by**:
  - `hooks/pre-change-check.md` (query)
  - `SKILL.md` Phase 6 (update)
  - `agents/requirement-analyzer.md` (apply patterns)

### Issue Interface
- **Defined in**: `schemas/issue-interface.json`
- **Producers**: `agents/quality/code-reviewer.md`
- **Consumers**: `agents/quality/confidence-scorer.md`
- **Validators**: Both agents validate against schema

## By Phase

### Phase 0
- Hook: `hooks/pre-change-check.md`
- Knowledge: `references/knowledge-base-schema.md`
- Output: `phase0-context.md`

### Phase 1
- Agent: requirement-analyzer
- Input: user request, phase0-context.md
- Gate: User approval (yes/no/refine)
- Output: `proposal.md`

[... continue for all phases]
```

**Files to modify**:
- `schemas/issue-interface.json`
- `templates/tasks-template.md`

**Files to create**:
- `references/cross-reference-index.md`

**Impact**: +2 Documentation

---

## 📊 Expected Score After Optimization

| Category | Before | After | Improvement |
|----------|--------|-------|-------------|
| Completeness | 98 | 98 | - |
| Correctness | 95 | 98 | +3 ✅ |
| Integration | 90 | 95 | +5 ✅ |
| Code Quality | 92 | 96 | +4 ✅ |
| Documentation | 96 | 98 | +2 ✅ |
| Consistency | 90 | 95 | +5 ✅ |

**Total**: 92 → **96.7** (+4.7)

**Rounded**: **97/100** 🎯

---

## ✅ Implementation Checklist

- [ ] Task 1: Error Handling
  - [ ] Add try-catch to phase1ApprovalGate
  - [ ] Add try-catch to phase3SelectionGate
  - [ ] Add try-catch to phase5DecisionGate
  - [ ] Add retryWriteState helper
  - [ ] Add timeout handling

- [ ] Task 2: Flaky Test Retry
  - [ ] Add runTestsWithRetry function
  - [ ] Update verification-agent to use retry
  - [ ] Add test result comparison logic

- [ ] Task 3: State Validation
  - [ ] Create state-schema.json
  - [ ] Add validation to readState
  - [ ] Add auto-repair logic
  - [ ] Update state-machine-spec.md

- [ ] Task 4: Safety Improvements
  - [ ] Replace git reset --hard with safer approach
  - [ ] Add backup before rollback
  - [ ] Add file size limits to code-reviewer
  - [ ] Add infinite loop detection

- [ ] Task 5: Documentation
  - [ ] Enhance issue-interface.json
  - [ ] Add rendering guide to tasks-template.md
  - [ ] Create cross-reference-index.md

---

## 🚀 Execution Order

1. **Task 3** (State Validation) - 基础设施，其他任务会用到
2. **Task 1** (Error Handling) - 最高优先级，影响correctness
3. **Task 4** (Safety) - 防止数据丢失
4. **Task 2** (Flaky Tests) - 改进可靠性
5. **Task 5** (Documentation) - 最后完善文档

**Estimated Time**: 2-3 hours

---

**Plan Created**: 2024-01-04
**Target Completion**: Today
**Expected Score**: 97/100
