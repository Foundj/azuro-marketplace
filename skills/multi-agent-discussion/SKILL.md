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

  <example>
  Context: User wants to discuss architecture decisions for a new feature with multiple AI perspectives
  user: "我想让多个 AI 工具一起讨论下这个微服务拆分方案，start a discussion 用 architecture-design preset"
  assistant: "I'll use the multi-agent-discussion skill to initiate an architecture-design discussion, detecting available CLI tools and orchestrating the debate."
  <commentary>
  User explicitly asks to "start a discussion" with a specific preset, triggering multi-agent orchestration.
  </commentary>
  </example>

  <example>
  Context: User has an ongoing discussion and wants to check convergence status
  user: "检查讨论进度，看看 auth-system 那个讨论各个角色都发言了没"
  assistant: "I'll use the multi-agent-discussion skill to check the progress of the auth-system discussion and evaluate convergence."
  <commentary>
  Chinese trigger "检查讨论进度" with a specific discussion topic triggers the progress check workflow.
  </commentary>
  </example>

  <example>
  Context: Discussion rounds are complete and user wants deliverables
  user: "讨论差不多了，汇总讨论结果生成 plan.md 和 task.md 吧"
  assistant: "I'll use the multi-agent-discussion skill to summarize the discussion and generate plan.md and task.md deliverables."
  <commentary>
  Trigger phrase "汇总讨论结果" combined with explicit output request activates the Summarize phase.
  </commentary>
  </example>
version: 6.0.23
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
6. **加权共识**：基于角色专业度和发言置信度的加权投票，提升决策质量

## Weighted Voting System

### 概述

借鉴 MiroFlow 深度推理模式的集成策略，本讨论框架引入加权投票机制。每个 Agent 的投票权重由**角色基础权重**和**发言置信度**共同决定，避免均等投票导致的专业意见被稀释。

### 角色基础权重表

| 角色 | 权重 | 说明 |
|------|------|------|
| @Architect | 0.90 | 架构决策权重最高 |
| @Engineer / @Backend / @Frontend | 0.85 | 实现可行性权威 |
| @Coordinator | 0.85 | 项目全局视角 |
| @PM | 0.80 | 需求理解与优先级 |
| @Security / @QA / @DevOps | 0.80 | 专业维度评审 |
| @UserAdvocate | 0.75 | 用户视角代表 |
| @Critic | 0.70 | 反对意见（权重略低防止过度否决） |
| 自定义角色 | 0.75 | 默认权重 |

### 发言置信度（Confidence）

Agent 发言时可附带置信度声明，范围 `[0.0, 1.0]`：

```markdown
## [Round 1] @Architect [confidence: 0.85] — codex
> 时间: 2025-01-15 14:30

方案 A 更优，因为...

#consensus(方案A)
```

- 未声明置信度时默认为 `1.0`（向后兼容）
- 置信度反映 Agent 对当前发言的确信程度
- 低置信度（如 0.5）表示"倾向但不确定"

### 加权收敛算法（五因子公式）

```
effective_weight = role_weight × confidence × quality_bonus × tool_score × history_modifier
weighted_consensus = Σ(effective_weight × vote_value) / Σ(effective_weight)

vote_value:
  #consensus  →  1.0（同意）
  #pending    →  0.0（待定）
  #rejected   → -0.5（反对）

收敛条件:
  weighted_consensus >= 0.65 且 blocker_count == 0 且 needs_input_count == 0
```

### 工具多维度评分（Tool Score）

不同工具在不同维度上表现差异显著。tool_score 基于 4 个维度和讨论主题类型计算：

| 维度 | 含义 | 说明 |
|------|------|------|
| thoroughness（彻底性） | 全面审查，不遗漏 | 高分 = 审查踏实、覆盖全面 |
| accuracy（真实性） | 事实准确，不幻觉 | 高分 = 输出可靠、少编造 |
| creativity（创造性） | 创新方案和思路 | 高分 = 方案新颖、视角独特 |
| execution（落实性） | 方案具体可执行 | 高分 = 细节充足、可直接落地 |

```
tool_score = Σ(dimension_value × topic_weight) 对每个维度
```

不同主题类型下维度权重不同（由 `data/topic-weights.json` 配置）：
- **code-review**: 彻底性和真实性最重要（各 0.35）
- **architecture**: 创造性和落实性重要（各 0.30）
- **requirement**: 四维度均衡（各 0.25）
- **security**: 真实性最重要（0.35）

工具初始评分在 `data/tool-profiles.json` 中配置，可根据实际使用经验调整。`claudea`/`claudec`/`claudeg` 等变体共享 `claude` 的 profile。

### 历史权重修正（History Modifier）

`history_modifier` 基于 Agent 在历往讨论中的表现自动计算：
- 质量得分平均值和共识对齐度越高，权重修正越大
- 范围 `[0.6, 1.4]`，初始值 `1.0`
- 由 `update-history.sh` 在讨论结束后更新到 `data/agent-history.json`

### 示例

code-review 场景下，使用 codex 的 @Architect：
```
role_weight  = 0.90 (Architect)
confidence   = 0.9
quality_bonus = 1.15 (3/5 质量维度命中)
tool_score   = 0.95×0.35 + 0.90×0.35 + 0.75×0.10 + 0.90×0.20 = 0.9025 (codex)
history_mod  = 1.08 (历史表现良好)

effective_weight = 0.90 × 0.9 × 1.15 × 0.9025 × 1.08 = 0.908
```

对比使用 gemini 的 @PM：
```
role_weight  = 0.80 (PM)
confidence   = 0.8
quality_bonus = 1.10 (2/5 质量维度命中)
tool_score   = 0.75×0.35 + 0.78×0.35 + 0.85×0.10 + 0.75×0.20 = 0.7705 (gemini)
history_mod  = 1.00 (无历史数据)

effective_weight = 0.80 × 0.8 × 1.10 × 0.7705 × 1.00 = 0.542
```

### 质量加分系统（Quality Scoring）

每次发言自动评估 5 个质量维度，每个维度 +1 分（最高 5 分），通过 `quality_bonus` 因子影响有效权重：

| 维度 | 检测条件 | 加分 |
|------|---------|------|
| 代码引用 | 包含代码块、文件路径或内联代码 | +1 |
| 风险识别 | 包含 `#risk`、安全/性能/漏洞等关键词 | +1 |
| 方案对比 | 包含 vs 对比、trade-off、权衡分析 | +1 |
| 引用他人 | 引用 `@Role`、引述其他 Agent 观点 | +1 |
| 行动项 | 包含 `#action`、建议、TODO、下一步 | +1 |

```
quality_bonus = 1.0 + (quality_score × 0.05)
# 范围: 1.00（0分）— 1.25（5分满分）
```

高质量发言（引用代码、识别风险、提出行动项）的投票权重最高可获得 25% 加成。

> **Note**: quality_bonus 是五因子公式中的一个因子。完整公式见「加权收敛算法」章节。

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
├── discussion.md                # Main blackboard (STATUS panel + rounds)
├── context.md                   # Auto-populated project background
├── README.md                    # Rules, roles, syntax reference
├── drafts/                      # Draft iteration artifacts
│   ├── v1.md, v1-verify.json   # Draft versions + verification results
│   └── final.md                # Accepted final draft
├── plans/                       # Decision deliverables (local copies)
│   ├── plan.md                 # Implementation plan
│   └── task.md                 # Task breakdown
├── notepads/                    # Process notes
│   ├── ensemble-*.json         # Parallel voting results
│   └── convergence.log         # Convergence snapshots
├── prompts/                     # Agent invocation prompts
├── continue/                    # Continuation prompts (manual mode)
│   ├── round-N-<role>-<tool>.md
│   ├── draft.md
│   └── review.md
├── invite-<role>-<tool>.md      # Self-contained invitation (manual mode)
└── refs/                        # Attachments (code, designs)
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
- **Parallel ensemble**: at `#decision-point` tags, multiple agents analyze in parallel with differentiated prompts, results aggregated via weighted voting (`ensemble-vote.sh`). Results saved to `notepads/ensemble-{N}.json`

**Progress check** — when user says "检查讨论进度" or "check progress":

Show progress label `[Round N/Max]`, then:
1. **Deep scan** `discussion.md`
2. If auto mode: also show `evaluate-convergence.sh` output
3. Report current state and recommend next action

### Phase 3: Draft (Optional + Verification Loop)

When discussion has converged but details need refinement. Skip if `#consensus` is already clear and comprehensive (auto mode will skip automatically based on convergence evaluation).

**Verification Loop (生成-校验循环):**

Draft 阶段引入迭代校验机制，借鉴 MiroFlow 校验策略：

```
Draft → Verify → (score < 7?) → Revise → Verify → ... → Accept
最多 3 轮，或校验分数 >= 7/10 时通过
```

校验脚本 `verify-draft.sh` 评估 4 个维度（各 1-10 分，加权平均）：
- **完整性 (30%)**：是否覆盖了所有 `#consensus` 议题
- **一致性 (30%)**：是否与讨论共识一致，不包含已否决内容
- **可行性 (20%)**：是否有具体代码、步骤和实现细节
- **风险覆盖 (20%)**：是否回应了 @Critic 提出的问题

不通过时，反馈具体改进建议，由 @Drafter 修正后重新校验。

**Output paths:**
- Draft 草案写入 `drafts/v{N}.md`（v1.md, v2.md, ...）
- 校验结果写入 `drafts/v{N}-verify.json`
- 最终通过的草案复制为 `drafts/final.md`

### Phase 4: Summarize

When convergence is reached (auto) or user triggers manually:

1. Read entire `discussion.md`
2. **Update agent history**: Run `bash ${CLAUDE_PLUGIN_ROOT}/scripts/update-history.sh discussion.md data/agent-history.json` to persist performance data
3. **Deep extract**: scan all tags, callouts, `#consensus`, `> [!decision]`
3. **Invoke `task-planner` skill** to generate versioned plan.md + task.md:
   - Pass extracted decisions, consensus items, and pending questions as input
   - task-planner handles version determination, requirement-analyzer evaluation, and template rendering
   - Output goes to `docs/tasks/v<VERSION>/`
4. **Local copies**: Copy generated plan.md and task.md to `plans/` directory for discussion-local reference
5. Update STATUS panel: set `phase: done`
6. Print deliverable summary:
   - `docs/tasks/v<VERSION>/plan.md` — 设计文档（正式位置）
   - `docs/tasks/v<VERSION>/task.md` — 执行看板（正式位置）
   - `plans/plan.md`, `plans/task.md` — 讨论本地副本
   - 来源讨论：`docs/discussions/<topic>/discussion.md`

> **Note**: Template specifications are maintained in `references/output-format.md` for reference, but the actual generation logic is handled by the `task-planner` skill to ensure consistency across all creation paths (discussion-driven, dev-driven, and direct).

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
- **`scripts/evaluate-convergence.sh`** — Evaluate discussion convergence (five-factor weighted voting)
- **`scripts/score-response.sh`** — Quality + tool dimension scoring engine
- **`scripts/verify-draft.sh`** — Draft verification loop (generator-verifier cycle)
- **`scripts/ensemble-vote.sh`** — Parallel ensemble voting for decision points
- **`scripts/update-history.sh`** — Update agent performance history after discussion
- **`scripts/orchestrate-round.sh`** — Orchestrate a single discussion round
- **`scripts/init-discussion.sh`** — Initialize discussion directory structure
- **`scripts/populate-context.sh`** — Auto-scan project and populate context.md

### Data Files
- **`data/agent-history.json`** — Agent historical performance data (auto-updated)
- **`data/tool-profiles.json`** — Tool multi-dimensional capability scores (configurable)
- **`data/topic-weights.json`** — Topic-type dimension weight templates

### Documentation
- **`docs/cli-non-interactive-modes.md`** — CLI non-interactive mode reference
- **`docs/refactor-plan-cli-orchestration.md`** — Architecture refactoring plan
