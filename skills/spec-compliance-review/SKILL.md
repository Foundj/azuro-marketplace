---
name: spec-compliance-review
description: |
  This skill should be used during Phase 5 (Quality Validation) as Stage 1 of the two-stage review process.
  It verifies that implementation matches specification EXACTLY - nothing more, nothing less.
  Triggers on "spec review", "specification check", "规格审查", "compliance check", "符合性检查".
  Must pass before proceeding to Stage 2 code quality review.
version: 5.1.15
status: experimental
triggers:
  - spec review
  - specification check
  - 规格审查
  - compliance check
  - 符合性检查
  - 需求符合性
  - spec-compliance
---

# Spec Compliance Review (Stage 1)

> **Adapted from Superpowers by obra** - Two-stage review for quality assurance.

## 触发词

此技能触发于: "spec review", "specification check", "规格审查", "符合性检查", "需求符合性".

## Core Principle

```
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   FIRST: Ensure we're doing the RIGHT THING                   ║
║   THEN:  Ensure we're doing it RIGHT                          ║
║                                                               ║
║   Spec Compliance Review (this) → Code Quality Review (next)  ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

## Workflow Integration

This skill is integrated into the **Phase 5: Quality Validation** of the `ai-dev` workflow and `ultrawork` mode.

```
[Implementation Complete]
       ↓
[Stage 1: Spec Compliance Review] ← (YOU ARE HERE)
       ↓
   (Issues found?) ── YES ──> [Fix Issues] ──> (Re-run Review)
       ↓
      NO
       ↓
[Stage 2: Code Quality Review]
```

## Purpose

Verify the implementer built **exactly** what was requested:
- Not more (no over-engineering, no "nice to haves")
- Not less (no missing requirements, no shortcuts)
- Not different (no misunderstandings, no wrong interpretations)

## Critical Rule

```
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   DO NOT TRUST THE IMPLEMENTER'S REPORT                       ║
║                                                               ║
║   They finished suspiciously quickly.                         ║
║   Their report may be incomplete, inaccurate, or optimistic.  ║
║   You MUST verify everything independently by reading code.   ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

## Review Checklist

### 1. Missing Requirements

Ask yourself:
- Did they implement **everything** that was requested?
- Are there requirements they skipped or missed?
- Did they claim something works but didn't actually implement it?
- Are there edge cases mentioned in spec but not handled?

**How to check:**
```
1. List each requirement from the spec
2. Find the corresponding code for each
3. Verify the code actually does what was required
4. Mark: ✅ Implemented / ❌ Missing
```

### 2. Extra/Unneeded Work

Ask yourself:
- Did they build things that **weren't requested**?
- Did they over-engineer or add unnecessary features?
- Did they add "nice to haves" that weren't in spec?
- Did they add options/configurations not asked for?

**Common YAGNI violations:**
- Adding optional parameters nobody asked for
- Implementing retry/backoff when spec didn't mention it
- Adding logging beyond what was requested
- Creating abstractions for things used only once
- Adding "future-proofing" code

### 3. Misunderstandings

Ask yourself:
- Did they interpret requirements **differently** than intended?
- Did they solve the **wrong problem**?
- Did they implement the right feature but the **wrong way**?
- Did they confuse similar-sounding requirements?

## Report Format

### If Spec Compliant

```markdown
## Spec Compliance Review: ✅ PASS

All requirements verified against implementation:

| Requirement | Status | Location |
|-------------|--------|----------|
| [Req 1]     | ✅     | `src/file.ts:45-67` |
| [Req 2]     | ✅     | `src/file.ts:89-102` |
| [Req 3]     | ✅     | `tests/test.ts:23-45` |

No extra features found.
No misunderstandings detected.

→ Proceed to Code Quality Review
```

### If Issues Found

```markdown
## Spec Compliance Review: ❌ ISSUES FOUND

### Missing Requirements

| Requirement | Expected | Actual |
|-------------|----------|--------|
| [Req 1]     | Handle empty input | Not implemented |
| [Req 2]     | Return error on failure | Returns null instead |

**Location:** `src/file.ts:45` - Missing validation

### Extra/Unneeded Work

| Feature | Why Unneeded |
|---------|--------------|
| Retry logic | Not in spec - YAGNI violation |
| JSON output flag | Not requested |

**Location:** `src/file.ts:78-95` - Remove this code

### Misunderstandings

| Requirement | Expected | Actual |
|-------------|----------|--------|
| "Validate email" | Check format | Only checks non-empty |

**Location:** `src/file.ts:23` - Wrong interpretation

---

**Action Required:** Implementer must fix issues above.
After fixes → Re-run Spec Compliance Review.
Do NOT proceed to Code Quality Review until ✅ PASS.
```

## Usage as Subagent

```yaml
Task Tool:
  subagent_type: "general-purpose"
  description: "Review spec compliance for Task N"
  prompt: |
    You are reviewing whether an implementation matches its specification.

    ## What Was Requested

    [FULL TEXT of task requirements - paste here]

    ## What Implementer Claims They Built

    [From implementer's report]

    ## Files Changed

    [List of files to review]

    ## CRITICAL: Do Not Trust the Report

    The implementer finished suspiciously quickly. Their report may be
    incomplete, inaccurate, or optimistic. You MUST verify everything
    independently.

    **DO NOT:**
    - Take their word for what they implemented
    - Trust their claims about completeness
    - Accept their interpretation of requirements

    **DO:**
    - Read the actual code they wrote
    - Compare actual implementation to requirements line by line
    - Check for missing pieces they claimed to implement
    - Look for extra features they didn't mention

    ## Your Job

    Read the implementation code and verify:

    **Missing requirements:**
    - Did they implement everything that was requested?
    - Are there requirements they skipped or missed?
    - Did they claim something works but didn't actually implement it?

    **Extra/unneeded work:**
    - Did they build things that weren't requested?
    - Did they over-engineer or add unnecessary features?
    - Did they add "nice to haves" that weren't in spec?

    **Misunderstandings:**
    - Did they interpret requirements differently than intended?
    - Did they solve the wrong problem?
    - Did they implement the right feature but wrong way?

    **Verify by reading code, not by trusting report.**

    Report:
    - ✅ Spec compliant (if everything matches after code inspection)
    - ❌ Issues found: [list specifically what's missing or extra, with file:line]
```

## Review Loop

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   Implementer completes task                                │
│           ↓                                                 │
│   Spec Compliance Review                                    │
│           ↓                                                 │
│   ┌─────────────────────────────────────────┐               │
│   │ Issues found?                           │               │
│   │   YES → Implementer fixes → Re-review   │──────┐        │
│   │   NO  → Proceed to Code Quality         │      │        │
│   └─────────────────────────────────────────┘      │        │
│           ↓                                        │        │
│   (loop until ✅ PASS)  ←──────────────────────────┘        │
│           ↓                                                 │
│   Code Quality Review (Stage 2)                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Red Flags

**Never:**
- Proceed to Code Quality Review with spec issues
- Accept "close enough" on spec compliance
- Skip re-review after fixes
- Trust implementer's self-assessment

**Always:**
- Read actual code, not just report
- Check each requirement individually
- Look for YAGNI violations
- Require complete compliance before next stage

## Integration

**Called by:**
- `ultrawork` - Stage 1 of two-stage review
- `subagent-driven-development` - After each task

**Must pass before:**
- `code-reviewer` - Stage 2 code quality review

**Pairs with:**
- `tdd-enforcement` - Ensures tests cover requirements

---

## Dependencies

- Requires `ultrawork` or `subagent-driven-development` as caller
- Works with `code-reviewer` for Stage 2 review

---

## Version History

| Version | Changes |
|---------|---------|
| 5.0.20 | Added Chinese triggers and dependencies |
| 5.0.0 | Initial release with two-stage review pattern |
