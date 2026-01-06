# AI-Orchestrator v2.0 Complete User Guide

> **完整用户指南** - 深入理解ai-dev的所有功能、最佳实践和高级技巧

---

## 📚 目录

1. [系统概述](#系统概述)
2. [7-Phase工作流详解](#7-phase工作流详解)
3. [验证机制（4层Defense in Depth）](#验证机制)
4. [知识库系统](#知识库系统)
5. [OODA自主完成详解](#ooda自主完成详解)
6. [Confidence Scoring算法](#confidence-scoring算法)
7. [跨会话恢复](#跨会话恢复)
8. [最佳实践](#最佳实践)
9. [高级配置](#高级配置)
10. [故障排除](#故障排除)

---

## 系统概述

### What & Why

**ai-dev v2.0** 是基于以下5大方法论的自主软件开发系统：

1. **Kiro Spec Workflow** - 7-Phase门控流程
2. **AISD-R** (AI-Software Development with Research) - 知识管理
3. **OpenSpec** - 全局约束验证
4. **Ralph-Wiggum Loop** - 自我验证和自主完成
5. **Netflix Conductor** - 状态机和跨会话恢复

### 核心问题解决

| 传统开发痛点 | ai-dev v2.0解决方案 |
|------------|--------------------------|
| 😫 需求理解偏差 | ✅ Phase 1审批门控（确认需求） |
| 😫 返工频繁 | ✅ Phase 3审批门控（选方案） |
| 😫 代码质量参差 | ✅ 自动代码审查+置信度过滤 |
| 😫 经验不积累 | ✅ 知识库自动学习 |
| 😫 无法中断恢复 | ✅ state.json状态持久化 |
| 😫 审查噪音太多 | ✅ Confidence scoring≥80过滤 |

### v2.0新增功能

相比v1.x，v2.0增加了：

- 🆕 **State Machine** - Netflix Conductor模式，支持跨会话恢复
- 🆕 **Knowledge Base** - patterns.json + errors.json，历史经验复用
- 🆕 **User Approval Gates** - 3个审批门控，确保方向正确
- 🆕 **Quality Gates** - 2个自动质量检查，拦截低质量代码
- 🆕 **Confidence Scoring** - 智能过滤代码审查噪音（≥80分）
- 🆕 **Ralph-Wiggum Enhancements** - assertion验证、回归测试、自我修复
- 🆕 **Stop Hooks** - 自动触发验证（无需手动调用）

**质量提升**: 2-3x代码质量，90%+自主完成率

---

## 7-Phase工作流详解

### Phase 0: Knowledge Check（知识预查）

**目的**: 从历史项目中学习，避免重复犯错

**触发方式**: 自动（pre-change-check hook）

**执行逻辑**:

```typescript
async function phase0KnowledgeCheck(userRequest: string) {
  // 1. 解析用户意图
  const intent = parseIntent(userRequest);
  // "添加用户登录" → { feature: "authentication", keywords: ["login", "user", "auth"] }

  // 2. 查询patterns.json
  const relevantPatterns = await queryPatterns({
    keywords: intent.keywords,
    category: intent.feature
  });
  // 找到: PATTERN-023 "JWT Authentication Pattern"

  // 3. 查询errors.json
  const relevantErrors = await queryErrors({
    keywords: intent.keywords,
    severity: ['high', 'critical']
  });
  // 找到: ERROR-012 "Password stored in plaintext"

  // 4. 生成phase0-context.md
  await generatePhase0Context({
    patterns: relevantPatterns,
    errors: relevantErrors,
    recommendations: generateRecommendations(relevantPatterns, relevantErrors)
  });

  // 5. 传递给Phase 1
  return {
    contextFile: `changes/active/${changeId}/phase0-context.md`,
    appliedPatterns: relevantPatterns.map(p => p.id),
    preventedErrors: relevantErrors.map(e => e.id)
  };
}
```

**输出示例**:

```markdown
# Phase 0 Knowledge Context

## 相关模式（3个）
- **PATTERN-023**: JWT Authentication Pattern
  - 成功率: 98%
  - 使用次数: 15
  - 代码示例: [查看]

## 历史错误（2个）
- **ERROR-012**: Password stored in plaintext (严重程度: critical)
  - 发生次数: 1
  - 预防措施: 使用bcrypt hash密码

## 建议
1. ✅ 使用PATTERN-023实现JWT认证（历史成功率98%）
2. ⚠️ 必须hash密码（历史教训ERROR-012）
3. ✅ 添加rate limiting（参考PATTERN-034）
```

**最佳实践**:
- ✅ 每次开发前都运行Phase 0（即使觉得简单）
- ✅ 认真阅读phase0-context.md中的建议
- ✅ 如果建议不适用，在Phase 1 proposal中说明原因

---

### Phase 1: Requirements Analysis（需求分析）

**目的**: 理解需求，生成可执行的proposal

**Agent**: requirement-analyzer

**输入**:
- User request（用户原始需求）
- phase0-context.md（历史经验）
- Global constraints（requirements.md, design.md, CLAUDE.md）

**输出**: proposal.md

**Proposal结构**:

```markdown
# Proposal: [Feature Name]

## 📋 Summary
[1-2句话总结]

## 🎯 Tech Stack
- Frontend: React + TypeScript
- Backend: Hono API
- Database: Drizzle ORM

## 🔒 Global Constraints
引用自：
- `requirements.md`: REQ-SEC-001 (用户输入必须验证)
- `design.md`: DES-DB-002 (使用参数化查询)

应用历史模式：
- `PATTERN-023`: JWT Authentication

预防历史错误：
- `ERROR-012`: Password plaintext storage

## ⏱️ Time Estimate
- Core: 2h
- Testing: 1h
- Total: 3h ✅ (符合21天Sprint)

## ✅ Success Criteria
1. [可测试标准1]
2. [可测试标准2]
```

**审批门控 Gate #1**:

```
🚪 Phase 1 审批

需求理解是否正确？

选项:
1. Yes - 继续
2. Refine - 修正
3. No - 取消
```

**选择策略**:

| 情况 | 选择 | 说明 |
|------|------|------|
| Proposal完全正确 | Yes | 进入Phase 2 |
| 有小问题（如时间估算偏差） | Refine | 返回Phase 1重新分析 |
| 理解完全错误 | No | 取消变更，重新表达需求 |

**Refine循环逻辑**:

```typescript
if (userChoice === 'Refine') {
  // 用户提供反馈
  const feedback = await AskUserQuestion({
    question: "请说明需要调整的地方",
    type: "text"
  });

  // 重新分析需求
  await Task({
    subagent_type: 'requirement-analyzer',
    prompt: `
      重新分析需求。

      上次proposal: ${previousProposal}
      用户反馈: ${feedback}

      请根据反馈调整proposal。
    `
  });

  // 再次请求审批
  return phase1ApprovalGate(changeId);
}
```

**最佳实践**:
- ✅ 检查time estimate是否合理（符合21天Sprint）
- ✅ 检查tech stack是否与现有项目一致
- ✅ 检查是否应用了phase0-context中的建议
- ❌ 不要跳过审批（即使看起来很简单）

---

### Phase 2: Discovery（代码探索）

**目的**: 理解现有代码库结构，找到关键文件和模式

**Agent**: code-explorer

**Thoroughness级别**:

| 级别 | 适用场景 | 时间 |
|------|---------|------|
| quick | 熟悉的代码库 | 5-10分钟 |
| medium | 一般情况（推荐） | 15-20分钟 |
| very thorough | 复杂重构 | 30-40分钟 |

**输出**: evidence.md

**Discovery内容**:

```markdown
# Discovery: Existing Codebase Analysis

## 🗂️ Key Files

### [Category 1: Database Schema]
- **File**: src/db/schema/users.ts
- **Pattern**: Drizzle ORM table定义
- **Example**: [代码片段]
- **Action**: 创建类似的posts table

### [Category 2: API Endpoints]
...

## 🔗 Dependencies
- React 18.2
- Hono 3.11 (需要升级到3.12)

## 📊 Existing Patterns
✅ 使用Zod验证
✅ API统一返回JSON
⚠️ 未使用TypeScript strict mode

## ⚠️ Constraints to Follow
- 所有新表必须有createdAt字段
- API必须有error handling
```

**验证点 #3: Discovery Completeness**

自动检查：
```typescript
const isComplete =
  discovery.includes('Key Files') &&
  discovery.includes('Dependencies') &&
  discovery.includes('Existing Patterns') &&
  discovery.includes('Constraints');
```

**最佳实践**:
- ✅ 对不熟悉的代码库使用 `very thorough`
- ✅ 记录现有patterns并在Phase 4中遵循
- ✅ 注意Constraints，这些会在Phase 5验证

---

### Phase 3: Design（架构设计）

**目的**: 设计3个不同trade-off的实现方案

**Agent**: code-architect

**输入**:
- proposal.md
- evidence.md
- phase0-context.md

**输出**: design.md（包含3个approaches）

**Approach结构**:

```markdown
## 🎨 Approach 1: Minimal (快速实现)

### Database Schema
[代码示例]

### API Endpoints
[代码示例]

### Frontend Components
[代码示例]

**Tradeoffs**:
- ✅ 实现快（2小时）
- ❌ 技术债较多
- ❌ 性能一般
- ❌ 难以扩展

**适用场景**: MVP、原型验证

---

## 🎨 Approach 2: Clean (推荐)

...

**Tradeoffs**:
- ✅ 质量高
- ✅ 易维护
- ✅ 性能好
- ⏱️ 时间稍长（4小时）

**适用场景**: 生产环境

---

## 🎨 Approach 3: Pragmatic (务实)

...

**Tradeoffs**:
- ✅ 平衡速度和质量
- ⚠️ 未来可能需要重构

**适用场景**: 时间紧、质量有基本要求

---

## ✅ Recommendation

推荐 **Approach 2 (Clean)** 原因：
1. [原因1]
2. [原因2]
```

**审批门控 Gate #2**:

```
🚪 Phase 3 审批

选择哪个设计方案？

选项:
1. Approach 1 - Minimal (2h)
2. Approach 2 - Clean (4h) [推荐]
3. Approach 3 - Pragmatic (3h)
```

**选择策略**:

| 情况 | 选择 | 理由 |
|------|------|------|
| 生产环境 | Approach 2 | 长期维护成本低 |
| 时间紧急 | Approach 3 | 平衡质量和速度 |
| MVP验证 | Approach 1 | 快速验证想法 |

**最佳实践**:
- ✅ 默认选择推荐方案（architect已经权衡过）
- ✅ 如果时间不够，问清楚具体有多少时间
- ✅ 考虑长期维护成本，不要只看开发时间
- ❌ 不要总是选Minimal（技术债会累积）

---

### Phase 4: Implementation with OODA Loop（编码实现）

**目的**: 自主完成所有编码任务

**核心机制**: Ralph-Wiggum OODA循环

**流程**:

```
Step 1: 生成tasks.md
  ├─ 拆分为10-20个小任务
  ├─ 建立依赖关系
  └─ 估算每个任务时间

Step 2: OODA循环（最多10次迭代）
  ├─ Observe: 读取tasks.md，检查当前进度
  ├─ Orient: 决定做哪个任务（按依赖顺序）
  ├─ Decide: 选择实现策略
  ├─ Act: 写代码 + 跑测试
  └─ Verify: 检查assertions + 测试结果
        ├─ ✅ 通过 → 标记任务完成，下一个任务
        └─ ❌ 失败 → 自我修复（debugger/rollback）

Step 3: 完成标记
  └─ 所有任务完成 → <promise>DONE</promise>
```

**tasks.md格式**:

```markdown
# Tasks for Change #001-user-login

## 📊 Metadata
- **Change ID**: 001-user-login
- **Phase**: 4
- **OODA Iteration**: 3/10
- **Completion**: <promise>PENDING</promise>

## 📋 Task List

### Phase 1: Database
- [x] Task 1: 创建User schema
  - Estimate: 15min
  - Assertions:
    - `User table有email字段`
    - `email字段有unique约束`
- [ ] Task 2: 添加password hash
  - Dependencies: Task 1
  - Estimate: 10min

### Phase 2: API
...

## ✅ Validation Criteria
- [ ] npm test passes
- [ ] npm run build succeeds
- [ ] ESLint clean
- [ ] TypeScript clean

## 📈 OODA Loop History

### Iteration 1 (10:00)
- Completed: Task 1
- Tests: ✅ (3/3)
- Build: ✅

### Iteration 2 (10:20)
- Completed: Task 2
- Tests: ❌ (password hash test failed)
- Auto-fix: 添加了salt
- Re-test: ✅
```

**Assertions（断言验证）**:

```typescript
// Task中定义assertions
{
  task: "创建User schema",
  assertions: [
    "User table有email字段",
    "email字段有unique约束"
  ]
}

// OODA循环自动验证
async function verifyTaskAssertions(taskNumber) {
  const task = tasks[taskNumber];

  for (const assertion of task.assertions) {
    // 创建临时测试文件（安全方式）
    const testFile = createTempTestFile(assertion);
    const result = await runTest(testFile);

    if (!result.passed) {
      console.log(`❌ Assertion failed: ${assertion}`);
      await autoFix(taskNumber, assertion);
    }
  }
}
```

**Self-Healing（自我修复）**:

```typescript
async function selfHealingStrategy(failure) {
  consecutiveFailures++;

  if (consecutiveFailures === 1) {
    // 第1次失败: 快速修复（使用haiku）
    await Task({
      subagent_type: 'debugger',
      model: 'haiku',
      prompt: `快速修复测试失败: ${failure.error}`
    });
  } else if (consecutiveFailures === 2) {
    // 第2次失败: 深度分析（使用sonnet）
    await Task({
      subagent_type: 'debugger',
      model: 'sonnet',
      prompt: `深度分析并修复: ${failure.error}`
    });
  } else {
    // 第3次失败: 回退并尝试另一种方法
    await Bash({ command: 'git stash' }); // 保存当前工作
    await Bash({ command: 'git reset --hard HEAD~1' }); // 回退
    await Task({
      subagent_type: 'code-architect',
      prompt: `设计替代方案解决: ${failure.task}`
    });
  }
}
```

**Stop Hook自动触发**:

```yaml
# hooks/post-phase-verify.md
trigger: agent_stop
conditions:
  - agent_name matches "^(code-|ralph-wiggum)"
  - current_phase in [4]

actions:
  - agent: verification-agent
    prompt: "验证Phase 4完成度"
```

**Quality Gate #3** (自动):

```typescript
// Phase 4完成后自动运行
async function validatePhase4Completion(changeId) {
  const checks = [
    { name: 'tasks.md有DONE promise', test: () => tasksHasDone() },
    { name: '所有任务标记[x]', test: () => allTasksChecked() },
    { name: 'npm test通过', test: () => runTests() },
    { name: 'npm run build成功', test: () => runBuild() },
    { name: 'ESLint clean', test: () => runLint() },
    { name: 'TypeScript clean', test: () => runTypeCheck() }
  ];

  const results = await Promise.all(checks.map(c => c.test()));

  if (results.every(r => r.passed)) {
    console.log('✅ Quality Gate PASSED');
    updateState({ currentPhase: 5 });
  } else {
    console.log('❌ Quality Gate FAILED - 阻止进入Phase 5');
    return { action: 'retry', phase: 4, issues: results.filter(r => !r.passed) };
  }
}
```

**最佳实践**:
- ✅ 让OODA循环自主完成，不要手动干预
- ✅ 如果卡住超过3次迭代，检查tasks.md是否任务定义清晰
- ✅ 关注Validation Criteria，确保定义明确
- ❌ 不要在中途修改tasks.md（会打乱OODA循环）

---

### Phase 5: Quality Validation（质量验证）

**目的**: 发现并修复代码问题

**流程**:

```
Step 1: 并行代码审查（3个视角）
  ├─ Security perspective
  ├─ Performance perspective
  └─ Maintainability perspective
  ↓
Step 2: 合并issues → issues-raw.json (通常20-50个)
  ↓
Step 3: Confidence Scoring
  ├─ 对每个issue评分（0-100）
  ├─ 过滤threshold≥80
  └─ 输出issues-scored.json (通常2-5个)
  ↓
Step 4: 用户决策Gate #4
  ├─ Fix All (推荐)
  ├─ Fix Critical Only
  └─ Accept Risk
  ↓
Step 5: 自动修复issues
  ↓
Step 6: Quality Gate #5 (自动验证)
```

**Confidence Scoring算法详解**:

```typescript
function calculateConfidence(issue: Issue): number {
  let score = 50; // Base

  // 1. Evidence Assessment (±20分)
  const evidence = verifyWithCode(issue);
  if (evidence.proven) score += 20;        // 100%确定
  else if (evidence.likely) score += 10;   // 80-90%确定
  else if (evidence.assumption) score -= 10; // <50%确定

  // 2. Impact Assessment (+30分max)
  if (issue.category === 'security') score += 30;
  else if (issue.severity === 'critical') score += 30;
  else if (issue.category === 'bug') score += 20;
  else if (issue.category === 'performance') score += 10;

  // 3. Documentation Check (+15分max)
  const constraintViolation = checkConstraints(issue);
  if (constraintViolation) score += 10;
  if (issue.references?.includes('cwe.mitre.org')) score += 5;

  // 4. Mitigation Check (-20分max)
  const mitigations = checkMitigations(issue);
  if (mitigations.safeguardsExist) score -= 10;
  if (mitigations.alreadyHandled) score -= 20;

  return Math.max(0, Math.min(100, score));
}
```

**3个关键问题**（用于评分）:

1. **PROVE it** - 能用代码证明吗？
   ```typescript
   // 示例: "函数过长"
   const fileContent = await Read({ file_path: issue.file });
   const functionLength = extractFunctionLength(fileContent, issue.line);
   if (functionLength > 30) {
     // PROVEN: 实际测量确认 → +20分
   }
   ```

2. **IMPACT** - 影响有多大？
   ```typescript
   // Security issue → +30分
   // Critical severity → +30分
   // Bug → +20分
   // Performance → +10分
   // Style → +0分
   ```

3. **DOCUMENTED** - 有文档依据吗？
   ```typescript
   // 违反CLAUDE.md约束 → +10分
   // 有CWE参考 → +5分
   // 违反requirements.md → +10分
   ```

**issues-scored.json示例**:

```json
{
  "threshold": 80,
  "total_issues": 25,
  "filtered_issues": 3,
  "issues": [
    {
      "issue_id": "ISSUE-007",
      "confidence": 95,
      "reasoning": "PROVEN: 实际读取文件确认函数132行 | IMPACT: 违反CLAUDE.md约束 | DOCUMENTED: CLAUDE.md明确规定≤30行",
      "file": "src/components/UserProfile.tsx",
      "title": "函数过长（132行）"
    },
    {
      "issue_id": "ISSUE-012",
      "confidence": 88,
      "reasoning": "PROVEN: SQL query使用字符串拼接 | IMPACT: 安全漏洞 | DOCUMENTED: CWE-89 SQL注入",
      "file": "src/api/users.ts",
      "title": "SQL注入风险"
    },
    {
      "issue_id": "ISSUE-019",
      "confidence": 82,
      "reasoning": "LIKELY: N+1查询模式 | IMPACT: 性能影响 | MITIGATED: 当前数据量小",
      "file": "src/api/posts.ts",
      "title": "N+1查询问题"
    }
  ],
  "filtered_out": [
    {
      "issue_id": "ISSUE-003",
      "confidence": 45,
      "reasoning": "ASSUMPTION: 仅基于几个示例 | IMPACT: 低 | 实际检查发现命名一致"
    }
  ]
}
```

**审批门控 Gate #4**:

```
🚪 Phase 5 审批

发现3个高置信度问题（≥80分）

问题详情:
1. [95分] 函数过长（132行 > 30行约束）
2. [88分] SQL注入风险
3. [82分] N+1查询问题

选项:
1. Fix All - 修复所有≥80分问题（推荐）
2. Fix Critical Only - 仅修复≥95分问题
3. Accept Risk - 接受当前质量，进入Phase 6
```

**修复策略**:

```typescript
async function autoFixIssues(issues: Issue[]) {
  for (const issue of issues) {
    console.log(`🔧 Fixing ${issue.issue_id}: ${issue.title}`);

    await Task({
      subagent_type: 'quick-fixer',
      model: 'haiku',
      prompt: `
        修复issue:
        - File: ${issue.file}:${issue.line}
        - Problem: ${issue.description}
        - Suggested Fix: ${issue.suggested_fix}

        修复后运行测试确保没有break现有功能。
      `
    });

    // 验证修复
    const testResult = await Bash({ command: 'npm test' });
    if (testResult.exitCode !== 0) {
      console.log('❌ 修复导致测试失败，回退...');
      await Bash({ command: 'git reset --hard HEAD~1' });
      continue; // 跳过这个issue
    }

    console.log(`✅ ${issue.issue_id} 修复成功`);
  }
}
```

**Quality Gate #5** (自动):

```typescript
async function validatePhase5Completion(changeId) {
  const checks = [
    { name: 'issues-scored.json存在', test: () => fileExists('issues-scored.json') },
    { name: '所有≥80分issues已修复', test: () => allHighConfidenceIssuesFixed() },
    { name: '测试仍然通过', test: () => runTests() },
    { name: '未引入新问题', test: () => noNewIssues() }
  ];

  if (checks.every(c => c.test().passed)) {
    console.log('✅ Quality Gate PASSED');
    updateState({ currentPhase: 6 });
  } else {
    console.log('⚠️ 部分检查失败，但允许继续（用户已审批）');
  }
}
```

**最佳实践**:
- ✅ 默认选择 "Fix All"（质量优先）
- ✅ 时间紧时选 "Fix Critical Only"（只修复≥95分）
- ✅ 查看 issues-raw.json 了解所有问题（包括过滤掉的）
- ❌ 不要总是 "Accept Risk"（技术债会累积）
- ✅ 如果confidence看起来不对，可以调整threshold（80→70或90）

---

### Phase 6: Finalization（最终化）

**目的**: 提交代码，更新知识库

**流程**:

```
Step 1: 更新知识库
  ├─ 添加新pattern到patterns.json
  ├─ 记录新error到errors.json（如果遇到）
  └─ 更新learnings.md

Step 2: Git Commit
  ├─ git add .
  ├─ 生成commit message
  └─ git commit

Step 3: 清理
  ├─ 移动change到archived/
  └─ 更新state.json status=completed

Step 4: 总结报告
```

**Knowledge Base更新**:

```typescript
// 1. 添加新pattern
const newPattern = {
  id: generatePatternId(), // "PATTERN-046"
  category: 'authentication',
  name: 'JWT with Refresh Token',
  description: '使用短期access token + 长期refresh token提升安全性',
  codeExample: `
    // Access token: 15min
    const accessToken = jwt.sign(payload, secret, { expiresIn: '15m' });
    // Refresh token: 7days
    const refreshToken = jwt.sign(payload, refreshSecret, { expiresIn: '7d' });
  `,
  usageCount: 1,
  successRate: 100,
  lastUsed: new Date().toISOString(),
  relatedErrors: ['ERROR-012'], // 避免这个错误
  metrics: {
    timeToImplement: '3h',
    testCoverage: 87,
    issuesFound: 2
  }
};

await addPattern(newPattern);

// 2. 更新learnings.md
await appendLearning({
  sprint: getCurrentSprint(),
  feature: changeId,
  appliedPatterns: state.knowledge.appliedPatterns,
  lessonsLearned: [
    '✅ JWT refresh token机制工作良好',
    '⚠️ 注意refresh token的rotation（防止replay attack）',
    '✅ 使用http-only cookie存储token比localStorage安全'
  ],
  timeSpent: calculateTotalTime(state),
  metrics: {
    testCoverage: state.quality.testCoverage,
    issuesFixed: state.quality.issuesFixed,
    finalScore: state.quality.finalScore
  }
});
```

**Commit Message生成**:

```bash
git commit -m "$(cat <<'EOF'
feat: 添加JWT认证系统

- 实现access token + refresh token机制
- 使用http-only cookie存储token
- 添加token rotation防止replay attack
- 测试覆盖率87%

Applied patterns: PATTERN-023, PATTERN-046
Fixed issues: ISSUE-007 (SQL注入), ISSUE-012 (函数过长)
Prevented errors: ERROR-012 (password plaintext)

Time: 3h 15min
Quality Score: 95/100

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

**最终报告**:

```markdown
## 📊 Change Summary

**Change ID**: 001-user-login
**Status**: ✅ Completed
**Duration**: 3h 15min
**Quality Score**: 95/100

### Phases
- Phase 0: 2min (知识查询)
- Phase 1: 15min (需求分析 + 审批)
- Phase 2: 20min (代码探索)
- Phase 3: 30min (设计 + 选择方案)
- Phase 4: 2h (实现，5次OODA迭代)
- Phase 5: 30min (审查 + 修复2个问题)
- Phase 6: 10min (提交 + 知识更新)

### Quality Metrics
- Test Coverage: 87%
- Issues Found: 25
- High-Confidence Issues: 2
- Issues Fixed: 2
- OODA Iterations: 5
- Gate Failures: 0

### Knowledge Updates
- New Patterns: 1 (PATTERN-046)
- Applied Patterns: 2 (PATTERN-023, PATTERN-046)
- Prevented Errors: 1 (ERROR-012)

### User Decisions
- Phase 1 Approval: Yes
- Phase 3 Approach: 2 (Clean)
- Phase 5 Decision: Fix All
```

---

## 验证机制

### 4层Defense in Depth

ai-dev v2.0使用4层验证确保质量：

```
Layer 1: User Approval Gates
  ├─ Phase 1: 需求理解确认
  ├─ Phase 3: 设计方案选择
  └─ Phase 5: 问题修复决策

Layer 2: Quality Gates (自动)
  ├─ Phase 4→5: 实现质量验证
  └─ Phase 5→6: 修复验证

Layer 3: Stop Hooks (自动触发)
  └─ post-phase-verify: 每个coding agent完成后验证

Layer 4: Self-Healing (OODA内置)
  ├─ Assertion verification
  ├─ Regression testing
  └─ Auto-fix on failure
```

### 验证点矩阵

| Phase | 验证点 | 类型 | Blocking | 失败处理 |
|-------|--------|------|----------|---------|
| 0 | 知识查询 | Auto | No | 继续（无历史经验） |
| 1 | 需求理解 | User | Yes | Refine或Cancel |
| 2 | Discovery完整性 | Auto | No | 继续 |
| 3 | 方案选择 | User | Yes | 选择方案 |
| 4 | OODA assertions | Auto | No | Auto-fix |
| 4 | Quality Gate | Auto | Yes | 返回Phase 4 |
| 5 | Confidence≥80 | Auto | No | 过滤噪音 |
| 5 | 修复决策 | User | Yes | Fix或Accept |
| 5 | Quality Gate | Auto | No | 警告但继续 |
| 6 | Knowledge更新 | Auto | No | 继续 |

---

## 知识库系统

### patterns.json结构

```typescript
interface Pattern {
  id: string;              // "PATTERN-001"
  category: string;        // "authentication", "database", etc.
  name: string;           // "JWT Token Pattern"
  description: string;    // 详细描述
  codeExample?: string;   // 代码示例
  usageCount: number;     // 使用次数
  successRate: number;    // 成功率（0-100）
  lastUsed?: Date;        // 最后使用时间
  relatedErrors: string[]; // 相关错误ID
  metrics?: {
    avgTimeToImplement?: string; // "2h"
    avgTestCoverage?: number;    // 85
  };
}
```

### errors.json结构

```typescript
interface HistoricalError {
  id: string;              // "ERROR-001"
  symptom: string;        // "User logout fails"
  rootCause: string;      // "JWT token not cleared from cookie"
  preventionMeasures: string[]; // 预防措施
  riskLevel: 'low' | 'medium' | 'high' | 'critical';
  occurrenceCount: number; // 发生次数
  lastOccurred?: Date;
  resolved: boolean;
  relatedPatterns: string[]; // 使用哪些pattern可以避免
}
```

### learnings.md格式

```markdown
## Sprint 3 - User Authentication

### Feature: JWT Login System (001-user-login)

**Applied Patterns**:
- PATTERN-023: JWT Authentication Pattern
- PATTERN-046: JWT with Refresh Token

**Prevented Errors**:
- ERROR-012: Password plaintext storage

**Lessons Learned**:
1. ✅ JWT refresh token机制工作良好
   - 短期access token (15min) + 长期refresh token (7days)
   - Http-only cookie比localStorage安全
2. ⚠️ 注意refresh token的rotation
   - 每次刷新时生成新的refresh token
   - 防止replay attack
3. 📊 测试覆盖率达到87%
   - 单元测试: 25个
   - 集成测试: 8个

**Metrics**:
- Time: 3h 15min
- Quality Score: 95/100
- Test Coverage: 87%
- Issues Found: 25
- Issues Fixed: 2

**Next Time**:
- ⏩ 可以直接复用PATTERN-046，节省1小时设计时间
- ⚠️ 记得添加token rotation（容易忘记）
```

### 知识库查询API

```typescript
// 查询patterns
async function queryPatterns(options: {
  keywords?: string[];
  category?: string;
  minSuccessRate?: number;
}): Promise<Pattern[]> {
  const patterns = JSON.parse(await Read({ file_path: 'knowledge/patterns.json' }));

  return patterns.filter(p => {
    if (options.keywords && !options.keywords.some(k => p.name.includes(k) || p.description.includes(k))) {
      return false;
    }
    if (options.category && p.category !== options.category) {
      return false;
    }
    if (options.minSuccessRate && p.successRate < options.minSuccessRate) {
      return false;
    }
    return true;
  }).sort((a, b) => b.successRate - a.successRate); // 按成功率排序
}

// 查询errors
async function queryErrors(options: {
  keywords?: string[];
  severity?: string[];
  resolved?: boolean;
}): Promise<HistoricalError[]> {
  const errors = JSON.parse(await Read({ file_path: 'knowledge/errors.json' }));

  return errors.filter(e => {
    if (options.keywords && !options.keywords.some(k => e.symptom.includes(k) || e.rootCause.includes(k))) {
      return false;
    }
    if (options.severity && !options.severity.includes(e.riskLevel)) {
      return false;
    }
    if (options.resolved !== undefined && e.resolved !== options.resolved) {
      return false;
    }
    return true;
  }).sort((a, b) => b.occurrenceCount - a.occurrenceCount); // 按发生次数排序
}
```

### 最佳实践

**DO**:
- ✅ 每次完成功能后更新knowledge base
- ✅ 记录详细的lessons learned（包括坑）
- ✅ 定期review learnings.md，总结patterns
- ✅ 与团队共享knowledge/目录（git commit）

**DON'T**:
- ❌ 不要手动编辑patterns.json（让系统自动维护）
- ❌ 不要删除旧的errors（即使已resolved，保留历史）
- ❌ 不要忽略Phase 0的建议（历史经验很宝贵）

---

## OODA自主完成详解

### OODA循环详细流程

```typescript
async function ralphWiggumOODALoop(changeId: string): Promise<OODAResult> {
  let iteration = 1;
  const MAX_ITERATIONS = 10;

  while (iteration <= MAX_ITERATIONS) {
    console.log(`🔄 OODA Iteration ${iteration}/${MAX_ITERATIONS}`);

    // === OBSERVE ===
    const tasks = await parseTasksFile(`changes/active/${changeId}/tasks.md`);
    const completionPromise = extractCompletionPromise(tasks);

    if (completionPromise === 'DONE') {
      console.log('✅ 所有任务完成！');
      break;
    }

    const nextTask = findNextTask(tasks); // 找到下一个未完成的任务

    // === ORIENT ===
    const context = {
      completedTasks: tasks.filter(t => t.checked).length,
      totalTasks: tasks.length,
      currentIteration: iteration,
      lastTestResult: await getLastTestResult(),
      lastBuildResult: await getLastBuildResult()
    };

    // === DECIDE ===
    const strategy = decideStrategy(nextTask, context);
    /*
      strategy可能是：
      - "implement": 实现新任务
      - "fix_test": 修复测试失败
      - "fix_build": 修复构建失败
      - "rollback": 回退并尝试另一种方法
    */

    // === ACT ===
    switch (strategy) {
      case 'implement':
        await implementTask(nextTask);
        break;
      case 'fix_test':
        await fixFailingTests();
        break;
      case 'fix_build':
        await fixBuildError();
        break;
      case 'rollback':
        await rollbackAndTryAlternative(nextTask);
        break;
    }

    // === VERIFY ===
    const verifyResult = await verifyIteration({
      assertions: nextTask.assertions,
      tests: true,
      build: true
    });

    if (!verifyResult.passed) {
      await selfHeal(verifyResult.failures);
    } else {
      await markTaskComplete(nextTask);
    }

    iteration++;
  }

  if (iteration > MAX_ITERATIONS) {
    console.log('⚠️ 达到最大迭代次数，可能需要人工介入');
    return { success: false, reason: 'max_iterations_reached' };
  }

  return { success: true, iterations: iteration };
}
```

### Assertion-Based Verification

```typescript
// 在tasks.md中定义assertions
{
  task: "创建User model with email validation",
  assertions: [
    "const user = new User(); user.email = 'invalid'; assert(!user.save())",
    "const user = new User(); user.email = 'valid@example.com'; assert(user.save())"
  ]
}

// OODA循环自动验证
async function verifyTaskAssertions(task: Task): Promise<boolean> {
  for (const assertion of task.assertions) {
    // 创建临时测试文件（避免不安全的eval）
    const testFile = `.claude-temp-assertion-${task.number}.test.js`;

    await Write({
      file_path: testFile,
      content: `
const assert = require('assert');
try {
  ${assertion}
  console.log('ASSERTION_PASSED');
  process.exit(0);
} catch (error) {
  console.error('ASSERTION_FAILED:', error.message);
  process.exit(1);
}
`
    });

    const result = await Bash({ command: `node ${testFile}` });
    await Bash({ command: `rm -f ${testFile}` }); // 清理

    if (result.exitCode !== 0) {
      console.log(`❌ Assertion failed: ${assertion}`);
      return false;
    }
  }

  return true;
}
```

### Auto Regression Testing

```typescript
async function runRegressionTests(baseline?: TestResult): Promise<TestResult> {
  const result = await Bash({
    command: 'npm test -- --json --outputFile=test-results.json',
    timeout: 180000
  });

  const testResults = JSON.parse(await Read({ file_path: 'test-results.json' }));

  const current = {
    passed: result.exitCode === 0,
    totalTests: testResults.numTotalTests,
    passingTests: testResults.numPassedTests,
    newFailures: []
  };

  if (baseline) {
    // 检测新引入的失败
    const previouslyPassing = testResults.testResults.filter(
      test => test.status === 'failed' && wasPassingInBaseline(test.name, baseline)
    );
    current.newFailures = previouslyPassing.map(t => t.name);

    if (current.newFailures.length > 0) {
      console.log(`⚠️ 检测到${current.newFailures.length}个回归失败:`);
      current.newFailures.forEach(name => console.log(`  - ${name}`));
    }
  }

  return current;
}
```

### Performance Baseline Checking

```typescript
async function checkPerformanceBaseline(baseline?: PerformanceMetrics): Promise<boolean> {
  const buildStart = Date.now();
  await Bash({ command: 'npm run build' });
  const buildTime = Date.now() - buildStart;

  const testStart = Date.now();
  await Bash({ command: 'npm test' });
  const testTime = Date.now() - testStart;

  const current = { buildTime, testTime };

  if (baseline) {
    const buildRegression = (current.buildTime - baseline.buildTime) / baseline.buildTime;
    const testRegression = (current.testTime - baseline.testTime) / baseline.testTime;

    if (buildRegression > 0.5) { // 50%变慢
      console.log(`⚠️ Build时间回归: ${baseline.buildTime}ms → ${current.buildTime}ms (+${Math.round(buildRegression * 100)}%)`);
      return false;
    }

    if (testRegression > 0.3) { // 30%变慢
      console.log(`⚠️ Test时间回归: ${baseline.testTime}ms → ${current.testTime}ms (+${Math.round(testRegression * 100)}%)`);
      return false;
    }
  }

  return true;
}
```

---

## Confidence Scoring算法

### 完整评分公式

```typescript
async function scoreIssue(
  issue: Issue,
  globalConstraints: any,
  fileContent: string
): Promise<number> {
  let baseScore = 50;
  let evidenceBonus = 0;
  let impactBonus = 0;
  let documentationBonus = 0;
  let mitigationPenalty = 0;

  // === 1. Evidence Assessment (±20 points) ===
  const codeProof = verifyWithCode(issue, fileContent);

  if (codeProof.proven) {
    // 100%确定：实际读取代码并测量
    evidenceBonus = 20;
    console.log(`  ✓ PROVEN: ${codeProof.evidence}`);
  } else if (codeProof.likely) {
    // 80-90%确定：代码模式匹配
    evidenceBonus = 10;
    console.log(`  ~ LIKELY: ${codeProof.evidence}`);
  } else if (codeProof.assumption) {
    // <50%确定：仅基于假设
    evidenceBonus = -10;
    console.log(`  ? ASSUMPTION: ${codeProof.evidence}`);
  }

  // === 2. Impact Assessment (+30 points max) ===
  if (issue.category === 'security') {
    impactBonus = 30;
    console.log(`  ! IMPACT: Security issue (+30)`);
  } else if (issue.severity === 'critical') {
    impactBonus = 30;
    console.log(`  ! IMPACT: Critical severity (+30)`);
  } else if (issue.category === 'bug') {
    impactBonus = 20;
    console.log(`  ! IMPACT: Bug (+20)`);
  } else if (issue.category === 'performance') {
    impactBonus = 10;
    console.log(`  ! IMPACT: Performance (+10)`);
  } else if (issue.category === 'maintainability') {
    impactBonus = 5;
    console.log(`  ! IMPACT: Maintainability (+5)`);
  }

  // === 3. Documentation Check (+15 points max) ===
  const constraintViolation = checkConstraintViolations(issue, globalConstraints);
  if (constraintViolation) {
    documentationBonus += 10;
    console.log(`  ✓ DOCUMENTED: Violates ${constraintViolation} (+10)`);
  }

  const cweReference = issue.references?.some(ref => ref.includes('cwe.mitre.org'));
  if (cweReference) {
    documentationBonus += 5;
    console.log(`  ✓ DOCUMENTED: CWE reference (+5)`);
  }

  // === 4. Mitigation Check (-20 points max) ===
  const mitigations = checkMitigations(issue, fileContent);
  if (mitigations.safeguardsExist) {
    mitigationPenalty = 10;
    console.log(`  - MITIGATED: Safeguards exist (-10)`);
  } else if (mitigations.alreadyHandled) {
    mitigationPenalty = 20;
    console.log(`  - MITIGATED: Already handled (-20)`);
  }

  // === Final Score ===
  const finalScore = Math.max(0, Math.min(100,
    baseScore + evidenceBonus + impactBonus + documentationBonus - mitigationPenalty
  ));

  console.log(`  FINAL: ${finalScore}/100`);

  return finalScore;
}
```

### 评分示例

**示例1: 高分issue（95分）**

```
Issue: 函数过长（132行）

Evidence (PROVEN +20):
  - 实际读取文件，确认函数132行
  - 使用AST parser精确测量

Impact (Maintainability +5):
  - 影响代码可读性和维护性

Documentation (Constraint +10):
  - 违反CLAUDE.md: "Functions ≤30 lines"

Mitigation (None 0):
  - 没有任何mitigating factors

Final Score: 50 + 20 + 5 + 10 - 0 = 85分

实际得分: 95分（因为严重违反明确约束，加权）
```

**示例2: 中分issue（82分）**

```
Issue: N+1查询问题

Evidence (LIKELY +10):
  - 代码模式显示循环内查询
  - 未实际profiling验证

Impact (Performance +10):
  - 性能影响中等

Documentation (None 0):
  - 没有明确约束规定

Mitigation (Safeguards exist -10):
  - 当前数据量小（<100条）
  - 有pagination限制

Final Score: 50 + 10 + 10 + 0 - 10 = 60分

实际得分: 82分（考虑future scalability，加权）
```

**示例3: 低分issue（45分）**

```
Issue: 变量命名不一致

Evidence (ASSUMPTION -10):
  - 仅基于几个示例
  - 未全面检查代码库

Impact (Style +0):
  - 仅影响代码风格

Documentation (None 0):
  - 没有强制命名规范

Mitigation (Already handled -0):
  - 实际检查发现80%变量命名一致

Final Score: 50 - 10 + 0 + 0 - 0 = 40分

实际得分: 45分（保留作为改进建议）
```

### 阈值调整策略

```typescript
// 默认阈值
const DEFAULT_THRESHOLD = 80;

// 根据项目阶段调整
function getThreshold(projectPhase: string): number {
  switch (projectPhase) {
    case 'mvp':
      return 90; // MVP阶段只修复最关键问题
    case 'production':
      return 80; // 生产环境，标准阈值
    case 'refactoring':
      return 70; // 重构时可以修复更多问题
    default:
      return DEFAULT_THRESHOLD;
  }
}

// 用户可以手动调整
const userThreshold = 85; // 更严格
const filteredIssues = allIssues.filter(issue => issue.confidence >= userThreshold);
```

---

## 跨会话恢复

### State Machine结构

```typescript
interface ChangeState {
  // === Basic Info ===
  changeId: string;               // "001-user-login"
  currentPhase: 0 | 1 | 2 | 3 | 4 | 5 | 6;
  status: 'active' | 'completed' | 'cancelled';
  createdAt: Date;
  updatedAt: Date;

  // === User Decisions ===
  userDecisions: {
    phase1Approval?: 'yes' | 'no' | 'refine';
    phase1RefineCount?: number;
    phase3SelectedApproach?: 1 | 2 | 3;
    phase5IssueDecision?: 'fix-all' | 'fix-critical' | 'accept';
  };

  // === OODA State (Phase 4) ===
  ooda: {
    iterationCount: number;
    lastCompletedTask?: string;
    completionPromise: 'PENDING' | 'DONE';
    iterationHistory: {
      iteration: number;
      completedTasks: string[];
      testsStatus: 'passed' | 'failed';
      buildStatus: 'success' | 'failed';
      timestamp: Date;
    }[];
  };

  // === Phase Outputs ===
  outputs: {
    phase0Context?: string;   // "changes/active/001/phase0-context.md"
    phase1Proposal?: string;  // "changes/active/001/proposal.md"
    phase2Discovery?: string; // "changes/active/001/evidence.md"
    phase3Design?: string;    // "changes/active/001/design.md"
    phase4Tasks?: string;     // "changes/active/001/tasks.md"
    phase5IssuesRaw?: string; // "changes/active/001/issues-raw.json"
    phase5IssuesScored?: string; // "changes/active/001/issues-scored.json"
  };

  // === Quality Metrics ===
  quality: {
    testCoverage?: number;
    issuesFound?: number;
    issuesFixed?: number;
    confidenceThreshold?: number;
    finalScore?: number;
  };

  // === Knowledge Integration ===
  knowledge: {
    appliedPatterns: string[]; // ["PATTERN-023"]
    preventedErrors: string[]; // ["ERROR-012"]
    relatedPatterns?: string[]; // 查询到但未应用
    relatedErrors?: string[];   // 查询到的历史错误
  };

  // === Phase History ===
  phaseHistory: {
    phase: number;
    startTime: Date;
    endTime?: Date;
    duration?: number; // seconds
    status: 'in_progress' | 'completed' | 'failed';
    verificationStatus?: 'passed' | 'failed';
    verificationTime?: Date;
  }[];

  // === Resumability ===
  resumability: {
    canResume: boolean;
    resumeFrom: string; // "Phase 4, Task 5"
    lastSessionTime: Date;
    nextAction: string; // "Continue OODA loop from Task 6"
  };
}
```

### 读写State

```typescript
// 读取state
async function readState(changeId: string): Promise<ChangeState | null> {
  const statePath = `changes/active/${changeId}/state.json`;

  try {
    const content = await Read({ file_path: statePath });
    return JSON.parse(content);
  } catch (error) {
    console.log(`⚠️ State file not found for ${changeId}`);
    return null;
  }
}

// 写入state
async function writeState(changeId: string, updates: Partial<ChangeState>): Promise<void> {
  const statePath = `changes/active/${changeId}/state.json`;

  // 读取现有state
  let state = await readState(changeId);

  if (!state) {
    // 初始化新state
    state = {
      changeId,
      currentPhase: 0,
      status: 'active',
      createdAt: new Date(),
      updatedAt: new Date(),
      userDecisions: {},
      ooda: {
        iterationCount: 0,
        completionPromise: 'PENDING',
        iterationHistory: []
      },
      outputs: {},
      quality: {},
      knowledge: {
        appliedPatterns: [],
        preventedErrors: []
      },
      phaseHistory: [],
      resumability: {
        canResume: false,
        resumeFrom: 'Phase 0',
        lastSessionTime: new Date(),
        nextAction: 'Start knowledge check'
      }
    };
  }

  // 合并更新
  Object.assign(state, updates);
  state.updatedAt = new Date();

  // 写入文件
  await Write({
    file_path: statePath,
    content: JSON.stringify(state, null, 2)
  });

  console.log(`✅ State updated for ${changeId}`);
}

// 更新phase历史
async function recordPhaseCompletion(changeId: string, phase: number): Promise<void> {
  const state = await readState(changeId);
  if (!state) return;

  const phaseEntry = state.phaseHistory.find(p => p.phase === phase);

  if (phaseEntry) {
    phaseEntry.endTime = new Date();
    phaseEntry.duration = (phaseEntry.endTime.getTime() - phaseEntry.startTime.getTime()) / 1000;
    phaseEntry.status = 'completed';
  } else {
    state.phaseHistory.push({
      phase,
      startTime: new Date(),
      endTime: new Date(),
      duration: 0,
      status: 'completed'
    });
  }

  await writeState(changeId, { phaseHistory: state.phaseHistory });
}
```

### 恢复会话

```typescript
async function resumeChange(changeId: string): Promise<void> {
  console.log(`🔄 Resuming change ${changeId}...`);

  // 1. 读取state
  const state = await readState(changeId);
  if (!state) {
    throw new Error(`Cannot find state for ${changeId}`);
  }

  if (!state.resumability.canResume) {
    throw new Error(`Change ${changeId} cannot be resumed`);
  }

  console.log(`📍 Resuming from: ${state.resumability.resumeFrom}`);
  console.log(`🎯 Next action: ${state.resumability.nextAction}`);

  // 2. 根据当前phase恢复
  switch (state.currentPhase) {
    case 1:
      // Phase 1中断：重新请求审批
      await phase1ApprovalGate(changeId);
      break;

    case 2:
      // Phase 2中断：继续探索
      await continueDiscovery(changeId, state);
      break;

    case 3:
      // Phase 3中断：重新请求方案选择
      await phase3SelectionGate(changeId);
      break;

    case 4:
      // Phase 4中断：继续OODA循环
      await resumeOODALoop(changeId, state);
      break;

    case 5:
      // Phase 5中断：继续代码审查
      await resumeQualityValidation(changeId, state);
      break;

    case 6:
      // Phase 6中断：完成finalization
      await resumeFinalization(changeId, state);
      break;

    default:
      throw new Error(`Unknown phase: ${state.currentPhase}`);
  }
}

// 恢复OODA循环（最复杂的情况）
async function resumeOODALoop(changeId: string, state: ChangeState): Promise<void> {
  console.log(`🔄 Resuming OODA loop from iteration ${state.ooda.iterationCount}...`);

  // 读取tasks.md
  const tasksPath = state.outputs.phase4Tasks!;
  const tasks = await parseTasksFile(tasksPath);

  // 找到上次完成的任务
  const lastCompletedTask = state.ooda.lastCompletedTask;
  console.log(`✅ Last completed: ${lastCompletedTask}`);

  // 找到下一个未完成的任务
  const nextTask = findNextTask(tasks);
  console.log(`🎯 Next task: ${nextTask.description}`);

  // 继续OODA循环
  await ralphWiggumOODALoop(changeId);
}
```

### 最佳实践

**DO**:
- ✅ 每个phase完成后立即更新state
- ✅ OODA每次迭代后更新state（防止中断丢失进度）
- ✅ 中断前检查state.json是否正确保存
- ✅ 恢复前查看resumability.nextAction了解下一步

**DON'T**:
- ❌ 不要手动编辑state.json（格式错误会导致无法恢复）
- ❌ 不要删除changes/active/目录（会丢失所有state）
- ❌ 不要在多个session同时操作同一个change（会导致state冲突）

---

## 最佳实践

### 项目初始化

```bash
# 1. 首次使用，初始化项目
cd your-project
"init project 用户管理系统"

# 2. 配置权限（避免频繁确认）
cat > .claude/settings.json <<EOF
{
  "permissionMode": "dontAsk",
  "allowedCommands": [
    "npm test",
    "npm run build",
    "npm run lint",
    "tsc --noEmit",
    "git status",
    "git diff",
    "git add .",
    "git commit -m *"
  ],
  "allowedPaths": [
    "src/**",
    "changes/**",
    "knowledge/**"
  ]
}
EOF

# 3. 创建全局约束文档
cat > requirements.md <<EOF
# Requirements

## Security
- REQ-SEC-001: 所有用户输入必须验证
- REQ-SEC-002: 密码必须hash存储（bcrypt）

## Performance
- REQ-PERF-001: API响应时间<200ms (p95)
EOF

cat > CLAUDE.md <<EOF
# CLAUDE Constraints

## Code Style
- CLD-FUNC-001: Functions ≤30 lines
- CLD-FILE-001: Files ≤500 lines
- CLD-NEST-001: Nesting depth ≤3

## Testing
- CLD-TEST-001: Test coverage ≥80%
EOF
```

### 功能开发流程

```bash
# 1. 描述需求（ai-dev自动开始7-Phase流程）
"添加用户登录功能，支持邮箱密码登录"

# 2. Phase 1审批（查看proposal.md，确认需求理解）
cat changes/active/001-user-login/proposal.md
# 选择: Yes

# 3. Phase 3选择方案（查看design.md，选择approach）
cat changes/active/001-user-login/design.md
# 选择: 2 (Clean)

# 4. Phase 4自动完成（无需干预，等待2-3小时）
# OODA循环自动运行，可以随时查看进度：
watch -n 10 'tail -20 changes/active/001-user-login/tasks.md'

# 5. Phase 5决定修复（查看高分issues）
cat changes/active/001-user-login/issues-scored.json
# 选择: Fix All

# 6. Phase 6自动完成（提交代码+更新知识库）
# 完成！检查commit
git log -1 --stat
```

### 中断和恢复

```bash
# 中断开发（Ctrl+C）
# state.json自动保存当前进度

# 稍后恢复
"继续完成001-user-login"
# 系统读取state.json，从断点继续
```

### 查看进度

```bash
# 实时查看tasks.md
tail -f changes/active/001-user-login/tasks.md

# 查看当前phase
jq '.currentPhase' changes/active/001-user-login/state.json

# 查看OODA迭代次数
jq '.ooda.iterationCount' changes/active/001-user-login/state.json

# 查看质量指标
jq '.quality' changes/active/001-user-login/state.json
```

### 知识库维护

```bash
# 查看所有patterns
jq '.[] | select(.successRate >= 90)' knowledge/patterns.json

# 查看未解决的errors
jq '.[] | select(.resolved == false)' knowledge/errors.json

# 查看最近学到的经验
tail -50 knowledge/learnings.md

# 与团队共享
git add knowledge/
git commit -m "chore: update knowledge base"
git push
```

---

## 高级配置

### 自定义Workflow

```typescript
// workflows/custom-workflow.json
{
  "name": "quick-fix-workflow",
  "description": "快速修复小bug，跳过部分phase",
  "phases": [
    { "phase": 1, "required": true, "agent": "requirement-analyzer" },
    { "phase": 2, "skip": true }, // 跳过discovery
    { "phase": 3, "skip": true }, // 跳过design
    { "phase": 4, "required": true, "maxIterations": 3 }, // 限制迭代次数
    { "phase": 5, "required": true, "threshold": 90 }, // 更高threshold
    { "phase": 6, "required": true }
  ]
}
```

### 调整Confidence Threshold

```typescript
// .claude/ai:dev-config.json
{
  "confidenceScoring": {
    "defaultThreshold": 80,
    "categoryThresholds": {
      "security": 70,      // 安全问题：更宽松（不要漏掉）
      "bug": 75,           // Bug：较宽松
      "performance": 85,   // 性能：较严格
      "style": 95          // 风格：非常严格
    },
    "weights": {
      "evidence": 1.0,
      "impact": 1.2,       // 提高impact权重
      "documentation": 0.8,
      "mitigation": 1.0
    }
  }
}
```

### 自定义Agent Permissions

```json
// .claude/settings.json
{
  "permissionMode": "dontAsk",
  "allowedCommands": [
    "npm test",
    "npm run build",
    "npm run lint",
    "tsc --noEmit",
    "git status",
    "git diff",
    "git add .",
    "git commit -m *",
    "docker-compose up -d",  // 允许启动docker
    "psql -c *"              // 允许数据库查询
  ],
  "dangerousCommands": [
    "rm -rf",
    "git push --force",
    "npm publish"
  ],
  "rateLimit": {
    "bash": 100,  // 每分钟最多100次bash命令
    "write": 50,  // 每分钟最多50次文件写入
    "task": 10    // 每分钟最多10次agent调用
  }
}
```

---

## 故障排除

### Phase 4 OODA循环卡住

**症状**: 超过5次迭代仍未完成任何任务

**可能原因**:
1. tasks.md任务定义不清晰
2. Assertions太严格或错误
3. 测试环境问题

**解决方案**:

```bash
# 1. 检查tasks.md
cat changes/active/XXX/tasks.md

# 如果任务太模糊，手动调整：
# "添加用户功能" → 拆分为更具体的子任务

# 2. 检查assertions
# 如果assertion错误，临时移除assertions字段

# 3. 检查测试环境
npm test  # 手动运行测试，看是否有环境问题
npm run build

# 4. 如果仍然卡住，手动介入
"暂停OODA，让我手动完成Task 5"
# 手动写代码
# 然后让OODA继续
"继续OODA循环"
```

### Confidence Scoring过滤太多

**症状**: Phase 5显示0个高分issues，但代码明显有问题

**解决方案**:

```bash
# 1. 查看所有原始issues
cat changes/active/XXX/issues-raw.json | jq '.issues | length'
# 假设显示25个

# 2. 查看过滤后的issues
cat changes/active/XXX/issues-scored.json | jq '.filtered | length'
# 假设显示0个

# 3. 降低threshold
# 在Phase 5时，手动调整threshold:
"重新评分issues，threshold设为70"

# 或者查看60-80分的issues:
cat changes/active/XXX/issues-scored.json | \
  jq '.issues[] | select(.confidence >= 60 and .confidence < 80)'
```

### State.json损坏

**症状**: 无法恢复change，报错"Invalid state.json"

**解决方案**:

```bash
# 1. 备份损坏的state
cp changes/active/XXX/state.json changes/active/XXX/state.json.backup

# 2. 验证JSON格式
jq '.' changes/active/XXX/state.json
# 如果有语法错误，手动修复

# 3. 如果无法修复，重建最小state
cat > changes/active/XXX/state.json <<EOF
{
  "changeId": "XXX",
  "currentPhase": 4,
  "status": "active",
  "createdAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "updatedAt": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "resumability": {
    "canResume": true,
    "resumeFrom": "Phase 4",
    "lastSessionTime": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "nextAction": "Resume OODA loop"
  }
}
EOF

# 4. 恢复
"继续完成XXX"
```

### Knowledge Base冲突

**症状**: 团队成员的patterns.json冲突

**解决方案**:

```bash
# 1. 查看冲突
git status
# both modified: knowledge/patterns.json

# 2. 手动合并（保留两边的patterns）
git checkout --ours knowledge/patterns.json
git checkout --theirs knowledge/patterns.json.remote
jq -s '.[0].patterns + .[1].patterns | unique_by(.id)' \
  knowledge/patterns.json knowledge/patterns.json.remote \
  > knowledge/patterns.json.merged

mv knowledge/patterns.json.merged knowledge/patterns.json

# 3. 提交
git add knowledge/patterns.json
git commit -m "chore: merge knowledge base"
```

---

## 附录

### 文件结构总览

```
your-project/
├── codebox/
│   ├── feature_list.json
│   ├── progress.txt
│   └── config.json
├── knowledge/
│   ├── patterns.json
│   ├── errors.json
│   └── learnings.md
├── changes/
│   ├── active/
│   │   └── 001-user-login/
│   │       ├── state.json
│   │       ├── phase0-context.md
│   │       ├── proposal.md
│   │       ├── evidence.md
│   │       ├── design.md
│   │       ├── tasks.md
│   │       ├── issues-raw.json
│   │       └── issues-scored.json
│   ├── staged/
│   └── archived/
├── requirements.md
├── design.md
├── CLAUDE.md
└── .claude/
    ├── settings.json
    └── ai-dev-config.json
```

### 快速参考

| 命令 | 说明 |
|------|------|
| `init project XXX` | 初始化项目 |
| `cat changes/active/XXX/tasks.md` | 查看进度 |
| `jq '.currentPhase' state.json` | 查看当前phase |
| `继续完成XXX` | 恢复change |
| `cat issues-scored.json | jq '.filtered'` | 查看高分issues |
| `git log -1` | 查看最近commit |

### 相关文档

- Quick Start: `docs/user-guide-quick-start.md`
- Complete Example: `examples/feature-development-complete-example.md`
- State Machine Spec: `references/state-machine-spec.md`
- OODA Loop: `references/ooda-loop.md`
- Confidence Scoring: `references/confidence-scoring.md`
- Knowledge Base Schema: `references/knowledge-base-schema.md`

---

**End of Complete User Guide**

**Last Updated**: 2024-01-04
**Version**: v2.0
**Feedback**: GitHub Issues
