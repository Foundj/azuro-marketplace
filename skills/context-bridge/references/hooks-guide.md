# Context Bridge Hooks 配置指南

> 本文档包含 context-bridge 的 Hook 配置详情。

---

## Auto-Checkpoint Suggestion Hook

当 context 使用率超过阈值时，建议保存：

```json
// .claude/settings.local.json
{
  "hooks": {
    "context-warning": {
      "trigger": "context_usage > 70%",
      "action": "suggest",
      "message": "💡 Context 70%+ used. Consider running /ai:session-save to checkpoint progress."
    }
  }
}
```

---

## Pre-Exit Hook

Session 结束前提醒保存：

```json
{
  "hooks": {
    "pre-exit": {
      "trigger": "session_end",
      "action": "prompt",
      "message": "📋 Session ending. Run /ai:session-save to preserve progress?"
    }
  }
}
```

---

## Auto-Resume on Start

如果存在 context 文件，自动提示恢复：

```json
{
  "hooks": {
    "post-init": {
      "trigger": "session_start",
      "condition": "file_exists('codebox/context/next_steps.md')",
      "action": "suggest",
      "message": "🔄 Previous session found. Resume with /ai:session-resume?"
    }
  }
}
```

---

## 完整 Auto Checkpoint 配置

多级阈值 hooks：

```json
{
  "hooks": {
    "attention-refresh-70": {
      "trigger": "context_usage > 70%",
      "action": "suggest",
      "message": "💡 Context 70%. Consider /focus to refresh goals."
    },
    "save-warning-85": {
      "trigger": "context_usage > 85%",
      "action": "warn",
      "message": "⚠️ Context 85%. Run /ai:session-save soon."
    },
    "auto-checkpoint-90": {
      "trigger": "context_usage > 90%",
      "action": "auto_execute",
      "command": "/ai:session-save",
      "message": "🔴 Context 90%. Auto-saving progress..."
    },
    "task-completion": {
      "trigger": "all_tasks_completed",
      "action": "suggest",
      "message": "✅ All tasks completed! Run /ai:session-save or /feature-archive"
    }
  }
}
```

---

## 配置选项

### Auto Checkpoint 阈值

| 阈值 | 动作 | 触发条件 |
|------|------|----------|
| **70%** | 💡 建议 `/focus` | Context 使用率 |
| **85%** | ⚠️ 警告 + 建议保存 | Context 使用率 |
| **90%** | 🔴 **自动保存** | Context 使用率 |
| — | ✅ 提示保存/归档 | 所有任务完成 |
| — | 💡 建议保存 | 连续工作 2+ 小时 |

### Session 归档策略

```yaml
archive:
  max_sessions: 50          # 保留最近 50 个 session
  compress_after: 30        # 30天后压缩
  auto_cleanup: true        # 自动清理
```

---

## 自定义 Hook 示例

### 基于时间的提醒

```json
{
  "hooks": {
    "hourly-checkpoint": {
      "trigger": "time_elapsed > 60min",
      "action": "suggest",
      "message": "⏰ 1 hour elapsed. Consider /ai:session-save to checkpoint."
    }
  }
}
```

### 基于任务进度的提醒

```json
{
  "hooks": {
    "milestone-checkpoint": {
      "trigger": "tasks_completed >= 5",
      "action": "suggest",
      "message": "🎯 5 tasks completed. Good time for /ai:session-save?"
    }
  }
}
```
