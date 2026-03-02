# 瞬态状态与恢复

> task-executor 的执行状态管理、断点续传和 Ralph Loop 集成

## 状态文件

`.claude/task-executor.local.md` 保存当前执行的瞬态状态：

```yaml
---
active: true
version: "2.0"
current_sprint: sprint-1
current_task: s1-2
current_phase: implement
iteration: 3
started_at: "2026-03-02T10:00:00Z"
errors: []
clarifications_needed: []
---
```

| 字段 | 类型 | 说明 |
|------|------|------|
| `active` | bool | 是否有活跃的执行循环 |
| `version` | string | 当前执行的版本号 |
| `current_sprint` | string | 当前 Sprint ID |
| `current_task` | string | 当前任务 ID |
| `current_phase` | enum | 当前阶段: understand / implement / test / review |
| `iteration` | int | Ralph Loop 迭代计数 |
| `started_at` | ISO datetime | 执行开始时间 |
| `errors` | string[] | 累积的错误记录 |
| `clarifications_needed` | string[] | 需要用户澄清的问题 |

## 状态流转

```
┌──────────┐    启动      ┌──────────┐
│  IDLE    │ ──────────→  │ RUNNING  │
└──────────┘              └────┬─────┘
     ↑                         │
     │    ┌────────────────────┼────────────────────┐
     │    │                    │                    │
     │    ↓                    ↓                    ↓
     │ ┌───────┐         ┌──────────┐         ┌─────────┐
     │ │PAUSED │         │VERIFYING │         │  ERROR  │
     │ │(用户)  │         │(测试中)   │         │(失败)    │
     │ └───────┘         └──────────┘         └─────────┘
     │    │                    │                    │
     │    └────────────────────┼────────────────────┘
     │                         │
     │                         ↓
     │                  ┌───────────┐
     └────────────────  │ COMPLETED │
                        └───────────┘
```

- IDLE → RUNNING: 用户触发执行
- RUNNING → PAUSED: 需求不清或用户请求暂停
- RUNNING → VERIFYING: 运行 verify 命令
- RUNNING → ERROR: verify 失败或执行异常
- ERROR → RUNNING: 修复后重试
- PAUSED → RUNNING: 用户回复澄清
- RUNNING → COMPLETED: 所有任务完成

## 断点续传

### 会话中断恢复

新会话开始时，task-executor 检查 `.claude/task-executor.local.md`：

1. 若 `active: true` → 检测到未完成的执行
2. 读取 `current_sprint` + `current_task` + `current_phase`
3. 从断点处继续执行
4. 同步 task.md 中的勾选状态确认实际进度

### Ralph Loop 恢复

Ralph Loop 通过 Stop Hook 保持循环。每次迭代：

1. 读取状态文件获取当前位置
2. 读取 task.md 获取实际勾选状态（以 task.md 为准）
3. 找到下一个未完成任务
4. 执行一个 understand → implement → test 周期
5. 更新状态文件和 task.md
6. 若全部完成 → 输出 `<promise>ALL_TASKS_DONE</promise>`

### 注意力管理

长时间执行时防止目标漂移（借鉴 ai-dev-ooda）：

- 每 5 次迭代重新读取 task.md 和 plan.md
- 读取 rules 刷新约束
- 检查 `.claude/task-executor.local.md` 同步状态

## 清理

执行完成或取消时：

```bash
rm -f .claude/task-executor.local.md
```

异常状态检测：若 `started_at` 超过 24 小时且仍为 `active: true`，视为孤儿状态，提示用户清理。
