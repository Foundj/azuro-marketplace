# Plugin Auditor - Scoring Rules

Detailed scoring dimensions and calculation methodology for plugin validation.

## Scoring Formula

```
Total Score = Σ (Dimension Score)
```

Max Score: 100

---

## Dimension 1: Structure (20 points)

Validates file layout and directory organization.

| Check | Points | Criteria |
|-------|--------|----------|
| Manifest location | 10 | `.claude-plugin/plugin.json` exists |
| Component nesting | 5 | Components (commands/, etc.) are at root, not nested |
| Naming convention | 5 | Kebab-case naming for root directory |

---

## Dimension 2: Manifest (20 points)

Validates `plugin.json` content.

| Check | Points | Criteria |
|-------|--------|----------|
| JSON Syntax | 5 | Valid JSON format |
| Required Fields | 10 | `name` and `version` present |
| Metadata | 5 | `description`, `author`, `license` present |

---

## Dimension 3: Components (30 points)

Validates specific component specifications.

| Component | Points | Criteria |
|-----------|--------|----------|
| Commands | 10 | Frontmatter has `description` and `argument-hint` |
| Agents | 10 | Frontmatter has `name`, `description` |
| Hooks | 10 | `hooks.json` has valid event names |

*Note: Component scores are deducted for issues found.*

---

## Dimension 4: Safety (15 points)

Validates security best practices.

| Check | Points | Criteria |
|-------|--------|----------|
| Path Safety | 10 | No hardcoded absolute paths (`/Users/`, `/home/`) |
| Permissions | 5 | Scripts in `scripts/` are executable |

---

## Dimension 5: Skills (15 points)

Validates embedded skills integrity.

**Calculation:**
Recursively calls `skill-auditor` on each embedded skill.
- Score = (Passed Skills / Total Skills) * 15
- Pass criteria: Grade A or B from skill-auditor

---

## Grade Mapping

| Score Range | Grade | Description |
|-------------|-------|-------------|
| 90-100 | A | Production Ready |
| 80-89 | B | Good |
| 70-79 | C | Acceptable |
| <70 | D/F | Needs Improvement |
