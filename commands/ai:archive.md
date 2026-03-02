---
name: ai:archive
description: Smartly archive completed changes, update knowledge base and generate summaries
argument-hint: "[change_id] [--current] [--all-completed]"
allowed-tools: Task, Read, Write, Edit, Grep, Glob, Bash
internal: true
---

# /ai:archive - Smart Change Archival Command

## Overview
Intelligently archives completed changes with comprehensive summary generation,
knowledge base updates, and documentation synchronization.

## Usage
```
/ai:archive [change_id] [options]
```

## Arguments
| Argument | Description |
|----------|-------------|
| `change_id` | Specific change ID to archive (e.g., CHG-20250106-001) |

## Options
| Option | Description |
|--------|-------------|
| `--current` | Archive the current active change in context |
| `--all-completed` | Archive all changes with completion_promise=DONE |
| `--force` | Skip validation checks (tests, build) |
| `--dry-run` | Show what would be archived without executing |
| `--no-summary` | Skip SUMMARY.md generation |
| `--no-index-update` | Skip feature-index.json update |

## Behavior

### 1. Smart Detection
```
Priority order:
1. Explicit change_id → archive that change
2. --current → detect from .agent/changes/active/
3. --all-completed → scan for all DONE changes
4. Interactive → list and select from active changes
```

### 2. Pre-Archive Validation
```yaml
validation_checks:
  required:
    - completion_promise: "must be DONE"
    - state.implementationComplete: "must be true"
  
  recommended:
    - related_tests: "should pass"
    - build_status: "should be clean"
    - lint_status: "should have no errors"
  
  skip_with_force:
    - All recommended checks can be skipped with --force
    - Required checks need --force to skip
```

### 3. Archive Process
```
┌─────────────────────────────────────────────────────────────┐
│                    Archive Workflow                          │
├─────────────────────────────────────────────────────────────┤
│  1. Validate Change                                          │
│     ├─ Check completion status                               │
│     ├─ Run related tests (unless --force)                    │
│     └─ Verify build clean (unless --force)                   │
│                                                              │
│  2. Generate Summary                                         │
│     ├─ Extract file changes from git                         │
│     ├─ Collect decisions from decision-log.md                │
│     ├─ Identify patterns from implementation                 │
│     └─ Compile learnings and insights                        │
│                                                              │
│  3. Update Knowledge Base                                    │
│     ├─ Append to learnings.md                                │
│     ├─ Update patterns.json with new patterns                │
│     └─ Update feature-index.json                             │
│                                                              │
│  4. Move to Archive                                          │
│     ├─ .agent/changes/active/{id}/                          │
│     └─ → .agent/changes/archived/{YYYY-MM}/{id}/            │
│                                                              │
│  5. Prompt Documentation Update                              │
│     └─ Detect if README/docs need updates                    │
└─────────────────────────────────────────────────────────────┘
```

### 4. Summary Generation (SUMMARY.md)
```markdown
# Change Summary: {change_id}

## Overview
- **Title**: {from proposal}
- **Completed**: {date}
- **Duration**: {start to end}
- **OODA Iterations**: {count}

## Files Changed
| File | Action | Lines |
|------|--------|-------|
| src/auth.ts | Modified | +45, -12 |

## Key Decisions
1. {decision from decision-log}
2. {decision}

## Patterns Identified
- Pattern: {name}
  - Context: {when to use}
  - Implementation: {how}

## Learnings
- {insight gained}
- {what worked well}
- {what to improve}

## References
- Related changes: {links}
- Documentation: {links}
```

### 5. Knowledge Base Updates
```yaml
updates:
  learnings.md:
    - Append change summary
    - Record OODA iterations
    - Document key insights
  
  patterns.json:
    - Add new patterns discovered
    - Link to source change
    - Include usage context
  
  feature-index.json:
    - Add feature entry
    - Map to files
    - Record dependencies
```

## Examples

### Archive Current Change
```
/ai:archive --current
```
Archives the change currently being worked on.

### Archive Specific Change
```
/ai:archive CHG-20250106-001
```
Archives the specified change after validation.

### Archive All Completed
```
/ai:archive --all-completed
```
Finds and archives all changes marked as DONE.

### Dry Run
```
/ai:archive --all-completed --dry-run
```
Shows what would be archived without making changes.

### Force Archive
```
/ai:archive CHG-20250106-001 --force
```
Archives even if tests fail or build has warnings.

## Integration Points

### Phase 6 Auto-Archive
When Phase 6 (Release) completes successfully, automatically calls:
```
/ai:archive --current
```

### Manual Archive
Available any time via:
```
/ai:archive [change_id]
/ai:feature-archive [change_id]  # alias
```

## Output

### Success
```
📦 Archive: Validating CHG-20250106-001...
✅ Completion status: DONE
✅ Related tests: 12/12 passed
✅ Build: clean

📦 Archive: Generating summary...
📝 Created: SUMMARY.md

📦 Archive: Updating knowledge base...
📚 Updated: learnings.md
📊 Updated: patterns.json (2 new patterns)
🗂️ Updated: feature-index.json

📦 Archive: Moving to archive...
✅ Archived: CHG-20250106-001 → archived/2025-01/CHG-20250106-001/

💡 Documentation Update Suggested:
   README.md may need updates for new feature.
   Run: /ai:docs update README.md
```

### Dry Run
```
📦 Archive: [DRY RUN] Would archive:
   - CHG-20250106-001 (auth-refactor)
   - CHG-20250105-002 (api-optimization)
   
   Changes to knowledge base:
   - learnings.md: +2 entries
   - patterns.json: +3 patterns
   - feature-index.json: +2 features
```

## Related Commands
- `/ai:check` - Pre-implementation check
- `/ai:status` - View change status
- `/ai:dev` - Full development workflow
- `/ai:update-feature-index` - Manual index update

## Aliases
- `/ai:feature-archive` - Same as /ai:archive
