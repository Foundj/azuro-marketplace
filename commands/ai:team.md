---
name: ai:team
description: Agent Teams 团队协作开发 - 使用 Claude Code 原生能力创建和管理多代理团队
argument-hint: "[mode] <feature-description> | [--dry-run] [--parallel] [--quick]"
allowed-tools: TeamCreate, TeamDelete, TaskCreate, TaskUpdate, TaskList, TaskGet, SendMessage, Task, Read, Write, Edit, Grep, Glob, Bash
internal: true
---

# AI Team Command

**使用 Claude Code 原生 Agent Teams 进行团队协作开发**

**Usage:**
- `/ai:team <feature>` - 团队协作开发功能
- `/ai:team review` - 团队代码审查模式
- `/ai:team debug` - 团队问题调查模式
- `/ai:team feature` - 功能开发模式 (默认)
- `/ai:team --dry-run` - 预览团队配置而不执行

---

## Pre-check: Agent Teams 是否启用

!`[ -n "$CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS" ] && echo "TEAMS_ENABLED" || echo "TEAMS_NOT_ENABLED"`

**如果输出 TEAMS_NOT_ENABLED:**
```
⚠️  Agent Teams 需要启用实验功能

请在 ~/.claude/settings.json 中添加:
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}

或者设置环境变量:
export CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1
```

---

## Mode Detection

解析 $ARGUMENTS 确定模式:

| 参数 | 模式 | 描述 |
|------|------|------|
| `review` | 代码审查 | 多角度并行审查 |
| `debug` | 问题调查 | 竞争假设并行调查 |
| `feature` 或其他 | 功能开发 | 前后端分离并行开发 (默认) |

**选项:**
- `--dry-run`: 预览团队配置和任务分配，不执行
- `--parallel`: 强制并行执行 (默认开启)
- `--quick`: 跳过详细规划阶段

---

## Phase 1: 需求分析

**分析用户请求:**

```typescript
interface TeamRequest {
  mode: "feature" | "review" | "debug"
  description: string
  complexity: "simple" | "medium" | "complex"
  estimatedTeammates: number
  fileScope: string[]
}
```

**复杂度评估:**
- **simple**: 1-2 个文件，2-3 个队友
- **medium**: 3-5 个文件，3-4 个队友
- **complex**: 5+ 个文件，4-5 个队友

---

## Phase 2: 团队配置

### 模式 1: 功能开发 (feature)

**触发词:** "功能", "开发", "实现", "feature", "develop"

```typescript
const FEATURE_TEAM = {
  teammates: [
    {
      role: "frontend-dev",
      type: "ai-dev:frontend-developer",
      description: "前端开发",
      fileScope: ["src/components/**", "src/pages/**", "src/styles/**"]
    },
    {
      role: "backend-dev",
      type: "ai-dev:api-helper",
      description: "后端开发",
      fileScope: ["src/api/**", "src/routes/**", "src/db/**"]
    },
    {
      role: "test-engineer",
      type: "ai-dev:test-automator",
      description: "测试自动化",
      fileScope: ["tests/**", "__tests__/**"],
      blockedBy: ["frontend-dev", "backend-dev"]
    }
  ],
  workflow: "parallel-then-merge"
}
```

### 模式 2: 代码审查 (review)

**触发词:** "审查", "review", "检查代码", "代码质量"

```typescript
const REVIEW_TEAM = {
  teammates: [
    {
      role: "security-reviewer",
      type: "ai-dev:code-reviewer",
      description: "安全审查",
      focus: "安全漏洞、XSS、SQL注入、权限问题"
    },
    {
      role: "performance-reviewer",
      type: "ai-dev:code-reviewer",
      description: "性能审查",
      focus: "性能瓶颈、内存泄漏、算法复杂度"
    },
    {
      role: "quality-reviewer",
      type: "ai-dev:quality-guardian",
      description: "质量审查",
      focus: "代码风格、可维护性、测试覆盖"
    }
  ],
  workflow: "parallel-independent"
}
```

### 模式 3: 问题调查 (debug)

**触发词:** "调查", "debug", "问题", "investigate", "排查"

```typescript
const DEBUG_TEAM = {
  teammates: [
    {
      role: "log-analyst",
      type: "ai-dev:debugger",
      description: "日志分析",
      focus: "错误日志、堆栈跟踪、异常模式"
    },
    {
      role: "code-tracer",
      type: "ai-dev:error-detective",
      description: "代码追踪",
      focus: "代码路径、数据流、状态变化"
    },
    {
      role: "hypothesis-tester",
      type: "ai-dev:debugger",
      description: "假设验证",
      focus: "复现问题、验证修复"
    }
  ],
  workflow: "competitive-hypothesis"
}
```

---

## Phase 3: 创建团队

**如果 --dry-run:**
- 显示团队配置预览
- 列出任务分配计划
- 退出不执行

**否则执行:**

### Step 3.1: 创建团队

```typescript
TeamCreate({
  team_name: generateTeamName($ARGUMENTS),
  description: $ARGUMENTS,
  agent_type: "team-orchestrator"
})
```

### Step 3.2: 生成队友

根据选择的模式，并行生成队友:

```typescript
// 示例: 功能开发模式
Task({
  subagent_type: "ai-dev:frontend-developer",
  team_name: currentTeam,
  name: "frontend-dev",
  prompt: `
    你是前端开发队友。
    任务: ${taskDescription}
    文件范围: src/components/**, src/pages/**
    与 backend-dev 协作完成功能。
  `
})

Task({
  subagent_type: "ai-dev:api-helper",
  team_name: currentTeam,
  name: "backend-dev",
  prompt: `
    你是后端开发队友。
    任务: ${taskDescription}
    文件范围: src/api/**, src/routes/**
    与 frontend-dev 协作完成功能。
  `
})
```

### Step 3.3: 创建共享任务

```typescript
TaskCreate({
  subject: "前端实现",
  description: "UI组件、表单验证、API连接",
  activeForm: "实现前端功能中"
})

TaskCreate({
  subject: "后端实现",
  description: "API端点、数据处理、数据库操作",
  activeForm: "实现后端功能中"
})

TaskCreate({
  subject: "集成测试",
  description: "E2E测试、集成验证",
  activeForm: "编写测试中"
})

// 设置依赖
TaskUpdate({
  taskId: "3",
  addBlockedBy: ["1", "2"]
})

// 分配任务
TaskUpdate({ taskId: "1", owner: "frontend-dev" })
TaskUpdate({ taskId: "2", owner: "backend-dev" })
TaskUpdate({ taskId: "3", owner: "test-engineer" })
```

---

## Phase 4: 监控执行

### 定期检查进度

```typescript
TaskList()
```

### 处理阻塞

如果检测到任务卡住:
1. 发送消息询问队友状态
2. 检查依赖是否满足
3. 必要时调整任务分配

---

## Phase 5: 完成闭环

### 当所有任务完成时

1. **发送关闭请求给所有队友:**

```typescript
SendMessage({
  type: "shutdown_request",
  recipient: "frontend-dev",
  content: "任务完成，感谢贡献！"
})
```

2. **等待队友确认关闭**

3. **清理团队资源:**

```typescript
TeamDelete()
```

---

## 使用示例

```bash
# 功能开发
/ai:team 实现用户认证功能，包括登录、注册、密码重置

# 代码审查
/ai:team review 检查 src/auth 目录下的所有代码

# 问题调查
/ai:team debug 调查登录失败的问题

# 预览模式
/ai:team --dry-run 实现购物车功能
```

---

## 与现有命令的关系

| 命令 | 模式 | 适用场景 |
|------|------|----------|
| `/ai:dev` | 传统 subagent | 7阶段开发工作流 |
| `/ai:dev --team` | Agent Teams | 自动选择团队模式 |
| `/ai:team` | Agent Teams | 强制使用团队模式 |
| `/ai:loop` | OODA 循环 | 快速迭代执行 |

---

## 注意事项

1. **文件隔离**: 确保不同队友编辑不同文件
2. **通信成本**: 优先使用单播，慎用广播
3. **资源清理**: 任务完成后必须清理团队资源
4. **队友数量**: 推荐 3-5 人，最多不超过 7 人