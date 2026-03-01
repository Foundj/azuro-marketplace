---
version: "1.0"
name: 插件市场产品策略优化
status: pending
updated: 2026-03-01
baseline: v0 (当前状态)
discussion_source: docs/discussions/plugin-marketplace-strategy/discussion.md

# ════════════════════════════════════════════════════════
# 执行规则
# ════════════════════════════════════════════════════════
rules:
  - task.md 是唯一状态真相，plan.md 不含任何勾选状态
  - 每个 Sprint 完成后必须 review code 再进入下一 Sprint
  - 集成测试必须附带可复现的验证命令
  - Sprint 间存在 depends_on 依赖时必须顺序执行
  - "Git 提交格式: feat(v1.0/s{N}): <description>"

# ════════════════════════════════════════════════════════
# 开发顺序与依赖（YAML 结构化描述）
#
# 字段说明：
#   id          - Sprint/Task 唯一标识，在看板区域引用
#   name        - 人类可读名称
#   depends_on  - 前置依赖（Sprint 级或 Task 级）
#   files       - 涉及的文件列表，对应 plan.md 中的文件变更清单
#   verify      - 完成后的验证命令（可复现）
# ════════════════════════════════════════════════════════
sprints:
  - id: sprint-1
    name: 基础架构 — Profile 按需加载 + 技能精简
    depends_on: []
    tasks:
      - id: s1-1
        name: Profile 分组配置
        files: [core/profiles.json, skills/*/SKILL.md]
        depends_on: []
        verify: "cat core/profiles.json | jq '.profiles | keys'"

      - id: s1-2
        name: 冗余 Agent 分析与精简
        files: [agents/]
        depends_on: [s1-1]

      - id: s1-review
        name: Sprint 1 代码审查
        depends_on: [s1-1, s1-2]

  - id: sprint-2
    name: 触发优化 — Description 重写 + Router 强化
    depends_on: [sprint-1]
    tasks:
      - id: s2-1
        name: 技能 Description 场景化重写
        files: [skills/*/SKILL.md]
        depends_on: []

      - id: s2-2
        name: 全局意图 Router 增强
        files: [skills/ai-dev/SKILL.md]
        depends_on: []

      - id: s2-3
        name: 构建触发率评估基准
        files: [evals/trigger-eval.json]
        depends_on: [s2-1]
        verify: "cat evals/trigger-eval.json | jq '.evals | length'"

      - id: s2-review
        name: Sprint 2 代码审查
        depends_on: [s2-1, s2-2, s2-3]

  - id: sprint-3
    name: v6.0 集成 + 监控
    depends_on: [sprint-2]
    tasks:
      - id: s3-1
        name: v6.0 Opt-in Deep Path 集成
        files: [skills/ai-dev/SKILL.md, commands/ai:team.md]
        depends_on: []

      - id: s3-2
        name: 触发率监控脚本
        files: [scripts/trigger-monitor.sh]
        depends_on: []

      - id: s3-review
        name: Sprint 3 代码审查
        depends_on: [s3-1, s3-2]
---

# V1.0 任务看板

<!--
  ┌───────────────────────────────────────────────────────────────┐
  │  本文件职责：唯一执行状态看板                                    │
  │  ✅ YAML 结构化开发顺序 + Markdown 打勾追踪 + 变更记录           │
  │  ❌ 不含技术方案、接口设计（这些在 plan.md）                      │
  │                                                               │
  │  来源讨论：docs/discussions/plugin-marketplace-strategy         │
  │  设计文档：docs/tasks/v1.0/plan.md                              │
  │                                                               │
  │  使用方式：                                                     │
  │  1. 阅读 YAML frontmatter 了解 Sprint/Task 依赖和执行顺序        │
  │  2. 在下方 Markdown 区域打勾追踪进度                              │
  │  3. 完成任务后在变更记录中补充条目                                 │
  │  4. Git 提交使用版本前缀：feat(v1.0/s{N}): description           │
  └───────────────────────────────────────────────────────────────┘
-->

> **唯一状态真相**：所有任务状态仅在此文件维护。`plan.md` 只含需求与设计，不含勾选。

## 前置基线（V0 当前状态）

- [x] Professional Suite 全量打包模式正常运行
- [x] 31 个 GA 技能通过质量审计（99/100）
- [x] v6.0 CLI 自动化编排已验证（7 后端、STATUS 面板、收敛评估）
- [x] populate-context.sh 集成到 init-discussion.sh
- [ ] 技能触发率未建立量化基线（不阻塞 V1.0）

---

## Sprint 1：基础架构 — Profile 按需加载 + 技能精简

- [x] `s1-1` Profile 分组配置 — `core/profiles.json` + 31 个 SKILL.md 添加 `profile` 字段
  > 已在 v6.0.6 完成：default(6), design(7), dev(10), review(6), debug(2)
- [x] `s1-2` 冗余 Agent 分析与精简 — `agents/` 目录功能重叠度分析
  > 30→25 个 Agent：合并 root-cause-analyst+error-detective→debugger，feature-planner→requirement-analyzer，废弃 task-orchestrator(v1)
- [x] `s1-review` Sprint 1 代码审查
  > 审查通过：0 P0, 1 P1(已修复), 2 P2(已修复)

---

## Sprint 2：触发优化 — Description 重写 + Router 强化

- [x] `s2-1` 技能 Description 场景化重写 — 31 个 `skills/*/SKILL.md` 添加 `<example>` 场景块
  > 93 个 `<example>` 场景块（31 技能 × 3），审计器限制 1024→3000 chars
- [x] `s2-2` 全局意图 Router 增强 — `skills/ai-dev/SKILL.md` Top-K + 兜底机制
  > Intent Router v6.0.12：Top-K(1-3) 激活约束 + Direct Routing 兜底 + Context Budget 卸载
- [x] `s2-3` 构建触发率评估基准 — `evals/trigger-eval.json`
  > 30 条评估用例，覆盖 feature-dev/bug-fix/browser/discussion/team/trivial/casual 等场景
- [x] `s2-review` Sprint 2 代码审查
  > 审查通过：0 P0, 5 P1(已修复), 3 P2(已记录)

---

## Sprint 3：v6.0 集成 + 监控

- [x] `s3-1` v6.0 Opt-in Deep Path 集成 — `skills/ai-dev/SKILL.md` + `commands/ai:team.md`
  > Dual Path: Fast(单Agent默认) / Deep(--team/ai:team, 3-5x cost) + discuss 子命令路由
- [x] `s3-2` 触发率监控脚本 — `scripts/trigger-monitor.sh`
  > 25/31 覆盖率 80% 达标，支持 --report/--json/--since 参数
- [ ] `s3-review` Sprint 3 代码审查

---

## 全量验证

- [ ] `bash skills/skill-auditor/scripts/validate-skill.sh skills/ai-dev` 通过质量门禁
- [ ] trigger eval 通过率 ≥ 80%
- [ ] 默认 Profile 注入技能数 ≤ 15
- [ ] `--team` flag 正确触发 v6.0 讨论编排

---

## 变更记录

| 日期 | 变更 | 原因 |
|------|------|------|
| 2026-03-01 | 创建 V1.0 plan/task | 基于讨论汇总生成（讨论：plugin-marketplace-strategy, 2 轮, @PM + @Critic） |
| 2026-03-01 | `s1-1` 标记已完成 | Profile 机制已在 v6.0.6 实现（commit 9bd7264） |
| 2026-03-01 | `s1-2` 标记已完成 | 30→25 Agent：删除 root-cause-analyst/error-detective/feature-planner/task-orchestrator(v1)，能力合并到 debugger/requirement-analyzer |
| 2026-03-02 | `s2-1` 标记已完成 | 31 技能 × 3 个 `<example>` 场景块，审计器限制提升至 3000 chars（commit 214a885） |
| 2026-03-02 | `s2-2` 标记已完成 | Intent Router：Top-K(1-3) + Direct Routing 兜底 + Context Budget 卸载 |
| 2026-03-02 | `s2-3` 标记已完成 | 30 条 trigger eval 用例（should-trigger + should-not-trigger），目标通过率 ≥80% |
| 2026-03-02 | `s2-review` 标记已完成 | 0 P0, 5 P1(已修复): eval触发词冲突、规格文档1024→3000、Router版本标记、eval覆盖率58→68%、Direct Routing补齐 |
| 2026-03-02 | `s3-1` 标记已完成 | Dual Path (Fast/Deep) + ai:team discuss 子命令路由 v6.0 multi-agent-discussion |
| 2026-03-02 | `s3-2` 标记已完成 | trigger-monitor.sh：25/31 覆盖率 80% 达标，支持 --report/--json/--since |
