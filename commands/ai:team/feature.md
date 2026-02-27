---
name: ai:team:feature
description: 团队功能开发模式 - 前后端分离并行开发，自动协调和测试
argument-hint: "<feature-description> [--frontend <path>] [--backend <path>]"
allowed-tools: TeamCreate, TeamDelete, TaskCreate, TaskUpdate, TaskList, TaskGet, SendMessage, Task, Read, Write, Edit, Grep, Glob, Bash
internal: true
---

# AI Team: Feature Development Mode

**前后端分离并行开发**

**Usage:**
- `/ai:team feature <description>` - 并行开发功能
- `/ai:team feature --frontend src/ui` - 指定前端目录
- `/ai:team feature --backend src/api` - 指定后端目录

---

## 功能开发团队配置

### 团队成员

```typescript
const FEATURE_TEAMMATES = {
  frontend: {
    role: "frontend-dev",
    type: "ai-dev:frontend-developer",
    description: "前端开发专家",
    responsibilities: [
      "UI 组件实现",
      "表单验证",
      "状态管理",
      "API 集成",
      "响应式设计"
    ],
    outputs: [
      "React/Vue 组件",
      "样式文件",
      "前端测试"
    ]
  },

  backend: {
    role: "backend-dev",
    type: "ai-dev:api-helper",
    description: "后端开发专家",
    responsibilities: [
      "API 设计与实现",
      "数据库操作",
      "业务逻辑",
      "错误处理",
      "API 文档"
    ],
    outputs: [
      "API 端点",
      "数据模型",
      "后端测试"
    ]
  },

  tester: {
    role: "test-engineer",
    type: "ai-dev:test-automator",
    description: "测试自动化专家",
    responsibilities: [
      "单元测试",
      "集成测试",
      "E2E 测试",
      "测试报告"
    ],
    outputs: [
      "测试文件",
      "测试覆盖率报告",
      "Bug 报告"
    ],
    blockedBy: ["frontend-dev", "backend-dev"]
  }
}
```

---

## 并行开发工作流

```
┌─────────────────────────────────────────────────────────────┐
│                   功能开发工作流                              │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  Phase 1: 规划 (串行)                                        │
│      │                                                       │
│      ▼                                                       │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ API 契约协商                                             │ │
│  │ • 端点定义                                              │ │
│  │ • 请求/响应格式                                         │ │
│  │ • 错误码约定                                            │ │
│  └─────────────────────────────────┬───────────────────────┘ │
│                                    │                         │
│  Phase 2: 并行开发                                           │
│                                    │                         │
│         ┌──────────────────────────┴──────────────────┐     │
│         ▼                                             ▼     │
│  ┌─────────────────┐                        ┌─────────────────┐ │
│  │  frontend-dev   │                        │  backend-dev    │ │
│  │                 │                        │                 │ │
│  │  • UI 组件      │    ◄── API 契约 ──►    │  • API 端点     │ │
│  │  • 表单验证     │                        │  • 数据模型     │ │
│  │  • 状态管理     │                        │  • 业务逻辑     │ │
│  │  • Mock 数据    │                        │  • 错误处理     │ │
│  └────────┬────────┘                        └────────┬────────┘ │
│           │                                          │        │
│           └──────────────────┬───────────────────────┘        │
│                              │                                │
│  Phase 3: 集成测试           ▼                                │
│                    ┌─────────────────┐                        │
│                    │  test-engineer  │                        │
│                    │                 │                        │
│                    │  • 集成测试     │                        │
│                    │  • E2E 测试     │                        │
│                    │  • 覆盖率报告   │                        │
│                    └────────┬────────┘                        │
│                              │                                │
│                              ▼                                │
│                         功能完成                              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 执行流程

### Step 1: 解析需求

```typescript
interface FeatureRequest {
  description: string
  frontendPath: string
  backendPath: string
  complexity: "simple" | "medium" | "complex"
  estimatedTasks: number
}

// 解析参数
const request = {
  description: $ARGUMENTS,
  frontendPath: extractFlag("--frontend") || "src/components",
  backendPath: extractFlag("--backend") || "src/api",
  complexity: assessComplexity($ARGUMENTS)
}
```

### Step 2: API 契约协商

**在并行开发前，先确定 API 契约:**

```typescript
// 创建契约文档
const apiContract = {
  endpoints: [
    {
      method: "POST",
      path: "/api/auth/login",
      request: {
        body: {
          email: "string",
          password: "string"
        }
      },
      response: {
        success: {
          user: { id: "string", email: "string", name: "string" },
          token: "string"
        },
        error: {
          code: "string",
          message: "string"
        }
      }
    }
  ]
}
```

### Step 3: 创建团队

```typescript
TeamCreate({
  team_name: generateFeatureName($ARGUMENTS),
  description: $ARGUMENTS,
  agent_type: "team-orchestrator"
})
```

### Step 4: 生成队友

```typescript
// 前端开发
Task({
  subagent_type: "ai-dev:frontend-developer",
  team_name: currentTeam,
  name: "frontend-dev",
  prompt: `
    你是前端开发专家，负责实现: ${description}

    ## 工作范围
    目录: ${frontendPath}

    ## API 契约
    ${JSON.stringify(apiContract, null, 2)}

    ## 任务
    1. 创建 UI 组件
    2. 实现表单验证
    3. 连接后端 API
    4. 编写前端测试

    ## 与后端协作
    - 使用上述 API 契约
    - 如需变更，先与 backend-dev 协商
    - 使用 SendMessage 沟通

    ## 技术栈
    React + TypeScript + Tailwind CSS
  `,
  isolation: "worktree"  // 自动隔离工作区
})

// 后端开发
Task({
  subagent_type: "ai-dev:api-helper",
  team_name: currentTeam,
  name: "backend-dev",
  prompt: `
    你是后端开发专家，负责实现: ${description}

    ## 工作范围
    目录: ${backendPath}

    ## API 契约
    ${JSON.stringify(apiContract, null, 2)}

    ## 任务
    1. 实现 API 端点
    2. 数据库模型
    3. 业务逻辑
    4. 编写后端测试

    ## 与前端协作
    - 遵循上述 API 契约
    - 如需变更，先与 frontend-dev 协商
    - 使用 SendMessage 沟通

    ## 技术栈
    Hono + Drizzle ORM + TypeScript
  `,
  isolation: "worktree"
})

// 测试工程师
Task({
  subagent_type: "ai-dev:test-automator",
  team_name: currentTeam,
  name: "test-engineer",
  prompt: `
    你是测试自动化专家，负责测试: ${description}

    ## 任务
    1. 编写集成测试
    2. 编写 E2E 测试
    3. 生成覆盖率报告

    ## 协作
    - 等待前端和后端完成后开始
    - 与 frontend-dev 和 backend-dev 确认测试范围

    ## 注意
    这是最后一个任务，依赖前端和后端完成
  `
})
```

### Step 5: 创建任务并设置依赖

```typescript
// 创建任务
TaskCreate({
  subject: "前端开发",
  description: "UI组件、表单验证、API集成",
  activeForm: "开发前端功能中",
  owner: "frontend-dev"
})

TaskCreate({
  subject: "后端开发",
  description: "API端点、数据模型、业务逻辑",
  activeForm: "开发后端功能中",
  owner: "backend-dev"
})

TaskCreate({
  subject: "集成测试",
  description: "集成测试、E2E测试、覆盖率报告",
  activeForm: "编写测试中",
  owner: "test-engineer",
  addBlockedBy: ["1", "2"]  // 依赖前端和后端
})
```

### Step 6: 监控与协调

```typescript
// 定期检查进度
const status = TaskList()

// 处理协作需求
// 例如：前端需要确认 API 响应格式
SendMessage({
  type: "message",
  recipient: "backend-dev",
  content: "请确认登录接口返回的用户对象包含哪些字段？",
  summary: "API 字段确认"
})

// 收到响应后
// backend-dev 会回复确认信息
```

---

## 协作通信示例

### API 变更协商

```typescript
// 后端需要修改 API 响应格式
SendMessage({
  type: "message",
  recipient: "frontend-dev",
  content: `
    ## API 变更通知

    登录接口响应格式变更:
    - 移除: user.avatar
    - 新增: user.profile.avatarUrl

    请更新前端代码。
  `,
  summary: "API 响应格式变更"
})
```

### 完成通知

```typescript
// 前端完成开发
TaskUpdate({ taskId: "1", status: "completed" })

SendMessage({
  type: "message",
  recipient: "test-engineer",
  content: `
    前端开发已完成，可以开始编写测试。
    组件位置: src/components/LoginForm.tsx
  `,
  summary: "前端开发完成"
})
```

---

## 功能开发报告格式

```markdown
# 功能开发报告

## 📋 功能概述
- 名称: ${featureName}
- 描述: ${description}
- 开发时间: ${duration}

## 👥 团队贡献
- frontend-dev: 前端组件、表单验证
- backend-dev: API 端点、数据模型
- test-engineer: 集成测试、E2E 测试

## 📁 文件变更
### 前端
- src/components/LoginForm.tsx (新增)
- src/hooks/useAuth.ts (新增)

### 后端
- src/api/auth.ts (新增)
- src/db/schema/users.ts (修改)

### 测试
- tests/integration/auth.test.ts (新增)
- tests/e2e/login.spec.ts (新增)

## 📊 测试覆盖率
- 单元测试: 85%
- 集成测试: 72%
- E2E 测试: 3 个场景

## 🔄 API 契约
${apiContract}

## 📝 后续建议
- [ ] 添加更多边界测试
- [ ] 性能优化
- [ ] 文档完善
```

---

## 完成后自动验收

**功能开发完成后，自动触发前端验收测试:**

```typescript
// Step 7: 自动验收
// 当所有开发任务完成后，自动启动前端验收

// 检查是否有前端页面需要验收
if (hasFrontendPages) {
  // 自动启动验收
  SendMessage({
    type: "message",
    recipient: "team-lead",
    content: `
## 🎉 功能开发完成

启动前端验收测试...

\`\`\`bash
/ai:acceptance ${baseUrl} --pages "${pagesToTest}" --change ${changeId} --report
\`\`\`
    `,
    summary: "启动自动验收"
  })

  // 自动执行验收
  // - 自动检测前端页面
  // - 自动选择最佳执行模式
  // - 生成验收报告
}
```

### 自动验收触发条件

| 条件 | 自动验收 |
|------|----------|
| 有前端组件变更 | ✅ 自动验收 |
| 仅后端 API 变更 | ❌ 跳过 (API 测试即可) |
| 全栈变更 | ✅ 自动验收前端 |
| 测试/文档变更 | ❌ 跳过 |

### 自动验收输出

```markdown
## ✅ 验收测试完成

- **验收 ID**: ACC-20260227-001
- **关联变更**: CHG-xxx
- **验收页面**: 3
- **通过率**: 100%
- **报告**: codebox/acceptance/2026-02-27/CHG-xxx/report.md

### 验收详情
| 页面 | 状态 | 截图 |
|------|------|------|
| /login | ✅ PASS | screenshots/login-xxx.png |
| /register | ✅ PASS | screenshots/register-xxx.png |
| /profile | ✅ PASS | screenshots/profile-xxx.png |
```

---

## 使用示例

```bash
# 开发用户认证功能
/ai:team feature 实现用户登录注册功能

# 指定前后端目录
/ai:team feature 实现购物车 --frontend src/ui --backend src/services

# 复杂功能
/ai:team feature 实现订单管理系统，包括创建、查询、取消订单功能
```