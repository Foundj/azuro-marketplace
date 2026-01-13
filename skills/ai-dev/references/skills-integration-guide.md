# Skills 协作流程指南

> ai-dev 工作流与各 skills 的集成规范

## 概览

ai-dev 采用 7 阶段门控工作流，每个阶段由特定 skills 支持：

```
Phase -1    Phase 0      Phase 0.5    Phase 1       Phase 2
   │           │            │            │             │
   ▼           ▼            ▼            ▼             ▼
┌─────────┐ ┌─────────┐ ┌─────────┐ ┌───────────┐ ┌─────────┐
│brainstorm│ │thinking │ │research │ │ai-dev-    │ │ User    │
│-mode    │ │-engine  │ │         │ │interview  │ │Approval │
│(可选)    │ │knowledge│ │         │ │           │ │         │
│         │ │-graph   │ │         │ │           │ │         │
└────┬────┘ └────┬────┘ └────┬────┘ └─────┬─────┘ └────┬────┘
     │           │            │            │            │
     ▼           ▼            ▼            ▼            ▼
discovery-   Context     research.json  proposal.md  design.md
brief.md     Loaded
philosophy.md

Phase 3      Phase 4        Phase 5        Phase 5.5      Phase 6
   │            │              │               │              │
   ▼            ▼              ▼               ▼              ▼
┌─────────┐ ┌──────────┐ ┌───────────┐ ┌───────────┐ ┌─────────┐
│ Auto    │ │ai-dev-   │ │ai-dev-    │ │code-      │ │Archive  │
│ Task    │ │ooda      │ │quality    │ │simplifier │ │& Commit │
│Breakdown│ │knowledge │ │           │ │(可选)      │ │knowledge│
│         │ │-graph    │ │           │ │           │ │-graph   │
└────┬────┘ └────┬─────┘ └─────┬─────┘ └─────┬─────┘ └────┬────┘
     │           │             │             │            │
     ▼           ▼             ▼             ▼            ▼
  tasks.md    Code +      quality-     Refined      Archived
             DONE promise report.md     Code        to knowledge
```

---

## Phase 详细说明

### Phase -1: Brainstorming (可选)

**触发条件**: 需求模糊时使用

| Skill | 作用 | 输入 | 输出 |
|-------|------|------|------|
| `brainstorm-mode` | 苏格拉底式探索对话 | 模糊想法 | `discovery-brief.md` |
| `brainstorm-mode` (哲学模式) | 建立创作原则 | 创意方向 | `philosophy.md` |

**数据流**:
```
用户模糊想法
    ↓
brainstorm-mode (发散探索)
    ↓
discovery-brief.md
    ↓
用户确认方向
    ↓
Phase 0 开始
```

**触发词**:
- `brainstorm`, `explore ideas`, `not sure what I need`
- `头脑风暴`, `探索想法`, `我不确定`, `帮我想想`

---

### Phase 0: Context & Knowledge

**触发条件**: 自动执行

| Skill | 作用 | 输入 | 输出 |
|-------|------|------|------|
| `thinking-engine` | 结构化思考 | 任务描述 | 分析结果 |
| `knowledge-graph` | 查询历史经验 | 项目上下文 | 相关 patterns/errors |

**数据流**:
```
project-snapshot.json + git diff
    ↓
knowledge-graph (查询相关经验)
    ↓
检测: 🔴 Blocking / 🟡 Warning / 🟢 Info
    ↓
Context 加载完成
```

**关键操作**:
- 加载 `codebox/project-snapshot.json`
- 查询 `codebox/knowledge/` 中的 patterns 和 errors
- 检测阻塞问题

---

### Phase 0.5: Research (新功能时执行)

**触发条件**: 新功能开发时自动执行

| Skill | 作用 | 输入 | 输出 |
|-------|------|------|------|
| `competitor-research` | 竞品调研 | 功能名称 | `[feature]-research.json` |

**数据流**:
```
功能描述
    ↓
competitor-research (多模型调研)
    ↓
codebox/research/[feature]-research.json
    ↓
Phase 1 使用
```

**输出位置**: `codebox/research/`

---

### Phase 1: Requirement Interview

**触发条件**: 用户批准进入

| Skill | 作用 | 输入 | 输出 |
|-------|------|------|------|
| `ai-dev-interview` | 多轮结构化访谈 | research, knowledge, 项目上下文 | `proposal.md` |

**数据流**:
```
Phase 0.5 research.json
    +
knowledge-graph 查询结果
    ↓
ai-dev-interview (2-6 轮)
    ↓
proposal.md
    ↓
用户批准 → Phase 2
```

**并行上下文收集**:
- @explore-fast: 扫描项目结构
- @librarian: 查询知识库
- Research: 加载竞品洞察

**风险检测**:
- 🔴 Blocking: 必须解决才能继续
- 🟡 Warning: 用户决定是否继续
- 🟢 Info: 纳入建议

---

### Phase 2: Design Approval

**触发条件**: 用户批准 proposal.md 后

**数据流**:
```
proposal.md
    +
codebox/design.md (全局约束)
    ↓
展示 2-3 种设计方案
    ↓
用户选择方案
    ↓
生成 design.md (功能专用)
```

**输出位置**: `codebox/changes/active/[id]/design.md`

---

### Phase 3: Task Breakdown

**触发条件**: 自动执行

**数据流**:
```
design.md
    ↓
自动生成任务分解
    ↓
tasks.md (含子任务、成功标准、验证命令)
```

**tasks.md 格式**:
```markdown
- [ ] 任务 1
  - verify_with: `npm test -- --grep "task1"`
  - success_criteria: 所有测试通过
- [ ] 任务 2
  ...
```

---

### Phase 4: Implementation (OODA)

**触发条件**: 自动激活

| Skill | 作用 | 输入 | 输出 |
|-------|------|------|------|
| `ai-dev-ooda` | OODA 自主执行 | `tasks.md` | 代码 + `<promise>DONE</promise>` |
| `knowledge-graph` | 参考历史实现 | 任务上下文 | 相关方案 |

**数据流**:
```
tasks.md
    ↓
┌─────────────────────────────────┐
│          OODA 循环              │
├─────────────────────────────────┤
│  OBSERVE: 读取 tasks.md         │
│  ORIENT: 分析上下文, 查询知识    │
│  DECIDE: 选择下一步动作          │
│  ACT: 执行, 更新 checkbox       │
│           ↓                     │
│  Loop until all ✅              │
│           ↓                     │
│  <promise>DONE</promise>        │
└─────────────────────────────────┘
```

**注意力管理**:
- 每次迭代读取 `tasks.md` 刷新目标
- 每 5 次迭代运行 `/focus`
- 最大迭代: 50 次

**验证门禁**:
- `verify_with` 命令必须通过才能标记完成
- 未通过则记录到 `solutions_learned.jsonl`

---

### Phase 5: Quality Validation

**触发条件**: `<promise>DONE</promise>` 后自动触发

| Skill | 作用 | 输入 | 输出 |
|-------|------|------|------|
| `ai-dev-quality` | 多视角代码审查 | 实现的代码 | `quality-report.md` |

**数据流**:
```
实现的代码
    ↓
┌─────────────────────────────────────┐
│  3x code-reviewer (并行)            │
│  - Security: 安全漏洞              │
│  - Bugs: 逻辑错误                  │
│  - Maintainability: 可维护性       │
└─────────────────────────────────────┘
    ↓
confidence-scorer (过滤 ≥80)
    ↓
verification-agent (Tests, Build, Lint)
    ↓
quality-report.md
    ↓
Pass ≥ 80? → Phase 5.5 / 6
No → 返回 Phase 4 修复
```

**质量门禁维度**:
| 维度 | 权重 |
|------|------|
| Security | 40% |
| Code Quality | 30% |
| Documentation | 20% |
| Architecture | 10% |

---

### Phase 5.5: Code Simplification (可选)

**触发条件**: 质量门禁通过 + `autoSimplify: true`

| Skill | 作用 | 输入 | 输出 |
|-------|------|------|------|
| `code-simplifier` | 代码精简 | 批准的代码 | 精简后的代码 |

**数据流**:
```
质量门禁通过的代码
    ↓
code-simplifier:
  - SOLID 原则检查
  - 复杂度度量
  - 应用重构模式
  - Anti-AI-Slop 原则
    ↓
精简后的代码
    ↓
Phase 6
```

**配置**:
```json
{
  "quality": {
    "autoSimplify": true,
    "simplifyScope": "recent"
  }
}
```

---

### Phase 6: Finalization

**触发条件**: 质量验证通过后

| Skill | 作用 | 输入 | 输出 |
|-------|------|------|------|
| `knowledge-graph` | 记录新模式 | 解决方案 | 更新 knowledge/ |

**数据流**:
```
精简后的代码
    ↓
knowledge-graph (记录成功模式)
    ↓
归档到 codebox/changes/archived/
    ↓
git commit
```

---

## 跨会话 Skills

### context-bridge

**作用**: 轻量级上下文持久化

**触发阈值**:
| 阈值 | 动作 |
|------|------|
| 70% | 建议 `/focus` |
| 85% | 警告保存 |
| 90% | **自动保存** |

**数据流**:
```
工作过程中
    ↓
检测 context 使用率
    ↓
自动保存到 codebox/context/
  - session_summary.md
  - next_steps.md
    ↓
新 session: /session:resume
```

### session-manager

**作用**: 完整会话恢复 (长时间中断后)

**区别**:
| 功能 | context-bridge | session-manager |
|------|----------------|-----------------|
| 场景 | 短时间中断 | 长时间中断 |
| 恢复 | 读取 context/ | 10 步验证 + 环境启动 |
| 速度 | 快 | 慢但彻底 |

---

## 数据文件流转图

```
codebox/
├── project-snapshot.json  ← Phase 0 读取
├── requirements.md        ← Phase 0/4 参考
├── design.md              ← Phase 2/4 参考
├── knowledge/             ← Phase 0/4/6 读写
│   ├── patterns.json
│   └── errors.json
├── research/              ← Phase 0.5 写入, Phase 1 读取
│   └── [feature]-research.json
├── context/               ← context-bridge 读写
│   ├── session_summary.md
│   ├── next_steps.md
│   └── sessions/
└── changes/
    ├── active/[id]/       ← 当前功能
    │   ├── state.json     ← 状态追踪
    │   ├── proposal.md    ← Phase 1 输出
    │   ├── design.md      ← Phase 2 输出
    │   ├── tasks.md       ← Phase 3 输出, Phase 4 读写
    │   └── progress.txt   ← OODA 日志
    └── archived/          ← Phase 6 归档
```

---

## 触发词汇总

| Skill | 触发词 |
|-------|--------|
| `brainstorm-mode` | brainstorm, explore ideas, 头脑风暴, 探索想法, 我不确定 |
| `ai-dev-interview` | requirement interview, ai:interview, 需求访谈 |
| `ai-dev-ooda` | autonomous loop, OODA loop, ai:loop, 自动执行 |
| `ai-dev-quality` | code review, quality check, ai:review, 代码审查 |
| `code-simplifier` | simplify code, refactor, 代码简化, 代码重构 |
| `context-bridge` | save, resume, focus, 保存, 恢复, 继续 |
| `knowledge-graph` | query knowledge, 查知识库, 知识图谱 |

---

## 命令汇总

### 用户命令

| 命令 | 阶段 | 作用 |
|------|------|------|
| `/ai:dev <feature>` | 全流程 | 启动 7 阶段工作流 |
| `/ai:dev auto` | Phase 4 | 自动完成所有任务 |
| `/ai:fix <bug>` | - | 快速修复 (subagent) |
| `/ai:status` | - | 查看进度 |
| `/ai:session-save` | 跨会话 | 保存会话 |
| `/ai:session-resume` | 跨会话 | 恢复会话 |

### 内部命令

| 命令 | 阶段 | 调用者 |
|------|------|--------|
| `ai:interview` | 1 | ai:dev |
| `ai:loop` | 4 | ai:dev auto |
| `ai:quality` | 5 | ai:dev |
| `ai:check` | 0 | ai:dev |

---

## 集成验证清单

| # | 检查项 | 验证方法 |
|---|--------|----------|
| 1 | Phase 0 → 1 数据传递 | research.json 被 interview 读取 |
| 2 | Phase 1 → 2 数据传递 | proposal.md 生成 |
| 3 | Phase 2 → 3 数据传递 | design.md 用于任务分解 |
| 4 | Phase 3 → 4 数据传递 | tasks.md 被 OODA 读取 |
| 5 | Phase 4 → 5 触发 | DONE promise 触发质量检查 |
| 6 | Phase 5 → 5.5 可选 | autoSimplify 配置生效 |
| 7 | Phase 5.5 → 6 数据传递 | 精简代码可提交 |
| 8 | 跨会话恢复 | context/ 文件正确加载 |
| 9 | 知识积累 | Phase 6 更新 knowledge/ |

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| 4.2.4 | 2026-01-13 | 初始文档，完整记录 11 个 skills 集成点 |
