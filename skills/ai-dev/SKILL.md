---
name: ai-dev
description: |
  Industrial-grade AI development orchestration with 7-phase gated workflow.
  Features requirement interviewing, competitor research, OODA autonomous implementation,
  knowledge management, Worker Session context scaling, and attention management.
version: 4.2.1
---

# AI-Dev v4.2 (Evolution Edition)

> The next generation of autonomous development agents. Featuring **Evaluation-Driven Development (EDD)**, **Worker Sessions**, **Reflexion System**, and **Attention Management**.

## New in v4.2

### Smart Empty Command Detection

当 `/ai:dev` 或 `/ai:auto` 不带参数时，自动检测并继续现有任务：

```bash
/ai:dev                # 无参数 → 检测现有任务
/ai:auto               # 无参数 → 继续未完成任务
```

**检测逻辑**：

```
用户输入: "/ai:dev" (无参数)
  ↓
检测 codebox/changes/active/ 是否有未完成的 change
  ↓
├─ 有 active change →
│   ━━━━━━━━━━━━━━━━━━━━━━━━━
│   📍 Found Active Change
│   ━━━━━━━━━━━━━━━━━━━━━━━━━
│   Change: 001-user-auth
│   Phase: 4 (Implementation)
│   Tasks: 5/7 completed
│
│   Options:
│   1. Continue this change (y)
│   2. Start new change (n)
│   3. Show details (/ai:status)
│   ━━━━━━━━━━━━━━━━━━━━━━━━━
│
└─ 无 active change → 检测 codebox/context/tasks.md (Lite Mode)
    ↓
    ├─ 有 tasks.md → 询问是否升级到 Full Mode
    └─ 无任务 → 提示 "Usage: /ai:dev <feature>"
```

**`/ai:auto` 空命令行为**：

```
用户输入: "/ai:auto" (无参数)
  ↓
检测 codebox/changes/active/*/tasks.md
  ↓
├─ 有未完成任务 → 自动继续执行
├─ 全部完成 →
│   ━━━━━━━━━━━━━━━━━━━━━━━━━
│   ✅ All Tasks Completed!
│   ━━━━━━━━━━━━━━━━━━━━━━━━━
│   Run /session:save or /feature-archive
│   ━━━━━━━━━━━━━━━━━━━━━━━━━
└─ 无任务 → 提示 "No pending tasks. Start with: /ai:dev <feature>"
```

### Enhanced Context Bridge Integration (v4.2)

增强与 context-bridge 的集成：

- **Auto Checkpoint (90%)**: 当 context 达到 90% 时自动保存
- **Lite Mode 统一**: 共享 `codebox/context/` 目录
- **任务完成检测**: 所有任务完成时自动提示保存/归档

---

## New in v4.1

### Attention Management (Read Before Decide)

Integrates Manus-style "Read Before Decide" pattern to prevent goal drift during long OODA loops.

**Key Changes:**
- **OODA Attention Management**: Each iteration starts by reading `tasks.md` to refresh goals
- **Periodic Focus Refresh**: Every 5 iterations, run `/focus` to refresh attention window
- **Context Bridge Integration**: Works with `/focus`, `/progress`, `/session:save` commands
- **Lost in the Middle Prevention**: Goals stay in attention window even after 50+ tool calls

**New Dependencies:**
- `context-bridge` skill (optional but recommended)

---

## New in v4.0

### 1. Hard Gates (Verification Enforcement)
The OODA Loop now enforces quality through automated verification.
- **`verify_with`**: Tasks in `tasks.md` can specify a shell command for verification.
- **Blocking Mechanism**: Claude cannot output `<promise>DONE</promise>` until the verification command passes.
- **Escape Hatch**: Use `verify_with: true` to skip verification for impossible-to-test tasks.

### 2. Reflexion System (Self-Improving Memory)
A persistent knowledge base of errors and their solutions.
- **Automatic Logging**: Every verification failure is analyzed and logged to `solutions_learned.jsonl`.
- **Intelligent Querying**: Before starting a task, the agent queries previous solutions to avoid repeating mistakes.

### 3. Worker Sessions (Manager-Worker Model)
Scales horizontally to handle complex features without context overflow.
- **Context Awareness**: Spawns a dedicated sub-agent when context reaches **80%**.
- **Handover Protocol**: Semantic context transfer via `handover.md`.
- **Safety**: Strict **Max Depth = 2** to prevent infinite agent recursion.

---

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
| 5 | Quality Validation | Auto | Multi-perspective review, confidence-scorer ≥80 filter |
| 5.5 | Code Simplification | Auto/Skip | Polish code (if autoSimplify enabled) |
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

#### OODA 注意力管理 (v4.1.0)

> **Read Before Decide** — 每次迭代开始时刷新目标

**每次 OODA 迭代必须**：

1. **OBSERVE 阶段开始时**：
   ```
   Read tasks.md              # 刷新任务列表到注意力窗口
   Read state.json            # 获取当前进度
   ```

2. **重大决策前**：
   ```
   Read design.md             # 参考架构约束
   Read requirements.md       # 确认符合全局需求
   ```

3. **每 5 次迭代后**：
   ```
   运行 /focus                # 强制刷新目标
   ```

**原因**：在长时间 OODA 循环中（50+ iterations），原始目标可能被 "遗忘"（Lost in the Middle 问题）。
通过周期性读取目标文件，将目标重新注入注意力窗口末端，保持决策质量。

**与 context-bridge 集成**：
- 如果 `codebox/context/current_focus.md` 存在，每次迭代也读取它
- 上下文超过 70% 时，建议运行 `/session:save` 保存进度

### Phase 5: Quality Validation

**Skill**: `ai-dev-quality`

**Agents:**
- `code-reviewer` → find issues (3 perspectives: security, bugs, maintainability)
- `confidence-scorer` → filter ≥80 confidence only
- `verification-agent` → run tests, build, lint

**Auto-gate**: Blocks if critical issues unresolved

### Phase 5.5: Code Simplification (Optional)

**Skill**: `code-simplifier`

When quality gate passes and `autoSimplify: true` in config:
1. Identify recently modified code
2. Apply project standards from CLAUDE.md
3. Reduce complexity while preserving functionality
4. Verify behavior unchanged

**Trigger**: Automatic after Phase 5 pass, or manual via `/ai:simplify`

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

## Integrated Skills

ai-dev 工作流集成以下辅助 Skills：

| Skill | Phase | 作用 |
|-------|-------|------|
| `brainstorm-mode` | -1 (Optional) | 苏格拉底式需求探索，从模糊想法发现清晰需求 |
| `ai-dev-interview` | 1 (Interview) | 多轮需求访谈，并行上下文收集，风险检测，生成 proposal.md |
| `ai-dev-ooda` | 4 (Implementation) | OODA 自主执行引擎，验证门禁，Reflexion 学习，注意力管理 |
| `ai-dev-quality` | 5 (Review) | 多视角代码审查，confidence-scorer ≥80 过滤，4 维度质量评分 |
| `code-simplifier` | 5.5 (Polish) | 代码简化和优化，SOLID 原则检查，复杂度度量 |
| `thinking-engine` | 0 (Pre-check) | think/ultrathink 模式的结构化思考支持，5-6 步分析流程 |
| `knowledge-graph` | 0, 4, 6 | 跨项目知识图谱，查询历史方案，记录新知识 |
| `competitor-research` | 0.5 (Research) | 多源竞品研究，最佳实践分析 |
| `context-bridge` | Cross-session | 轻量级上下文恢复，Auto Checkpoint，Manus 3-file 模式 |
| `session-manager` | Cross-session | 完整项目恢复，10 步验证流程，环境启动 |

### Quality Validation 集成 (ai-dev-quality)

Phase 5 自动执行：
```
[ai-dev] Phase 5: Quality Validation
├── 3x code-reviewer (security, bugs, maintainability)
├── confidence-scorer (filter ≥80)
├── verification-agent (tests, build, lint)
└── 4-dimension scoring (Security 40%, Code 30%, Docs 20%, Arch 10%)
```

### Code Simplification 集成 (code-simplifier)

Phase 5 通过后，如果 `autoSimplify: true`：
```
[ai-dev] Phase 5.5: Code Simplification
├── Identify recently modified code
├── Apply CLAUDE.md standards
├── Reduce complexity
└── Verify behavior unchanged
```

手动执行：`/ai:simplify` 或提示 "简化代码"

### Thinking Engine 集成

think 模式触发时自动激活：
```
[Thinking Engine] Task Analysis Mode
├── Step 1: 理解任务
├── Step 2: 分析上下文
├── Step 3: 评估复杂度
├── Step 4: 选择策略
└── Step 5: 验证方案
```

### Knowledge Graph 集成

- **Phase 0**: 查询相关知识和历史方案
- **Phase 4**: 参考类似项目的实现
- **Phase 6**: 记录新知识到图谱

手动查询：`/ai:knowledge [关键词]`

---

## Dependencies

### Core Skills (Modular Architecture v4.1+)
- `ai-dev-interview` - Phase 1 requirement interview system
- `ai-dev-ooda` - Phase 4 OODA autonomous execution engine
- `ai-dev-quality` - Phase 5 quality validation (replaces legacy `quality-gate`)
- `code-simplifier` - Phase 5.5 code refinement

### Supporting Skills
- `competitor-research` - Phase 0.5 multi-source research
- `thinking-engine` - Structured thinking for complex decisions
- `knowledge-graph` - Cross-project knowledge management
- `context-bridge` - Cross-session context persistence
- `claude-reflect` - Learning capture and /reflect command

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
