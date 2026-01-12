---
name: ai:status
description: AI development status - show project status, feature list, or feature details
argument-hint: "[--list] [--detailed] [<feature-id>]"
allowed-tools: Read, Bash, Grep, Glob
---

# AI Status Command (Unified)

**Usage:**
- `/ai:status` - Show project status and current progress
- `/ai:status --list` - List all features with status
- `/ai:status <id>` - Show detailed info for specific feature

---

## Mode Detection

Parse $ARGUMENTS to determine mode:

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
test -d codebox && echo "INITIALIZED" || echo "NOT_INITIALIZED"
```

If NOT_INITIALIZED:
```
⚠️ Project not initialized
Run /init to set up AI development environment
```

### Step 2: Gather Status

**Active Changes:**
```bash
ls -la codebox/changes/active/ 2>/dev/null
```

For each active change, check:
- `proposal.md` exists → Phase 1 complete
- `design.md` exists → Phase 2 complete
- `tasks.md` exists → Phase 3 complete
- Task completion % → Phase 4 progress

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

**Goal**: Display all features with their status

### Step 1: Read feature_list.json

```bash
cat codebox/feature_list.json
```

### Step 2: Apply Filters (if specified)

- `--active`: Active features only
- `--archived`: Archived features only
- `--stage=X`: Specific phase

### Step 3: Display List

```
# Feature List

## Summary
- **Total**: 15
- **Active**: 3
- **Completed**: 10

## Active Features
001 🟡 用户登录功能 [Phase 4] 62.5% - 2 issues
002 🟡 数据分析仪表板 [Phase 2] 30% - exploring
003 ⚪ 支付集成 [Phase 1] 0% - pending approval

## Quick Commands
- View details: /ai:status <id>
- Continue work: /ai:dev auto
```

---

## Feature Detail Mode (`<id>`)

**Goal**: Show detailed information for a specific feature

### Step 1: Find Feature

Search in `feature_list.json` by ID or change_id.

If not found:
```
❌ Feature not found: <id>
Use /ai:status --list to see available features
```

### Step 2: Display Details

```markdown
# Feature: [Title]

## Basic Info
- **ID**: 001
- **Change ID**: 001-user-auth
- **Phase**: Phase 4 (Implementation)
- **Status**: in_progress

## Progress
- **Tasks**: 5/8 complete (62.5%)
- **OODA Iterations**: 6/10
- **Quality Score**: 92/100

## Task List
- [x] Task 1: Create IUserRepository interface
- [x] Task 2: Implement UserRepository class
- [ ] Task 3: Add unit tests
- [ ] Task 4: Fix security issues

## Related Files
- changes/active/001-user-auth/proposal.md
- changes/active/001-user-auth/design.md
- changes/active/001-user-auth/tasks.md

## Next Steps
- Complete remaining 3 tasks
- Fix 2 high-confidence issues
```

### Step 3: If Archived

```
⚠️ This feature is archived
Location: changes/archived/2024-01/001-user-auth/
Archived: 2024-01-20 15:30
```

---

## Detailed Mode (`--detailed`)

Add to any mode for extra information:
- Knowledge base stats
- Test coverage summary
- Dependency health check
- Agent execution history
