---
name: ultrawork
description: |
  This skill should be used when the user wants autonomous end-to-end task completion.
  It provides a one-word trigger for a complete development workflow, orchestrating
  requirement clarification, worktree isolation, TDD implementation, two-stage review,
  and continuous execution until <promise>DONE</promise>.
version: 5.1.8
triggers:
  - ultrawork
  - ulw
  - 自动完成
  - 全自动
  - autonomous
  - just do it
  - 帮我搞定
  - 一键开发
  - 自动实现
  - 任务闭环
  - team mode
  - 团队模式
---

# Ultrawork: Autonomous Development Mode

> **Philosophy**: Human intervention during agentic work is a failure signal. The system should complete work without requiring babysitting.

## 触发词

此技能触发于: "ultrawork", "ulw", "自动完成", "全自动", "autonomous", "一键开发".

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
│  0. CHECK           Confidence Gate (≥90% proceed)           │
│       ↓             <90% → Clarify / Research first          │
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

### Phase 0: Confidence Gate (using `confidence-gate` skill)

**Mandatory pre-execution check. Prevents wrong-direction work.**

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

### Phase 3: Worktree Isolation & Codebox Setup

**For MEDIUM/COMPLEX tasks (using `git-worktree` skill):**

#### Step 1: Worktree Creation
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
```

#### Step 2: Codebox Setup (STANDARD)
```bash
# Create codebox directory structure
mkdir -p codebox/changes
mkdir -p codebox/archive

# Create spec.md (requirements)
cat > codebox/spec.md << 'EOF'
# [Feature Name] Specification

## Requirements
- [List requirements from user request]

## Success Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Files Affected
- [List files to be created/modified]
EOF

# Create plan.md (implementation plan)
cat > codebox/plan.md << 'EOF'
# Implementation Plan

## Tasks
### Task 1: [Name]
- Time: 2-5 min
- Files: [list]
- TDD: test → fail → implement → pass

### Task 2: [Name]
...
EOF

# Create active.md (progress tracking)
cat > codebox/changes/active.md << 'EOF'
# Active Tasks

## In Progress
- [ ] Task 1
- [ ] Task 2

## Completed
- (none yet)

---
Status: IN_PROGRESS
Started: [date]
EOF
```

#### Step 3: Project Setup
```bash
# Install dependencies (auto-detect)
[ -f package.json ] && npm install
[ -f requirements.txt ] && pip install -r requirements.txt
[ -f Cargo.toml ] && cargo build
[ -f go.mod ] && go mod download

# Verify baseline (if tests exist)
npm test 2>/dev/null || pytest 2>/dev/null || cargo test 2>/dev/null || echo "No tests found"
```

### Phase 4: Plan Generation

**Use `task-templates` skill to generate atomic tasks (2-5 minutes each).**

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

### Phase 5: Subagent Execution

**Dispatch subagents using `subagent-driven-development` skill.**
One subagent per task with structured handoff.

#### Phase 5.0: Mode Selection (新增)

**检测 Agent Teams 是否启用并评估协作需求:**

```typescript
// 检测 Agent Teams 是否启用
const agentTeamsEnabled = process.env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS === "1"

// 评估任务复杂度和协作需求
const complexity = assessComplexity(task)
const needsCollaboration = task.files.length > 3 || task.requiresTeam

// 评估协作分数
function evaluateCollaborationNeeds(task): number {
  let score = 0

  // 文件数量
  if (task.files.length > 5) score += 0.3
  else if (task.files.length > 3) score += 0.15

  // 跨领域
  if (task.domains.length > 2) score += 0.3
  else if (task.domains.length > 1) score += 0.15

  // 需要沟通
  if (task.needsCommunication) score += 0.2

  // 并行机会
  if (task.parallelizable) score += 0.2

  return Math.min(score, 1.0)
}

// 路由决策
if (agentTeamsEnabled && needsCollaboration && collaborationScore > 0.7) {
  // 使用 Agent Teams 模式
  log("🚀 使用 Agent Teams 模式执行")
  return executeWithAgentTeams(task)
} else {
  // 使用传统子代理模式
  log("📦 使用传统子代理模式执行")
  return executeWithSubagents(task)
}
```

#### Phase 5.1: Agent Teams 执行模式 (新增)

**当协作分数 > 0.7 且 Agent Teams 启用时使用:**

```typescript
async function executeWithAgentTeams(task: Task) {
  // 1. 创建团队
  const team = await TeamCreate({
    team_name: `ultrawork-${task.id}`,
    description: task.description,
    agent_type: "team-orchestrator"
  })

  // 2. 选择团队模板
  const template = selectTeamTemplate(task.description)

  // 3. 生成队友
  for (const mate of template.teammates) {
    await Task({
      subagent_type: mate.type,
      team_name: team.name,
      name: mate.role,
      prompt: generateTeammatePrompt(mate, task),
      isolation: "worktree"  // 自动隔离
    })
  }

  // 4. 创建共享任务
  for (const t of plannedTasks) {
    await TaskCreate({
      subject: t.subject,
      description: t.description,
      activeForm: t.activeForm
    })
  }

  // 5. 设置依赖和分配
  for (const t of plannedTasks) {
    if (t.blockedBy) {
      await TaskUpdate({ taskId: t.id, addBlockedBy: t.blockedBy })
    }
    if (t.owner) {
      await TaskUpdate({ taskId: t.id, owner: t.owner })
    }
  }

  // 6. 监控执行
  return await monitorAndCleanup(team)
}

async function monitorAndCleanup(team: Team) {
  // 监控任务进度
  while (true) {
    const status = await TaskList()
    const allComplete = status.every(t => t.status === "completed")

    if (allComplete) {
      // 发送关闭请求
      for (const member of team.members) {
        await SendMessage({
          type: "shutdown_request",
          recipient: member.name,
          content: "任务完成，感谢贡献！"
        })
      }

      // 清理团队资源
      await TeamDelete()
      break
    }

    // 等待后继续检查
    await sleep(5000)
  }
}
```

#### Phase 5.2: 传统子代理执行模式

**CRITICAL: Use Task Tool for parallel execution**
```
Task Tool (parallel dispatch):
┌─────────────────────────────────────────────────────────────┐
│  Task 1 → subagent A ──────────────────┐                  │
│  Task 2 → subagent B ──────────────────┼─→ Wait for all   │
│  Task 3 → subagent C ──────────────────┘                  │
└─────────────────────────────────────────────────────────────┘
```

**Subagent Prompt Template:**
```yaml
Task Tool:
  subagent_type: "general-purpose"
  description: "Implement Task N: [name]"
  prompt: |
    You are implementing Task N: [name]

    ## Working Directory
    [worktree path, e.g., .worktrees/<feature-name>]

    ## Task Description
    [FULL task text - don't make subagent read file]

    ## Dependencies (if any)
    - Task M must complete first: [status]

    ## Before You Begin
    If you have questions about requirements, approach, or assumptions - ASK NOW.

    ## Your Job
    1. Implement exactly what the task specifies
    2. Follow TDD (test first, watch fail, implement, watch pass)
    3. Commit your work
    4. Self-review before reporting

    ## Report Format
    - What you implemented
    - Test results (run commands and show output)
    - Files changed (list with paths)
    - Any concerns or blockers
```

**Progress Tracking:**
```markdown
# Update codebox/changes/active.md after each task
- [x] Task 1: [name] ✅
- [ ] Task 2: [name] (in progress)
- [ ] Task 3: [name]
```

### Phase 6: Two-Stage Review

**CRITICAL: Use actual subagent calls for review, not manual checklists.**

#### Stage 1: Spec Compliance Review (using `ai-dev:spec-compliance-reviewer`)

```yaml
Task Tool:
  subagent_type: "ai-dev:spec-compliance-reviewer"
  description: "Review spec compliance for [feature]"
  prompt: |
    ## What Was Requested
    Read codebox/spec.md for the full requirements.

    ## What Was Built
    Read the implementation in:
    - [list of created/modified files]

    ## CRITICAL: Do Not Trust the Report
    Read the actual code yourself. Verify independently.

    ## Review Checklist
    - Missing requirements? (spec has X, code doesn't implement)
    - Extra/unneeded work? (code does Y, spec doesn't require)
    - Misunderstandings? (spec means A, code does B)

    ## Output Format
    ✅ Spec compliant: All requirements implemented correctly
    OR
    ❌ Issues found:
    - [file:line] Missing: [requirement]
    - [file:line] Extra: [unneeded work]
```

#### Stage 2: Code Quality Review (using `ai-dev:code-reviewer`)

```yaml
Task Tool:
  subagent_type: "ai-dev:code-reviewer"
  description: "Review code quality for [feature]"
  prompt: |
    Review code quality for the implementation.

    ## Files to Review
    - [list of created/modified files]

    ## Review Criteria
    - Code cleanliness (no dead code, clear naming)
    - Test quality (meaningful assertions, coverage)
    - Pattern consistency (follows project conventions)
    - No AI slop (checked by comment-checker hook)

    ## Output Format
    **Strengths:**
    - [positive aspects]

    **Issues:**
    - CRITICAL: [blocking issues]
    - IMPORTANT: [should fix]
    - MINOR: [nice to have]

    **Assessment:** ✅ Ready for merge / ⚠️ Needs revision
```

#### Review Loop

```yaml
if Stage 1 fails:
  - Fix spec compliance issues
  - Re-run Stage 1

if Stage 2 has CRITICAL issues:
  - Fix critical issues
  - Re-run Stage 2

if Stage 2 has IMPORTANT issues:
  - Offer to fix or proceed with warnings

if both pass:
  - Proceed to Phase 7
```

### Phase 7: Continuation Enforcement

**Enforced by `todo-continuation-enforcer` hook + Task tool tracking.**

```yaml
After each task completion:
  1. Update TaskUpdate(status: "completed")
  2. Update codebox/changes/active.md
  3. Check TaskList for remaining tasks
  4. If incomplete AND no <promise>DONE</promise>:
     → Auto-continue to next task
  5. If all complete:
     → Proceed to Phase 8

Task Tracking Pattern:
  TaskCreate(subject: "Task N: Name", description: "...")
  # ... do work ...
  TaskUpdate(taskId: "N", status: "completed")
```

**active.md Update Template:**
```markdown
# Active Tasks

## In Progress
- [ ] Task 3: [name] ← current

## Completed
- [x] Task 1: [name] ✅
- [x] Task 2: [name] ✅

---
Status: IN_PROGRESS
Last Updated: [timestamp]
```

This is what keeps Sisyphus rolling the boulder.

### Phase 8: Finishing

```
Implementation complete. What would you like to do?

1. Merge back to main locally
2. Push and create a Pull Request
3. Keep the branch as-is (I'll handle it later)
4. Discard this work

Which option?
```

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
- `confidence-gate` - Phase 0 pre-execution confidence check
- `tdd-enforcement` - TDD discipline for all implementation
- `spec-compliance-review` - Stage 1 review
- `code-reviewer` - Stage 2 review
- `git-worktree` - Isolation for complex tasks
- `task-templates` - Fine-grained planning
- `subagent-driven-development` - Atomic task execution
- `mcp-integration` - Context7/Tavily for documentation & research
- `team-collaboration` - Agent Teams 协作模式 (新增)

**Hooks:**
- `todo-continuation-enforcer` - Forces completion
- `comment-checker` - Prevents AI slop

---

## Dependencies

- `confidence-gate` - Phase 0 confidence check
- `tdd-enforcement` - TDD discipline
- `spec-compliance-review` - Stage 1 review
- `code-reviewer` - Stage 2 review
- `git-worktree` - Task isolation
- `task-templates` - Fine-grained planning
- `subagent-driven-development` - Atomic task execution
- `team-collaboration` - Agent Teams 协作 (可选，需启用实验功能)

---

## Version History

| Version | Changes |
|---------|---------|
| 5.2.0 | Added Agent Teams integration with auto-routing |
| 5.1.2 | Added team mode triggers |
| 5.0.20 | Added Chinese triggers and dependencies |
| 5.0.0 | Initial release with 9-phase workflow |
