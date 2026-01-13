---
name: ai:skills-audit
description: Audit all skills in project - validate structure, quality, and best practices compliance
argument-hint: "[--summary] [--fix] [--report] [--json] [--background]"
allowed-tools: Read, Bash, Glob, Grep, Task
execution-mode: subagent
---

# /ai:skills-audit - 技能质量审计

Audit all skills in the current project for quality and best practices compliance.

---

## Execution Mode

This command can run as a **subagent** to preserve main session context.

```
/ai:skills-audit --background
    ↓
Launch Task tool with subagent:
  - run_in_background: true
  - Isolated context execution
    ↓
Subagent executes:
  - Locate all SKILL.md files
  - Run validation script for each
  - Aggregate results
    ↓
Returns Audit Report to main session
```

**Advantage**: Auditing many skills does not block main session.

---

## Usage
```bash
/ai:skills-audit
/ai:skills-audit --background  # Run in background
```

## Options

- `--summary`: Output only the summary scores, skip detailed checks
- `--fix`: Auto-fix simple issues (script permissions, missing version)
- `--report`: Generate detailed Markdown report file
- `--json`: Output results in JSON format
- `--background`: Run in background, return immediately

---

## Execution Steps

### Step 1: Locate All Skills

Find all skill directories in the project:

```bash
find . -name "SKILL.md" -type f 2>/dev/null | while read skillmd; do
    dirname "$skillmd"
done
```

### Step 2: Run Validation Script

For each skill found, run the validation script:

```bash
SCRIPT_PATH="skills/skill-auditor/scripts/validate-skill.sh"

if [[ -x "$SCRIPT_PATH" ]]; then
    for skill_dir in $(find . -name "SKILL.md" -type f -exec dirname {} \;); do
        echo "Auditing: $skill_dir"
        bash "$SCRIPT_PATH" "$skill_dir"
        echo ""
    done
else
    echo "Validation script not found or not executable"
fi
```

### Step 3: Aggregate Results

Collect scores from all skills:

| Skill | Score | Grade | Status |
|-------|-------|-------|--------|
| skill-name | XX/100 | A-F | PASS/WARN/FAIL |

### Step 4: Generate Summary

```
╔════════════════════════════════════════════════════════════╗
║                 PROJECT SKILL AUDIT SUMMARY                 ║
╠════════════════════════════════════════════════════════════╣
║  Skills Audited: X                                          ║
║  Passed (≥70): X                                            ║
║  Warnings (60-69): X                                        ║
║  Failed (<60): X                                            ║
║                                                              ║
║  Average Score: XX/100                                       ║
║  Overall Grade: X                                            ║
╚════════════════════════════════════════════════════════════╝
```

---

## Auto-Fix (--fix)

When `--fix` is specified, automatically resolve:

- ✅ Script execution permissions (`chmod +x`)
- ✅ Missing version field (add `version: 1.0.0`)
- ✅ Frontmatter formatting issues

---

## Report Output (--report)

Generate `skill-audit-report.md` with:

1. Executive summary
2. Per-skill detailed scores
3. Issues by severity
4. Recommendations

---

## Usage Examples

```bash
# Audit all skills in project
/ai:skills-audit

# Quick summary only
/ai:skills-audit --summary

# Auto-fix simple issues
/ai:skills-audit --fix

# Generate report file
/ai:skills-audit --report

# JSON output for CI/CD
/ai:skills-audit --json
```

---

## Integration

Use with quality-gate workflow:

```yaml
quality_checks:
  - /ai:skills-audit      # Check skill quality first
  - /ai:quality           # Then check code quality
```

---

## Scoring Reference

| Score | Grade | Description |
|-------|-------|-------------|
| 90-100 | A | Production Ready |
| 80-89 | B | Good |
| 70-79 | C | Acceptable |
| 60-69 | D | Poor |
| <60 | F | Failing |

For detailed scoring rules, see `skills/skill-auditor/references/scoring-rules.md`.
