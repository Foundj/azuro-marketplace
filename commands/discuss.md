---
name: discuss
description: Multi-agent discussion coordinator — init, invite, check progress, or summarize
argument-hint: "<init|invite|status|draft|summarize> [topic] [--tools cursor,codex] [--roles PM,Architect,Security] [--rounds 3] [--project-root .]"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task
---

# Multi-Agent Discussion Command

Parse `$ARGUMENTS` to determine subcommand.

## Subcommands

### `init <topic>`

Initialize a new discussion space.

1. Parse options:
   - `<topic>`: 讨论主题（必需，kebab-case）
   - `--tools`: 参与工具列表（默认: `cursor,codex`）
   - `--roles`: 角色分配（默认: `PM,Architect,Frontend`）
   - `--rounds`: 最大讨论轮次（默认: `3`）
   - `--project-root`: 目标项目根目录（默认: `.`，当前目录）

2. Invoke skill `multi-agent-discussion` — follow its Phase 1 (Init) workflow:
   - Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-discussion.sh <project-root> <topic> <rounds>`
   - Read `${CLAUDE_PLUGIN_ROOT}/references/role-catalog.md` to get role descriptions
   - Update the generated `README.md` with selected roles
   - Update `discussion.md` STATUS panel with role list in `pending`
   - Read `${CLAUDE_PLUGIN_ROOT}/references/invitation-templates.md`
   - Generate and print invitation prompts for each tool+role combination
   - Generate role-specific continuation prompts in `continue/`

3. Print instructions for the user:
   - Which prompt to copy to which tool
   - How to check progress later (`/discuss status <topic>`)

### `invite <topic>`

Re-generate invitation prompts for an existing discussion.

1. Read `docs/discussions/<topic>/README.md` to get role assignments
2. Read `docs/discussions/<topic>/discussion.md` STATUS panel for current round
3. Read `${CLAUDE_PLUGIN_ROOT}/references/invitation-templates.md`
4. Generate fresh invitation prompts based on current state
5. Print to terminal

### `status <topic>`

Check discussion progress.

1. Read `docs/discussions/<topic>/discussion.md`
2. Parse the `<!-- STATUS -->` panel
3. Report:
   - Current round and phase
   - Which roles have responded, which are pending
   - Unresolved `@` mentions
   - Whether convergence conditions are met
4. If pending agents remain, generate continuation prompts and print them
5. If all rounds complete, suggest moving to draft phase (`/discuss draft <topic>`)

### `draft <topic>`

Enter draft phase.

1. Read `docs/discussions/<topic>/discussion.md`
2. Verify sufficient discussion has occurred (at least 1 complete round)
3. Synthesize discussion into a draft entry appended to `discussion.md`
4. Update STATUS panel: set `phase: draft`
5. Generate review continuation prompts for other tools
6. Print instructions for soliciting reviews

### `summarize <topic>`

Generate final plan.md and task.md.

1. Read entire `docs/discussions/<topic>/discussion.md`
2. Read `${CLAUDE_PLUGIN_ROOT}/references/output-format.md` for templates
3. Follow skill Phase 4 (Summarize) workflow:
   - Extract `#consensus` decisions and `> [!decision]` callouts
   - Extract core viewpoints from each role
   - Identify unresolved `#pending` items
4. Generate `docs/discussions/<topic>/plan.md` following Fabula v5.x format
5. Generate `docs/discussions/<topic>/task.md` following Fabula v5.x format
6. Print summary of generated deliverables

## Default Behavior

If no subcommand is recognized, print usage help:

```
用法: /discuss <subcommand> [topic] [options]

子命令:
  init <topic>       初始化讨论空间
  invite <topic>     生成/重新生成邀请提示词
  status <topic>     检查讨论进度
  draft <topic>      进入草案阶段
  summarize <topic>  汇总生成 plan.md + task.md

选项:
  --tools <list>         参与工具 (默认: cursor,codex)
  --roles <list>         角色分配 (默认: PM,Architect,Frontend)
  --rounds <n>           最大讨论轮次 (默认: 3)
  --project-root <path>  目标项目根目录 (默认: .)

示例:
  /discuss init auth-system --roles PM,Architect,Security --tools cursor,codex
  /discuss status auth-system
  /discuss summarize auth-system
```
