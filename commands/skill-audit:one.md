---
description: Audit a single skill by name or path - validate structure, quality, and best practices
argument-hint: <skill-name-or-path> [--fix] [--verbose]
allowed-tools: Read, Bash, Glob
---

# Skill Audit One - 单个技能审计

Audit a single skill for quality and best practices compliance.

## Arguments

- `<skill-name-or-path>`: Skill name (e.g., `ai-dev`) or path (e.g., `./skills/ai-dev`)

## Options

- `--fix`: Auto-fix simple issues
- `--verbose`: Show detailed check output

---

## Execution Steps

### Step 1: Locate Skill

```bash
SKILL_INPUT="$ARGUMENTS"

# Remove options
SKILL_INPUT="${SKILL_INPUT/--fix/}"
SKILL_INPUT="${SKILL_INPUT/--verbose/}"
SKILL_INPUT=$(echo "$SKILL_INPUT" | xargs)

# Check if it's a path
if [[ -d "$SKILL_INPUT" ]]; then
    SKILL_PATH="$SKILL_INPUT"
elif [[ -d "./skills/$SKILL_INPUT" ]]; then
    SKILL_PATH="./skills/$SKILL_INPUT"
elif [[ -d "./skills/$SKILL_INPUT" ]]; then
    SKILL_PATH="./skills/$SKILL_INPUT"
else
    echo "Skill not found: $SKILL_INPUT"
    exit 1
fi
```

### Step 2: Run Validation

```bash
SCRIPT_PATH="skills/skill-auditor/scripts/validate-skill.sh"

if [[ -x "$SCRIPT_PATH" ]]; then
    bash "$SCRIPT_PATH" "$SKILL_PATH"
else
    echo "Validation script not found"
fi
```

### Step 3: Report Results

Display the validation results with scores and issues.

---

## Usage Examples

```bash
# Audit by name
/skill-audit:one ai-dev

# Audit by path
/skill-audit:one ./skills/skill-auditor

# With auto-fix
/skill-audit:one ai-dev --fix

# Verbose output
/skill-audit:one ai-dev --verbose
```

---

## Output Format

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Validating Skill: skill-name
  Path: /path/to/skill
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📁 Structure:       XX/25
📝 Documentation:   XX/25
🔍 Discoverability: XX/20
🔧 Maintainability: XX/15
🔗 Integration:     XX/15

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  TOTAL: XX/100  |  GRADE: X  |  STATUS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```
