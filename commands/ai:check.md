---
name: ai:check
description: Pre-implementation check - analyze codebase before coding to prevent errors and duplication
argument-hint: "<task-description> [--deep] [--report]"
allowed-tools: Task, Read, Grep, Glob, Bash
internal: true
---

Pre-Implementation Check: $ARGUMENTS

**Goal**: Analyze codebase before implementation to prevent errors, duplication, and ensure standard compliance.

## Options

- `--deep`: Extended analysis with similarity scoring
- `--report`: Generate detailed report file

---

## Phase 1: Load Constraints (2s)

Load cached constraints:

```bash
CONSTRAINTS_FILE=".agent/implementation-constraints.json"
if [[ -f "$CONSTRAINTS_FILE" ]]; then
    cat "$CONSTRAINTS_FILE"
else
    echo "⚠️ No constraints cache. Run /ai:update-constraints first."
fi
```

Extract key constraints:
- `tech_stack`: Allowed technologies
- `forbidden_deps`: Blocked dependencies
- `naming`: File and code naming conventions
- `patterns`: Import/export/async styles
- `forbidden`: Prohibited patterns
- `templates`: Reference template files

---

## Phase 2: Extract Keywords (2s)

Parse task description:
1. Extract domain entities (User, Auth, Product, etc.)
2. Extract action verbs (create, update, delete)
3. Generate search patterns

Example:
```
Task: "Create UserService for authentication"
Keywords: user, service, authentication, auth, create
Patterns: *User*, *Service*, *Auth*
```

---

## Phase 3: Search Related Code (5s)

```bash
# Search by keywords
grep -rlE "KEYWORDS" --include="*.ts" --include="*.tsx" . | head -20

# Search by file pattern
find . -type f \( -name "*User*" -o -name "*Auth*" \) | head -20

# Check feature index
jq '.features[] | select(.keywords[] | contains("auth"))' \
    .agent/knowledge/feature-index.json
```

---

## Phase 4: Duplicate Detection (3s)

### 4.1 Exact Match Check

```
Search: "class UserService" or "function UserService"
If found: DECISION = REUSE
```

### 4.2 Partial Match Check

```
Search: Similar functionality (login, auth, token)
If found:
  - Analyze overlap
  - DECISION = EXTEND (reuse existing, add new)
```

### 4.3 Semantic Match

```
Compare task intent with existing features in feature-index.json
Flag similar features for review
```

---

## Phase 5: Context Loading (10s)

Load files in priority order:

1. **Direct matches** (files containing keywords)
2. **Template files** (from constraints.templates)
3. **Type definitions** (*.types.ts, *.d.ts)
4. **Related tests** (understand expected behavior)
5. **Index/barrel files** (understand module structure)

Max files: 5 (to limit context size)

---

## Phase 6: Impact Analysis (5s)

### 6.1 Trace Dependencies

```bash
# Find who imports the files we'll modify
grep -rl "from.*TargetFile" --include="*.ts" .
```

### 6.2 Identify Breaking Changes

Check if modification will:
- Change public API signatures
- Modify shared types
- Affect >5 dependent files

### 6.3 List Sync Updates

Files that need updates after modification:
- Related tests
- Type definitions
- Documentation

---

## Phase 7: Generate Report

### Summary Output

```
📋 Pre-Check: ${TASK}
━━━━━━━━━━━━━━━━━━━━━━

🔍 Related Code: X files found
🔄 Duplicates: X matches
📁 Context: X files loaded
⚠️ Impact: X dependent files

📌 Decision: ${DECISION}
${DECISION_DETAILS}

✅ Compliant: Tech stack, naming, patterns
⚠️ Warning: ${WARNINGS}

Ready to implement with context.
```

### Decision Types

| Decision | Condition | Action |
|----------|-----------|--------|
| **REUSE** | Exact duplicate | Skip task, mark complete |
| **EXTEND** | Partial match | Extend existing code |
| **CAREFUL** | High impact | List files to sync |
| **PROCEED** | No issues | Continue with context |

---

## Phase 8: Standards Verification

Before proceeding, verify:

1. **Tech Stack**: Task doesn't introduce forbidden dependencies
2. **Naming**: Planned files follow naming conventions
3. **Patterns**: Will use correct import/export style
4. **Templates**: Reference templates identified

If violations found:
```
⛔ Standards Violation Detected

- Using Joi instead of zod (project uses zod)
- Creating src/utils/ (project uses src/lib/utils/)

Suggestions:
1. Use zod for validation
2. Place utilities in src/lib/utils/
```

---

## Usage Examples

```bash
# Quick check
/ai:check 实现用户登录

# Deep analysis with report
/ai:check --deep --report "Add OAuth Google login"

# Check before implementation
/ai:check "Create PaymentService for Stripe integration"
```

---

## Integration

This command is automatically called by:
- `/ai:loop` - Before each task
- `/ai:implement` - Before implementation phase

Manual use:
- Before starting any new feature
- When unsure about existing code
- To verify approach before coding
