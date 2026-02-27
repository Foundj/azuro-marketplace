# CLAUDE.md / AGENTS.md Quality Criteria

> **Research Note**: Studies show that **LLM-generated context files can decrease performance** (-0.5% to -2%), while **human-written files improve success rates** (+4%). Context files add ~20% inference cost regardless of quality. **Write for gaps, not overviews.**

## Core Principle

**Context files should contain what the code itself cannot explain.**

- ✅ Write about gaps: tool choices that differ from conventions, non-obvious test configs, project-specific quirks
- ❌ Don't repeat: README content, obvious code info, generic best practices

## Scoring Rubric

### 1. Commands/Workflows (20 points)

**20 points**: All essential commands documented with context
- Build, test, lint, deploy commands present
- Development workflow clear
- Common operations documented

**15 points**: Most commands present, some missing context

**10 points**: Basic commands only, no workflow

**5 points**: Few commands, many missing

**0 points**: No commands documented

### 2. Architecture Clarity (20 points)

**20 points**: Clear codebase map
- Key directories explained
- Module relationships documented
- Entry points identified
- Data flow described where relevant

**15 points**: Good structure overview, minor gaps

**10 points**: Basic directory listing only

**5 points**: Vague or incomplete

**0 points**: No architecture info

### 3. Non-Obvious Patterns (15 points)

**15 points**: Gotchas and quirks captured
- Known issues documented
- Workarounds explained
- Edge cases noted
- "Why we do it this way" for unusual patterns

**10 points**: Some patterns documented

**5 points**: Minimal pattern documentation

**0 points**: No patterns or gotchas

### 4. Conciseness (15 points)

**15 points**: Dense, valuable content
- No filler or obvious info
- Each line adds value
- No redundancy with code comments

**10 points**: Mostly concise, some padding

**5 points**: Verbose in places

**0 points**: Mostly filler or restates obvious code

### 5. Currency (15 points)

**15 points**: Reflects current codebase
- Commands work as documented
- File references accurate
- Tech stack current

**10 points**: Mostly current, minor staleness

**5 points**: Several outdated references

**0 points**: Severely outdated

### 6. Actionability (15 points)

**15 points**: Instructions are executable
- Commands can be copy-pasted
- Steps are concrete
- Paths are real

**10 points**: Mostly actionable

**5 points**: Some vague instructions

**0 points**: Vague or theoretical

### 7. Line Limits (15 points)

**15 points**: Main files ≤200 lines, structure optimal
- CLAUDE.md concise and focused
- AGENTS.md well-organized
- Excessive content moved to `.claude/rules/*.md`

**10 points**: Main files 201-300 lines, acceptable but could improve
- Some redundancy present
- Could benefit from modularization

**5 points**: Main files 301-400 lines, needs refactoring
- Clear bloat or redundancy
- Should extract to modular rules

**0 points**: Main files >400 lines, severely bloated
- Difficult to maintain
- Immediate refactoring needed

**Note**: Modular rule files (`.claude/rules/*.md`) are **exempt** from line limits.
These files should focus on single topics and be as long as needed.

## File Type Differences

### CLAUDE.md (Project Context)

Focus on:
- Build/test commands
- Code style conventions
- Project-specific patterns
- Environment setup

### AGENTS.md (Agent Instructions)

Focus on:
- Agent behavior rules
- Tool usage guidelines
- Decision-making criteria
- Response patterns

## Assessment Process

### Pre-Assessment Check

Before auditing, determine if context files are needed:

| Scenario | Recommendation |
|----------|----------------|
| Well-documented repo (README, docs/) | May not need CLAUDE.md |
| Standard framework (Next.js, Rails) | Minimal context needed |
| Custom/proprietary architecture | CLAUDE.md valuable |
| Unique tooling/build process | CLAUDE.md valuable |
| Team-specific conventions | AGENTS.md valuable |

### Assessment Steps

1. Read the file completely
2. Cross-reference with actual codebase:
   - Run documented commands (mentally or actually)
   - Check if referenced files exist
   - Verify architecture descriptions
3. Check for redundancy with existing docs (README, docs/)
4. Score each criterion
5. Calculate total and assign grade
6. List specific issues found
7. Propose concrete improvements

## Quality Grades

| Grade | Score | Description |
|-------|-------|-------------|
| A | 100-115 | Comprehensive, current, actionable, well-structured |
| B | 80-99 | Good coverage, minor gaps |
| C | 60-79 | Basic info, missing key sections |
| D | 40-59 | Sparse or outdated |
| F | 0-39 | Missing or severely outdated |

## Red Flags

- Commands that would fail (wrong paths, missing deps)
- References to deleted files/folders
- Outdated tech versions
- Copy-paste from templates without customization
- Generic advice not specific to the project
- "TODO" items never completed
- Duplicate info across multiple files
- Main files exceeding 400 lines (needs modularization)

## Agent-Specific Red Flags

- Contradictory instructions between CLAUDE.md and AGENTS.md
- Tool restrictions that don't match allowed-tools
- Behavior rules that conflict with project context
- Missing trigger conditions or use cases

## Modular Rules Integration

When main files exceed recommended line limits, consider extracting content to modular rule files:

| Content Type | Recommended Location |
|--------------|---------------------|
| Python-specific rules | `.claude/rules/python.md` |
| TypeScript-specific rules | `.claude/rules/typescript.md` |
| Testing conventions | `.claude/rules/testing.md` |
| API design patterns | `.claude/rules/api.md` |
| Security guidelines | `.claude/rules/security.md` |

See [modular-rules-guide.md](modular-rules-guide.md) for detailed guidance.