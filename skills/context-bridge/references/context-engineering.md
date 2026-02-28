# Context Engineering Principles

> Context is attention. Attention is finite. Manage it like a scarce resource.

## The Research → Plan → Reset → Implement Cycle

Long-running agent sessions suffer from **context rot**: the context window fills with investigation artifacts, dead-end explorations, and stale intermediate results. The signal-to-noise ratio drops, and the agent makes increasingly poor decisions.

The fix is a deliberate cycle:

```
┌─────────────────────────────────────────────────┐
│  1. RESEARCH                                     │
│     Agent collects data. Context grows and gets   │
│     messy. This is normal and expected.           │
│                    ↓                             │
│  2. PLAN                                         │
│     Synthesize findings into a high-density       │
│     artifact (PLAN.md). This becomes the single   │
│     source of truth.                              │
│                    ↓                             │
│  3. RESET                                        │
│     Clear the context window (/clear or new       │
│     session). This prevents context rot from       │
│     degrading implementation quality.             │
│                    ↓                             │
│  4. IMPLEMENT                                    │
│     Fresh session reads only the high-density     │
│     plan. No investigation noise. Pure execution. │
│                    ↓                             │
│     (Repeat if implementation reveals new         │
│      unknowns requiring another research cycle)   │
└─────────────────────────────────────────────────┘
```

### When to Reset

| Signal | Action |
|--------|--------|
| Context usage > 70% | Consider reset |
| Agent starts contradicting earlier decisions | Reset immediately |
| Investigation produced a clear plan | Reset before implementing |
| Agent "forgets" the original goal | Reset — this is context rot |

### What Goes Into PLAN.md

Only high-density, decision-relevant content:
- **Decisions made** — not the deliberation process
- **Architecture chosen** — not the alternatives considered
- **Constraints discovered** — not the investigation steps
- **Remaining tasks** — with acceptance criteria

What stays out: search results, code exploration output, conversation fragments, hypotheses that were disproven.

---

## 5 Diagnostic Questions for Context Health

Use these to detect **Context Hoarding Disorder** — the tendency to keep everything in context "just in case."

### 1. What specific decision does this context support?

If the context doesn't support a pending decision, it's dead weight. Remove it.

### 2. Can retrieval replace persistence?

Information that can be re-read from files (via Read/Grep) doesn't need to live in the context window. Only keep what can't be efficiently re-fetched.

### 3. Who owns the context boundary?

Every piece of context should have a clear owner (a specific phase, task, or decision). Orphaned context is a sign of poor architecture.

### 4. What failure would excluding it cause?

If removing a piece of context wouldn't change any decision, it doesn't belong. Be ruthless about this.

### 5. Are we fixing structure or escaping it?

Adding more context is often a substitute for fixing the underlying process. If you keep needing more context to make decisions, the workflow structure is wrong — not the context size.

---

## Application to Context Bridge

These principles inform how Context Bridge operates:

| Principle | Context Bridge Implementation |
|-----------|-------------------------------|
| Research → Plan → Reset | `/ai:session-save` synthesizes to summary → `/clear` → `/ai:session-resume` reads only summary |
| Context is attention | `/focus` refreshes goals to attention window end — Read Before Decide |
| Retrieval > persistence | Session files stored on disk, not held in context. Read on demand. |
| Auto Checkpoint at 90% | Prevents context rot by forcing a save/reset cycle |
| High-density artifacts | `session_summary.md` and `next_steps.md` are the PLAN.md equivalent |

---

## References

- PM Skills `context-engineering-advisor` — original diagnostic framework
- Manus Agent "Read Before Decide" pattern
- "Lost in the Middle" (Liu et al., 2023) — positional attention bias in LLMs
