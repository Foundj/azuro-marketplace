---
name: context-compressor
description: |
  This skill provides intelligent context compression for long-running workflows.
  It summarizes subagent results, archives detailed outputs, and keeps main context
  lean. Use when context window is filling up, during long ultrawork sessions,
  or when the user mentions "compress context", "summarize", "archive results",
  "上下文压缩", "结果归档".
version: 6.0.7
status: ga
profile: default
triggers:
  - compress context
  - summarize results
  - archive results
  - context too long
  - 上下文压缩
  - 结果归档
  - summarize subagent
  - trim context
---

# Context Compressor

> Keep the main context lean while preserving essential information.

## 触发词

此技能触发于: "compress context", "summarize results", "上下文压缩", "结果归档".

## Problem

```
┌─────────────────────────────────────────────────────────────┐
│                    CONTEXT BLOAT PROBLEM                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Subagent 1 result: 500 lines of code + output             │
│  Subagent 2 result: 300 lines of code + output             │
│  Subagent 3 result: 400 lines of code + output             │
│  ...                                                         │
│                                                              │
│  Main context: 200K+ tokens → SLOW, EXPENSIVE, ERROR-PRONE │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Solution

```
┌─────────────────────────────────────────────────────────────┐
│                    CONTEXT COMPRESSION                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Subagent result → Extract key info → 1-2 sentences        │
│                  ↓                                           │
│  Archive full result to codebox/archive/                     │
│                  ↓                                           │
│  Keep only summary in main context                           │
│                                                              │
│  Main context: 20K tokens → FAST, CHEAP, CLEAR              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Compression Algorithm

### Step 1: Identify Compressible Content

```yaml
Compressible:
  - Full code listings (keep file paths only)
  - Test output (keep pass/fail summary)
  - Error traces (keep resolution)
  - Verbose explanations (keep key points)

NOT Compressible:
  - Active task descriptions
  - File paths being modified
  - Unresolved blockers
  - User instructions
```

### Step 2: Extract Key Information

```markdown
## Template: Subagent Result Summary

### Task: [Task Name]
**Status**: ✅ Complete / ❌ Failed
**Files Changed**: `path/to/file1.ts`, `path/to/file2.ts`
**Tests**: X passing, Y failing
**Key Changes**: [1-2 sentences]
**Concerns**: [Any blockers or notes]
**Archive**: `codebox/archive/task-N.md`
```

### Step 3: Archive Full Content

```bash
# Create archive
mkdir -p codebox/archive

# Archive subagent result
cat > codebox/archive/task-N.md << 'EOF'
# Task N: [Name]

## Full Report
[Complete subagent output]

## Implementation Details
[Full code, test output, etc.]

## Timestamp
[ISO 8601]
EOF
```

## Integration with Ultrawork

### Phase 5: After Each Subagent Completes

```yaml
On Subagent Complete:
  1. Extract:
     - What was implemented (1-2 sentences)
     - Files changed (list only)
     - Test results (pass/fail counts)
     - Any concerns

  2. Archive:
     - Full report → codebox/archive/task-N.md
     - Include timestamp and task ID

  3. Update Active:
     - codebox/changes/active.md with summary only
     - Mark task complete with ✅

  4. Context Cleanup:
     - Do NOT include full code in main context
     - Do NOT include verbose test output
     - Keep summary only
```

### Phase 7: Before Continuation

```yaml
Before Next Task:
  1. Check context size estimate
  2. If > 50K tokens of subagent results:
     - Run compression
     - Archive all completed tasks
     - Keep only summaries
  3. Continue with clean context
```

## Compression Triggers

### Automatic Triggers

```yaml
Trigger compression when:
  - 3+ subagents have completed
  - Context contains > 10K lines
  - User requests "compress" or "summarize"
  - Entering Phase 6 (Review) after Phase 5
```

### Manual Trigger

```
User: "compress context"
User: "summarize results so far"
User: "archive completed tasks"

Action:
  1. Identify all completed subagent results
  2. Apply compression algorithm
  3. Report compression stats
```

## Compression Report

```
╔═══════════════════════════════════════════════════════════════╗
║                    CONTEXT COMPRESSION REPORT                     ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Before: X,XXX lines (~XXK tokens)                           ║
║  After:  XXX lines (~XK tokens)                              ║
║  Reduced: XX%                                                 ║
║                                                               ║
║  Archived:                                                    ║
║    - Task 1: codebox/archive/task-1.md                       ║
║    - Task 2: codebox/archive/task-2.md                       ║
║    - Task 3: codebox/archive/task-3.md                       ║
║                                                               ║
║  Summary in active.md:                                        ║
║    - [x] Task 1: Setup ✅                                     ║
║    - [x] Task 2: Core ✅                                      ║
║    - [x] Task 3: Tests ✅                                     ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

## Common Pitfalls

### Pitfall 1: 过早压缩未完成的任务

**症状**: 将进行中的任务结果也压缩归档
**后果**: 丢失调试所需的详细上下文，需要重新执行 subagent
**修正**: 只压缩状态为 ✅ Complete 的任务，保留 in-progress 任务的完整上下文

### Pitfall 2: 归档后忘记保留文件路径

**症状**: 压缩摘要中只有 "已修改 5 个文件" 而没有具体路径
**后果**: 后续任务需要查看这些文件时无法快速定位
**修正**: 摘要中始终保留完整的文件路径列表（这是最常被回溯查看的信息）

### Pitfall 3: 不区分压缩级别

**症状**: 对所有内容使用相同的压缩策略
**后果**: 关键决策理由被过度压缩，导致后续重复踩坑
**修正**: 按优先级保留：未解决的 blocker > 文件路径 > 测试结果 > 代码细节

## Best Practices

### DO

- Archive immediately after subagent completes
- Keep file paths (you may need to read them later)
- Keep pass/fail counts for each test suite
- Note any concerns or blockers
- Use consistent summary format

### DON'T

- Don't include full code listings
- Don't include verbose test output
- Don't include error traces (just resolution)
- Don't lose track of what was done
- Don't archive before user confirms

## Hook Integration

### PostToolUse Hook (Optional)

```bash
# Auto-compress after every 3 Write/Edit operations
# hooks/scripts/context-compressor-hook.sh

#!/bin/bash
# Check operation count
# If > 3 file modifications:
#   - Suggest compression
#   - Or auto-compress if enabled
```

## Integration with Other Skills

| Skill | Integration |
|-------|-------------|
| `ultrawork` | Auto-compress in Phase 5-7 |
| `subagent-driven-development` | Compress after each subagent |
| `context-bridge` | Use archive for session resume |
| `session-manager` | Include archives in session save |

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 5.0.18 | 2026-02-26 | Initial release with compression algorithm |