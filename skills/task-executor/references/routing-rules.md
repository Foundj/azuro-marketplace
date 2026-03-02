# 路由规则与降级策略

> 任务到执行器的匹配逻辑和工具不可用时的降级处理

## 路由解析流程

对每个任务，按以下优先级确定执行器：

```
1. task.md 单任务 executor 字段
   └─ 有值 → 使用该值
   └─ 无值 ↓

2. roles 匹配
   └─ 任务 tags 匹配某角色 → 使用角色配置
   └─ 任务 id 匹配某角色 (通配符) → 使用角色配置
   └─ 无匹配 ↓

3. version README.md steps 配置
   └─ 版本级 README 存在且定义了对应 step → 使用
   └─ 不存在 ↓

4. global README.md steps 配置
   └─ 全局 README 定义了对应 step → 使用
   └─ 未定义 ↓

5. self（兜底默认）
```

## 角色匹配规则

### 按 tags 匹配

```yaml
roles:
  frontend:
    match: { tags: [frontend, ui, design] }
```

任务 tags 中包含**任一**匹配 tag 即命中。

### 按 ID 通配匹配

```yaml
roles:
  review-task:
    match: { id: "*-review" }
```

支持 `*` 通配符匹配任务 ID。

### 简写匹配

```yaml
roles:
  frontend: gemini
```

简写模式下，角色名本身作为隐式 tag 匹配：任务 tags 中包含 `frontend` 即命中。

### 多角色匹配

若任务匹配多个角色，按 roles 中定义顺序取第一个匹配。

## 降级策略

### CLI 工具不可用

当指定的 CLI 工具未安装时：

```
gemini (未安装)
  ↓ 降级
claude (检查是否安装)
  ↓ 降级
subagent (始终可用)
  ↓ 降级
self (终极兜底)
```

降级链通过 `detect-executors.sh` 检测实际可用工具。

### Agent Team 不可用

Agent Team 是实验性功能，不可用时：

```
agent-team
  ↓ executors.agent-team.fallback
subagent (默认)
```

### 降级日志

每次降级都记录到执行日志：

```
[WARN] gemini 不可用，降级为 claude
[WARN] agent-team 不可用，降级为 subagent
```

## 执行器能力矩阵

| 执行器 | 文件读写 | 命令执行 | 并行 | 会话隔离 | 需安装 |
|--------|---------|---------|------|---------|--------|
| self | 完整 | 完整 | 否 | 否 | - |
| subagent | 完整 | 完整 | 是 | 是 | - |
| claude | 受限 | 受限 | 是 | 是 | claude CLI |
| codex | 完整 | 沙箱 | 是 | 是 | codex CLI |
| gemini | 只读 | 沙箱 | 是 | 是 | gemini CLI |
| opencode | 取决配置 | 取决配置 | 是 | 是 | opencode CLI |
| agent-team | 按 fileScope | 完整 | 是 | 是 | Agent Teams 功能 |
