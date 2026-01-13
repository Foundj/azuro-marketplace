# Parallel Execution Mode

> Wave → Checkpoint → Wave 并行执行模式规范

## 概述

并行执行模式允许在适当的场景下同时启动多个 Agent，提高开发效率。本文档定义并行执行的条件、实现方式和最佳实践。

## 触发方式

### 1. 显式触发

```bash
ai implement feature --parallel    # 英文标记
ai 开发功能 并行                   # 中文关键词
ai ulw implement feature           # Ultrawork 模式（隐含并行）
```

### 2. 自动判断

系统根据任务特性自动判断是否启用并行：

| 条件 | 并行 | 原因 |
|------|------|------|
| 无数据依赖 | ✅ | 任务独立，可并行 |
| 不同文件/模块 | ✅ | 无冲突风险 |
| 互补能力 | ✅ | 多视角分析 |
| 需要前序输出 | ❌ | 存在依赖 |
| 修改同一文件 | ❌ | 冲突风险 |
| 显式数据依赖 | ❌ | 必须串行 |

---

## Wave → Checkpoint → Wave 模式

```
┌─────────────────────────────────────────────────────────────┐
│                    PARALLEL EXECUTION FLOW                   │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Wave 1 (并行读取)                                          │
│  ┌──────────────┬──────────────┬──────────────┐            │
│  │ @explore-fast│ @librarian   │ @oracle      │            │
│  │ 项目结构     │ 知识查询     │ 复杂度分析   │            │
│  └──────┬───────┴──────┬───────┴──────┬───────┘            │
│         │              │              │                     │
│         └──────────────┼──────────────┘                     │
│                        ↓                                    │
│  Checkpoint 1 (同步点)                                      │
│  - 合并所有 Agent 输出                                      │
│  - 分析结果，决定下一步                                     │
│         │                                                   │
│         ↓                                                   │
│  Wave 2 (并行设计)                                          │
│  ┌──────────────┬──────────────┐                           │
│  │ code-architect│ code-explorer│                          │
│  │ 架构设计     │ 实现路径     │                           │
│  └──────┬───────┴──────┬───────┘                           │
│         │              │                                    │
│         └──────────────┘                                    │
│                        ↓                                    │
│  Checkpoint 2 (同步点)                                      │
│  - 整合设计方案                                             │
│  - 生成 design.md                                           │
│         │                                                   │
│         ↓                                                   │
│  Wave 3 (并行实现) - 可选                                   │
│  - 仅当模块足够独立时                                       │
│  - 否则串行执行                                             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Task 工具并行调用模板

在单条消息中发送多个 Task 工具调用以实现真正的并行执行：

### 基本模板

```markdown
发送单个消息，包含多个 Task 工具调用：

Task 1: subagent_type=Explore, description="探索项目结构"
Task 2: subagent_type=ai-dev:code-explorer, description="分析实现路径"
Task 3: subagent_type=ai-dev:code-architect, description="设计架构方案"
```

### Phase 2 设计阶段并行

```yaml
parallel_tasks:
  - agent: code-architect
    focus: "API 设计和数据流"
  - agent: code-explorer
    focus: "现有代码模式和约束"
  - agent: "@oracle"
    focus: "架构决策和权衡"
```

### Phase 4 实现阶段并行

```yaml
parallel_tasks:
  - agent: api-helper
    focus: "后端 API 实现"
    files: ["src/api/**"]
  - agent: frontend-developer
    focus: "前端组件实现"
    files: ["src/components/**"]
```

---

## 并行执行条件判断

### 可并行的场景

1. **多视角分析**
   - 代码审查 + 安全扫描 + 性能分析
   - 需求分析 + 竞品研究 + 技术评估

2. **独立模块开发**
   - 前端 + 后端（API 契约已定义）
   - 多个独立组件

3. **信息收集**
   - 项目结构扫描 + 知识库查询 + 文档读取

### 必须串行的场景

1. **数据依赖**
   - 需要前一步的输出作为输入
   - 例：先读取配置，再修改配置

2. **同一文件操作**
   - 多个 Agent 需要修改同一文件
   - 避免冲突和覆盖

3. **决策依赖**
   - 后续步骤取决于前一步的决定
   - 例：先确定方案，再实现

---

## 结果合并规范

### Checkpoint 同步流程

```python
def checkpoint_sync(wave_results):
    """
    同步并合并一个 Wave 的所有 Agent 输出
    """
    # 1. 等待所有 Agent 完成
    all_outputs = await gather_all(wave_results)

    # 2. 合并结果
    merged = {
        "insights": combine_insights(all_outputs),
        "files_identified": dedupe_files(all_outputs),
        "recommendations": prioritize_recommendations(all_outputs),
        "conflicts": detect_conflicts(all_outputs)
    }

    # 3. 解决冲突
    if merged["conflicts"]:
        resolved = resolve_conflicts(merged["conflicts"])
        merged["recommendations"] = apply_resolutions(merged["recommendations"], resolved)

    # 4. 生成下一阶段输入
    return prepare_next_wave_input(merged)
```

### 冲突解决策略

| 冲突类型 | 解决方式 |
|----------|----------|
| 相同文件的不同建议 | 合并或选择更优方案 |
| 架构方案冲突 | 提交用户决策 |
| 优先级不一致 | 按任务重要性排序 |

---

## 与 ai-dev 工作流集成

### Phase 0: Context & Knowledge (高度并行)

```yaml
wave_1:
  parallel:
    - "@explore-fast": "扫描项目结构"
    - "@librarian": "查询知识库"
    - "competitor-research": "竞品分析" (if enabled)
  checkpoint:
    - 合并上下文
    - 生成 context-summary.md
```

### Phase 2: Design Approval (部分并行)

```yaml
wave_1:
  parallel:
    - "code-architect": "方案 A 设计"
    - "code-architect": "方案 B 设计"
  checkpoint:
    - 对比方案
    - 用户选择
```

### Phase 4: Implementation (条件并行)

```yaml
condition: 模块是否独立
if_independent:
  parallel:
    - "api-helper": "后端实现"
    - "frontend-developer": "前端实现"
else:
  serial:
    - "code-explorer": "分析依赖"
    - "quick-fixer": "实现核心功能"
    - "test-automator": "编写测试"
```

### Phase 5: Quality Validation (高度并行)

```yaml
wave_1:
  parallel:
    - "code-reviewer": "安全审查"
    - "code-reviewer": "代码质量"
    - "code-reviewer": "可维护性"
  checkpoint:
    - 合并审查报告
    - confidence-scorer 过滤
```

---

## 配置

### FLAGS.md 中的定义

```markdown
| 标记 | 行为 |
|------|------|
| `--parallel` | 启用并行执行模式 |
| `并行` | 中文触发词 |
| `ulw` | Ultrawork 模式（隐含并行） |
```

### keyword-detector.sh 检测

```bash
# 添加 --parallel 检测
if echo "$PROMPT_LOWER" | grep -qE '(--parallel|并行|parallel)'; then
    MODE="parallel"
    INJECTION="[Parallel Mode 已激活]

并行执行策略:
1. 识别可并行的任务
2. 在同一消息中发送多个 Task 工具调用
3. 使用 Checkpoint 同步结果
4. 合并输出继续下一阶段"
fi
```

---

## 性能预期

| 场景 | 串行时间 | 并行时间 | 提升 |
|------|----------|----------|------|
| 多视角代码审查 | 3x T | T | 3x |
| 前后端并行开发 | 2x T | T | 2x |
| 信息收集阶段 | 3x T | T | 3x |
| 全流程（适度并行） | 10x T | 4x T | 2.5x |

---

## 最佳实践

1. **优先并行读取操作** - 读取文件、查询知识库等只读操作最适合并行
2. **谨慎并行写入操作** - 确保不同 Agent 操作不同文件
3. **使用 Checkpoint 同步** - 每个 Wave 后进行结果合并
4. **处理冲突** - 检测并解决 Agent 输出的冲突
5. **监控上下文使用** - 并行 Agent 会增加上下文消耗

---

## 版本历史

| 版本 | 日期 | 变更 |
|------|------|------|
| 1.0.0 | 2026-01-14 | 初始版本：Wave-Checkpoint 模式 |
