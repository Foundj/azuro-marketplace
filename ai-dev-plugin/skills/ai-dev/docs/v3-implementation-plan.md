# ai-dev Plugin v3.0 实施方案

> 版本: 3.0.0
> 日期: 2025-01-05
> 目标评分: 95+

---

## 📋 项目概述

### 背景

将 `ai-dev` 技能优化到 95+ 分，主要解决：
1. SKILL.md 严重膨胀（1,961 行 → ~200 行）
2. 缺少可执行脚本（hooks/, scripts/ 目录）
3. 设计宏大但缺乏实际执行机制
4. 未利用现有插件生态

### 核心改动

| 改动 | 描述 |
|------|------|
| Plugin 重命名 | `long-running-dev` → `ai-dev` |
| 项目目录 | `codebox/` → `codebox/` |
| 新增 competitor-research | 竞品调研 Skill |
| 新增 requirement-interviewer | 需求采访 Agent |
| 新增可执行 Hooks | ooda-stop-hook.sh, pre-change-check |
| 整合 mem0 | 知识库查询到 Phase 0 |
| 项目上下文感知 | 初始化深度扫描 + git diff 增量 |

---

## 🏗️ 架构设计

### 最终目录结构

```
${CLAUDE_PLUGIN_ROOT}/skills/
├── .claude-plugin/
│   └── plugin.json                  # name: "ai-dev"
│
├── ai-dev/                 # 核心编排
│   ├── SKILL.md                     # ~200 行精简版
│   ├── agents/
│   │   ├── requirement-interviewer.md   # 🆕 需求采访 Agent
│   │   ├── verification-agent.md        # 已有
│   │   └── quality/
│   │       ├── confidence-scorer.md     # 已有
│   │       └── code-reviewer.md         # 已有
│   ├── hooks/
│   │   ├── hooks.json                   # 🆕 Hook 注册
│   │   ├── ooda-stop-hook.sh            # 🆕 OODA 循环
│   │   └── pre-change-check.md          # 已有
│   ├── scripts/
│   │   ├── query-knowledge.sh           # 🆕 mem0 集成
│   │   ├── init-change.sh               # 🆕 变更初始化
│   │   ├── scan-project.sh              # 🆕 项目扫描
│   │   └── archive-change.sh            # 🆕 变更归档
│   ├── references/                      # 详细文档（按需加载）
│   ├── templates/
│   │   └── codebox/                     # 🆕 项目模板
│   └── docs/
│       └── v3-implementation-plan.md    # 本文档
│
├── competitor-research/             # 🆕 竞品调研 Skill
│   └── SKILL.md
│
├── project-initializer/             # 已有，需更新
│   └── SKILL.md
│
└── session-manager/                 # 已有
    └── SKILL.md
```

### 项目目录模板 (codebox/)

```
codebox/                              # 项目 AI 配置目录
├── config.json                       # 项目配置
├── requirements.md                   # 全局需求 (EARS)
├── design.md                         # 架构设计
├── CLAUDE.md                         # AI 行为约束
├── constraints.md                    # 质量门禁
├── feature_list.json                 # 功能列表和状态
├── progress.txt                      # 进度日志
├── project-snapshot.json             # 项目快照（初始化生成）
│
├── knowledge/                        # 知识库
│   ├── patterns.json                 # 成功模式
│   ├── errors.json                   # 历史错误
│   └── learnings.md                  # 经验总结
│
├── research/                         # 调研结果
│   └── [feature]-research.json
│
├── changes/                          # 变更管理
│   ├── active/[id]/
│   │   ├── proposal.md
│   │   ├── design.md
│   │   ├── tasks.md
│   │   ├── evidence.md
│   │   ├── phase0-context.md
│   │   └── state.json
│   ├── staged/
│   └── archived/YYYY-MM/
│
└── memory/                           # mem0 集成
    └── ...
```

---

## 🔄 完整工作流程

```
用户输入: "ai 实现用户搜索"
           │
           ▼
┌─────────────────────────────────────────────────────────────────┐
│ Phase 0.1: 上下文预加载                                          │
├─────────────────────────────────────────────────────────────────┤
│ • 读取 project-snapshot.json（快速）                             │
│ • git diff HEAD~10（增量变更）                                   │
│ • 读取 codebox/requirements.md, design.md, feature_list.json    │
│ • 读取 knowledge/patterns.json, errors.json                     │
└─────────────────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────────┐
│ Phase 0.2: 问题检测（分级处理）                                    │
├─────────────────────────────────────────────────────────────────┤
│ 🔴 阻断级 → 必须解决（重复功能、严重架构冲突）                       │
│ 🟡 警告级 → 显示警告，用户可选择（相似功能、轻微偏离）               │
│ 🟢 建议级 → 附加信息，不阻断（历史模式、最佳实践）                   │
└─────────────────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────────┐
│ Phase 0.3: 判断是否需要调研                                       │
├─────────────────────────────────────────────────────────────────┤
│ • 新功能 → 自动调研                                               │
│ • 简单修复 → 跳过调研                                             │
│ • 用户指定 → 按用户要求                                           │
└─────────────────────────────────────────────────────────────────┘
           │
           ├─ 需要调研 ──────────────────────────────────┐
           │                                             ▼
           │              ┌──────────────────────────────────────────┐
           │              │ Phase 0.4: 竞品调研 (competitor-research) │
           │              ├──────────────────────────────────────────┤
           │              │ • ~/.claude/common/lib/codeagent-wrapper.sh │
           │              │   --backend gemini (web search)           │
           │              │   --backend codex (code analysis)         │
           │              │   --backend claude (code review)          │
           │              │ • 生成 research/[feature]-research.json  │
           │              └──────────────────────────────────────────┘
           │                                             │
           ├─────────────────────────────────────────────┘
           ▼
┌─────────────────────────────────────────────────────────────────┐
│ Phase 1: 需求采访 (requirement-interviewer)                      │
├─────────────────────────────────────────────────────────────────┤
│ • 多轮采访式提问                                                  │
│ • 每个问题附带调研参考 + 项目上下文 + 历史经验                       │
│ • 检测不合理需求 → 提出建议或拒绝                                  │
│ • 输出: proposal.md                                              │
└─────────────────────────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────────────┐
│ Phase 2-6: 标准 7-Phase 流程                                     │
├─────────────────────────────────────────────────────────────────┤
│ 2. 设计审批 → design.md                                          │
│ 3. 任务拆解 → tasks.md                                           │
│ 4. OODA 实现 → 代码变更 (ooda-stop-hook.sh)                       │
│ 5. 质量验证 → confidence-scorer + verification-agent             │
│ 6. 完成归档 → 更新 knowledge/, 归档 changes/                       │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📝 设计决策记录

### D1: Plugin 命名
- **决策**: `long-running-dev` → `ai-dev`
- **原因**: 更简洁，更能表达核心功能

### D2: 项目目录命名
- **决策**: `codebox/` → `codebox/`
- **原因**: 不以 `.` 开头，方便用户查看

### D3: 上下文检查严格程度
- **决策**: 分级处理（阻断/警告/建议）
- **原因**: 严重问题必须阻断，轻微问题可忽略

### D4: 代码扫描策略
- **决策**: 初始化深度扫描 + 日常 git diff 增量
- **原因**: 初始化时建立完整理解，后续增量感知更高效

### D5: 历史经验匹配
- **决策**: 先用关键词+标签，后续整合 mem0
- **原因**: 快速上线，避免过度设计

### D6: 调研触发
- **决策**: 自动触发（新功能）+ 手动触发（/research）
- **原因**: 智能判断 + 用户可控

### D7: 调研工具
- **决策**: 使用 `~/.claude/common/lib/codeagent-wrapper.sh` (gemini/codex/claude)
- **原因**: 统一多后端调用，支持自动选择，不依赖 CCS

### D8: 调研存储
- **决策**: 永久存储，无过期，用户手动重新调研
- **原因**: 简化逻辑，用户有控制权

### D9: Agents 复用
- **决策**: 保留现有 agents，仅引用 feature-dev 的 code-explorer
- **原因**: 我们的 agents 更完善（confidence-scorer 703行，verification-agent 725行）

---

## 📋 任务列表

### Phase 1: 核心文件创建 (P0)

| # | 任务 | 文件 | 依赖 |
|---|------|------|------|
| 1.1 | 更新 plugin.json | `.claude-plugin/plugin.json` | 无 |
| 1.2 | 创建 competitor-research SKILL.md | `competitor-research/SKILL.md` | 无 |
| 1.3 | 创建 requirement-interviewer | `ai-dev/agents/requirement-interviewer.md` | 无 |
| 1.4 | 创建 hooks.json | `ai-dev/hooks/hooks.json` | 无 |
| 1.5 | 创建 ooda-stop-hook.sh | `ai-dev/hooks/ooda-stop-hook.sh` | 1.4 |
| 1.6 | 创建 query-knowledge.sh | `ai-dev/scripts/query-knowledge.sh` | 无 |
| 1.7 | 创建 scan-project.sh | `ai-dev/scripts/scan-project.sh` | 无 |

### Phase 2: SKILL.md 瘦身 (P1)

| # | 任务 | 文件 | 依赖 |
|---|------|------|------|
| 2.1 | 备份现有 SKILL.md | `ai-dev/SKILL.md.backup` | 无 |
| 2.2 | 重写精简版 SKILL.md | `ai-dev/SKILL.md` | 2.1 |

### Phase 3: 模板和初始化 (P1)

| # | 任务 | 文件 | 依赖 |
|---|------|------|------|
| 3.1 | 创建 codebox 模板 | `ai-dev/templates/codebox/` | 无 |
| 3.2 | 更新 project-initializer | `project-initializer/SKILL.md` | 3.1 |

### Phase 4: 脚本和工具 (P2)

| # | 任务 | 文件 | 依赖 |
|---|------|------|------|
| 4.1 | 创建 init-change.sh | `ai-dev/scripts/init-change.sh` | 无 |
| 4.2 | 创建 archive-change.sh | `ai-dev/scripts/archive-change.sh` | 无 |

### Phase 5: 文档更新 (P2)

| # | 任务 | 文件 | 依赖 |
|---|------|------|------|
| 5.1 | 更新 quick-start 文档 | `ai-dev/docs/user-guide-quick-start.md` | 全部 |
| 5.2 | 更新 7-phase-workflow | `ai-dev/references/7-phase-workflow.md` | 全部 |

---

## ✅ 验收标准

1. **SKILL.md 行数**: ≤ 250 行
2. **可执行脚本**: hooks/, scripts/ 目录有实际脚本
3. **触发词生效**: `ai`, `dev`, `fix` 等关键词能触发
4. **调研功能**: `/research` 命令可用
5. **采访功能**: 需求采访流程完整
6. **上下文感知**: 能检测重复功能、架构冲突
7. **OODA 循环**: stop-hook 正常工作

---

## 📚 参考资料

- ralph-wiggum OODA: `${CLAUDE_PLUGIN_ROOT}/../../../marketplaces/claude-plugins-official/plugins/ralph-wiggum/`
- feature-dev agents: `${CLAUDE_PLUGIN_ROOT}/../../../marketplaces/claude-plugins-official/plugins/feature-dev/`
- mem0 集成: `${CLAUDE_PLUGIN_ROOT}/../../../common/lib/mem0-integration.sh`
- codex skill 参考: https://github.com/cexll/myclaude/tree/master/skills/codex
- Anthropic Skills 文档: https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview

---

**文档版本**: 1.0
**最后更新**: 2025-01-05
