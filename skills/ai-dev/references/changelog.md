# AI-Dev Changelog

## v4.2 - Context Bridge Integration

### Smart Empty Command Detection

当 `/ai:dev` 或 `/ai:auto` 不带参数时，自动检测并继续现有任务：

```bash
/ai:dev                # 无参数 → 检测现有任务
/ai:auto               # 无参数 → 继续未完成任务
```

**检测逻辑**：

```
用户输入: "/ai:dev" (无参数)
  ↓
检测 .agent/changes/active/ 是否有未完成的 change
  ↓
├─ 有 active change →
│   ━━━━━━━━━━━━━━━━━━━━━━━━━
│   📍 Found Active Change
│   ━━━━━━━━━━━━━━━━━━━━━━━━━
│   Change: 001-user-auth
│   Phase: 4 (Implementation)
│   Tasks: 5/7 completed
│
│   Options:
│   1. Continue this change (y)
│   2. Start new change (n)
│   3. Show details (/ai:status)
│   ━━━━━━━━━━━━━━━━━━━━━━━━━
│
└─ 无 active change → 检测 .agent/context/tasks.md (Lite Mode)
    ↓
    ├─ 有 tasks.md → 询问是否升级到 Full Mode
    └─ 无任务 → 提示 "Usage: /ai:dev <feature>"
```

**`/ai:auto` 空命令行为**：

```
用户输入: "/ai:auto" (无参数)
  ↓
检测 .agent/changes/active/*/tasks.md
  ↓
├─ 有未完成任务 → 自动继续执行
├─ 全部完成 →
│   ━━━━━━━━━━━━━━━━━━━━━━━━━
│   ✅ All Tasks Completed!
│   ━━━━━━━━━━━━━━━━━━━━━━━━━
│   Run /session:save or /feature-archive
│   ━━━━━━━━━━━━━━━━━━━━━━━━━
└─ 无任务 → 提示 "No pending tasks. Start with: /ai:dev <feature>"
```

### Enhanced Context Bridge Integration

- **Auto Checkpoint (90%)**: 当 context 达到 90% 时自动保存
- **Lite Mode 统一**: 共享 `.agent/context/` 目录
- **任务完成检测**: 所有任务完成时自动提示保存/归档

---

## v4.1 - Attention Management

### Read Before Decide Pattern

Integrates Manus-style "Read Before Decide" pattern to prevent goal drift during long OODA loops.

**Key Changes:**
- **OODA Attention Management**: Each iteration starts by reading `tasks.md` to refresh goals
- **Periodic Focus Refresh**: Every 5 iterations, run `/focus` to refresh attention window
- **Context Bridge Integration**: Works with `/focus`, `/progress`, `/session:save` commands
- **Lost in the Middle Prevention**: Goals stay in attention window even after 50+ tool calls

---

## v4.0 - Industrial Grade

### 1. Hard Gates (Verification Enforcement)

The OODA Loop now enforces quality through automated verification.
- **`verify_with`**: Tasks in `tasks.md` can specify a shell command for verification.
- **Blocking Mechanism**: Claude cannot output `<promise>DONE</promise>` until the verification command passes.
- **Escape Hatch**: Use `verify_with: true` to skip verification for impossible-to-test tasks.

### 2. Reflexion System (Self-Improving Memory)

A persistent knowledge base of errors and their solutions.
- **Automatic Logging**: Every verification failure is analyzed and logged to `solutions_learned.jsonl`.
- **Intelligent Querying**: Before starting a task, the agent queries previous solutions to avoid repeating mistakes.

### 3. Worker Sessions (Manager-Worker Model)

Scales horizontally to handle complex features without context overflow.
- **Context Awareness**: Spawns a dedicated sub-agent when context reaches **80%**.
- **Handover Protocol**: Semantic context transfer via `handover.md`.
- **Safety**: Strict **Max Depth = 2** to prevent infinite agent recursion.
