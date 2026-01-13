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
