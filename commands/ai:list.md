---
name: ai:list
description: List all features and their status, support filtering by stage, status and priority
argument-hint: "[--active] [--staged] [--archived] [--stage=X]"
allowed-tools: Read, Bash, Grep, Glob
---

# Feature List Command

显示所有功能的概览列表。

## 用法

```bash
/feature-list                    # 显示所有功能
/feature-list --active          # 仅显示active
/feature-list --stage=phase-4   # 仅显示Phase 4
/feature-list --completed       # 仅显示已完成
```

## 执行步骤

1. **读取feature_list.json**
   ```bash
   cat feature_list.json
   ```

2. **应用过滤器** (如果指定)
   - `--active`: 仅active功能
   - `--staged`: 仅staged功能
   - `--archived`: 仅archived功能
   - `--stage=X`: 特定阶段
   - `--completed`: lifecycle.stage = "completed"

3. **显示列表**

```markdown
# 功能列表

## 统计
- **总功能**: 15
- **Active**: 3
- **Staged**: 2
- **Archived**: 10
- **完成率**: 66.7%

## Active 功能 (3)

### 001 - 用户登录功能 [Phase 4: Implementation]
- **状态**: in_progress (62.5% complete)
- **质量**: ⭐⭐⭐⭐⭐ (92/100)
- **问题**: 2个高置信度问题待修复
- **位置**: changes/active/001-user-auth/

### 002 - 数据分析仪表板 [Phase 2: Discovery]
- **状态**: exploring (30% complete)
- **质量**: N/A (未开始实现)
- **代理**: 2x code-explorer
- **位置**: changes/active/002-analytics/

### 003 - 支付集成 [Phase 1: Clarification]
- **状态**: pending_approval
- **质量**: N/A
- **等待**: 用户审批proposal.md
- **位置**: changes/active/003-payment/

## Staged 功能 (2)

### 004 - 邮件通知系统 [Ready for Review]
- **准备阶段**: Phase 6
- **等待**: 最终用户审批
- **位置**: changes/staged/004-email/

### 005 - 搜索优化 [Ready for Review]
- **准备阶段**: Phase 6
- **等待**: 最终用户审批
- **位置**: changes/staged/005-search/

## 快速操作
- 查看详情: `/feature-show <id>`
- 归档功能: `/ai:feature-archive <id>`
- 恢复功能: `/feature-resume <id>`

---
总计: 15个功能 | Active: 3 | Staged: 2 | Archived: 10
```

## 表格模式 (可选)

```
┌────┬─────────────────────┬──────────┬──────────┬─────────┬────────┐
│ ID │ 标题                │ 阶段     │ 状态     │ 进度    │ 质量   │
├────┼─────────────────────┼──────────┼──────────┼─────────┼────────┤
│001 │用户登录功能         │ Phase 4  │ active   │ 62.5%   │ 92/100 │
│002 │数据分析仪表板       │ Phase 2  │ active   │ 30%     │ N/A    │
│003 │支付集成             │ Phase 1  │ pending  │ 0%      │ N/A    │
│004 │邮件通知系统         │ Phase 6  │ staged   │ 100%    │ 95/100 │
│005 │搜索优化             │ Phase 6  │ staged   │ 100%    │ 88/100 │
└────┴─────────────────────┴──────────┴──────────┴─────────┴────────┘
```

## 颜色编码 (终端)

- 🟢 Green: 进展顺利 (>80% complete, quality >90)
- 🟡 Yellow: 需要关注 (50-80% complete)
- 🔴 Red: 阻塞或问题 (<50% complete, quality <80)
- ⚪ Gray: 未开始或归档

## 示例输出

```bash
$ /feature-list

# 功能列表 (15个)

## Active (3)
001 🟡 用户登录功能 [Phase 4] 62.5% - 2 issues
002 🟡 数据分析仪表板 [Phase 2] 30% - exploring
003 ⚪ 支付集成 [Phase 1] 0% - pending approval

## Staged (2)
004 🟢 邮件通知系统 [Ready] 100% - quality 95
005 🟢 搜索优化 [Ready] 100% - quality 88

## Archived (10)
...

使用 /feature-show <id> 查看详情
```
