# Changelog

All notable changes to Azuro Marketplace will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
