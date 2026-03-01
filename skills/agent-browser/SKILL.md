---
name: agent-browser
description: |
  This skill should be used when the user needs to automate browser interactions,
  test web applications, fill forms, take screenshots, or extract data from web pages.
  Uses a ref-based element selection system (@e1, @e2) optimized for LLM interaction.
  Supports session isolation for parallel testing and semantic locators for accessibility.

  <example>
  Context: User wants to test a login flow on their local development server
  user: "帮我测试一下 localhost:3000/login 的登录流程，用 admin@test.com 登录看看能不能进 dashboard"
  assistant: "I'll use the agent-browser skill to open the login page, fill in the credentials, and verify the dashboard loads."
  <commentary>
  User requests browser-based testing of a specific web flow, triggering this skill for automated interaction.
  </commentary>
  </example>

  <example>
  Context: User needs a screenshot of the current state of a deployed page
  user: "screenshot the homepage at https://staging.myapp.com and check if the hero banner is showing correctly"
  assistant: "I'll use the agent-browser skill to open the page, take a screenshot, and verify the hero banner element."
  <commentary>
  Screenshot and visual verification request for a web page triggers this skill.
  </commentary>
  </example>

  <example>
  Context: User wants to fill out and submit a multi-step form
  user: "网页测试一下注册表单，填完所有字段然后提交，看看有没有报错"
  assistant: "I'll use the agent-browser skill to navigate to the registration form, fill all fields with test data, submit, and check for errors."
  <commentary>
  Form filling and submission testing on a web page triggers this skill.
  </commentary>
  </example>
version: 6.0.15
status: ga
profile: debug
triggers:
  - browser
  - web test
  - test website
  - screenshot
  - fill form
  - 浏览器
  - 网页测试
  - 截图
  - 表单填写
  - e2e test
  - 端到端测试
---

# Agent Browser

> Headless browser automation CLI optimized for AI agents.

## Trigger Detection / 触发词

This skill triggers on: "browser", "test website", "screenshot", "fill form", "浏览器", "网页测试".

## Quick Start

```bash
# 安装（全局）
npm install -g agent-browser
agent-browser install

# 核心工作流
agent-browser open https://example.com
agent-browser snapshot -i          # 获取可交互元素
agent-browser click @e1            # 使用 ref 交互
agent-browser fill @e2 "text"      # 填写表单
agent-browser screenshot result.png
```

---

## Core Workflow

### Ref 系统（推荐）

Snapshot 生成带有 ref 标记的元素列表，便于 AI 理解和交互：

```bash
# 1. 打开页面
agent-browser open https://app.example.com/login

# 2. 获取可交互元素（带 ref）
agent-browser snapshot -i

# 输出示例：
# @e1: button "Sign In"
# @e2: input[type="email"] placeholder="Email"
# @e3: input[type="password"] placeholder="Password"
# @e4: checkbox "Remember me"

# 3. 使用 ref 交互
agent-browser fill @e2 "user@example.com"
agent-browser fill @e3 "password123"
agent-browser click @e1

# 4. 页面变化后重新 snapshot
agent-browser snapshot -i
```

### 为什么使用 Ref？

| 方式 | 示例 | 稳定性 | AI 友好度 |
|------|------|--------|-----------|
| Ref | `@e1` | ⭐⭐⭐ | ⭐⭐⭐ |
| CSS | `#login-btn` | ⭐⭐ | ⭐⭐ |
| XPath | `//button[@id='login']` | ⭐ | ⭐ |

---

## Commands Reference

### Navigation

| 命令 | 说明 | 示例 |
|------|------|------|
| `open <url>` | 打开页面 | `open https://example.com` |
| `back` | 后退 | `back` |
| `forward` | 前进 | `forward` |
| `reload` | 刷新 | `reload` |

### Interaction

| 命令 | 说明 | 示例 |
|------|------|------|
| `click <sel>` | 点击元素 | `click @e1` |
| `dblclick <sel>` | 双击 | `dblclick @e1` |
| `fill <sel> <text>` | 填写输入框 | `fill @e2 "hello"` |
| `type <sel> <text>` | 逐字输入 | `type @e2 "hello"` |
| `press <key>` | 按键 | `press Enter` |
| `hover <sel>` | 悬停 | `hover @e1` |
| `check <sel>` | 勾选 | `check @e3` |
| `uncheck <sel>` | 取消勾选 | `uncheck @e3` |
| `select <sel> <val>` | 下拉选择 | `select @e4 "option1"` |

### Snapshot & Screenshot

| 命令 | 说明 | 示例 |
|------|------|------|
| `snapshot` | 获取页面结构 | `snapshot` |
| `snapshot -i` | 获取可交互元素 | `snapshot -i` |
| `screenshot [path]` | 截图 | `screenshot login.png` |

### Information

| 命令 | 说明 | 示例 |
|------|------|------|
| `get text <sel>` | 获取文本 | `get text @e1` |
| `get title` | 获取标题 | `get title` |
| `get url` | 获取 URL | `get url` |
| `get html <sel>` | 获取 HTML | `get html @e1` |
| `get value <sel>` | 获取输入值 | `get value @e2` |

### Wait

| 命令 | 说明 | 示例 |
|------|------|------|
| `wait <sel>` | 等待元素出现 | `wait @e1` |
| `wait --text <text>` | 等待文本出现 | `wait --text "Welcome"` |
| `wait --load networkidle` | 等待网络空闲 | `wait --load networkidle` |

### State Management

| 命令 | 说明 | 示例 |
|------|------|------|
| `state save <file>` | 保存登录状态 | `state save auth.json` |
| `state load <file>` | 加载登录状态 | `state load auth.json` |

### Semantic Locators

| 命令 | 说明 | 示例 |
|------|------|------|
| `find role <role> <action>` | 按角色查找 | `find role button click` |
| `find text <text> <action>` | 按文本查找 | `find text "Sign In" click` |
| `find label <label> <action>` | 按标签查找 | `find label "Email" fill "test@example.com"` |
| `find placeholder <ph> <action>` | 按占位符查找 | `find placeholder "Search" fill "query"` |
| `find testid <id> <action>` | 按 data-testid 查找 | `find testid "submit-btn" click` |

---

## Sessions

支持多个独立浏览器实例：

```bash
# 创建命名会话
agent-browser open https://app.com --session test1
agent-browser open https://app.com --session test2

# 在不同会话中操作
agent-browser click @e1 --session test1
agent-browser fill @e2 "text" --session test2

# 每个 session 独立：
# - 独立的浏览器实例
# - 独立的 Cookies 和存储
# - 独立的历史记录
```

---

## Flags

| Flag | 说明 | 示例 |
|------|------|------|
| `--session <name>` | 指定会话 | `--session auth-test` |
| `--headed` | 显示浏览器窗口 | `open url --headed` |
| `--json` | JSON 输出（机器可读） | `snapshot --json` |
| `--timeout <ms>` | 超时时间 | `--timeout 30000` |

---

## Common Workflows

### 登录测试

```bash
agent-browser open https://app.com/login
agent-browser snapshot -i
agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password"
agent-browser click @e3
agent-browser wait --text "Dashboard"
agent-browser screenshot login-success.png
```

### 表单提交测试

```bash
agent-browser open https://app.com/form
agent-browser snapshot -i
agent-browser fill @e1 "John Doe"
agent-browser fill @e2 "john@example.com"
agent-browser select @e3 "Option A"
agent-browser check @e4
agent-browser click @e5
agent-browser wait --load networkidle
agent-browser get text @success-message
```

### 保存/恢复登录状态

```bash
# 首次登录并保存状态
agent-browser open https://app.com/login
agent-browser fill @e1 "user@example.com"
agent-browser fill @e2 "password"
agent-browser click @e3
agent-browser wait --text "Dashboard"
agent-browser state save auth.json

# 后续测试直接加载状态
agent-browser state load auth.json
agent-browser open https://app.com/dashboard
# 已登录状态
```

---

## Integration with ai-dev

在 Phase 5 (Quality Validation) 中可用于 E2E 测试：

```yaml
# workflow-patterns.md
e2e-testing:
  tool: agent-browser
  workflow:
    - open: "${APP_URL}"
    - snapshot: "-i"
    - verify: "关键元素存在"
    - interaction: "核心用户流程"
    - screenshot: "evidence.png"
```

---

## Common Pitfalls

### Pitfall 1: 不刷新 Snapshot 就操作

**症状**: 页面已变化但仍用旧的 @e1 ref 交互
**后果**: 操作错误元素或报错 "element not found"
**修正**: 每次页面状态变化后（点击导航、表单提交、弹窗）重新执行 `snapshot -i`

### Pitfall 2: 跳过 wait 直接断言

**症状**: 点击按钮后立即检查结果文本
**后果**: 异步操作未完成，断言失败（假阳性）
**修正**: 使用 `wait --text "Expected"` 或 `wait --load networkidle` 等待状态稳定

### Pitfall 3: 硬编码 CSS 选择器代替 Ref

**症状**: 使用 `click #login-btn` 而非 `click @e1`
**后果**: UI 改版后选择器失效，测试全面崩溃
**修正**: 始终使用 snapshot ref（@e1），它们自动适应 DOM 变化

---

## Troubleshooting

| 问题 | 解决方案 |
|------|----------|
| 元素未找到 | 使用 `wait <sel>` 等待元素加载 |
| 点击无效 | 尝试 `wait --load networkidle` 后再操作 |
| 登录状态丢失 | 使用 `state save/load` 保存会话 |
| 调试问题 | 添加 `--headed` 查看浏览器界面 |

---

## Dependencies

- **Node.js** 18+ (for agent-browser CLI)
- **Playwright** (installed automatically with agent-browser)

---

## Version History

| Version | Changes |
|---------|---------|
| 5.0.20 | Added Chinese trigger phrases and references |
| 5.0.0 | Initial release with ref-based selection |

---

## See Also

- [commands.md](references/commands.md) - 完整命令参考
- [workflows.md](references/workflows.md) - 工作流模板
- [agent-browser GitHub](https://github.com/vercel-labs/agent-browser)
