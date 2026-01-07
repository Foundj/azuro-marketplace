---
name: ai:loop
description: Self-referential development loop that runs until task completion with <promise>DONE</promise>
argument-hint: "<task-description> [--max-iterations N]"
allowed-tools: Task, Read, Write, Edit, Grep, Glob, Bash
---

Start AI Loop: $ARGUMENTS

**Goal**: Self-referential development loop inspired by oh-my-opencode's Ralph Loop.
Continuously execute tasks until `<promise>DONE</promise>` is detected or max iterations reached.

## Step 1: Parse Options & Initialize

**Options**:
- `--max-iterations N`: Maximum iterations (default: 100)

**Find Active Change**:

```bash
# Locate active change directory
ACTIVE_CHANGE=$(find codebox/changes/active -maxdepth 1 -type d ! -name "active" 2>/dev/null | head -1)
```

If no active change exists:
1. Initialize a new change with the provided task description
2. Create `codebox/changes/active/<change-id>/` directory
3. Generate initial `tasks.md` from task description

---

## Step 2: Pre-Implementation Check (Phase 0)

**Before starting implementation**, run knowledge pre-check:

```
/ai:check $ARGUMENTS
```

This will:
1. Search `codebox/knowledge/` for related implementations
2. Check `feature-index.json` for existing features
3. Load `implementation-constraints.json` for patterns
4. Generate a pre-check report with:
   - Existing implementations to reference
   - Patterns to follow
   - Potential conflicts to avoid

**If duplicates detected**:
- WARN user and ask for confirmation
- Suggest modifying existing implementation instead

**If constraints available**:
- Load into context for enforcement during implementation

---

## Step 3: Load State

Read from `codebox/changes/active/<change-id>/`:
- `tasks.md`: Task checklist (- [ ] format)
- `state.json`: Phase and iteration tracking
- `pre-check-report.md`: Constraints and patterns to follow

```json
{
  "phases": {
    "phase-4-implementation": {
      "ooda_iteration": 0,
      "max_iterations": 100,
      "completion_promise": "PENDING"
    }
  }
}
```

---

## Step 4: OODA Loop Execution

```
┌─────────────────────────────────────────────────────┐
│                    OODA LOOP                         │
├─────────────────────────────────────────────────────┤
│  OBSERVE                                             │
│  - Read current tasks.md                             │
│  - Count completed vs remaining tasks                │
│  - Check test/build status                           │
├─────────────────────────────────────────────────────┤
│  ORIENT                                              │
│  - Identify next unchecked task                      │
│  - Analyze dependencies                              │
│  - Check for blockers                                │
├─────────────────────────────────────────────────────┤
│  DECIDE                                              │
│  - Select task to execute                            │
│  - Plan implementation approach                      │
├─────────────────────────────────────────────────────┤
│  ACT                                                 │
│  - Execute the task                                  │
│  - Update tasks.md checkbox: - [ ] → - [x]           │
│  - Run verification (tests, build)                   │
└─────────────────────────────────────────────────────┘
         ↓
    Check completion:
    ├── All tasks done + tests pass → Output <promise>DONE</promise>
    ├── Max iterations reached → Warn and exit
    └── Tasks remaining → Continue loop
```

---

## Step 5: Notification Strategy

**Progressive Notification** (avoid spam):

| Iteration Range | Notify Every |
|-----------------|--------------|
| 1-10            | 5 iterations |
| 11-50           | 10 iterations |
| 51+             | 20 iterations |

**Special Notifications**:
- ✅ Task completion: Immediately notify
- ⚠️ Near max iterations (90%): Warning
- ❌ No progress for 3 iterations: Alert

**Notification Format**:
```
🔄 AI-Loop: Iteration 15/100
📊 Progress: 4/8 tasks complete (50%)
⏱️ Current task: Implement API endpoint
```

---

## Step 6: Completion Detection

**Exit conditions**:

1. **Success**: All tasks checked + tests pass → Output `<promise>DONE</promise>`
2. **Max iterations**: Reached limit → Warn and exit
3. **User cancel**: `/ai:cancel-loop` command received

**On completion**, update state.json:
```json
{
  "phases": {
    "phase-4-implementation": {
      "completion_promise": "DONE",
      "completed_at": "2025-01-06T12:00:00Z"
    }
  }
}
```

---

## Step 7: Final Verification

Before outputting `<promise>DONE</promise>`:

```bash
# Run verification checks
npm test        # All tests pass
npm run build   # Build succeeds
npm run lint    # No lint errors (optional)
tsc --noEmit    # No TypeScript errors (if applicable)
```

Only output `<promise>DONE</promise>` when ALL checks pass.

---

## Usage Examples

```bash
# Start loop with task description
/ai:loop 实现用户登录功能

# Limit max iterations
/ai:loop "Build REST API" --max-iterations 50

# Continue existing active change
/ai:loop --continue

# Cancel running loop
/ai:cancel-loop
```

---

## Error Handling

**If stuck for 3+ iterations**:
1. Analyze what's blocking progress
2. Consider alternative approach
3. If truly stuck, output summary and ask user for guidance

**If tests fail repeatedly**:
1. Identify failing test
2. Analyze root cause
3. Fix test or code
4. Continue loop

---

## Integration with OODA Stop Hook

This command works in conjunction with `hooks/ooda-stop-hook.sh`:
- The hook monitors for `<promise>DONE</promise>` in output
- Prevents premature exit when tasks remain
- Feeds tasks.md back as prompt to continue loop
