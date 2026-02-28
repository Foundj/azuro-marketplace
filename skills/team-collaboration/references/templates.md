# Team Collaboration Templates

> 场景模板库和详细配置

## 1. 功能开发团队

**触发词**: "功能", "开发", "feature"

```typescript
const FEATURE_DEVELOPMENT_TEMPLATE = {
  name: "功能开发团队",
  teammates: [
    {
      role: "frontend-dev",
      type: "ai-dev:frontend-developer",
      fileScope: ["src/components/**", "src/pages/**"],
      estimatedTasks: 3
    },
    {
      role: "backend-dev",
      type: "ai-dev:api-helper",
      fileScope: ["src/api/**", "src/routes/**"],
      estimatedTasks: 3
    },
    {
      role: "test-engineer",
      type: "ai-dev:test-automator",
      fileScope: ["tests/**"],
      blockedBy: ["frontend-dev", "backend-dev"],
      estimatedTasks: 2
    }
  ],
  workflow: {
    type: "parallel-then-merge",
    phases: [
      { name: "开发", teammates: ["frontend-dev", "backend-dev"], parallel: true },
      { name: "测试", teammates: ["test-engineer"], blockedBy: ["开发"] }
    ]
  }
}
```

---

## 2. 代码审查团队

**触发词**: "审查", "review"

```typescript
const CODE_REVIEW_TEMPLATE = {
  name: "代码审查团队",
  teammates: [
    {
      role: "security-reviewer",
      type: "ai-dev:quality-guardian",
      focus: "安全漏洞、注入风险"
    },
    {
      role: "performance-reviewer",
      type: "ai-dev:backend-architect",
      focus: "性能瓶颈、N+1查询"
    },
    {
      role: "style-reviewer",
      type: "ai-dev:code-simplifier",
      focus: "代码风格、可读性"
    }
  ],
  workflow: {
    type: "parallel",
    allTeammates: ["security-reviewer", "performance-reviewer", "style-reviewer"]
  }
}
```

---

## 3. 问题调查团队

**触发词**: "调查", "debug", "问题"

```typescript
const INVESTIGATION_TEMPLATE = {
  name: "问题调查团队",
  teammates: [
    {
      role: "error-detective",
      type: "ai-dev:error-detective",
      task: "分析错误日志和堆栈"
    },
    {
      role: "code-tracer",
      type: "ai-dev:code-explorer",
      task: "追踪代码执行路径"
    },
    {
      role: "root-cause-analyst",
      type: "ai-dev:root-cause-analyst",
      task: "5-Why分析根因"
    }
  ],
  workflow: {
    type: "parallel-then-synthesize",
    phases: [
      { name: "并行调查", parallel: true },
      { name: "综合分析", teammate: "root-cause-analyst" }
    ]
  }
}
```

---

## 4. 架构设计团队

**触发词**: "架构", "设计", "architecture"

```typescript
const ARCHITECTURE_TEMPLATE = {
  name: "架构设计团队",
  teammates: [
    {
      role: "architect",
      type: "ai-dev:backend-architect",
      task: "架构方案设计"
    },
    {
      role: "security-expert",
      type: "ai-dev:quality-guardian",
      task: "安全审查"
    },
    {
      role: "tech-advisor",
      type: "ai-dev:typescript-pro",
      task: "技术选型建议"
    }
  ]
}
```

---

## 监控指标

```typescript
interface TeamMetrics {
  teamName: string
  tasks: {
    total: number
    completed: number
    inProgress: number
    blocked: number
  }
  health: {
    score: number  // 0-100
    issues: string[]
  }
}
```

---

## 故障排除

| 问题 | 解决方案 |
|------|----------|
| 队友未响应 | 发送唤醒消息 |
| 任务卡住 | 检查依赖，手动解除阻塞 |
| 资源残留 | `rm -rf ~/.claude/teams/<team-name>` |