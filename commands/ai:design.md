---
name: ai:design
description: Design phase - evaluate architecture options and generate design.md
argument-hint: "[--from-proposal]"
allowed-tools: Task, Read, Write, Edit, Grep, Glob, Bash
internal: true
---

Design review for: $ARGUMENTS

**Goal**: Generate 2-3 design approaches, evaluate trade-offs, user selects approach

**Step 1: Load Context**

1. Check for existing proposal:
   - If `--from-proposal`: Load `.agent/changes/active/*/proposal.md`
   - Otherwise: Quick requirement summary from $ARGUMENTS

2. Load constraints:
   - `.agent/design.md` - Architecture constraints
   - `.agent/CLAUDE.md` - AI behavior rules
   - `.agent/constraints.md` - Global constraints

3. Scan related code:
   - Find integration points
   - Identify affected components

**Step 2: Generate Design Options**

Present 2-3 approaches:

```markdown
## Option A: [Name]

**Approach**: Brief description

**Pros**:
- Pro 1
- Pro 2

**Cons**:
- Con 1

**Effort**: S/M/L
**Risk**: Low/Medium/High

**Key Changes**:
- File 1: Change description
- File 2: Change description
```

**Step 3: Trade-off Analysis**

| Criterion | Option A | Option B | Option C |
|-----------|----------|----------|----------|
| Complexity | ⭐⭐ | ⭐⭐⭐ | ⭐ |
| Maintainability | ⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐ |
| Performance | ⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| Risk | Low | Medium | Low |

**Step 4: User Selection**

Ask user to select:
> 请选择设计方案 (A/B/C)，或提出修改意见。

**Step 5: Generate Design Document**

After selection, create `.agent/changes/active/[id]/design.md`:

```markdown
# Design: [Feature Name]

## Selected Approach
[Option X]: [Name]

## Architecture
[Diagram or description]

## Components
| Component | Responsibility | Changes |
|-----------|---------------|---------|

## API Changes
[If applicable]

## Data Model Changes
[If applicable]

## Implementation Notes
- Note 1
- Note 2
```

**Next Step**:
> 设计确认后，运行 `/ai:implement` 开始实现。
