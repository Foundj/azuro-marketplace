---
name: ai:team:acceptance
description: Agent Teams parallel acceptance testing - multiple pages tested simultaneously with screenshot evidence
argument-hint: "<url> --pages <list> [--change <id>] [--mode <mode>] [--report]"
allowed-tools: TeamCreate, TeamDelete, TaskCreate, TaskUpdate, TaskList, TaskGet, SendMessage, Task, Bash, Read, Write
execution-mode: subagent
---

# /ai:team:acceptance - 团队并行验收

使用 Agent Teams 并行验收多个前端页面，每个页面由独立的验收队友处理。

---

## Usage

```bash
/ai:team:acceptance <url> --pages <list>              # 并行验收多个页面
/ai:team:acceptance <url> --pages <list> --change <id> # 关联变更
/ai:team:acceptance <url> --pages <list> --mode <mode> # 指定测试模式
/ai:team:acceptance <url> --pages <list> --report     # 生成报告
```

---

## Options

| 选项 | 说明 |
|------|------|
| `--pages <list>` | 逗号分隔的页面列表 (必需) |
| `--change <id>` | 关联变更 ID |
| `--plan <id>` | 关联计划 ID |
| `--mode <mode>` | 测试模式: quick\|full\|regression\|smoke |
| `--report` | 生成完整验收报告 |

---

## 工作流程

```
用户请求验收
    │
    ▼
┌─────────────────────────────────────────┐
│ Step 1: 创建验收团队                      │
│ • TeamCreate("acceptance-{changeId}")    │
│ • 创建共享任务列表                        │
└─────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────┐
│ Step 2: 生成验收队友                      │
│ • 为每个页面创建 acceptance-tester       │
│ • 使用 Task 工具并行启动                  │
└─────────────────────────────────────────┘
    │
    ├── tester-home ──────→ 验收首页 (/)
    │     • agent-browser open /
    │     • 截图 home-{ts}.png
    │     • 验证检查项
    │     • SendMessage 结果
    │
    ├── tester-login ─────→ 验收登录页 (/login)
    │     • agent-browser open /login
    │     • 截图 login-{ts}.png
    │     • 验证检查项
    │     • SendMessage 结果
    │
    └── tester-dashboard ─→ 验收仪表盘 (/dashboard)
          • agent-browser open /dashboard
          • 截图 dashboard-{ts}.png
          • 验证检查项
          │
    ▼
┌─────────────────────────────────────────┐
│ Step 3: 收集结果                         │
│ • 等待所有队友完成                       │
│ • 汇总验收结果                           │
└─────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────┐
│ Step 4: 生成报告                         │
│ • 合并所有页面截图                       │
│ • 生成 report.md + report.html          │
│ • 更新 state.json                        │
└─────────────────────────────────────────┘
    │
    ▼
┌─────────────────────────────────────────┐
│ Step 5: 清理团队                         │
│ • 发送 shutdown_request 给所有队友       │
│ • TeamDelete 清理团队资源                │
└─────────────────────────────────────────┘
```

---

## Step 1: 解析参数

```bash
URL=""           # 目标 URL
PAGES=""         # 页面列表
CHANGE_ID=""     # 变更 ID
PLAN_ID=""       # 计划 ID
MODE="full"      # 测试模式
FLAG_REPORT=false

# 解析参数
for arg in $ARGUMENTS; do
  case $arg in
    http*://*) URL="$arg" ;;
    --pages=*) PAGES="${arg#*=}" ;;
    --change=*) CHANGE_ID="${arg#*=}" ;;
    --plan=*) PLAN_ID="${arg#*=}" ;;
    --mode=*) MODE="${arg#*=}" ;;
    --report) FLAG_REPORT=true ;;
  esac
done

# 验证必需参数
if [ -z "$URL" ] || [ -z "$PAGES" ]; then
  echo "❌ 错误: 必须提供 URL 和 --pages 参数"
  echo "用法: /ai:team:acceptance <url> --pages \"home,login,dashboard\""
  exit 1
fi
```

---

## Step 2: 创建验收团队

```typescript
// 生成团队名称
const teamName = `acceptance-${CHANGE_ID || Date.now().toString(36)}`

// 创建团队
TeamCreate({
  team_name: teamName,
  description: `并行验收: ${PAGES}`,
  agent_type: "general-purpose"
})
```

---

## Step 3: 创建验收任务

```typescript
// 解析页面列表
const pages = PAGES.split(',')

// 创建共享任务列表
for (const page of pages) {
  TaskCreate({
    subject: `验收页面: ${page}`,
    description: `使用 agent-browser 验收 ${page} 页面，截图并验证检查项`,
    activeForm: `验收 ${page} 页面中`
  })
}
```

---

## Step 4: 并行启动验收队友

```typescript
// 获取团队配置
const teamConfig = Read({ file_path: `~/.claude/teams/${teamName}/config.json` })

// 为每个页面创建验收队友
for (const page of pages) {
  Task({
    subagent_type: "acceptance-tester",  // 使用验收测试 Agent
    description: `验收 ${page} 页面`,
    team_name: teamName,
    name: `tester-${page}`,
    prompt: `
你是验收测试队友，负责验收 ${page} 页面。

## 任务信息
- **验收 ID**: ${ACCEPTANCE_ID}
- **页面名称**: ${page}
- **页面 URL**: ${URL}/${page === 'home' ? '' : page}
- **测试模式**: ${MODE}
- **截图目录**: ${SCREENSHOT_DIR}

## 执行步骤
1. 使用 agent-browser 打开页面
2. 等待页面加载完成
3. 捕获页面截图
4. 执行验证检查项
5. 记录任何错误或问题
6. 使用 SendMessage 向 team-lead 报告结果

## 验证检查项
- 页面加载成功 (HTTP 200)
- 页面标题正确
- 无 JavaScript 错误
- 主要内容可见

## 完成后
使用 SendMessage 发送验收结果:
- 状态 (passed/failed)
- 截图路径
- 验证详情
- 发现的问题
    `
  })
}
```

---

## Step 5: 等待队友完成

```typescript
// 监控任务状态
let allCompleted = false
const results = []

while (!allCompleted) {
  const taskList = TaskList()

  // 检查所有任务是否完成
  const pendingTasks = taskList.filter(t => t.status !== 'completed')
  allCompleted = pendingTasks.length === 0

  if (!allCompleted) {
    // 等待 5 秒后再次检查
    await sleep(5000)
  }
}
```

---

## Step 6: 收集验收结果

```typescript
// 从各队友收集结果
for (const page of pages) {
  // 队友已通过 SendMessage 发送结果
  // 结果已保存到共享目录
  const resultPath = `${ACCEPTANCE_DIR}/results/${page}.json`
  const result = Read({ file_path: resultPath })
  results.push(JSON.parse(result))
}
```

---

## Step 7: 生成汇总报告

```typescript
// 计算汇总统计
const summary = {
  totalPages: results.length,
  passedPages: results.filter(r => r.status === 'passed').length,
  failedPages: results.filter(r => r.status === 'failed').length,
  totalValidations: results.reduce((sum, r) => sum + r.validations.length, 0),
  passRate: 0
}

// 生成报告
if (FLAG_REPORT) {
  // 生成 Markdown 报告
  const mdReport = generateMarkdownReport(results, summary)
  Write({
    file_path: `${ACCEPTANCE_DIR}/report.md`,
    content: mdReport
  })

  // 生成 HTML 报告
  const htmlReport = generateHTMLReport(results, summary)
  Write({
    file_path: `${ACCEPTANCE_DIR}/report.html`,
    content: htmlReport
  })
}
```

---

## Step 8: 清理团队

```typescript
// 向所有队友发送关闭请求
for (const page of pages) {
  SendMessage({
    type: "shutdown_request",
    recipient: `tester-${page}`,
    content: "验收任务完成，感谢贡献！"
  })
}

// 等待队友关闭
await sleep(3000)

// 清理团队资源
TeamDelete()
```

---

## 输出示例

### 成功

```
✅ 团队并行验收完成: ACC-20260227-001

## 概览
- 验收页面: 5
- 通过页面: 5
- 失败页面: 0
- 通过率: 100%
- 执行时间: 45s (并行)

## 页面详情
| 页面 | 状态 | 截图 | 验证项 |
|------|------|------|--------|
| home | ✅ PASS | home-20260227-143022.png | 4/4 |
| login | ✅ PASS | login-20260227-143025.png | 4/4 |
| dashboard | ✅ PASS | dashboard-20260227-143028.png | 4/4 |
| settings | ✅ PASS | settings-20260227-143031.png | 4/4 |
| profile | ✅ PASS | profile-20260227-143034.png | 4/4 |

📁 报告: .agent/acceptance/2026-02-27/CHG-xxx/report.md
```

### 部分失败

```
⚠️ 团队并行验收完成 (部分失败): ACC-20260227-002

## 概览
- 验收页面: 5
- 通过页面: 3
- 失败页面: 2
- 通过率: 60%

## 问题详情
- login: JavaScript 错误 - Cannot read property 'value' of null
- dashboard: 页面加载超时

📁 报告: .agent/acceptance/2026-02-27/CHG-xxx/report.md
```

---

## 与 /ai:acceptance 对比

| 特性 | /ai:acceptance | /ai:team:acceptance |
|------|----------------|---------------------|
| 执行模式 | 串行 | 并行 |
| 页面处理 | 逐个验收 | 同时验收 |
| 适用场景 | 单页面、简单验收 | 多页面、复杂验收 |
| 效率 | 较慢 (N × 单页面时间) | 较快 (接近单页面时间) |
| 资源占用 | 低 | 高 (多个 Agent) |

---

## 最佳实践

1. **页面数量**: 推荐 3-5 个页面并行验收
2. **资源隔离**: 每个队友使用独立的浏览器会话
3. **错误隔离**: 单个页面失败不影响其他页面
4. **结果汇总**: 自动合并所有队友的验收结果
5. **团队清理**: 验收完成后自动关闭团队

---

## 相关文档

- [ai:acceptance 命令](../commands/ai:acceptance.md)
- [acceptance-tester Agent](../agents/acceptance-tester.md)
- [team-orchestrator Agent](../agents/team-orchestrator.md)