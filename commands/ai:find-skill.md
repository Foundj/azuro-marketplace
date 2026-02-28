---
name: ai:find-skill
description: Search skills by name, keyword, trigger phrase, or status
argument-hint: "<query> [--name|--trigger|--status|--list]"
allowed-tools: Bash
internal: true
---

# Find Skill Command

Search the skill directory by name, keyword, trigger phrase, or status.

## Usage

Parse `$ARGUMENTS` and run the search script:

```bash
bash skills/skill-auditor/scripts/find-skill.sh $ARGUMENTS
```

## Examples

- `/ai:find-skill brainstorm` — Search all fields for "brainstorm"
- `/ai:find-skill --name browser` — Search by skill name only
- `/ai:find-skill --trigger "code review"` — Search trigger phrases
- `/ai:find-skill --status experimental` — Filter by status
- `/ai:find-skill --list` — List all skills with metadata
