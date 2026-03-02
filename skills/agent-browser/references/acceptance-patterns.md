# Acceptance Testing Patterns

> 前端验收测试模式定义 - 用于 `/ai:acceptance` 命令

---

## Overview

验收测试模式定义了不同场景下的前端验证策略:

| 模式 | 页面覆盖 | 验证深度 | 适用场景 |
|------|----------|----------|----------|
| Full | 全部页面 | 完整验证 | 版本发布、重大变更 |
| Quick | 关键页面 | 基础验证 | 快速验证、CI/CD |
| Regression | 变更影响页面 | 定向验证 | Bug 修复、小功能 |
| Smoke | 核心功能页面 | 烟雾测试 | 部署验证、健康检查 |

---

## 1. Full Acceptance (完整验收)

### 适用场景

- 版本发布前验证
- 重大功能变更
- 用户验收测试 (UAT)

### 验证范围

```
✅ 所有公开页面
✅ 所有认证页面 (需登录状态)
✅ 所有表单提交
✅ 所有导航路径
✅ 所有错误处理
✅ 响应式布局 (桌面/平板/移动)
```

### 工作流

```yaml
full_acceptance:
  setup:
    - create_acceptance_directory
    - initialize_browser_session

  pages:
    public:
      - home
      - about
      - contact
      - login
      - signup
      - forgot-password

    authenticated:
      - dashboard
      - profile
      - settings
      - logout

  validations:
    - page_loads
    - elements_visible
    - forms_functional
    - navigation_works
    - errors_handled

  evidence:
    - screenshots_all_pages
    - validation_results
    - performance_metrics

  output:
    - state.json
    - report.md
    - report.html
```

### 执行命令

```bash
/ai:acceptance http://localhost:3000 \
  --change CHG-xxx \
  --pages "home,about,contact,login,signup,dashboard,profile,settings" \
  --report
```

---

## 2. Quick Acceptance (快速验收)

### 适用场景

- CI/CD 流水线验证
- 快速功能检查
- 开发过程中的增量验证

### 验证范围

```
✅ 首页加载
✅ 关键功能入口
✅ 核心用户流程
❌ 完整表单测试
❌ 响应式测试
```

### 工作流

```yaml
quick_acceptance:
  setup:
    - create_acceptance_directory
    - initialize_browser_session

  pages:
    - home
    - login

  validations:
    - page_loads
    - key_elements_visible

  evidence:
    - screenshots_key_pages

  output:
    - state.json
    - brief_report.md
```

### 执行命令

```bash
/ai:acceptance http://localhost:3000 --change CHG-xxx --quick
```

---

## 3. Regression Acceptance (回归验收)

### 适用场景

- Bug 修复后验证
- 小功能迭代
- 变更影响范围明确

### 验证范围

```
✅ 变更直接影响的功能
✅ 变更间接影响的功能
✅ 上下游关联功能
❌ 未受影响的页面
```

### 工作流

```yaml
regression_acceptance:
  setup:
    - analyze_change_impact
    - identify_affected_pages

  pages: dynamic  # 基于变更分析确定

  validations:
    - affected_functionality
    - related_functionality
    - no_new_regressions

  evidence:
    - before_after_comparison
    - regression_test_results

  output:
    - state.json
    - regression_report.md
```

### 影响分析

```bash
# 基于变更文件确定验收页面
CHANGED_FILES=$(git diff --name-only HEAD~1)

# 示例映射规则
# src/pages/login/* → login, forgot-password
# src/pages/dashboard/* → dashboard
# src/components/Header/* → all pages (header on every page)
# src/api/auth/* → login, logout, profile

case $CHANGED_FILES in
  *login*) PAGES="login,forgot-password,dashboard" ;;
  *dashboard*) PAGES="dashboard,profile" ;;
  *Header*) PAGES="home,login,dashboard,profile,settings" ;;
  *) PAGES="home" ;;
esac
```

### 执行命令

```bash
/ai:acceptance http://localhost:3000 --change CHG-xxx --pages "login,dashboard"
```

---

## 4. Smoke Acceptance (烟雾验收)

### 适用场景

- 部署后健康检查
- 生产环境监控
- 快速失败检测

### 验证范围

```
✅ 服务可访问
✅ 首页渲染
✅ 登录功能
✅ API 响应
❌ 详细功能验证
```

### 工作流

```yaml
smoke_acceptance:
  setup:
    - minimal_session

  pages:
    - home
    - health_endpoint

  validations:
    - server_responds
    - page_renders
    - no_critical_errors

  evidence:
    - minimal_screenshot

  output:
    - pass/fail_status
    - error_log_if_failed
```

### 执行命令

```bash
/ai:acceptance https://production.example.com --quick
```

---

## Validation Checklist

### Page Load Validation

| 检查项 | 说明 | 自动化 |
|--------|------|--------|
| HTTP Status | 返回 200 | ✅ |
| Page Title | 标题正确 | ✅ |
| Load Time | < 3s | ✅ |
| No JS Errors | 控制台无错误 | ✅ |
| Content Visible | 主要内容可见 | ✅ |

### Element Validation

| 检查项 | 说明 | 自动化 |
|--------|------|--------|
| Header | 页头存在 | ✅ |
| Footer | 页脚存在 | ✅ |
| Navigation | 导航可点击 | ✅ |
| Forms | 表单可提交 | ✅ |
| Links | 链接有效 | ✅ |

### Form Validation

| 检查项 | 说明 | 自动化 |
|--------|------|--------|
| Required Fields | 必填验证 | ✅ |
| Format Validation | 格式验证 | ✅ |
| Submit Success | 提交成功 | ✅ |
| Error Handling | 错误提示 | ✅ |

---

## Evidence Naming Convention

### Screenshot Naming

```
{page-name}-{YYYYMMDD}-{HHMMSS}.png

Examples:
- home-20260227-143022.png
- login-20260227-143035.png
- dashboard-20260227-143048.png
```

### State File Structure

```json
{
  "acceptanceId": "ACC-20260227-001",
  "changeId": "CHG-xxx",
  "status": "passed",
  "pages": [
    {
      "name": "home",
      "url": "/",
      "status": "passed",
      "screenshot": "screenshots/home-20260227-143022.png",
      "validations": [
        {"check": "Page loads", "result": "PASS"},
        {"check": "Title correct", "result": "PASS"}
      ],
      "loadTime": 1.2,
      "errors": []
    }
  ]
}
```

---

## Integration Points

### With ai-dev Workflow

```yaml
# Phase 5: Quality Validation
frontend_acceptance:
  trigger: phase_5_complete
  command: /ai:acceptance
  options:
    - --change ${CHANGE_ID}
    - --pages ${AFFECTED_PAGES}
    - --report

# Phase 6: Finalization
acceptance_archive:
  trigger: phase_6_start
  action: move_to_archived
```

### With Agent Teams

```yaml
# 自动并行验收 (4+ 页面自动触发)
/ai:acceptance http://localhost:3000 --pages "home,login,dashboard,settings,profile"
# 系统自动:
# 1. 检测页面数量 >= 4
# 2. 创建验收团队
# 3. 为每个页面分配 acceptance-tester 队友
# 4. 并行验收并汇总结果

# 功能开发后自动验收
/ai:team feature 实现用户登录功能
# 完成后自动触发前端验收
```

### With CI/CD

```yaml
# GitHub Actions Example
acceptance_test:
  runs-on: ubuntu-latest
  steps:
    - name: Start App
      run: npm start &

    - name: Run Acceptance
      run: |
        claude /ai:acceptance http://localhost:3000 \
          --change ${{ github.sha }} \
          --quick

    - name: Upload Evidence
      uses: actions/upload-artifact@v3
      with:
        path: .agent/acceptance/
```

---

## Best Practices

### 1. Session Isolation

```bash
# 每次验收使用独立会话
SESSION="acceptance-$(date +%s)"
agent-browser open "$URL" --session "$SESSION"
# ... 验收操作 ...
agent-browser close --session "$SESSION"
```

### 2. Wait Strategies

```bash
# 等待策略选择
agent-browser wait --load networkidle  # 等待网络空闲
agent-browser wait --selector "#content"  # 等待特定元素
agent-browser wait --text "Welcome"  # 等待文本出现
```

### 3. Error Handling

```bash
# 验收失败处理
if ! agent-browser wait --selector "#main" --timeout 10000; then
  echo "❌ Page failed to load"
  agent-browser screenshot "error-$(date +%Y%m%d-%H%M%S).png"
  # 记录错误但继续验收其他页面
fi
```

### 4. History Management

```bash
# 保留最近 5 次验收历史
MAX_HISTORY=5
# 清理逻辑在验收完成后执行
```

---

## Related

- [workflows.md](workflows.md) - 工作流模板
- [commands.md](commands.md) - 命令参考
- [ai:acceptance](../../commands/ai:acceptance.md) - 验收命令
- [ai:team:acceptance](../../commands/ai:team/acceptance.md) - 团队验收命令
- [acceptance-tester](../../agents/acceptance-tester.md) - 验收测试 Agent
- [acceptance-reporter](../acceptance-reporter/SKILL.md) - 报告生成
- [acceptance-team](../acceptance-team/SKILL.md) - 验收团队技能