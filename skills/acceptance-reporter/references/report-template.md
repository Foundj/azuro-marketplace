# Report Template

> 验收报告模板 - 用于 generate-html.js 脚本

---

## Template Variables

| 变量 | 说明 | 示例 |
|------|------|------|
| `{{ACCEPTANCE_ID}}` | 验收编号 | ACC-20260227-001 |
| `{{CHANGE_ID}}` | 变更 ID | CHG-v4-pilot-logger |
| `{{PLAN_ID}}` | 计划 ID | magical-inventing-flame |
| `{{TASK_ID}}` | 任务 ID | 1 |
| `{{DATE}}` | 验收日期 | 2026-02-27 |
| `{{TIMESTAMP}}` | 验收时间 | 2026-02-27 14:35:00 |
| `{{STATUS}}` | 验收状态 | PASSED / FAILED |
| `{{STATUS_ICON}}` | 状态图标 | ✅ / ❌ |
| `{{BASE_URL}}` | 基础 URL | http://localhost:3000 |
| `{{BROWSER}}` | 浏览器 | chromium |
| `{{VIEWPORT}}` | 视口大小 | 1280x720 |
| `{{PAGE_COUNT}}` | 页面数量 | 5 |
| `{{SCREENSHOT_COUNT}}` | 截图数量 | 5 |
| `{{VALIDATION_COUNT}}` | 验证项数量 | 23 |
| `{{PASS_RATE}}` | 通过率 | 100 |

---

## Markdown Template

```markdown
# 验收报告

**验收编号**: {{ACCEPTANCE_ID}}
{{#if CHANGE_ID}}**关联变更**: {{CHANGE_ID}}{{/if}}
{{#if PLAN_ID}}**关联计划**: {{PLAN_ID}}{{/if}}
{{#if TASK_ID}}**关联任务**: {{TASK_ID}}{{/if}}
**验收日期**: {{DATE}}
**状态**: {{STATUS_ICON}} {{STATUS}}

---

## 概览

| 指标 | 值 |
|------|-----|
| 验收页面 | {{PAGE_COUNT}} |
| 截图数量 | {{SCREENSHOT_COUNT}} |
| 验证项 | {{VALIDATION_COUNT}} |
| 通过率 | {{PASS_RATE}}% |

---

## 环境信息

| 项目 | 值 |
|------|-----|
| 基础 URL | {{BASE_URL}} |
| 浏览器 | {{BROWSER}} |
| 视口 | {{VIEWPORT}} |

---

## 页面验收详情

{{#each PAGES}}
### {{@index}}. {{name}} ({{url}})

![{{name}}截图](screenshots/{{screenshot}})

**加载时间**: {{loadTime}}s

| 验证项 | 结果 |
|--------|------|
{{#each validations}}
| {{check}} | {{result}} |
{{/each}}

{{#if errors}}
**错误**:
{{#each errors}}
- {{this}}
{{/each}}
{{/if}}

{{/each}}

---

## 问题列表

{{#if ISSUES}}
| 编号 | 页面 | 问题描述 | 严重程度 |
|------|------|----------|----------|
{{#each ISSUES}}
| {{id}} | {{page}} | {{description}} | {{severity}} |
{{/each}}
{{else}}
*无问题发现*
{{/if}}

---

## 验收历史

| 验收编号 | 日期 | 状态 |
|----------|------|------|
{{#each HISTORY}}
| {{id}} | {{date}} | {{status}} |
{{/each}}

---

## 签名

- **验收人**: Claude Code
- **验收时间**: {{TIMESTAMP}}

---

*此报告由 acceptance-reporter 自动生成*
```

---

## HTML Template

```html
<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>验收报告 - {{ACCEPTANCE_ID}}</title>
  <style>
    :root {
      --color-pass: #22863a;
      --color-fail: #cb2431;
      --color-border: #e1e4e8;
      --color-bg: #f6f8fa;
      --color-text: #24292e;
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, sans-serif;
      line-height: 1.6;
      color: var(--color-text);
      background: var(--color-bg);
      padding: 20px;
    }

    .container {
      max-width: 1200px;
      margin: 0 auto;
      background: white;
      border-radius: 8px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.1);
      overflow: hidden;
    }

    .header {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      padding: 30px;
    }

    .header h1 {
      font-size: 24px;
      margin-bottom: 10px;
    }

    .header .meta {
      font-size: 14px;
      opacity: 0.9;
    }

    .status-badge {
      display: inline-block;
      padding: 4px 12px;
      border-radius: 20px;
      font-size: 14px;
      font-weight: 600;
    }

    .status-pass {
      background: var(--color-pass);
      color: white;
    }

    .status-fail {
      background: var(--color-fail);
      color: white;
    }

    .content {
      padding: 30px;
    }

    .summary-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
      gap: 20px;
      margin-bottom: 30px;
    }

    .summary-card {
      text-align: center;
      padding: 20px;
      background: var(--color-bg);
      border-radius: 8px;
    }

    .summary-card .value {
      font-size: 32px;
      font-weight: 700;
      color: #667eea;
    }

    .summary-card .label {
      font-size: 14px;
      color: #586069;
    }

    .page-section {
      border: 1px solid var(--color-border);
      border-radius: 8px;
      margin-bottom: 20px;
      overflow: hidden;
    }

    .page-header {
      background: var(--color-bg);
      padding: 15px 20px;
      border-bottom: 1px solid var(--color-border);
      display: flex;
      justify-content: space-between;
      align-items: center;
    }

    .page-header h3 {
      font-size: 16px;
    }

    .page-body {
      padding: 20px;
    }

    .screenshot {
      max-width: 100%;
      border-radius: 4px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      margin-bottom: 15px;
    }

    table {
      width: 100%;
      border-collapse: collapse;
      font-size: 14px;
    }

    th, td {
      padding: 10px;
      text-align: left;
      border-bottom: 1px solid var(--color-border);
    }

    th {
      background: var(--color-bg);
      font-weight: 600;
    }

    .pass { color: var(--color-pass); }
    .fail { color: var(--color-fail); }

    .footer {
      text-align: center;
      padding: 20px;
      color: #586069;
      font-size: 12px;
      border-top: 1px solid var(--color-border);
    }

    @media print {
      body {
        background: white;
        padding: 0;
      }
      .container {
        box-shadow: none;
      }
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>验收报告</h1>
      <div class="meta">
        <strong>编号</strong>: {{ACCEPTANCE_ID}} |
        <strong>日期</strong>: {{DATE}} |
        <span class="status-badge status-{{STATUS_CLASS}}">{{STATUS_ICON}} {{STATUS}}</span>
      </div>
    </div>

    <div class="content">
      <!-- Summary -->
      <div class="summary-grid">
        <div class="summary-card">
          <div class="value">{{PAGE_COUNT}}</div>
          <div class="label">验收页面</div>
        </div>
        <div class="summary-card">
          <div class="value">{{SCREENSHOT_COUNT}}</div>
          <div class="label">截图数量</div>
        </div>
        <div class="summary-card">
          <div class="value">{{VALIDATION_COUNT}}</div>
          <div class="label">验证项</div>
        </div>
        <div class="summary-card">
          <div class="value">{{PASS_RATE}}%</div>
          <div class="label">通过率</div>
        </div>
      </div>

      <!-- Pages -->
      <h2>页面验收详情</h2>
      {{#each PAGES}}
      <div class="page-section">
        <div class="page-header">
          <h3>{{name}} ({{url}})</h3>
          <span class="status-badge status-{{statusClass}}">{{statusIcon}} {{status}}</span>
        </div>
        <div class="page-body">
          <img class="screenshot" src="{{screenshotBase64}}" alt="{{name}} screenshot">
          <table>
            <thead>
              <tr>
                <th>验证项</th>
                <th>结果</th>
              </tr>
            </thead>
            <tbody>
              {{#each validations}}
              <tr>
                <td>{{check}}</td>
                <td class="{{resultClass}}">{{resultIcon}} {{result}}</td>
              </tr>
              {{/each}}
            </tbody>
          </table>
        </div>
      </div>
      {{/each}}
    </div>

    <div class="footer">
      <p>验收人: Claude Code | 验收时间: {{TIMESTAMP}}</p>
      <p>此报告由 acceptance-reporter 自动生成</p>
    </div>
  </div>
</body>
</html>
```