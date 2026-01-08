# Skill Auditor - Report Format

Detailed report format specifications and output examples.

## Console Output Format

### Full Report

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

### Summary Output (--summary)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Skill Audit Summary - 3 skills
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  ✅ ai-dev           94/100  A   PASS
  ✅ skill-auditor    88/100  B+  PASS
  ⚠️ thinking-engine  72/100  C+  WARN

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Average: 85/100  |  Pass: 2  Warn: 1  Fail: 0
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## JSON Output Format (--json)

```json
{
  "skill": "ai-dev",
  "version": "3.2.0",
  "timestamp": "2025-01-07T22:00:00Z",
  "scores": {
    "structure": {
      "score": 25,
      "max": 25,
      "weight": 0.25,
      "checks": [
        {"name": "skill_md_exists", "passed": true, "points": 10},
        {"name": "valid_frontmatter", "passed": true, "points": 5},
        {"name": "directory_structure", "passed": true, "points": 5},
        {"name": "naming_conventions", "passed": true, "points": 5}
      ]
    },
    "documentation": {
      "score": 23,
      "max": 25,
      "weight": 0.25,
      "checks": [
        {"name": "description_quality", "passed": true, "points": 10},
        {"name": "usage_examples", "passed": true, "points": 7},
        {"name": "feature_documentation", "passed": true, "points": 5},
        {"name": "bilingual_support", "passed": false, "points": 0}
      ]
    },
    "discoverability": {
      "score": 18,
      "max": 20,
      "weight": 0.20
    },
    "maintainability": {
      "score": 15,
      "max": 15,
      "weight": 0.15
    },
    "integration": {
      "score": 13,
      "max": 15,
      "weight": 0.15
    }
  },
  "total": {
    "score": 94,
    "max": 100,
    "grade": "A",
    "status": "PRODUCTION_READY"
  },
  "issues": [
    {
      "severity": "warning",
      "code": "W001",
      "message": "Missing CHANGELOG.md",
      "suggestion": "Add version history tracking"
    },
    {
      "severity": "info",
      "code": "I002",
      "message": "Consider more trigger phrases",
      "suggestion": "Add synonyms: validate, verify, check"
    }
  ]
}
```

## Markdown Report Format (--report)

Generate with `/ai:skills-audit --report` or programmatically.

```markdown
# Skill Audit Report

**Generated**: 2025-01-07 22:00:00
**Skills Audited**: 3

## Summary

| Skill | Score | Grade | Status |
|-------|-------|-------|--------|
| ai-dev | 94/100 | A | ✅ Production Ready |
| skill-auditor | 88/100 | B+ | ✅ Good |
| thinking-engine | 72/100 | C+ | ⚠️ Needs Work |

**Average Score**: 85/100

## Detailed Results

### ai-dev (94/100 - Grade A)

| Dimension | Score | Status |
|-----------|-------|--------|
| Structure | 25/25 | ✅ |
| Documentation | 23/25 | ✅ |
| Discoverability | 18/20 | ✅ |
| Maintainability | 15/15 | ✅ |
| Integration | 13/15 | ✅ |

**Issues**:
- ⚠️ Missing CHANGELOG.md
- ℹ️ Consider more trigger phrases

### skill-auditor (88/100 - Grade B+)

...
```

## Issue Severity Icons

| Severity | Icon | Color | Description |
|----------|------|-------|-------------|
| CRITICAL | 🚨 | Red | Skill unusable, must fix |
| ERROR | ❌ | Red | Significant issue |
| WARNING | ⚠️ | Yellow | Non-compliant but usable |
| INFO | ℹ️ | Blue | Optimization suggestion |

## Grade Status Labels

| Grade | Score Range | Status Label |
|-------|-------------|--------------|
| A | 90-100 | PRODUCTION READY |
| B+ | 85-89 | VERY GOOD |
| B | 80-84 | GOOD |
| C+ | 75-79 | ACCEPTABLE |
| C | 70-74 | NEEDS WORK |
| D | 60-69 | POOR |
| F | <60 | FAILING |
