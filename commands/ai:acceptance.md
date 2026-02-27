---
name: ai:acceptance
description: Frontend acceptance testing - browser validation, screenshot evidence, structured reports with task association
argument-hint: "<url> [--change <id>] [--plan <id>] [--task <id>] [--pages <list>] [--mode <mode>] [--report] [--history] [--parallel] [--team] [--compare <id>]"
allowed-tools: Bash, Read, Write, Grep, Glob
execution-mode: subagent
internal: true
status: ga
---

# /ai:acceptance - 前端验收测试

使用 agent-browser 进行前端验收测试，支持浏览器验证、截图证据管理、结构化报告生成。

---

## Execution Mode

此命令作为 **subagent** 执行，隔离浏览器会话，不占用主会话上下文。

```
/ai:acceptance http://localhost:3000 --change CHG-xxx
    ↓
Launch Task tool with subagent:
  - Create acceptance directory: codebox/acceptance/{date}/{changeId}/
  - Initialize browser session
  - Execute page validation
  - Capture screenshots
  - Generate report
    ↓
Returns Acceptance Report + Screenshots
```

---

## Usage

```bash
# 基础用法 - 自动判断最佳模式
/ai:acceptance <url>                              # 验收首页
/ai:acceptance <url> --change <changeId>          # 关联变更并验收

# 多页面验收 - 自动并行
/ai:acceptance <url> --pages "home,login,dashboard"  # 自动并行验收

# 完整报告
/ai:acceptance <url> --change CHG-xxx --report    # 生成完整报告
```

> **智能模式**: 系统自动选择最佳执行方式：
> - 单页面 → 直接验收
> - 2-3 个页面 → 并行执行
> - 4+ 个页面 → Agent Teams 并行

---

## Options

| 选项 | 说明 |
|------|------|
| `--change <id>` | 关联变更 ID (如 CHG-v4-pilot-logger) |
| `--plan <id>` | 关联计划 ID |
| `--task <id>` | 关联任务 ID |
| `--pages <list>` | 逗号分隔的页面列表 (如 "home,login,dashboard") |
| `--report` | 生成完整验收报告 |
| `--history` | 查看历史验收记录 |
| `--quick` | 快速验收 (仅关键页面) |
| `--headed` | 显示浏览器窗口 |
| `--mode <mode>` | 测试模式: quick (快速)、full (完整)、regression (回归)、smoke (冒烟) |
| `--parallel` | 并行执行多页面验收 (需配合 --pages 使用) |
| `--team` | 使用 Agent Teams 并行测试 (自动为每个页面创建验收队友) |
| `--compare <id>` | 与指定验收 ID 对比，显示差异 |

---

## Test Modes

| 模式 | 说明 | 验证项 |
|------|------|--------|
| `quick` | 快速验收 | 页面加载、标题、无 JS 错误 |
| `full` | 完整验收 | 所有验证项 + 交互测试 + 性能指标 |
| `regression` | 回归验收 | 核心功能验证 + 截图对比 |
| `smoke` | 冒烟测试 | 仅验证关键路径是否通畅 |

---

## Step 1: Parse Arguments & Auto Mode Selection

解析 `$ARGUMENTS`:
- 提取 URL (第一个参数)
- 提取关联 ID: --change, --plan, --task
- 提取页面列表: --pages
- 提取测试模式: --mode
- 检测 flags: --report, --history, --quick, --headed
- 提取对比 ID: --compare

```bash
URL=""           # 目标 URL
CHANGE_ID=""     # 变更 ID
PLAN_ID=""       # 计划 ID
TASK_ID=""       # 任务 ID
PAGES=""         # 页面列表
MODE=""          # 测试模式
COMPARE_ID=""    # 对比验收 ID
FLAG_REPORT=false
FLAG_HISTORY=false
FLAG_QUICK=false
FLAG_HEADED=false

# 解析参数
for arg in $ARGUMENTS; do
  case $arg in
    http*://*) URL="$arg" ;;
    --change=*) CHANGE_ID="${arg#*=}" ;;
    --change) NEXT_IS_CHANGE=true ;;
    --plan=*) PLAN_ID="${arg#*=}" ;;
    --plan) NEXT_IS_PLAN=true ;;
    --task=*) TASK_ID="${arg#*=}" ;;
    --task) NEXT_IS_TASK=true ;;
    --pages=*) PAGES="${arg#*=}" ;;
    --pages) NEXT_IS_PAGES=true ;;
    --mode=*) MODE="${arg#*=}" ;;
    --mode) NEXT_IS_MODE=true ;;
    --compare=*) COMPARE_ID="${arg#*=}" ;;
    --compare) NEXT_IS_COMPARE=true ;;
    --report) FLAG_REPORT=true ;;
    --history) FLAG_HISTORY=true ;;
    --quick) FLAG_QUICK=true ;;
    --headed) FLAG_HEADED=true ;;
  esac
done

# 设置默认测试模式
if [ -z "$MODE" ]; then
  if [ "$FLAG_QUICK" = true ]; then
    MODE="quick"
  else
    MODE="full"
  fi
fi

# 自动选择执行模式
PAGE_COUNT=$(echo "$PAGES" | tr ',' '\n' | wc -l | tr -d ' ')

if [ "$PAGE_COUNT" -ge 4 ]; then
  # 4+ 页面: 使用 Agent Teams 并行
  EXEC_MODE="team"
elif [ "$PAGE_COUNT" -ge 2 ]; then
  # 2-3 页面: 并行执行
  EXEC_MODE="parallel"
else
  # 单页面: 直接验收
  EXEC_MODE="direct"
fi

echo "📊 验收模式: $EXEC_MODE (${PAGE_COUNT} 页面)"
```

---

## Step 2: Setup Acceptance Directory

### Directory Structure

```
codebox/acceptance/
├── index.json                    # 验收索引
├── {YYYY-MM-DD}/                 # 按日期归档
│   └── {changeId}/               # 关联变更
│       ├── state.json            # 验收状态
│       ├── report.md             # Markdown 报告
│       ├── report.html           # HTML 报告 (可选)
│       └── screenshots/          # 截图证据
│           └── {page}-{timestamp}.png
└── templates/
    └── acceptance-report.md      # 报告模板
```

### Initialize Directory

```bash
DATE=$(date +%Y-%m-%d)
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
ACCEPTANCE_DIR="codebox/acceptance"

# 生成验收 ID
ACCEPTANCE_ID="ACC-$(date +%Y%m%d)-$(printf '%03d' $(ls -1 $ACCEPTANCE_DIR/$DATE 2>/dev/null | wc -l | awk '{print $1+1}'))"

# 创建目录
mkdir -p "$ACCEPTANCE_DIR/$DATE/${CHANGE_ID:-default}/screenshots"
mkdir -p "$ACCEPTANCE_DIR/templates"

# 初始化索引文件
if [ ! -f "$ACCEPTANCE_DIR/index.json" ]; then
  echo '{"acceptances": []}' > "$ACCEPTANCE_DIR/index.json"
fi
```

---

## Step 3: Initialize Browser Session

```bash
# 创建独立会话
SESSION_NAME="acceptance-$ACCEPTANCE_ID"

# 浏览器启动选项
BROWSER_OPTS=""
if [ "$FLAG_HEADED" = true ]; then
  BROWSER_OPTS="--headed"
fi

# 打开浏览器
agent-browser open "$URL" --session "$SESSION_NAME" $BROWSER_OPTS
agent-browser wait --load networkidle
```

---

## Step 4: Execute Page Validation

### Page Validation Flow

对于每个要验证的页面:

```bash
# 解析页面列表
if [ -z "$PAGES" ]; then
  # 默认页面: 首页
  PAGES="home"
fi

IFS=',' read -ra PAGE_ARRAY <<< "$PAGES"

for PAGE in "${PAGE_ARRAY[@]}"; do
  # 导航到页面
  case $PAGE in
    home)
      agent-browser open "$URL" --session "$SESSION_NAME"
      ;;
    login)
      agent-browser open "$URL/login" --session "$SESSION_NAME"
      ;;
    dashboard)
      agent-browser open "$URL/dashboard" --session "$SESSION_NAME"
      ;;
    *)
      agent-browser open "$URL/$PAGE" --session "$SESSION_NAME"
      ;;
  esac

  # 等待页面加载
  agent-browser wait --load networkidle

  # 获取页面信息
  PAGE_TITLE=$(agent-browser get title --session "$SESSION_NAME")
  PAGE_URL=$(agent-browser get url --session "$SESSION_NAME")

  # 截图
  SCREENSHOT_NAME="${PAGE}-${TIMESTAMP}.png"
  agent-browser screenshot "$ACCEPTANCE_DIR/$DATE/${CHANGE_ID:-default}/screenshots/$SCREENSHOT_NAME" --session "$SESSION_NAME"

  # 验证关键元素
  agent-browser snapshot -i --session "$SESSION_NAME"

  # 记录验证结果
  echo "Page: $PAGE, Title: $PAGE_TITLE, URL: $PAGE_URL, Screenshot: $SCREENSHOT_NAME"
done
```

### Quick Mode (--quick)

快速验收仅验证关键检查:

```bash
# 快速验证
agent-browser open "$URL" --session "$SESSION_NAME"
agent-browser wait --load networkidle
agent-browser snapshot -i --session "$SESSION_NAME"
agent-browser screenshot "$ACCEPTANCE_DIR/$DATE/${CHANGE_ID:-default}/screenshots/quick-${TIMESTAMP}.png" --session "$SESSION_NAME"
```

---

## Step 5: Generate State File

创建 `state.json`:

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
      "validations": [
        {"check": "Page loads", "result": "PASS"},
        {"check": "Title correct", "result": "PASS"}
      ]
    }
  ],
  "issues": [],
  "historyCount": 3,
  "history": []
}
```

---

## Step 6: Generate Report (--report)

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

...

## 问题列表

*无问题发现*

## 签名

- **验收人**: Claude Code
- **验收时间**: 2026-02-27 14:35:00
```

---

## Step 7: Update Index

更新 `codebox/acceptance/index.json`:

```bash
# 读取现有索引
INDEX=$(cat "$ACCEPTANCE_DIR/index.json")

# 添加新记录
NEW_ENTRY=$(cat <<EOF
{
  "id": "$ACCEPTANCE_ID",
  "date": "$DATE",
  "changeId": "${CHANGE_ID:-}",
  "planId": "${PLAN_ID:-}",
  "status": "passed",
  "pages": $(echo "$PAGES" | tr ',' '\n' | wc -l),
  "screenshots": $(ls -1 "$ACCEPTANCE_DIR/$DATE/${CHANGE_ID:-default}/screenshots/" | wc -l),
  "reportPath": "$ACCEPTANCE_DIR/$DATE/${CHANGE_ID:-default}/report.md"
}
EOF
)

# 更新索引文件
echo "$INDEX" | jq ".acceptances += [$NEW_ENTRY]" > "$ACCEPTANCE_DIR/index.json"
```

---

## Step 8: Link to Change/Plan

### Update Change State

如果指定了 `--change`:

```bash
CHANGE_STATE="codebox/changes/active/$CHANGE_ID/state.json"

if [ -f "$CHANGE_STATE" ]; then
  # 添加验收记录
  jq ".acceptance.latestId = \"$ACCEPTANCE_ID\" | .acceptance.history += [{\"id\": \"$ACCEPTANCE_ID\", \"date\": \"$DATE\", \"status\": \"passed\"}]" "$CHANGE_STATE" > "$CHANGE_STATE.tmp"
  mv "$CHANGE_STATE.tmp" "$CHANGE_STATE"
fi
```

### Update Plan File

如果指定了 `--plan`:

```markdown
## Verification

### Acceptance Testing
- Run `/ai:acceptance http://localhost:3000 --change CHG-xxx`
- Verify all pages load correctly
- Check screenshots in `codebox/acceptance/`

### Acceptance Evidence
- [验收报告](codebox/acceptance/2026-02-27/CHG-xxx/report.md)
```

---

## Step 9: Cleanup and History Management

### History Retention (最近 5 次)

```bash
# 清理旧验收记录
MAX_HISTORY=5

# 获取当前变更的验收历史
HISTORY_COUNT=$(ls -1d "$ACCEPTANCE_DIR"/*/"$CHANGE_ID" 2>/dev/null | wc -l)

if [ "$HISTORY_COUNT" -gt "$MAX_HISTORY" ]; then
  # 删除最旧的验收目录
  OLDEST=$(ls -1dt "$ACCEPTANCE_DIR"/*/"$CHANGE_ID" | tail -1)
  rm -rf "$OLDEST"
  echo "Removed old acceptance: $OLDEST"
fi
```

### Close Browser

```bash
agent-browser close --session "$SESSION_NAME"
```

---

## Step 10: View History (--history)

```bash
if [ "$FLAG_HISTORY" = true ]; then
  # 显示验收历史
  echo "## Acceptance History"

  if [ -n "$CHANGE_ID" ]; then
    # 显示特定变更的历史
    cat "$ACCEPTANCE_DIR/index.json" | jq -r ".acceptances[] | select(.changeId == \"$CHANGE_ID\") | \"- \(.id) (\(.date)): \(.status)\""
  else
    # 显示所有历史
    cat "$ACCEPTANCE_DIR/index.json" | jq -r ".acceptances[] | \"- \(.id) (\(.date)) [\(.changeId)]: \(.status)\""
  fi

  exit 0
fi
```

---

## Examples

### 基础验收

```bash
/ai:acceptance http://localhost:3000
```

### 关联变更并生成报告

```bash
/ai:acceptance http://localhost:3000 --change CHG-v4-pilot-logger --report
```

### 指定页面验收

```bash
/ai:acceptance http://localhost:3000 --pages "home,login,dashboard,settings" --change CHG-xxx
```

### 查看历史

```bash
/ai:acceptance http://localhost:3000 --history
/ai:acceptance http://localhost:3000 --change CHG-xxx --history
```

### 快速验收

```bash
/ai:acceptance http://localhost:3000 --quick --change CHG-xxx
```

### 指定测试模式

```bash
# 完整验收
/ai:acceptance http://localhost:3000 --mode full --report

# 回归测试
/ai:acceptance http://localhost:3000 --mode regression --change CHG-xxx

# 冒烟测试
/ai:acceptance http://localhost:3000 --mode smoke
```

### 并行验收多页面

```bash
# 并行验收多个页面
/ai:acceptance http://localhost:3000 --pages "home,login,dashboard,settings" --parallel --report
```

### 使用 Agent Teams 并行验收

```bash
# 使用 Agent Teams 为每个页面创建独立的验收队友
/ai:acceptance http://localhost:3000 --pages "home,login,dashboard" --team --change CHG-xxx --report
```

### 验收对比

```bash
# 与上次验收对比
/ai:acceptance http://localhost:3000 --compare ACC-20260226-001 --change CHG-xxx
```

---

## Team Mode (--team)

当使用 `--team` 参数时，系统将：

1. **创建验收团队**: 使用 TeamCreate 创建临时验收团队
2. **分配验收队友**: 为每个页面创建独立的 acceptance-tester 队友
3. **并行执行**: 所有页面同时验收，提高效率
4. **汇总结果**: 收集所有队友的验收结果，生成统一报告
5. **清理团队**: 验收完成后自动关闭团队

### Team Mode 工作流

```
/ai:acceptance --team --pages "home,login,dashboard"
    │
    ├── TeamCreate("acceptance-{changeId}")
    │
    ├── Task: tester-home     → 验收首页 (/)
    │     • agent-browser open /
    │     • 截图 + 验证
    │     • SendMessage 结果
    │
    ├── Task: tester-login    → 验收登录页 (/login)
    │     • agent-browser open /login
    │     • 截图 + 验证
    │     • SendMessage 结果
    │
    └── Task: tester-dashboard → 验收仪表盘 (/dashboard)
          • agent-browser open /dashboard
          • 截图 + 验证
          • SendMessage 结果
    │
    ▼
汇总结果 → 生成报告 → TeamDelete
```

---

## Compare Mode (--compare)

当使用 `--compare` 参数时，系统将：

1. **读取历史验收**: 加载指定的历史验收状态
2. **对比截图**: 对比同一页面的截图差异
3. **对比验证项**: 显示验证项的变化
4. **生成对比报告**: 包含变化摘要

### 对比输出示例

```
## 验收对比报告

**当前验收**: ACC-20260227-001
**对比基准**: ACC-20260226-001

### 变化摘要

| 页面 | 截图变化 | 验证项变化 |
|------|----------|------------|
| home | ✅ 无变化 | +2 通过 |
| login | ⚠️ 有变化 | -1 通过 |
| dashboard | ❌ 新增 | N/A |

### 详情

**login 页面截图变化**:
- 表单按钮位置变化
- 输入框样式调整
```

---

## Integration

此命令集成到 ai-dev 工作流:

- **Phase 5 Quality**: 前端验收测试
- **Phase 6 Finalization**: 验收证据归档
- **ai:archive**: 验收历史记录

---

## Output

### Success

```
✅ Acceptance completed: ACC-20260227-001
   - Pages validated: 5
   - Screenshots: 5
   - Report: codebox/acceptance/2026-02-27/CHG-xxx/report.md
```

### Failure

```
❌ Acceptance failed: ACC-20260227-001
   - Issues found: 2
   - Report: codebox/acceptance/2026-02-27/CHG-xxx/report.md
```

---

## Prerequisites

确保已安装 agent-browser:

```bash
npm install -g agent-browser
agent-browser install  # 下载浏览器
```

---

## Related

- [agent-browser skill](skills/agent-browser/SKILL.md) - 浏览器自动化
- [acceptance-reporter skill](skills/acceptance-reporter/SKILL.md) - 报告生成
- [verification-workflow](skills/ai-dev/references/verification-workflow.md) - 验证流程