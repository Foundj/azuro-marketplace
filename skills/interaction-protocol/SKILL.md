---
name: interaction-protocol
description: |
  This skill provides standardized multi-turn interaction protocol for all guided skills.
  It defines entry modes (Guided / Context dump / Quick), progress tracking with phase labels,
  decision-point recommendations, quick-select options, flexible input parsing, interruption
  handling, and fast-path output. Use when building or referencing an interactive skill that
  conducts multi-round conversations, or when the user mentions "interaction protocol",
  "交互协议", "对话协议", "引导模式". Referenced by brainstorm-mode, ai-dev-interview,
  multi-agent-discussion as their Facilitation Source of Truth.
version: 6.0.6
status: ga
profile: default
triggers:
  - interaction protocol
  - guided interaction
  - conversation protocol
  - facilitation protocol
  - 交互协议
  - 对话协议
  - 引导模式
  - 多轮对话
---

# Interaction Protocol

> Facilitation Source of Truth for all multi-turn interactive skills.

## Purpose

Define a shared behavioral standard for skills that conduct multi-round conversations with the user. Each referencing skill owns its **domain logic** (what questions to ask, what outputs to produce); this protocol governs **how** the conversation is facilitated.

If a referencing skill's domain logic conflicts with this protocol, the domain logic wins.

## Entry Modes

Open every guided session by offering three entry modes:

| Mode | Behavior |
|------|----------|
| **Guided** (default) | Step-by-step questions, one at a time |
| **Context dump** | User pastes existing context; skip questions already answered |
| **Quick mode** | AI infers missing details, marks assumptions with `[assumed]` |

Prompt format:

```
How would you like to proceed?
1. Guided — I'll walk you through step by step
2. Context dump — Paste what you already have, I'll fill gaps
3. Quick mode — I'll infer details and flag assumptions
```

If the user ignores the prompt and starts talking, default to **Guided**.

## One-Step-at-a-Time

Ask **one core question per turn**. Bundling multiple questions reduces answer quality and overwhelms the user.

Exception: when two questions are tightly coupled (e.g., "What's the scope, and is there an existing implementation?"), combine them.

## Progress Visibility

Show a progress label at the start of each question turn:

```
[Context Q3/6]
What authentication method does the project currently use?
```

Format: `[Phase QN/Total]` where Phase comes from the referencing skill's domain.

Rules:
- Total may increase if follow-up questions are needed — update the denominator
- When a phase completes, announce: `Context complete. Moving to Design.`

## Decision-Point Recommendations

Provide numbered options **only at decision points** — not for every question.

Decision point = a fork where multiple valid approaches exist and the choice materially affects the outcome.

Format:

```
[Design Q2/4]
How should we handle session storage?

1. Server-side sessions (Redis) — simpler, stateful
2. JWT tokens — stateless, scales horizontally
3. Hybrid — JWT for API, sessions for web

Which approach fits best? (number, or describe your preference)
```

Rules:
- 3-5 options maximum
- Each option: label + one-line trade-off
- Always accept free-text as an alternative to numbered selection

## Quick-Select Options

For routine questions where common answers exist, provide quick-select shortcuts:

```
[Context Q4/6]
What's the target deployment environment?

1. Docker/K8s
2. Serverless (AWS Lambda / Vercel)
3. Traditional VPS
4. Other (specify)
```

Rules:
- Include `Other (specify)` as the last option
- Accept mixed input: `1`, `1,3`, `1 and 3`, or free text

## Flexible Parsing

Accept all of these as valid input:
- `1` — select option 1
- `1,3` or `1, 3` — select options 1 and 3
- `1 and 3` or `1 跟 3` — natural language selection
- Free text — interpret as custom answer
- `skip` or `跳过` — skip the question (use sensible defaults)

## Interruption Handling

When the user changes topic mid-flow:

1. **Answer the interruption directly** — don't say "let's get back to..."
2. **After answering**, offer to resume: `Ready to continue? We were on [Phase QN/Total].`
3. If the user doesn't respond to the resume offer, **don't repeat it**

## Fast Path

When the user requests bulk output (e.g., "just give me the result", "一次性输出"):

1. Stop multi-turn questioning
2. Generate the complete output using best-effort inference
3. Mark all inferred values with `[assumed]`
4. Offer: `Review the assumptions above. Reply with corrections, or confirm to proceed.`

## Summary

```
Protocol checklist for referencing skills:

[ ] Offer 3 entry modes at session start
[ ] One core question per turn
[ ] Show progress labels [Phase QN/Total]
[ ] Numbered options only at decision points (3-5 options)
[ ] Quick-select for routine questions (include "Other")
[ ] Parse flexible input (numbers, ranges, free text)
[ ] Handle interruptions: answer first, then offer resume
[ ] Support fast path on user request
```

## Integration

Skills reference this protocol by adding:

```markdown
### Interaction Protocol
Use [`interaction-protocol`](../interaction-protocol/SKILL.md) as the default interaction behavior.
It defines entry modes, progress labels, decision-point recommendations, and interruption handling.
This file defines the domain-specific content. If conflict, follow this file's domain logic.
```

## Dependencies

This skill has no external dependencies. It is a pure behavioral specification referenced by other skills.

**Referenced by:**
- `brainstorm-mode` — Socratic exploration sessions
- `ai-dev-interview` — Requirement interview rounds
- `multi-agent-discussion` — Multi-agent coordination discussions

## Agent Collaboration

| Agent | Role |
|-------|------|
| `brainstorm-mode` | References this protocol for diverge/converge sessions |
| `ai-dev-interview` | References this protocol for requirement interview rounds |
| `multi-agent-discussion` | References this protocol for discussion coordination |

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 5.2.6 | 2026-02-28 | Initial release, extracted from PM Skills workshop-facilitation pattern |
