# Project Structure

## codebox/ Directory

项目 AI 配置和状态管理目录结构：

```
codebox/                          # Project AI configuration
├── config.json                   # Project config
├── requirements.md               # Global requirements (EARS format)
├── design.md                     # Architecture constraints
├── CLAUDE.md                     # AI behavior rules
├── project-snapshot.json         # Project scan result
├── feature_list.json             # Feature tracking
│
├── knowledge/                    # Knowledge base
│   ├── patterns.json             # Success patterns
│   ├── errors.json               # Historical errors
│   └── learnings.md              # Insights
│
├── research/                     # Competitor research
│   └── [feature]-research.json
│
├── context/                      # Lite Mode files (context-bridge)
│   ├── tasks.md                  # Current tasks
│   ├── progress.md               # Progress tracking
│   └── current_focus.md          # Active focus
│
└── changes/                      # Change management
    ├── active/[id]/              # Current change
    │   ├── proposal.md
    │   ├── design.md
    │   ├── tasks.md
    │   ├── phase0-context.md
    │   └── state.json
    └── archived/YYYY-MM/         # Completed changes
```

## State Files

### state.json

```json
{
  "phase": 4,
  "iteration": 12,
  "tasksCompleted": 5,
  "tasksTotal": 7,
  "lastActivity": "2024-01-15T10:30:00Z"
}
```

### tasks.md Format

```markdown
# Tasks for [Feature Name]

## Phase 4: Implementation

- [x] Task 1 description
  - verify_with: `npm test -- --grep "task1"`
- [ ] Task 2 description
  - verify_with: `bash scripts/check-task2.sh`
- [ ] Task 3 description
  - verify_with: true  # Skip verification
```
