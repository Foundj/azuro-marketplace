---
name: multi-agent-discussion
description: |
  This skill should be used when the user asks to "start a discussion", "multi-agent discuss",
  "cross-tool collaboration", "invite agents to discuss", "需求讨论", "多工具协作",
  "跨工具讨论", "邀请讨论", "自动讨论", "auto discuss", "生成邀请提示词",
  "检查讨论进度", "汇总讨论结果", or wants to coordinate multiple AI tools
  (Codex, Cursor, OpenCode, Gemini, Claude variants) for collaborative
  requirement analysis and decision making. It provides a structured multi-agent discussion
  framework with automated CLI orchestration, shared markdown workspace, and convergence evaluation.
version: 6.0.8
status: ga
profile: design
triggers:
  - start a discussion
  - multi-agent discuss
  - cross-tool collaboration
  - invite agents to discuss
  - auto discuss
  - 需求讨论
  - 多工具协作
  - 跨工具讨论
  - 自动讨论
  - 邀请讨论
  - 生成邀请提示词
  - 检查讨论进度
  - 汇总讨论结果
  - summarize discussion
  - check discussion progress
---

# Multi-Agent Discussion

Coordinate requirement discussions across AI coding tools via **automated CLI orchestration** or manual invitation files.

## Overview

Create a discussion space in a target project's `docs/discussions/` directory. Claude Code acts as the **Orchestrator**, automatically invoking external AI tools (Codex, OpenCode, Gemini, Claude variants) via their non-interactive CLI modes. All agents share a `discussion.md` blackboard. When CLI tools are unavailable, gracefully degrades to manual invitation file mode.

## Architecture: Orchestrator-Driven Blackboard

```
┌──────────────────────────────────────────────────────────┐
│  Claude Code (Orchestrator + @Coordinator)               │
│                                                          │
│  1. init → 创建目录 + 分析项目 + 种子发言                │
│  2. detect-cli-tools.sh → 检测可用工具                   │
│  3. 循环编排每轮讨论：                                   │
│     ┌────────────────────────────────────────┐           │
│     │  for each role:                        │           │
│     │    构建 prompt (角色+上下文+黑板)       │           │
│     │    invoke-agent.sh $tool $prompt        │           │
│     │    parse-response.sh → 追加黑板         │           │
│     └────────────────────────────────────────┘           │
│  4. evaluate-convergence.sh → 评估收敛                   │
│  5. 收敛 → summarize → docs/tasks/v<VER>/plan.md + task.md  │
└──────────────────────────────────────────────────────────┘
      │          │          │          │
 ┌────┴───┐ ┌───┴────┐ ┌───┴────┐ ┌───┴──────────┐
 │ codex  │ │opencode│ │ gemini │ │ claude*      │
 │ exec   │ │ run    │ │ -p     │ │ -a/-c/-g -p  │
 └────────┘ └────────┘ └────────┘ └──────────────┘
```

**Key decisions:**
- **轮内顺序执行**：每个 agent 能看到同轮前序 agent 的发言
- **黑板 = discussion.md**：所有 agent 读写同一个文件
- **降级回退**：CLI 调用失败时，自动回退到手动邀请文件模式
- **7 种工具后端**：codex, opencode, gemini, claude, claudea, claudec, claudeg

## Core Principles

1. **自动化优先**：检测可用 CLI 工具，自动编排讨论，用户零手动操作
2. **Claude Code 主动参与**：不仅调度，还以 @Coordinator 身份提供项目数据种子
3. **降级兼容**：无 CLI 工具时自动切换手动邀请文件模式
4. **反共识偏见**：@Critic 角色强制反对，问题框架优先于方案设计
5. **收敛驱动**：自动评估收敛指标，达成共识后可跳过 Draft 直接 Summarize

## Discussion Presets

| 预设 | 角色组合 | 适用场景 |
|------|----------|----------|
| `product-discovery` | @PM + @UserAdvocate + @Architect + @Critic | 需求分析、功能规划 |
| `architecture-design` | @Architect + @Backend + @Security + @Critic | 技术选型、架构评审 |
| `full-review` | @PM + @Architect + @Frontend + @Backend + @QA | 全栈功能开发 |
| `security-audit` | @Architect + @Security + @Backend + @DevOps | 安全审计 |
| `custom` | 用户自定义 | 灵活组合 |

详见 `references/discussion-presets.md`。

## Five-Phase Workflow

### Phase 1: Init

#### Entry Modes

At session start, offer three entry modes per interaction-protocol:

```
How would you like to set up this discussion?
1. Guided — I'll ask about topic, tools, and roles step by step
2. Context dump — Paste your topic and role preferences, I'll scaffold
3. Quick mode — I'll auto-select roles based on the topic (uses --preset)
```

If the user ignores this and names a topic directly, default to **Guided**.

#### Setup Steps

Parse `$ARGUMENTS` for topic and options. Show progress labels:

```
[Init Q1/3] What topic should the discussion focus on?
[Init Q2/3] Select a preset or specify roles:
  1. product-discovery (PM + UserAdvocate + Architect + Critic)
  2. architecture-design (Architect + Backend + Security + Critic)
  3. full-review (PM + Architect + Frontend + Backend + QA)
  4. custom — specify roles manually
[Init Q3/3] Auto mode? (yes = CLI automation, no = manual invitation files)
```

Then:

1. Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-discussion.sh <project-root> <topic> [max-rounds] [--preset <preset>]`
2. **Auto-populate `context.md`**：Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/populate-context.sh <project-root> <context-file>` 自动扫描技术栈、目录结构、关键文件，然后用 Glob/Grep/Read 增强分析
3. Read `references/role-catalog.md` to select roles (from preset or user choice)
4. Update generated `README.md` with role table, update STATUS panel
5. **Seed Round 0**：以 @Coordinator 身份在 `discussion.md` 中追加项目分析种子发言
6. **Detect CLI tools**：Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/detect-cli-tools.sh`
7. **Mode selection**：
   - `auto_mode_possible == true` → 自动模式，分配角色到可用工具（优先不同后端以获得多样视角）
   - `auto_mode_possible == false` → 手动模式，生成邀请文件
   - 混合模式：部分工具可用时，可用的自动调用，不可用的生成邀请文件
8. If auto mode: proceed to Phase 2 automatically
9. If manual mode: Generate `invite-<role>-<tool>.md` files and print usage guide

**Directory created:**
```
docs/discussions/<topic>/
├── README.md                    # Rules, roles, syntax reference
├── discussion.md                # Main file (STATUS panel + Round 0 seed + discussion)
├── context.md                   # Auto-populated project background
├── invite-<role>-<tool>.md      # Self-contained invitation per role+tool (manual mode)
├── refs/                        # Attachments (code, designs)
└── continue/                    # Continuation prompts (manual mode)
    ├── round-N-<role>-<tool>.md
    ├── draft.md
    └── review.md
```

### Phase 2: Discuss (Auto or Manual)

#### Auto Mode (CLI Orchestration)

Claude Code automatically orchestrates each discussion round:

1. **构建 prompt**：对每个角色，读取 `references/cli-prompt-templates.md` 模板，注入角色描述、项目上下文、当前 discussion.md 内容、待回应 @ 提及
2. **调用 agent**：`bash ${CLAUDE_PLUGIN_ROOT}/scripts/invoke-agent.sh <tool> <prompt-file> <working-dir>`
3. **解析响应**：`bash ${CLAUDE_PLUGIN_ROOT}/scripts/parse-response.sh <role> <tool> <round>` 解析并格式化
4. **追加黑板**：将格式化后的发言追加到 `discussion.md`
5. **更新 STATUS**：将角色从 pending 移至 completed
6. **顺序执行**：同轮内按角色顺序执行，确保后续角色能看到前序发言
7. **轮结束后评估**：`bash ${CLAUDE_PLUGIN_ROOT}/scripts/evaluate-convergence.sh discussion.md`
8. **自动决策**：
   - `converged == true` → 进入 Phase 4 Summarize（跳过 Draft）
   - `converged == false && round < max_rounds` → 开始下一轮
   - `round >= max_rounds` → 提示用户决定是否继续或进入 Draft/Summarize

#### Manual Mode (Invitation Files)

与旧版工作流相同：

- 用户将 `invite-*.md` 文件内容复制到各工具
- 使用 `/ai:discuss status <topic>` 检查进度
- 使用 `/ai:discuss next <topic>` 推进轮次

#### Hybrid Mode

部分工具可用时：
- 可用工具自动调用
- 不可用工具生成邀请文件并提示用户手动操作
- 手动部分完成后继续自动编排

**Key rules (all modes):**
- Read ALL prior entries before responding
- Use `@Role` mentions for directed communication
- Use callouts for structured content
- Update the `<!-- STATUS -->` panel after each entry
- @Critic 必须包含至少一个反对意见

**Convergence rules:**
- Default: 3 discussion rounds + 1 optional draft round
- **Fast path**: when `evaluate-convergence.sh` reports `converged: true`, skip Draft
- Timeout: Claude Code intervenes after exceeding max rounds

**Progress check** — when user says "检查讨论进度" or "check progress":

Show progress label `[Round N/Max]`, then:
1. **Deep scan** `discussion.md`
2. If auto mode: also show `evaluate-convergence.sh` output
3. Report current state and recommend next action

### Phase 3: Draft (Optional)

When discussion has converged but details need refinement. Skip if `#consensus` is already clear and comprehensive (auto mode will skip automatically based on convergence evaluation).

### Phase 4: Summarize

When convergence is reached (auto) or user triggers manually:

1. Read entire `discussion.md`
2. **Deep extract**: scan all tags, callouts, `#consensus`, `> [!decision]`
3. Read `references/output-format.md` for template structure and output path rules
4. **Determine version**:
   - If user specified `--version`, use it
   - Otherwise, scan target project's `docs/tasks/` for existing `v*` directories
   - Auto-increment: take max version + 0.1 (e.g., v1.2 → v1.3)
   - First time: default to `v1.0`
5. **Create output directory**: `docs/tasks/v<VERSION>/`
6. Generate `plan.md` — multiClaw v6 format:
   - YAML frontmatter with `discussion_source` pointing to this discussion
   - **NO checkboxes** anywhere — plan is WHY/WHAT/HOW only
   - Sprint-based with file change lists
   - Preserve ADR records, confidence analysis, risk table from discussion
   - Acceptance criteria as numbered prose, not checkboxes
7. Generate `task.md` — multiClaw v6 format:
   - Rich YAML frontmatter with sprints, tasks, dependencies, rules
   - Git commit rules: `feat(v<VERSION>/s<N>): description`
   - Mandatory `sN-review` gate after each Sprint
   - Change log table initialized with creation record
   - `discussion_source` cross-reference
8. Update STATUS panel: set `phase: done`
9. Print deliverable summary:
   - `docs/tasks/v<VERSION>/plan.md` — 设计文档
   - `docs/tasks/v<VERSION>/task.md` — 执行看板
   - 来源讨论：`docs/discussions/<topic>/discussion.md`

## STATUS Panel Format

Maintain at the top of `discussion.md`:

```markdown
<!-- STATUS
round: 1
pending: @Architect, @Security
completed: @PM
mentions:
  - target: @Security, from: @PM, round: 1, topic: "认证方案安全评估"
phase: discuss
mode: auto | manual | hybrid
max_rounds: 3
tools:
  codex: available
  gemini: available
  claudea: available
-->
```

**Validation rule**: when checking progress, compare STATUS panel against actual discussion content. Auto-repair if inconsistent.

### Interaction Protocol
Use [`interaction-protocol`](../interaction-protocol/SKILL.md) as the default interaction behavior.

## Best Practices

**DO:**
- Run `detect-cli-tools.sh` at init to determine available backends
- Assign different roles to different tool backends for maximum diversity
- Auto-populate context.md with project-specific data
- Seed Round 0 with concrete project analysis as @Coordinator
- Use `evaluate-convergence.sh` to objectively assess discussion state
- Support graceful degradation: auto → hybrid → manual
- Include @Critic in all non-custom presets for anti-consensus bias

**DON'T:**
- Force auto mode when CLI tools are unavailable
- Assign all roles to the same tool backend (reduces diversity)
- Generate generic continuation files without role-specific context
- Leave context.md empty for user to fill manually
- Force Draft phase when convergence is already clear
- Delete or modify other agents' entries
- Exceed configured max rounds without user approval

## Additional Resources

### Reference Files
- **`references/markdown-conventions.md`** — @ mentions, callouts, tags, quoting syntax
- **`references/role-catalog.md`** — Predefined expert roles, presets, and anti-consensus rules
- **`references/discussion-presets.md`** — Preset role combinations and tool assignment strategies
- **`references/cli-prompt-templates.md`** — CLI prompt templates for automated orchestration
- **`references/output-format.md`** — plan.md and task.md templates (Fabula v5.x)
- **`references/invitation-templates.md`** — Tool-specific invitation prompt templates (manual/hybrid mode)

### Scripts
- **`scripts/detect-cli-tools.sh`** — Detect available CLI tool backends
- **`scripts/invoke-agent.sh`** — Unified agent invocation wrapper
- **`scripts/parse-response.sh`** — Parse agent response into structured format
- **`scripts/evaluate-convergence.sh`** — Evaluate discussion convergence
- **`scripts/orchestrate-round.sh`** — Orchestrate a single discussion round
- **`scripts/init-discussion.sh`** — Initialize discussion directory structure
- **`scripts/populate-context.sh`** — Auto-scan project and populate context.md

### Documentation
- **`docs/cli-non-interactive-modes.md`** — CLI non-interactive mode reference
- **`docs/refactor-plan-cli-orchestration.md`** — Architecture refactoring plan
