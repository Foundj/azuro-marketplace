# Agent Browser Commands Reference

> 完整命令列表和参数说明

## Navigation Commands

### open

打开 URL 并导航到页面。

```bash
agent-browser open <url> [options]

# 别名
agent-browser goto <url>
agent-browser navigate <url>

# 选项
--session <name>     使用指定会话
--headed             显示浏览器窗口
--timeout <ms>       超时时间（默认 30000）

# 示例
agent-browser open https://example.com
agent-browser open https://app.com --session login-test --headed
```

### back / forward / reload

```bash
agent-browser back              # 后退
agent-browser forward           # 前进
agent-browser reload            # 刷新
agent-browser reload --hard     # 强制刷新（清除缓存）
```

---

## Interaction Commands

### click

```bash
agent-browser click <selector> [options]

# 变体
agent-browser dblclick <selector>    # 双击
agent-browser rightclick <selector>  # 右键

# 选项
--force              强制点击（即使被遮挡）
--position <x,y>     点击位置偏移

# 示例
agent-browser click @e1
agent-browser click "#submit-btn"
agent-browser dblclick @e2
```

### fill / type

```bash
# fill: 清空后填写
agent-browser fill <selector> <text>

# type: 逐字符输入（模拟真实打字）
agent-browser type <selector> <text> [options]

# 选项
--delay <ms>         每个字符间隔（仅 type）

# 示例
agent-browser fill @e1 "hello@example.com"
agent-browser type @e2 "password" --delay 100
```

### press

```bash
agent-browser press <key> [options]

# 支持的特殊键
Enter, Tab, Escape, Space, Backspace, Delete
ArrowUp, ArrowDown, ArrowLeft, ArrowRight
Control, Shift, Alt, Meta

# 组合键
agent-browser press "Control+a"
agent-browser press "Shift+Tab"

# 示例
agent-browser press Enter
agent-browser press "Control+c"
```

### hover

```bash
agent-browser hover <selector>

# 示例
agent-browser hover @e1
agent-browser hover ".dropdown-menu"
```

### check / uncheck

```bash
agent-browser check <selector>     # 勾选
agent-browser uncheck <selector>   # 取消勾选

# 示例
agent-browser check @e3
agent-browser uncheck "#remember-me"
```

### select

```bash
agent-browser select <selector> <value>

# 按值选择
agent-browser select @e1 "option-value"

# 按标签选择
agent-browser select @e1 --label "Display Text"

# 按索引选择
agent-browser select @e1 --index 2
```

---

## Snapshot & Screenshot

### snapshot

```bash
agent-browser snapshot [options]

# 选项
-i, --interactive    仅显示可交互元素
--json               JSON 格式输出
--full               完整 DOM 结构

# 示例
agent-browser snapshot -i
agent-browser snapshot --json > snapshot.json
```

### screenshot

```bash
agent-browser screenshot [path] [options]

# 选项
--full-page          整页截图（含滚动区域）
--element <sel>      元素截图
--quality <0-100>    JPEG 质量

# 示例
agent-browser screenshot                    # 默认 screenshot.png
agent-browser screenshot result.png
agent-browser screenshot --full-page full.png
agent-browser screenshot --element @e1 element.png
```

---

## Information Commands

### get

```bash
agent-browser get <property> [selector]

# 属性
text      获取文本内容
html      获取 HTML
value     获取输入值
title     获取页面标题
url       获取当前 URL
box       获取元素边界框

# 示例
agent-browser get text @e1
agent-browser get title
agent-browser get url
agent-browser get value @input
agent-browser get html @container
```

---

## Wait Commands

### wait

```bash
agent-browser wait <selector> [options]

# 等待元素
agent-browser wait @e1
agent-browser wait "#loading" --hidden    # 等待消失

# 等待文本
agent-browser wait --text "Welcome"
agent-browser wait --text "Success" --timeout 10000

# 等待页面状态
agent-browser wait --load load           # DOMContentLoaded
agent-browser wait --load domcontentloaded
agent-browser wait --load networkidle    # 网络空闲

# 等待时间
agent-browser wait --time 2000           # 等待 2 秒
```

---

## State Management

### state

```bash
# 保存状态（cookies, localStorage, sessionStorage）
agent-browser state save <file>

# 加载状态
agent-browser state load <file>

# 示例
agent-browser state save auth.json
agent-browser state load auth.json
```

---

## Semantic Locators

### find

基于语义属性查找并操作元素。

```bash
agent-browser find <type> <value> <action> [action-value]

# 类型
role          ARIA 角色（button, link, textbox, etc.）
text          可见文本
label         关联的 label 文本
placeholder   placeholder 属性
testid        data-testid 属性

# 动作
click, dblclick, hover, fill, check, uncheck

# 示例
agent-browser find role button click
agent-browser find text "Sign In" click
agent-browser find label "Email" fill "test@example.com"
agent-browser find placeholder "Search..." fill "query"
agent-browser find testid "submit-btn" click
```

---

## Advanced Commands

### mouse

```bash
agent-browser mouse move <x> <y>           # 移动鼠标
agent-browser mouse down                    # 按下
agent-browser mouse up                      # 释放
agent-browser mouse wheel <deltaY>          # 滚轮
```

### network

```bash
# 拦截请求
agent-browser network route <url-pattern> --abort
agent-browser network route <url-pattern> --fulfill <file>

# 监控请求
agent-browser network log --filter "api/*"
```

### set

```bash
# 视口大小
agent-browser set viewport <width> <height>

# 地理位置
agent-browser set geolocation <lat> <lon>

# 用户代理
agent-browser set useragent "<ua-string>"
```

### cookies

```bash
agent-browser cookies get [name]
agent-browser cookies set <name> <value> [options]
agent-browser cookies clear
```

---

## Global Options

| Option | 说明 |
|--------|------|
| `--session <name>` | 使用命名会话 |
| `--headed` | 显示浏览器窗口 |
| `--json` | JSON 格式输出 |
| `--timeout <ms>` | 操作超时时间 |
| `--verbose` | 详细日志 |
| `--help` | 显示帮助 |
