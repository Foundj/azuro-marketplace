---
name: skill-auditor
description: |
  This skill should be used when the user asks to "audit skill", "validate skill", "check skill quality", 
  "review skill structure", "skill-check", "verify skill", "score skill", or wants to ensure skills 
  follow Claude Code best practices. Provides multi-dimensional quality assessment with scoring, 
  issue detection, and optimization recommendations.
  
  Trigger phrases: audit, validate, check skill, skill quality, skill review, verify skill, skill-audit
version: 1.0.0
---

# Skill Auditor

> Quality gate system ensuring skills meet production standards

## Overview

Skill Auditor validates Claude Code skills against best practices, providing:

- **Quality Scoring**: 0-100 score across 5 dimensions
- **Issue Detection**: Automatic problem identification with severity levels
- **Optimization Guidance**: Specific, actionable improvement recommendations
- **Consistency Assurance**: Uniform skill quality across projects

## Quick Start

### Audit All Skills in Project

```bash
# Scan and audit all skills
/ai:skills-audit

# Summary only
/ai:skills-audit --summary

# Auto-fix simple issues
/ai:skills-audit --fix
```

### Audit Single Skill

```bash
# By name
/ai:skills-audit:one ai-dev

# By path
/ai:skills-audit:one ./path/to/skill
```

### Generate Reports

```bash
# Markdown report
/ai:skills-audit --report

# JSON output
/ai:skills-audit --json
```

---

## Scoring System

Total score calculated from 5 weighted dimensions:

| Dimension | Weight | Focus |
|-----------|--------|-------|
| Structure | 25% | SKILL.md, frontmatter, directories |
| Documentation | 25% | Description quality, examples, clarity |
| Discoverability | 20% | Trigger phrases, bilingual support |
| Maintainability | 15% | Versioning, dependencies, scripts |
| Integration | 15% | Workflow hooks, agent collaboration |

### Grade Scale

| Score | Grade | Status |
|-------|-------|--------|
| 90-100 | A | Production Ready |
| 80-89 | B | Good, minor improvements |
| 70-79 | C | Acceptable, needs work |
| 60-69 | D | Poor, significant issues |
| <60 | F | Fails requirements |

For detailed scoring rules and dimension breakdowns, see `references/scoring-rules.md`.

---

## Audit Process

### Step 1: Locate Skills

Scan project for skill directories:

```bash
find . -name "SKILL.md" -type f
```

Each parent directory containing SKILL.md is a skill.

### Step 2: Validate Structure

Check required elements:

1. **SKILL.md exists** - Required file
2. **Valid frontmatter** - YAML with `name` and `description`
3. **Markdown body** - Instructions present
4. **Directory naming** - kebab-case, no special characters

### Step 3: Assess Description Quality

Evaluate frontmatter description:

- **Third-person format**: "This skill should be used when..."
- **Trigger phrases**: Specific user queries listed
- **Length**: 50+ characters with concrete scenarios
- **Avoid**: Vague statements like "Provides X guidance"

**Good example:**
```yaml
description: |
  This skill should be used when the user asks to "create a hook", 
  "add a PreToolUse hook", "validate tool use", or mentions hook events.
```

**Bad example:**
```yaml
description: Provides hook guidance.  # Too vague, no triggers
```

### Step 4: Check Content Quality

Evaluate SKILL.md body:

- **Writing style**: Imperative/infinitive form (not second person)
- **Word count**: 1,500-2,000 ideal, max 3,000
- **Progressive disclosure**: Details in references/, core in SKILL.md
- **Resource references**: All bundled files documented

### Step 5: Verify Resources

Check bundled resources:

- **references/**: Documentation files exist and are referenced
- **scripts/**: Executable, have proper permissions
- **examples/**: Complete, working code samples
- **No orphans**: All files referenced in SKILL.md

### Step 6: Score and Report

Calculate weighted score, identify issues, generate report.

---

## Issue Severity Levels

| Level | Icon | Impact | Example |
|-------|------|--------|---------|
| CRITICAL | 🚨 | Skill unusable | SKILL.md missing |
| ERROR | ❌ | Functionality broken | Empty description |
| WARNING | ⚠️ | Usable but non-compliant | Missing version |
| INFO | ℹ️ | Optimization opportunity | Add more triggers |

---

## Auto-Fix Capabilities

The `--fix` flag can automatically resolve:

- ✅ Script execution permissions
- ✅ Missing version field (adds 1.0.0)
- ✅ Frontmatter formatting issues
- ⚠️ Directory structure creation (requires confirmation)

Manual intervention required for:

- ❌ Description content quality
- ❌ Writing style corrections
- ❌ Logical/design issues

---

## Report Format

### Console Output

```
╔════════════════════════════════════════════════════════════╗
║                   SKILL AUDIT REPORT                       ║
╠════════════════════════════════════════════════════════════╣
║  Skill: ai-dev                                             ║
║  Version: 3.2.0                                            ║
╠════════════════════════════════════════════════════════════╣
║  DIMENSION          │ SCORE  │ WEIGHT │ STATUS             ║
║  ─────────────────────────────────────────────────────────║
║  📁 Structure       │  25/25 │   25%  │ ✅ A+              ║
║  📝 Documentation   │  23/25 │   25%  │ ✅ A               ║
║  🔍 Discoverability │  18/20 │   20%  │ ✅ A               ║
║  🔧 Maintainability │  15/15 │   15%  │ ✅ A+              ║
║  🔗 Integration     │  13/15 │   15%  │ ✅ A-              ║
╠════════════════════════════════════════════════════════════╣
║  TOTAL: 94/100  │  GRADE: A  │  STATUS: PRODUCTION READY  ║
╚════════════════════════════════════════════════════════════╝

ISSUES: 2

⚠️ [WARNING] Missing CHANGELOG.md
   → Add version history tracking

ℹ️ [INFO] Consider more trigger phrases
   → Add synonyms: validate, verify, check
```

---

## Configuration

Customize audit behavior in `.claude-project/config.json`:

```json
{
  "skill_auditor": {
    "thresholds": {
      "pass": 70,
      "warn": 60
    },
    "rules": {
      "require_changelog": false,
      "min_description_length": 50,
      "max_skill_md_words": 3000
    }
  }
}
```

---

## Integration with Workflow

### With ai-dev Workflow

```
Phase 0 (Pre-check)  → skill-auditor: Validate related skills
Phase 5 (Quality)    → skill-auditor: Validate newly created skills
Phase 6 (Archive)    → skill-auditor: Final validation
```

### With quality-gate

Run skill validation before code quality checks:

```yaml
quality_checks:
  - skill-auditor    # Skill compliance first
  - quality-gate     # Code quality second
```

---

## Additional Resources

### Reference Files

For detailed information, consult:

- **`references/scoring-rules.md`** - Complete scoring dimensions, point allocation, calculation formulas
- **`references/best-practices.md`** - Validation checklist, common mistakes, good/bad examples

### Utility Scripts

- **`scripts/validate-skill.sh`** - Automated structure and frontmatter validation

---

## Dependencies

- `bash` - Script execution
- `grep` - Text search
- `jq` - JSON processing (optional, for --json output)
