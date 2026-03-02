# Agent Browser Workflow Templates

> 常见测试场景的工作流模板

## 1. Login Flow Testing

```bash
# 标准登录测试
agent-browser open https://app.example.com/login
agent-browser snapshot -i

# 填写登录表单
agent-browser fill @e1 "testuser@example.com"
agent-browser fill @e2 "SecurePassword123"
agent-browser click @e3

# 验证登录成功
agent-browser wait --text "Dashboard"
agent-browser screenshot login-success.png
agent-browser get url  # 应该跳转到 dashboard

# 保存登录状态供后续测试使用
agent-browser state save auth-state.json
```

## 2. Form Submission Testing

```bash
agent-browser open https://app.example.com/form
agent-browser snapshot -i

# 填写各类表单字段
agent-browser fill @name "John Doe"
agent-browser fill @email "john@example.com"
agent-browser fill @phone "+1-555-123-4567"
agent-browser select @country "United States"
agent-browser check @terms
agent-browser fill @comments "Test submission"

# 提交并验证
agent-browser click @submit
agent-browser wait --text "Thank you"
agent-browser screenshot form-submitted.png
```

## 3. Navigation Testing

```bash
agent-browser open https://example.com
agent-browser snapshot -i

# 测试导航链接
agent-browser click @nav-about
agent-browser wait --load networkidle
agent-browser get title  # 验证页面标题

# 测试后退/前进
agent-browser back
agent-browser get url  # 应该回到首页
agent-browser forward
agent-browser get url  # 应该回到 about 页面

# 测试外部链接
agent-browser click @external-link
agent-browser get url  # 验证跳转目标
```

## 4. Search Functionality Testing

```bash
agent-browser open https://example.com
agent-browser snapshot -i

# 执行搜索
agent-browser fill @search "test query"
agent-browser press Enter

# 或点击搜索按钮
agent-browser click @search-btn

# 验证搜索结果
agent-browser wait --text "results"
agent-browser snapshot -i
agent-browser screenshot search-results.png
```

## 5. E-commerce Checkout Flow

```bash
# 加载已登录状态
agent-browser state load auth-state.json

# 添加商品到购物车
agent-browser open https://shop.example.com/product/123
agent-browser snapshot -i
agent-browser click @add-to-cart
agent-browser wait --text "Added to cart"

# 进入购物车
agent-browser click @cart-icon
agent-browser wait --load networkidle
agent-browser snapshot -i

# 开始结账
agent-browser click @checkout-btn
agent-browser wait --load networkidle
agent-browser snapshot -i

# 填写支付信息
agent-browser fill @card-number "4111111111111111"
agent-browser fill @expiry "12/25"
agent-browser fill @cvv "123"
agent-browser click @place-order

# 验证订单确认
agent-browser wait --text "Order Confirmed"
agent-browser screenshot order-confirmation.png
```

## 6. Multi-tab Testing

```bash
# 使用不同 session 模拟多用户
agent-browser open https://app.example.com --session user1
agent-browser open https://app.example.com --session user2

# 用户 1 登录
agent-browser state load user1-auth.json --session user1
agent-browser open https://app.example.com/chat --session user1

# 用户 2 登录
agent-browser state load user2-auth.json --session user2
agent-browser open https://app.example.com/chat --session user2

# 用户 1 发送消息
agent-browser fill @message "Hello from User 1" --session user1
agent-browser click @send --session user1

# 用户 2 验证收到消息
agent-browser wait --text "Hello from User 1" --session user2
agent-browser screenshot chat-received.png --session user2
```

## 7. Error Handling Testing

```bash
agent-browser open https://app.example.com/login
agent-browser snapshot -i

# 测试空字段验证
agent-browser click @submit
agent-browser wait --text "required"
agent-browser screenshot validation-error.png

# 测试无效邮箱
agent-browser fill @email "invalid-email"
agent-browser fill @password "password123"
agent-browser click @submit
agent-browser wait --text "valid email"
agent-browser screenshot email-error.png

# 测试错误密码
agent-browser fill @email "user@example.com"
agent-browser fill @password "wrongpassword"
agent-browser click @submit
agent-browser wait --text "Invalid credentials"
agent-browser screenshot login-failed.png
```

## 8. Responsive Testing

```bash
# 桌面视图
agent-browser set viewport 1920 1080
agent-browser open https://example.com
agent-browser screenshot desktop.png

# 平板视图
agent-browser set viewport 768 1024
agent-browser reload
agent-browser screenshot tablet.png

# 移动视图
agent-browser set viewport 375 667
agent-browser reload
agent-browser screenshot mobile.png

# 验证移动端菜单
agent-browser snapshot -i
agent-browser click @hamburger-menu
agent-browser wait @mobile-nav
agent-browser screenshot mobile-menu.png
```

## 9. API Integration Testing

```bash
# 监控网络请求
agent-browser network log --filter "api/*" &

# 执行操作
agent-browser open https://app.example.com/dashboard
agent-browser state load auth-state.json
agent-browser click @refresh-data

# 验证 API 调用
agent-browser wait --load networkidle
# 检查网络日志确认 API 被正确调用
```

## 10. Accessibility Testing

```bash
agent-browser open https://example.com
agent-browser snapshot -i

# 使用语义定位器验证可访问性
agent-browser find role button click          # 验证按钮有正确角色
agent-browser find role navigation click      # 验证导航区域
agent-browser find role main click            # 验证主内容区域
agent-browser find label "Email" fill "test"  # 验证表单标签

# 键盘导航测试
agent-browser press Tab
agent-browser press Tab
agent-browser press Enter  # 验证键盘可访问
```

---

## Integration with ai-dev Workflow

### Phase 5: Quality Validation E2E Test

```yaml
# 在 ai-dev Phase 5 中使用
e2e_test:
  before:
    - agent-browser state load auth-state.json

  steps:
    - name: "验证首页加载"
      commands:
        - agent-browser open ${APP_URL}
        - agent-browser wait --load networkidle
        - agent-browser screenshot home.png

    - name: "验证核心功能"
      commands:
        - agent-browser snapshot -i
        - agent-browser click @main-feature
        - agent-browser wait --text "Expected Result"

    - name: "验证错误处理"
      commands:
        - agent-browser open ${APP_URL}/invalid
        - agent-browser wait --text "404"

  after:
    - agent-browser screenshot final-state.png
```

### Parallel E2E Testing

```bash
# 并行运行多个测试场景
agent-browser open https://app.com/login --session login-test &
agent-browser open https://app.com/signup --session signup-test &
agent-browser open https://app.com/forgot --session forgot-test &

wait  # 等待所有 session 完成导航

# 分别执行测试
agent-browser fill @email "test@example.com" --session login-test
agent-browser fill @email "new@example.com" --session signup-test
agent-browser fill @email "forgot@example.com" --session forgot-test
```

---

## 11. Acceptance Testing Workflow

> 用于 `/ai:acceptance` 命令的标准化验收工作流

### Step 1: Initialize Session

```bash
# 生成验收 ID
ACCEPTANCE_ID="ACC-$(date +%Y%m%d)-001"
SESSION_NAME="acceptance-$ACCEPTANCE_ID"

# 创建验收目录
mkdir -p ".agent/acceptance/$(date +%Y-%m-%d)/{changeId}/screenshots"

# 打开浏览器
agent-browser open "$BASE_URL" --session "$SESSION_NAME"
```

### Step 2: Page Tour

对于每个要验收的页面:

```bash
# 定义页面列表
PAGES=("home" "login" "dashboard" "settings")

for PAGE in "${PAGES[@]}"; do
  # 导航到页面
  case $PAGE in
    home) URL="/" ;;
    login) URL="/login" ;;
    dashboard) URL="/dashboard" ;;
    settings) URL="/settings" ;;
    *) URL="/$PAGE" ;;
  esac

  agent-browser open "$BASE_URL$URL" --session "$SESSION_NAME"

  # 等待页面加载完成
  agent-browser wait --load networkidle

  # 获取页面信息
  PAGE_TITLE=$(agent-browser get title --session "$SESSION_NAME")
  PAGE_URL=$(agent-browser get url --session "$SESSION_NAME")

  # 截图 (带时间戳命名)
  TIMESTAMP=$(date +%Y%m%d-%H%M%S)
  SCREENSHOT_NAME="${PAGE}-${TIMESTAMP}.png"
  agent-browser screenshot ".agent/acceptance/$(date +%Y-%m-%d)/{changeId}/screenshots/$SCREENSHOT_NAME" --session "$SESSION_NAME"

  # 验证关键元素
  agent-browser snapshot -i --session "$SESSION_NAME"

  # 记录验证结果
  echo "✅ Page: $PAGE | Title: $PAGE_TITLE | Screenshot: $SCREENSHOT_NAME"
done
```

### Step 3: Evidence Collection

```bash
# 收集验收证据
ACCEPTANCE_DIR=".agent/acceptance/$(date +%Y-%m-%d)/{changeId}"

# 创建状态文件
cat > "$ACCEPTANCE_DIR/state.json" <<EOF
{
  "acceptanceId": "$ACCEPTANCE_ID",
  "changeId": "{changeId}",
  "createdAt": "$(date -Iseconds)",
  "status": "passed",
  "pages": [],
  "screenshots": $(ls -1 "$ACCEPTANCE_DIR/screenshots/" | jq -R -s -c 'split("\n")[:-1]')
}
EOF

# 计算截图数量
SCREENSHOT_COUNT=$(ls -1 "$ACCEPTANCE_DIR/screenshots/"*.png 2>/dev/null | wc -l)
echo "📸 Screenshots captured: $SCREENSHOT_COUNT"
```

### Step 4: Generate Report

```bash
# 使用 acceptance-reporter 生成报告
# 参考: skills/acceptance-reporter/SKILL.md

REPORT_PATH="$ACCEPTANCE_DIR/report.md"

# 生成 Markdown 报告
cat > "$REPORT_PATH" <<EOF
# 验收报告

**验收编号**: $ACCEPTANCE_ID
**验收日期**: $(date +%Y-%m-%d)
**状态**: ✅ PASSED

## 概览

| 指标 | 值 |
|------|-----|
| 验收页面 | ${#PAGES[@]} |
| 截图数量 | $SCREENSHOT_COUNT |
| 验收模式 | Full |

## 截图证据

$(for f in "$ACCEPTANCE_DIR/screenshots/"*.png; do
  name=$(basename "$f")
  echo "### ${name%.png}"
  echo ""
  echo "![${name%.png}](screenshots/$name)"
  echo ""
done)

## 签名

- **验收人**: Claude Code
- **验收时间**: $(date)
EOF

echo "📋 Report generated: $REPORT_PATH"
```

### Step 5: Cleanup

```bash
# 关闭浏览器会话
agent-browser close --session "$SESSION_NAME"

# 清理旧验收记录 (保留最近 5 次)
MAX_HISTORY=5
HISTORY_COUNT=$(ls -1d ".agent/acceptance"/*/* 2>/dev/null | wc -l)

if [ "$HISTORY_COUNT" -gt "$MAX_HISTORY" ]; then
  OLDEST=$(ls -1dt ".agent/acceptance"/*/* | tail -1)
  rm -rf "$OLDEST"
  echo "🗑️ Removed old acceptance: $OLDEST"
fi

echo "✅ Acceptance completed: $ACCEPTANCE_ID"
```

---

### Quick Acceptance Mode

快速验收模式，仅验证关键检查:

```bash
# 快速验收流程
ACCEPTANCE_ID="ACC-$(date +%Y%m%d)-quick"
SESSION_NAME="acceptance-$ACCEPTANCE_ID"

# 1. 打开页面
agent-browser open "$BASE_URL" --session "$SESSION_NAME"
agent-browser wait --load networkidle

# 2. 快速验证
agent-browser snapshot -i --session "$SESSION_NAME"
agent-browser screenshot ".agent/acceptance/$(date +%Y-%m-%d)/{changeId}/screenshots/quick-$(date +%Y%m%d-%H%M%S).png" --session "$SESSION_NAME"

# 3. 关闭
agent-browser close --session "$SESSION_NAME"

echo "✅ Quick acceptance completed"
```

---

### Acceptance with Login

需要登录状态的验收:

```bash
# 加载认证状态
agent-browser state load auth-state.json --session "$SESSION_NAME"

# 或执行登录流程
agent-browser open "$BASE_URL/login" --session "$SESSION_NAME"
agent-browser snapshot -i --session "$SESSION_NAME"
agent-browser fill @e1 "user@example.com" --session "$SESSION_NAME"
agent-browser fill @e2 "password" --session "$SESSION_NAME"
agent-browser click @e3 --session "$SESSION_NAME"
agent-browser wait --text "Dashboard" --session "$SESSION_NAME"

# 保存登录状态供后续使用
agent-browser state save ".agent/acceptance/auth-state.json" --session "$SESSION_NAME"

# 继续验收流程...
```
