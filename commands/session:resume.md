---
name: session:resume
description: 恢复上下文并自动继续执行上次的任务
---

# /session:resume - 恢复并继续执行

执行此命令恢复上次进度并自动开始下一个任务。

## 执行步骤

### 1. 检查 Context 文件

```bash
if [ ! -f "codebox/context/next_steps.md" ]; then
  echo "⚠️ 未找到 next_steps.md，请先使用 /session:save 保存进度"
  exit 1
fi
```

### 2. 读取上下文

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

### 3. 显示恢复报告

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

### 4. 确定第一优先任务

**优先级顺序:**
1. P0 - Blockers (failing tests, critical errors)
2. P1 - In Progress tasks (继续未完成的工作)
3. P2 - Ready to start (可以开始的新任务)

### 5. 显示任务详情

```
🎯 First Priority Task:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

修复 AuthService.test.ts 中的 4 个 failing tests

Change: 001-user-auth
Phase: 4 (Implementation)
File: src/auth/__tests__/AuthService.test.ts

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### 6. 自动执行任务 ⭐

**关键**: 不仅读取，还自动开始执行第一个任务！

```
🚀 Auto-starting task...

[开始分析并执行任务...]
```

### 7. 更新 Session 状态

```bash
current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
for state_file in codebox/changes/active/*/state.json; do
  jq --arg time "$current_time" \
     '.resumability.lastSessionTime = $time' \
     "$state_file" > tmp.json && mv tmp.json "$state_file"
done
```

## 选项

- `/session:resume` - 恢复并自动执行 (默认)
- `/session:resume --show` - 仅显示状态，不执行
- `/session:resume --full` - 调用 session-manager 完整恢复
- `/session:resume {change_id}` - 恢复特定变更

## 无 Context 文件时

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚠️ No Context Found
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

建议操作：
1. 使用 session-manager: "status"
2. 开始新工作: "ai {task}"
3. 创建首个 checkpoint: 完成工作后 "/session:save"
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 触发词

- `/session:resume`
- `resume session`
- `继续`
- `恢复`
- `接着做`
