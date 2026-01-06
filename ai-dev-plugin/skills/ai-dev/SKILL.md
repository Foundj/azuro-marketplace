---
name: ai-dev
description: |
  Industrial-grade AI development orchestration with 7-phase gated workflow.
  Features intelligent requirement interviewing, competitor research, OODA autonomous completion, 
  knowledge management, and project context awareness.

  **TRIGGERS**: ai, dev, build, implement, fix, review, optimize, refactor
  **中文触发**: 开发, 实现, 构建, 修复, 优化, 重构
  
  **MODIFIERS** (append to trigger, priority: ulw > ultrathink > think > quick):
  - `ulw` / `ultrawork` / `全力` / `全自动` → Ultrawork mode (parallel agents, continuous execution)
  - `ultrathink` / `好好思考` / `深思熟虑` → Ultra-think mode (maximum thinking budget)
  - `think` / `思考` / `想一想` / `仔细` / `深度` → Extended thinking mode
  - `quick` / `快速` / `简单` / `快点` → Quick mode (skip phases 0.5/1/2)
  
  **AUTO-DETECT** (based on task verb):
  - fix/update/patch/修复/修改 → quick mode
  - implement/build/create/实现/构建/创建 → standard workflow
  - design/architect/plan/设计/架构/规划 → think mode
  
  **AGENTS** (call directly with @):
  - `@oracle` → Strategic reasoning, debugging, architecture decisions
  - `@librarian` → Documentation lookup, codebase research
  - `@explore-fast` → Quick file discovery, pattern matching
  - `@frontend-engineer` → UI/UX implementation
  
  **LOOP COMMANDS**:
  - `/ai:loop <task>` → Self-referential loop until <promise>DONE</promise>
  - `/ai:auto` → Auto-complete remaining tasks
  - `/ai:cancel-loop` → Cancel running loop
  
  Example: "ai implement user login" → triggers full workflow
  Example: "dev fix the auth bug" → quick mode (auto-detected)
  Example: "ai ulw 重构整个模块" → ultrawork mode with parallel agents
  Example: "@oracle review this architecture" → direct agent call
  
  For quick tasks, use /research for competitor insights or /ai:status for progress.
version: 3.2.0
---

# AI-Dev v3.2

> Industrial-grade AI development orchestration with 7-phase gated workflow, parallel Task subagents, and integrated learning system.

## Quick Start

```bash
ai implement user authentication   # Full 7-phase workflow
dev fix login button bug           # Quick mode (auto-detected)
ai ulw 重构整个模块                 # Ultrawork mode with parallel agents
ai quick update readme             # Quick mode (explicit)
ai think design new architecture   # Extended thinking mode
ai 好好思考 设计架构                # Ultra-think mode (中文)
/ai:loop "Build REST API"          # Self-referential loop
/ai:auto                           # Auto-complete remaining tasks
/research "payment integration"    # Competitor research only
/ai:status                         # Check current progress
```

### Direct Agent Calls

```bash
@oracle review this architecture design
@librarian find how authentication is implemented
@explore-fast find all API endpoints
@frontend-engineer create a login form component
```

---

## Execution Modes

### Standard Mode (Default)

Full 7-phase workflow with user approval gates.

### Quick Mode (`quick` / `快速`)

Skip phases 0.5, 1, 2. Direct to implementation.

**Auto-triggered by**: fix, update, patch, 修复, 修改

### Ultrawork Mode (`ulw` / `全力`)

Maximum parallelism with background agents:

```
Phase 0 (Parallel):
├── @explore-fast (background): Scan project structure
├── @librarian (background): Query knowledge base  
└── @oracle (background): Analyze complexity

Wait for all → Merge results → Continue workflow
```

### Think Mode (`think` / `深度`)

Extended reasoning with higher token budget.

**Auto-triggered by**: design, architect, plan, 设计, 架构

### Ultra-Think Mode (`ultrathink` / `好好思考`)

Maximum thinking budget for complex decisions:

**Keywords**: ultrathink, 好好思考, 深思熟虑

**Behavior**:
- Maximum thinking budget
- Consider multiple approaches
- Weigh pros and cons thoroughly
- Don't rush to conclusions

---

## Core Workflow

### Phase Overview

| Phase | Name | Gate | Key Action |
|-------|------|------|------------|
| 0 | Context & Knowledge | Auto | Load project context, query knowledge, detect issues |
| 0.5 | Research | Auto/Skip | Competitor research (new features only) |
| 1 | Requirement Interview | User Approval | Multi-round interview, generate proposal.md |
| 2 | Design Approval | User Approval | Present approaches, user selects, generate design.md |
| 3 | Task Breakdown | Auto | Generate tasks.md with subtasks |
| 4 | Implementation | OODA Loop | Autonomous execution until <promise>DONE</promise> |
| 5 | Quality Validation | Auto | confidence-scorer ≥80 filter, verification-agent |
| 6 | Finalization | User Approval | Archive to knowledge, commit |

### Phase 0: Context & Knowledge Pre-Check

**Automatic actions:**
1. Load `codebox/project-snapshot.json` (incremental via git diff)
2. Query `codebox/knowledge/` for patterns and errors
3. Detect issues:
   - 🔴 **Blocking**: Duplicate feature, severe conflict → must resolve
   - 🟡 **Warning**: Similar feature, minor deviation → user chooses
   - 🟢 **Info**: Related patterns → include in suggestions

**Script**: `scripts/scan-project.sh`, `scripts/query-knowledge.sh`

### Phase 0.5: Competitor Research

**Trigger**: New feature keywords (`implement`, `build`, `create`)
**Skip**: Simple tasks (`fix`, `update`, `refactor`)

**Actions:**
1. `~/.claude/common/lib/codeagent-wrapper.sh --backend gemini` → web search best practices
2. `~/.claude/common/lib/codeagent-wrapper.sh --backend codex` → analyze open-source implementations
3. `~/.claude/common/lib/codeagent-wrapper.sh --backend claude` → code review
4. Save to `codebox/research/[feature]-research.json`

**Skill**: See `competitor-research/SKILL.md`

### Phase 1: Requirement Interview

**Agent**: `requirement-interviewer`

**Process:**
1. Load context (project, research, knowledge)
2. Multi-round interview (2-6 questions based on complexity)
3. Each question includes:
   - Research references
   - Project context
   - Historical patterns
4. Detect and warn about risks
5. Generate `proposal.md`

**User Approval Required**: Confirm requirements before Phase 2

### Phase 2: Design Approval

**Process:**
1. Present 2-3 design approaches
2. Reference global constraints (`codebox/design.md`, `codebox/CLAUDE.md`)
3. User selects approach
4. Generate `design.md`

**User Approval Required**: Confirm design before Phase 3

### Phase 3: Task Breakdown

**Auto-generate** `tasks.md`:
- Subtasks with checkboxes
- Success criteria
- Test requirements

### Phase 4: OODA Implementation

**Autonomous loop** via `hooks/ooda-stop-hook.sh`:
1. Execute tasks from `tasks.md`
2. Update checkboxes as completed
3. Continue until all done
4. Output `<promise>DONE</promise>` to exit loop

**Controls:**
- Max iterations: 50 (configurable)
- State tracking: `codebox/changes/active/[id]/state.json`

### Phase 5: Quality Validation

**Agents:**
- `code-reviewer` → find issues
- `confidence-scorer` → filter ≥80 confidence only
- `verification-agent` → run tests, build, lint

**Auto-gate**: Blocks if critical issues unresolved

### Phase 6: Finalization

**Actions:**
1. Update `codebox/knowledge/` with new patterns
2. Archive change to `codebox/changes/archived/`
3. Commit with structured message

**User Approval Required**: Final confirmation

---

## Project Structure

### codebox/ Directory

```
codebox/                          # Project AI configuration
├── config.json                   # Project config
├── requirements.md               # Global requirements (EARS format)
├── design.md                     # Architecture constraints
├── CLAUDE.md                     # AI behavior rules
├── project-snapshot.json         # Project scan result
├── feature_list.json             # Feature tracking
│
├── knowledge/                    # Knowledge base
│   ├── patterns.json             # Success patterns
│   ├── errors.json               # Historical errors
│   └── learnings.md              # Insights
│
├── research/                     # Competitor research
│   └── [feature]-research.json
│
└── changes/                      # Change management
    ├── active/[id]/              # Current change
    │   ├── proposal.md
    │   ├── design.md
    │   ├── tasks.md
    │   ├── phase0-context.md
    │   └── state.json
    └── archived/YYYY-MM/         # Completed changes
```

---

## Commands

See `commands/README.md` for full documentation.

### Core Commands

| Command | Description |
|---------|-------------|
| `/ai:dev <feature>` | Full 7-phase development workflow |
| `/dev <feature>` | Alias for `/ai:dev` |
| `/fix <bug>` | Quick bug fix (auto-selects quick/deep strategy) |
| `/research <topic>` | Multi-model competitor research |
| `/progress` | Show project progress and status |

### Loop Commands (v3.2.0)

| Command | Description |
|---------|-------------|
| `/ai:loop <task>` | Self-referential loop until `<promise>DONE</promise>` |
| `/ai:auto` | Auto-complete remaining tasks in active change |
| `/ai:cancel-loop` | Cancel running loop |

### Learning Commands

| Command | Description |
|---------|-------------|
| `/reflect` | Trigger learning reflection |
| `/view-queue` | View pending reflection queue |
| `/skip-reflect` | Skip current reflection |

### Feature Management

| Command | Description |
|---------|-------------|
| `/feature-list` | List all features |
| `/feature-show <id>` | Show feature details |
| `/feature-resume [id]` | Resume/continue feature |
| `/feature-archive <id>` | Archive completed feature |

---

## Agents

### Specialist Agents (Direct Call with @)

| Agent | Model | Purpose |
|-------|-------|---------|
| `@oracle` | GPT 5.2 | Strategic reasoning, debugging, architecture decisions |
| `@librarian` | Sonnet 4.5 | Documentation lookup, codebase research, pattern discovery |
| `@explore-fast` | Gemini Flash | Quick file discovery, pattern matching (30s timeout) |
| `@frontend-engineer` | Gemini Pro | UI/UX design and implementation |

**Background Execution**: All specialist agents support `run_in_background: true` for parallel execution.

### Workflow Agents

| Agent | Phase | Purpose |
|-------|-------|---------|
| `requirement-interviewer` | 1 | Multi-round interview with parallel context collection |
| `research-coordinator` | 0.5 | Multi-source parallel research (Task subagents) |
| `code-explorer` | 2 | Deep multi-perspective codebase exploration |
| `code-architect` | 3 | Design approaches |
| `task-decomposer` | 3 | Task breakdown |
| `verification-agent` | 4-5 | Run tests, build, lint |
| `code-reviewer` | 5 | Find code issues |
| `confidence-scorer` | 5 | Filter issues ≥80 |
| `learning-coordinator` | 6-7 | Knowledge capture and reflection |
| `quick-fixer` | Quick Fix | Fast bug fixes (<30min) |
| `debugger` | Debug | Deep debugging |
| `api-helper` | Any | API integration help |
| `test-automator` | 5 | Test automation |

See `agents/` directory for detailed documentation.

---

## Hooks & Scripts

### Hooks

| Hook | Type | Purpose |
|------|------|---------|
| `ooda-stop-hook.sh` | Stop | OODA loop control in Phase 4 |
| `todo-continuation.sh` | Stop | Block exit when unchecked tasks remain |
| `keyword-detector.sh` | UserPromptSubmit | Detect ulw/think/quick keywords (v3.2.0) |
| `context-window-monitor.sh` | PostToolUse | Warn at 85% context usage (v3.2.0) |
| `comment-checker.sh` | PostToolUse | Warn about redundant comments |
| `pre-change-check` | PreToolUse | Knowledge query before changes |
| `learning-capture` | UserPromptSubmit | Capture user corrections |
| `post-phase-learning` | PostToolUse | Trigger learning after Phase 6-7 |

### Scripts

| Script | Purpose |
|--------|---------|
| `scan-project.sh` | Deep/incremental project scanning |
| `query-knowledge.sh` | Query patterns and errors |
| `init-change.sh` | Initialize new change directory |
| `archive-change.sh` | Archive completed change |
| `check-dependencies.sh` | Verify external dependencies |

---

## Configuration

### hooks/hooks.json

```json
{
  "hooks": [
    {
      "id": "ooda-stop-hook",
      "type": "Stop",
      "script": "hooks/ooda-stop-hook.sh",
      "conditions": {
        "currentPhase": 4,
        "oodaEnabled": true
      }
    }
  ],
  "config": {
    "completionPromise": "DONE",
    "maxIterations": 50
  }
}
```

---

## References

For detailed documentation:
- 7-Phase Workflow: `references/7-phase-workflow.md`
- State Machine Spec: `references/state-machine-spec.md`
- Confidence Scoring: `references/confidence-scoring.md`

---

## Dependencies

- `competitor-research` skill for Phase 0.5
- `project-initializer` skill for codebox setup
- `session-manager` skill for cross-session continuity
- `claude-reflect` skill for learning capture and /reflect command
- `~/.claude/common/lib/codeagent-wrapper.sh` for multi-backend execution (gemini/codex/claude)

---

## References

| Document | Description |
|----------|-------------|
| `references/7-phase-workflow.md` | Detailed phase documentation |
| `references/ooda-loop.md` | OODA autonomous completion |
| `references/multi-agent-patterns.md` | Multi-agent architecture patterns |
| `references/memory-systems.md` | Knowledge base design |
| `references/context-compression.md` | Context optimization strategies |
| `references/confidence-scoring.md` | Quality filtering |
| `references/state-machine-spec.md` | State management |
