---
name: ai:status
description: AI development status - show project status, feature list, version overview, or feature details
argument-hint: "[--list] [--versions] [--detailed] [<feature-id>]"
allowed-tools: Read, Bash, Grep, Glob
---

# AI Status Command (Unified)

**Usage:**
- `/ai:status` - Show project status and current progress
- `/ai:status --list` - List all features with status
- `/ai:status --versions` - Show versioned task overview
- `/ai:status <id>` - Show detailed info for specific feature

---

## Mode Detection

Parse $ARGUMENTS to determine mode:

**If argument is `--versions`:**
→ Execute **Version Overview Mode**

**If argument is `--list`:**
→ Execute **Feature List Mode**

**If argument matches feature ID (e.g., `001`, `001-user-auth`):**
→ Execute **Feature Detail Mode**

**Otherwise:**
→ Execute **Project Status Mode**

---

## Project Status Mode (Default)

**Goal**: Display current development state, progress, and recommended next steps

### Step 1: Check Project Initialization

```bash
test -d docs/tasks && echo "INITIALIZED" || echo "NOT_INITIALIZED"
```

If NOT_INITIALIZED:
```
⚠️ Project not initialized
Run /ai:dev <feature> to start your first versioned task
```

### Step 2: Gather Status

**Active Versions:**
```bash
bash skills/task-planner/scripts/check-version-status.sh 2>/dev/null
```

For each active version, check task.md:
- Task completion % from `[x]` vs `[ ]` counts
- Current Sprint progress

**Recent Activity:**
```bash
git log --oneline -5
```

### Step 3: Display Status

```
╔══════════════════════════════════════════════════════╗
║  🤖 AI-Dev Status                                    ║
╠══════════════════════════════════════════════════════╣
║  Project: [name]                                     ║
║  Current Phase: [0-6 or idle]                        ║
║  Active Feature: [name or none]                      ║
╠══════════════════════════════════════════════════════╣
║  📊 Progress                                         ║
║  ├── Total Features: XX                              ║
║  ├── Completed: XX (XX%)                             ║
║  └── In Progress: XX                                 ║
╠══════════════════════════════════════════════════════╣
║  💡 Recommended Next                                 ║
║  └── [action based on current state]                 ║
╚══════════════════════════════════════════════════════╝
```

### Step 4: Recommendations

| State | Recommendation |
|-------|----------------|
| No active change | `/ai:dev <feature>` |
| Has proposal, no design | Continue with `/ai:dev` |
| Tasks in progress | `/ai:dev auto` |
| Tasks complete | Review and commit |

---

## Feature List Mode (`--list`)

**Goal**: Display all versioned features with their status

### Step 1: Read Version Status

```bash
bash skills/task-planner/scripts/check-version-status.sh
```

### Step 2: Apply Filters (if specified)

- `--active`: Active versions only
- `--archived`: Archived versions only

### Step 3: Display List

```
# Version List

## Summary
- **Total**: 3
- **Active**: 1
- **Completed**: 1
- **Archived**: 1

## Active Versions
v2.0 🔄 统一任务架构 [in_progress] 37% - Sprint 2

## Completed/Archived Versions
v1.0 ✅ 产品策略优化 [archived] 100%

## Quick Commands
- View details: /ai:status <version>
- Continue work: /ai:dev auto
```

---

## Feature Detail Mode (`<id>`)

**Goal**: Show detailed information for a specific version

### Step 1: Find Version

Search in `docs/tasks/` by version number (e.g., `v1.0`, `v2.0`).

If not found:
```
❌ Version not found: <id>
Use /ai:status --list to see available versions
```

### Step 2: Display Details

```markdown
# Version: v2.0 — 统一任务架构

## Basic Info
- **Version**: v2.0
- **Status**: in_progress
- **Created**: 2026-03-01

## Progress
- **Tasks**: 5/12 complete (41.6%)
- **Current Sprint**: Sprint 2

## Task List
- [x] s1-1: 创建 task-planner 独立技能
- [x] s1-review: Sprint 1 代码审查
- [ ] s2-1: .agent 完全迁移
- [ ] s2-review: Sprint 2 代码审查

## Related Files
- docs/tasks/v2.0/plan.md
- docs/tasks/v2.0/task.md

## Next Steps
- Complete remaining tasks in Sprint 2
```

### Step 3: If Archived

```
This version is archived
Location: docs/tasks/v1.0/
Archived: 2026-02-28
See: docs/tasks/v1.0/ARCHIVED.md
```

---

## Detailed Mode (`--detailed`)

Add to any mode for extra information:
- Knowledge base stats
- Test coverage summary
- Dependency health check
- Agent execution history

---

## Version Overview Mode (`--versions`)

**Goal**: Display all versioned task plans and their status

### Step 1: Scan Version Directories

```bash
bash skills/task-planner/scripts/check-version-status.sh
```

### Step 2: Display Version Table

```
┌──────────┬──────────────┬────────────┬────────────┐
│ Version  │ Name         │ Status     │ Progress   │
├──────────┼──────────────┼────────────┼────────────┤
│ v1.0     │ 产品策略优化  │ ✅ archived │ 9/9 (100%) │
│ v2.0     │ 统一任务架构  │ 🔄 active   │ 3/8 (37%)  │
└──────────┴──────────────┴────────────┴────────────┘
```

### Step 3: Per-Version Detail

For each version with status `pending` or `in_progress`, show:
- Current Sprint progress
- Next unchecked task
- Blocking issues (if any)

### Step 4: Recommendations

| State | Recommendation |
|-------|----------------|
| No versions | Create first version with `/ai:dev <feature>` |
| Active version exists | Continue with `/ai:dev auto` |
| All versions archived | Start new version |
