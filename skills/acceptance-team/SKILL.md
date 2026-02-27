---
name: acceptance-team
description: |
  Agent Teams 并行验收技能。使用 Claude Code 原生 Agent Teams 能力
  实现多页面并行验收测试，每个页面由独立的 acceptance-tester 处理。
  触发词: "并行验收", "团队验收", "acceptance team", "多页面测试"
version: 5.2.1
status: experimental
triggers:
  - 并行验收
  - 团队验收
  - acceptance team
  - 多页面测试
  - parallel acceptance
---

# Acceptance Team Skill

> Agent Teams 并行验收技能 - 多页面同时验收，提高效率

## Purpose

Acceptance Team 用于并行验收多个前端页面，利用 Agent Teams 能力:

- 🚀 **并行执行**: 多个页面同时验收，大幅缩短测试时间
- 📸 **截图证据**: 每个页面独立截图，作为验收证据
- ✅ **自动验证**: 执行预定义的验证检查项
- 📊 **统一报告**: 汇总所有验收结果生成报告
- 🔗 **任务关联**: 验收与变更、计划、任务自动关联

---

## Quick Start

```bash
# 基础并行验收
/ai:team:acceptance http://localhost:3000 \
  --pages "home,login,dashboard" \
  --change CHG-xxx

# 完整模式 + 报告生成
/ai:team:acceptance http://localhost:3000 \
  --pages "home,login,dashboard,settings,profile" \
  --change CHG-xxx \
  --mode full \
  --report
```

---

## 工作流程

```
┌─────────────────────────────────────────────────────────────┐
│                    Acceptance Team 工作流                    │
└─────────────────────────────────────────────────────────────┘

用户请求
    │
    ▼
┌─────────────────────┐
│ 1. 创建验收团队      │ TeamCreate("acceptance-{changeId}")
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ 2. 创建共享任务列表  │ TaskCreate × N (每个页面一个任务)
└─────────────────────┘
    │
    ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. 并行启动验收队友                                          │
│    ┌───────────┬───────────┬───────────┐                    │
│    │ tester-   │ tester-   │ tester-   │                    │
│    │ home      │ login     │ dashboard │                    │
│    │           │           │           │                    │
│    │ • 打开    │ • 打开    │ • 打开    │                    │
│    │ • 截图    │ • 截图    │ • 截图    │                    │
│    │ • 验证    │ • 验证    │ • 验证    │                    │
│    │ • 报告    │ • 报告    │ • 报告    │                    │
│    └───────────┴───────────┴───────────┘                    │
│              (并行执行)                                       │
└─────────────────────────────────────────────────────────────┘
    │
    ▼
┌─────────────────────┐
│ 4. 收集验收结果      │ 汇总所有队友的验收数据
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ 5. 生成汇总报告      │ report.md + report.html
└─────────────────────┘
    │
    ▼
┌─────────────────────┐
│ 6. 清理团队资源      │ TeamDelete()
└─────────────────────┘
```

---

## 核心组件

### 1. Team Orchestrator

负责创建和管理验收团队:

```typescript
// 创建验收团队
TeamCreate({
  team_name: `acceptance-${changeId}`,
  description: `并行验收: ${pages.join(', ')}`,
  agent_type: "general-purpose"
})

// 创建任务列表
for (const page of pages) {
  TaskCreate({
    subject: `验收页面: ${page}`,
    description: `使用 agent-browser 验收 ${page} 页面`,
    activeForm: `验收 ${page} 页面中`
  })
}
```

### 2. Acceptance Tester Agents

每个页面的验收队友:

```typescript
Task({
  subagent_type: "acceptance-tester",
  description: `验收 ${page} 页面`,
  team_name: teamName,
  name: `tester-${page}`,
  prompt: `
    验收 ${page} 页面:
    - URL: ${baseUrl}/${page}
    - 模式: ${mode}
    - 截图目录: ${screenshotDir}
  `
})
```

### 3. Communication Protocol

队友间通信:

```typescript
// 队友向领导报告结果
SendMessage({
  type: "message",
  recipient: "team-lead",
  content: `## ${page} 验收完成\n- 状态: ${status}\n- 截图: ${screenshot}`,
  summary: `${page} 验收${status === 'passed' ? '通过' : '失败'}`
})

// 领导关闭队友
SendMessage({
  type: "shutdown_request",
  recipient: `tester-${page}`,
  content: "验收任务完成"
})
```

---

## 验收检查项

### Quick Mode

| 检查项 | 说明 |
|--------|------|
| `page_load` | 页面加载成功 (HTTP 200) |
| `title_correct` | 页面标题正确 |
| `no_js_errors` | 无 JavaScript 错误 |
| `content_visible` | 主要内容可见 |

### Full Mode

| 检查项 | 说明 |
|--------|------|
| `page_load` | 页面加载成功 |
| `title_correct` | 页面标题正确 |
| `no_js_errors` | 无 JavaScript 错误 |
| `navigation_visible` | 导航元素可见 |
| `forms_interactive` | 表单/按钮可交互 |
| `images_loaded` | 图片加载成功 |
| `responsive` | 响应式布局正确 |

### Regression Mode

| 检查项 | 说明 |
|--------|------|
| `page_load` | 页面加载成功 |
| `screenshot_match` | 截图与基准匹配 |
| `core_function` | 核心功能正常 |

### Smoke Mode

| 检查项 | 说明 |
|--------|------|
| `page_load` | 页面加载成功 |
| `critical_path` | 关键路径通畅 |

---

## 配置选项

### 环境变量

| 变量 | 说明 | 默认值 |
|------|------|--------|
| `ACCEPTANCE_TEAM_MAX_SIZE` | 最大并行队友数 | 5 |
| `ACCEPTANCE_TIMEOUT` | 验收超时时间 (秒) | 300 |
| `ACCEPTANCE_SCREENSHOT_DIR` | 截图保存目录 | codebox/acceptance/ |
| `ACCEPTANCE_HEADLESS` | 无头模式 | true |

### 任务配置

```json
{
  "acceptance": {
    "defaultMode": "full",
    "maxRetries": 2,
    "screenshotFormat": "png",
    "viewport": {
      "width": 1280,
      "height": 720
    },
    "timeout": {
      "pageLoad": 30000,
      "element": 5000
    }
  }
}
```

---

## 输出目录结构

```
codebox/acceptance/
├── index.json                       # 全局验收索引
├── templates/
│   ├── index-schema.json
│   └── acceptance-report.md
└── {YYYY-MM}/                       # 按月份归档
    └── {changeId}/
        ├── state.json               # 验收状态
        ├── report.md                # Markdown 报告
        ├── report.html              # HTML 报告
        └── screenshots/             # 截图证据
            ├── home-1709012345.png
            ├── login-1709012346.png
            └── dashboard-1709012347.png
```

---

## 性能对比

| 场景 | 串行验收 | 并行验收 (Team) | 提升 |
|------|----------|-----------------|------|
| 3 页面 | ~90s | ~35s | 61% |
| 5 页面 | ~150s | ~40s | 73% |
| 10 页面 | ~300s | ~60s | 80% |

*基于平均每页面 30s 验收时间计算*

---

## 最佳实践

### 1. 页面分组

按功能模块分组验收:

```bash
# 认证模块
/ai:team:acceptance $URL --pages "login,register,forgot-password" --change CHG-auth

# 用户模块
/ai:team:acceptance $URL --pages "profile,settings,notifications" --change CHG-user
```

### 2. 模式选择

| 场景 | 推荐模式 |
|------|----------|
| 快速检查 | quick |
| 完整验证 | full |
| 版本发布 | regression |
| CI/CD | smoke |

### 3. 资源管理

```bash
# 限制并行数量
export ACCEPTANCE_TEAM_MAX_SIZE=3

# 设置超时
export ACCEPTANCE_TIMEOUT=180
```

### 4. 错误处理

```typescript
// 单个页面失败不影响其他页面
try {
  await testPage(page)
} catch (error) {
  // 记录错误，继续其他页面
  recordError(page, error)
}
```

---

## 故障排除

### 问题: 队友未响应

```typescript
// 检查团队配置
Read({ file_path: `~/.claude/teams/${teamName}/config.json` })

// 发送消息唤醒
SendMessage({
  type: "message",
  recipient: `tester-${page}`,
  content: "请更新验收进度"
})
```

### 问题: 截图保存失败

```bash
# 检查目录权限
ls -la codebox/acceptance/

# 创建目录
mkdir -p codebox/acceptance/$(date +%Y-%m)/${CHANGE_ID}/screenshots
```

### 问题: 浏览器启动失败

```bash
# 安装浏览器
agent-browser install

# 检查依赖
agent-browser --version
```

---

## 与其他组件集成

### 与 ai-dev 工作流集成

```yaml
# Phase 5: Quality Validation
frontend_acceptance:
  steps:
    - name: "Run parallel acceptance"
      command: /ai:team:acceptance ${BASE_URL} --pages "${PAGES}" --change ${CHANGE_ID} --report

    - name: "Review report"
      action: read_file
      path: codebox/acceptance/${DATE}/${CHANGE_ID}/report.md
```

### 与 Change Management 集成

```json
// state.json
{
  "acceptance": {
    "latestId": "ACC-20260227-001",
    "latestStatus": "passed",
    "reportPath": "codebox/acceptance/2026-02/CHG-xxx/report.md",
    "linkedTaskIds": ["1", "2", "3"]
  }
}
```

---

## 相关文档

- [ai:acceptance 命令](../../commands/ai:acceptance.md)
- [ai:team:acceptance 命令](../../commands/ai:team/acceptance.md)
- [acceptance-tester Agent](../../agents/acceptance-tester.md)
- [acceptance-reporter 技能](../acceptance-reporter/SKILL.md)
- [team-collaboration 技能](../team-collaboration/SKILL.md)

---

## 版本历史

| Version | Changes |
|---------|---------|
| 1.0.0 | 初始版本，支持并行验收、多模式测试、报告生成 |