---
description: Automatically complete all unchecked tasks in the active change - wrapper for /ai:loop
argument-hint: [--dry-run] [--from-task N.N]
allowed-tools: Task, Read, Write, Edit, Grep, Glob, Bash
---

AI Auto-Complete: $ARGUMENTS

**Goal**: Automatically complete all remaining unchecked tasks in the active change.
Wrapper around `/ai:loop` that reads from `codebox/changes/active/*/tasks.md`.

## Step 1: Parse Options

**Options**:
- `--dry-run`: Preview tasks without executing
- `--from-task N.N`: Start from specific task (e.g., `1.3`)

---

## Step 2: Find Active Change

```bash
# Locate active change
ACTIVE_CHANGE=$(find codebox/changes/active -maxdepth 1 -type d ! -name "active" 2>/dev/null | head -1)
TASKS_FILE="${ACTIVE_CHANGE}/tasks.md"
```

**If no active change exists**:
```
❌ No active change found.

To start a new change, use:
  /ai:dev <feature-description>
  or
  /ai:loop <task-description>
```

---

## Step 3: Analyze Task Status

Read `tasks.md` and count:

```
📋 Task Analysis
━━━━━━━━━━━━━━━━
Change ID: add-user-login
Tasks File: codebox/changes/active/add-user-login/tasks.md

📊 Status:
  ✅ Completed: 3
  ⏳ Remaining: 5
  📊 Progress: 37.5%

⏳ Remaining Tasks:
  - [ ] 1.4 Add Zod validation schemas
  - [ ] 2.1 Create login API endpoint
  - [ ] 2.2 Create signup API endpoint
  - [ ] 3.1 Add unit tests for AuthService
  - [ ] 3.2 Add integration tests
```

**If all tasks complete**:
```
✅ All tasks already complete!

📊 Final Status:
  - 8/8 tasks completed
  - Tests: Passing
  - Build: Clean

Nothing to do. Use /ai:status for details.
```

---

## Step 4: Execute (unless --dry-run)

**If `--dry-run`**:
```
🔍 Dry Run Mode - No changes will be made

Would execute 5 remaining tasks:
  1. 1.4 Add Zod validation schemas
  2. 2.1 Create login API endpoint
  3. 2.2 Create signup API endpoint
  4. 3.1 Add unit tests for AuthService
  5. 3.2 Add integration tests

Run without --dry-run to execute.
```

**Otherwise**, invoke OODA loop:

```
🚀 Starting AI Auto-Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Change: add-user-login
Remaining: 5 tasks
Max Iterations: 100

Starting OODA loop...
```

Then execute same logic as `/ai:loop`:
1. Read next unchecked task
2. Execute task
3. Update checkbox
4. Run tests
5. Continue until all complete
6. Output `<promise>DONE</promise>`

---

## Step 5: Completion

**On success**:
```
🎉 AI Auto-Complete Finished!
━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Results:
  - Tasks: 8/8 complete
  - Iterations: 12
  - Tests: ✅ All passing
  - Build: ✅ Clean

<promise>DONE</promise>
```

---

## Differences from /ai:loop

| Feature | /ai:loop | /ai:auto |
|---------|----------|----------|
| Task source | User-specified or tasks.md | Only tasks.md |
| Create new change | Yes | No, must exist |
| Best for | New tasks or continuing | Resuming existing work |
| Dry-run option | No | Yes |
| From-task option | No | Yes |

---

## Usage Examples

```bash
# Auto-complete all remaining tasks
/ai:auto

# Preview without executing
/ai:auto --dry-run

# Start from specific task
/ai:auto --from-task 2.1

# Combination
/ai:auto --dry-run --from-task 1.4
```

---

## Error Handling

**No active change**:
- Suggest using `/ai:dev` or `/ai:loop` first

**Tasks file missing**:
- Check if change was properly initialized
- Suggest re-running task breakdown phase

**All tasks already complete**:
- Report success and exit
- No OODA loop needed
