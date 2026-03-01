# docs/tasks/ — 版本化任务管理

本目录包含项目的版本化任务计划。每个版本目录下有 `plan.md`（设计文档）和 `task.md`（执行看板）。

## 目录结构

```
docs/tasks/
├── README.md           # 本文件：使用指南
├── v1.0/               # 版本 1.0
│   ├── plan.md         # WHY + WHAT + HOW（设计文档）
│   └── task.md         # 唯一状态看板（执行追踪）
├── v2.0/               # 版本 2.0
│   ├── plan.md
│   ├── task.md
│   └── knowledge.md    # 归档时生成：版本知识提取
└── ...
```

## 创建任务计划

有三条路径可以创建版本化的任务计划：

### 路径 A：讨论驱动

适用场景：复杂需求需要多角色评审和讨论。

```
1. /ai:discuss init <topic>        # 初始化讨论空间
2. /ai:discuss invite <topic>      # 邀请角色参与讨论
3. /ai:discuss check <topic>       # 检查讨论进度
4. /ai:discuss summarize <topic>   # 生成任务计划 → docs/tasks/v<X.Y>/
```

task-planner 技能在 summarize 阶段自动调用，生成标准化的 plan.md 和 task.md。

### 路径 B：开发驱动

适用场景：明确的功能需求，通过 ai-dev 工作流推进。

```
/ai:dev <feature-description>      # 启动开发工作流
```

ai-dev 在 Phase 1（需求访谈）后调用 task-planner 生成版本化任务蓝图。

### 路径 C：直接创建

适用场景：快速规划，已有清晰的需求描述。

直接在对话中描述需求：
```
"帮我规划一个用户权限管理模块的任务"
```

task-planner 技能自动触发，评估需求并生成 plan.md + task.md。

## 版本号规则

### 版本号格式

`v<major>.<minor>` — 如 `v1.0`, `v1.3`, `v2.0`

### 判定逻辑

| 条件 | 版本类型 | 示例 |
|------|---------|------|
| 新增独立功能 / 增强优化 / Bug 修复 | minor (+0.1) | v1.0 → v1.1 |
| 架构重构 / 破坏性变更 / 全新方向 | major (+1.0) | v1.3 → v2.0 |

版本号通过以下优先级确定：
1. 用户指定 `--version X.Y`
2. requirement-analyzer 基于复杂度建议
3. 自动递增（扫描现有版本 +0.1）
4. 首次使用默认 `v1.0`

### 拆分策略

当需求过大时（复杂度 > 8/10, 时间 > 21 天, Sprint > 4），task-planner 会建议拆分为多个版本阶段。

详见 `skills/task-planner/references/versioning.md`。

## 执行任务

### 开始工作

1. 阅读 `task.md` 的 YAML frontmatter 了解 Sprint 依赖
2. 按依赖顺序执行任务
3. 完成一项任务后在 task.md 中打勾 `[x]`
4. 在变更记录表中追加条目
5. Git 提交格式：`feat(v<VERSION>/s<N>): <description>`

### Sprint 规则

- 每个 Sprint 末尾有 `sN-review` 代码审查任务
- Sprint 间存在 `depends_on` 依赖时必须顺序执行
- `task.md` 是唯一状态真相，`plan.md` 不含任何勾选状态

### 检查进度

```bash
# 查看所有版本状态
bash skills/task-planner/scripts/check-version-status.sh

# 或使用命令
/ai:status --versions
```

## 归档

### 归档条件

版本满足以下**全部**条件时可归档：

1. task.md 中所有 Sprint 任务标记为 `[x]`
2. 全量验证项全部通过
3. task.md frontmatter `status: completed`
4. Git 中无未提交的相关变更

### 归档操作

```bash
# 预检查
bash scripts/archive-version.sh --dry-run v1.0

# 执行归档
bash scripts/archive-version.sh v1.0
```

归档后生成：
- `ARCHIVED.md` — 归档摘要
- `knowledge.md` — 版本知识提取（关键决策、模式、学习要点）

## 版本索引

| 版本 | 名称 | 状态 | 说明 |
|------|------|------|------|
| v1.0 | 插件市场产品策略优化 | completed | Profile 按需加载 + 触发优化 + 监控 |
