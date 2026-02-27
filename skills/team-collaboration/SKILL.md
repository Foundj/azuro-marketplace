---
name: team-collaboration
description: |
  Agent Teams 团队协作技能。提供场景模板库、团队配置指南、协作最佳实践。
  使用 Claude Code 原生 Agent Teams 能力实现多代理并行协作。
  触发词: "团队协作", "team collaboration", "多代理", "并行开发", "agent teams"
version: 5.1.12
status: experimental
triggers:
  - team collaboration
  - 团队协作
  - agent teams
  - 多代理协作
  - 并行开发
  - team mode
---

# Team Collaboration Skill

> **核心原则**: 使用 Claude Code 原生 Agent Teams 实现多代理协作，让复杂任务变得简单。

## 触发词

此技能触发于: "团队协作", "team collaboration", "agent teams", "多代理协作", "并行开发".

---

## 快速开始

### 用户只需这样描述:

```
"创建一个团队并行开发用户认证功能：
- 前端做登录页面
- 后端做认证API
- 测试工程师写测试"
```

**系统自动完成团队配置和执行!**

---

## 场景模板库

### 1. 功能开发团队

**触发词**: "功能", "开发", "实现", "feature", "develop"

```typescript
const FEATURE_DEVELOPMENT_TEMPLATE = {
  name: "功能开发团队",
  description: "前后端分离并行开发",

  teammates: [
    {
      role: "frontend-dev",
      type: "ai-dev:frontend-developer",
      description: "前端开发",
      fileScope: ["src/components/**", "src/pages/**", "src/styles/**"],
      estimatedTasks: 3
    },
    {
      role: "backend-dev",
      type: "ai-dev:api-helper",
      description: "后端开发",
      fileScope: ["src/api/**", "src/routes/**", "src/db/**"],
      estimatedTasks: 3
    },
    {
      role: "test-engineer",
      type: "ai-dev:test-automator",
      description: "测试自动化",
      fileScope: ["tests/**", "__tests__/**"],
      blockedBy: ["frontend-dev", "backend-dev"],
      estimatedTasks: 2
    }
  ],

  workflow: {
    type: "parallel-then-merge",
    phases: [
      {
        name: "开发",
        teammates: ["frontend-dev", "backend-dev"],
        parallel: true
      },
      {
        name: "测试",
        teammates: ["test-engineer"],
        parallel: false,
        blockedBy: ["开发"]
      }
    ]
  },

  communication: {
    syncPoints: ["API 契约确认", "数据结构确认", "集成测试准备"],
    broadcastOn: ["API 变更", "数据结构变更", "环境变更"]
  }
}
```

### 2. 代码审查团队

**触发词**: "审查", "review", "检查代码", "代码质量"

```typescript
const CODE_REVIEW_TEMPLATE = {
  name: "代码审查团队",
  description: "多角度并行审查",

  teammates: [
    {
      role: "security-reviewer",
      type: "ai-dev:code-reviewer",
      description: "安全审查",
      focus: "安全漏洞、XSS、SQL注入、权限问题",
      estimatedTasks: 2
    },
    {
      role: "performance-reviewer",
      type: "ai-dev:code-reviewer",
      description: "性能审查",
      focus: "性能瓶颈、内存泄漏、算法复杂度",
      estimatedTasks: 2
    },
    {
      role: "quality-reviewer",
      type: "ai-dev:quality-guardian",
      description: "质量审查",
      focus: "代码风格、可维护性、测试覆盖",
      estimatedTasks: 2
    }
  ],

  workflow: {
    type: "parallel-independent",
    phases: [
      {
        name: "审查",
        teammates: ["security-reviewer", "performance-reviewer", "quality-reviewer"],
        parallel: true
      }
    ]
  }
}
```

### 3. 问题调查团队

**触发词**: "调查", "debug", "问题", "investigate", "排查"

```typescript
const INVESTIGATION_TEMPLATE = {
  name: "问题调查团队",
  description: "竞争假设并行调查",

  teammates: [
    {
      role: "log-analyst",
      type: "ai-dev:debugger",
      description: "日志分析",
      focus: "错误日志、堆栈跟踪、异常模式",
      estimatedTasks: 2
    },
    {
      role: "code-tracer",
      type: "ai-dev:error-detective",
      description: "代码追踪",
      focus: "代码路径、数据流、状态变化",
      estimatedTasks: 2
    },
    {
      role: "hypothesis-tester",
      type: "ai-dev:debugger",
      description: "假设验证",
      focus: "复现问题、验证修复",
      estimatedTasks: 2
    }
  ],

  workflow: {
    type: "competitive-hypothesis",
    phases: [
      {
        name: "调查",
        teammates: ["log-analyst", "code-tracer"],
        parallel: true
      },
      {
        name: "验证",
        teammates: ["hypothesis-tester"],
        parallel: false
      }
    ]
  }
}
```

### 4. 架构设计团队

**触发词**: "架构", "设计", "architecture", "design"

```typescript
const ARCHITECTURE_TEMPLATE = {
  name: "架构设计团队",
  description: "多视角架构评审",

  teammates: [
    {
      role: "backend-architect",
      type: "ai-dev:backend-architect",
      description: "后端架构",
      focus: "服务设计、数据模型、API设计",
      estimatedTasks: 3
    },
    {
      role: "frontend-architect",
      type: "ai-dev:frontend-developer",
      description: "前端架构",
      focus: "组件设计、状态管理、路由",
      estimatedTasks: 2
    },
    {
      role: "security-architect",
      type: "ai-dev:code-reviewer",
      description: "安全架构",
      focus: "认证授权、数据保护、安全边界",
      estimatedTasks: 2
    }
  ],

  workflow: {
    type: "collaborative-design",
    phases: [
      {
        name: "设计",
        teammates: ["backend-architect", "frontend-architect"],
        parallel: true
      },
      {
        name: "评审",
        teammates: ["security-architect"],
        parallel: false,
        blockedBy: ["设计"]
      }
    ]
  }
}
```

---

## 场景选择器

```typescript
function selectTeamTemplate(request: string): TeamTemplate {
  const keywords = extractKeywords(request)

  // 匹配分数计算
  const scores = Object.entries(TEAM_TEMPLATES).map(([key, template]) => ({
    key,
    template,
    score: calculateMatchScore(keywords, template.trigger)
  }))

  // 选择最高分
  const best = scores.sort((a, b) => b.score - a.score)[0]

  if (best.score > 0.5) {
    return best.template
  }

  // 默认使用功能开发团队
  return TEAM_TEMPLATES.FEATURE_DEVELOPMENT
}

function calculateMatchScore(keywords: string[], triggers: string[]): number {
  const matches = keywords.filter(k =>
    triggers.some(t => k.includes(t) || t.includes(k))
  )
  return matches.length / Math.max(keywords.length, triggers.length)
}

const TEAM_TEMPLATES = {
  FEATURE_DEVELOPMENT: FEATURE_DEVELOPMENT_TEMPLATE,
  CODE_REVIEW: CODE_REVIEW_TEMPLATE,
  INVESTIGATION: INVESTIGATION_TEMPLATE,
  ARCHITECTURE: ARCHITECTURE_TEMPLATE
}
```

---

## 团队创建流程

### Step 1: 创建团队

```typescript
TeamCreate({
  team_name: generateTeamName(featureDescription),
  description: featureDescription,
  agent_type: "team-orchestrator"
})
```

### Step 2: 生成队友

```typescript
// 根据模板生成队友
for (const teammate of template.teammates) {
  await Task({
    subagent_type: teammate.type,
    team_name: currentTeam,
    name: teammate.role,
    prompt: generateTeammatePrompt(teammate, task),
    isolation: "worktree"  // 可选：自动隔离
  })
}
```

### Step 3: 创建任务

```typescript
// 创建共享任务列表
for (const task of plannedTasks) {
  await TaskCreate({
    subject: task.subject,
    description: task.description,
    activeForm: task.activeForm
  })
}

// 设置依赖关系
for (const task of plannedTasks) {
  if (task.blockedBy) {
    await TaskUpdate({
      taskId: task.id,
      addBlockedBy: task.blockedBy
    })
  }
  if (task.owner) {
    await TaskUpdate({
      taskId: task.id,
      owner: task.owner
    })
  }
}
```

### Step 4: 监控执行

```typescript
// 定期检查进度
const status = TaskList()

// 处理阻塞和通信
// ...
```

### Step 5: 完成闭环

```typescript
// 发送关闭请求
for (const teammate of teamMembers) {
  await SendMessage({
    type: "shutdown_request",
    recipient: teammate.name,
    content: "任务完成，感谢贡献！"
  })
}

// 清理团队资源
await TeamDelete()
```

---

## 最佳实践

### 1. 团队规模

| 复杂度 | 队友数量 | 任务数量 |
|--------|----------|----------|
| 简单 | 2-3 | 3-5 |
| 中等 | 3-4 | 5-10 |
| 复杂 | 4-5 | 10-15 |

### 2. 文件隔离

```
避免两个队友编辑同一文件！

推荐分配:
- frontend-dev: src/components/*.tsx
- backend-dev: src/api/*.ts
- test-engineer: tests/*.test.ts
```

### 3. 通信策略

- **单播优先** (`type: "message"`) - 大多数情况
- **广播慎用** (`type: "broadcast"`) - 仅关键通知
- **空闲唤醒** - 队友空闲时发送消息

### 4. 任务粒度

- **每个任务**: 2-5 分钟可完成
- **每个队友**: 3-6 个任务
- **总任务数**: 不超过 20 个

---

## 监控指标

```typescript
interface TeamMetrics {
  teamName: string
  createdAt: Date
  teammates: number
  tasks: {
    total: number
    completed: number
    inProgress: number
    pending: number
    blocked: number
  }
  health: {
    score: number  // 0-100
    issues: string[]
  }
}

function collectMetrics(teamName: string): TeamMetrics {
  const tasks = TaskList()

  return {
    teamName,
    createdAt: new Date(),
    teammates: getTeammateCount(teamName),
    tasks: {
      total: tasks.length,
      completed: tasks.filter(t => t.status === "completed").length,
      inProgress: tasks.filter(t => t.status === "in_progress").length,
      pending: tasks.filter(t => t.status === "pending").length,
      blocked: tasks.filter(t => t.blockedBy.length > 0).length
    },
    health: calculateHealth(tasks)
  }
}
```

---

## 故障排除

### 队友未响应

```typescript
// 发送唤醒消息
SendMessage({
  type: "message",
  recipient: "frontend-dev",
  content: "请确认你的进度"
})
```

### 任务卡住

```typescript
// 检查依赖
TaskGet({ taskId: "3" })

// 手动解除阻塞
TaskUpdate({ taskId: "3", addBlockedBy: [] })
```

### 资源残留

```bash
# 手动清理
rm -rf ~/.claude/teams/<team-name>
rm -rf ~/.claude/tasks/<team-name>
```

---

## 相关命令

- `/ai:team` - 团队协作开发入口
- `/ai:team review` - 团队代码审查
- `/ai:team debug` - 团队问题调查
- `/ai:team feature` - 功能开发模式
- `/ai:dev --team` - 混合模式

---

## 相关 Agents

- `team-orchestrator` - 团队编排器
- `team-worker` - 通用工作者
- `master-controller` - 智能路由

---

## 版本历史

| Version | Changes |
|---------|---------|
| 1.0.0 | 初始版本，包含四种场景模板 |