# Context Bridge 实现细节

> 本文档包含 context-bridge 的详细实现逻辑，供需要深入了解的场景使用。

---

## 模式检测逻辑

```bash
# Step 0: 检测运行模式
detect_mode() {
  if [ -d ".agent/changes/active" ]; then
    active_count=$(ls .agent/changes/active/ 2>/dev/null | wc -l)
    if [ "$active_count" -gt 0 ]; then
      for dir in .agent/changes/active/*/; do
        if [ -f "${dir}state.json" ]; then
          echo "ai-dev"  # Mode A
          return
        fi
      done
    fi
  fi
  echo "standalone"  # Mode B
}

MODE=$(detect_mode)
CONTEXT_DIR=".agent/context"
mkdir -p "$CONTEXT_DIR/sessions"
```

---

## /ai:session-save 实现流程

### Step 0: 检测运行模式

```bash
MODE="standalone"
CONTEXT_DIR=".agent/context"

if [ -d ".agent/changes/active" ]; then
  for dir in .agent/changes/active/*/; do
    if [ -f "${dir}state.json" ]; then
      MODE="ai-dev"
      break
    fi
  done
fi

mkdir -p "$CONTEXT_DIR/sessions"
echo "📍 Running in $MODE mode, output to $CONTEXT_DIR"
```

### Step 1: 收集状态信息

#### Mode A (ai-dev): 从结构化文件收集

```bash
# 1. 扫描 active changes
active_changes=$(ls .agent/changes/active/ 2>/dev/null)

# 2. 读取每个 change 的 state.json
for change in $active_changes; do
  state=$(cat ".agent/changes/active/$change/state.json")
  change_id=$(echo "$state" | jq -r '.changeId')
  phase=$(echo "$state" | jq -r '.currentPhase')
  ooda_count=$(echo "$state" | jq -r '.ooda.iterationCount // 0')
  ooda_max=$(echo "$state" | jq -r '.ooda.maxIterations // 10')

  # 读取 tasks.md 统计完成情况
  tasks_file=".agent/changes/active/$change/tasks.md"
  if [ -f "$tasks_file" ]; then
    completed=$(grep -c "^\s*- \[x\]" "$tasks_file" 2>/dev/null || echo "0")
    pending=$(grep -c "^\s*- \[ \]" "$tasks_file" 2>/dev/null || echo "0")
  fi
done

# 3. 读取 progress.txt 最近条目
recent_progress=$(tail -50 .agent/progress.txt 2>/dev/null)
```

#### Mode B (独立模式): 从对话和 git 收集

```bash
# 1. 从 git 获取最近变更
recent_commits=$(git log --oneline -10 2>/dev/null)
files_changed=$(git diff --stat HEAD~5..HEAD 2>/dev/null || git diff --stat)

# 2. 从对话上下文提取
# - 本次讨论的主题
# - 已完成的工作
# - 遇到的问题
# - 下一步计划
```

### Step 2-4: 生成文件和归档

参见 [templates.md](templates.md) 获取完整模板。

```bash
# 归档历史 Session
session_count=$(ls .agent/context/sessions/ 2>/dev/null | wc -l)
next_session=$((session_count + 1))
mv .agent/context/session_summary.md \
   .agent/context/sessions/session-$(printf "%03d" $next_session).md
```

---

## /ai:session-resume 实现流程

### Step 1: 读取上下文文件

```bash
# 1. 读取 next_steps.md
next_steps=$(cat .agent/context/next_steps.md)

# 2. 读取上次 session 摘要
last_summary=$(cat .agent/context/session_summary.md)

# 3. 验证 active changes 状态
for change in .agent/changes/active/*/state.json; do
  # 验证 state.json 有效
  # 检查 resumability.canResume
done
```

### Step 2-3: 显示报告并自动执行

```
📍 Resuming Session...

Last session: #5 (2025-01-09 18:30)
Completed: 2 tasks | In progress: Task 6

🎯 Auto-starting first priority task:
"修复 AuthService.test.ts 中的 4 个 failing tests"

[开始执行...]
```

---

## Auto Checkpoint 流程

当检测到 context 达到 90% 时：

```
1. 自动运行 /ai:session-save
2. 输出 Auto Checkpoint 报告：

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔴 Auto Checkpoint (Context 90%)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ Progress saved to .agent/context/
   - session_summary.md (updated)
   - next_steps.md (updated)

📊 Current Status:
   - Phase: 4 (Implementation)
   - Tasks: 5/7 completed
   - Blockers: None

🔄 To continue with fresh context:
   1. Run: /clear
   2. Then: resume

⚠️ If you continue without /clear, context may overflow.
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 模式对比详情

| 特性 | Mode A (ai-dev) | Mode B (独立) |
|------|-----------------|---------------|
| 任务来源 | state.json + tasks.md | 对话上下文 + git |
| Phase 追踪 | ✅ 自动 | ❌ 无 |
| OODA 状态 | ✅ 自动 | ❌ 无 |
| 输出目录 | .agent/context/ | .agent/context/ |
| 恢复精度 | 高 (结构化数据) | 中 (文本描述) |

---

## 与其他系统协作

### 与 session-manager 协作

```
session-manager (完整恢复)     context-bridge (轻量恢复)
        │                              │
        │  10步完整验证                 │  快速读取 context/
        │  环境启动                     │  直接继续任务
        │  测试运行                     │
        ▼                              ▼
   适合: 长时间中断后              适合: 短时间中断
         环境可能变化                   只需继续任务
```

### 与 ai-dev workflow 协作

```
/ai:session-save → 保存 Phase/OODA 状态
/ai:session-resume → 恢复并继续 Phase/OODA
```

### 与 knowledge-graph 协作

```
/ai:session-save 时:
- 提取本次 session 的 learnings
- 更新 knowledge/learnings.md
```

---

## Dependencies

**Required**:
- `jq` - JSON processing (for state.json parsing)
- `bash` - Script execution (POSIX compatible)
- `git` - Version history and commit tracking

**Optional**:
- `.agent/` - ai-dev workflow integration (auto-detected)

**Skill Dependencies**:
- `ai-dev` - 7-Phase workflow integration (optional)
- `session-manager` - Full recovery fallback (optional)
- `knowledge-graph` - Learning extraction on save (optional)

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 4.2.0 | 2026-01-10 | Auto Checkpoint, unified Lite Mode naming |
| 4.1.0 | 2025-01-10 | Attention Manager upgrade, /focus, /progress, Lite Mode |
| 4.0.2 | 2025-01-09 | Added hooks config, dependencies |
| 4.0.1 | 2025-01-08 | Dual-mode architecture |
| 4.0.0 | 2025-01-07 | Initial release |
