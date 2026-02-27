# Changelog

All notable changes to Azuro Marketplace will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [5.1.15] - 2026-02-27

### Changed
- TODO: Describe your changes here


## [5.1.14] - 2026-02-27

### Changed
- TODO: Describe your changes here


## [5.1.13] - 2026-02-27

### Added
- **acceptance-reporter**: Enhanced HTML report generation with:
  - markdown-it integration for Markdown rendering (optional)
  - pixelmatch integration for screenshot comparison (optional)
  - Dark mode support via `prefers-color-scheme`
  - Table of contents navigation
  - Screenshot zoom functionality
  - Print-friendly styles
  - Diff indicator badges for comparison results

### Changed
- **acceptance-reporter**: Improved HTML template with better accessibility and responsive design


## [5.1.12] - 2026-02-27

### Changed
- TODO: Describe your changes here


## [5.1.11] - 2026-02-27

### Changed
- TODO: Describe your changes here


## [5.1.10] - 2026-02-27

### Added
- **Acceptance Testing Enhancement**: Implemented comprehensive acceptance testing system
  - New `/ai:acceptance` parameters: `--mode`, `--parallel`, `--team`, `--compare`
  - New `/ai:team:acceptance` command for Agent Teams parallel acceptance testing
  - New `acceptance-tester` Agent for browser-based page validation
  - New `acceptance-team` Skill for multi-page parallel acceptance
  - Updated `state-schema.json` with acceptance tracking fields
  - Created `codebox/acceptance/` directory structure with templates
  - Updated `team-orchestrator` with ACCEPTANCE_TEAM template
  - Updated `team-collaboration/templates.ts` with acceptance team template

### Changed
- **Smart Mode Selection**: `/ai:acceptance` now automatically selects the best execution mode:
  - Single page → Direct execution
  - 2-3 pages → Parallel execution
  - 4+ pages → Agent Teams parallel
- **Auto Acceptance**: `/ai:team feature` now automatically triggers frontend acceptance after development completes


## [5.1.9] - 2026-02-27

### Changed
- TODO: Describe your changes here


## [5.1.8] - 2026-02-27

### Changed
- TODO: Describe your changes here


## [5.1.7] - 2026-02-27

### Added
- **claude-reflect**: Added modular rules support (`.claude/rules/*.md`) with `paths` frontmatter
- **claude-reflect**: Added line limit checking (≤200 lines for main files) as 7th quality dimension
- **claude-reflect**: Added smart distribution algorithm for learning content
- **claude-reflect**: Created `references/modular-rules-guide.md` with complete documentation
- **claude-reflect**: Added modular rule templates to `references/templates.md`
- **claude-reflect**: Added research-based warnings about LLM-generated context files

### Changed
- **claude-reflect**: Updated scoring from 100 to 115 points (added Line Limits dimension)
- **claude-reflect**: Enhanced `audit-claude-md` command to discover and audit modular rules
- **claude-reflect**: Updated target file selection to include path-specific rules
- **claude-reflect**: Added pre-assessment check to determine if context files are needed
- **claude-reflect**: Emphasized "write for gaps, not overviews" principle based on research


## [5.1.6] - 2026-02-27

### Changed
- TODO: Describe your changes here


## [5.1.5] - 2026-02-27

### Changed
- TODO: Describe your changes here


## [5.1.4] - 2026-02-27

### Changed
- **code-reviewer**: Added single file line limit (≤700 lines) to deep quality checklist
- **code-reviewer**: Enhanced with 5-dimensional parallel review workflow from official plugin


## [5.1.3] - 2026-02-27

### Changed
- **code-reviewer**: Added single file line limit (≤700 lines) to deep quality checklist
- **code-reviewer**: Reduced from 548 to 237 lines while enhancing with 5-dimensional parallel review


## [5.1.2] - 2026-02-27

### Changed
- TODO: Describe your changes here


## [5.1.1] - 2026-02-27

### Changed
- TODO: Describe your changes here


## [5.1.0] - 2026-02-27

### Changed
- TODO: Describe your changes here


## [5.0.20] - 2026-02-26

### Added
- **ai:init command**: Quick start command for initializing new projects with ultrawork-compatible structure
- **.github/workflows/ci.yml**: GitHub Actions CI workflow for automated testing and validation
- **task-dependency-analyzer/examples/**: Example dependency analysis documentation
- **task-dependency-analyzer/references/**: DAG algorithm reference documentation

### Changed
- **task-dependency-analyzer**: Improved from 87 to 91 quality score
- **execution-tracker.sh**: Tested and verified working


## [5.0.19] - 2026-02-26

### Added
- **context-compressor skill**: Intelligent context compression for long-running workflows
- **task-dependency-analyzer skill**: DAG-based dependency analysis for parallel execution optimization
- **templates/nodejs**: Quick start template for Node.js projects with ultrawork compatibility
- **templates/python**: Quick start template for Python projects with ultrawork compatibility
- **execution-tracker.sh hook**: Session execution timing and performance reporting

### Changed
- **hooks.json**: Added execution-tracker to Stop hooks for session reports
- **subagent-driven-development**: Enhanced with context compression patterns


## [5.0.18] - 2026-02-26

### Added
- **tests/e2e-ultrawork-test.sh**: E2E automated test suite for ultrawork workflow validation (6 test cases)

### Changed
- **mcp-integration skill**: Added Context7 semantic search patterns for code pattern discovery, LSP integration priority
- **subagent-driven-development skill**: Added parallel execution optimization, dependency detection, context window management tips


## [5.0.17] - 2026-02-26

### Added
- **codebox-setup.sh**: Automated codebox directory creation script (spec.md, plan.md, active.md, completed.md)
- **ultrawork/references/workflow-details.md**: Comprehensive workflow reference documentation

### Changed
- **ultrawork Phase 3**: Enhanced with standardized codebox setup (spec.md, plan.md, active.md templates)
- **ultrawork Phase 5**: Added Task Tool parallel dispatch pattern and progress tracking template
- **ultrawork Phase 6**: Enhanced two-stage review with actual subagent call templates and review loop logic
- **ultrawork Phase 7**: Added TaskUpdate integration and active.md update template


## [5.0.16] - 2026-02-24

### Added
- **mcp-setup.sh**: One-click MCP server configuration script (Context7, Sequential-Thinking, Tavily)
- **Confidence Gate Phase 0**: Integrated into ultrawork flow for pre-execution confidence checking

### Changed
- **All 25 skills reach 90+ score**: Quality audit optimization complete
- **ultrawork**: Added Phase 0 Confidence Gate and mcp-integration dependency
- **tdd-enforcement**: Improved description, added examples directory
- **subagent-driven-development**: Added references directory, enhanced triggers
- **spec-compliance-review**: Added workflow integration docs, examples directory
- **pre-check**: Fixed third-person description, added Chinese triggers
- **comment-checker hook**: Enhanced AI slop detection with 5 pattern categories


## [5.0.15] - 2026-02-11

### Added
- **comment-checker hook**: Enhanced AI slop detection (redundant comments, step narration, AI markers)
- **task-templates skill**: Atomic task templates for fine-grained 2-5 minute implementation steps

### Changed
- **ultrawork skill**: Full integration of all Superpowers components (TDD, Worktree, Subagents, Two-stage Review, Sisyphus Mode)
- **hooks.json**: Minor configuration refinements


## [5.0.14] - 2026-02-09

### Added
- **todo-continuation-enforcer hook**: Sisyphus mode - blocks exit until all tasks complete with <promise>DONE</promise>
- **subagent-driven-development skill**: One subagent per task with structured handoff and two-stage review

### Changed
- **git-worktree skill**: Enhanced with auto-trigger for COMPLEX tasks (≥5 files)
- **hooks.json**: Added todo-continuation-enforcer to Stop hooks


## [5.0.13] - 2026-02-09

### Added
- **ultrawork skill**: One-word trigger for complete autonomous workflow (TDD, subagent-driven, two-stage review)
- **tdd-enforcement skill**: Strict TDD discipline with Iron Law enforcement
- **spec-compliance-review skill**: Stage 1 review - verify implementation matches spec exactly

### Changed
- **code-reviewer**: Enhanced with two-stage review mechanism (Stage 2: code quality)
- Borrowed key patterns from Superpowers: TDD Iron Law, Subagent-driven development, Two-stage review


## [5.0.10] - 2026-01-14

### Changed
- TODO: Describe your changes here


## [5.0.9] - 2026-01-14

### Added
- **LSP-First Navigation** - 代码导航优先使用 LSP 工具
  - `LSP.goToDefinition`, `LSP.findReferences` 替代 Grep 进行符号导航
  - 语义理解，跨文件精确导航，类型感知引用
  - 在 CLAUDE.md、ai-dev、knowledge-graph 中添加指导
- **Parallel Task Marking** - OODA 循环支持并行任务标记
  - tasks.md 支持 `[parallel]` 标记
  - 自动检测文件冲突，无冲突时并行执行
  - LSP 辅助验证任务依赖

### Changed
- **knowledge-graph** - 增强工具优先级链
  - LSP (代码导航) → MCP Context7 (文档) → 本地知识库 → Grep/Glob
  - MCP 语义搜索集成
- **ai-dev workflow** - 新增 LSP-First Navigation 关键特性


## [5.0.8] - 2026-01-14

### Added
- **mcp-integration skill** - MCP 服务器集成指南
  - Context7: 官方文档查询，防止 AI 幻觉
  - Tavily: 深度网络搜索，增强研究能力
  - Sequential-Thinking: 多步推理，减少 token
  - 配置示例和最佳实践

### Changed
- **competitor-research** - 新增 MCP 增强研究功能
  - Tavily MCP 优先于 Gemini 进行网络搜索
  - Context7 MCP 用于官方文档查询
  - 实现 MCP → 传统方法的降级链
- **ai-dev workflow** - 集成 mcp-integration 到 Phase 0, 0.5

### Technical
- 遵循官方插件参考文档的 MCP 配置规范
- 支持 `.mcp.json` 和 `plugin.json` 两种配置方式


## [5.0.7] - 2026-01-14

### Added
- **git-worktree skill** - 隔离开发工作空间管理（借鉴 Superpowers）
  - `create-worktree.sh` - 创建隔离 worktree 并自动安装依赖
  - `cleanup-worktree.sh` - 安全清理 worktree 并可选删除分支
  - 集成到 ai-dev Phase 2.5 和 Phase 6
- **confidence-gate skill** - 前置置信度门控（借鉴 SuperClaude PM Agent）
  - ≥90%: 直接执行
  - 70-89%: 提供备选方案
  - <70%: 必须问问题，不能猜测
  - ROI: 25-250x token 节省
- **TDD Enforcement** in ai-dev-ooda - 强制 Red-Green-Refactor 循环
  - 每个任务必须先写失败测试
  - 无测试不允许标记完成

### Changed
- **ai-dev workflow** - 新增 Phase 2.5 (Worktree Setup) 和 Phase 0 Confidence Gate
- **ai-dev-ooda** - 新增 TDD 强制门控，任务格式增加 `tdd_required` 字段

### Technical
- 借鉴 Superpowers 的 git-worktree 隔离开发模式
- 借鉴 SuperClaude PM Agent 的置信度门控（≥90%/70-89%/<70%）
- 借鉴 Superpowers 的 TDD 铁律（红绿重构）


## [5.0.6] - 2026-01-14

### Added
- **spec-compliance-reviewer agent** - 规格符合性审查，验证实现是否不多不少符合需求
  - Missing/Extra/Misunderstood 三维检查
  - Phase 5 Quality Validation 的第一道门禁
- **TDD 意识检查** - code-reviewer 新增测试先行原则验证

### Changed
- **task-decomposer 原子化要求** - 任务粒度从 2-8 小时改为 2-5 分钟
  - 每个任务必须包含精确文件路径
  - 每个任务必须包含验证命令
- **ai-dev Phase 5 流程优化** - Spec Compliance → Code Review → Confidence Scoring
- **ai-dev Phase 3 强化** - 生成 2-5 分钟原子化子任务

### Technical
- 借鉴 Superpowers 的三角色子代理模型（Implementer + Spec Reviewer + Quality Reviewer）
- 借鉴 Superpowers 的 TDD 铁律和防御性措辞


## [5.0.5] - 2026-01-14

### Changed
- Reverted URLs to use `refs/heads/main` format (industry standard)


## [5.0.4] - 2026-01-14

### Fixed
- Fixed raw.githubusercontent.com URLs in README (removed `refs/heads/` prefix)


## [5.0.3] - 2026-01-14

### Added
- **Multi-platform Installation** - Support for Codex and OpenCode platforms
- `.codex/INSTALL.md` - Installation guide for Codex users
- `.opencode/INSTALL.md` - Installation guide for OpenCode users

### Changed
- Updated README.md and README.zh-CN.md with multi-platform quick start section


## [5.0.2] - 2026-01-14

### Added
- **CHANGELOG Gate** - Pre-commit validation ensures CHANGELOG.md documents current version
- `bump.sh` now auto-generates CHANGELOG entry template

### Changed
- Moved `components/scripts/` → `scripts/` (17 scripts + templates)
- Deleted empty `components/` directory
- Updated all path references in hooks and scripts

## [5.0.1] - 2026-01-14

### Changed
- Fixed `sync-docs.sh` relative paths after directory restructure
- Updated `context-window-monitor.sh` SCRIPTS_DIR path
- Updated `handover.md` template path reference

## [5.0.0] - 2026-01-14

### Added
- **README Command Table Update** - Added 3 missing commands: session-save, session-resume, test-web
- **context-bridge v5.0** - Simplified from 1022 to ~225 lines (78% reduction)
- All 16 skills achieved **90+ quality scores** (A grade)

### Changed
- Removed 3 deprecated commands from docs: loop, auto, review
- Detailed implementation moved to `skills/context-bridge/references/`
- Version management with comprehensive pre-commit validation

### Technical
- Professional 7-phase gated workflow fully documented
- OODA autonomous completion loop refined


## [4.2.9] - 2026-01-14

### Added
- **PreToolUse Hook** - Pre-commit code review triggered before `git commit`
- **PostToolUse Hook** - Automated quick code review after Write/Edit operations
- Hook script `pre-commit-check.sh` for git commit interception

### Technical
- Updated hooks.json with PreToolUse and PostToolUse configurations
- Workaround for Claude Code not supporting "PreCommit" hook type

## [4.2.8] - 2026-01-14

### Added
- All skills upgraded to **90+ quality score**
- Chinese trigger keywords optimization for natural usage

### Changed
- Optimized trigger phrases: 优化 (simplified), 重构, 技术债务

## [4.2.7] - 2026-01-13

### Added
- **Comprehensive Skills Integration Guide** (`references/skills-integration-guide.md`)
- Official patterns applied: Progressive Disclosure, Philosophy-Driven Creation, Anti-AI-Slop

### Changed
- Skills documentation restructured for better discoverability
- Third-person descriptions in all skill frontmatters

## [4.2.6] - 2026-01-13

### Added
- **Command Consolidation** - 22 commands reduced to 6 user-facing commands
- Subagent mode for `/ai:fix` command
- Internal command markers (`internal: true` in frontmatter)

### Changed
- `/ai:dev auto` replaces standalone `/ai:auto`
- `/ai:status` consolidates list/show functionality
- `/ai:session-save` and `/ai:session-resume` unified naming

## [4.2.5] - 2026-01-12

### Added
- **brainstorm-mode skill** - Socratic exploration for unclear requirements
- **root-cause-analyst agent** - 5-Why, Fishbone, Fault Tree Analysis
- **Unified Flag System** (`core/FLAGS.md`) - `--think`, `--ultrathink`, `--parallel`, etc.

### Technical
- FLAGS.md referenced in CLAUDE.md for discoverability

## [4.2.4] - 2026-01-11

### Added
- **code-simplifier** integration with SOLID principles
- Complexity metrics (cyclomatic, cognitive)
- Anti-AI-Slop principles documentation

### Changed
- ai-dev architecture modularization (ai-dev-ooda, ai-dev-interview, ai-dev-quality)

## [4.1.2] - 2026-01-08

### Fixed
- Version sync stabilization across all skills
- Auto-stage nested SKILL.md files in pre-commit hook

## [4.1.0] - 2026-01-07

### Added
- **context-bridge v4.1.0** - Auto Checkpoint and unified Lite Mode
- Context window monitoring with anxiety management

## [4.0.2] - 2026-01-07

### Added
- AI-Dev Evolution Edition release
- OODA autonomous completion loop refinements

## [4.0.0] - 2026-01-07

### Added
- **AI-Dev v4.0 Evolution Edition**
- **7-Phase Gated Workflow** with user approval gates
- **OODA Autonomous Completion Loop** - Execute until `<promise>DONE</promise>`
- **Worker Sessions** for context scaling (80% threshold)
- **Reflexion System** for self-learning from failures
- **Attention Management** - Read Before Decide pattern

### Technical
- `codebox/` project structure for change management
- Knowledge base with patterns.json and errors.json
- Confidence-filtered quality review (≥80 threshold)

## [3.5.1] - 2026-01-05

### Added
- **Professional Suite Structure** - Multiple isolated plugins
- Standard plugin directory layout (agents/, commands/, hooks/, skills/)

### Changed
- Migrated from single-plugin to multi-plugin architecture

## [3.4.6] - 2026-01-04

### Changed
- Marketplace renamed to `azuro-marketplace`
- Updated README with new marketplace handle

## [3.3.0] - 2026-01-03

### Added
- **skill-auditor** with quality validation scripts
- Quality gate and version gate pre-commit hooks
- `validate-skill.sh` for automated skill scoring

### Technical
- Skills must achieve ≥80 score to pass quality gate

## [3.2.0] - 2026-01-02

### Added
- **thinking-engine** skill for structured reasoning
- **knowledge-graph** skill for cross-project knowledge
- **competitor-research** skill for Phase 0.5 research

## [3.0.0] - 2026-01-01

### Added
- Initial orchestration framework
- Basic phase workflow
- Core agents: requirement-interviewer, code-explorer, code-architect

---

## Version Summary

| Version | Date | Key Features |
|---------|------|--------------|
| 5.0.2 | 2026-01-14 | CHANGELOG gate, directory restructure |
| 5.0.0 | 2026-01-14 | context-bridge v5.0, all skills 90+ |
| 4.2.9 | 2026-01-14 | Pre-commit hooks, automated code review |
| 4.2.8 | 2026-01-14 | Skills 90+ quality, Chinese triggers |
| 4.2.7 | 2026-01-13 | Skills integration guide, official patterns |
| 4.2.6 | 2026-01-13 | Command consolidation (22→6) |
| 4.2.5 | 2026-01-12 | brainstorm-mode, root-cause-analyst, FLAGS |
| 4.2.4 | 2026-01-11 | code-simplifier SOLID, ai-dev modularization |
| 4.0.0 | 2026-01-07 | AI-Dev v4.0 Evolution Edition |
| 3.5.1 | 2026-01-05 | Professional suite structure |
| 3.3.0 | 2026-01-03 | skill-auditor, quality gates |
| 3.0.0 | 2026-01-01 | Initial release |
