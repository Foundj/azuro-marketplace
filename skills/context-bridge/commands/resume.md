---
name: resume
version: 4.0.2
description: |
  Resume context and automatically continue executing previous tasks.
  Triggers on "resume", "continue", "继续", "恢复", "接着做".
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task
model: sonnet
---

# /resume - 恢复并继续执行

## 执行流程

当用户输入 `resume`、`continue`、`继续`、`恢复`、`接着做` 时，执行以下步骤：

### Step 1: 检查 Context 文件存在

```bash
# 检查必要文件
if [ ! -f "codebox/context/next_steps.md" ]; then
  echo "⚠️ 未找到 next_steps.md"
  echo "可能是首次运行，请先使用 /checkpoint 保存进度"
  echo "或使用 session-manager 进行完整恢复"
  exit 1
fi
```

### Step 2: 读取上下文文件

**2.1 读取 next_steps.md**
```bash
cat codebox/context/next_steps.md
```

提取关键信息：
- 上次 session 编号和时间
- P0/P1/P2 任务列表
- 推荐的第一个任务
- 可执行的命令

**2.2 读取 session_summary.md (如果存在)**
```bash
cat codebox/context/session_summary.md 2>/dev/null
```

提取：
- 上次完成的工作
- 当前进行中的任务
- 已知的 blockers
- 上下文摘要

**2.3 验证 active changes 状态**
```bash
for state_file in codebox/changes/active/*/state.json; do
  # 验证文件存在且有效
  jq -e '.changeId' "$state_file" > /dev/null 2>&1

  # 检查 resumability
  can_resume=$(jq -r '.resumability.canResume // true' "$state_file")

  if [ "$can_resume" = "false" ]; then
    echo "⚠️ Change $(jq -r '.changeId' "$state_file") 不可恢复"
  fi
done
```

### Step 3: 显示恢复报告

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 Session Resumed - Starting #{new_session_number}
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📅 Last Session: #{last_session_number}
⏰ Ended: {last_end_time} ({time_ago})

📊 Quick Recap:
   ✅ Completed: {completed_summary}
   🔄 In Progress: {in_progress_summary}
   ⚠️ Blockers: {blockers_count}

🔍 State Validation:
   ✅ context/next_steps.md - found
   ✅ context/session_summary.md - found
   ✅ Active changes: {active_count} validated

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 4: 确定第一优先任务

**优先级逻辑**:

```
Priority Order:
1. P0 - Blockers (failing tests, critical errors)
2. P1 - In Progress tasks (继续未完成的工作)
3. P2 - Ready to start (可以开始的新任务)
```

**从 next_steps.md 解析**:

```bash
# 提取 P0 任务
p0_task=$(grep -A 5 "## 🔴 P0" next_steps.md | grep -E "^\s*-|^\s*\*|^###" | head -1)

# 如果没有 P0，提取 P1
if [ -z "$p0_task" ] || [[ "$p0_task" == *"无阻塞"* ]]; then
  p1_task=$(grep -A 5 "## 🟡 P1" next_steps.md | grep -E "^\s*-|^\s*\*|^###" | head -1)
fi

# 提取可执行命令
command=$(grep -A 10 "## 🎯 Recommended Focus" next_steps.md | grep "^ai " | head -1)
```

### Step 5: 显示任务并请求确认 (可选)

```
🎯 First Priority Task:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{task_description}

Change: {change_id}
Phase: {phase_name}
File: {relevant_file}

Command to execute:
  {command}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

**两种模式**:

1. **Auto-execute (默认)**: 直接开始执行
2. **Confirm first**: 显示任务后等待用户确认

### Step 6: 自动执行任务 ⭐ 关键步骤

**这是 resume 的核心价值 - 不仅读取，还自动继续执行！**

```
🚀 Auto-starting task...
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

{开始执行任务...}
```

**执行方式**:

根据任务类型选择执行方式：

```
任务类型              执行方式
─────────────────────────────────────────────
修复 failing tests → 分析测试文件，定位问题，修复
继续 OODA loop     → 读取 state.json，继续迭代
完成 Phase 任务    → 读取 tasks.md，执行下一步
开始新任务         → 触发 ai-dev workflow
```

### Step 7: 更新 Session 状态

```bash
# 更新 resumability.lastSessionTime
current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

for state_file in codebox/changes/active/*/state.json; do
  jq --arg time "$current_time" \
     '.resumability.lastSessionTime = $time' \
     "$state_file" > tmp.json && mv tmp.json "$state_file"
done
```

---

## 📋 完整执行示例

### 示例 1: 有 Failing Tests 的情况

```
你: "resume"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 Session Resumed - Starting #6
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📅 Last Session: #5
⏰ Ended: 2025-01-09 18:30 (14 hours ago)

📊 Quick Recap:
   ✅ Completed: Task 4 (login API), Task 5 (password validation)
   🔄 In Progress: Task 6 (Integration tests)
   ⚠️ Blockers: 4 failing tests

🔍 State Validation:
   ✅ context/next_steps.md - found
   ✅ context/session_summary.md - found
   ✅ Active changes: 2 validated

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 First Priority Task (P0 - Blocker):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

修复 AuthService.test.ts 中的 4 个 failing tests

Change: 001-user-auth
Phase: 4 (Implementation)
File: src/auth/__tests__/AuthService.test.ts

Issues:
  1. Line 45: token refresh timeout
  2. Line 67: missing error handling
  3. Line 89: mock configuration
  4. Line 112: async handling

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 Auto-starting fix...

[Claude 开始分析 AuthService.test.ts...]
[定位第一个 failing test...]
[修复 token refresh timeout 问题...]
[继续修复其他测试...]
```

### 示例 2: 无 Blockers，继续 OODA

```
你: "继续"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 Session Resumed - Starting #7
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📅 Last Session: #6
⏰ Ended: 2025-01-10 12:00 (2 hours ago)

📊 Quick Recap:
   ✅ Completed: Fixed 4 failing tests
   🔄 In Progress: Task 6 → Task 7
   ⚠️ Blockers: None ✅

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🎯 First Priority Task (P1 - Continue):
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

继续 001-user-auth OODA Loop

Change: 001-user-auth
Phase: 4 (Implementation)
OODA: Iteration 7/10

Current Task: Task 7 - API Documentation
Next Action: Document AuthService endpoints

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

🚀 Continuing OODA loop...

[读取 tasks.md 获取当前任务详情...]
[开始 Task 7: API Documentation...]
```

### 示例 3: 首次运行 (无 Context 文件)

```
你: "resume"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ No Context Found
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

未找到 codebox/context/next_steps.md

这可能是因为：
1. 这是首次运行 context-bridge
2. 上次 session 未保存 checkpoint
3. context 目录被删除

建议操作：
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. 如果有 active changes，使用 session-manager:
   → 输入: "status" 或 "progress"

2. 如果需要完整恢复:
   → 输入: session-manager 完整恢复

3. 如果要开始新工作:
   → 输入: "ai {task description}"

4. 创建首个 checkpoint:
   → 完成一些工作后输入: "checkpoint"

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🔧 高级选项

### resume --show (仅显示，不执行)

```bash
resume --show  # 或 "next" 命令
```

只显示下一步任务，不自动执行。适用于想先了解情况再决定的场景。

### resume --full (完整恢复)

```bash
resume --full
```

调用 session-manager 进行完整恢复（10步序列），适用于长时间中断后。

### resume {change_id} (恢复特定变更)

```bash
resume 001-user-auth
```

只恢复并继续指定的变更，忽略其他 active changes。

---

## 🔗 与其他命令配合

```
/checkpoint  →  保存进度，生成 next_steps.md
     ↓
/resume      →  读取 next_steps.md，自动继续
     ↓
/checkpoint  →  再次保存...
```

**循环使用**:
```
Session 1: 工作... → checkpoint
Session 2: resume → 继续工作... → checkpoint
Session 3: resume → 继续工作... → checkpoint
...
```

---

## ⚠️ 注意事项

1. **resume 会自动开始执行任务** - 如果只想查看状态，使用 `resume --show` 或 `/next`
2. **确保上次 checkpoint 正确保存** - 如果 next_steps.md 内容不对，可以手动编辑或重新 checkpoint
3. **长时间中断后建议使用 session-manager** - resume 适合短时间中断，完整恢复请用 session-manager

---

## 💡 最佳实践

1. **每次 session 结束前 checkpoint**
2. **新 session 开始直接 resume**
3. **遇到问题时先 checkpoint 保存思路**
4. **resume 后检查任务是否正确**
