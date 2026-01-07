---
name: ai:status
description: AI development status - show current phase, progress, and next steps
argument-hint: "[--detailed]"
allowed-tools: Read, Bash, Grep, Glob
---

Show AI development status

**Goal**: Display current development state, progress, and recommended next steps

**Step 1: Check Project Initialization**

```bash
test -d codebox && echo "INITIALIZED" || echo "NOT_INITIALIZED"
```

If NOT_INITIALIZED:
```
⚠️ Project not initialized
Run /init to set up AI development environment
```

**Step 2: Gather Status**

### Active Changes
```bash
ls -la codebox/changes/active/ 2>/dev/null
```

For each active change, check:
- `proposal.md` exists → Phase 1 complete
- `design.md` exists → Phase 2 complete
- `tasks.md` exists → Phase 3 complete
- Task completion % → Phase 4 progress

### Recent Activity
```bash
git log --oneline -5
```

### File Health
- `feature_list.json`: Feature count
- `progress.txt`: Recent entries
- `knowledge/`: Pattern and error counts

**Step 3: Display Status**

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
║  📁 Active Change                                    ║
║  ├── ID: [change-id]                                 ║
║  ├── Phase: [current phase name]                     ║
║  ├── Tasks: X/Y complete                             ║
║  └── Artifacts: proposal ✓ design ✓ tasks ✓          ║
╠══════════════════════════════════════════════════════╣
║  🔄 Recent Commits                                   ║
║  ├── abc1234 feat: user login                        ║
║  ├── def5678 fix: auth bug                           ║
║  └── ghi9012 refactor: cleanup                       ║
╠══════════════════════════════════════════════════════╣
║  💡 Recommended Next                                 ║
║  └── [action based on current state]                 ║
╚══════════════════════════════════════════════════════╝
```

**Step 4: Detailed Mode (--detailed)**

Additional info:
- Last 5 completed features
- Knowledge base stats (patterns, errors)
- Test coverage summary
- Archived changes list
- Dependency health check

**Step 5: Recommendations**

Based on current state, suggest:

| State | Recommendation |
|-------|----------------|
| No active change | `/ai:interview <feature>` or `/ai:dev <feature>` |
| Has proposal, no design | `/ai:design --from-proposal` |
| Has design, no tasks | `/ai:implement --from-design` |
| Tasks in progress | Continue with `/ai:implement` |
| Tasks complete | `/ai:review` |
| Review complete | Commit and archive |
