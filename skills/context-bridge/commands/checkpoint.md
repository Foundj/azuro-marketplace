---
name: checkpoint
version: 4.0.2
description: |
  Save current session progress, generate summary and next steps files.
  Triggers on "checkpoint", "save", "保存进度", "存档".
allowed-tools: Read, Write, Edit, Bash, Grep, Glob
model: sonnet
---

# /checkpoint - 保存 Session 进度

## 执行流程

当用户输入 `checkpoint`、`save`、`保存进度`、`存档` 时，执行以下步骤：

### Step 1: 确认 codebox 目录存在

```bash
# 检查 codebox 目录
if [ ! -d "codebox" ]; then
  echo "⚠️ codebox 目录不存在，请先运行 /init 初始化项目"
  exit 1
fi

# 创建 context 目录
mkdir -p codebox/context/sessions
```

### Step 2: 收集当前状态信息

**2.1 扫描 active changes**
```bash
# 列出所有活跃的变更
active_changes=$(ls codebox/changes/active/ 2>/dev/null)
```

**2.2 读取每个 change 的状态**
对于每个 active change，读取 `state.json` 提取：
- changeId
- currentPhase
- ooda.iterationCount / ooda.maxIterations
- quality.testsStatus
- resumability.blockers

**2.3 读取 tasks.md 进度**
对于每个 active change，读取 `tasks.md` 统计：
- 已完成任务数 (`- [x]`)
- 进行中任务数 (`- [ ]` 且在当前阶段)
- 待办任务数

**2.4 收集 git 信息**
```bash
# 最近 10 条提交
git log --oneline -10

# 本次 session 的文件变更 (最近 4 小时)
git diff --stat HEAD~10..HEAD 2>/dev/null || git diff --stat
```

**2.5 读取 progress.txt 最近条目**
```bash
tail -30 codebox/progress.txt 2>/dev/null
```

### Step 3: 生成 Session Summary

创建/更新 `codebox/context/session_summary.md`：

```markdown
# Session Summary - #{session_number}

**Date**: {YYYY-MM-DD}
**Time**: {HH:MM} - {HH:MM}
**Generated**: {timestamp}

---

## 📊 Session Overview

| Metric | Value |
|--------|-------|
| Tasks Completed | {completed_count} |
| Tasks In Progress | {in_progress_count} |
| Commits Made | {commit_count} |
| Files Changed | {files_changed} |

---

## ✅ Completed This Session

{for each completed task}
- ✅ **{task_name}** ({change_id})
  - Phase: {phase}
  - Time: ~{duration}
{end for}

---

## 🔄 In Progress

{for each in_progress task}
- 🔄 **{task_name}** ({change_id})
  - Phase: {phase}, Step: {step}
  - Progress: {progress_description}
  - Blockers: {blockers or "None"}
{end for}

---

## 📁 Active Changes Status

| Change ID | Title | Phase | Progress | Blockers |
|-----------|-------|-------|----------|----------|
{for each active change}
| {change_id} | {title} | {phase} | {progress} | {blockers} |
{end for}

---

## 🔧 Key Decisions Made

{extract from conversation or state.json}
- {decision_1}
- {decision_2}

---

## ⚠️ Issues Encountered

{extract errors and resolutions}
- **{issue_1}**: {resolution_1}
- **{issue_2}**: {resolution_2}

---

## 📝 Files Changed

```
{git diff --stat output}
```

---

## 💾 Git Commits This Session

```
{git log --oneline output}
```

---

## 🧠 Context for Next Session

### Current State Summary
{1-2 paragraph summary of where we are}

### Key Files to Review
- `{file_1}` - {reason}
- `{file_2}` - {reason}

### Open Questions
- {question_1}
- {question_2}

---

## 🚧 Blockers to Address

{if blockers exist}
- ⚠️ **{blocker_1}**: {description}
  - Suggested fix: {suggestion}
{else}
- ✅ No blockers
{end if}
```

### Step 4: 生成 Next Steps

创建/更新 `codebox/context/next_steps.md`：

```markdown
# Next Steps 📋

> **Generated**: {timestamp}
> **Last Session**: #{session_number}
> **Resume Command**: `resume` 或 `继续`

---

## 🚀 Quick Start

新 Session 开始时，直接输入：
```
resume
```
系统将自动读取此文件并开始执行第一个任务。

---

## 🔴 P0 - 立即处理 (Blockers)

{if P0 tasks exist}
### 1. {task_title}
- **Change**: {change_id}
- **File**: `{file_path}`
- **Issue**: {issue_description}
- **Command**:
  ```
  {ready_to_execute_command}
  ```
{else}
✅ 无阻塞任务
{end if}

---

## 🟡 P1 - 继续进行中的工作

{for each in_progress task}
### {index}. {task_title}
- **Change**: {change_id}
- **Phase**: {phase}
- **Current Step**: {step_description}
- **Next Action**: {next_action}
- **Command**:
  ```
  {ready_to_execute_command}
  ```
{end for}

---

## 🟢 P2 - 可以开始的新任务

{for each pending task with satisfied dependencies}
### {index}. {task_title}
- **Change**: {change_id}
- **Dependencies**: ✅ All satisfied
- **Estimated Time**: ~{estimate}
- **Command**:
  ```
  {ready_to_execute_command}
  ```
{end for}

---

## 📊 Active Changes Overview

| Priority | Change | Phase | Next Action |
|----------|--------|-------|-------------|
{for each active change sorted by priority}
| {priority_emoji} | {change_id} | {phase} | {next_action} |
{end for}

---

## 🎯 Recommended Focus

Based on priority and dependencies:

**Primary**: {primary_task_description}
```
{primary_command}
```

**Alternative**: {alternative_task_description}
```
{alternative_command}
```

---

## 📈 Session Continuity

| Metric | Value |
|--------|-------|
| Previous Session | #{session_number} |
| Ended At | {end_time} |
| Active Changes | {active_count} |
| Pending Tasks | {pending_count} |

---

## 💡 Quick Commands Reference

```bash
# 恢复并继续 (推荐)
resume

# 查看特定变更
/feature-show {change_id}

# 查看所有变更
/feature-list

# 手动开始任务
ai {task_description}
```
```

### Step 5: 归档历史 Session

```bash
# 计算 session 编号
session_count=$(ls codebox/context/sessions/ 2>/dev/null | grep -c "session-" || echo "0")
next_session=$((session_count + 1))
session_id=$(printf "%03d" $next_session)

# 如果存在旧的 session_summary.md，归档它
if [ -f "codebox/context/session_summary.md" ]; then
  # 检查是否是今天的 session (避免重复归档)
  last_modified=$(stat -f "%Sm" -t "%Y-%m-%d" codebox/context/session_summary.md 2>/dev/null || date +%Y-%m-%d)

  # 归档
  cp codebox/context/session_summary.md \
     "codebox/context/sessions/session-${session_id}-${last_modified}.md"
fi
```

### Step 6: 输出确认信息

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Checkpoint Complete - Session #{session_number}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Summary:
   - Tasks Completed: {completed_count}
   - Tasks In Progress: {in_progress_count}
   - Active Changes: {active_count}

📁 Files Generated:
   - codebox/context/session_summary.md
   - codebox/context/next_steps.md

🗄️ Archived:
   - codebox/context/sessions/session-{session_id}.md

🎯 Next Priority:
   {first_priority_task}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
下次开始时输入 "resume" 即可继续
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🔧 实现细节

### 从 state.json 提取信息

```javascript
// 提取关键字段
const extractStateInfo = (stateJson) => ({
  changeId: stateJson.changeId,
  phase: stateJson.currentPhase,
  phaseNames: ['Clarify', 'Discover', 'Design', 'Implement', 'Quality', 'Archive'],
  phaseName: phaseNames[stateJson.currentPhase - 1],
  oodaIteration: stateJson.ooda?.iterationCount || 0,
  oodaMax: stateJson.ooda?.maxIterations || 10,
  testsStatus: stateJson.quality?.testsStatus || 'unknown',
  blockers: stateJson.resumability?.blockers || [],
  canResume: stateJson.resumability?.canResume || true,
  lastSession: stateJson.resumability?.lastSessionTime
});
```

### 从 tasks.md 统计进度

```bash
# 统计任务状态
completed=$(grep -c "^\s*- \[x\]" tasks.md 2>/dev/null || echo "0")
in_progress=$(grep -c "^\s*- \[ \]" tasks.md 2>/dev/null || echo "0")
total=$((completed + in_progress))
```

### 优先级排序逻辑

```
P0 (立即处理):
  - 有 failing tests
  - 有明确的 blockers
  - Phase 4 且接近完成 (>70% OODA iterations)

P1 (继续进行):
  - 当前 in_progress 的任务
  - Phase 4 正在进行中

P2 (可以开始):
  - 依赖已满足
  - Phase 1-3 等待推进
```

---

## ⚠️ 注意事项

1. **不要手动编辑生成的文件** - 这些文件会被下次 checkpoint 覆盖
2. **定期运行 checkpoint** - 建议每完成一个重要任务后运行
3. **历史 sessions 自动清理** - 保留最近 50 个 session
