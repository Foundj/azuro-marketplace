# Changelog

All notable changes to AI-Dev will be documented in this file.

## [3.2.0] - 2025-01-06

### Added
- **`/ai:loop` command** - Self-referential development loop inspired by oh-my-opencode's Ralph Loop
  - Continues until `<promise>DONE</promise>` detected or max iterations reached
  - Progressive notification strategy (5/10/20 iteration intervals)
  - Supports `--max-iterations` option
- **`/ai:auto` command** - Auto-complete remaining tasks in active change
  - Wrapper for `/ai:loop` focused on continuing existing work
  - Supports `--dry-run` and `--from-task` options
- **`keyword-detector.sh` hook** (UserPromptSubmit) - Detects keywords and injects mode instructions
  - Priority: ulw > ultrathink > think > quick
  - Keywords: ulw/ultrawork/全力/全自动, ultrathink/好好思考/深思熟虑, think/思考/想一想/仔细/深度, quick/快速/简单/快点
- **`context-window-monitor.sh` hook** (PostToolUse) - Monitors context usage
  - Warns at 85% threshold
  - Severity levels: medium (85%), high (90%), critical (95%)
  - Implements Context Window Anxiety Management pattern

### Enhanced
- **SKILL.md** - Added Ultra-Think mode documentation and loop commands
- **hooks.json** - Added keyword priority config and loop notification settings
- **commands/README.md** - Added /ai:loop and /ai:auto documentation

## [3.1.0] - 2025-01-06

### Added
- **commands/README.md** - Command documentation and usage guide
- **research-coordinator agent** - Multi-source parallel research using Task subagents
- **learning-coordinator agent** - Knowledge capture and reflection integration
- **multi-agent-patterns.md** - Reference for multi-agent architecture patterns
- **memory-systems.md** - Reference for memory and knowledge base design
- **context-compression.md** - Reference for context optimization strategies
- **learning-capture hook** - Automatic capture of user corrections
- **post-phase-learning hook** - Trigger learning after Phase 6-7

### Enhanced
- **SKILL.md Commands section** - Expanded with learning and feature management commands
- **requirement-interviewer** - Added Task tool for parallel context collection
- **code-explorer** - Added multi-perspective exploration using Task subagents
- **hooks.json** - Added learning hooks and external dependencies config

### Changed
- Renamed `ai-orchestrator` → `ai-dev` for consistency with `/ai:dev` command
- Migrated `claude-reflect` from `bak/` to `skills/` directory
- Updated all internal and external references (~65 files)

### Fixed
- Removed duplicate content in code-explorer.md
- Updated external dependency descriptions in hooks.json

## [3.0.0] - 2025-01-05

### Added
- 7-Phase Gated Workflow
- OODA Autonomous Completion Loop
- 12 specialized agents
- Knowledge management system (patterns.json, errors.json)
- Competitor research integration (Phase 0.5)
- Global constraints enforcement (Kiro Spec alignment)
- Confidence-filtered quality review (≥80)
- Change management with state tracking

### Agents
- requirement-interviewer
- feature-planner
- code-explorer
- code-architect
- task-decomposer
- verification-agent
- quick-fixer
- debugger
- api-helper
- test-automator
- code-reviewer
- confidence-scorer

### References
- 7-phase-workflow.md
- ooda-loop.md
- state-machine-spec.md
- confidence-scoring.md
- knowledge-base-schema.md
- verification-workflow.md
- orchestration-engine.md
- global-constraints-integration.md
- workflow-patterns.md
- agents-registry.md

## [2.0.0] - 2025-01-01

### Added
- Initial orchestration framework
- Basic phase workflow
- Core agents

---

## Version Summary

| Version | Date | Agents | References | Hooks | Commands |
|---------|------|--------|------------|-------|----------|
| 3.2.0 | 2025-01-06 | 15 | 13 | 7 | 12 |
| 3.1.0 | 2025-01-06 | 15 | 13 | 5 | 10 |
| 3.0.0 | 2025-01-05 | 12 | 10 | 3 | 4 |
| 2.0.0 | 2025-01-01 | 5 | 3 | 1 | 2 |
