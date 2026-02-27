---
name: ai:test-web
description: Web automation testing - browser interactions, form testing, screenshots, and E2E validation
argument-hint: "<url> [--login] [--screenshot] [--validate <selector>]"
allowed-tools: Bash, Read, Write
execution-mode: subagent
internal: true
---

# /ai:test-web - Web 自动化测试

使用 agent-browser 进行 Web 自动化测试，支持表单填写、截图、E2E 验证。

---

## Execution Mode

此命令作为 **subagent** 执行，不占用主会话上下文。

```
/ai:test-web https://example.com --screenshot
    ↓
Launch Task tool with subagent:
  - Isolated browser session
  - Execute test steps
    ↓
Returns Test Report + Screenshots
```

---

## Usage

```bash
/ai:test-web <url>                           # 基础导航和快照
/ai:test-web <url> --screenshot              # 导航并截图
/ai:test-web <url> --login                   # 测试登录流程
/ai:test-web <url> --validate "selector"     # 验证元素存在
/ai:test-web <url> --e2e                     # 完整 E2E 测试
```

---

## Options

| 选项 | 说明 |
|------|------|
| `--screenshot` | 截取页面截图 |
| `--login` | 测试登录流程 (需要交互输入凭据) |
| `--validate <selector>` | 验证指定元素存在 |
| `--e2e` | 执行完整 E2E 测试流程 |
| `--headed` | 显示浏览器窗口 (调试模式) |

---

## Step 1: Parse Arguments

解析 `$ARGUMENTS`:
- 提取 URL
- 检测 flags: --screenshot, --login, --validate, --e2e, --headed

---

## Step 2: Initialize Browser

```bash
# 打开浏览器并导航
agent-browser open "$URL"

# 获取可交互元素
agent-browser snapshot -i
```

---

## Step 3: Execute Test Mode

### Basic Mode (default)

```bash
agent-browser open "$URL"
agent-browser snapshot -i
agent-browser get title
agent-browser get url
```

### Screenshot Mode (--screenshot)

```bash
agent-browser open "$URL"
agent-browser wait --load networkidle
agent-browser screenshot "test-$(date +%Y%m%d-%H%M%S).png"
```

### Login Test Mode (--login)

```bash
agent-browser open "$URL"
agent-browser snapshot -i
# 识别登录表单元素
# @e1 = username/email field
# @e2 = password field
# @e3 = submit button

agent-browser fill @e1 "$USERNAME"
agent-browser fill @e2 "$PASSWORD"
agent-browser click @e3
agent-browser wait --load networkidle
agent-browser snapshot -i  # 验证登录后状态
```

### Validation Mode (--validate)

```bash
agent-browser open "$URL"
agent-browser wait "$SELECTOR"
agent-browser get text "$SELECTOR"
```

### E2E Mode (--e2e)

完整端到端测试流程:

1. 导航到页面
2. 获取所有可交互元素
3. 验证关键元素存在
4. 执行用户流程
5. 截图记录结果
6. 生成测试报告

---

## Step 4: Generate Report

```markdown
## Web Test Report

**URL**: $URL
**Date**: $(date)
**Status**: PASS/FAIL

### Page Info
- Title: ...
- Load Time: ...

### Elements Found
- Forms: X
- Buttons: X
- Links: X

### Validations
| Check | Result |
|-------|--------|
| Page loads | PASS |
| Element exists | PASS |
| Form submits | PASS |

### Screenshots
- [screenshot-1.png]
```

---

## Step 5: Cleanup

```bash
agent-browser close
```

---

## Examples

### 基础页面检查

```bash
/ai:test-web https://example.com
```

### 登录流程测试

```bash
/ai:test-web https://app.example.com/login --login
```

### 截图并验证元素

```bash
/ai:test-web https://example.com --screenshot --validate "#main-content"
```

### 调试模式 (显示浏览器)

```bash
/ai:test-web https://example.com --headed
```

---

## Integration

此命令可集成到 ai-dev 工作流:

- **Phase 5 Quality**: 自动运行 E2E 测试
- **ai:research**: 抓取竞品页面内容
- **手动测试**: 验证前端功能

---

## Prerequisites

确保已安装 agent-browser:

```bash
npm install -g agent-browser
agent-browser install  # 下载浏览器
```
