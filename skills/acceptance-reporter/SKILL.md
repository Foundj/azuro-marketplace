---
name: acceptance-reporter
description: |
  Generate structured acceptance reports with screenshots, validations,
  and task associations. Use after web testing to create evidence reports.
  Triggers on: "acceptance report", "验收报告", "generate report", "报告生成".
version: 5.1.13
status: ga
triggers:
  - acceptance report
  - 验收报告
  - generate report
  - 报告生成
  - evidence report
---

# Acceptance Reporter

> 验收报告生成技能 - 支持双格式报告 (Markdown + HTML)

## Purpose

Acceptance Reporter 用于生成结构化的前端验收报告，包含:

- ✅ 验收概览和状态
- ✅ 页面验证详情
- ✅ 截图证据嵌入
- ✅ 问题列表追踪
- ✅ 历史验收记录
- ✅ 任务/计划/变更关联

---

## Quick Start

```bash
# 从验收状态生成报告
/ai:acceptance http://localhost:3000 --change CHG-xxx --report

# 手动生成报告
node scripts/generate-report.js --state state.json --output report.md
```

---

## Report Structure

### Markdown Report

```markdown
# 验收报告

**验收编号**: ACC-20260227-001
**关联变更**: CHG-v4-pilot-logger
**关联计划**: magical-inventing-flame
**验收日期**: 2026-02-27 14:30
**状态**: ✅ PASSED

## 概览

| 指标 | 值 |
|------|-----|
| 验收页面 | 5 |
| 截图数量 | 5 |
| 验证项 | 23 |
| 通过率 | 100% |

## 页面验收详情

### 1. 首页 (/)

![首页截图](screenshots/page-home-20260227-143022.png)

| 验证项 | 结果 |
|--------|------|
| 页面加载 | ✅ PASS |
| 标题正确 | ✅ PASS |
| 导航可见 | ✅ PASS |

### 2. 登录页 (/login)

![登录截图](screenshots/page-login-20260227-143030.png)

| 验证项 | 结果 |
|--------|------|
| 页面加载 | ✅ PASS |
| 表单可见 | ✅ PASS |
| 提交成功 | ✅ PASS |

## 问题列表

*无问题发现*

## 验收历史

| 验收编号 | 日期 | 状态 |
|----------|------|------|
| ACC-20260227-001 | 2026-02-27 | ✅ PASSED |
| ACC-20260226-002 | 2026-02-26 | ✅ PASSED |
| ACC-20260225-001 | 2026-02-25 | ❌ FAILED |

## 签名

- **验收人**: Claude Code
- **验收时间**: 2026-02-27 14:35:00
```

### HTML Report

HTML 报告特点:

- 📦 **自包含**: 截图嵌入为 base64，离线可用
- 🎨 **美观样式**: 使用内置 CSS 样式
- 📱 **响应式**: 支持桌面和移动查看
- 🔗 **可导航**: 页面锚点跳转

---

## Report Templates

### State File Schema

```json
{
  "acceptanceId": "ACC-20260227-001",
  "changeId": "CHG-v4-pilot-logger",
  "planId": "magical-inventing-flame",
  "taskId": "1",
  "createdAt": "2026-02-27T14:30:00+08:00",
  "status": "passed",
  "environment": {
    "baseUrl": "http://localhost:3000",
    "browser": "chromium",
    "viewport": "1280x720"
  },
  "pages": [
    {
      "name": "home",
      "url": "/",
      "status": "passed",
      "screenshot": "screenshots/page-home-20260227-143022.png",
      "loadTime": 1.2,
      "validations": [
        {"check": "Page loads", "result": "PASS"},
        {"check": "Title correct", "result": "PASS"},
        {"check": "Navigation visible", "result": "PASS"}
      ],
      "errors": []
    }
  ],
  "issues": [],
  "summary": {
    "totalPages": 5,
    "passedPages": 5,
    "failedPages": 0,
    "totalValidations": 23,
    "passedValidations": 23,
    "passRate": 100
  },
  "historyCount": 3,
  "history": [
    {"id": "ACC-20260227-001", "date": "2026-02-27", "status": "passed"},
    {"id": "ACC-20260226-002", "date": "2026-02-26", "status": "passed"},
    {"id": "ACC-20260225-001", "date": "2026-02-25", "status": "failed"}
  ]
}
```

---

## Usage

### With /ai:acceptance

```bash
# 自动在验收完成后生成报告
/ai:acceptance http://localhost:3000 --change CHG-xxx --report
```

### Standalone

```bash
# 从现有状态文件生成报告
node scripts/generate-html.js \
  --state codebox/acceptance/2026-02-27/CHG-xxx/state.json \
  --output codebox/acceptance/2026-02-27/CHG-xxx/report.html
```

---

## Report Generation Flow

```
state.json
    ↓
┌─────────────────────────────┐
│  1. Read State              │
│  - Parse JSON               │
│  - Validate schema          │
└─────────────────────────────┘
    ↓
┌─────────────────────────────┐
│  2. Load Screenshots        │
│  - Read PNG files           │
│  - Convert to base64        │
└─────────────────────────────┘
    ↓
┌─────────────────────────────┐
│  3. Generate Markdown       │
│  - Apply template           │
│  - Insert data              │
└─────────────────────────────┘
    ↓
┌─────────────────────────────┐
│  4. Generate HTML           │
│  - Convert MD to HTML       │
│  - Embed screenshots        │
│  - Apply styles             │
└─────────────────────────────┘
    ↓
report.md + report.html
```

---

## Output Files

| 文件 | 格式 | 用途 |
|------|------|------|
| `report.md` | Markdown | 版本控制、文档集成 |
| `report.html` | HTML | 分享、存档、离线查看 |
| `state.json` | JSON | 数据存储、程序读取 |

---

## Template Customization

### Custom CSS

```css
/* 自定义报告样式 */
.acceptance-report {
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

.page-section {
  border: 1px solid #e1e4e8;
  border-radius: 6px;
  padding: 16px;
  margin-bottom: 20px;
}

.screenshot {
  max-width: 100%;
  border-radius: 6px;
  box-shadow: 0 2px 8px rgba(0,0,0,0.1);
}

.status-pass {
  color: #22863a;
}

.status-fail {
  color: #cb2431;
}
```

### Custom Sections

```markdown
## 性能指标

| 页面 | 加载时间 | 首次渲染 | 可交互时间 |
|------|----------|----------|------------|
| 首页 | 1.2s | 0.8s | 1.5s |
| 登录 | 0.9s | 0.6s | 1.1s |

## 控制台错误

无错误记录
```

---

## Integration

### With ai-dev

```yaml
# Phase 5: Quality Validation
frontend_acceptance:
  steps:
    - name: "Run acceptance tests"
      command: /ai:acceptance --change ${CHANGE_ID} --report

    - name: "Review report"
      action: read_file
      path: codebox/acceptance/${DATE}/${CHANGE_ID}/report.md
```

### With Change Management

```json
// codebox/changes/active/{changeId}/state.json
{
  "acceptance": {
    "latestId": "ACC-20260227-001",
    "latestStatus": "passed",
    "reportPath": "codebox/acceptance/2026-02-27/CHG-xxx/report.md",
    "history": [...]
  }
}
```

---

## Troubleshooting

| 问题 | 解决方案 |
|------|----------|
| 截图未嵌入 HTML | 确保 `screenshots/` 目录存在且 PNG 文件可读 |
| 模板渲染失败 | 检查 `state.json` 格式是否符合 schema |
| 中文乱码 | 确保文件 UTF-8 编码，HTML 添加 `<meta charset="utf-8">` |

---

## Dependencies

- **Node.js** 18+ (for script execution)
- **markdown-it** (Markdown to HTML conversion)

```bash
npm install markdown-it
```

---

## Version History

| Version | Changes |
|---------|---------|
| 1.0.0 | Initial release with Markdown + HTML support |

---

## See Also

- [ai:acceptance](../../commands/ai:acceptance.md) - 验收命令
- [acceptance-patterns.md](../agent-browser/references/acceptance-patterns.md) - 验收模式
- [report-template.md](references/report-template.md) - 报告模板