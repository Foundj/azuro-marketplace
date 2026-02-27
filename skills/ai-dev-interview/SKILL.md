---
name: ai-dev-interview
description: |
  This skill provides multi-round requirement interview system for AI development. It conducts structured
  interviews with parallel context collection, risk detection, and proposal generation. Use this skill
  when the user mentions "requirement interview", "需求访谈", "ai:interview", "clarify requirements",
  "gather requirements", or when gathering requirements for new features or clarifying ambiguous specifications.
version: 5.1.15
status: ga
triggers:
  - requirement interview
  - clarify requirements
  - gather requirements
  - 需求访谈
  - 需求分析
  - 访谈需求
  - 需求
  - 要求
---

# Requirement Interview System

> Structured multi-round interview with parallel context collection and risk detection.

## 触发词

此技能触发于: "requirement interview", "需求访谈", "ai:interview", "clarify requirements".

## Quick Start

```bash
/ai:interview "user authentication"   # Start requirement interview
/ai:dev "new feature"                 # Triggers interview in Phase 1
```

## Interview Process

```
┌─────────────────────────────────────────────────────────┐
│                 INTERVIEW WORKFLOW                       │
├─────────────────────────────────────────────────────────┤
│  1. CONTEXT COLLECTION (Parallel)                       │
│     ├── @explore-fast: Scan project structure           │
│     ├── @librarian: Query knowledge base                │
│     └── Research: Load competitor insights              │
│                                                         │
│  2. INTERVIEW ROUNDS (2-6 based on complexity)          │
│     ├── Each question includes context references       │
│     ├── Detect risks and conflicts                      │
│     └── Validate against project constraints            │
│                                                         │
│  3. PROPOSAL GENERATION                                 │
│     └── Output: proposal.md with requirements           │
└─────────────────────────────────────────────────────────┘
```

## Parallel Context Collection

Before asking questions, the interviewer collects context in parallel:

```javascript
// Parallel execution
await Promise.all([
  Task({ subagent_type: 'Explore', prompt: 'Scan project for related code' }),
  Task({ subagent_type: 'ai-dev:librarian', prompt: 'Query knowledge base' }),
  loadResearchResults(featureName)
]);
```

## Interview Rounds

**Complexity-based rounds**:
| Complexity | Rounds | Examples |
|------------|--------|----------|
| Simple | 2 | Bug fix, small update |
| Medium | 3-4 | New endpoint, component |
| Complex | 5-6 | New system, major refactor |

**Each question includes**:
- Project context references
- Research insights
- Historical patterns
- Risk warnings

## Risk Detection

Automatically detects and warns about:

| Risk Level | Icon | Action |
|------------|------|--------|
| 🔴 Blocking | ❌ | Must resolve before proceeding |
| 🟡 Warning | ⚠️ | User decides to proceed or modify |
| 🟢 Info | ℹ️ | Include in suggestions |

**Examples**:
- Duplicate feature detection
- Breaking change warnings
- Security implications
- Performance concerns

## Output: proposal.md

```markdown
# Feature Proposal: User Authentication

## Summary
[Concise feature description]

## Requirements
1. [Requirement 1]
2. [Requirement 2]

## Constraints
- Must integrate with existing user model
- Session timeout: 30 minutes

## Risks Identified
- 🟡 Existing session handling may need refactoring

## Research References
- OAuth 2.0 best practices (from competitor research)
- JWT implementation patterns (from knowledge base)

## Next Steps
Proceed to Phase 2 (Design Approval)
```

## Agent: requirement-interviewer

See `agents/requirement-interviewer.md` for the agent definition.

**Capabilities**:
- Multi-round structured interviews
- Parallel context collection via Task tool
- Risk detection and warning
- Proposal document generation
- Integration with research and knowledge systems

## Integration with ai-dev

This skill is used in **Phase 1 (Requirement Interview)** of the 7-phase workflow:

1. Phase 0 completes context loading
2. Phase 0.5 completes research (if applicable)
3. **Phase 1 activates interview system**
4. User approves proposal.md
5. Phase 2 begins design approval

## Configuration

Interview behavior can be configured in `codebox/config.json`:

```json
{
  "interview": {
    "minRounds": 2,
    "maxRounds": 6,
    "parallelContextCollection": true,
    "riskDetectionEnabled": true
  }
}
```

## Agent Collaboration

| Agent | Role |
|-------|------|
| `ai-dev` | Triggers interview in Phase 1 |
| `brainstorm-mode` | Pre-interview exploration (optional) |
| `competitor-research` | Provides research context |
| `@explore-fast` | Scans project during context collection |
| `@librarian` | Queries knowledge base |

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 4.2.6 | 2026-01-13 | Add agent collaboration, version history |
| 4.0.0 | 2026-01-07 | Initial release with parallel context collection |

## References

See `references/interview-guide.md` for best practices.
