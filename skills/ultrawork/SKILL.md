---
name: ultrawork
description: |
  One-word trigger for complete autonomous development workflow. This skill activates when the user
  mentions "ultrawork", "ulw", "自动完成", "全自动", or wants autonomous end-to-end task completion.
  It orchestrates the entire development process: requirement clarification, worktree isolation,
  TDD implementation, two-stage review, and continuous execution until <promise>DONE</promise>.
version: 5.0.13
triggers:
  - ultrawork
  - ulw
  - 自动完成
  - 全自动
  - autonomous
  - just do it
  - 帮我搞定
---

# Ultrawork: Autonomous Development Mode

> **Philosophy**: Human intervention during agentic work is a failure signal. The system should complete work without requiring babysitting.

## Core Principle

```
Human Intent → Agent Execution → Verified Result
      ↑                              ↓
      └──────── Minimum ─────────────┘
         (intervention only on true failure)
```

## Trigger Detection

Activate ultrawork when user prompt contains:
- `ultrawork` or `ulw`
- `自动完成` or `全自动`
- `autonomous` or `just do it`
- `帮我搞定` or `一键完成`

## The Ultrawork Flow

```
┌─────────────────────────────────────────────────────────────┐
│                    ULTRAWORK MODE                            │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. ANALYZE         Detect task complexity                   │
│       ↓             Simple (<3 files) → Direct execution     │
│       ↓             Complex (≥3 files) → Full workflow       │
│                                                              │
│  2. CLARIFY         If ambiguous → Ask 1-3 questions         │
│       ↓             If clear → Skip to next                  │
│                                                              │
│  3. ISOLATE         Complex task → Auto-create worktree      │
│       ↓             Run project setup, verify baseline       │
│                                                              │
│  4. PLAN            Generate bite-sized tasks (2-5 min each) │
│       ↓             TDD steps: test → fail → code → pass     │
│                                                              │
│  5. EXECUTE         Dispatch subagent per task               │
│       ↓             Self-review before handoff               │
│                                                              │
│  6. REVIEW          Stage 1: Spec compliance (不多不少)       │
│       ↓             Stage 2: Code quality                    │
│       ↓             Loop until both pass                     │
│                                                              │
│  7. CONTINUE        Check TodoList for remaining tasks       │
│       ↓             If incomplete → Loop back to EXECUTE     │
│       ↓             If complete → Proceed to FINISH          │
│                                                              │
│  8. FINISH          Run all tests                            │
│       ↓             Offer: Merge / PR / Keep / Discard       │
│       ↓             Cleanup worktree                         │
│                                                              │
│  9. DONE            Output <promise>DONE</promise>           │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Phase Details

### Phase 1: Task Analysis

```yaml
Complexity Detection:
  SIMPLE:
    - Single file modification
    - Bug fix with clear location
    - Config change
    → Execute directly with TDD

  MEDIUM:
    - 2-5 files affected
    - New function/component
    → Worktree optional, TDD required

  COMPLEX:
    - 5+ files affected
    - New feature/module
    - Architecture changes
    → Worktree required, full workflow
```

### Phase 2: Requirement Clarification

**Only if ambiguous.** Ask maximum 3 questions, one at a time.

```
Clarification needed:
1. [Specific question about requirement]

Options:
A) [Option with clear implication]
B) [Option with clear implication]
C) Other (please specify)
```

If requirements are clear → Skip directly to Phase 3.

### Phase 3: Worktree Isolation

**For MEDIUM/COMPLEX tasks:**

```bash
# Check existing directory
ls -d .worktrees 2>/dev/null || ls -d worktrees 2>/dev/null

# Verify gitignore
git check-ignore -q .worktrees 2>/dev/null || {
  echo ".worktrees/" >> .gitignore
  git add .gitignore && git commit -m "chore: ignore worktrees directory"
}

# Create worktree
git worktree add .worktrees/<feature-name> -b feature/<feature-name>
cd .worktrees/<feature-name>

# Project setup
[ -f package.json ] && npm install
[ -f requirements.txt ] && pip install -r requirements.txt
[ -f Cargo.toml ] && cargo build

# Verify baseline
npm test / pytest / cargo test
```

### Phase 4: Plan Generation

**Task granularity: 2-5 minutes per task**

```markdown
### Task 1: Write failing test for [feature]

**Files:**
- Create: `tests/test_feature.py`

**Step 1:** Write the failing test
```python
def test_feature_does_x():
    result = feature(input)
    assert result == expected
```

**Step 2:** Run test to verify it fails
```bash
pytest tests/test_feature.py -v
```
Expected: FAIL with "feature not defined"

---

### Task 2: Implement minimal code

**Files:**
- Create: `src/feature.py`

**Step 1:** Write minimal implementation
```python
def feature(input):
    return expected
```

**Step 2:** Run test to verify it passes
```bash
pytest tests/test_feature.py -v
```
Expected: PASS

**Step 3:** Commit
```bash
git add tests/ src/
git commit -m "feat: add feature"
```
```

### Phase 5: Subagent Execution

**Dispatch implementer subagent per task:**

```yaml
Task Tool:
  subagent_type: "general-purpose"
  description: "Implement Task N: [name]"
  prompt: |
    You are implementing Task N: [name]

    ## Task Description
    [FULL task text - don't make subagent read file]

    ## Before You Begin
    If you have questions about requirements, approach, or assumptions - ASK NOW.

    ## Your Job
    1. Implement exactly what the task specifies
    2. Follow TDD (test first, watch fail, implement, watch pass)
    3. Commit your work
    4. Self-review before reporting

    ## Report Format
    - What you implemented
    - Test results
    - Files changed
    - Any concerns
```

### Phase 6: Two-Stage Review

**Stage 1: Spec Compliance (不多不少)**

```yaml
Task Tool:
  subagent_type: "ai-dev:spec-compliance-reviewer"
  prompt: |
    ## What Was Requested
    [Task requirements]

    ## What Was Built
    [Implementer's report]

    ## CRITICAL: Do Not Trust the Report
    Read the actual code. Verify independently.

    Check:
    - Missing requirements?
    - Extra/unneeded work?
    - Misunderstandings?

    Report: ✅ Spec compliant OR ❌ Issues: [list with file:line]
```

**Stage 2: Code Quality** (only after Stage 1 passes)

```yaml
Task Tool:
  subagent_type: "ai-dev:code-reviewer"
  prompt: |
    Review code quality for Task N.

    Check:
    - Code cleanliness
    - Test quality
    - Following patterns
    - No AI slop

    Report: Strengths, Issues (Critical/Important/Minor), Assessment
```

### Phase 7: Continuation Enforcement

```yaml
After each task completion:
  1. Check TodoList for remaining tasks
  2. If incomplete AND no <promise>DONE</promise>:
     → Auto-continue to next task
  3. If all complete:
     → Proceed to Phase 8

This is what keeps Sisyphus rolling the boulder.
```

### Phase 8: Finishing

```
Implementation complete. What would you like to do?

1. Merge back to main locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

Execute chosen option, cleanup worktree if applicable.

### Phase 9: Completion

```
<promise>DONE</promise>

Summary:
- Feature implemented: [description]
- Files changed: [count]
- Tests: [count] passing
- Commits: [count]
```

## Red Flags - STOP and Ask

- Requirements fundamentally unclear after 3 questions
- Tests fail repeatedly with no progress
- Subagent stuck in loop
- Spec compliance fails 3+ times on same issue

## Integration

**Required skills:**
- `tdd-enforcement` - TDD discipline for all implementation
- `spec-compliance-review` - Stage 1 review
- `code-reviewer` - Stage 2 review
- `git-worktree` - Isolation for complex tasks

**Hooks:**
- `todo-continuation-enforcer` - Forces completion
- `comment-checker` - Prevents AI slop
