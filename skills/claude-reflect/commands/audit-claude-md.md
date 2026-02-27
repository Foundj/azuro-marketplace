---
name: audit-claude-md
description: Audit CLAUDE.md and AGENTS.md files for quality and completeness
allowed-tools: Read, Glob, Grep, Bash
internal: true
---

Audit all CLAUDE.md and AGENTS.md files in the repository for quality and suggest improvements.

## Step 1: Discovery

Find all context files:

```bash
# Find main context files
find . -name "CLAUDE.md" -o -name "AGENTS.md" -o -name ".claude.md" -o -name ".claude.local.md" 2>/dev/null | head -50

# Find modular rule files
find .claude/rules -name "*.md" 2>/dev/null | head -50
```

**File Types:**

| Type | Location | Purpose |
|------|----------|---------|
| CLAUDE.md | Project root | Team-shared project context (≤200 lines) |
| AGENTS.md | Project root | Agent behavior instructions (≤200 lines) |
| .claude.local.md | Project root | Personal/local settings (gitignored) |
| .claude/rules/*.md | Modular rules | Topic-specific rules with `paths` frontmatter |
| ~/.claude/CLAUDE.md | Home | User-wide defaults |

## Step 2: Quality Assessment

For each file, evaluate against 7 criteria (115 points total):

| Criterion | Weight | Check |
|-----------|--------|-------|
| Commands/workflows | 20 | Are build/test/deploy commands present? |
| Architecture clarity | 20 | Can Claude understand the codebase structure? |
| Non-obvious patterns | 15 | Are gotchas and quirks documented? |
| Conciseness | 15 | No verbose explanations or obvious info? |
| Currency | 15 | Does it reflect current codebase state? |
| Actionability | 15 | Are instructions executable, not vague? |
| Line limits | 15 | Main files ≤200 lines, well-structured? |

**Line Count Check:**

```bash
# Check line count for main files
wc -l CLAUDE.md AGENTS.md 2>/dev/null
```

| Lines | Score | Status |
|-------|-------|--------|
| ≤200 | 15 | Optimal |
| 201-300 | 10 | Acceptable |
| 301-400 | 5 | Needs refactoring |
| >400 | 0 | Critical: extract to modular rules |

**Note**: Modular rule files (`.claude/rules/*.md`) are **exempt** from line limits.

See [references/quality-criteria.md](../references/quality-criteria.md) for detailed rubrics.

## Step 3: Modular Rules Audit

For each file in `.claude/rules/`:

1. Check frontmatter has `name` and `description`
2. Verify `paths` patterns are valid globs
3. Check content is topic-focused
4. Ensure no duplication with main files

```markdown
### Modular Rules Summary

| File | Name | Paths | Lines | Status |
|------|------|-------|-------|--------|
| python.md | Python Linting | *.py | 45 | ✓ |
| testing.md | Test Rules | tests/**/* | 120 | ✓ |
```

## Step 4: Output Quality Report

```
## Context Files Quality Report

### Summary
- Files found: X
- Average score: X/115
- Files needing update: X
- Modular rules: X files

### Line Count Status
| File | Lines | Status |
|------|-------|--------|
| CLAUDE.md | 185 | ✓ Optimal |
| AGENTS.md | 312 | ⚠ Needs refactoring |

### File-by-File Assessment

#### 1. ./CLAUDE.md (Project Root)
**Score: XX/115 (Grade: X)**

| Criterion | Score | Notes |
|-----------|-------|-------|
| Commands/workflows | X/20 | ... |
| Architecture clarity | X/20 | ... |
| Non-obvious patterns | X/15 | ... |
| Conciseness | X/15 | ... |
| Currency | X/15 | ... |
| Actionability | X/15 | ... |
| Line limits | X/15 | ... |

**Issues:**
- [List specific problems]

**Recommended additions:**
- [List what should be added]

#### 2. ./AGENTS.md (Agent Instructions)
...

### Modular Rules Assessment

#### .claude/rules/python.md
- **Name**: Python Linting
- **Paths**: `*.py`, `src/**/*.py`
- **Lines**: 45
- **Status**: ✓ Valid

#### .claude/rules/testing.md
- **Name**: Testing Guidelines
- **Paths**: `tests/**/*`
- **Lines**: 120
- **Status**: ✓ Valid
```

## Step 5: Suggest Updates

For each issue found, propose targeted additions:

```markdown
### Update: ./CLAUDE.md

**Why:** Build command was missing, causing confusion.

\`\`\`diff
+ ## Commands
+
+ | Command | Description |
+ |---------|-------------|
+ | `npm install` | Install dependencies |
+ | `npm run dev` | Start development server |
+ | `npm test` | Run test suite |
\`\`\`
```

### Refactoring Suggestions

When files exceed line limits:

```markdown
### Refactoring: ./AGENTS.md (312 lines → target ≤200)

**Extract to modular rules:**
- Agent-specific TypeScript rules → `.claude/rules/typescript-agents.md`
- Testing workflow rules → `.claude/rules/testing.md`

**Estimated post-refactor:** 180 lines
```

## Step 6: Apply with Approval

Ask user which updates to apply. Only edit files they approve.

## Red Flags to Check

- Commands that would fail
- References to deleted files
- Outdated tech versions
- Generic advice not specific to project
- Duplicate info across CLAUDE.md and AGENTS.md
- Contradictory instructions between files
- Main files exceeding 400 lines
- Modular rules missing required frontmatter

## Templates

See [references/templates.md](../references/templates.md) for project templates to suggest for new/empty files.