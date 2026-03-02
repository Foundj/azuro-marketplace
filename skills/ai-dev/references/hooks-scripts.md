# Hooks & Scripts Reference

## Hooks

| Hook | Type | Purpose |
|------|------|---------|
| `ooda-stop-hook.sh` | Stop | OODA loop control in Phase 4 |
| `todo-continuation.sh` | Stop | Block exit when unchecked tasks remain |
| `keyword-detector.sh` | UserPromptSubmit | Detect ulw/think/quick keywords |
| `context-window-monitor.sh` | PostToolUse | Warn at 85% context usage |
| `comment-checker.sh` | PostToolUse | Warn about redundant comments |
| `pre-change-check` | PreToolUse | Knowledge query before changes |
| `learning-capture` | UserPromptSubmit | Capture user corrections |
| `post-phase-learning` | PostToolUse | Trigger learning after Phase 6-7 |

## Scripts

| Script | Purpose |
|--------|---------|
| `scan-project.sh` | Deep/incremental project scanning |
| `query-knowledge.sh` | Query patterns and errors |
| `init-version.sh` | Initialize new versioned task directory |
| `archive-change.sh` | Archive completed change |
| `check-dependencies.sh` | Verify external dependencies |

## Configuration Example

### hooks/hooks.json

```json
{
  "hooks": [
    {
      "id": "ooda-stop-hook",
      "type": "Stop",
      "script": "hooks/ooda-stop-hook.sh",
      "conditions": {
        "currentPhase": 4,
        "oodaEnabled": true
      }
    }
  ],
  "config": {
    "completionPromise": "DONE",
    "maxIterations": 50
  }
}
```

## OODA Attention Management

> **Read Before Decide** — 每次迭代开始时刷新目标

**每次 OODA 迭代必须**：

1. **OBSERVE 阶段开始时**：
   ```
   Read tasks.md              # 刷新任务列表到注意力窗口
   Read state.json            # 获取当前进度
   ```

2. **重大决策前**：
   ```
   Read design.md             # 参考架构约束
   Read requirements.md       # 确认符合全局需求
   ```

3. **每 5 次迭代后**：
   ```
   运行 /focus                # 强制刷新目标
   ```

**原因**：在长时间 OODA 循环中（50+ iterations），原始目标可能被 "遗忘"（Lost in the Middle 问题）。
通过周期性读取目标文件，将目标重新注入注意力窗口末端，保持决策质量。
