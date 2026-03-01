# AI Orchestrator - Agents 能力注册表

本文档包含 AI Orchestrator 系统中所有 agents 的完整能力描述、触发条件和使用场景。

---

## 📊 实现状态概览

### ✅ 已实现 Agents (12个)

| Agent | 文件 | 阶段 | 用途 |
|-------|------|------|------|
| `requirement-interviewer` | ✅ `agents/requirement-interviewer.md` | Phase 1 | 多轮需求采访 |
| `requirement-analyzer` | ✅ `agents/requirement-analyzer.md` | Phase 1 | 需求分析和功能规划 |
| `code-explorer` | ✅ `agents/code-explorer.md` | Phase 2 | 代码库深度探索 |
| `code-architect` | ✅ `agents/code-architect.md` | Phase 3 | 架构设计方案 |
| `task-decomposer` | ✅ `agents/task-decomposer.md` | Phase 3 | 任务分解和协作规划 |
| `verification-agent` | ✅ `agents/verification-agent.md` | Phase 4-5 | 自我验证 |
| `code-reviewer` | ✅ `agents/quality/code-reviewer.md` | Phase 5 | 代码审查 |
| `confidence-scorer` | ✅ `agents/quality/confidence-scorer.md` | Phase 5 | 置信度评分 |
| `quick-fixer` | ✅ `agents/quick-fixer.md` | Quick Fix | 快速 bug 修复 |
| `debugger` | ✅ `agents/debugger.md` | 调试 | 深度问题诊断 |
| `api-helper` | ✅ `agents/api-helper.md` | 开发 | API 开发和后端实现 |
| `test-automator` | ✅ `agents/test-automator.md` | Phase 5 | 测试自动化 |

### 📋 规划中 Agents (8个)

> 以下 agents 已设计能力描述，但尚未创建独立文件。
> 可根据需要逐步实现。

| 分类 | Agent | 状态 |
|------|-------|------|
| 🔄 工作流管理 | task-orchestrator-v2 | 📋 规划中 |
| 🔄 工作流管理 | sprint-manager | 📋 规划中 |
| 🔄 工作流管理 | requirement-analyzer | 📋 规划中 |
| 🔄 工作流管理 | ooda-manager | 📋 规划中 |
| 🏗️ 架构开发 | backend-architect | 📋 规划中 |
| 🏗️ 架构开发 | frontend-developer | 📋 规划中 |
| 🎯 质量保障 | code-mentor | 📋 规划中 |
| 🎯 质量保障 | quality-guardian | 📋 规划中 |

---

## 注册表详情

### 分类概览

| 分类 | Agent数量 | 主要职责 |
|------|----------|---------| 
| 🔄 工作流管理 | 5 | 需求分析、任务规划、Sprint管理 |
| 🔍 代码探索 | 1 | 深度代码库理解、架构探索 |
| 🏗️ 架构开发 | 3 | 架构设计、后端开发、前端开发 |
| 🛠️ 开发助手 | 4 | API开发、Bug修复、调试、测试 |
| 🎯 质量保障 | 4 | 代码审查、置信度评分、质量守护、指导教学 |
| 🔤 语言专家 | 1 | TypeScript优化 |

**总计**: 20个专业agents（12个已实现，8个规划中）

---

## 🔄 工作流管理 (6个)

---

### 2. task-orchestrator-v2
**任务分析和Sprint规划专家 (Sequential Thinking 版本)**

**适用意图**:
- `FEATURE_DEVELOPMENT`
- `PROJECT_SETUP`
- `PLANNING`

**关键词触发**:
- 任务、规划、管理、Sprint、计划、协调

**复杂度**: Medium → Complex

**核心能力**:
- `task_management` - 任务管理和追踪
- `sprint_planning` - Sprint周期规划
- `coordination` - 团队协调
- `capacity_planning` - 容量规划
- `milestone_tracking` - 里程碑追踪

**典型使用场景**:
```
用户: "帮我规划这个月的开发任务"
→ task-orchestrator分析项目
→ 输出: sprint-plan.md, task-breakdown.md, timeline.md
```

**时间估算**: 1-2天

---

### 3. sprint-manager
**21天Sprint周期管理专家**

**适用意图**:
- `PLANNING`
- `PROJECT_SETUP`

**关键词触发**:
- Sprint、21天、周期、管理、进度、交付、迭代

**复杂度**: Medium → Complex

**核心能力**:
- `sprint_management` - Sprint周期管理
- `cycle_planning` - 迭代周期规划
- `milestone_tracking` - 里程碑追踪
- `delivery_management` - 交付管理
- `scope_control` - 范围控制和蔓延防护

**典型使用场景**:
```
用户: "启动新的Sprint周期"
→ sprint-manager设置Sprint
→ 输出: sprint-goals.md, 3-week-plan.md, checkpoints.md
```

**特殊约束**:
- 严格21天周期
- 三周节奏：探索(Week 1) → 开发(Week 2) → 交付(Week 3)
- 范围蔓延控制

**时间估算**: 1-2天（设置），21天（执行周期）

---

### 4. requirement-analyzer
**需求分析、功能规划和可行性评估专家**

**适用意图**:
- `PLANNING`
- `FEATURE_DEVELOPMENT`
- `PROJECT_SETUP`

**关键词触发**:
- 功能、需求、规划、分析、设计、实现、评估、可行性、范围、验收

**复杂度**: Simple → Medium → Complex

**核心能力**:
- `requirement_analysis` - 深度需求分析和澄清
- `task_breakdown` - 任务分解和拆分
- `planning` - 实施计划制定
- `risk_assessment` - 风险识别和评估
- `milestone_definition` - 里程碑定义
- `feasibility_assessment` - 可行性评估（21天Sprint）
- `scope_definition` - 范围定义
- `acceptance_criteria` - 验收标准制定
- `rejection_handling` - 不合理需求拒绝

**典型使用场景**:
```
用户: "构建一个完整的电商平台"
→ requirement-analyzer评估可行性
→ 输出: ❌ 超出21天Sprint限制
→ 推荐: MVP版本或分阶段实施
```

**特殊功能**:
- 21天可行性评估
- 自动拒绝超范围需求
- MVP建议

**时间估算**: 1-3天

---

### 5. ooda-manager
**OODA循环快速迭代管理专家**

**适用意图**:
- `OPTIMIZATION`
- `PLANNING`
- `QUICK_VALIDATION`

**关键词触发**:
- OODA、快速、迭代、循环、敏捷、验证、1小时

**复杂度**: Simple → Medium

**核心能力**:
- `rapid_iteration` - 快速迭代
- `ooda_loop` - OODA循环（Observe-Orient-Decide-Act）
- `fast_feedback` - 快速反馈
- `quick_validation` - 快速验证
- `pivot_decision` - 快速调整决策

**典型使用场景**:
```
用户: "快速验证这个设计方案"
→ ooda-manager执行1小时循环
→ 输出: 观察结果 → 分析定位 → 决策建议 → 行动计划
```

**特殊约束**:
- 1小时时间限制
- 小步快跑
- 频繁验证

**时间估算**: 0.1-1天（1小时为一个循环）

---

### 6. task-decomposer
**任务分解和协作规划专家**

**适用意图**:
- `PLANNING`
- `FEATURE_DEVELOPMENT`

**关键词触发**:
- 任务、分解、拆分、细化、协作、分工

**复杂度**: Medium → Complex

**核心能力**:
- `task_breakdown` - 任务分解
- `work_decomposition` - 工作拆解
- `task_planning` - 任务规划
- `collaboration_design` - 协作设计
- `dependency_analysis` - 依赖关系分析

**典型使用场景**:
```
用户: "将这个大功能拆分成可执行的任务"
→ task-decomposer分解任务
→ 输出: 50-200+个可测试的子任务，包含依赖关系
```

**时间估算**: 1-2天

---

## 🔍 代码探索 (1个)

### 7. code-explorer
**代码库深度分析和架构理解专家（Phase 2专用）**

**适用意图**:
- `CODEBASE_EXPLORATION`
- `ARCHITECTURE_ANALYSIS`
- `FEATURE_DEVELOPMENT` (Phase 2 Discovery)

**关键词触发**:
- 探索、分析、理解、代码库、架构、现有、依赖

**复杂度**: Medium → Complex

**核心能力**:
- `codebase_exploration` - 代码库深度探索
- `architecture_mapping` - 架构映射和理解
- `pattern_discovery` - 模式识别和发现
- `dependency_analysis` - 依赖关系分析
- `execution_tracing` - 执行路径追踪
- `context_building` - 上下文构建

**Phase 2 专用工作流**:
1. **执行路径追踪** - 从入口点追踪完整调用链
2. **架构层次映射** - 理解presentation/application/domain/infrastructure分层
3. **模式和抽象识别** - 识别Repository/Service/Factory等模式
4. **依赖和边界分析** - 分析模块依赖和集成点
5. **现有实现发现** - 查找可复用代码和相似功能

**典型使用场景**:
```
Phase 2 (Discovery): "理解现有用户认证实现"
→ code-explorer (2-3 agents并行，不同视角)
→ 输出: evidence.md (深度分析报告)
  - 执行路径图
  - 架构层次说明
  - 模式和抽象总结
  - 依赖关系图
  - 复用建议
```

**多agent策略**:
- 2-3个code-explorer并行执行
- 不同起点和视角（如：API层、数据层、业务层）
- 综合多个视角的发现

**关键原则**:
- ✅ 深度优先：追踪完整调用链，不止步于表面
- ✅ 模式识别：识别设计模式和架构抽象
- ✅ 依赖映射：理解模块间的集成和依赖
- ✅ 实用发现：聚焦可复用代码和相似实现

**输出格式**: evidence.md (结构化发现报告)

**时间估算**: 1-3天

---

## 🏗️ 架构开发 (3个)

### 8. code-architect
**架构设计和实施蓝图专家（Phase 3专用）**

**适用意图**:
- `ARCHITECTURE_DESIGN`
- `FEATURE_DEVELOPMENT` (Phase 3 Design)

**关键词触发**:
- 设计、架构、蓝图、方案、技术选型、组件

**复杂度**: Medium → Complex

**核心能力**:
- `architecture_design` - 架构方案设计
- `pattern_application` - 设计模式应用
- `component_design` - 组件设计
- `data_flow_design` - 数据流设计
- `integration_planning` - 集成规划
- `blueprint_creation` - 实施蓝图创建

**Phase 3 专用工作流**:
1. **分析现有模式** - 基于evidence.md理解现有架构
2. **设计组件架构** - 设计符合现有模式的组件
3. **数据流设计** - 设计数据在各层间的流动
4. **集成点规划** - 规划与现有系统的集成
5. **实施蓝图** - 创建详细的实施计划

**典型使用场景**:
```
Phase 3 (Design): "设计用户认证功能架构"
→ code-architect (2-3 agents并行，不同方案)
→ 输出: design.md (实施蓝图)
  - 架构组件图
  - 数据流图
  - 文件清单（创建/修改）
  - 实施步骤序列
  - 技术选型说明
```

**多agent策略**:
- 2-3个code-architect并行执行
- 提供不同架构方案（如：方案A vs 方案B）
- 对比权衡，推荐最佳方案

**关键原则**:
- ✅ 遵循现有模式：与代码库现有架构保持一致
- ✅ 具体可执行：提供明确的文件和步骤清单
- ✅ 数据流清晰：明确数据在各层间的流动
- ✅ 集成明确：清楚说明与现有系统的集成点

**输出格式**: design.md (实施蓝图文档)

**时间估算**: 2-4天

---

### 9. verification-agent
**自我验证和质量门禁专家** (NEW in v2.0)

**适用意图**:
- `QUALITY_VALIDATION`
- `PHASE_VERIFICATION`
- `SELF_CHECK`

**关键词触发**:
- verify, validation, check quality, self-check
- phase complete, gate check, verification
- tests pass, build success, quality assurance

**核心能力**:
- **Phase 4验证**: 检查tasks.md完成、测试通过、构建成功、lint清洁、类型检查
- **Phase 5验证**: 检查issues处理、修复后测试、无新问题引入
- **自动质量门禁**: 阻止有问题的phase转换
- **State验证**: 确保state.json正确更新

**工具**: Read, Bash, Grep, Glob

**输入**: changeId, verificationType (phase4/phase5/cross-phase)

**输出**:
```typescript
{
  passed: boolean,
  report: string,
  failedChecks: {
    name: string,
    message: string
  }[]
}
```

**使用场景**:
1. **自动触发** (via post-phase-verify hook): Phase 4/5完成后
2. **手动触发**: 用户请求验证 (e.g., "/verify", "check if everything works")
3. **Phase门禁**: validatePhase4/5Completion()调用

**关键特性**:
- ✅ 运行实际命令 (npm test, build, lint)
- ✅ 检查state.json一致性
- ✅ 提供具体、可执行的错误信息
- ✅ 使用haiku模型（快速且经济）
- ✅ 阻止不合格代码进入下一phase

**文档**: `${CLAUDE_PLUGIN_ROOT}/skills/ai-dev/agents/verification-agent.md`

**集成点**:
- `/hooks/post-phase-verify.md` - Stop hook自动触发
- `/SKILL.md` - validatePhase4/5Completion()显式调用
- `ralph-wiggum OODA loop` - 自我验证循环

---

### 10. backend-architect
**后端架构和系统设计专家**

**适用意图**:
- `ARCHITECTURE_DESIGN`
- `API_DEVELOPMENT`

**关键词触发**:
- 架构、设计、后端、系统、数据库、扩展、微服务

**复杂度**: Medium → Complex

**核心能力**:
- `system_design` - 系统架构设计
- `architecture_planning` - 架构规划
- `scalability` - 扩展性设计
- `database_design` - 数据库设计
- `api_architecture` - API架构
- `performance_design` - 性能设计

**典型使用场景**:
```
用户: "设计一个可扩展的用户服务架构"
→ backend-architect设计架构
→ 输出: architecture-diagram.md, database-schema.sql, api-spec.md
```

**技术栈专长**:
- Hono framework
- Drizzle ORM
- Node.js / Bun
- PostgreSQL / MySQL

**时间估算**: 2-5天

---

### 11. frontend-developer
**React/Next.js前端开发专家**

**适用意图**:
- `UI_IMPLEMENTATION`
- `FEATURE_DEVELOPMENT`

**关键词触发**:
- 前端、界面、组件、React、UI、用户、页面、Next.js

**复杂度**: Simple → Medium → Complex

**核心能力**:
- `ui_implementation` - UI实现
- `component_development` - React组件开发
- `user_experience` - 用户体验设计
- `react_development` - React/Next.js开发
- `responsive_design` - 响应式设计
- `state_management` - 状态管理（Zustand）

**典型使用场景**:
```
用户: "实现一个用户资料编辑页面"
→ frontend-developer开发UI
→ 输出: ProfileEdit.tsx, styles.module.css, tests
```

**技术栈专长**:
- React + Next.js
- Shadcn/ui组件库
- Tailwind CSS
- Zustand状态管理

**时间估算**: 1-4天

---

## 🛠️ 开发助手 (4个)

### 12. api-helper
**API开发和后端实现专家**

**适用意图**:
- `API_DEVELOPMENT`
- `FEATURE_DEVELOPMENT`

**关键词触发**:
- API、接口、服务、后端、Hono、RESTful、GraphQL

**复杂度**: Simple → Medium → Complex

**核心能力**:
- `api_design` - API设计
- `backend_implementation` - 后端实现
- `database_integration` - 数据库集成
- `authentication` - 认证授权
- `api_documentation` - API文档

**典型使用场景**:
```
用户: "实现用户登录API"
→ api-helper实现接口
→ 输出: /api/auth/login endpoint, middleware, tests
```

**技术栈专长**:
- Hono framework
- Drizzle ORM
- JWT authentication
- RESTful API设计

**时间估算**: 0.5-3天

---

### 13. quick-fixer
**快速问题解决专家（<30分钟）**

**适用意图**:
- `BUG_FIXING`
- `TROUBLESHOOTING`

**关键词触发**:
- bug、修复、错误、问题、快速、简单、临时

**复杂度**: Simple only

**核心能力**:
- `bug_fixing` - 快速bug修复
- `quick_patch` - 临时补丁
- `simple_features` - 简单功能实现
- `hotfix` - 紧急修复

**典型使用场景**:
```
用户: "登录按钮点击没反应"
→ quick-fixer快速定位和修复
→ 输出: 修复代码（≤50行，≤3文件）
```

**严格约束**:
- 时间限制：30分钟内
- 文件限制：≤3个文件
- 行数限制：≤50行修改
- 复杂度：仅Simple任务

**时间估算**: 0.1-0.5小时

---

### 14. debugger
**深度调试和问题诊断专家**

**适用意图**:
- `TROUBLESHOOTING`
- `BUG_FIXING`

**关键词触发**:
- 调试、诊断、错误、问题、故障、异常、trace、定位

**复杂度**: Medium → Complex

**核心能力**:
- `error_diagnosis` - 错误诊断
- `deep_debugging` - 深度调试
- `problem_solving` - 问题解决
- `log_analysis` - 日志分析
- `stack_trace_analysis` - 堆栈追踪分析

**典型使用场景**:
```
用户: "用户登录后偶尔出现权限错误"
→ debugger深度调查
→ 输出: 根本原因分析、修复方案、预防建议
```

**时间估算**: 1-4天

---

### 15. test-automator
**测试自动化和质量保证专家**

**适用意图**:
- `TESTING`
- `QUALITY_ASSURANCE`

**关键词触发**:
- 测试、自动化、单元测试、集成测试、覆盖率、quality

**复杂度**: Simple → Medium → Complex

**核心能力**:
- `test_automation` - 测试自动化
- `unit_testing` - 单元测试
- `integration_testing` - 集成测试
- `e2e_testing` - 端到端测试
- `test_coverage` - 测试覆盖率分析

**典型使用场景**:
```
用户: "为用户认证模块添加测试"
→ test-automator编写测试
→ 输出: auth.test.ts, integration-tests/, coverage-report
```

**时间估算**: 1-3天

---

## 🎯 质量保障 (4个)

### 17. code-reviewer
**代码审查和坏味道检测专家（强制）**

**适用意图**:
- `CODE_REVIEW`
- `OPTIMIZATION`

**关键词触发**:
- 审查、检查、质量、优化、重构、review

**复杂度**: Simple → Medium → Complex

**核心能力**:
- `code_review` - 全面代码审查
- `quality_analysis` - 质量分析
- `best_practices` - 最佳实践检查
- `code_smell_detection` - 代码坏味道检测

**坏味道检测系统**:
- 设计层面：godClass, longMethod, featureEnvy, dataClumps
- 实现层面：duplicatedCode, deadCode, magicNumbers, complexConditionals
- 命名问题：unclearNaming, inconsistentNaming, abbreviations
- 性能问题：n+1Query, unnecessaryLoops, memoryLeaks

**审查标准**:
- 函数长度 ≤ 30行（目标）
- 类大小 ≤ 300行（目标）
- 圈复杂度 ≤ 10
- 嵌套深度 ≤ 4层
- 参数数量 ≤ 5个

**审查优先级**:
- 🔴 Critical: 安全漏洞、内存泄漏、语法错误
- 🟡 Warning: 代码坏味道、设计问题、可维护性
- 🔵 Info: 命名优化、注释完善、小重构建议

**典型使用场景**:
```
用户: （完成功能后自动触发）
→ code-reviewer审查代码
→ 输出: review-report.md（包含问题列表、改进建议、质量评分）
```

**强制执行**: 
- ✅ 每个feature完成后自动触发
- ✅ 代码质量门禁
- ✅ Mandatory agent

**时间估算**: 0.5-2天

---

### 18. confidence-scorer
**置信度评分和问题过滤专家（Phase 5专用）**

**适用意图**:
- `QUALITY_ASSURANCE`
- `CODE_REVIEW` (Phase 5 Quality Validation)

**关键词触发**:
- 置信度、评分、过滤、优先级、验证

**复杂度**: Simple → Medium

**核心能力**:
- `confidence_scoring` - 0-100置信度评分
- `issue_filtering` - 基于阈值过滤问题
- `objective_assessment` - 客观影响评估
- `priority_ranking` - 问题优先级排序
- `false_positive_reduction` - 减少误报

**Phase 5 专用工作流**:
1. **接收code-reviewer输出** - 读取所有报告的问题（JSON格式）
2. **逐个问题评分** - 使用客观标准评估每个问题（0-100）
3. **应用阈值过滤** - 仅保留confidence ≥80的问题
4. **生成过滤报告** - 输出高置信度问题列表

**评分维度（0-100）**:
- **Impact** (40%) - 真实影响程度（安全/性能/可维护性）
- **Certainty** (30%) - 问题确定性（是否真的有问题）
- **Evidence** (20%) - 证据充分性（代码片段/引用）
- **Actionability** (10%) - 可操作性（修复建议是否清晰）

**典型使用场景**:
```
Phase 5 (Quality): code-reviewer报告12个问题
→ confidence-scorer评分
→ 输出:
  - ISS-001: SQL注入 (confidence=98) ✅ 报告
  - ISS-002: 命名不清 (confidence=65) ❌ 过滤
  - ISS-003: 内存泄漏 (confidence=92) ✅ 报告
  - ISS-004: 缺少注释 (confidence=45) ❌ 过滤
→ 最终用户看到: 2个高置信度问题
```

**关键原则**:
- ✅ 客观评分：基于可测量标准，非主观判断
- ✅ 严格阈值：≥80才报告给用户
- ✅ 透明过程：记录评分理由
- ✅ 减少噪音：过滤低影响问题

**集成方式**:
```
code-reviewer (报告所有)
  → confidence-scorer (客观评分)
  → filter ≥80
  → 用户看到高置信度问题
```

**输出格式**: filtered-issues.json (仅高置信度问题)

**时间估算**: 0.5-1天

---

### 19. code-mentor
**代码指导和最佳实践教学专家**

**适用意图**:
- `LEARNING`
- `CODE_REVIEW`

**关键词触发**:
- 学习、指导、教学、解释、概念、最佳实践、如何

**复杂度**: Simple → Medium → Complex

**核心能力**:
- `teaching` - 教学和指导
- `concept_explanation` - 概念解释
- `best_practices` - 最佳实践传授
- `mentoring` - 代码指导
- `pattern_teaching` - 设计模式教学

**典型使用场景**:
```
用户: "如何正确使用React Hooks？"
→ code-mentor教学指导
→ 输出: 概念解释、代码示例、最佳实践、常见陷阱
```

**时间估算**: 0.5-2天

---

### 20. quality-guardian
**质量标准守护和流程管控专家**

**适用意图**:
- `QUALITY_ASSURANCE`
- `CODE_REVIEW`

**关键词触发**:
- 质量、守护、标准、流程、管控、门禁

**复杂度**: Medium → Complex

**核心能力**:
- `quality_control` - 质量控制
- `process_management` - 流程管理
- `standards_enforcement` - 标准执行
- `quality_gates` - 质量门禁
- `compliance_check` - 合规性检查

**典型使用场景**:
```
（在关键阶段自动触发）
→ quality-guardian检查质量标准
→ 输出: 质量报告、合规性检查、放行/阻止决策
```

**时间估算**: 1-2天

---

## 🔤 语言专家 (2个)

### 21. typescript-pro
**TypeScript类型设计和优化专家**

**适用意图**:
- `OPTIMIZATION`
- `REFACTORING`
- `LEARNING`

**关键词触发**:
- TypeScript、类型、泛型、接口、type、类型安全

**复杂度**: Simple → Medium → Complex

**核心能力**:
- `typescript_optimization` - TypeScript优化
- `type_design` - 类型设计
- `generic_programming` - 泛型编程
- `type_safety` - 类型安全保障
- `advanced_types` - 高级类型应用

**典型使用场景**:
```
用户: "优化这个API的TypeScript类型定义"
→ typescript-pro优化类型
→ 输出: 优化后的类型定义、类型安全改进、泛型应用
```

**时间估算**: 0.5-2天

---

### 22. javascript-pro
**JavaScript性能和现代语法专家**

**适用意图**:
- `OPTIMIZATION`
- `REFACTORING`
- `LEARNING`

**关键词触发**:
- JavaScript、性能、现代语法、ES6、优化、async

**复杂度**: Simple → Medium → Complex

**核心能力**:
- `javascript_optimization` - JavaScript性能优化
- `modern_syntax` - 现代语法应用（ES6+）
- `async_programming` - 异步编程
- `performance_tuning` - 性能调优

**典型使用场景**:
```
用户: "优化这段JavaScript代码的性能"
→ javascript-pro分析优化
→ 输出: 优化后代码、性能提升报告、现代语法应用
```

**时间估算**: 0.5-2天

---

## Agent选择算法

### 评分公式

```
总分 = (关键词匹配 × 0.4) + (能力匹配 × 0.3) + (复杂度匹配 × 0.2) + (成功率 × 0.1)
```

### 选择策略

1. **Primary Agent**: 得分最高的agent
2. **Supporting Agents**: 得分>0.5且能力互补的agents（最多3个）
3. **Mandatory Agents**: code-reviewer在有代码改动时强制添加

### 互补能力判断

- 前端 + 后端
- 设计 + 实现
- 开发 + 测试
- 实现 + 审查

---

## 使用建议

### 何时使用哪个Agent？

| 场景 | 推荐Agents |
|------|-----------|
| 新功能开发 (7-Phase) | requirement-analyzer, code-explorer, code-architect, api-helper, frontend-developer, code-reviewer, confidence-scorer |
| 代码库理解 (Phase 2) | code-explorer (2-3并行) |
| 架构设计 (Phase 3) | code-architect (2-3并行), backend-architect |
| 质量验证 (Phase 5) | code-reviewer, confidence-scorer |
| 快速Bug修复 | quick-fixer, test-automator |
| 复杂Bug调查 | debugger, test-automator |
| 代码优化 | code-reviewer, typescript-pro, javascript-pro |
| 学习指导 | code-mentor |
| 项目规划 | task-orchestrator-v2, requirement-analyzer, sprint-manager |
| 快速验证 | ooda-manager, quick-fixer |

### 质量优先原则

- ✅ 代码改动必须经过code-reviewer审查
- ✅ 审查问题必须经过confidence-scorer过滤（仅报告confidence≥80）
- ✅ 关键功能必须有test-automator测试
- ✅ 复杂任务必须有quality-guardian把关

---

**注**: 本注册表基于 `${CLAUDE_PLUGIN_ROOT}/agents/workflow/master-controller.md` 生成和维护。
