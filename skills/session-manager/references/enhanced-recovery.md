# Enhanced Recovery Process

> v2.0-enhanced 恢复流程详解：7步 → 10步

## 新增恢复步骤

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
      - 按 lastSessionTime 排序
      - 分析每个可恢复变更的状态
      - 生成恢复建议
```

## State.json 恢复流程

当 Step 10 检测到可恢复的变更时，生成详细的恢复建议。

### 恢复报告格式

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
  - 修复 failing tests 后继续 OODA 循环
  - 预计剩余: 5次迭代

**建议操作**: `ai-dev resume 001-user-auth`
```

### 恢复优先级建议

```
推荐恢复顺序（基于状态分析）：

1. **#003 - Payment Integration** (最高优先级)
   - 原因: 仅需用户审批即可继续
   - 预计时间: 5分钟审批 + 4小时实现
   - 风险: 低

2. **#001 - User Authentication** (中优先级)
   - 原因: 接近完成(5/10 iterations)，但有 failing tests
   - 预计时间: 30分钟修复 + 1.5小时完成剩余
   - 风险: 中

3. **#002 - Analytics Dashboard** (低优先级)
   - 原因: 较早期阶段，依赖探索完成
   - 预计时间: 等待探索 + 3小时设计 + 6小时实现
   - 风险: 低
```

## 实施代码

```bash
function analyzeResumableChanges() {
  local resumableList=()

  for stateFile in changes/active/*/state.json; do
    if [ ! -f "$stateFile" ]; then continue; fi

    local canResume=$(jq -r '.resumability.canResume' "$stateFile")
    if [ "$canResume" != "true" ]; then continue; fi

    local changeId=$(jq -r '.changeId' "$stateFile")
    local phase=$(jq -r '.currentPhase' "$stateFile")
    local lastSession=$(jq -r '.resumability.lastSessionTime' "$stateFile")

    # 添加到列表
    resumableList+=("$changeId|$phase|$lastSession")
  done

  # 按 lastSession 排序
  IFS=$'\n' sorted=($(sort -t'|' -k3 -r <<<"${resumableList[*]}"))
  unset IFS

  # 生成报告
  for entry in "${sorted[@]}"; do
    IFS='|' read -r changeId phase lastSession <<< "$entry"
    echo "### 变更 #${changeId} [Phase ${phase}]"
    echo "**最后活动**: $lastSession"
    echo "**建议操作**: \`ai-dev resume $changeId\`"
  done
}
```

## Enhanced feature_list.json Schema

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
      }
    }
  ]
}
```

## 与 7-Phase Workflow 集成

```
Feature #001: Phase 4 (Implementation) - OODA iteration 6
  ↓
session-manager 建议:
- 继续 OODA loop (剩余4次迭代)
- 参考 tasks.md 了解剩余工作

Feature #002: Phase 2 (Discovery)
  ↓
session-manager 建议:
- 等待 code-explorer agents 完成
- 查看 evidence.md 了解探索进度

Feature #003: Phase 1 (Clarification)
  ↓
session-manager 建议:
- 等待用户审批 proposal.md
```