---
name: ai:dev
description: AI-powered 7-phase development workflow for complete feature implementation
argument-hint: "<feature-description> [--skip-research] [--quick]"
allowed-tools: Task, Read, Write, Edit, Grep, Glob, Bash
---

Implement feature: $ARGUMENTS

**Pre-check: Verify project initialization**

Check if codebox/ exists: !`test -d codebox && echo "OK" || echo "NOT_INITIALIZED"`

If NOT_INITIALIZED:
- Stop and inform user: "Please run /init first to initialize the project"

**Parse options:**
- `--skip-research`: Skip Phase 0.5 competitor research
- `--quick`: Skip Phase 2 (resource discovery) and Phase 3 (design review)

**Phase 0: Context Awareness**

1. Run project scan: !`./codebox/scripts/scan-project.sh incremental 2>/dev/null || echo "Scan skipped"`
2. Query knowledge base: !`./codebox/scripts/query-knowledge.sh "$ARGUMENTS" 2>/dev/null || echo "No prior knowledge"`
3. Generate context summary in phase0-context.md

**Phase 0.5: Competitor Research** (unless --skip-research)

For new features, execute research:
!`~/.claude/common/lib/codeagent-wrapper.sh --backend auto --yolo "Research best practices for: $ARGUMENTS"`

Skip for bug fixes or when --skip-research flag is present.

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

1. Stage changes: !`git add -A`
2. Create commit with descriptive message
3. Update codebox/feature_list.json
4. Archive change to codebox/changes/archived/
5. Update knowledge base with learnings

**Completion:**
Report summary of implemented feature and any follow-up recommendations.
