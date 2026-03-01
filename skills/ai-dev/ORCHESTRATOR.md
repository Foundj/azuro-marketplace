# AI Orchestrator - 编排引擎详细设计

## 架构概览

AI Orchestrator采用分层架构设计，将复杂的任务分析和agent调度过程分解为清晰的组件：

```
┌─────────────────────────────────────────┐
│         Natural Language Input          │
│      (用户自然语言描述任务)              │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│       Intent Analysis Engine            │
│    (意图分析引擎 - 12种任务类型)         │
│  ├─ Keyword Extraction                  │
│  ├─ Intent Classification               │
│  ├─ Complexity Assessment               │
│  ├─ Tech Stack Detection                │
│  └─ Time Estimation                     │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│        Agent Selection Engine           │
│    (Agent选择引擎 - 评分算法)            │
│  ├─ Candidate Filtering (17 agents)    │
│  ├─ Capability Scoring (4维度)         │
│  ├─ Optimal Combination                │
│  └─ Primary/Supporting Assignment       │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│       Workflow Orchestration            │
│    (工作流编排引擎 - 模板+动态生成)       │
│  ├─ Template Selection                  │
│  ├─ Phase Configuration                 │
│  ├─ Parallel Optimization               │
│  └─ Quality Gates Injection             │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│         Execution Manager               │
│    (执行管理器 - Task调度和监控)         │
│  ├─ Parallel/Serial Execution           │
│  ├─ Progress Monitoring                 │
│  ├─ Error Handling                      │
│  └─ Result Aggregation                  │
└──────────────┬──────────────────────────┘
               ↓
┌─────────────────────────────────────────┐
│         Quality Assurance               │
│    (质量保障层 - 强制code-reviewer)      │
│  ├─ Code Review                         │
│  ├─ Test Validation                     │
│  ├─ Standards Compliance                │
│  └─ Performance Check                   │
└─────────────────────────────────────────┘
```

## 核心组件详解

### 1. Intent Analysis Engine (意图分析引擎)

#### 1.1 任务意图分类系统

```typescript
enum TaskIntent {
  // 开发类
  FEATURE_DEVELOPMENT = "feature_development",    // 新功能开发
  BUG_FIXING = "bug_fixing",                     // Bug修复
  REFACTORING = "refactoring",                   // 代码重构

  // 架构类
  ARCHITECTURE_DESIGN = "architecture_design",   // 架构设计
  API_DEVELOPMENT = "api_development",           // API开发
  UI_IMPLEMENTATION = "ui_implementation",       // UI实现

  // 质量类
  CODE_REVIEW = "code_review",                   // 代码审查
  TESTING = "testing",                           // 测试
  OPTIMIZATION = "optimization",                 // 性能优化

  // 管理类
  PROJECT_SETUP = "project_setup",               // 项目搭建
  TROUBLESHOOTING = "troubleshooting",           // 问题诊断
  LEARNING = "learning"                          // 学习指导
}
```

#### 1.2 意图识别算法

```typescript
function classifyIntent(input: string, keywords: string[]): TaskIntent {
  const scores: Map<TaskIntent, number> = new Map();

  // 1. 关键词匹配
  for (const [intent, intentKeywords] of INTENT_KEYWORDS) {
    const matchScore = keywords.filter(k =>
      intentKeywords.some(ik => k.includes(ik) || ik.includes(k))
    ).length / keywords.length;

    scores.set(intent, matchScore);
  }

  // 2. 语义模式匹配
  for (const [intent, patterns] of INTENT_PATTERNS) {
    if (patterns.some(p => input.match(p))) {
      scores.set(intent, scores.get(intent) + 0.3);
    }
  }

  // 3. 返回得分最高的意图
  return Array.from(scores.entries())
    .sort((a, b) => b[1] - a[1])[0][0];
}
```

#### 1.3 复杂度评估系统

```typescript
function assessComplexity(input: string, keywords: string[]): ComplexityLevel {
  let score = 0;

  // 因素1: 任务范围 (0-3分)
  const scopeIndicators = ["多个", "全部", "整个系统", "完整的"];
  if (scopeIndicators.some(i => input.includes(i))) score += 3;
  else if (keywords.length > 5) score += 2;
  else score += 1;

  // 因素2: 技术复杂度 (0-3分)
  const complexTech = ["架构", "重构", "微服务", "分布式", "实时"];
  score += complexTech.filter(t => input.includes(t)).length;

  // 因素3: 依赖关系 (0-2分)
  const dependencies = ["集成", "迁移", "兼容", "同步"];
  if (dependencies.some(d => input.includes(d))) score += 2;

  // 因素4: 新技术学习 (0-2分)
  if (input.includes("新") || input.includes("首次") || input.includes("从零")) {
    score += 2;
  }

  // 分类
  if (score <= 3) return "simple";
  if (score <= 7) return "medium";
  return "complex";
}
```

### 2. Agent Selection Engine (Agent选择引擎)

#### 2.1 四维评分系统

```typescript
interface ScoringWeights {
  keywordMatch: 0.4,      // 关键词匹配权重
  capabilityMatch: 0.3,   // 能力匹配权重
  complexityMatch: 0.2,   // 复杂度匹配权重
  successRate: 0.1        // 历史成功率权重
}

function scoreAgent(
  agent: AgentInfo,
  task: TaskAnalysis,
  weights: ScoringWeights = DEFAULT_WEIGHTS
): number {
  let totalScore = 0;

  // 维度1: 关键词匹配 (40%)
  const keywordScore = calculateKeywordMatch(
    agent.keywords,
    task.keywords
  );
  totalScore += keywordScore * weights.keywordMatch;

  // 维度2: 能力匹配 (30%)
  const capabilityScore = calculateCapabilityMatch(
    agent.capabilities,
    task.intent,
    task.techStack
  );
  totalScore += capabilityScore * weights.capabilityMatch;

  // 维度3: 复杂度匹配 (20%)
  const complexityScore = agent.complexity.includes(task.complexity) ? 1.0 : 0.3;
  totalScore += complexityScore * weights.complexityMatch;

  // 维度4: 历史成功率 (10%)
  const successScore = agent.successRate || 0.8; // 默认80%
  totalScore += successScore * weights.successRate;

  return Math.min(totalScore, 1.0);
}
```

#### 2.2 关键词匹配算法

```typescript
function calculateKeywordMatch(
  agentKeywords: string[],
  taskKeywords: string[]
): number {
  let matches = 0;
  let totalWeight = 0;

  for (const taskKw of taskKeywords) {
    // 权重：越靠前的关键词权重越高
    const weight = 1.0 / (taskKeywords.indexOf(taskKw) + 1);
    totalWeight += weight;

    // 检查是否匹配
    const matched = agentKeywords.some(agentKw =>
      taskKw.includes(agentKw) ||
      agentKw.includes(taskKw) ||
      levenshteinDistance(taskKw, agentKw) <= 2
    );

    if (matched) matches += weight;
  }

  return totalWeight > 0 ? matches / totalWeight : 0;
}
```

#### 2.3 最优组合算法

```typescript
function selectOptimalAgents(
  analysis: TaskAnalysis,
  registry: AgentRegistry
): AgentSelection {
  // 1. 过滤候选agents
  const candidates = Object.entries(registry).filter(([name, info]) =>
    info.intent.includes(analysis.intent) ||
    info.keywords.some(k => analysis.keywords.includes(k))
  );

  // 2. 评分排序
  const scored = candidates
    .map(([name, info]) => ({
      name,
      info,
      score: scoreAgent(info, analysis)
    }))
    .sort((a, b) => b.score - a.score);

  // 3. 选择primary agent (得分最高)
  const primary = scored[0];

  // 4. 选择supporting agents (得分>0.5且能力互补)
  const supporting = scored
    .slice(1)
    .filter(a =>
      a.score > 0.5 &&
      hasComplementaryCapabilities(a.info, primary.info)
    )
    .slice(0, 3); // 最多3个supporting agents

  // 5. 强制添加code-reviewer（如果有代码改动）
  if (analysis.intent !== TaskIntent.LEARNING &&
      !supporting.find(a => a.name === 'code-reviewer')) {
    supporting.push({
      name: 'code-reviewer',
      info: registry['code-reviewer'],
      score: 0.9
    });
  }

  return {
    primary: primary.name,
    supporting: supporting.map(a => a.name),
    scores: { [primary.name]: primary.score, ...supportScores(supporting) },
    reasoning: generateReasoningReport(primary, supporting, analysis)
  };
}
```

### 3. Workflow Orchestration (工作流编排)

#### 3.1 工作流模板库

```typescript
const WORKFLOW_TEMPLATES: Record<TaskIntent, WorkflowTemplate> = {
  [TaskIntent.FEATURE_DEVELOPMENT]: {
    name: "功能开发工作流",
    phases: [
      {
        name: "需求分析",
        agents: ["requirement-analyzer"],
        parallel: true,
        timeEstimate: "0.1 * totalTime",
        outputs: ["requirements.md", "user-stories.md"]
      },
      {
        name: "架构设计",
        agents: ["backend-architect", "frontend-developer"],
        parallel: true,
        dependencies: ["需求分析"],
        timeEstimate: "0.3 * totalTime",
        outputs: ["api-design.md", "component-design.md"]
      },
      {
        name: "实现开发",
        agents: ["api-helper", "frontend-developer"],
        parallel: true,
        dependencies: ["架构设计"],
        timeEstimate: "0.4 * totalTime",
        constraints: {
          maxLinesPerPR: 150,
          maxFilesPerPR: 8,
          maxFunctionLines: 30
        }
      },
      {
        name: "质量保障",
        agents: ["code-reviewer", "test-automator"],
        parallel: true,
        dependencies: ["实现开发"],
        timeEstimate: "0.2 * totalTime",
        mandatory: true // 强制执行
      }
    ]
  },

  [TaskIntent.BUG_FIXING]: {
    name: "快速修复工作流",
    phases: [
      {
        name: "问题诊断",
        agents: ["debugger", "quick-fixer"],
        parallel: false,
        timeLimit: 15, // 15分钟
        outputs: ["diagnosis.md"]
      },
      {
        name: "快速修复",
        agents: ["quick-fixer"],
        dependencies: ["问题诊断"],
        timeLimit: 30, // 30分钟
        constraints: {
          maxFilesChanged: 3,
          maxLinesChanged: 50
        }
      },
      {
        name: "验证测试",
        agents: ["test-automator"],
        dependencies: ["快速修复"],
        timeLimit: 10,
        mandatory: true
      }
    ]
  }
};
```

#### 3.2 动态工作流生成

```typescript
function generateWorkflow(
  taskAnalysis: TaskAnalysis,
  selectedAgents: AgentSelection
): ExecutionPlan {
  // 1. 选择基础模板
  const template = WORKFLOW_TEMPLATES[taskAnalysis.intent];
  if (!template) {
    return generateCustomWorkflow(taskAnalysis, selectedAgents);
  }

  // 2. 自定义agents配置
  const customizedPhases = template.phases.map(phase => {
    // 过滤掉不在选择列表中的agents
    const availableAgents = phase.agents.filter(agent =>
      agent === selectedAgents.primary ||
      selectedAgents.supporting.includes(agent)
    );

    return {
      ...phase,
      agents: availableAgents.length > 0 ? availableAgents : [selectedAgents.primary]
    };
  }).filter(phase => phase.agents.length > 0);

  // 3. 优化并行执行
  const optimized = optimizeParallelExecution(
    customizedPhases,
    taskAnalysis.complexity
  );

  // 4. 注入质量门禁
  const withQuality = injectQualityGates(optimized, taskAnalysis);

  // 5. 计算时间估算
  const withTiming = calculatePhaseTiming(
    withQuality,
    taskAnalysis.timeEstimate
  );

  return {
    template: template.name,
    phases: withTiming,
    totalTime: taskAnalysis.timeEstimate,
    parallelizationFactor: calculateParallelFactor(withTiming)
  };
}
```

#### 3.3 并行执行优化

```typescript
function optimizeParallelExecution(
  phases: Phase[],
  complexity: ComplexityLevel
): Phase[] {
  // 简单任务：更多并行
  if (complexity === "simple") {
    return phases.map(phase => ({
      ...phase,
      parallel: phase.agents.length > 1 // 多agents自动并行
    }));
  }

  // 复杂任务：保守并行（避免冲突）
  if (complexity === "complex") {
    return phases.map(phase => ({
      ...phase,
      parallel: phase.parallel && phase.agents.length <= 2
    }));
  }

  // 中等任务：使用模板默认配置
  return phases;
}
```

### 4. Execution Manager (执行管理)

#### 4.1 并行/串行执行策略

```typescript
async function executeWorkflow(plan: ExecutionPlan): Promise<ExecutionResult> {
  const results: PhaseResult[] = [];
  const context: ExecutionContext = createInitialContext();

  for (const phase of plan.phases) {
    console.log(`\n## Phase: ${phase.name}`);
    console.log(`Agents: ${phase.agents.join(', ')}`);
    console.log(`Mode: ${phase.parallel ? 'Parallel' : 'Serial'}`);

    let phaseResult: PhaseResult;

    if (phase.parallel && phase.agents.length > 1) {
      // 并行执行
      phaseResult = await executeParallel(phase, context);
    } else {
      // 串行执行
      phaseResult = await executeSerial(phase, context);
    }

    results.push(phaseResult);
    context = updateContext(context, phaseResult);

    // 检查phase是否成功
    if (!phaseResult.success && phase.mandatory) {
      throw new ExecutionError(
        `Mandatory phase "${phase.name}" failed`,
        phaseResult.error
      );
    }
  }

  return {
    success: results.every(r => r.success),
    phases: results,
    totalTime: results.reduce((sum, r) => sum + r.duration, 0),
    artifacts: collectArtifacts(results)
  };
}
```

#### 4.2 错误处理和重试

```typescript
async function executeWithRetry(
  agent: string,
  task: AgentTask,
  maxRetries: number = 3
): Promise<AgentResult> {
  let lastError: Error;

  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      console.log(`[${agent}] Attempt ${attempt}/${maxRetries}`);

      const result = await callAgent(agent, task);

      if (result.success) {
        return result;
      }

      lastError = result.error;

      // 指数退避
      await sleep(Math.pow(2, attempt) * 1000);

    } catch (error) {
      lastError = error;
      console.error(`[${agent}] Error:`, error.message);
    }
  }

  // 所有重试失败，尝试fallback agent
  const fallback = selectFallbackAgent(agent);
  if (fallback) {
    console.log(`[${agent}] Switching to fallback: ${fallback}`);
    return executeWithRetry(fallback, task, 1);
  }

  throw new AgentExecutionError(
    `Agent ${agent} failed after ${maxRetries} attempts`,
    lastError
  );
}
```

### 5. Long-Running Project Integration (长运行项目集成)

#### 5.1 项目模式检测

```typescript
async function detectProjectMode(): Promise<ProjectMode> {
  // 检查是否存在codebox/目录
  const projectDir = path.join(process.cwd(), 'codebox');

  if (!fs.existsSync(projectDir)) {
    return {
      mode: 'standard',
      initialized: false
    };
  }

  // 检查必需文件
  const requiredFiles = [
    'feature_list.json',
    'progress.txt',
    'config.json'
  ];

  const missingFiles = requiredFiles.filter(file =>
    !fs.existsSync(path.join(projectDir, file))
  );

  if (missingFiles.length > 0) {
    return {
      mode: 'long-running',
      initialized: false,
      missingFiles
    };
  }

  return {
    mode: 'long-running',
    initialized: true,
    projectDir
  };
}
```

#### 5.2 与Session Manager集成

```typescript
async function integrateWithSessionManager(
  taskAnalysis: TaskAnalysis
): Promise<SessionContext> {
  const projectMode = await detectProjectMode();

  if (projectMode.mode !== 'long-running' || !projectMode.initialized) {
    return { mode: 'standard' };
  }

  console.log('\n🔄 Long-running project detected!');
  console.log('Calling session-manager to restore context...\n');

  // 调用session-manager恢复上下文
  const recoveryReport = await callSkill('session-manager', {
    action: 'restore',
    projectDir: projectMode.projectDir
  });

  // 从feature_list.json选择下一个特性
  const featureList = await readFeatureList(projectMode.projectDir);
  const nextFeature = selectNextFeature(featureList, taskAnalysis);

  return {
    mode: 'long-running',
    recoveryReport,
    currentFeature: nextFeature,
    featureList,
    projectDir: projectMode.projectDir
  };
}
```

#### 5.3 增量开发强制机制

```typescript
function enforceOneFeatureAtATime(
  sessionContext: SessionContext,
  workflow: ExecutionPlan
): ExecutionPlan {
  if (sessionContext.mode !== 'long-running') {
    return workflow;
  }

  // 添加约束：只实现一个特性
  const constrainedPhases = workflow.phases.map(phase => ({
    ...phase,
    constraints: {
      ...phase.constraints,
      onlyOneFeature: true,
      featureId: sessionContext.currentFeature.id,
      featureDescription: sessionContext.currentFeature.description
    }
  }));

  // 添加完成后处理phase
  constrainedPhases.push({
    name: "更新项目状态",
    agents: ["session-manager"],
    parallel: false,
    dependencies: [constrainedPhases[constrainedPhases.length - 1].name],
    mandatory: true,
    action: {
      type: "update_feature_status",
      featureId: sessionContext.currentFeature.id,
      passes: true,
      updateProgress: true
    }
  });

  return {
    ...workflow,
    phases: constrainedPhases,
    mode: 'incremental'
  };
}
```

## 性能优化策略

### 1. 缓存机制

```typescript
// Agent能力评分缓存
const scoringCache = new LRUCache<string, number>({
  max: 1000,
  ttl: 1000 * 60 * 60 // 1小时
});

// 工作流模板缓存
const workflowCache = new Map<string, ExecutionPlan>();
```

### 2. 并行执行最大化

- 识别无依赖的phases自动并行
- 在phase内部并行调用多个agents
- 使用Promise.all批量等待结果

### 3. 早期失败检测

- Phase开始前验证依赖
- Agent调用前检查前置条件
- 快速失败避免浪费资源

## 监控和日志

### 执行追踪

```typescript
interface ExecutionTrace {
  taskId: string;
  startTime: Date;
  endTime?: Date;
  phases: PhaseTrace[];
  totalAgentCalls: number;
  successRate: number;
  errors: ErrorTrace[];
}
```

### 性能指标

- 总执行时间
- 各phase耗时分布
- Agent调用成功率
- 并行化效率（理论时间 vs 实际时间）
- 缓存命中率

## 未来增强

1. **机器学习优化**
   - 基于历史数据优化评分权重
   - 预测任务成功率
   - 推荐最佳agent组合

2. **动态负载均衡**
   - Agent负载监控
   - 智能任务分配
   - 失败自动转移

3. **成本优化**
   - Token使用追踪
   - 成本效益分析
   - 预算控制

---

**设计原则**: 简单、高效、可靠、可扩展
