---
name: ai-dev
description: |
  This skill provides industrial-grade AI development orchestration with 7-phase gated workflow.
  It should be used when the user mentions "implement feature", "develop", "build", "开发功能",
  "实现", "构建", or wants full development workflow with requirement interview,
  competitor research, OODA autonomous implementation, and quality validation.
  Note: Use /ai:dev command as the primary entry point. This skill is the backend implementation.
version: 6.0.0
status: ga
triggers:
  - implement
  - develop
  - build feature
  - 开发功能
  - 实现功能
  - 实现
  - 构建
  - 开发
---

# AI-Dev v4.2 (Evolution Edition)

> The next generation of autonomous development agents. Featuring **Evaluation-Driven Development (EDD)**, **Worker Sessions**, **Reflexion System**, and **Attention Management**.

## Quick Start

```bash
ai implement user authentication   # Full 7-phase workflow
dev fix login button bug           # Quick mode (auto-detected)
ai ulw 重构整个模块                 # Ultrawork mode with parallel agents
ai --parallel implement API        # Parallel mode (explicit)
ai quick update readme             # Quick mode (explicit)
ai think design new architecture   # Extended thinking mode
ai 好好思考 设计架构                # Ultra-think mode (中文)
/ai:dev auto                       # Auto-complete remaining tasks
/ai:status                         # Check current progress
```

### Direct Agent Calls

```bash
@oracle review this architecture design
@librarian find how authentication is implemented
@explore-fast find all API endpoints
```

---

## Execution Modes

| Mode | Keywords | Behavior |
|------|----------|----------|
| **Standard** | (default) | Full 7-phase workflow with user approval gates |
| **Quick** | `quick`, `fix`, `修复`, `赶紧` | Skip phases 0.5, 1, 2. Direct to implementation |
| **Ultrawork** | `ulw`, `全力`, `并行` | Maximum parallelism with background agents |
| **Parallel** | `--parallel`, `并行执行` | Wave → Checkpoint → Wave parallel execution |
| **Think** | `think`, `深度`, `考虑`, `分析` | Extended reasoning with higher token budget |
| **Ultra-Think** | `ultrathink`, `好好思考`, `好好想想`, `认真想` | Maximum thinking budget for complex decisions |
| **Explore** | `explore`, `熟悉`, `好好熟悉`, `学习`, `了解` | Deep codebase exploration before implementation |

**Parallel Execution**: See `references/parallel-execution.md` for Wave → Checkpoint → Wave pattern.

---

## Core Workflow

### Phase Overview

| Phase | Name | Gate | Key Action |
|-------|------|------|------------|
| 0 | Context & Knowledge | Auto | Load project context, query knowledge, **confidence gate** |
| 0.5 | Research | Auto/Skip | Competitor research (new features only) |
| 1 | Requirement Interview | User | Multi-round interview, generate proposal.md |
| 2 | Design Approval | User | Present approaches, user selects, generate design.md |
| 2.5 | Worktree Setup | Auto | Create isolated worktree for feature development |
| 3 | Task Breakdown | Auto | Generate tasks.md with 2-5min atomic subtasks |
| 4 | Implementation | OODA | Autonomous execution with **TDD enforcement** |
| 5 | Quality Validation | Auto | Spec compliance → Code review → Confidence ≥80 filter |
| 5.5 | Code Simplification | Auto/Skip | Polish code (if autoSimplify enabled) |
| 6 | Finalization | User | Archive to knowledge, commit, cleanup worktree |

### Phase Details

**Phase 0: Context & Knowledge**
- **Use:** [`confidence-gate`](../confidence-gate/SKILL.md), [`knowledge-graph`](../knowledge-graph/SKILL.md), [`mcp-integration`](../mcp-integration/SKILL.md)
- Load `codebox/project-snapshot.json` (incremental via git diff)
- Query `codebox/knowledge/` for patterns and errors
- Detect blocking issues (🔴), warnings (🟡), info (🟢)
- **★ Run Confidence Gate** (v5.0.7)
  - ≥90%: Proceed immediately
  - 70-89%: Present alternatives, user chooses
  - <70%: Must ask clarifying questions

**Phase 0.5: Research** (new features only)
- **Use:** [`competitor-research`](../competitor-research/SKILL.md), [`mcp-integration`](../mcp-integration/SKILL.md)
- Multi-source research via WebSearch/MCP Tavily
- Save to `codebox/research/[feature]-research.md`

**Phase 1: Requirement Interview**
- **Use:** [`ai-dev-interview`](../ai-dev-interview/SKILL.md), [`interaction-protocol`](../interaction-protocol/SKILL.md)
- Multi-round interview (2-6 questions based on complexity)
- Parallel context collection from research, knowledge, project
- Generate `proposal.md`

**Phase 2: Design Approval**
- Present 2-3 design approaches
- Reference global constraints (`codebox/design.md`)
- Generate `design.md`

**Phase 2.5: Worktree Setup** (v5.0.7)
- **Use:** [`git-worktree`](../git-worktree/SKILL.md)
- Create isolated worktree: `.worktrees/{change-id}`
- Install dependencies automatically
- Verify test baseline passes
- Parallel development without branch conflicts

**Phase 3: Task Breakdown**
- **Use:** [`task-templates`](../task-templates/SKILL.md), [`task-dependency-analyzer`](../task-dependency-analyzer/SKILL.md)
- Auto-generate `tasks.md` with atomic subtasks (2-5 minutes each)
- Each task includes: file path, verify command, acceptance criteria
- Include success criteria and test requirements

**Phase 4: OODA Implementation**
- **Use:** [`ai-dev-ooda`](../ai-dev-ooda/SKILL.md), [`tdd-enforcement`](../tdd-enforcement/SKILL.md), [`subagent-driven-development`](../subagent-driven-development/SKILL.md)
- Autonomous loop via Stop hook
- **★ TDD Enforcement** (v5.0.7): Red → Green → Refactor cycle
- Execute tasks, update checkboxes
- Output `<promise>DONE</promise>` to exit
- Max iterations: 50 (configurable)

**Phase 5: Quality Validation**
- **Use:** [`spec-compliance-review`](../spec-compliance-review/SKILL.md), [`ai-dev-quality`](../ai-dev-quality/SKILL.md), [`agent-browser`](../agent-browser/SKILL.md), [`acceptance-reporter`](../acceptance-reporter/SKILL.md)
- **Step 1**: spec-compliance-reviewer (规格符合性审查)
  - 验证实现是否**不多不少**符合原始需求
  - Missing/Extra/Misunderstood 检查
- **Step 2**: 3x code-reviewer (security, bugs, maintainability)
- **Step 3**: confidence-scorer filters ≥80 only
- **Step 4**: verification-agent runs tests/build/lint
- **Step 5**: Frontend Acceptance (条件性执行)
  - 检测项目是否有前端组件
  - 自动运行 `/ai:acceptance` 验收测试
  - 收集截图证据，生成报告
  - 后端项目自动跳过

**Phase 5.5: Code Simplification** (auto when `autoSimplify: true`)
- **Use:** [`code-simplifier`](../code-simplifier/SKILL.md)
- Triggered automatically after Phase 5 passes (if enabled in config)
- Apply SOLID principles and complexity metrics
- Reduce complexity while preserving functionality
- Can also be triggered manually via "优化代码" / "simplify"

**Phase 6: Finalization**
- **Use:** [`knowledge-graph`](../knowledge-graph/SKILL.md), [`git-worktree`](../git-worktree/SKILL.md)
- Update knowledge base with new patterns
- Archive change to `codebox/changes/archived/`
- Commit with structured message
- **★ Cleanup worktree** (v5.0.7): Remove after merge

---

## Key Features

### Worker Sessions (Context Scaling)

When context reaches **80%**, spawns dedicated sub-agent:
- Semantic context transfer via `handover.md`
- Max Depth = 2 (safety limit)

### Reflexion System (Self-Learning)

- Every verification failure logged to `solutions_learned.jsonl`
- Before tasks, query previous solutions to avoid mistakes

### Attention Management (v4.1)

Read Before Decide pattern prevents goal drift:
- Each OODA iteration reads `tasks.md` to refresh goals
- Every 5 iterations, run `/focus` to refresh attention window
- Works with context-bridge for long sessions

### Smart Empty Command (v4.2)

When `/ai:dev` or `/ai:dev auto` runs without arguments:
- Detects active changes in `codebox/changes/active/`
- Offers to continue or start new

### LSP-First Navigation (v5.0.9)

**Always prefer LSP tools over grep/glob for code navigation:**

| Task | Use LSP | Fallback |
|------|---------|----------|
| Find definition | `LSP.goToDefinition` | Grep |
| Find references | `LSP.findReferences` | Grep |
| Get type info | `LSP.hover` | Read |
| Find implementations | `LSP.goToImplementation` | Grep |
| Call hierarchy | `LSP.incomingCalls/outgoingCalls` | Manual |

**Benefits:**
- Semantic understanding (not text matching)
- Accurate cross-file navigation
- Type-aware references
- Respects language semantics

---

## Integrated Skills

| Skill | Phase | Purpose |
|-------|-------|---------|
| `confidence-gate` | 0 | Pre-execution confidence checking (≥90%/70-89%/<70%) |
| `mcp-integration` | 0, 0.5 | External tool integration (Context7, Tavily) |
| `brainstorm-mode` | -1 | Socratic exploration for unclear requirements |
| `competitor-research` | 0.5 | MCP-enhanced research with Tavily/Context7 |
| `ai-dev-interview` | 1 | Multi-round requirement interview |
| `git-worktree` | 2.5, 6 | Isolated development workspace management |
| `ai-dev-ooda` | 4 | OODA autonomous execution engine with TDD |
| `ai-dev-quality` | 5 | Multi-perspective code review |
| `agent-browser` | 5 | Frontend acceptance testing (E2E) |
| `acceptance-reporter` | 5 | Acceptance report generation (MD + HTML) |
| `code-simplifier` | 5.5 | Code refinement and simplification |
| `thinking-engine` | 0 | Structured thinking for complex decisions |
| `knowledge-graph` | 0,4,6 | Cross-project knowledge management |
| `context-bridge` | Cross-session | Lightweight context persistence |
| `session-manager` | Cross-session | Full project recovery |

---

## Commands

| Command | Description |
|---------|-------------|
| `/ai:dev <feature>` | Full 7-phase development workflow |
| `/ai:dev auto` | Auto-complete remaining tasks |
| `/ai:fix <bug>` | Quick bug fix (subagent mode) |
| `/ai:status` | Check current progress |
| `/ai:session-save` | Save session progress |
| `/ai:session-resume` | Resume saved session |

See `references/commands.md` for full command list.

---

## Agents

| Agent | Purpose |
|-------|---------|
| `@oracle` | Strategic reasoning, architecture decisions |
| `@librarian` | Documentation lookup, pattern discovery |
| `@explore-fast` | Quick file discovery (30s timeout) |
| `requirement-interviewer` | Phase 1 interviews |
| `code-reviewer` | Phase 5 issue detection |
| `quick-fixer` | Fast bug fixes |

See `references/agents.md` for full agent list.

---

## Project Structure

```
codebox/
├── config.json                # Project config
├── requirements.md            # Global requirements
├── design.md                  # Architecture constraints
├── CLAUDE.md                  # AI behavior rules
├── knowledge/                 # Patterns & errors
├── research/                  # Competitor research
├── context/                   # Lite mode files
└── changes/
    ├── active/[id]/           # Current change
    └── archived/              # Completed changes
```

See `references/project-structure.md` for full structure.

---

## Common Pitfalls

### Pitfall 1: Skipping Requirement Interview
**Symptom:** Agent jumps straight to Phase 3/4, produces code that doesn't match user intent.
**Consequence:** Rework costs 3-5x more than the interview would have taken.
**Fix:** Only skip Phase 1 with `quick` mode for bug fixes. New features always need Phase 1.

### Pitfall 2: Over-Granular Task Breakdown
**Symptom:** Phase 3 generates 20+ tasks for a simple feature. Each task is trivially small.
**Consequence:** Context overhead per task exceeds the work itself. Subagents spend more time reading context than coding.
**Fix:** Target 5-10 tasks. Each task should be 2-5 minutes of work, not 30 seconds.

### Pitfall 3: Ignoring Confidence Gate
**Symptom:** Agent proceeds at <70% confidence, makes assumptions, builds the wrong thing.
**Consequence:** Phase 5 review catches fundamental misalignment. Entire implementation discarded.
**Fix:** <70% must ask clarifying questions. No exceptions. This is cheaper than rebuilding.

---

## References

| Document | Description |
|----------|-------------|
| `references/changelog.md` | Version history and features |
| `references/commands.md` | Full command documentation |
| `references/agents.md` | Agent reference |
| `references/hooks-scripts.md` | Hooks and scripts |
| `references/project-structure.md` | codebox/ structure |
| `references/integrated-skills.md` | Skill integration details |
