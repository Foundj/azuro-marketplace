---
name: confidence-gate
description: |
  This skill provides pre-execution confidence checking to prevent wrong-direction work.
  It implements SuperClaude PM Agent's confidence gate pattern: ≥90% proceed, 70-89% present
  alternatives, <70% must ask questions. Use when starting tasks, before implementation,
  or when the user mentions "confidence check", "置信度", "确认方向", "ai:check".
version: 5.0.14
triggers:
  - confidence check
  - pre-check
  - ai:check
  - 置信度检查
  - 确认方向
  - 方向确认
---

# Confidence Gate

> Pre-execution confidence checking to prevent wrong-direction work. ROI: 25-250x token savings.

## Quick Start

```bash
/ai:check "implement user authentication"  # Check confidence before starting
```

## Core Concept

Confidence Gate prevents wasted effort by checking understanding BEFORE execution:

```
┌─────────────────────────────────────────────────────────────┐
│                    CONFIDENCE GATE                           │
├─────────────────────────────────────────────────────────────┤
│  Input: Task description + Available context                 │
│                          ↓                                   │
│  ┌───────────────────────────────────────────────────────┐  │
│  │  Confidence Assessment                                 │  │
│  │  - Official docs available?                            │  │
│  │  - Similar patterns in codebase?                       │  │
│  │  - Clear requirements?                                 │  │
│  │  - Technology familiarity?                             │  │
│  └───────────────────────────────────────────────────────┘  │
│                          ↓                                   │
│  ┌─────────┐    ┌─────────────┐    ┌─────────────────────┐  │
│  │ ≥90%    │    │  70-89%     │    │      <70%           │  │
│  │ PROCEED │    │ ALTERNATIVES│    │  MUST ASK           │  │
│  └─────────┘    └─────────────┘    └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Confidence Factors

| Factor | Weight | Description |
|--------|--------|-------------|
| Official Documentation | 25% | Context7/WebFetch verified docs |
| Codebase Patterns | 25% | Similar implementations exist |
| Clear Requirements | 20% | Unambiguous success criteria |
| Technology Familiarity | 15% | Known vs novel tech stack |
| Test Coverage | 15% | Existing tests to validate against |

## Decision Matrix

### ≥90% Confidence: PROCEED

```yaml
Criteria:
  - Official docs consulted and understood
  - Similar pattern exists in codebase
  - Requirements are clear and specific
  - Technology is familiar

Action: Execute immediately
```

### 70-89% Confidence: PRESENT ALTERNATIVES

```yaml
Criteria:
  - Some ambiguity in requirements
  - Multiple valid approaches exist
  - Novel technology involved

Action:
  1. Present 2-3 approach options
  2. Explain trade-offs for each
  3. Let user choose direction
  4. Then proceed with chosen approach
```

### <70% Confidence: MUST ASK

```yaml
Criteria:
  - Missing critical information
  - Conflicting requirements
  - Unknown technology
  - No similar patterns found

Action:
  1. DO NOT guess or assume
  2. List specific unknowns
  3. Ask targeted questions
  4. Wait for user response
  5. Re-assess after answers
```

## Implementation

### Phase 0 Integration

Confidence Gate runs in Phase 0 (Context & Knowledge) of ai-dev workflow:

```
Phase 0: Context & Knowledge
├── Load project snapshot
├── Query knowledge base
├── ★ Run Confidence Gate ★
│   ├── ≥90%: Continue to Phase 1
│   ├── 70-89%: Present alternatives, then Phase 1
│   └── <70%: Ask questions, loop until ≥70%
└── Proceed to next phase
```

### Assessment Template

```markdown
## Confidence Assessment

**Task**: [Task description]

### Factors Evaluated

| Factor | Score | Evidence |
|--------|-------|----------|
| Official Docs | X/25 | [Source or "Not found"] |
| Codebase Patterns | X/25 | [File paths or "None"] |
| Clear Requirements | X/20 | [Specific or ambiguous points] |
| Tech Familiarity | X/15 | [Experience level] |
| Test Coverage | X/15 | [Existing tests or "None"] |

**Total Score**: XX/100

### Decision

- [ ] ≥90%: Proceed immediately
- [ ] 70-89%: Present alternatives
- [ ] <70%: Ask questions below

### Questions (if <70%)

1. [Specific question about unknown]
2. [Clarification needed]
```

## Token Savings Analysis

| Scenario | Without Gate | With Gate | Savings |
|----------|-------------|-----------|---------|
| Wrong direction detected early | 50,000 tokens | 200 tokens | 250x |
| Minor course correction | 10,000 tokens | 400 tokens | 25x |
| Clarification needed | 20,000 tokens | 300 tokens | 67x |

**Average ROI**: 25-250x token savings by preventing wrong-direction work.

## Red Flags

**Never:**
- Proceed with <70% confidence without asking
- Guess at requirements when unsure
- Assume user intent without verification
- Skip confidence check for "simple" tasks

**Always:**
- Check official documentation first
- Look for existing patterns in codebase
- Present alternatives when ambiguous
- Ask specific, targeted questions

## Integration with ai-dev

This skill is automatically invoked in:
- Phase 0 (Context & Knowledge)
- Before any significant implementation decision
- When switching approaches mid-task

## Commands

| Command | Description |
|---------|-------------|
| `/ai:check <task>` | Run confidence assessment |
| `/ai:check --verbose` | Show detailed factor breakdown |
| `/ai:check --force` | Override and proceed anyway |

## Agent Collaboration

| Agent | Role |
|-------|------|
| `ai-dev` | Invokes confidence-gate in Phase 0 |
| `requirement-interviewer` | Handles <70% question flow |
| `@oracle` | Provides strategic assessment input |
| `@librarian` | Finds documentation and patterns |

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 5.0.7 | 2026-01-14 | Initial release, based on SuperClaude PM Agent |
