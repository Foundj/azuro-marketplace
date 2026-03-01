---
name: ai:discuss
description: Multi-agent discussion coordinator — init, run, invite, check progress, or summarize with automated CLI orchestration
argument-hint: "<init|run|invite|status|next|draft|summarize> [topic] [--preset product-discovery|architecture-design|full-review|security-audit] [--auto] [--roles PM,Architect,Security] [--rounds 3] [--project-root .]"
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
   - `--preset`: 预设角色组合（默认: 无，交互式选择）
     - `product-discovery`: @PM + @UserAdvocate + @Architect + @Critic
     - `architecture-design`: @Architect + @Backend + @Security + @Critic
     - `full-review`: @PM + @Architect + @Frontend + @Backend + @QA
     - `security-audit`: @Architect + @Security + @Backend + @DevOps
   - `--auto`: 强制自动模式（不询问，直接使用 CLI 编排）
   - `--roles`: 自定义角色分配（覆盖 preset）
   - `--rounds`: 最大讨论轮次（默认: `3`）
   - `--project-root`: 目标项目根目录（默认: `.`）

2. Scaffold directory:
   - Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/init-discussion.sh <project-root> <topic> <rounds> [--preset <preset>]`

3. **Auto-populate context.md**（不留空让用户填）:
   - Use Glob/Grep/Read 分析目标项目
   - 填充技术栈、架构概览、关键数据指标
   - 尽量提供具体数字而非通用描述

4. Configure roles:
   - Read `${CLAUDE_PLUGIN_ROOT}/references/role-catalog.md` to get role descriptions
   - If `--preset` specified, read `${CLAUDE_PLUGIN_ROOT}/references/discussion-presets.md` for preset config
   - Update `README.md` with selected roles
   - Update `discussion.md` STATUS panel with role list in `pending`

5. **Seed Round 0 as @Coordinator**:
   - 在 `discussion.md` 中追加 Claude Code 的项目分析发言
   - 包含：项目关键数据、当前痛点分析、讨论议题框架
   - 使用标准发言格式

6. **Detect CLI tools**:
   - Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/detect-cli-tools.sh`
   - Determine mode: auto / manual / hybrid

7. **Mode-dependent actions**:
   - **Auto mode** (`--auto` or all roles have available tools):
     - Assign roles to available tools using max-diversity strategy
     - Record tool assignments in STATUS panel
     - Inform user: "检测到 N 个可用工具，将使用自动编排模式"
     - Suggest: `/ai:discuss run <topic>` to start automated discussion
   - **Manual mode** (no external tools):
     - Generate invitation files: `invite-<role>-<tool>.md`
     - Generate continuation files: `continue/round-1-<role>-<tool>.md`
     - Print usage guide with file paths and copy instructions
   - **Hybrid mode** (some tools available):
     - Auto-assign available tools, generate invitations for unavailable ones
     - Print clear status of which roles are automated vs manual

### `run <topic>`

**NEW**: Run automated discussion rounds until convergence or max rounds.

1. Read `docs/discussions/<topic>/discussion.md` for current state
2. Verify auto mode is possible (check STATUS panel `mode` field)
3. If no tool detection done yet, run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/detect-cli-tools.sh`
4. **Orchestration loop**:
   ```
   for round in 1..max_rounds:
     for each role in preset/assigned roles:
       a. Build prompt from cli-prompt-templates.md + role-catalog.md
       b. Inject current discussion.md content + context.md + pending @ mentions
       c. Write prompt to temp file
       d. invoke-agent.sh <tool> <prompt-file> <working-dir>
       e. parse-response.sh → append to discussion.md
       f. Update STATUS panel

     evaluate-convergence.sh → check convergence
     if converged → break
   ```
5. After loop:
   - If converged: suggest `/ai:discuss summarize <topic>`
   - If max rounds reached: show convergence report, let user decide
6. Print round-by-round summary

### `invite <topic>`

Re-generate invitation files with current discussion state.

1. Read discussion state
2. Read `${CLAUDE_PLUGIN_ROOT}/references/invitation-templates.md`
3. **Write** fresh invitation files with up-to-date context
4. Print file list with instructions

### `status <topic>`

Check discussion progress with deep scan.

1. Read `docs/discussions/<topic>/discussion.md`
2. **Deep scan**:
   - Parse actual `[Round N]` headers
   - Scan `@` mentions and status tags
3. **Run convergence evaluation**:
   - `bash ${CLAUDE_PLUGIN_ROOT}/scripts/evaluate-convergence.sh <discussion-file>`
   - Show convergence metrics: consensus_ratio, pending_count, blocker_count
4. **Validate and repair** STATUS panel if inconsistent
5. Report and suggest next action:
   - Pending agents → print continuation file paths (manual) or suggest `run` (auto)
   - Consensus reached → suggest `summarize`
   - All rounds exhausted → suggest `draft` or `summarize`

### `next <topic>`

Advance to next round with context-rich continuation files (manual/hybrid mode).

1. Read and deep scan discussion
2. Verify current round is complete
3. Update STATUS panel: increment round, reset pending
4. **Dynamically generate** role-specific continuation files with @ mention context
5. Print instructions

### `draft <topic>`

Enter draft phase (optional — skip if consensus is comprehensive).

1. Read discussion and verify at least 1 complete round
2. Synthesize into `[Draft v1]` entry
3. Update STATUS: set `phase: draft`
4. Write review continuation files
5. Print instructions

### `summarize <topic>`

Generate final plan.md and task.md.

1. Read entire `docs/discussions/<topic>/discussion.md`
2. Read `${CLAUDE_PLUGIN_ROOT}/references/output-format.md`
3. **Deep extract** all decisions, proposals, pending items
4. Generate `plan.md` and `task.md` in Fabula v5.x format
5. Update STATUS: set `phase: done`
6. Print deliverable summary

## Default Behavior

If no subcommand is recognized, print usage help:

```
用法: /ai:discuss <subcommand> [topic] [options]

子命令:
  init <topic>       初始化讨论空间（含项目分析种子 + 工具检测）
  run <topic>        自动运行讨论轮次（CLI 编排模式）
  invite <topic>     重新生成邀请文件（手动模式）
  status <topic>     深度扫描讨论进度 + 收敛评估
  next <topic>       推进下一轮（手动模式，动态生成续接文件）
  draft <topic>      进入草案阶段（可选）
  summarize <topic>  汇总生成 plan.md + task.md

选项:
  --preset <name>        预设角色组合:
                           product-discovery  — 需求分析
                           architecture-design — 架构评审
                           full-review        — 全栈评审
                           security-audit     — 安全审计
  --auto                 强制自动编排模式
  --roles <list>         自定义角色 (覆盖 preset)
  --rounds <n>           最大讨论轮次 (默认: 3)
  --project-root <path>  目标项目根目录 (默认: .)

示例:
  /ai:discuss init auth-system --preset product-discovery
  /ai:discuss init auth-system --preset architecture-design --auto
  /ai:discuss run auth-system
  /ai:discuss status auth-system
  /ai:discuss summarize auth-system

工作流 (自动模式):
  init → run → (自动多轮讨论) → summarize

工作流 (手动模式):
  init → 复制邀请到各工具 → status → next → 复制续接 → ... → summarize
```
