# Context Compression Reference

> Extracted from Agent-Skills-for-Context-Engineering

## Core Insight

The correct optimization target is **tokens-per-task** (total tokens to complete a task), not tokens-per-request. Compression that loses critical details causes re-fetching, wasting more tokens than it saves.

## Compression Approaches

| Approach | Compression | Quality | Trade-off |
|----------|-------------|---------|-----------|
| Anchored Iterative | 98.6% | 3.70 | Best quality, slightly less compression |
| Regenerative | 98.7% | 3.44 | Good quality, moderate compression |
| Opaque | 99.3% | 3.35 | Best compression, quality loss |

**Key insight**: 0.7% additional tokens buys 0.35 quality points. Worth it when re-fetching costs matter.

## The Artifact Trail Problem

**Weakest dimension across all methods** (2.2-2.5 out of 5.0).

Coding agents need to track:
- Which files were created/modified
- What changed in each file
- Which files were read but not changed
- Function names, variable names, error messages

**Solution**: Maintain separate artifact index or explicit file-state tracking.

## Structured Summary Sections

```markdown
## Session Intent
[What the user is trying to accomplish]

## Files Modified
- auth.controller.ts: Fixed JWT token generation
- config/redis.ts: Updated connection pooling
- tests/auth.test.ts: Added mock setup

## Decisions Made
- Using Redis connection pool instead of per-request
- Retry logic with exponential backoff

## Current State
- 14 tests passing, 2 failing
- Remaining: mock setup for session service tests

## Next Steps
1. Fix remaining test failures
2. Run full test suite
3. Update documentation
```

**Why structure matters**: Each section is a checklist the summarizer must populate, preventing silent information drift.

## Compression Triggers

| Strategy | Trigger Point | Trade-off |
|----------|---------------|-----------|
| Fixed threshold | 70-80% utilization | Simple but may compress too early |
| Sliding window | Last N turns + summary | Predictable context size |
| Importance-based | Low-relevance first | Complex but preserves signal |
| Task-boundary | Logical task completions | Clean summaries, unpredictable timing |

**Recommended**: Sliding window with structured summaries.

## Three-Phase Compression (Large Codebases)

For systems exceeding context windows (5M+ tokens):

### Phase 1: Research
- Produce research document from architecture, docs, interfaces
- Output: Single research document

### Phase 2: Planning
- Convert research into implementation specification
- 5M token codebase → ~2,000 words specification
- Output: Structured spec with function signatures, types

### Phase 3: Implementation
- Execute against specification
- Context focused on spec, not raw codebase

## Probe-Based Evaluation

Traditional metrics (ROUGE, embedding similarity) miss functional quality.

| Probe Type | What It Tests | Example Question |
|------------|---------------|------------------|
| Recall | Factual retention | "What was the original error?" |
| Artifact | File tracking | "Which files have we modified?" |
| Continuation | Task planning | "What should we do next?" |
| Decision | Reasoning chain | "What did we decide about Redis?" |

## Evaluation Dimensions

| Dimension | What It Measures | Variation |
|-----------|------------------|-----------|
| Accuracy | Technical details correct | Largest (0.6 point gap) |
| Context Awareness | Reflects current state | Moderate |
| Artifact Trail | File tracking | Universally weak (2.2-2.5) |
| Completeness | Addresses all parts | Moderate |
| Continuity | Can work continue? | High |
| Instruction Following | Respects constraints | Moderate |

## Application to ai-dev

| Component | Compression Strategy |
|-----------|---------------------|
| OODA Loop | Anchored iterative (preserve task state) |
| Phase 0 Context | Structured summary (patterns, errors) |
| Evidence.md | Task-boundary (after exploration) |
| Knowledge Base | None (already structured) |

## Guidelines

1. Optimize for tokens-per-task, not tokens-per-request
2. Use structured summaries with explicit file sections
3. Trigger compression at 70-80% context utilization
4. Implement incremental merging, not full regeneration
5. Test quality with probe-based evaluation
6. Track artifact trail separately if file tracking is critical
7. Accept slightly lower compression for better quality
8. Monitor re-fetching frequency as quality signal

## Anchored Iterative Implementation

```python
def compress_anchored(existing_summary, new_content):
    """
    1. Summarize only newly-truncated content
    2. Merge into existing summary sections
    3. Preserve explicit sections (files, decisions, next steps)
    """
    new_summary = summarize_structured(new_content)
    return merge_sections(existing_summary, new_summary)
```
