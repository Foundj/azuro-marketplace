# Design Rationale

> Why interaction-protocol exists and the patterns it draws from.

## Origin

Extracted from the PM Skills project's `workshop-facilitation` pattern, which serves as "Facilitation Source of Truth" for 20+ interactive skills. The core insight: when multiple skills define their own conversation behavior independently, users get inconsistent experiences and each new skill reinvents the wheel.

## Key Design Decisions

### Domain logic always wins

The protocol governs *how* to converse (entry modes, progress labels, option formatting). The referencing skill governs *what* to discuss (questions, outputs, domain rules). On conflict, the referencing skill wins. This prevents the protocol from becoming a bottleneck.

### Three entry modes, not two

Early drafts had only Guided and Quick. Adding Context dump eliminated the friction of re-answering questions when the user already has a spec, PRD, or partial context from a previous session.

### Progress labels use skill-defined phases

Rather than generic `Q1/N`, labels read `[Context Q3/6]` or `[Design Q2/4]`. The phase name comes from the referencing skill, making progress meaningful in context.

### Decision points vs. quick-select

Two distinct option patterns serve different purposes:
- **Decision points**: meaningful forks (3-5 options with trade-offs). Used sparingly.
- **Quick-select**: routine choices with obvious defaults. Used freely.

Conflating them leads to "option fatigue" where users see numbered lists on every question.

## References

- PM Skills `workshop-facilitation` — original inspiration
- Nielsen Norman Group: "One Thing Per Page" pattern
- Conversational UI best practices: progressive disclosure in chatbots
