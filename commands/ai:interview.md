---
name: ai:interview
description: AI-powered requirement interview - clarify requirements through multi-round conversation
argument-hint: "<feature-description>"
allowed-tools: Task, Read, Write, Grep, Glob, Bash
---

Conduct requirement interview for: $ARGUMENTS

**Goal**: Clarify requirements through structured conversation, generate proposal.md

**Step 1: Context Collection (Parallel)**

Launch parallel context gathering:
1. Project scan: `./codebox/scripts/scan-project.sh incremental 2>/dev/null`
2. Knowledge query: `./codebox/scripts/query-knowledge.sh "$ARGUMENTS" 2>/dev/null`
3. Similar features: Search codebase for related implementations

**Step 2: Multi-Round Interview**

Conduct 2-6 rounds based on complexity:

For each round:
1. Ask focused question with:
   - Reference to project context
   - Similar patterns found
   - Potential risks/considerations
2. Wait for user response
3. Refine understanding

**Question Categories:**
- 🎯 Core functionality: What exactly should happen?
- 👤 User interaction: How will users trigger/use this?
- 🔗 Integration: What existing systems are affected?
- ⚠️ Edge cases: What happens when X fails?
- 📊 Success criteria: How do we know it's working?

**Step 3: Generate Proposal**

Create `codebox/changes/active/[id]/proposal.md`:

```markdown
# Feature: [Name]

## User Stories
- As a [role], I want [feature] so that [benefit]

## Acceptance Criteria
- [ ] Criterion 1
- [ ] Criterion 2

## Technical Constraints
- Constraint 1
- Constraint 2

## Risks & Mitigations
| Risk | Impact | Mitigation |
|------|--------|------------|

## Estimated Complexity
- Size: S/M/L/XL
- Estimated time: X hours/days
```

**Step 4: User Confirmation**

Present proposal summary and ask:
> 需求理解是否正确？确认后可继续 `/ai:design` 进入设计阶段。
