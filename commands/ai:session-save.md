---
name: ai:session-save
description: 保存当前 session 进度，生成摘要和下一步任务文件
argument-hint: ""
allowed-tools: Read, Write, Bash, Grep, Glob
---

# /ai:session-save - 保存 Session 进度

执行此命令保存当前工作状态。

## 执行步骤

### 1. 检查并创建目录结构
```bash
mkdir -p codebox/context/sessions
```

### 2. 收集当前状态

**扫描 active changes:**
- 读取 `codebox/changes/active/*/state.json`
- 提取 changeId, currentPhase, ooda iteration, blockers

**统计任务进度:**
- 读取每个 change 的 `tasks.md`
- 统计 `[x]` 完成数和 `[ ]` 待办数

**收集 Git 信息:**
```bash
git log --oneline -10
git diff --stat HEAD~5..HEAD 2>/dev/null
```

**读取最近进度:**
```bash
tail -30 codebox/progress.txt 2>/dev/null
```

### 3. 生成 session_summary.md

在 `codebox/context/session_summary.md` 创建包含:
- Session 日期时间
- 完成的任务列表
- 进行中的任务
- Active changes 状态表
- 关键决策和遇到的问题
- 文件变更和 Git 提交
- 下次 session 的上下文摘要
- 需要处理的 blockers

### 4. 生成 next_steps.md

在 `codebox/context/next_steps.md` 创建包含:
- Quick Resume 命令说明
- P0 任务 (Blockers - 立即处理)
- P1 任务 (In Progress - 继续进行)
- P2 任务 (Ready - 可以开始)
- Active changes 概览表
- 推荐的首要任务和可执行命令

### 5. 归档历史 Session

```bash
session_count=$(ls codebox/context/sessions/ 2>/dev/null | grep -c "session-" || echo "0")
next_session=$((session_count + 1))
session_id=$(printf "%03d" $next_session)

if [ -f "codebox/context/session_summary.md" ]; then
  cp codebox/context/session_summary.md \
     "codebox/context/sessions/session-${session_id}-$(date +%Y%m%d).md"
fi
```

### 6. 输出确认

显示:
- 完成任务数 / 进行中任务数
- 生成的文件路径
- 下次优先任务
- 恢复命令提示

## 输出示例

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Session Saved - #5
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

📊 Summary:
   - Tasks Completed: 3
   - Tasks In Progress: 1
   - Active Changes: 2

📁 Files Generated:
   - codebox/context/session_summary.md
   - codebox/context/next_steps.md

🎯 Next Priority:
   Fix 4 failing tests in AuthService.test.ts

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
下次开始时输入 "/ai:session-resume" 即可继续
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## 触发词

- `/ai:session-save`
- `save session`
- `save progress`
- `保存进度`
- `存档`
