---
name: pre-implementation-check
description: |
  This skill should be used before starting any implementation task to prevent errors,
  duplication, and ensure technical standards compliance. It performs pre-implementation
  analysis through code search, duplicate detection, and impact analysis.
  Triggers on "pre-check", "analysis before coding", "实现前检查", "预检", "代码查重".
version: 5.1.22
triggers:
  - pre-check
  - analysis before coding
  - 实现前检查
  - 预检
  - 代码查重
  - 影响分析
  - search-before-code
---

# Pre-Implementation Check

> Prevent code errors, duplication, and maintain project consistency through systematic pre-implementation analysis.

## Overview

Pre-check runs automatically before each task implementation to:
1. Search for related existing code
2. Detect potential duplicates
3. Enforce technical standards and conventions
4. Load relevant context
5. Analyze modification impact

## Two-Layer Caching Strategy

### Layer 1: Project-Level Cache (Generated Once)

**Trigger**: `/init` or `/ai:update-constraints`

**Files Generated**:
- `codebox/implementation-constraints.json` (~50 lines)
- `codebox/knowledge/feature-index.json` (~30 lines)

**Source Files** (read only during generation):
- `codebox/design.md` - Architecture constraints
- `codebox/CLAUDE.md` - AI behavior rules
- `codebox/constraints.md` - Global constraints
- `package.json` - Tech stack
- `tsconfig.json` - TypeScript config
- Existing code sampling - Implicit patterns

### Layer 2: Task-Level Check (Per Task)

**Each Pre-Check reads**:
- `implementation-constraints.json` (~50 lines)
- `feature-index.json` (~30 lines)
- Related code files (max 5 files, ~200 lines)

**Total Context**: ~280 lines per task (acceptable)

---

## Pre-Check Flow

```
┌─────────────────────────────────────────────────────────────┐
│  PHASE 1: KEYWORD EXTRACTION (2s)                           │
│  - Extract domain entities from task                        │
│  - Generate search patterns                                 │
├─────────────────────────────────────────────────────────────┤
│  PHASE 2: TECHNICAL STANDARDS LOADING (5s)                  │
│  - Load implementation-constraints.json                     │
│  - Verify tech stack compliance                             │
├─────────────────────────────────────────────────────────────┤
│  PHASE 3: CODE SEARCH (5s)                                  │
│  - Grep keywords in codebase                                │
│  - Query feature-index.json                                 │
│  - Find similar implementations                             │
├─────────────────────────────────────────────────────────────┤
│  PHASE 4: DUPLICATE DETECTION (3s)                          │
│  - Exact match → REUSE                                      │
│  - Partial match → EXTEND                                   │
│  - No match → PROCEED                                       │
├─────────────────────────────────────────────────────────────┤
│  PHASE 5: CONTEXT LOADING (10s)                             │
│  - Load related files (priority order)                      │
│  - Load template files as reference                         │
│  - Load type definitions                                    │
├─────────────────────────────────────────────────────────────┤
│  PHASE 6: IMPACT ANALYSIS (5s)                              │
│  - Trace dependencies                                       │
│  - Identify files needing sync                              │
├─────────────────────────────────────────────────────────────┤
│  PHASE 7: GENERATE IMPLEMENTATION GUIDE (2s)                │
│  - What to reuse                                            │
│  - What patterns to follow                                  │
│  - What is forbidden                                        │
│  - Template files to reference                              │
└─────────────────────────────────────────────────────────────┘

Total: ~32 seconds
```

---

## Decision Types

| Decision | Condition | Action |
|----------|-----------|--------|
| **REUSE** | Exact duplicate found | Skip task, mark complete |
| **EXTEND** | Partial match found | Extend existing code |
| **CAREFUL** | High impact modification | List files to sync |
| **PROCEED** | No issues found | Continue with loaded context |

---

## Technical Standards Enforcement

### Constraints Loaded

```json
{
  "tech_stack": ["next.js", "typescript", "drizzle"],
  "forbidden_deps": ["prisma", "mongoose", "lodash"],
  "directories": {
    "services": "src/lib/services/",
    "repositories": "src/lib/repositories/"
  },
  "naming": {
    "service_file": "PascalCase.ts",
    "function": "camelCase"
  },
  "patterns": {
    "import": "@/ alias",
    "async": "async/await"
  },
  "forbidden": [
    "no any type",
    "no var",
    "no default export"
  ],
  "templates": {
    "service": "src/lib/services/AuthService.ts"
  }
}
```

### Enforcement Points

1. **Before Implementation**: Check task against constraints
2. **During Implementation**: Reference templates
3. **After Implementation**: Verify compliance in review

---

## Agents

| Agent | Purpose |
|-------|---------|
| `pattern-extractor` | Extract patterns from existing code |
| `standards-checker` | Verify technical standards compliance |

## Scripts

| Script | Purpose |
|--------|---------|
| `generate-constraints.sh` | Generate implementation-constraints.json |
| `search-related.sh` | Search for related code |
| `update-feature-index.sh` | Update feature index |

## Templates

| Template | Purpose |
|----------|---------|
| `implementation-constraints.json` | Constraint cache template |
| `feature-index.json` | Feature index template |
| `pre-check-report.md` | Check report template |

---

## Integration

### With /ai:loop

```
for each task in tasks.md:
    pre_check_result = execute_pre_check(task)
    
    if pre_check_result.decision == "REUSE":
        mark_complete(task, "Reused: " + existing_file)
        continue
    
    implement_with_context(task, pre_check_result.context)
```

### With /ai-implement

Same integration as /ai:loop, called for each task.

### With /init

```
/init project_name
├── Create codebox structure
├── Run generate-constraints.sh  ← Generate constraints
└── Initialize feature-index.json
```

---

## Commands

| Command | Description |
|---------|-------------|
| `/ai-check <task>` | Manual pre-check |
| `/ai:update-constraints` | Regenerate constraints cache |
| `/ai:update-feature-index` | Update feature index |

---

## Related Files

- `agents/pattern-extractor.md`
- `agents/standards-checker.md`
- `scripts/generate-constraints.sh`
- `scripts/search-related.sh`
- `templates/implementation-constraints.json`
- `templates/feature-index.json`
