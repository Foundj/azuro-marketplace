---
name: multi-agent-discussion
description: |
  This skill should be used when the user asks to "start a discussion", "multi-agent discuss",
  "cross-tool collaboration", "invite agents to discuss", "需求讨论", "多工具协作",
  "跨工具讨论", "邀请讨论", "生成邀请提示词", "检查讨论进度", "汇总讨论结果",
  or wants to coordinate multiple AI tools (Codex, Cursor, Claude Code) for collaborative
  requirement analysis and decision making. It provides a structured multi-agent discussion
  framework with shared markdown workspace, invitation prompts, and automated summarization.
version: 5.1.8
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

Create a discussion space in a target project's `docs/discussions/` directory. Each AI tool plays a specialized expert role, contributing structured opinions in a shared `discussion.md`. Claude Code acts as the coordinator — initializing, monitoring progress, and producing final `plan.md` + `task.md` deliverables.

## Four-Phase Workflow

### Phase 1: Init

Parse `$ARGUMENTS` for topic and options. Then:

1. Ask user for: topic name, participating tools, role assignments, project context
2. Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-discussion.sh <project-root> <topic>` to scaffold the directory
3. Read `references/role-catalog.md` to select roles matching user's needs
4. Read `references/invitation-templates.md` and generate tool-specific invitation prompts
5. Print each invitation prompt to terminal with clear copy instructions
6. Generate `continue/` directory with pre-built continuation prompts for Rounds 2-3

**Directory created:**
```
docs/discussions/<topic>/
├── README.md          # Rules, roles, syntax reference
├── discussion.md      # Main discussion file with STATUS panel
├── context.md         # Project background (user fills)
├── refs/              # Attachments (code, designs)
└── continue/          # Pre-generated continuation prompts
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
- Early exit: when all agents select the same option with `#consensus` tag
- Timeout: Claude Code intervenes after exceeding max rounds

**Progress check** — when user says "检查讨论进度" or "check progress":
1. Read the `<!-- STATUS -->` panel from `discussion.md`
2. Report: current round, pending agents, unresolved `@` mentions
3. Generate next continuation prompts if needed

### Phase 3: Draft

Any agent proposes a draft using `[Draft vN]` format. Others review with `[Draft vN Review]` entries. Iterate until `#consensus` status is reached on the final draft.

### Phase 4: Summarize

When user triggers summarization:

1. Read entire `discussion.md`
2. Extract all `#consensus` decisions and `> [!decision]` callouts
3. Read `references/output-format.md` for template structure
4. Generate `plan.md` — Fabula v5.x format with:
   - Frontmatter, context, success criteria, phased approach, architecture decisions, confidence analysis
5. Generate `task.md` — Fabula v5.x format with:
   - Status header, phase-grouped checkbox tasks, review gates, change log

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

## Best Practices

**DO:**
- Generate self-contained invitation prompts (each includes all rules needed)
- Pre-generate continuation prompts in `continue/` to minimize user friction
- Use STATUS panel for machine-readable progress tracking
- Respect convergence limits

**DON'T:**
- Delete or modify other agents' entries
- Skip reading prior discussion entries
- Exceed configured max rounds without user approval
- Generate plan/task without `#consensus` on at least one draft

## Additional Resources

### Reference Files
- **`references/markdown-conventions.md`** — @ mentions, callouts, tags, quoting syntax
- **`references/role-catalog.md`** — Predefined expert roles and custom role guide
- **`references/output-format.md`** — plan.md and task.md templates (Fabula v5.x)
- **`references/invitation-templates.md`** — Tool-specific invitation prompt templates

### Scripts
- **`scripts/init-discussion.sh`** — Initialize discussion directory structure
