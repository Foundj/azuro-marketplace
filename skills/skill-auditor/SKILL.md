---
name: skill-auditor
description: |
  Audit Claude Code skills against best practices.
  Provides quality scoring, issue detection, and optimization guidance.
version: 4.2.10
---

# Skill Auditor

Quality gate system ensuring skills meet production standards.

## Overview

Skill Auditor validates Claude Code skills against best practices:

- **Quality Scoring** - 0-100 score across 5 weighted dimensions
- **Issue Detection** - Automatic problem identification with severity levels
- **Optimization Guidance** - Specific, actionable improvement recommendations

## Scoring Dimensions

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
| 80-89 | B | Good |
| 70-79 | C | Acceptable |
| <70 | D/F | Needs Work |

For detailed scoring rules, see `references/scoring-rules.md`.

---

## Audit Process

### Step 1: Locate Skills

Scan project for skill directories:

```bash
find . -name "SKILL.md" -type f
```

### Step 2: Validate Structure

Check required elements:

1. **SKILL.md exists** - Required file
2. **Valid frontmatter** - YAML with `name` and `description`
3. **Directory naming** - kebab-case, no special characters

### Step 3: Assess Description Quality

Evaluate frontmatter description:

- **Third-person format**: "This skill should be used when..."
- **Trigger phrases**: Specific user queries listed
- **Length**: 50+ characters with concrete scenarios

**Good:**
```yaml
description: |
  This skill should be used when the user asks to "create a hook", 
  "add a PreToolUse hook", or mentions hook events.
```

**Bad:**
```yaml
description: Provides hook guidance.  # Too vague
```

### Step 4: Check Content Quality

Evaluate SKILL.md body:

- **Writing style**: Imperative form (not "You should...")
- **Word count**: 1,500-2,000 ideal, max 3,000
- **Progressive disclosure**: Details in references/

### Step 5: Verify Resources

Check bundled resources:

- Scripts are executable
- All files referenced in SKILL.md
- No orphan files

### Step 6: Score and Report

Calculate weighted score, identify issues, generate report.

---

## Issue Severity

| Level | Icon | Impact |
|-------|------|--------|
| CRITICAL | 🚨 | Skill unusable |
| ERROR | ❌ | Functionality broken |
| WARNING | ⚠️ | Usable but non-compliant |
| INFO | ℹ️ | Optimization opportunity |

---

## Auto-Fix Capabilities

The `--fix` flag can automatically resolve:

- ✅ Script execution permissions
- ✅ Missing version field
- ✅ Frontmatter formatting

Manual intervention required:
- ❌ Description content quality
- ❌ Writing style corrections

---

## Workflow Integration

```
Phase 0 (Pre-check)  → Validate related skills
Phase 5 (Quality)    → Validate newly created skills
Phase 6 (Archive)    → Final validation
```

---

## Additional Resources

### Reference Files

- **`references/scoring-rules.md`** - Detailed scoring dimensions and calculation
- **`references/best-practices.md`** - Validation checklist, common mistakes
- **`references/report-format.md`** - Output format specifications
- **`references/configuration.md`** - Customization options

### Utility Scripts

- **`scripts/validate-skill.sh`** - Automated validation script

Usage:
```bash
./scripts/validate-skill.sh /path/to/skill
```

---

## Dependencies

- `bash` - Script execution
- `grep` - Text search
- `jq` - JSON processing (optional)
