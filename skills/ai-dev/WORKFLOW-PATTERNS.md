# AI Orchestrator - 工作流模板库

本文档包含AI Orchestrator支持的所有标准工作流模板。每个模板针对特定的任务类型进行优化。

## 模板概览

| 任务意图 | 工作流名称 | Phases | 典型时长 | 并行化 |
|---------|----------|--------|---------|--------|
| FEATURE_DEVELOPMENT | 功能开发 | 4 | 5-15天 | 高 |
| BUG_FIXING | 快速修复 | 3 | 1小时 | 低 |
| CODE_REVIEW | 代码审查 | 2 | 0.5-2天 | 中 |
| ARCHITECTURE_DESIGN | 架构设计 | 3 | 3-7天 | 中 |
| OPTIMIZATION | 性能优化 | 4 | 2-5天 | 中 |
| REFACTORING | 重构 | 4 | 2-8天 | 中 |
| TESTING | 测试开发 | 3 | 1-4天 | 高 |
| PROJECT_SETUP | 项目初始化 | 2 | 0.5-1天 | 低 |

---

## 1. 功能开发工作流 (FEATURE_DEVELOPMENT)

**适用场景**: 新功能开发、功能增强

### Phase 1: 需求分析 (10% 时间)
- **Agents**: requirement-analyzer (并行)
- **目标**: 明确需求、定义验收标准
- **输出**: requirements.md, user-stories.md, acceptance-criteria.md
- **质量门禁**: 需求清晰度检查

### Phase 2: 架构设计 (30% 时间)
- **Agents**: backend-architect, frontend-developer (并行)
- **依赖**: Phase 1
- **目标**: 设计API和UI架构
- **输出**: api-design.md, component-design.md, database-schema.sql
- **质量门禁**: 架构review

### Phase 3: 实现开发 (40% 时间)
- **Agents**: api-helper, frontend-developer (并行)
- **依赖**: Phase 2
- **目标**: 实现功能代码
- **输出**: 源代码、组件、API endpoints
- **约束**: 
  - 单次修改 ≤ 150行
  - 单个PR ≤ 8文件
  - 函数 ≤ 30行

### Phase 4: 质量保障 (20% 时间)
- **Agents**: code-reviewer, test-automator (并行)
- **依赖**: Phase 3
- **目标**: 确保代码质量和测试覆盖
- **输出**: review-report.md, test-results.md, coverage-report
- **强制执行**: 必须通过才能合并

---

## 2. 快速修复工作流 (BUG_FIXING)

**适用场景**: 简单bug修复、hotfix

### Phase 1: 问题诊断 (25% 时间，15分钟上限)
- **Agents**: debugger, quick-fixer (串行)
- **目标**: 定位问题根源
- **输出**: diagnosis.md

### Phase 2: 快速修复 (50% 时间，30分钟上限)
- **Agents**: quick-fixer
- **依赖**: Phase 1
- **目标**: 修复bug
- **约束**:
  - 修改文件 ≤ 3个
  - 修改行数 ≤ 50行
- **输出**: 修复代码

### Phase 3: 验证测试 (25% 时间，10分钟上限)
- **Agents**: test-automator
- **依赖**: Phase 2
- **目标**: 验证修复效果
- **输出**: test-results.md
- **强制执行**: 必须通过

---

## 3. 代码审查工作流 (CODE_REVIEW)

**适用场景**: PR审查、代码质量检查

### Phase 1: 静态分析 (40% 时间)
- **Agents**: code-reviewer
- **目标**: 检测代码坏味道
- **输出**: code-smells-report.md, quality-score

### Phase 2: 深度审查 (60% 时间)
- **Agents**: code-reviewer, code-mentor (串行)
- **依赖**: Phase 1
- **目标**: 深度审查和改进建议
- **输出**: review-report.md, improvement-suggestions.md

---

## 4. 架构设计工作流 (ARCHITECTURE_DESIGN)

**适用场景**: 系统架构设计、技术选型

### Phase 1: 需求分析 (20% 时间)
- **Agents**: backend-architect, requirement-analyzer (并行)
- **目标**: 理解架构需求和约束
- **输出**: architecture-requirements.md

### Phase 2: 方案设计 (50% 时间)
- **Agents**: backend-architect, frontend-developer (并行)
- **依赖**: Phase 1
- **目标**: 设计多个架构方案
- **输出**: architecture-options.md, diagrams/

### Phase 3: 方案评估 (30% 时间)
- **Agents**: backend-architect, quality-guardian (串行)
- **依赖**: Phase 2
- **目标**: 评估和选择最优方案
- **输出**: architecture-decision-record.md

---

## 5. 性能优化工作流 (OPTIMIZATION)

**适用场景**: 性能瓶颈优化、资源优化

### Phase 1: 性能分析 (25% 时间)
- **Agents**: debugger (并行)
- **目标**: 识别性能瓶颈
- **输出**: performance-analysis.md, bottlenecks.md

### Phase 2: 优化方案 (30% 时间)
- **Agents**: typescript-pro, javascript-pro, backend-architect (根据需要)
- **依赖**: Phase 1
- **目标**: 设计优化方案
- **输出**: optimization-plan.md

### Phase 3: 实施优化 (30% 时间)
- **Agents**: api-helper, frontend-developer (根据需要)
- **依赖**: Phase 2
- **目标**: 实施优化代码
- **输出**: 优化后的代码

### Phase 4: 效果验证 (15% 时间)
- **Agents**: test-automator, code-reviewer (并行)
- **依赖**: Phase 3
- **目标**: 验证优化效果
- **输出**: performance-benchmark.md, comparison-report

---

## 6. 重构工作流 (REFACTORING)

**适用场景**: 代码重构、技术债务清理

### Phase 1: 坏味道识别 (20% 时间)
- **Agents**: code-reviewer
- **目标**: 识别代码坏味道
- **输出**: code-smells.md, refactoring-targets.md

### Phase 2: 重构规划 (25% 时间)
- **Agents**: backend-architect, frontend-developer (根据范围)
- **依赖**: Phase 1
- **目标**: 制定重构计划
- **输出**: refactoring-plan.md

### Phase 3: 实施重构 (40% 时间)
- **Agents**: api-helper, frontend-developer (根据需要)
- **依赖**: Phase 2
- **目标**: 执行重构
- **约束**: 保持功能不变
- **输出**: 重构后的代码

### Phase 4: 验证和审查 (15% 时间)
- **Agents**: test-automator, code-reviewer (并行)
- **依赖**: Phase 3
- **目标**: 确保功能无回归
- **输出**: test-results.md, review-report.md
- **强制执行**: 必须通过

---

## 7. 测试开发工作流 (TESTING)

**适用场景**: 测试编写、测试覆盖率提升

### Phase 1: 测试规划 (20% 时间)
- **Agents**: test-automator, requirement-analyzer
- **目标**: 设计测试策略
- **输出**: test-plan.md, test-cases.md

### Phase 2: 单元测试 (40% 时间)
- **Agents**: test-automator, typescript-pro (根据需要)
- **依赖**: Phase 1
- **目标**: 编写单元测试
- **输出**: *.test.ts文件

### Phase 3: 集成测试 (40% 时间)
- **Agents**: test-automator
- **依赖**: Phase 2
- **目标**: 编写集成和E2E测试
- **输出**: integration-tests/, e2e-tests/

---

## 8. 项目初始化工作流 (PROJECT_SETUP)

**适用场景**: 新项目创建、长运行项目初始化

### Phase 1: 环境设置 (40% 时间)
- **Agents**: project-initializer (Skill)
- **目标**: 创建项目结构和配置
- **输出**: 项目骨架、配置文件、codebox/

### Phase 2: 初始化验证 (60% 时间)
- **Agents**: project-initializer, project-doctor
- **依赖**: Phase 1
- **目标**: 验证项目健康状态
- **输出**: project-health-report.md

---

## 长运行项目工作流增强

当检测到长运行项目模式时（codebox/存在），所有工作流都会添加以下增强：

### 前置Phase: 上下文恢复
- **Agent**: session-manager (Skill)
- **执行时机**: 任何工作流开始前
- **目标**: 恢复项目状态和进度
- **输出**: session-recovery-report.md

### 增量开发约束
每个实现Phase添加：
- **ONE FEATURE AT A TIME强制执行**
- **Feature选择**: 从feature_list.json自动选择
- **依赖检查**: 确保前置特性已完成
- **状态追踪**: 完成后更新passes=true

### 后置Phase: 状态更新
- **Agent**: session-manager (Skill)
- **执行时机**: 工作流完成后
- **目标**: 更新项目状态
- **输出**: 
  - 更新feature_list.json (passes=true)
  - 追加progress.txt
  - Git commit

---

## 工作流自定义规则

### 并行执行条件
两个agents可以并行执行当：
1. 无数据依赖
2. 操作不同的文件/模块
3. 能力互补（如前端+后端）

### 串行执行条件
必须串行执行当：
1. 有明确的数据依赖
2. 需要前一步输出作为输入
3. 修改相同的文件

### 质量门禁插入规则
在以下情况自动插入质量门禁：
1. 代码实现Phase之后
2. 重构Phase之后
3. 优化Phase之后
4. 用户明确要求时

---

## 模板选择算法

```typescript
function selectWorkflowTemplate(
  intent: TaskIntent,
  complexity: ComplexityLevel,
  isLongRunning: boolean
): WorkflowTemplate {
  // 1. 基于意图选择基础模板
  let template = WORKFLOW_TEMPLATES[intent];
  
  // 2. 根据复杂度调整
  if (complexity === 'simple') {
    template = simplifyTemplate(template);
  } else if (complexity === 'complex') {
    template = enhanceTemplate(template);
  }
  
  // 3. 长运行项目增强
  if (isLongRunning) {
    template = addLongRunningEnhancements(template);
  }
  
  return template;
}
```

---

## 性能优化策略

- **并行最大化**: 自动识别可并行的phases
- **早期失败**: Phase失败立即终止
- **增量执行**: 长运行项目按特性增量执行
- **缓存复用**: 复用之前phases的输出

---

**注**: 模板会根据实际任务动态调整和优化。
