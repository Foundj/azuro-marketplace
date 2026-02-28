# Ultrawork Phase Details

> 各阶段详细说明和代码示例

## Phase 0: Confidence Gate

使用 `confidence-gate` skill 进行强制预检。

```yaml
Assessment:
  ≥90%: Proceed to ANALYZE
  70-89%: Present 2-3 alternatives, let user choose
  <70%: STOP. Ask targeted questions. Do NOT guess.

How to boost confidence:
  - Use Context7 MCP to query official documentation
  - Search codebase for existing patterns (LSP/Grep)
  - Ask user for missing context
```

---

## Phase 1: Task Analysis

```yaml
Complexity Detection:
  SIMPLE:
    - Single file modification
    - Bug fix with clear location
    → Execute directly with TDD

  MEDIUM:
    - 2-5 files affected
    - New function/component
    → Worktree optional, TDD required

  COMPLEX:
    - 5+ files affected
    - New feature/module
    → Worktree required, full workflow
```

---

## Phase 2: Requirement Clarification

**Only if ambiguous.** Ask maximum 3 questions, one at a time.

```
Clarification needed:
1. [Specific question about requirement]

Options:
A) [Option with clear implication]
B) [Option with clear implication]
C) Other (please specify)
```

---

## Phase 3: Worktree Isolation

### Step 1: Worktree Creation
```bash
# Create worktree
git worktree add .worktrees/<feature-name> -b feature/<feature-name>
cd .worktrees/<feature-name>
```

### Step 2: Codebox Setup
```bash
mkdir -p codebox/changes codebox/archive

# Create spec.md, plan.md, active.md
# See references/codebox-setup.md for templates
```

### Step 3: Project Setup
```bash
# Install dependencies (auto-detect)
[ -f package.json ] && npm install
[ -f requirements.txt ] && pip install -r requirements.txt

# Verify baseline
npm test 2>/dev/null || echo "No tests found"
```

---

## Phase 4: Plan Generation

使用 `task-templates` skill 生成原子任务。

### Task Template Example

```markdown
### Task 1: Write failing test

**Files:**
- Create: `tests/test_feature.py`

**Step 1:** Write the failing test
**Step 2:** Run test to verify it fails
Expected: FAIL
```

---

## Phase 5: Subagent Execution

使用 `subagent-driven-development` skill，每个任务一个子代理。

### Mode Selection

```typescript
// 检测 Agent Teams 是否启用
const agentTeamsEnabled = process.env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS === "1"

// 评估协作需求
const needsCollaboration = task.files.length > 3 || task.requiresTeam
```

---

## Phase 6: Two-Stage Review

**Stage 1: Spec Compliance Review**
- Verify implementation matches spec exactly
- Check: Missing / Extra / Misunderstood

**Stage 2: Code Quality Review**
- Security, performance, maintainability
- Use `code-reviewer` skill

---

## Phase 7: Continuation Enforcement

使用 `todo-continuation-enforcer` hook 强制完成。

```
Check TodoList:
- If incomplete → Loop back to EXECUTE
- If complete → Proceed to FINISH
```

---

## Phase 8-9: Finishing

```bash
# Run all tests
npm test

# Offer options
1. Merge to main
2. Create PR
3. Keep worktree
4. Discard changes

# Cleanup
git worktree remove .worktrees/<feature-name>
```

---

## Red Flags - STOP and Ask

- Requirements fundamentally unclear after 3 questions
- Tests fail repeatedly with no progress
- Subagent stuck in loop
- Spec compliance fails 3+ times on same issue