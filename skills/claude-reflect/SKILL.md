---
name: claude-reflect
description: |
  This skill provides comprehensive CLAUDE.md and AGENTS.md management with quality auditing,
  template support, and self-learning from user corrections. Use when the user mentions
  "reflect", "audit CLAUDE.md", "improve context", "remember this", "更新规则", "审计文档",
  "质量检查", or when reviewing/updating project context files.
  Combines automatic learning capture with quality-based context optimization.
version: 5.1.4
triggers:
  - reflect
  - remember this
  - learn from this
  - update rules
  - audit claude md
  - audit agents md
  - improve context
  - 更新规则
  - 记住这个
  - 反思
  - 审计文档
  - 质量检查
---

# Claude Reflect - Context Management System

Comprehensive CLAUDE.md and AGENTS.md management with quality auditing and self-learning.

## 触发词

此技能触发于: "reflect", "remember this", "audit CLAUDE.md", "更新规则", "审计文档", "质量检查".

## Core Capabilities

| Capability | Commands | Purpose |
|------------|---------|---------|
| **Quality Audit** | `/audit-claude-md` | Score context files against 6 criteria |
| **Self-Learning** | `/reflect` | Capture corrections and sync to files |
| **Template Support** | References | Project templates for CLAUDE.md/AGENTS.md |
| **Deduplication** | `/reflect --dedupe` | Consolidate similar entries |

## Quick Start

```bash
# Audit context files for quality
/audit-claude-md

# Process queued learnings
/reflect

# View pending learnings
/view-queue

# Skip current learnings
/skip-reflect
```

## Stage 1: Quality Audit

Audit CLAUDE.md and AGENTS.md files against quality criteria.

### Scoring Rubric (100 points)

| Criterion | Weight | Focus |
|-----------|--------|-------|
| Commands/workflows | 20 | Are build/test/deploy commands present? |
| Architecture clarity | 20 | Can Claude understand the codebase structure? |
| Non-obvious patterns | 15 | Are gotchas and quirks documented? |
| Conciseness | 15 | No verbose explanations or obvious info? |
| Currency | 15 | Does it reflect current codebase state? |
| Actionability | 15 | Are instructions executable, not vague? |

### Quality Grades

| Grade | Score | Description |
|-------|-------|-------------|
| A | 90-100 | Comprehensive, current, actionable |
| B | 70-89 | Good coverage, minor gaps |
| C | 50-69 | Basic info, missing key sections |
| D | 30-49 | Sparse or outdated |
| F | 0-29 | Missing or severely outdated |

See [references/quality-criteria.md](references/quality-criteria.md) for detailed rubrics.

## Stage 2: Self-Learning (Automatic Capture)

### Detection Patterns

High-confidence corrections:
- Tool rejections (user stops an action with guidance)
- "no, use X" / "don't use Y"
- "actually..." / "I meant..."
- "use X not Y" / "X instead of Y"
- "remember:" (explicit marker)
- "perfect!" / "exactly right" (positive reinforcement)

### Target File Selection

| Correction Type | Target File |
|----------------|-------------|
| Build/test commands | CLAUDE.md |
| Code style preferences | CLAUDE.md |
| Project-specific patterns | CLAUDE.md |
| Agent behavior rules | AGENTS.md |
| Tool usage patterns | AGENTS.md |
| Workflow preferences | AGENTS.md |
| General corrections | ~/.claude/CLAUDE.md |

## File Types & Locations

| Type | Location | Purpose |
|------|----------|---------|
| CLAUDE.md | Project root | Team-shared project context (git tracked) |
| AGENTS.md | Project root | Agent behavior instructions (git tracked) |
| .claude.local.md | Project root | Personal/local settings (gitignored) |
| ~/.claude/CLAUDE.md | Home | User-wide defaults |

## Available Commands

| Command | Purpose |
|---------|---------|
| `/audit-claude-md` | Quality audit of all context files |
| `/reflect` | Process queued learnings with human review |
| `/reflect --scan-history` | Scan past sessions for missed learnings |
| `/reflect --dry-run` | Preview changes without applying |
| `/reflect --dedupe` | Find and consolidate similar entries |
| `/skip-reflect` | Discard all queued learnings |
| `/view-queue` | View pending learnings without processing |

## Update Guidelines

### What TO Add

1. **Commands/Workflows Discovered** - Saves future discovery time
2. **Gotchas and Non-Obvious Patterns** - Prevents repeated debugging
3. **Package/Module Relationships** - Architecture knowledge
4. **Testing Approaches That Worked** - Established patterns
5. **Configuration Quirks** - Environment-specific knowledge
6. **Agent Behavior Learnings** - Workflow preferences

### What NOT to Add

1. **Obvious Code Info** - Already clear from code
2. **Generic Best Practices** - Universal advice, not project-specific
3. **One-Off Fixes** - Won't recur, clutters file
4. **Verbose Explanations** - One line per concept when possible

See [references/update-guidelines.md](references/update-guidelines.md) for details.

## Templates

See [references/templates.md](references/templates.md) for:
- CLAUDE.md Templates (Minimal, Comprehensive, Package, Monorepo)
- AGENTS.md Templates (Minimal, Full, Multi-Agent)

## Example Interaction

```
User: no, use gpt-5.1 not gpt-5 for reasoning tasks
Claude: Got it, I'll use gpt-5.1 for reasoning tasks.

[Hook captures this correction to queue]

User: /reflect
Claude: Found 1 learning queued. "Use gpt-5.1 for reasoning tasks"
       Scope: global
       Apply to ~/.claude/CLAUDE.md? [y/n]
```

## Quality Audit Workflow

```
User: /audit-claude-md
Claude: ## Context Files Quality Report

       ### Summary
       - Files found: 2
       - Average score: 75/100
       - Files needing update: 1

       ### ./CLAUDE.md (Grade: B)
       | Criterion | Score | Notes |
       |-----------|-------|-------|
       | Commands | 18/20 | Missing deploy command |
       | Architecture | 15/20 | Outdated structure |
       | ...

       **Recommended additions:**
       - Add `npm run deploy` command
       - Update directory structure
```

## Prerequisites & Dependencies

- Python 3.6+
- `jq` for JSON processing
- Git (for post-commit hooks)
- Claude Code CLI

## Workflow Integration

| Workflow Phase | Integration |
|----------------|------------|
| ai-dev Phase 0 | Audit CLAUDE.md before starting |
| ai-dev Phase 5 | Capture learnings during review |
| Post-session | `/reflect` to sync learnings |

## Agent Collaboration

| Agent | Role |
|-------|------|
| `ai-dev` | Source of learnings during development |
| `knowledge-graph` | Store patterns in knowledge base |
| `session-manager` | Persist learnings across sessions |

## Version History

| Version | Changes |
|---------|---------|
| 5.2.0 | Added AGENTS.md support, quality audit, templates |
| 5.1.1 | Added Chinese triggers |
| 5.0.0 | Merged claude-md-management best practices |
| 4.0.0 | Initial release with two-stage learning system |

## References

- [quality-criteria.md](references/quality-criteria.md) - 6-dimension scoring rubric
- [templates.md](references/templates.md) - Project templates for CLAUDE.md/AGENTS.md
- [update-guidelines.md](references/update-guidelines.md) - DO/DON'T for updates