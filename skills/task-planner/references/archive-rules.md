# 归档条件和流程

本文档定义版本归档的条件、流程和产出。

## 归档条件

版本满足以下**全部**条件时可归档：

### 1. 任务完成度

- task.md 中所有 Sprint 任务标记为 `[x]`（不含注释中的模板行）
- 每个 Sprint 的 `sN-review` 代码审查任务已完成

### 2. 全量验证

- task.md「全量验证」章节中所有检查项标记为 `[x]`
- 验证命令可重复执行并通过

### 3. 状态标记

- task.md frontmatter 的 `status` 字段为 `completed`

### 4. Git 清洁

- 版本相关的所有文件已提交到 Git
- 无暂存区或工作区的未提交变更

## 归档流程

### 预检查

```bash
bash scripts/archive-version.sh --dry-run <version>
```

预检查仅验证归档条件，不执行任何修改。

### 执行归档

```bash
bash scripts/archive-version.sh <version>
```

归档操作按以下步骤执行：

1. **验证归档条件** — 检查上述 4 项条件
2. **生成 ARCHIVED.md** — 在 `docs/tasks/v<VERSION>/` 下创建归档摘要
3. **提取知识** — 生成 `docs/tasks/v<VERSION>/knowledge.md`
4. **更新索引** — 在 `docs/tasks/README.md` 版本索引表中更新状态
5. **标记状态** — 将 task.md frontmatter `status` 改为 `archived`

### 强制归档

```bash
bash scripts/archive-version.sh --force <version>
```

跳过部分条件检查（如 Git 清洁检查），用于特殊情况。

## 归档产出

### ARCHIVED.md 模板

```markdown
# V<VERSION> 归档摘要

- **版本**: v<VERSION>
- **名称**: <NAME>
- **归档日期**: <DATE>
- **Git 范围**: <FIRST_COMMIT>..<LAST_COMMIT>

## 完成概况

- Sprint 数量: <N>
- 任务数量: <TOTAL> (已完成: <DONE>)
- 变更记录条目: <ENTRIES>

## 关键成果

<从 task.md 变更记录中提取的关键条目>

## 学习要点

<从 plan.md ADR 和 task.md review 结论中提取>
```

### knowledge.md 模板

```markdown
# V<VERSION> 知识提取

## 版本概要

- 名称: <NAME>
- 日期: <START_DATE> ~ <ARCHIVE_DATE>
- Git 范围: <FIRST_COMMIT>..<LAST_COMMIT>

## 关键决策

<从 plan.md 的 ADR 记录提取>

## 发现的模式

<从 task.md review 中发现的可复用模式>

## 项目特征变化

<本版本带来的项目能力变化、技术栈更新等>

## 教训

<从 P1/P2 修复中提取的经验教训>
```

## 归档后约束

- 归档版本的 task.md 不应再修改
- 如需调整归档版本的内容，应创建新的 patch 版本（如 v1.0.1）
- 归档目录不移动，保持在 `docs/tasks/v<VERSION>/` 原位

## 脚本位置

归档脚本位于项目根目录 `scripts/archive-version.sh`。
