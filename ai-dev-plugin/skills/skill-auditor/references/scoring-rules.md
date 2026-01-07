# Skill Auditor - Scoring Rules

Detailed scoring dimensions, point allocation, and calculation methodology.

## Scoring Formula

```
Total Score = Σ (Dimension Score × Weight)
```

Each dimension is scored independently, then weighted to produce the final score.

---

## Dimension 1: Structure (25 points, 25% weight)

Validates physical skill structure and required files.

### Point Allocation

| Check | Points | Criteria |
|-------|--------|----------|
| SKILL.md exists | 10 | Required file present |
| Valid frontmatter | 5 | YAML block with `name` and `description` |
| Directory structure | 5 | Proper organization (references/, scripts/, etc.) |
| Naming conventions | 5 | kebab-case, no special characters |

### Validation Commands

```bash
# Check SKILL.md exists
test -f SKILL.md && echo "PASS: 10 pts" || echo "FAIL: 0 pts"

# Validate frontmatter
head -50 SKILL.md | grep -q "^---" && echo "Has frontmatter"

# Check name field
grep -E "^name:" SKILL.md && echo "Has name field"

# Check description field  
grep -E "^description:" SKILL.md && echo "Has description field"

# Validate naming (kebab-case)
basename "$(pwd)" | grep -qE "^[a-z0-9]+(-[a-z0-9]+)*$" && echo "Valid naming"
```

### Scoring Logic

```
structure_score = 0

if SKILL.md exists:
    structure_score += 10
    
    if has_valid_frontmatter:
        structure_score += 5
    
if has_proper_directories:
    structure_score += 5
    
if naming_is_kebab_case:
    structure_score += 5
```

---

## Dimension 2: Documentation (25 points, 25% weight)

Evaluates description quality and documentation completeness.

### Point Allocation

| Check | Points | Criteria |
|-------|--------|----------|
| Description quality | 10 | Third-person, 50+ chars, specific triggers |
| Usage examples | 7 | Code blocks with examples |
| Feature documentation | 5 | Clear capability listing |
| Bilingual support | 3 | Chinese and English triggers |

### Description Quality Rubric

| Score | Criteria |
|-------|----------|
| 10/10 | Third-person, specific triggers, concrete scenarios, 100+ chars |
| 7/10 | Third-person, some triggers, 50+ chars |
| 4/10 | Has content but wrong format or vague |
| 0/10 | Empty or minimal description |

**Third-person pattern detection:**
```bash
grep -qE "This skill (should|can|is|provides|enables)" SKILL.md
```

**Trigger phrase detection:**
```bash
grep -qiE "(trigger|when.*user.*asks|should be used when)" SKILL.md
```

### Usage Examples Rubric

| Score | Criteria |
|-------|----------|
| 7/7 | Multiple code blocks, diverse examples |
| 5/7 | At least one code block |
| 2/7 | Examples mentioned but no code |
| 0/7 | No examples |

---

## Dimension 3: Discoverability (20 points, 20% weight)

Measures how easily the skill triggers on relevant user queries.

### Point Allocation

| Check | Points | Criteria |
|-------|--------|----------|
| Trigger phrases defined | 8 | Explicit triggers in description |
| Multilingual triggers | 5 | Chinese and English support |
| Command binding | 4 | Associated slash commands |
| Synonym coverage | 3 | Common alternative phrases |

### Trigger Quality Assessment

**Strong triggers (8/8):**
```yaml
description: |
  This skill should be used when the user asks to "create hook", 
  "add PreToolUse hook", "validate tool", or mentions hook events.
```

**Weak triggers (3/8):**
```yaml
description: Helps with hook development.
```

### Multilingual Detection

```bash
# Check for Chinese characters
grep -qP "[\x{4e00}-\x{9fff}]" SKILL.md && echo "Has Chinese"

# Check for English triggers
grep -qiE "(trigger|when|use)" SKILL.md && echo "Has English triggers"
```

---

## Dimension 4: Maintainability (15 points, 15% weight)

Assesses long-term maintenance characteristics.

### Point Allocation

| Check | Points | Criteria |
|-------|--------|----------|
| Semantic version | 5 | version: X.Y.Z in frontmatter |
| Dependency declaration | 4 | Dependencies listed |
| Executable scripts | 3 | Scripts have +x permission |
| Changelog | 3 | Version history (bonus) |

### Version Validation

```bash
# Check for semantic version
grep -qE "^version: [0-9]+\.[0-9]+\.[0-9]+" SKILL.md && echo "Valid semver"
```

### Script Permissions

```bash
# Check all scripts are executable
for script in scripts/*; do
    test -x "$script" || echo "Not executable: $script"
done
```

---

## Dimension 5: Integration (15 points, 15% weight)

Measures workflow integration and collaboration capabilities.

### Point Allocation

| Check | Points | Criteria |
|-------|--------|----------|
| Workflow integration | 6 | Integrates with ai-dev or similar |
| Hook configuration | 5 | Automatic trigger mechanisms |
| Agent collaboration | 4 | Works with specialized agents |

### Integration Detection

```bash
# Check for workflow mentions
grep -qiE "(ai-dev|workflow|phase|hook)" SKILL.md && echo "Workflow integrated"

# Check for agent mentions
grep -qiE "(agent|delegate|collaborate)" SKILL.md && echo "Agent aware"
```

---

## Grade Calculation

### Final Score Formula

```python
final_score = (
    structure_score * 0.25 +
    documentation_score * 0.25 +
    discoverability_score * 0.20 +
    maintainability_score * 0.15 +
    integration_score * 0.15
)
```

### Grade Mapping

| Score Range | Grade | Description | Action |
|-------------|-------|-------------|--------|
| 90-100 | A | Excellent | Production ready |
| 85-89 | A- | Very Good | Minor polish needed |
| 80-84 | B+ | Good | Few improvements |
| 75-79 | B | Satisfactory | Some work needed |
| 70-74 | C+ | Acceptable | Notable gaps |
| 65-69 | C | Below Average | Significant work |
| 60-64 | D | Poor | Major issues |
| <60 | F | Failing | Fundamental problems |

---

## Issue Severity Classification

### CRITICAL (Blocking)

Issues that prevent skill from functioning:

- SKILL.md file missing
- Frontmatter completely absent
- Frontmatter parse errors
- No name field

**Action required:** Must fix before skill can be used.

### ERROR (Major)

Issues that significantly impair functionality:

- Empty or minimal description (<20 chars)
- No markdown body content
- Missing required fields
- Broken file references

**Action required:** Should fix before deployment.

### WARNING (Minor)

Issues that reduce quality but don't break functionality:

- Description not in third-person
- Missing version number
- No usage examples
- Scripts without execute permission
- Missing trigger phrases

**Action required:** Recommended to fix.

### INFO (Suggestion)

Optimization opportunities:

- Could add more trigger phrases
- Consider bilingual support
- Add integration with workflows
- Include changelog

**Action required:** Nice to have.

---

## Scoring Examples

### Example 1: High-Quality Skill (Score: 94/100)

```
Structure:      25/25 (all checks pass)
Documentation:  23/25 (excellent description, examples)
Discoverability: 18/20 (strong triggers, some synonyms missing)
Maintainability: 15/15 (versioned, scripts executable)
Integration:    13/15 (workflow integrated, no hooks)

Total: 94 → Grade A
```

### Example 2: Basic Skill (Score: 72/100)

```
Structure:      20/25 (SKILL.md exists, weak organization)
Documentation:  15/25 (description present but vague)
Discoverability: 12/20 (few triggers, English only)
Maintainability: 12/15 (no changelog)
Integration:    13/15 (minimal workflow mention)

Total: 72 → Grade C+
```

### Example 3: Failing Skill (Score: 45/100)

```
Structure:      15/25 (no proper directories)
Documentation:   8/25 (minimal description)
Discoverability:  5/20 (no triggers defined)
Maintainability:  7/15 (no version, no deps)
Integration:     10/15 (basic mentions)

Total: 45 → Grade F
```

---

## Custom Weight Configuration

Override default weights in project config:

```json
{
  "skill_auditor": {
    "weights": {
      "structure": 30,
      "documentation": 30,
      "discoverability": 15,
      "maintainability": 15,
      "integration": 10
    }
  }
}
```

Weights must sum to 100.

---

## Automated Scoring Script

See `scripts/validate-skill.sh` for automated scoring implementation.

Usage:
```bash
./scripts/validate-skill.sh /path/to/skill
```

Output:
```
Validating skill: my-skill
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Structure:      25/25 ✅
Documentation:  22/25 ✅
Discoverability: 16/20 ⚠️
Maintainability: 15/15 ✅
Integration:    12/15 ✅
━━━━━━━━━━━━━━━━━━━━━━━━━━━━
TOTAL: 90/100 (Grade: A)
```
