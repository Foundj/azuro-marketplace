---
name: ai:dev
description: AI-powered 7-phase development workflow for complete feature implementation
argument-hint: "<feature-description> | auto [--dry-run] [--skip-research] [--quick] [--team]"
allowed-tools: Task, Read, Write, Edit, Grep, Glob, Bash, TeamCreate, TeamDelete, TaskCreate, TaskUpdate, TaskList, TaskGet, SendMessage
---

# AI Development Command

**Usage:**
- `/ai:dev <feature>` - Start 7-phase development workflow
- `/ai:dev auto` - Auto-complete all unchecked tasks in active change
- `/ai:dev auto --dry-run` - Preview tasks without executing
- `/ai:dev <feature> --team` - Use Agent Teams collaborative mode

---

## Mode Detection

Parse $ARGUMENTS to determine mode:

**Check for --team flag first:**
- If `--team` present → Execute **Agent Teams Mode** (see below)

**If first argument is "auto":**
→ Execute **Auto-Complete Mode** (see below)

**Otherwise:**
→ Execute **Feature Development Mode** (7-phase workflow)

---

## Agent Teams Mode

**Triggered by `--team` flag**

When user specifies `--team`, delegate to the team-orchestrator for collaborative development:

```typescript
// Check if Agent Teams is enabled
const teamsEnabled = process.env.CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS === "1"

if (!teamsEnabled) {
  console.log(`
⚠️  Agent Teams requires experimental feature enabled

Add to ~/.claude/settings.json:
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
  `)
  // Fall back to traditional mode
}

// Assess task complexity for team configuration
const complexity = assessComplexity(featureDescription)
const needsTeam = complexity === "medium" || complexity === "complex"

if (needsTeam) {
  // Create team with appropriate teammates
  TeamCreate({
    team_name: generateTeamName(featureDescription),
    description: featureDescription,
    agent_type: "team-orchestrator"
  })

  // Generate teammates based on task type
  // ... (see team-orchestrator agent for details)
}
```

**Team Mode Selection Logic:**
| Complexity | Recommendation | Team Size |
|------------|----------------|-----------|
| simple | Single agent | 1 |
| medium | Small team | 2-3 |
| complex | Full team | 3-5 |

**After team execution:**
1. All teammates receive shutdown_request
2. TeamDelete cleans up resources
3. Return to normal workflow

---

## Auto-Complete Mode

**Goal**: Automatically complete all remaining unchecked tasks in the active change.

### Step 1: Parse Options

- `--dry-run`: Preview tasks without executing
- `--from-task N.N`: Start from specific task (e.g., `1.3`)

### Step 2: Find Active Change

```bash
ACTIVE_CHANGE=$(find codebox/changes/active -maxdepth 1 -type d ! -name "active" 2>/dev/null | head -1)
TASKS_FILE="${ACTIVE_CHANGE}/tasks.md"
```

**If no active change exists:**
```
❌ No active change found.

To start a new change, use:
  /ai:dev <feature-description>
```

### Step 3: Analyze Task Status

Read `tasks.md` and count completed vs remaining tasks.

**If all tasks complete:**
```
✅ All tasks already complete!
Nothing to do. Use /ai:status for details.
```

### Step 4: Execute (unless --dry-run)

**If `--dry-run`:**
- Show task preview and exit

**Otherwise**, invoke OODA loop:
1. Read next unchecked task
2. Execute task
3. Update checkbox
4. Run tests
5. Continue until all complete
6. Output `<promise>DONE</promise>`

---

## Feature Development Mode

Implement feature: $ARGUMENTS

**Pre-check: Auto-initialize if needed**

Check if codebox/ exists: !`test -d codebox && echo "OK" || echo "NOT_INITIALIZED"`

If NOT_INITIALIZED:
- **Auto-initialize** codebox structure:
  ```
  mkdir -p codebox/{changes/{active,archived},knowledge,research,scripts}
  echo '[]' > codebox/feature_list.json
  echo '# Design Constraints' > codebox/design.md
  ```
- Log: "Auto-initialized codebox/ for ai-dev workflow"

**Parse options:**
- `--skip-research`: Skip Phase 0.5 competitor research
- `--quick`: Skip Phase 2 (resource discovery) and Phase 3 (design review)

**Phase 0: Context Awareness**

1. Run project scan: !`./codebox/scripts/scan-project.sh incremental 2>/dev/null || echo "Scan skipped"`
2. Query knowledge base: !`./codebox/scripts/query-knowledge.sh "$ARGUMENTS" 2>/dev/null || echo "No prior knowledge"`
3. Generate context summary in phase0-context.md

**Phase 0.5: Competitor Research** (unless --skip-research)

For new features, execute research using available tools:

1. **If MCP Tavily available**: Use Tavily for deep research
2. **Otherwise**: Use WebSearch for best practices:
   - Search for: "[feature topic] best practices 2024"
   - Search for: "[feature topic] implementation patterns"
3. Save findings to `codebox/research/[feature]-research.md`

Skip for bug fixes, simple tasks, or when --skip-research flag is present.

**Phase 1: Requirement Interview**

Load and invoke requirement-interviewer agent:
- Conduct multi-turn requirement clarification
- Reference research findings from Phase 0.5
- Generate proposal.md with:
  - User stories
  - Acceptance criteria
  - Technical constraints
  - Estimated complexity

**USER APPROVAL CHECKPOINT ✓**
Present proposal.md and wait for user approval before proceeding.

**Phase 2: Resource Discovery** (unless --quick)

Launch 2-3 code-explorer agents in parallel:
- Identify relevant existing code
- Map dependencies
- Find integration points
- Generate evidence.md

**Phase 3: Design Review** (unless --quick)

Launch 2-3 code-architect agents:
- Generate 2-3 design options
- Evaluate trade-offs
- Create design.md with options

**USER APPROVAL CHECKPOINT ✓**
Present design options and wait for user to select approach.

**Phase 4: OODA Implementation Loop**

Initialize tasks.md with implementation steps.

Execute OODA cycle (max 10 iterations):
1. **Observe**: Check current state, read relevant files
2. **Orient**: Analyze what needs to be done next
3. **Decide**: Choose specific action
4. **Act**: Implement the change

Continue until all tasks complete with `<promise>DONE</promise>`.

**Phase 5: Quality Validation**

Launch code-reviewer agents:
- Review all changes
- Run confidence-scorer (threshold: ≥80)
- Generate review findings

**USER DECISION CHECKPOINT ✓**
Present findings and let user decide which issues to fix.

**Phase 6: Archive & Commit**

Check if git repository: `git rev-parse --git-dir 2>/dev/null && echo "GIT_OK" || echo "NO_GIT"`

If the above command outputs GIT_OK:
1. Stage changes: `git add -A`
2. Create commit with descriptive message

If the above command outputs NO_GIT:
- Skip git operations
- Inform user: "Note: Not a git repository, skipping commit step"

Always:
3. Update codebox/feature_list.json
4. Archive change to codebox/changes/archived/
5. Update knowledge base with learnings

**Completion:**
Report summary of implemented feature and any follow-up recommendations.
