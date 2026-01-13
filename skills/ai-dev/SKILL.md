---
name: ai-dev
description: |
  This skill provides industrial-grade AI development orchestration with 7-phase gated workflow.
  It should be used when the user mentions "implement feature", "develop", "build", "ai:dev",
  "开发功能", "实现", "构建", or wants full development workflow with requirement interview,
  competitor research, OODA autonomous implementation, and quality validation.
version: 4.2.9
triggers:
  - implement
  - develop
  - build feature
  - ai:dev
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
| **Think** | `think`, `深度`, `考虑`, `分析` | Extended reasoning with higher token budget |
| **Ultra-Think** | `ultrathink`, `好好思考`, `好好想想`, `认真想` | Maximum thinking budget for complex decisions |
| **Explore** | `explore`, `熟悉`, `好好熟悉`, `学习`, `了解` | Deep codebase exploration before implementation |

---

## Core Workflow

### Phase Overview

| Phase | Name | Gate | Key Action |
|-------|------|------|------------|
| 0 | Context & Knowledge | Auto | Load project context, query knowledge, detect issues |
| 0.5 | Research | Auto/Skip | Competitor research (new features only) |
| 1 | Requirement Interview | User | Multi-round interview, generate proposal.md |
| 2 | Design Approval | User | Present approaches, user selects, generate design.md |
| 3 | Task Breakdown | Auto | Generate tasks.md with subtasks |
| 4 | Implementation | OODA | Autonomous execution until `<promise>DONE</promise>` |
| 5 | Quality Validation | Auto | Multi-perspective review, confidence-scorer ≥80 filter |
| 5.5 | Code Simplification | Auto/Skip | Polish code (if autoSimplify enabled) |
| 6 | Finalization | User | Archive to knowledge, commit |

### Phase Details

**Phase 0: Context & Knowledge**
- Load `codebox/project-snapshot.json` (incremental via git diff)
- Query `codebox/knowledge/` for patterns and errors
- Detect blocking issues (🔴), warnings (🟡), info (🟢)

**Phase 0.5: Research** (new features only)
- Multi-model research via `codeagent-wrapper.sh`
- Save to `codebox/research/[feature]-research.json`

**Phase 1: Requirement Interview**
- Multi-round interview (2-6 questions based on complexity)
- Parallel context collection from research, knowledge, project
- Generate `proposal.md`

**Phase 2: Design Approval**
- Present 2-3 design approaches
- Reference global constraints (`codebox/design.md`)
- Generate `design.md`

**Phase 3: Task Breakdown**
- Auto-generate `tasks.md` with subtasks
- Include success criteria and test requirements

**Phase 4: OODA Implementation**
- Autonomous loop via Stop hook
- Execute tasks, update checkboxes
- Output `<promise>DONE</promise>` to exit
- Max iterations: 50 (configurable)

**Phase 5: Quality Validation**
- 3x code-reviewer (security, bugs, maintainability)
- confidence-scorer filters ≥80 only
- verification-agent runs tests/build/lint

**Phase 5.5: Code Simplification** (auto when `autoSimplify: true`)
- Triggered automatically after Phase 5 passes (if enabled in config)
- Apply SOLID principles and complexity metrics
- Reduce complexity while preserving functionality
- Can also be triggered manually via "优化代码" / "simplify"

**Phase 6: Finalization**
- Update knowledge base with new patterns
- Archive change to `codebox/changes/archived/`
- Commit with structured message

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

---

## Integrated Skills

| Skill | Phase | Purpose |
|-------|-------|---------|
| `brainstorm-mode` | -1 | Socratic exploration for unclear requirements |
| `ai-dev-interview` | 1 | Multi-round requirement interview |
| `ai-dev-ooda` | 4 | OODA autonomous execution engine |
| `ai-dev-quality` | 5 | Multi-perspective code review |
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

## References

| Document | Description |
|----------|-------------|
| `references/changelog.md` | Version history and features |
| `references/commands.md` | Full command documentation |
| `references/agents.md` | Agent reference |
| `references/hooks-scripts.md` | Hooks and scripts |
| `references/project-structure.md` | codebox/ structure |
| `references/integrated-skills.md` | Skill integration details |
