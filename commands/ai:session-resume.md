---
name: ai:session-resume
description: 恢复会话上下文并继续执行，或恢复特定功能
argument-hint: "[<feature-id>] [--full] [--show]"
allowed-tools: Bash, Read, Write, Task
---

# /ai:session-resume - 恢复并继续执行

**Usage:**
- `/ai:session-resume` - 快速恢复会话并自动继续 (context-bridge)
- `/ai:session-resume <id>` - 恢复特定功能
- `/ai:session-resume --full` - 完整恢复 (session-manager, 10步验证)
- `/ai:session-resume --show` - 仅显示状态，不执行

---

## Mode Detection

Parse $ARGUMENTS to determine mode:

**If argument is `--full`:**
→ Execute **Full Recovery Mode** (session-manager)

**If argument matches feature ID (e.g., `001`, `001-user-auth`):**
→ Execute **Feature Resume Mode**

**Otherwise:**
→ Execute **Quick Resume Mode** (context-bridge)

---

## Quick Resume Mode (Default)

**Goal**: 恢复上次进度并自动开始下一个任务

### Step 1: 检查 Context 文件

```bash
if [ ! -f "codebox/context/next_steps.md" ]; then
  echo "⚠️ 未找到 next_steps.md，请先使用 /ai:session-save 保存进度"
  exit 1
fi
```

### Step 2: 读取上下文

**读取 next_steps.md:**
- 提取上次 session 信息
- 解析 P0/P1/P2 任务列表
- 获取推荐的第一个任务

**读取 session_summary.md:**
- 获取上次完成的工作
- 了解当前进行中的任务
- 查看已知 blockers

**验证 active changes:**
```bash
for state_file in codebox/changes/active/*/state.json; do
  jq -e '.changeId' "$state_file" > /dev/null 2>&1
  can_resume=$(jq -r '.resumability.canResume // true' "$state_file")
done
```

### Step 3: 显示恢复报告

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 Session Resumed - Starting #6
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📅 Last Session: #5
⏰ Ended: 2025-01-09 18:30 (14 hours ago)

📊 Quick Recap:
   ✅ Completed: Task 4, Task 5
   🔄 In Progress: Task 6
   ⚠️ Blockers: 4 failing tests

🔍 State Validation:
   ✅ context/next_steps.md - found
   ✅ context/session_summary.md - found
   ✅ Active changes: 2 validated
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Step 4: 确定优先任务

**优先级顺序:**
1. P0 - Blockers (failing tests, critical errors)
2. P1 - In Progress tasks (继续未完成的工作)
3. P2 - Ready to start (可以开始的新任务)

### Step 5: 自动执行任务

**关键**: 不仅读取，还自动开始执行第一个任务！

```
🚀 Auto-starting task...

[开始分析并执行任务...]
```

---

## Feature Resume Mode (`<id>`)

**Goal**: 恢复归档功能或继续未完成的工作

### 场景1: 恢复归档功能

1. **搜索归档目录**
   ```bash
   find changes/archived -name "001-user-auth" -type d
   ```

2. **显示归档信息**
   ```markdown
   # 归档功能: 001-user-auth

   - **标题**: 用户登录功能
   - **归档时间**: 2024-01-20 15:30:00
   - **归档原因**: Completed
   - **最终阶段**: Phase 6 (Finalization)
   - **质量评分**: 95/100

   确定要恢复到active吗？
   ```

3. **恢复文件**
   ```bash
   mv "changes/archived/2024-01/001-user-auth" "changes/active/"
   ```

4. **更新 feature_list.json**

### 场景2: 继续未完成的功能 (跨会话恢复)

1. **读取 state.json**
   ```bash
   cat changes/active/001-user-auth/state.json
   ```

2. **分析剩余工作**
   - 已完成任务列表
   - 待完成任务列表
   - OODA 迭代状态

3. **继续 OODA Loop**
   从断点恢复执行

### 显示恢复信息

```markdown
✅ 功能 #001 "用户登录功能" 继续中

## 会话信息
- **上次会话**: 2024-01-21 18:45 (中断)
- **本次会话**: 2024-01-22 10:00 (恢复)
- **中断原因**: Context window limit

## 进度
- **已完成任务**: 5/8 (62.5%)
- **OODA迭代**: 7/10 → 继续
- **完成承诺**: PENDING

## 恢复执行
正在启动OODA loop (iteration 8)...
```

---

## Full Recovery Mode (`--full`)

**Goal**: 完整恢复，调用 session-manager 执行 10 步验证

**适用场景**:
- 长时间中断后
- 环境可能变化
- 需要运行测试验证

**执行步骤**:
1. 检查 pwd
2. 读取 progress.txt
3. 读取 feature_list.json
4. 检查 git 状态
5. 运行 init.sh (如果存在)
6. 运行测试
7. 分析代码变更
8. 读取全局约束
9. 查询知识库
10. 恢复可继续的变更

```
🔍 Full Recovery Mode
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Step 1/10: Checking working directory... ✅
Step 2/10: Reading progress.txt... ✅
Step 3/10: Reading feature_list.json... ✅
Step 4/10: Checking git status... ✅
Step 5/10: Running init.sh... ⏭️ (skipped)
Step 6/10: Running tests... ✅ (42/42 passing)
Step 7/10: Analyzing changes... ✅
Step 8/10: Reading constraints... ✅
Step 9/10: Querying knowledge base... ✅
Step 10/10: Resuming changes... ✅
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 无 Context 文件时

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ No Context Found
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

建议操作：
1. 完整恢复: /ai:session-resume --full
2. 开始新工作: /ai:dev <feature>
3. 创建首个 checkpoint: 完成工作后 /ai:session-save
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 触发词

- `/ai:session-resume`
- `resume session`
- `继续`
- `恢复`
- `接着做`
