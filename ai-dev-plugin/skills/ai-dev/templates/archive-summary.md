# Change Summary: {{change_id}}

## Overview

| Field | Value |
|-------|-------|
| **Title** | {{title}} |
| **Change ID** | {{change_id}} |
| **Created** | {{created_date}} |
| **Completed** | {{completed_date}} |
| **Duration** | {{duration}} |
| **OODA Iterations** | {{ooda_count}} |

## Files Changed

| File | Action | Lines Changed |
|------|--------|---------------|
{{#files}}
| `{{path}}` | {{action}} | +{{added}}, -{{removed}} |
{{/files}}

## Key Decisions

{{#decisions}}
### {{number}}. {{title}}

- **Context**: {{context}}
- **Decision**: {{decision}}
- **Rationale**: {{rationale}}
- **Consequences**: {{consequences}}

{{/decisions}}

## Patterns Identified

{{#patterns}}
### {{name}}

- **Context**: {{context}}
- **Problem**: {{problem}}
- **Solution**: {{solution}}
- **Example**:
```{{language}}
{{example}}
```

{{/patterns}}

## Learnings

{{#learnings}}
- {{insight}}
{{/learnings}}

## Metrics

| Metric | Value |
|--------|-------|
| OODA Iterations | {{ooda_count}} |
| Files Modified | {{files_count}} |
| Lines Added | {{lines_added}} |
| Lines Removed | {{lines_removed}} |
| Tests Added | {{tests_added}} |
| Test Coverage Delta | {{coverage_delta}} |

## References

- **Proposal**: [proposal.md](./proposal.md)
- **State**: [state.json](./state.json)
- **Decision Log**: [decision-log.md](./decision-log.md)
{{#related_changes}}
- **Related**: [{{id}}]({{link}})
{{/related_changes}}

## Notes

{{notes}}

---
_Generated: {{generated_date}}_
_Archived to: {{archive_path}}_
