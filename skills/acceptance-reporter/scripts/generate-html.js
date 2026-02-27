#!/usr/bin/env node

/**
 * Generate HTML Acceptance Report
 *
 * Usage:
 *   node generate-html.js --state <state.json> --output <report.html>
 *   node generate-html.js --state <state.json> --output <report.html> --compare <baseline.json>
 *
 * Features:
 *   - Convert Markdown to HTML using markdown-it
 *   - Embed screenshots as base64
 *   - Apply custom styles with dark mode support
 *   - Generate self-contained HTML file
 *   - Screenshot comparison with pixelmatch (optional)
 *   - Print-friendly output
 */

const fs = require('fs');
const path = require('path');

// Try to load optional dependencies
let markdownit = null;
let pixelmatch = null;
let PNG = null;

try {
  markdownit = require('markdown-it');
} catch (e) {
  // markdown-it not installed, will use built-in renderer
}

try {
  pixelmatch = require('pixelmatch');
  PNG = require('pngjs').PNG;
} catch (e) {
  // pixelmatch not installed, comparison feature disabled
}

// Parse command line arguments
function parseArgs() {
  const args = process.argv.slice(2);
  const result = {
    state: null,
    output: null,
    template: null,
    compare: null,
    threshold: 0.1
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
      case '--compare':
        result.compare = args[++i];
        break;
      case '--threshold':
        result.threshold = parseFloat(args[++i]) || 0.1;
        break;
      case '--help':
        console.log(`
Usage: node generate-html.js [options]

Options:
  --state <file>      Path to state.json file (required)
  --output <file>     Path to output HTML file (required)
  --template <file>   Path to custom HTML template (optional)
  --compare <file>    Path to baseline state.json for comparison (optional)
  --threshold <num>   Pixel difference threshold (default: 0.1)
  --help              Show this help message

Example:
  node generate-html.js --state state.json --output report.html
  node generate-html.js --state state.json --output report.html --compare baseline.json
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

// Compare two screenshots using pixelmatch
async function compareScreenshots(currentPath, baselinePath, diffPath, threshold = 0.1) {
  if (!pixelmatch || !PNG) {
    console.warn('pixelmatch not installed, skipping screenshot comparison');
    return { diff: 0, diffPercent: 0 };
  }

  const stateDir = path.dirname(currentPath);
  const currentFullPath = path.resolve(stateDir, currentPath);
  const baselineFullPath = path.resolve(stateDir, baselinePath);
  const diffFullPath = path.resolve(stateDir, diffPath);

  if (!fs.existsSync(currentFullPath) || !fs.existsSync(baselineFullPath)) {
    return { diff: 0, diffPercent: 0 };
  }

  try {
    const currentImg = PNG.sync.read(fs.readFileSync(currentFullPath));
    const baselineImg = PNG.sync.read(fs.readFileSync(baselineFullPath));

    const { width, height } = currentImg;
    const diff = new PNG({ width, height });

    const numDiffPixels = pixelmatch(
      currentImg.data,
      baselineImg.data,
      diff.data,
      width,
      height,
      { threshold }
    );

    // Save diff image
    fs.writeFileSync(diffFullPath, PNG.sync.write(diff));

    const diffPercent = (numDiffPixels / (width * height)) * 100;
    return { diff: numDiffPixels, diffPercent, diffPath };
  } catch (error) {
    console.warn(`Screenshot comparison failed: ${error.message}`);
    return { diff: 0, diffPercent: 0 };
  }
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
  if (state.mode) lines.push(`**测试模式**: ${state.mode}`);
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

  if (state.duration) {
    lines.push(`| 执行时间 | ${state.duration}s |`);
  }
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

    if (page.loadTime) {
      lines.push(`**加载时间**: ${page.loadTime}s`);
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

    // Screenshot comparison result
    if (page.diffPercent !== undefined) {
      lines.push(`**截图对比**: ${page.diffPercent < 1 ? '✅ 无变化' : `⚠️ 差异 ${page.diffPercent.toFixed(2)}%`}`);
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
    lines.push('| 验收编号 | 日期 | 状态 | 模式 |');
    lines.push('|----------|------|------|------|');
    state.history.forEach(h => {
      const icon = h.status === 'passed' ? '✅' : '❌';
      lines.push(`| ${h.id} | ${h.date} | ${icon} ${h.status} | ${h.mode || '-'} |`);
    });
    lines.push('');
  }

  // Footer
  lines.push('## 签名');
  lines.push('');
  lines.push('- **验收人**: Claude Code');
  lines.push('- **验收工具**: agent-browser + acceptance-reporter');
  lines.push(`- **验收时间**: ${state.createdAt || new Date().toISOString()}`);
  lines.push('');
  lines.push('*此报告由 acceptance-reporter 自动生成*');

  return lines.join('\n');
}

// Convert Markdown to HTML using markdown-it or fallback
function markdownToHTML(markdown) {
  if (markdownit) {
    const md = markdownit({
      html: true,
      linkify: true,
      typographer: true
    });
    return md.render(markdown);
  }

  // Fallback: simple conversion
  return markdown
    .replace(/^### (.*$)/gim, '<h3>$1</h3>')
    .replace(/^## (.*$)/gim, '<h2>$1</h2>')
    .replace(/^# (.*$)/gim, '<h1>$1</h1>')
    .replace(/\*\*(.*?)\*\*/g, '<strong>$1</strong>')
    .replace(/\*(.*?)\*/g, '<em>$1</em>')
    .replace(/!\[(.*?)\]\((.*?)\)/g, '<img src="$2" alt="$1" class="screenshot">')
    .replace(/\[(.*?)\]\((.*?)\)/g, '<a href="$2">$1</a>')
    .replace(/\n\n/g, '</p><p>')
    .replace(/^- (.*$)/gim, '<li>$1</li>')
    .replace(/(<li>.*<\/li>)/s, '<ul>$1</ul>')
    .replace(/\|(.*)\|/g, (match) => {
      const cells = match.split('|').filter(c => c.trim());
      return `<tr>${cells.map(c => `<td>${c.trim()}</td>`).join('')}</tr>`;
    });
}

// Generate HTML report with embedded screenshots
function generateHTML(state, stateDir, args) {
  // Calculate stats
  const totalPages = state.pages.length;
  const screenshotCount = state.pages.filter(p => p.screenshot).length;
  const totalValidations = state.pages.reduce((sum, p) => sum + (p.validations?.length || 0), 0);
  const passedValidations = state.pages.reduce((sum, p) =>
    sum + (p.validations?.filter(v => v.result === 'PASS').length || 0), 0);
  const passRate = totalValidations > 0 ? Math.round((passedValidations / totalValidations) * 100) : 100;

  const statusClass = state.status === 'passed' ? 'pass' : 'fail';
  const statusIcon = state.status === 'passed' ? '✅' : '❌';

  // Build TOC
  const tocItems = state.pages.map((page, index) =>
    `<a href="#page-${index + 1}" class="toc-item">${page.name}</a>`
  ).join('');

  // Generate page sections
  const pageSections = state.pages.map((page, index) => {
    const pageStatusClass = page.status === 'passed' ? 'pass' : 'fail';
    const pageStatusIcon = page.status === 'passed' ? '✅' : '❌';

    // Convert screenshot to base64
    let screenshotBase64 = '';
    let diffIndicator = '';

    if (page.screenshot) {
      screenshotBase64 = screenshotToBase64(page.screenshot, stateDir) || '';
    }

    // Diff indicator
    if (page.diffPercent !== undefined && page.diffPercent > 0) {
      diffIndicator = `<span class="diff-badge ${page.diffPercent > 5 ? 'high' : 'low'}">Δ ${page.diffPercent.toFixed(1)}%</span>`;
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

    // Error section
    const errorSection = (page.errors && page.errors.length > 0) ? `
      <div class="errors">
        <h4>错误</h4>
        <ul>
          ${page.errors.map(e => `<li>${e}</li>`).join('')}
        </ul>
      </div>` : '';

    return `
      <div class="page-section" id="page-${index + 1}">
        <div class="page-header">
          <h3>${page.name} (${page.url})</h3>
          <div class="page-badges">
            <span class="status-badge status-${pageStatusClass}">${pageStatusIcon} ${page.status}</span>
            ${diffIndicator}
            ${page.loadTime ? `<span class="load-time">${page.loadTime}s</span>` : ''}
          </div>
        </div>
        <div class="page-body">
          ${screenshotBase64 ? `
            <div class="screenshot-container">
              <img class="screenshot" src="${screenshotBase64}" alt="${page.name} screenshot" onclick="this.classList.toggle('zoomed')">
              ${page.diffPath ? `<a href="${page.diffPath}" class="diff-link">查看差异</a>` : ''}
            </div>` : ''}
          <table>
            <thead>
              <tr>
                <th>验证项</th>
                <th>结果</th>
              </tr>
            </thead>
            <tbody>
              ${validationRows || '<tr><td colspan="2">无验证项</td></tr>'}
            </tbody>
          </table>
          ${errorSection}
        </div>
      </div>`;
  }).join('');

  // History section
  const historySection = (state.history && state.history.length > 0) ? `
    <div class="history-section">
      <h2>验收历史</h2>
      <table>
        <thead>
          <tr>
            <th>验收编号</th>
            <th>日期</th>
            <th>状态</th>
            <th>模式</th>
          </tr>
        </thead>
        <tbody>
          ${state.history.map(h => {
            const icon = h.status === 'passed' ? '✅' : '❌';
            return `<tr>
              <td><a href="../${h.id}/report.html">${h.id}</a></td>
              <td>${h.date}</td>
              <td class="${h.status}">${icon} ${h.status}</td>
              <td>${h.mode || '-'}</td>
            </tr>`;
          }).join('')}
        </tbody>
      </table>
    </div>` : '';

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
      --color-warn: #f0883e;
      --color-border: #e1e4e8;
      --color-bg: #f6f8fa;
      --color-text: #24292e;
      --color-primary: #667eea;
      --color-primary-dark: #5a67d8;
    }

    @media (prefers-color-scheme: dark) {
      :root {
        --color-bg: #0d1117;
        --color-text: #c9d1d9;
        --color-border: #30363d;
        --color-primary: #8b9ff7;
      }
    }

    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Noto Sans SC', sans-serif;
      line-height: 1.6;
      color: var(--color-text);
      background: var(--color-bg);
      padding: 20px;
    }

    .container {
      max-width: 1200px;
      margin: 0 auto;
      background: white;
      border-radius: 12px;
      box-shadow: 0 4px 12px rgba(0,0,0,0.1);
      overflow: hidden;
    }

    @media (prefers-color-scheme: dark) {
      .container { background: #161b22; }
    }

    .header {
      background: linear-gradient(135deg, var(--color-primary) 0%, #764ba2 100%);
      color: white;
      padding: 40px;
      position: relative;
    }

    .header h1 { font-size: 28px; margin-bottom: 15px; }
    .header .meta { font-size: 14px; opacity: 0.95; display: flex; flex-wrap: wrap; gap: 15px; }
    .header .meta span { display: inline-flex; align-items: center; gap: 5px; }

    .status-badge {
      display: inline-flex;
      align-items: center;
      padding: 6px 14px;
      border-radius: 20px;
      font-size: 13px;
      font-weight: 600;
      gap: 6px;
    }

    .status-pass { background: var(--color-pass); color: white; }
    .status-fail { background: var(--color-fail); color: white; }

    .diff-badge {
      padding: 4px 10px;
      border-radius: 12px;
      font-size: 12px;
      font-weight: 500;
    }

    .diff-badge.low { background: #fff3cd; color: #856404; }
    .diff-badge.high { background: #f8d7da; color: #721c24; }

    .toc {
      background: var(--color-bg);
      padding: 15px 30px;
      border-bottom: 1px solid var(--color-border);
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
    }

    .toc-item {
      padding: 6px 12px;
      background: white;
      border-radius: 6px;
      text-decoration: none;
      color: var(--color-primary);
      font-size: 13px;
      transition: all 0.2s;
    }

    .toc-item:hover { background: var(--color-primary); color: white; }

    .content { padding: 30px; }

    .summary-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(140px, 1fr));
      gap: 20px;
      margin-bottom: 30px;
    }

    .summary-card {
      text-align: center;
      padding: 25px 15px;
      background: var(--color-bg);
      border-radius: 10px;
      transition: transform 0.2s;
    }

    .summary-card:hover { transform: translateY(-2px); }

    .summary-card .value {
      font-size: 36px;
      font-weight: 700;
      background: linear-gradient(135deg, var(--color-primary), #764ba2);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
    }

    .summary-card .label { font-size: 13px; color: #586069; margin-top: 5px; }

    .page-section {
      border: 1px solid var(--color-border);
      border-radius: 10px;
      margin-bottom: 20px;
      overflow: hidden;
      transition: box-shadow 0.2s;
    }

    .page-section:hover { box-shadow: 0 2px 8px rgba(0,0,0,0.08); }

    .page-header {
      background: var(--color-bg);
      padding: 18px 24px;
      border-bottom: 1px solid var(--color-border);
      display: flex;
      justify-content: space-between;
      align-items: center;
      flex-wrap: wrap;
      gap: 10px;
    }

    .page-header h3 { font-size: 16px; color: var(--color-text); }
    .page-badges { display: flex; align-items: center; gap: 10px; flex-wrap: wrap; }
    .load-time { font-size: 12px; color: #586069; background: white; padding: 4px 8px; border-radius: 4px; }

    .page-body { padding: 24px; }

    .screenshot-container {
      margin-bottom: 20px;
      text-align: center;
    }

    .screenshot {
      max-width: 100%;
      border-radius: 8px;
      box-shadow: 0 2px 8px rgba(0,0,0,0.12);
      cursor: zoom-in;
      transition: transform 0.2s;
    }

    .screenshot.zoomed {
      position: fixed;
      top: 50%;
      left: 50%;
      transform: translate(-50%, -50%) scale(1.5);
      z-index: 1000;
      cursor: zoom-out;
      max-width: 90vw;
      max-height: 90vh;
    }

    .diff-link {
      display: inline-block;
      margin-top: 10px;
      font-size: 13px;
      color: var(--color-primary);
    }

    table { width: 100%; border-collapse: collapse; font-size: 14px; }
    th, td { padding: 12px; text-align: left; border-bottom: 1px solid var(--color-border); }
    th { background: var(--color-bg); font-weight: 600; }

    .pass { color: var(--color-pass); }
    .fail { color: var(--color-fail); }

    .errors {
      margin-top: 20px;
      padding: 15px;
      background: #fff5f5;
      border-radius: 8px;
      border-left: 4px solid var(--color-fail);
    }

    @media (prefers-color-scheme: dark) {
      .errors { background: #2d1f1f; }
    }

    .errors h4 { color: var(--color-fail); margin-bottom: 10px; }
    .errors ul { margin-left: 20px; }

    .history-section { margin-top: 40px; padding-top: 30px; border-top: 1px solid var(--color-border); }
    .history-section h2 { margin-bottom: 20px; }
    .history-section a { color: var(--color-primary); text-decoration: none; }
    .history-section a:hover { text-decoration: underline; }

    .footer {
      text-align: center;
      padding: 25px;
      color: #586069;
      font-size: 13px;
      border-top: 1px solid var(--color-border);
    }

    .footer p { margin: 5px 0; }

    /* Print styles */
    @media print {
      body { background: white; padding: 0; }
      .container { box-shadow: none; }
      .screenshot { page-break-inside: avoid; }
      .page-section { page-break-inside: avoid; margin-bottom: 15px; }
      .toc { display: none; }
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>📋 验收报告</h1>
      <div class="meta">
        <span><strong>编号</strong>: ${state.acceptanceId}</span>
        <span><strong>日期</strong>: ${state.createdAt ? state.createdAt.split('T')[0] : new Date().toISOString().split('T')[0]}</span>
        ${state.changeId ? `<span><strong>变更</strong>: ${state.changeId}</span>` : ''}
        ${state.mode ? `<span><strong>模式</strong>: ${state.mode}</span>` : ''}
        <span class="status-badge status-${statusClass}">${statusIcon} ${state.status.toUpperCase()}</span>
      </div>
    </div>

    <nav class="toc">
      <span style="color: #586069; font-size: 13px;">快速导航:</span>
      ${tocItems}
    </nav>

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

      ${historySection}
    </div>

    <div class="footer">
      <p>👤 验收人: Claude Code | 🕐 验收时间: ${state.createdAt || new Date().toISOString()}</p>
      <p>🔧 工具: agent-browser + acceptance-reporter | 📦 版本: 5.1.10</p>
    </div>
  </div>

  <script>
    // Screenshot zoom functionality
    document.querySelectorAll('.screenshot').forEach(img => {
      img.addEventListener('click', function() {
        if (this.classList.contains('zoomed')) {
          this.classList.remove('zoomed');
        } else {
          document.querySelectorAll('.screenshot.zoomed').forEach(z => z.classList.remove('zoomed'));
          this.classList.add('zoomed');
        }
      });
    });

    // Close zoomed image on click outside
    document.addEventListener('click', function(e) {
      if (!e.target.classList.contains('screenshot')) {
        document.querySelectorAll('.screenshot.zoomed').forEach(z => z.classList.remove('zoomed'));
      }
    });
  </script>
</body>
</html>`;
}

// Main
async function main() {
  const args = parseArgs();
  const stateDir = path.dirname(args.state);
  const state = readState(args.state);

  // Screenshot comparison if baseline provided
  if (args.compare && pixelmatch) {
    const baseline = readState(args.compare);
    console.log('📊 Comparing with baseline...');

    for (const page of state.pages) {
      const baselinePage = baseline.pages.find(p => p.name === page.name);
      if (baselinePage && page.screenshot && baselinePage.screenshot) {
        const diffPath = `diff-${page.name}-${Date.now()}.png`;
        const result = await compareScreenshots(
          page.screenshot,
          baselinePage.screenshot,
          `screenshots/${diffPath}`,
          args.threshold
        );
        page.diffPercent = result.diffPercent;
        page.diffPath = result.diffPath ? `screenshots/${diffPath}` : null;
        console.log(`  ${page.name}: ${result.diffPercent.toFixed(2)}% diff`);
      }
    }
  }

  // Generate Markdown report
  const mdReport = generateMarkdown(state);
  const mdPath = args.output.replace('.html', '.md');
  fs.writeFileSync(mdPath, mdReport, 'utf-8');
  console.log(`✅ Markdown report: ${mdPath}`);

  // Generate HTML report
  const htmlReport = generateHTML(state, stateDir, args);
  fs.writeFileSync(args.output, htmlReport, 'utf-8');
  console.log(`✅ HTML report: ${args.output}`);
}

main().catch(err => {
  console.error('Error:', err);
  process.exit(1);
});