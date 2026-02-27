# Context Bridge Templates Reference

This document contains the output templates used by context-bridge for generating session summaries and next steps files.

## Session Summary Template (Mode A - ai-dev)

```markdown
# Session Summary - #{session_number}

**Date**: {YYYY-MM-DD}
**Time**: {HH:MM} - {HH:MM}
**Mode**: ai-dev (7-Phase Workflow)
**Generated**: {timestamp}

---

## Completed This Session

- [ ] {task_1} ({change_id})
- [ ] {task_2} ({change_id})
- [x] {task_3} (in progress → completed)

## Active Changes Status

| Change ID | Phase | Progress | Blockers |
|-----------|-------|----------|----------|
| {change_id} | Phase {n} | {x}/{y} OODA | {blocker_list} |

## Key Decisions Made

- {decision_1}
- {decision_2}

## Errors Encountered

> **Keep Failure Traces** — 错误是学习信号，不应隐藏

| Time | Error | Root Cause | Resolution | Status |
|------|-------|------------|------------|--------|
| {time} | {error_message} | {root_cause} | {resolution} | RESOLVED |
| {time} | {error_message} | {root_cause} | {resolution} | OPEN |

### Lessons Learned
- {lesson_1}
- {lesson_2}

## Files Changed

```
{git diff --stat output}
```

## Git Commits

- {commit_hash} {commit_message}

## Context for Next Session

{1-2 paragraph summary of current state}

## Blockers to Address

- [ ] {blocker_1}: {description}
```

---

## Session Summary Template (Mode B - Standalone)

```markdown
# Session Summary - #{session_number}

**Date**: {YYYY-MM-DD}
**Mode**: Standalone

---

## What We Worked On

{Topic description from conversation context}

## Completed This Session

- [ ] {task_1}
- [ ] {task_2}

## In Progress

- [x] {current_task}

## Key Decisions

- {decision_1}

## Files Changed

```
{git diff --stat output}
```

## Git Commits

```
{git log --oneline -10 output}
```

## Errors & Solutions

> **Keep Failure Traces** — 错误是学习信号

| Time | Error | Root Cause | Solution |
|------|-------|------------|----------|
| {time} | {error} | {cause} | {solution} |

## Context for Next Session

{Conversation summary with key context}

## Next Steps

- {next_step_1}
- {next_step_2}
```

---

## Next Steps Template

```markdown
# Next Steps

> **Generated**: {timestamp}
> **Last Session**: #{session_number}
> **Resume Command**: `resume` or `/ai:session-resume`

---

## Quick Start

New session start command:
```
resume
```

---

## P0 - Immediate (Blockers)

### 1. {task_title}
- **Change**: {change_id}
- **File**: `{file_path}`
- **Issue**: {issue_description}
- **Command**:
  ```
  {ready_to_execute_command}
  ```

---

## P1 - Continue In Progress

### 1. {task_title}
- **Change**: {change_id}
- **Phase**: {phase}
- **Current Step**: {step_description}
- **Next Action**: {next_action}
- **Command**:
  ```
  {ready_to_execute_command}
  ```

---

## P2 - Ready to Start

### 1. {task_title}
- **Change**: {change_id}
- **Dependencies**: All satisfied
- **Command**:
  ```
  {ready_to_execute_command}
  ```

---

## Active Changes Overview

| Priority | Change | Phase | Next Action |
|----------|--------|-------|-------------|
| {priority} | {change_id} | {phase} | {next_action} |

---

## Recommended Focus

**Primary**: {primary_task_description}
```
{primary_command}
```

---

## Session Continuity

| Metric | Value |
|--------|-------|
| Previous Session | #{session_number} |
| Ended At | {end_time} |
| Active Changes | {active_count} |
| Pending Tasks | {pending_count} |
```

---

## Resume Report Template

```markdown
# Session Resumed - Starting #{new_session_number}

**Previous Session**: #{last_session_number}
**Ended**: {last_end_time} ({time_ago})

---

## Quick Recap

| Metric | Value |
|--------|-------|
| Completed | {completed_summary} |
| In Progress | {in_progress_summary} |
| Blockers | {blockers_count} |

---

## State Validation

- [x] context/next_steps.md - found
- [x] context/session_summary.md - found
- [x] Active changes: {active_count} validated

---

## First Priority Task

**{task_description}**

- **Change**: {change_id}
- **Phase**: {phase_name}
- **File**: `{relevant_file}`

**Command**:
```
{command}
```

---

Starting execution...
```

---

## File Naming Conventions

| File | Location | Purpose |
|------|----------|---------|
| `session_summary.md` | `codebox/context/` | Current session summary |
| `next_steps.md` | `codebox/context/` | Next steps for resume |
| `current_focus.md` | `codebox/context/` | Real-time focus (optional) |
| `session-{NNN}.md` | `codebox/context/sessions/` | Archived sessions |

---

## Priority Definitions

| Priority | Symbol | Criteria |
|----------|--------|----------|
| P0 | Red | Failing tests, blockers, critical errors |
| P1 | Yellow | In-progress tasks, continue work |
| P2 | Green | Ready to start, dependencies satisfied |

---

## Focus Refresh Template

```
━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Focus Refresh
━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Current Goal: {goal}
📊 Progress: {completed}/{total} tasks
📁 Active Change: {change_id} (Phase {n}, OODA {x}/{y})

🔴 P0: {p0_task}
🟡 P1: {p1_task}
🟢 P2: {p2_task}
━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Progress Check Template

```
━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Progress Check (Task {current}/{total})
━━━━━━━━━━━━━━━━━━━━━━━━━
Goal: {full_goal_description}
Phase: {phase_number} ({phase_name}) | OODA: {ooda_current}/{ooda_max}

Done:
  ✅ Task 1: {task_1_description}
  ✅ Task 2: {task_2_description}
  ...

Next:
  🔄 Task N: {current_task} (IN PROGRESS)
  ⏳ Task N+1: {next_task}
  ...

Blockers:
  ⚠️ {blocker_1}
  ⚠️ {blocker_2}
━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Lite Mode Templates (v4.2.0 统一命名)

> **v4.2.0 变更**：Lite Mode 使用统一的文件命名和位置
> - 位置：`codebox/context/` (与 Full Mode 相同)
> - 文件：`tasks.md`, `notes.md`, `session_summary.md`

### codebox/context/tasks.md (Lite Mode)

```markdown
# Tasks: {brief_description}

## Goal
{one_sentence_goal}

## Phases
- [ ] Phase 1: Plan and setup
- [ ] Phase 2: Research/gather information
- [ ] Phase 3: Execute/build
- [ ] Phase 4: Review and deliver

## Key Questions
1. {question_1}
2. {question_2}

## Decisions Made
- {decision}: {rationale}

## Errors Encountered

| Time | Error | Root Cause | Resolution |
|------|-------|------------|------------|
| {time} | {error} | {cause} | {resolution} |

## Status
**Currently in Phase X** - {what_doing_now}
```

### codebox/context/notes.md (Lite Mode)

```markdown
# Notes: {topic}

## Sources

### Source 1: {name}
- URL: {link}
- Key points:
  - {finding}
  - {finding}

## Synthesized Findings

### {category_1}
- {finding}
- {finding}

### {category_2}
- {finding}

## Decisions
- {decision}: {rationale}
```

### codebox/context/session_summary.md (Lite Mode)

```markdown
# Session Summary

**Date**: {date}
**Mode**: Lite (3-file pattern)
**Generated**: {timestamp}

## What We Worked On
{topic_description}

## Progress
- Phase 1: {status}
- Phase 2: {status}
- Phase 3: {status}
- Phase 4: {status}

## Key Accomplishments
- {accomplishment_1}
- {accomplishment_2}

## Errors Encountered
| Error | Resolution |
|-------|------------|
| {error} | {resolution} |

## Next Steps
1. {next_step_1}
2. {next_step_2}

---

Resume with: `/lite-resume` or `/ai:session-resume`
```

---

## Lite Mode Focus Refresh Template

```
━━━━━━━━━━━━━━━━━━━━━━━━━
📍 Focus Refresh (Lite Mode)
━━━━━━━━━━━━━━━━━━━━━━━━━
🎯 Goal: {goal_from_tasks.md}
📍 Status: Phase {n} - {phase_description}

Location: codebox/context/

Phases:
  {✅|⏳} Phase 1: Planning
  {✅|🔄|⏳} Phase 2: Research
  {✅|🔄|⏳} Phase 3: Build
  {✅|🔄|⏳} Phase 4: Deliver

Next Action: {from_status_section}
━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Error Output Template

When no focus file exists:

```
━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ No Focus File Found
━━━━━━━━━━━━━━━━━━━━━━━━━
Suggestions:
1. Run /ai:session-save to generate next_steps.md
2. Or run /lite-save to generate task_plan.md
3. Or describe your current goal

Would you like me to create a focus file?
━━━━━━━━━━━━━━━━━━━━━━━━━
```
