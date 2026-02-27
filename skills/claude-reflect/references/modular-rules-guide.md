# Modular Rules Guide (`.claude/rules/`)

## Overview

Claude Code supports modular rule files in `.claude/rules/` directory. These files provide topic-specific rules that automatically apply based on file paths, helping keep main CLAUDE.md/AGENTS.md files concise.

## Directory Structure

```
project/
├── CLAUDE.md              # Main project context (≤200 lines)
├── AGENTS.md              # Agent behavior rules (≤200 lines)
├── .claude/
│   ├── rules/
│   │   ├── python.md      # Python-specific rules
│   │   ├── typescript.md  # TypeScript-specific rules
│   │   ├── testing.md     # Testing conventions
│   │   ├── api.md         # API design patterns
│   │   └── security.md    # Security guidelines
│   └── settings.json
└── .claude.local.md       # Personal settings (gitignored)
```

## Rule File Format

### Required Frontmatter

```markdown
---
name: <rule-name>
description: <brief description>
paths:
  - "<glob-pattern-1>"
  - "<glob-pattern-2>"
---

# Rule Content

Your specific rules here...
```

### Frontmatter Fields

| Field | Required | Description |
|-------|----------|-------------|
| `name` | Yes | Unique identifier for the rule |
| `description` | Yes | Brief summary of what the rule covers |
| `paths` | No | Glob patterns for auto-application |

### Example: Python Linting Rule

```markdown
---
name: python-linting
description: Python-specific linting and formatting rules
paths:
  - "*.py"
  - "src/**/*.py"
  - "tests/**/*.py"
---

# Python Linting Rules

## Tools

- Use **ruff** for linting (faster than flake8)
- Use **black** for formatting
- Use **mypy** for type checking

## Commands

```bash
ruff check .              # Run linter
ruff check . --fix        # Auto-fix issues
black .                   # Format code
mypy src/                 # Type check
```

## Conventions

- Max line length: 88 characters (black default)
- Use f-strings for string formatting
- Prefer dataclasses over dicts for structured data
```

### Example: TypeScript Rule

```markdown
---
name: typescript-strict
description: TypeScript strict mode conventions
paths:
  - "*.ts"
  - "*.tsx"
  - "src/**/*.ts"
  - "src/**/*.tsx"
---

# TypeScript Strict Mode Rules

## Type Safety

- Enable `strict: true` in tsconfig.json
- No `any` types - use `unknown` with type guards
- Explicit return types for public functions

## Imports

- Use path aliases: `@/components/...`
- Group imports: external → internal → relative
- No barrel exports (index.ts re-exports)

## Testing

- Use `vitest` for unit tests
- Test files: `*.test.ts` adjacent to source
```

## Path Matching

### Glob Pattern Examples

| Pattern | Matches |
|---------|---------|
| `*.py` | All Python files in root |
| `src/**/*.py` | All Python files in src/ (recursive) |
| `tests/**/*` | All files in tests/ (recursive) |
| `*.{ts,tsx}` | TypeScript and TSX files |
| `!*.d.ts` | Exclude declaration files |

### Path Matching Rules

1. Patterns are relative to project root
2. `**` matches any number of directories
3. `*` matches any characters except `/`
4. Multiple patterns = OR logic (any match applies rule)
5. Rules apply when editing any matching file

## Importing Rules

Rules can reference other files using `@path` syntax:

```markdown
---
name: full-stack-rules
description: Combined rules for full-stack development
paths:
  - "src/**/*"
---

# Full Stack Rules

Includes:
- @.claude/rules/typescript.md
- @.claude/rules/testing.md

## Additional Project Rules

- Use React Query for data fetching
- Implement error boundaries per route
```

## When to Create Modular Rules

### Good Candidates for Extraction

| Content | Suggested File |
|---------|----------------|
| Language-specific conventions | `.claude/rules/{lang}.md` |
| Framework guidelines | `.claude/rules/{framework}.md` |
| Testing patterns | `.claude/rules/testing.md` |
| API design rules | `.claude/rules/api.md` |
| Security requirements | `.claude/rules/security.md` |
| Database conventions | `.claude/rules/database.md` |

### When to Keep in Main Files

- Project overview and architecture
- Build/deploy commands
- Environment setup
- Core project patterns
- High-level workflow

## Line Limit Guidelines

| File Type | Recommended Max | Exempt? |
|-----------|-----------------|---------|
| CLAUDE.md | 200 lines | No |
| AGENTS.md | 200 lines | No |
| .claude/rules/*.md | No limit | Yes |

**Why the exemption?** Modular rules focus on single topics and should be comprehensive within their scope. The constraint is topic scope, not line count.

## Rule Discovery

Claude Code automatically discovers rules:

1. **Path-based**: Rules auto-apply when editing matching files
2. **Explicit import**: Use `@path` to include in other rules
3. **Main file reference**: Reference from CLAUDE.md for visibility

```markdown
# In CLAUDE.md

## Modular Rules

See `.claude/rules/` for topic-specific rules:
- [Python Rules](.claude/rules/python.md)
- [TypeScript Rules](.claude/rules/typescript.md)
```

## Best Practices

### DO

- Use descriptive `name` in frontmatter
- Write clear `description` for discoverability
- Use specific `paths` patterns
- Keep rules focused on single topic
- Reference rules from main files

### DON'T

- Create overlapping rules (merge instead)
- Duplicate content from main files
- Use vague patterns like `**/*`
- Mix unrelated topics in one file
- Forget to add frontmatter

## Validation Checklist

Before committing a new rule file:

- [ ] Has valid YAML frontmatter
- [ ] `name` is unique among rules
- [ ] `description` accurately describes content
- [ ] `paths` patterns are specific (not too broad)
- [ ] Content doesn't duplicate main files
- [ ] Topic is cohesive and focused
- [ ] File follows naming convention: `{topic}.md`

## Troubleshooting

### Rule Not Applying

1. Check `paths` patterns match your files
2. Verify YAML frontmatter syntax
3. Ensure file is in `.claude/rules/` directory
4. Check for conflicting rules

### Too Many Rules Applying

1. Make patterns more specific
2. Use `!` to exclude patterns
3. Consolidate similar rules

### Content Duplicated Across Files

1. Identify source of truth
2. Use `@path` imports
3. Remove duplicate content
4. Add reference to main file