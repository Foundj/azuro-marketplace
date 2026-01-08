# Skill Auditor - Configuration

Customization options and configuration examples.

## Project Configuration

Customize audit behavior in `.claude-project/config.json`:

```json
{
  "skill_auditor": {
    "thresholds": {
      "pass": 80,
      "warn": 70,
      "fail": 60
    },
    "rules": {
      "require_changelog": false,
      "require_bilingual": false,
      "min_description_length": 50,
      "max_skill_md_words": 3000
    },
    "ignore": [
      "deprecated-skill",
      "experimental/*"
    ]
  }
}
```

## Configuration Options

### Thresholds

| Option | Default | Description |
|--------|---------|-------------|
| `pass` | 80 | Minimum score for passing |
| `warn` | 70 | Score below this triggers warning |
| `fail` | 60 | Score below this is failing |

### Rules

| Option | Default | Description |
|--------|---------|-------------|
| `require_changelog` | false | Require CHANGELOG.md file |
| `require_bilingual` | false | Require Chinese + English triggers |
| `min_description_length` | 50 | Minimum description characters |
| `max_skill_md_words` | 3000 | Maximum SKILL.md word count |

### Ignore Patterns

Exclude skills from auditing:

```json
{
  "skill_auditor": {
    "ignore": [
      "deprecated-skill",
      "experimental/*",
      "*-wip"
    ]
  }
}
```

## Custom Weight Configuration

Override default dimension weights:

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

**Note:** Weights must sum to 100.

## Per-Skill Overrides

Override settings for specific skills in `.claude-project/skills.json`:

```json
{
  "skills": {
    "legacy-skill": {
      "max_skill_md_words": 5000,
      "require_changelog": false
    },
    "new-skill": {
      "require_bilingual": true
    }
  }
}
```

## Environment Variables

| Variable | Description |
|----------|-------------|
| `SKILL_AUDIT_THRESHOLD` | Override pass threshold |
| `SKILL_AUDIT_VERBOSE` | Enable verbose output |
| `SKILL_AUDIT_FORMAT` | Output format: text, json, markdown |

Example:

```bash
SKILL_AUDIT_THRESHOLD=85 /ai:skills-audit
SKILL_AUDIT_FORMAT=json /ai:skills-audit
```

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Skill Quality Gate
on: [push, pull_request]

jobs:
  audit:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Audit Skills
        run: |
          for skill in skills/*/; do
            ./skills/skill-auditor/scripts/validate-skill.sh "$skill"
          done
```

### Pre-commit Hook

```bash
#!/bin/bash
# .git/hooks/pre-commit

for skill in skills/*/; do
    if ! ./skills/skill-auditor/scripts/validate-skill.sh "$skill"; then
        echo "Skill audit failed for: $skill"
        exit 1
    fi
done
```

## Default Configuration

If no configuration file exists, these defaults apply:

```json
{
  "skill_auditor": {
    "thresholds": {
      "pass": 80,
      "warn": 70,
      "fail": 60
    },
    "weights": {
      "structure": 25,
      "documentation": 25,
      "discoverability": 20,
      "maintainability": 15,
      "integration": 15
    },
    "rules": {
      "require_changelog": false,
      "require_bilingual": false,
      "min_description_length": 50,
      "max_skill_md_words": 3000
    },
    "ignore": []
  }
}
```
