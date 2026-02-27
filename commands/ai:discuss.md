---
name: ai:discuss
description: Multi-agent discussion coordinator — init, invite, check progress, or summarize
argument-hint: "<init|invite|status|next|draft|summarize> [topic] [--tools cursor,codex] [--roles PM,Architect,Security] [--rounds 3] [--project-root .]"
allowed-tools: Read, Write, Edit, Bash, Glob, Grep, Task
internal: true
---

# Multi-Agent Discussion Command

Parse `$ARGUMENTS` to determine subcommand.

## Subcommands

### `init <topic>`

Initialize a new discussion space with project analysis seed.

1. Parse options:
   - `<topic>`: 讨论主题（必需，kebab-case）
   - `--tools`: 参与工具列表（默认: `cursor,codex`）
   - `--roles`: 角色分配（默认: `PM,Architect,Frontend`）
   - `--rounds`: 最大讨论轮次（默认: `3`）
   - `--project-root`: 目标项目根目录（默认: `.`，当前目录）

2. Scaffold directory:
   - Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-discussion.sh <project-root> <topic> <rounds>`

3. **Auto-populate context.md**（不留空让用户填）:
   - Use Glob/Grep/Read 分析目标项目
   - 填充技术栈、架构概览、关键数据指标（文件数、模块数、依赖关系、已知问题等）
   - 尽量提供具体数字而非通用描述

4. Configure roles:
   - Read `${CLAUDE_PLUGIN_ROOT}/references/role-catalog.md` to get role descriptions
   - Update `README.md` with selected roles
   - Update `discussion.md` STATUS panel with role list in `pending`

5. **Seed Round 0 as @Coordinator**:
   - 在 `discussion.md` 中追加 Claude Code 的项目分析发言
   - 包含：项目关键数据、当前痛点分析、讨论议题框架
   - 使用标准发言格式（`## [Round 0] @Coordinator — Claude Code`）
   - 为后续 agent 提供事实基础，降低其信息搜索成本

6. Generate invitation files:
   - Read `${CLAUDE_PLUGIN_ROOT}/references/invitation-templates.md`
   - **Write** `invite-<role>-<tool>.md` to discussion directory
   - **注入 context.md 数据和 Round 0 关键发现**到邀请中（不是通用的项目描述）

7. Generate continuation files:
   - Write `continue/round-1-<role>-<tool>.md` for each role+tool
   - Round 1 而非 Round 2（因为 Round 0 由 Claude Code 完成）

8. Print usage guide:
   - List all `invite-*.md` files with target tools
   - Tell user: "将 `invite-<role>-<tool>.md` 的内容复制到 <tool> 中"
   - How to check progress: `/ai:discuss status <topic>`

### `invite <topic>`

Re-generate invitation files with current discussion state.

1. Read `docs/ai:discussions/<topic>/README.md` for role assignments
2. Read `docs/ai:discussions/<topic>/ai:discussion.md` for STATUS and latest content
3. Read `docs/ai:discussions/<topic>/context.md` for project data
4. Read `${CLAUDE_PLUGIN_ROOT}/references/invitation-templates.md`
5. **Write** fresh invitation files with up-to-date discussion context
6. Print file list with instructions

### `status <topic>`

Check discussion progress with deep scan.

1. Read `docs/ai:discussions/<topic>/ai:discussion.md`
2. **Deep scan** — not just STATUS panel:
   - Parse actual `[Round N]` headers to determine who has responded
   - Scan `@` mentions in text to find unresolved ones
   - Scan `#consensus`/`#pending`/`#rejected` tags for convergence status
3. **Validate and repair** STATUS panel if inconsistent with actual content
4. Report:
   - Current round and phase
   - Which roles have responded, which are pending
   - Unresolved `@` mentions (with quoted topic)
   - Convergence assessment: can we skip Draft?
5. Suggest next action:
   - Pending agents → print continuation file paths
   - Round complete → suggest `/ai:discuss next <topic>`
   - Consensus reached → suggest `/ai:discuss summarize <topic>` (skip Draft)
   - All rounds exhausted → suggest `/ai:discuss draft <topic>` or `/ai:discuss summarize <topic>`

### `next <topic>`

Advance to next round with context-rich continuation files.

1. Read `docs/ai:discussions/<topic>/ai:discussion.md`
2. **Deep scan** to verify current round is complete
3. Update STATUS panel: increment round, reset all roles to pending
4. **Dynamically generate** role-specific continuation files:
   - Extract all unresolved `@` mentions targeting each role
   - Quote the relevant context (not just the topic string)
   - Summarize current consensus/disagreement points
   - Add "完成后提示" footer with next role's file path
5. Print instructions: which file to copy to which tool, in what order

### `draft <topic>`

Enter draft phase (optional — skip if consensus is comprehensive).

1. Read `docs/ai:discussions/<topic>/ai:discussion.md`
2. Verify at least 1 complete round
3. Synthesize discussion into a `[Draft v1]` entry appended to `discussion.md`
4. Update STATUS: set `phase: draft`
5. **Write** review continuation files for other tools
6. Print instructions

### `summarize <topic>`

Generate final plan.md and task.md.

1. Read entire `docs/ai:discussions/<topic>/ai:discussion.md`
2. Read `${CLAUDE_PLUGIN_ROOT}/references/output-format.md`
3. **Deep extract**:
   - All `#consensus` decisions and `> [!decision]` callouts
   - All `> [!proposal]` callouts with their pros/cons
   - All `#pending` and `#needs-input` items → "Open Issues"
   - Core viewpoints from each role
4. Generate `docs/ai:discussions/<topic>/plan.md`:
   - Fabula v5.x format with ADRs, confidence analysis, rollback points
   - Unresolved items listed explicitly
5. Generate `docs/ai:discussions/<topic>/task.md`:
   - Phase-grouped tasks with review gates
   - Each phase links to corresponding rollback point in plan.md
6. Update STATUS: set `phase: done`
7. Print deliverable summary

## Default Behavior

If no subcommand is recognized, print usage help:

```
用法: /ai:discuss <subcommand> [topic] [options]

子命令:
  init <topic>       初始化讨论空间（含项目分析种子）
  invite <topic>     重新生成邀请文件
  status <topic>     深度扫描讨论进度
  next <topic>       推进下一轮（动态生成续接文件）
  draft <topic>      进入草案阶段（可选）
  summarize <topic>  汇总生成 plan.md + task.md

选项:
  --tools <list>         参与工具 (默认: cursor,codex)
  --roles <list>         角色分配 (默认: PM,Architect,Frontend)
  --rounds <n>           最大讨论轮次 (默认: 3)
  --project-root <path>  目标项目根目录 (默认: .)

示例:
  /ai:discuss init auth-system --roles PM,Architect,Security --tools cursor,codex
  /ai:discuss status auth-system
  /ai:discuss next auth-system
  /ai:discuss summarize auth-system

工作流:
  init(含Round 0种子) → 复制邀请到各工具 → status → next → 复制续接 → ... → summarize
  注: 达成共识后可跳过 draft 直接 summarize
```
