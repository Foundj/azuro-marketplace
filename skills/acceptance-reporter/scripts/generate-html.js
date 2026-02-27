#!/usr/bin/env node

/**
 * Generate HTML Acceptance Report
 *
 * Usage:
 *   node generate-html.js --state <state.json> --output <report.html>
 *
 * Features:
 *   - Convert Markdown to HTML using markdown-it
 *   - Embed screenshots as base64
 *   - Apply custom styles
 *   - Generate self-contained HTML file
 */

const fs = require('fs');
const path = require('path');

// Parse command line arguments
function parseArgs() {
  const args = process.argv.slice(2);
  const result = {
    state: null,
    output: null,
    template: null
  };

  for (let i = 0; i < args.length; i++) {
    switch (args[i]) {
      case '--state':
        result.state = args[++i];
        break;
      case '--output':
        result.output = args[++i];
        break;
      case '--template':
        result.template = args[++i];
        break;
      case '--help':
        console.log(`
Usage: node generate-html.js [options]

Options:
  --state <file>     Path to state.json file (required)
  --output <file>    Path to output HTML file (required)
  --template <file>  Path to custom HTML template (optional)
  --help             Show this help message

Example:
  node generate-html.js --state state.json --output report.html
        `);
        process.exit(0);
    }
  }

  if (!result.state || !result.output) {
    console.error('Error: --state and --output are required');
    process.exit(1);
  }

  return result;
}

// Read and validate state file
function readState(statePath) {
  try {
    const content = fs.readFileSync(statePath, 'utf-8');
    const state = JSON.parse(content);

    // Validate required fields
    const required = ['acceptanceId', 'status', 'pages'];
    for (const field of required) {
      if (!state[field]) {
        throw new Error(`Missing required field: ${field}`);
      }
    }

    return state;
  } catch (error) {
    console.error(`Error reading state file: ${error.message}`);
    process.exit(1);
  }
}

// Convert screenshot to base64
function screenshotToBase64(screenshotPath, stateDir) {
  const fullPath = path.resolve(stateDir, screenshotPath);

  if (!fs.existsSync(fullPath)) {
    console.warn(`Warning: Screenshot not found: ${fullPath}`);
    return null;
  }

  const buffer = fs.readFileSync(fullPath);
  return `data:image/png;base64,${buffer.toString('base64')}`;
}

// Generate Markdown report
function generateMarkdown(state) {
  const lines = [];

  // Header
  lines.push('# 验收报告');
  lines.push('');
  lines.push(`**验收编号**: ${state.acceptanceId}`);
  if (state.changeId) lines.push(`**关联变更**: ${state.changeId}`);
  if (state.planId) lines.push(`**关联计划**: ${state.planId}`);
  if (state.taskId) lines.push(`**关联任务**: ${state.taskId}`);
  lines.push(`**验收日期**: ${state.createdAt ? state.createdAt.split('T')[0] : new Date().toISOString().split('T')[0]}`);
  lines.push(`**状态**: ${state.status === 'passed' ? '✅ PASSED' : '❌ FAILED'}`);
  lines.push('');

  // Summary
  lines.push('## 概览');
  lines.push('');
  lines.push('| 指标 | 值 |');
  lines.push('|------|-----|');
  lines.push(`| 验收页面 | ${state.pages.length} |`);
  lines.push(`| 截图数量 | ${state.pages.filter(p => p.screenshot).length} |`);

  const totalValidations = state.pages.reduce((sum, p) => sum + (p.validations?.length || 0), 0);
  lines.push(`| 验证项 | ${totalValidations} |`);

  const passedValidations = state.pages.reduce((sum, p) =>
    sum + (p.validations?.filter(v => v.result === 'PASS').length || 0), 0);
  const passRate = totalValidations > 0 ? Math.round((passedValidations / totalValidations) * 100) : 100;
  lines.push(`| 通过率 | ${passRate}% |`);
  lines.push('');

  // Environment
  if (state.environment) {
    lines.push('## 环境信息');
    lines.push('');
    lines.push('| 项目 | 值 |');
    lines.push('|------|-----|');
    if (state.environment.baseUrl) lines.push(`| 基础 URL | ${state.environment.baseUrl} |`);
    if (state.environment.browser) lines.push(`| 浏览器 | ${state.environment.browser} |`);
    if (state.environment.viewport) lines.push(`| 视口 | ${state.environment.viewport} |`);
    lines.push('');
  }

  // Pages
  lines.push('## 页面验收详情');
  lines.push('');

  state.pages.forEach((page, index) => {
    lines.push(`### ${index + 1}. ${page.name} (${page.url})`);
    lines.push('');

    if (page.screenshot) {
      lines.push(`![${page.name}截图](screenshots/${path.basename(page.screenshot)})`);
      lines.push('');
    }

    if (page.validations && page.validations.length > 0) {
      lines.push('| 验证项 | 结果 |');
      lines.push('|--------|------|');
      page.validations.forEach(v => {
        const icon = v.result === 'PASS' ? '✅' : '❌';
        lines.push(`| ${v.check} | ${icon} ${v.result} |`);
      });
      lines.push('');
    }

    if (page.errors && page.errors.length > 0) {
      lines.push('**错误**:');
      page.errors.forEach(err => lines.push(`- ${err}`));
      lines.push('');
    }
  });

  // Issues
  lines.push('## 问题列表');
  lines.push('');

  if (state.issues && state.issues.length > 0) {
    lines.push('| 编号 | 页面 | 问题描述 | 严重程度 |');
    lines.push('|------|------|----------|----------|');
    state.issues.forEach((issue, index) => {
      lines.push(`| ${index + 1} | ${issue.page || '-'} | ${issue.description} | ${issue.severity || '-'} |`);
    });
  } else {
    lines.push('*无问题发现*');
  }
  lines.push('');

  // History
  if (state.history && state.history.length > 0) {
    lines.push('## 验收历史');
    lines.push('');
    lines.push('| 验收编号 | 日期 | 状态 |');
    lines.push('|----------|------|------|');
    state.history.forEach(h => {
      const icon = h.status === 'passed' ? '✅' : '❌';
      lines.push(`| ${h.id} | ${h.date} | ${icon} ${h.status} |`);
    });
    lines.push('');
  }

  // Footer
  lines.push('## 签名');
  lines.push('');
  lines.push('- **验收人**: Claude Code');
  lines.push(`- **验收时间**: ${state.createdAt || new Date().toISOString()}`);
  lines.push('');
  lines.push('*此报告由 acceptance-reporter 自动生成*');

  return lines.join('\n');
}

// Generate HTML report with embedded screenshots
function generateHTML(state, stateDir) {
  // Calculate stats
  const totalPages = state.pages.length;
  const screenshotCount = state.pages.filter(p => p.screenshot).length;
  const totalValidations = state.pages.reduce((sum, p) => sum + (p.validations?.length || 0), 0);
  const passedValidations = state.pages.reduce((sum, p) =>
    sum + (p.validations?.filter(v => v.result === 'PASS').length || 0), 0);
  const passRate = totalValidations > 0 ? Math.round((passedValidations / totalValidations) * 100) : 100;

  const statusClass = state.status === 'passed' ? 'pass' : 'fail';
  const statusIcon = state.status === 'passed' ? '✅' : '❌';

  // Generate page sections
  const pageSections = state.pages.map((page) => {
    const pageStatusClass = page.status === 'passed' ? 'pass' : 'fail';
    const pageStatusIcon = page.status === 'passed' ? '✅' : '❌';

    // Convert screenshot to base64
    let screenshotBase64 = '';
    if (page.screenshot) {
      screenshotBase64 = screenshotToBase64(page.screenshot, stateDir) || '';
    }

    // Generate validation rows
    const validationRows = (page.validations || []).map(v => {
      const resultClass = v.result === 'PASS' ? 'pass' : 'fail';
      const resultIcon = v.result === 'PASS' ? '✅' : '❌';
      return `
              <tr>
                <td>${v.check}</td>
                <td class="${resultClass}">${resultIcon} ${v.result}</td>
              </tr>`;
    }).join('');

    return `
      <div class="page-section">
        <div class="page-header">
          <h3>${page.name} (${page.url})</h3>
          <span class="status-badge status-${pageStatusClass}">${pageStatusIcon} ${page.status}</span>
        </div>
        <div class="page-body">
          ${screenshotBase64 ? `<img class="screenshot" src="${screenshotBase64}" alt="${page.name} screenshot">` : ''}
          <table>
            <thead>
              <tr>
                <th>验证项</th>
                <th>结果</th>
              </tr>
            </thead>
            <tbody>
              ${validationRows}
            </tbody>
          </table>
        </div>
      </div>`;
  }).join('');

  // Full HTML template
  return `<!DOCTYPE html>
<html lang="zh-CN">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>验收报告 - ${state.acceptanceId}</title>
  <style>
    :root {
      --color-pass: #22863a;
      --color-fail: #cb2431;
      --color-border: #e1e4e8;
      --color-bg: #f6f8fa;
      --color-text: #24292e;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
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
    .header h1 { font-size: 24px; margin-bottom: 10px; }
    .header .meta { font-size: 14px; opacity: 0.9; }
    .status-badge {
      display: inline-block;
      padding: 4px 12px;
      border-radius: 20px;
      font-size: 14px;
      font-weight: 600;
    }
    .status-pass { background: var(--color-pass); color: white; }
    .status-fail { background: var(--color-fail); color: white; }
    .content { padding: 30px; }
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
    .summary-card .value { font-size: 32px; font-weight: 700; color: #667eea; }
    .summary-card .label { font-size: 14px; color: #586069; }
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
    .page-header h3 { font-size: 16px; }
    .page-body { padding: 20px; }
    .screenshot {
      max-width: 100%;
      border-radius: 4px;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
      margin-bottom: 15px;
    }
    table { width: 100%; border-collapse: collapse; font-size: 14px; }
    th, td { padding: 10px; text-align: left; border-bottom: 1px solid var(--color-border); }
    th { background: var(--color-bg); font-weight: 600; }
    .pass { color: var(--color-pass); }
    .fail { color: var(--color-fail); }
    .footer {
      text-align: center;
      padding: 20px;
      color: #586069;
      font-size: 12px;
      border-top: 1px solid var(--color-border);
    }
    @media print { body { background: white; padding: 0; } .container { box-shadow: none; } }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>验收报告</h1>
      <div class="meta">
        <strong>编号</strong>: ${state.acceptanceId} |
        <strong>日期</strong>: ${state.createdAt ? state.createdAt.split('T')[0] : new Date().toISOString().split('T')[0]} |
        <span class="status-badge status-${statusClass}">${statusIcon} ${state.status.toUpperCase()}</span>
      </div>
    </div>
    <div class="content">
      <div class="summary-grid">
        <div class="summary-card">
          <div class="value">${totalPages}</div>
          <div class="label">验收页面</div>
        </div>
        <div class="summary-card">
          <div class="value">${screenshotCount}</div>
          <div class="label">截图数量</div>
        </div>
        <div class="summary-card">
          <div class="value">${totalValidations}</div>
          <div class="label">验证项</div>
        </div>
        <div class="summary-card">
          <div class="value">${passRate}%</div>
          <div class="label">通过率</div>
        </div>
      </div>
      <h2>页面验收详情</h2>
      ${pageSections}
    </div>
    <div class="footer">
      <p>验收人: Claude Code | 验收时间: ${state.createdAt || new Date().toISOString()}</p>
      <p>此报告由 acceptance-reporter 自动生成</p>
    </div>
  </div>
</body>
</html>`;
}

// Main
function main() {
  const args = parseArgs();
  const stateDir = path.dirname(args.state);
  const state = readState(args.state);

  // Generate Markdown report
  const mdReport = generateMarkdown(state);
  const mdPath = args.output.replace('.html', '.md');
  fs.writeFileSync(mdPath, mdReport, 'utf-8');
  console.log(`✅ Markdown report: ${mdPath}`);

  // Generate HTML report
  const htmlReport = generateHTML(state, stateDir);
  fs.writeFileSync(args.output, htmlReport, 'utf-8');
  console.log(`✅ HTML report: ${args.output}`);
}

main();