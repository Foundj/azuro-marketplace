---
name: ai:update-feature-index
description: Update the feature index that maps features to their implementation files
argument-hint: "[--from-archive] [--from-codebase] [--rebuild]"
allowed-tools: Task, Read, Write, Bash, Grep, Glob
internal: true
---

# /ai:update-feature-index - Update Feature Index

## Overview
Updates the feature index that maps features to their implementation files,
enabling intelligent pre-implementation checks and duplicate detection.

## Usage
```
/ai:update-feature-index [options]
```

## Options
| Option | Description |
|--------|-------------|
| `--from-archive` | Extract features from archived changes |
| `--from-codebase` | Scan codebase for feature indicators |
| `--merge` | Merge new entries with existing index |
| `--rebuild` | Rebuild index from scratch |
| `--dry-run` | Show what would be updated |

## Behavior

### 1. Feature Detection
```yaml
sources:
  archived_changes:
    - Read from .agent/changes/archived/
    - Extract feature names from proposals
    - Map to implementation files
  
  codebase_scan:
    - Detect feature modules (src/features/*)
    - Identify service classes
    - Find API endpoints
    - Locate UI components
  
  documentation:
    - Parse README feature sections
    - Extract from API docs
    - Read from feature specs
```

### 2. Index Structure
```json
{
  "version": "1.0.0",
  "lastUpdated": "2025-01-06T12:00:00Z",
  "features": {
    "user-authentication": {
      "description": "User login, logout, and session management",
      "files": [
        "src/auth/login.ts",
        "src/auth/session.ts",
        "src/api/routes/auth.ts"
      ],
      "dependencies": ["database", "jwt"],
      "relatedChanges": ["CHG-20250101-001"],
      "status": "implemented"
    },
    "api-rate-limiting": {
      "description": "Rate limiting for API endpoints",
      "files": [
        "src/middleware/rate-limit.ts"
      ],
      "dependencies": ["redis"],
      "relatedChanges": ["CHG-20250103-002"],
      "status": "implemented"
    }
  }
}
```

### 3. Duplicate Detection
When adding new features, checks for:
```
- Exact name matches
- Similar descriptions (fuzzy matching)
- Overlapping file references
- Related functionality patterns
```

## Examples

### Update from Archives
```
/ai:update-feature-index --from-archive
```
Scans archived changes and updates the index.

### Full Rebuild
```
/ai:update-feature-index --rebuild
```
Rebuilds the entire index from all sources.

### Dry Run
```
/ai:update-feature-index --dry-run
```
Shows what would be added/updated without making changes.

## Output

### Success
```
🗂️ Feature Index: Scanning sources...
📁 Archived changes: 12 found
📂 Codebase features: 8 detected

🗂️ Feature Index: Updating...
✅ Added: payment-processing
✅ Added: email-notifications
📝 Updated: user-authentication (new files)
⚠️ Potential duplicate: user-auth → user-authentication

🗂️ Feature Index: Complete
   Total features: 15
   New: 2
   Updated: 1
   Potential duplicates: 1
```

## Integration

### With /ai:check
The feature index is used by `/ai:check` to:
- Detect if a proposed feature already exists
- Find related implementations
- Identify files that might be affected

### With /ai:archive
When archiving changes, automatically calls:
```
/ai:update-feature-index --from-archive --merge
```

## Related Commands
- `/ai:check` - Uses feature index for duplicate detection
- `/ai:update-constraints` - Updates coding constraints
- `/ai:archive` - Triggers automatic index updates
