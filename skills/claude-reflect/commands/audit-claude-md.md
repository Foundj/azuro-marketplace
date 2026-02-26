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
find . -name "CLAUDE.md" -o -name "AGENTS.md" -o -name ".claude.md" -o -name ".claude.local.md" 2>/dev/null | head -50
```

**File Types:**

| Type | Location | Purpose |
|------|----------|---------|
| CLAUDE.md | Project root | Team-shared project context |
| AGENTS.md | Project root | Agent behavior instructions |
| .claude.local.md | Project root | Personal/local settings (gitignored) |
| ~/.claude/CLAUDE.md | Home | User-wide defaults |

## Step 2: Quality Assessment

For each file, evaluate against 6 criteria (100 points total):

| Criterion | Weight | Check |
|-----------|--------|-------|
| Commands/workflows | 20 | Are build/test/deploy commands present? |
| Architecture clarity | 20 | Can Claude understand the codebase structure? |
| Non-obvious patterns | 15 | Are gotchas and quirks documented? |
| Conciseness | 15 | No verbose explanations or obvious info? |
| Currency | 15 | Does it reflect current codebase state? |
| Actionability | 15 | Are instructions executable, not vague? |

See [references/quality-criteria.md](../references/quality-criteria.md) for detailed rubrics.

## Step 3: Output Quality Report

```
## Context Files Quality Report

### Summary
- Files found: X
- Average score: X/100
- Files needing update: X

### File-by-File Assessment

#### 1. ./CLAUDE.md (Project Root)
**Score: XX/100 (Grade: X)**

| Criterion | Score | Notes |
|-----------|-------|-------|
| Commands/workflows | X/20 | ... |
| Architecture clarity | X/20 | ... |
| Non-obvious patterns | X/15 | ... |
| Conciseness | X/15 | ... |
| Currency | X/15 | ... |
| Actionability | X/15 | ... |

**Issues:**
- [List specific problems]

**Recommended additions:**
- [List what should be added]

#### 2. ./AGENTS.md (Agent Instructions)
...
```

## Step 4: Suggest Updates

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

## Step 5: Apply with Approval

Ask user which updates to apply. Only edit files they approve.

## Red Flags to Check

- Commands that would fail
- References to deleted files
- Outdated tech versions
- Generic advice not specific to project
- Duplicate info across CLAUDE.md and AGENTS.md
- Contradictory instructions between files

## Templates

See [references/templates.md](../references/templates.md) for project templates to suggest for new/empty files.