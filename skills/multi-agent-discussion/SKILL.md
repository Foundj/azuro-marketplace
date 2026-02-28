---
name: multi-agent-discussion
description: |
  This skill should be used when the user asks to "start a discussion", "multi-agent discuss",
  "cross-tool collaboration", "invite agents to discuss", "需求讨论", "多工具协作",
  "跨工具讨论", "邀请讨论", "生成邀请提示词", "检查讨论进度", "汇总讨论结果",
  or wants to coordinate multiple AI tools (Codex, Cursor, Claude Code) for collaborative
  requirement analysis and decision making. It provides a structured multi-agent discussion
  framework with shared markdown workspace, invitation prompts, and automated summarization.
version: 5.3.2
status: ga
triggers:
  - start a discussion
  - multi-agent discuss
  - cross-tool collaboration
  - invite agents to discuss
  - 需求讨论
  - 多工具协作
  - 跨工具讨论
  - 邀请讨论
  - 生成邀请提示词
  - 检查讨论进度
  - 汇总讨论结果
  - summarize discussion
  - check discussion progress
---

# Multi-Agent Discussion

Coordinate requirement discussions across AI coding tools (Claude Code, Cursor, Codex) via shared markdown workspace.

## Overview

Create a discussion space in a target project's `docs/discussions/` directory. Each AI tool plays a specialized expert role, contributing structured opinions in a shared `discussion.md`. **Claude Code acts as both coordinator AND active participant** — it seeds the discussion with project analysis, monitors progress, generates continuation prompts, and produces final `plan.md` + `task.md`.

## Core Principles

1. **Claude Code 主动参与**：不仅调度，还以 @Coordinator 身份提供项目数据种子（代码统计、架构分析），降低其他 agent 的信息搜索成本
2. **邀请即文件**：所有邀请和续接提示词写入文件（`invite-*.md`, `continue/*.md`），不打印到终端
3. **续接带上下文**：每个续接文件包含上一轮的待回应 @ 提及摘要和下一步指引
4. **收敛优先**：达成共识后可跳过 Draft 直接 Summarize

## Four-Phase Workflow

### Phase 1: Init

#### Entry Modes

At session start, offer three entry modes per interaction-protocol:

```
How would you like to set up this discussion?
1. Guided — I'll ask about topic, tools, and roles step by step
2. Context dump — Paste your topic and role preferences, I'll scaffold
3. Quick mode — I'll auto-select roles based on the topic
```

If the user ignores this and names a topic directly, default to **Guided**.

#### Setup Steps

Parse `$ARGUMENTS` for topic and options. Show progress labels:

```
[Init Q1/3] What topic should the discussion focus on?
[Init Q2/3] Which AI tools will participate? (e.g., Claude Code, Cursor, Codex)
[Init Q3/3] Role assignment — here are recommended roles:
  1. @Architect — system design focus
  2. @Security — threat modeling
  3. @PM — user impact analysis
  Which roles? (numbers, or describe custom roles)
```

Then:

1. ~~Ask user for: topic name, participating tools, role assignments~~ (handled by Entry Modes above)
2. Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-discussion.sh <project-root> <topic>` to scaffold the directory
3. **Auto-populate `context.md`**：使用 Glob/Grep/Read 分析目标项目，自动填充技术栈、架构概览、关键数据指标（文件数、组件数、依赖关系等）
4. Read `references/role-catalog.md` to select roles matching user's needs
5. Update generated `README.md` with role table, update STATUS panel with role list
6. **Seed Round 0**：以 @Coordinator 身份在 `discussion.md` 中追加项目分析种子发言——包含具体数据（不是通用描述），为后续 agent 的讨论提供事实基础
7. Read `references/invitation-templates.md` and write `invite-<role>-<tool>.md` files, **注入 context.md 中的具体数据和 Round 0 的关键发现**
8. Write role-specific `continue/round-1-<role>-<tool>.md` files（Round 1 的续接，因为 Round 0 由 Claude Code 完成）
9. Print usage guide: file paths + copy-to-which-tool instructions

**Directory created:**
```
docs/discussions/<topic>/
├── README.md                    # Rules, roles, syntax reference
├── discussion.md                # Main file (STATUS panel + Round 0 seed + discussion)
├── context.md                   # Auto-populated project background
├── invite-<role>-<tool>.md      # Self-contained invitation per role+tool
├── refs/                        # Attachments (code, designs)
└── continue/                    # Continuation prompts
    ├── round-N-<role>-<tool>.md # Role-specific, includes pending @ mentions
    ├── draft.md
    └── review.md
```

### Phase 2: Discuss

Each invited agent reads `README.md`, then appends to `discussion.md` following the format in `references/markdown-conventions.md`.

**Key rules:**
- Read ALL prior entries before responding
- Use `@Role` mentions for directed communication
- Use callouts (`> [!analysis]`, `> [!proposal]`, etc.) for structured content
- Update the `<!-- STATUS -->` panel after each entry
- Follow deep-contribution principle: address current topic AND preemptively respond to anticipated concerns from other roles

**Convergence rules:**
- Default: 3 discussion rounds + 1 draft round + 1 review round
- **Fast path**: when all agents select the same option with `#consensus` tag, can skip Draft and go directly to Summarize
- Timeout: Claude Code intervenes after exceeding max rounds

**Progress check** — when user says "检查讨论进度" or "check progress":

Show progress label `[Round N/Max]`, then:
1. **Deep scan** `discussion.md`：不仅读 STATUS 面板，还扫描实际文本中的 `@` 提及和 `#consensus`/`#pending` 标签
2. If STATUS panel and actual content are inconsistent, **repair** the STATUS panel
3. Report: current round, pending agents, unresolved `@` mentions, consensus status
4. Generate next continuation prompts if needed

**Advancing rounds** — when user says "next" or "推进下一轮":
1. Verify current round is complete (deep scan, not just STATUS)
2. Update STATUS panel: increment round, reset pending
3. **Dynamically generate** role-specific continuation files with:
   - Unresolved `@` mentions targeting that role (with quoted context)
   - Summary of current consensus/disagreement points
   - "Next step" footer pointing to the next role's file
4. Print instructions

### Phase 3: Draft (Optional)

When discussion has converged but details need refinement. Skip if `#consensus` is already clear and comprehensive.

Any agent proposes a draft using `[Draft vN]` format. Others review with `[Draft vN Review]` entries.

### Phase 4: Summarize

When user triggers summarization (or when fast-path convergence allows skipping Draft):

1. Read entire `discussion.md`
2. **Deep extract**: scan all `#consensus`, `#pending`, `#rejected` tags AND all `> [!decision]`, `> [!proposal]` callouts
3. Read `references/output-format.md` for template structure
4. Generate `plan.md` — Fabula v5.x format with:
   - Frontmatter, context, success criteria, phased approach, architecture decisions, confidence analysis
   - **Unresolved items**: all `#pending` and `#needs-input` items listed explicitly
5. Generate `task.md` — Fabula v5.x format with:
   - Status header, phase-grouped checkbox tasks, review gates, change log
   - **Rollback point references**: each Phase links to corresponding RP in plan.md
6. Update STATUS panel: set `phase: done`

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
max_rounds: 3
-->
```

**Validation rule**: when checking progress, compare STATUS panel against actual discussion content. If an agent has posted a `[Round N]` entry but STATUS still lists them as pending, auto-repair the panel.

### Interaction Protocol
Use [`interaction-protocol`](../interaction-protocol/SKILL.md) as the default interaction behavior.
It defines entry modes, progress labels, decision-point recommendations, and interruption handling.
This file defines the domain-specific content. If conflict, follow this file's domain logic.

## Best Practices

**DO:**
- Auto-populate context.md with project-specific data (not generic placeholders)
- Seed Round 0 with concrete project analysis as @Coordinator
- Inject specific data into invitation prompts (not just generic role descriptions)
- Generate continuation files dynamically with pending @ mention context
- Deep-scan discussion content when checking progress (don't trust STATUS alone)
- Support fast-path: discuss → summarize when consensus is clear
- Preserve neutral stance in summarization — report disagreements as-is

**DON'T:**
- Print invitation prompts to terminal (always write to files)
- Generate generic continuation files without role-specific context
- Leave context.md empty for user to fill manually
- Force Draft phase when consensus is already comprehensive
- Delete or modify other agents' entries
- Exceed configured max rounds without user approval

## Additional Resources

### Reference Files
- **`references/markdown-conventions.md`** — @ mentions, callouts, tags, quoting syntax
- **`references/role-catalog.md`** — Predefined expert roles and custom role guide
- **`references/output-format.md`** — plan.md and task.md templates (Fabula v5.x)
- **`references/invitation-templates.md`** — Tool-specific invitation prompt templates

### Scripts
- **`scripts/init-discussion.sh`** — Initialize discussion directory structure
