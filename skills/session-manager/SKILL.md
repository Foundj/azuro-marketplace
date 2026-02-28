---
name: session-manager
description: |
  This skill should be used when the user wants to manage development sessions and restore
  project context across multiple Claude sessions. It automatically recovers progress,
  validates state, and suggests next steps. Use when the user mentions "continue", "resume",
  "status", "progress", "恢复会话", "继续", "进度", or when starting a new session.
  Critical for long-running project continuity.
version: 5.2.3
status: ga
allowed-tools: Read, Bash, Grep, Glob
model: sonnet
triggers:
  - continue
  - resume
  - restore
  - status
  - progress
  - where was I
  - what's next
  - 恢复会话
  - 继续
  - 进度
  - 上次做到哪了
---

# Session Manager - 会话管理系统

## 🎯 一句话说明

**智能恢复项目上下文，确保跨 session 的连续性，就像从未中断过。**

## ⚡ 快速使用

### 简短触发词 ⭐ 推荐
```bash
"continue"         # 最简单，恢复并继续
"resume"           # 同 continue
"status"           # 查看状态（自然语言）
"progress"         # 查看进度
"what's next"      # 推荐下一步
```

### 自然语言触发
```bash
"恢复项目继续工作"
"项目进度如何？"
"上次做到哪了？"
"下一步做什么？"
```

## 🧠 核心功能

### 1. 7步智能启动序列

```
Step 1: 确认位置 (pwd)
Step 2: 读取进度 (progress.txt 最近 50 行)
Step 3: 读取特性 (feature_list.json)
Step 4: 检查 Git (git log, git status)
Step 5: 启动环境 (./init.sh)
Step 6: 运行测试 (smoke tests)
Step 7: 分析推荐 (下一个特性)
```

### 2. 智能状态分析
- **完成率计算**：42/150 (28%)
- **当前特性识别**：Feature #43
- **下一步推荐**：基于依赖和优先级
- **剩余时间估算**：约 15 天

### 3. 环境验证
- ✅ 启动 init.sh
- ✅ 运行 smoke 测试
- ✅ 检查依赖完整性
- ✅ 验证 Git 状态

### 4. 自动归档管理
当文件过大时自动归档：
- `progress.txt > 2000 行` → 归档
- `feature_list.json > 500 特性` → 提醒拆分

## 📋 使用示例

### 示例1：新 Session 开始
```
你: "continue"

Session Manager 执行：
✓ Step 1: 确认位置: /path/to/my-app
✓ Step 2: 读取最近进度
✓ Step 3: 加载特性列表 (150 features)
✓ Step 4: Git 状态: Clean ✅
✓ Step 5: 启动环境: ✅
✓ Step 6: 测试: 45/45 passing ✅
✓ Step 7: 分析完成

📊 Session Recovery Report
==================
Total: 150 features
Completed: 42 (28%)
Current: Feature #43 "用户可以上传头像"
Remaining: 108 (est. 15 days)

🎯 Recommended Next
Feature #43: "用户可以上传头像"
- Priority: high
- Dependencies: ✅ All satisfied
- Estimated Time: 45min
- Steps:
  1. Configure multer middleware
  2. Create upload API endpoint
  3. Build upload UI component
  4. Test end-to-end

准备好继续了！输入 "ai 实现头像上传" 开始
```

### 示例2：检查进度
```
你: "status"

Session Manager 报告：
📊 Project: my-app
Total Features: 150
Completed: 42 (28%)
In Progress: Feature #43

📈 Recent Progress:
- Feature #40: ✅ "用户资料编辑"
- Feature #41: ✅ "密码修改"
- Feature #42: ✅ "邮箱验证"

📁 File Health:
- progress.txt: 856 lines ✅
- feature_list.json: 150 features ✅

🔄 Git:
- Branch: main
- Last Commit: "feat: #42 implement email verification"
- Status: Clean ✅

🎯 Next: Feature #43 "用户可以上传头像"
```

### 示例3：长时间中断后恢复
```
你: "上次做到哪了？"

Session Manager 分析：
⏰ Last Session: 7 days ago
📅 Last Activity: 2025-12-24 18:30

恢复信息：
✅ 上次完成: Feature #42 "邮箱验证"
✅ Git: 已提交并push
✅ 测试: 全部通过
⚠️  注意: 7天未活动，建议：
  1. 运行 git pull 检查远程更新
  2. 运行完整测试验证
  3. 检查依赖更新

推荐: 继续 Feature #43 "用户可以上传头像"
```

## 🔄 恢复报告格式

```markdown
# Session Recovery Report - Session #N

## Project Status
- Project: my-app
- Total Features: 150
- Completed: 42 (28%)
- Remaining: 108

## Last Session Summary
- Session: #N-1
- Date: 2025-12-30 18:30
- Completed: #40, #41, #42
- Last Commit: "feat: #42 implement email verification"

## Current State Validation
- ✅ Environment: Ready
- ✅ Git: Clean
- ✅ Tests: 45/45 passing
- ⚠️  Dependencies: 2 packages need update

## Recommended Next Steps
1. Feature #43 "用户可以上传头像" (45min)
2. Feature #50 "API性能优化" (2h)
```

## 💡 使用技巧

### ✅ 推荐做法
1. **每个 session 开始时运行**：养成习惯
2. **定期归档**：不让 progress.txt 过大
3. **及时更新状态**：Feature 完成后立即标记
4. **备份重要状态**：定期 commit codebox/

### ❌ 常见错误
1. 不在项目目录就运行 ❌
2. 长时间不更新状态 ❌
3. 让文件无限增长 ❌

## 📊 文件大小管理

### 自动归档触发
```bash
progress.txt > 2000 行 → 归档最老的 sessions
feature_list.json > 500 特性 → 建议拆分项目
```

### 归档策略
- **progress.txt**: 保留最近 1000 行
- **feature_list.json**: 保留未完成 + 最近30天完成
- **archive/**: 自动归档旧内容

## 🆕 v2.0-Enhanced Integration

### 新增恢复步骤 (7步 → 10步)

```
Step 1-7: [原有步骤保持不变]

Step 8: 读取全局约束 (Global Constraints)
  ├─ requirements.md (全局需求)
  ├─ design.md (架构模式)
  ├─ CLAUDE.md (代码规范)
  └─ constraints.md (质量规则)

Step 9: 加载知识库 (Knowledge Base)
  ├─ knowledge/patterns.json (成功模式)
  ├─ knowledge/errors.json (历史错误)
  └─ knowledge/learnings.md (经验教训)

Step 10: 检查可恢复状态 (Resumability)
  └─ 扫描 changes/active/*/state.json
      - 查找 resumability.canResume = true
      - 按lastSessionTime排序
      - 分析每个可恢复变更的状态
      - 生成恢复建议

实施细节:
```bash
# 1. 扫描所有active变更的state.json
for stateFile in changes/active/*/state.json; do
  changeId=$(jq -r '.changeId' "$stateFile")
  canResume=$(jq -r '.resumability.canResume' "$stateFile")

  if [ "$canResume" = "true" ]; then
    # 提取关键信息
    currentPhase=$(jq -r '.currentPhase' "$stateFile")
    resumeFrom=$(jq -r '.resumability.resumeFrom' "$stateFile")
    lastSession=$(jq -r '.resumability.lastSessionTime' "$stateFile")
    blockers=$(jq -r '.resumability.blockers // [] | join(", ")' "$stateFile")
    instructions=$(jq -r '.resumability.resumeInstructions // ""' "$stateFile")

    # OODA状态（如果在Phase 4）
    if [ "$currentPhase" = "4" ]; then
      oodaIteration=$(jq -r '.ooda.iterationCount' "$stateFile")
      oodaMax=$(jq -r '.ooda.maxIterations' "$stateFile")
      oodaStatus=$(jq -r '.ooda.completionPromise' "$stateFile")
    fi

    # 质量状态
    testsStatus=$(jq -r '.quality.testsStatus // "unknown"' "$stateFile")
    testsPassing=$(jq -r '.quality.testsPassing // 0' "$stateFile")
    testsTotal=$(jq -r '.quality.testsTotal // 0' "$stateFile")

    # 添加到可恢复列表
    resumableChanges+=("$changeId|$currentPhase|$resumeFrom|$lastSession|$blockers|$instructions")
  fi
done

# 2. 按lastSessionTime排序（最近的优先）
sortedChanges=$(sort -t'|' -k4 -r resumableChanges)

# 3. 生成恢复报告（见下方"恢复报告新增内容"部分）
```

### State.json 恢复流程详解

当Step 10检测到可恢复的变更时，生成详细的恢复建议：

#### 恢复报告格式

```markdown
## 可恢复变更 (Resumable Changes)

### 变更 #001 - User Authentication [Phase 4 - Iteration 5/10]
**状态**: OODA循环进行中
**最后活动**: 2小时前 (2025-01-04 12:00)
**Progress**:
  - 当前Phase: 4 (Implementation)
  - OODA迭代: 5/10
  - 完成状态: PENDING

**质量指标**:
  - 测试: 18/22 passing (⚠️ 4 failing)
  - 构建: ✅ Success

**阻塞问题**:
  - ⚠️ 4 failing tests in AuthService.test.ts

**恢复建议**:
  - 修复failing tests后继续OODA循环
  - 预计剩余: 5次迭代

**文件位置**:
  - State: `changes/active/001-user-auth/state.json`
  - Tasks: `changes/active/001-user-auth/tasks.md`
  - 建议操作: `ai-dev resume 001-user-auth`

---

### 变更 #002 - Analytics Dashboard [Phase 2 - Exploring]
**状态**: 等待code-explorer完成
**最后活动**: 1天前 (2025-01-03 15:30)
**Progress**:
  - 当前Phase: 2 (Discovery)
  - 探索状态: code-explorer agents运行中

**阻塞问题**: 无

**恢复建议**:
  - 检查evidence.md是否生成完成
  - 如果完成，可进入Phase 3设计

**文件位置**:
  - State: `changes/active/002-analytics/state.json`
  - Evidence: `changes/active/002-analytics/evidence.md`
  - 建议操作: `ai-dev resume 002-analytics`

---

### 变更 #003 - Payment Integration [Phase 1 - Awaiting Approval]
**状态**: 等待用户审批proposal
**最后活动**: 3小时前 (2025-01-04 11:00)
**Progress**:
  - 当前Phase: 1 (Clarification)
  - 等待: 用户审批proposal.md

**阻塞问题**: 需要用户决策

**恢复建议**:
  - 阅读 proposal.md
  - 审批：yes/no/refine
  - 审批后自动进入Phase 2

**文件位置**:
  - State: `changes/active/003-payment/state.json`
  - Proposal: `changes/active/003-payment/proposal.md`
  - 建议操作:
    1. `cat changes/active/003-payment/proposal.md`  # 查看proposal
    2. `ai-dev resume 003-payment`           # 恢复并审批
```

#### 恢复优先级建议

```
推荐恢复顺序（基于状态分析）：

1. **#003 - Payment Integration** (最高优先级)
   - 原因: 仅需用户审批即可继续，无技术障碍
   - 预计时间: 5分钟审批 + 4小时实现
   - 风险: 低

2. **#001 - User Authentication** (中优先级)
   - 原因: 接近完成(5/10 iterations)，但有failing tests
   - 预计时间: 30分钟修复 + 1.5小时完成剩余
   - 风险: 中 (failing tests需要调试)

3. **#002 - Analytics Dashboard** (低优先级)
   - 原因: 较早期阶段，依赖探索完成
   - 预计时间: 等待探索 + 3小时设计 + 6小时实现
   - 风险: 低
```

#### 实施代码示例

```bash
# session-manager在Step 10执行的代码
function analyzeResumableChanges() {
  local resumableList=()

  # 扫描所有state.json
  for stateFile in changes/active/*/state.json; do
    if [ ! -f "$stateFile" ]; then continue; fi

    local canResume=$(jq -r '.resumability.canResume' "$stateFile")
    if [ "$canResume" != "true" ]; then continue; fi

    # 提取变更信息
    local changeId=$(jq -r '.changeId' "$stateFile")
    local phase=$(jq -r '.currentPhase' "$stateFile")
    local lastSession=$(jq -r '.resumability.lastSessionTime' "$stateFile")
    local blockers=$(jq -r '.resumability.blockers // [] | join(", ")' "$stateFile")
    local instructions=$(jq -r '.resumability.resumeInstructions // ""' "$stateFile")

    # Phase特定信息
    local phaseInfo=""
    case $phase in
      1)
        phaseInfo="Phase 1 (Clarification) - 等待审批"
        ;;
      2)
        phaseInfo="Phase 2 (Discovery) - 探索中"
        ;;
      3)
        phaseInfo="Phase 3 (Design) - 等待方案选择"
        ;;
      4)
        local iteration=$(jq -r '.ooda.iterationCount' "$stateFile")
        local maxIter=$(jq -r '.ooda.maxIterations' "$stateFile")
        phaseInfo="Phase 4 (Implementation) - OODA $iteration/$maxIter"
        ;;
      5)
        phaseInfo="Phase 5 (Quality) - 质量验证"
        ;;
    esac

    # 计算时间差
    local hoursSince=$(calculateHoursSince "$lastSession")
    local timeAgo="${hoursSince}小时前"

    # 添加到列表
    resumableList+=("$changeId|$phase|$phaseInfo|$timeAgo|$blockers|$instructions|$lastSession")
  done

  # 按lastSession排序（最近的优先）
  IFS=$'\n' sorted=($(sort -t'|' -k7 -r <<<"${resumableList[*]}"))
  unset IFS

  # 生成报告
  echo "## 可恢复变更 (${#sorted[@]} 个)"
  echo ""

  for entry in "${sorted[@]}"; do
    IFS='|' read -r changeId phase phaseInfo timeAgo blockers instructions lastSession <<< "$entry"

    echo "### 变更 #${changeId} [$phaseInfo]"
    echo "**最后活动**: $timeAgo ($lastSession)"

    if [ -n "$blockers" ]; then
      echo "**阻塞问题**: ⚠️ $blockers"
    else
      echo "**阻塞问题**: 无"
    fi

    echo "**恢复建议**: $instructions"
    echo "**建议操作**: \`ai-dev resume $changeId\`"
    echo ""
    echo "---"
    echo ""
  done

  # 推荐优先级
  echo ""
  echo "## 推荐恢复顺序"
  echo ""
  prioritizeResumption "${sorted[@]}"
}

function prioritizeResumption() {
  # 根据阻塞情况、完成度、时间等因素排序
  # Phase 1 等待审批 > Phase 4 接近完成且无blockers > 其他
  # 实现逻辑省略...
}
```

### Enhanced feature_list.json Support

现在支持 v2.0-enhanced schema:
```json
{
  "version": "2.0-enhanced",
  "changes": {
    "active": ["001-user-auth", "002-analytics"],
    "staged": ["003-payment"],
    "archived_count": 25
  },
  "features": [
    {
      "id": 1,
      "change_id": "001-user-auth",
      "lifecycle": {
        "stage": "implementation",
        "phase": "phase-4-implementation",
        "workflow_state": {
          "ooda_iteration": 6,
          "completion_promise": "PENDING"
        }
      },
      "quality": {
        "average_confidence": 92,
        "issues": [...]
      },
      "knowledge": {
        "related_patterns": ["PATTERN-001"],
        "related_errors": ["ERROR-012"]
      }
    }
  ]
}
```

### 恢复报告新增内容

```markdown
# Session Recovery Report - v2.0

## Project Status
- Total Features: 150
- Active: 3 | Staged: 2 | Archived: 25

## Global Constraints
✅ requirements.md (15 global requirements)
✅ design.md (5 architecture patterns)
✅ CLAUDE.md (code style rules)
✅ constraints.md (quality gates)

## Knowledge Base
📚 Patterns: 12 (PATTERN-001 used 25 times)
⚠️  Errors: 5 (防止重复错误)
📖 Learnings: 38 entries

## Resumable Features (可继续)
### #001 - User Authentication [Phase 4 - Iteration 6/10]
- Last activity: 2 hours ago
- Status: OODA loop in progress
- Next task: Task 6 (Add integration tests)
- Can resume: ✅ state.json valid

### #002 - Analytics Dashboard [Phase 2 - Exploring]
- Last activity: 1 day ago
- Status: code-explorer running
- Can resume: ✅

## Quality Metrics (新增)
- Average confidence: 92/100
- High-confidence issues: 4 (across all active)
- Test coverage: 87%

## Recommended Next
考虑到 global constraints 和 knowledge base:
1. 继续 #001 (6/10 iterations, 接近完成)
2. 修复 4 个高置信度问题
3. 或开始新功能 (遵循 design.md patterns)
```

### Phase 0 Knowledge Pre-check

当推荐下一个功能时，自动触发Phase 0检查：
```
🔍 Phase 0 Pre-check for Feature #43

Global Constraints:
✅ 符合 REQ-GLOBAL-001 (API规范)
✅ 符合 design.md (Repository pattern)
⚠️  注意 CLAUDE.md (函数 ≤30行)

Knowledge Base:
✅ PATTERN-001 可参考 (用户上传功能)
⚠️  ERROR-005 需注意 (文件大小验证)

建议:
- 参考 src/lib/repositories/FileRepository.ts
- 使用 multer + 文件大小验证避免 ERROR-005
- 遵循 Repository pattern (design.md)

准备好开始了！
```

### 归档时知识更新

功能完成并归档时，自动更新知识库：
```bash
# 归档 Feature #42 后
✅ Feature #42 已归档

知识更新:
- patterns.json: PATTERN-001 使用次数 +1
- learnings.md: 新增3条最佳实践
- errors.json: 无新错误 ✅

归档位置: changes/archived/2024-01/042-email-verification/
```

### 与7-Phase Workflow集成

识别功能所处阶段并提供对应帮助：
```
Feature #001: Phase 4 (Implementation) - OODA iteration 6
  ↓
session-manager 建议:
- 继续OODA loop (剩余4次迭代)
- 参考 tasks.md 了解剩余工作
- 或使用 /feature-show 001 查看详情

Feature #002: Phase 2 (Discovery)
  ↓
session-manager 建议:
- 等待 code-explorer agents 完成
- 或查看 evidence.md 了解探索进度

Feature #003: Phase 1 (Clarification)
  ↓
session-manager 建议:
- 等待用户审批 proposal.md
- 或使用 ai 命令查看proposal内容
```

## 🔗 与其他系统协作

- **project-initializer**: 读取初始化创建的所有文件（包括全局约束和知识库）
- **ai-dev**: 提供完整上下文（constraints + knowledge + state），推荐下一个特性
- **Commands**: 可用 `/progress`, `/feature-list`, `/feature-show` 查看详细进度
- **confidence-scorer**: 读取质量指标，报告高置信度问题

## 📚 详细参考

- **[恢复流程详解](references/recovery-process.md)** - 7步启动序列详细说明
- **[归档管理](references/archive-management.md)** - 自动归档机制和手动管理
- **[故障排除](references/troubleshooting.md)** - 常见问题和解决方案

## ❓ 故障排除

**恢复失败？**
- 确保在正确的项目目录
- 检查 codebox/ 目录存在
- 验证文件格式：`jq . feature_list.json`

**环境启动失败？**
- 检查 init.sh 可执行权限
- 手动运行并查看错误
- 检查端口占用

**特性依赖未满足？**
- 查看特性的 dependencies 字段
- 先完成依赖特性
- 或选择其他可执行特性

---

## Agent Collaboration

| Agent | Role |
|-------|------|
| `project-initializer` | Creates files session-manager reads |
| `ai-dev` | Provides feature context for recovery |
| `context-bridge` | Lightweight alternative for quick resume |
| `@librarian` | Query knowledge during recovery |

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 4.2.6 | 2026-01-13 | Add third-person description, triggers, agent collaboration |
| 4.2.0 | 2026-01-07 | Add v2.0-enhanced support with 10-step recovery |
| 4.0.0 | 2026-01-01 | Initial release with 7-step recovery |

---

**核心理念**: 让每个新 session 的开始就像从未中断过。完美的上下文恢复 = 持续的生产力。
