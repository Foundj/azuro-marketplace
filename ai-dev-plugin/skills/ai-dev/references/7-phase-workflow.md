# 7-Phase Gated Workflow (v3.0)

> 工业级门控工作流：智能需求采访 + 竞品调研 + OODA 自主完成

---

## 🎯 概述

7-Phase Gated Workflow 是 ai-dev v3.0 的核心执行引擎，集成：

- **Phase 0**: 项目上下文感知（深度扫描 + git diff 增量）
- **Phase 0.5**: 竞品调研（Gemini 搜索 + Codex 分析）
- **Phase 1**: 多轮需求采访（requirement-interviewer）
- **Phase 2-3**: 设计审批 + 任务拆解
- **Phase 4**: OODA 自主完成（ooda-stop-hook.sh）
- **Phase 5**: 置信度过滤质量验证（≥80）
- **Phase 6**: 归档 + 知识更新

---

## 📊 工作流阶段概览

```
Phase 0: Context & Knowledge (上下文 + 知识预查)
   ↓ [自动执行]
Phase 0.5: Competitor Research (竞品调研) [新功能才触发]
   ↓ [自动执行/可跳过]
Phase 1: Requirement Interview (多轮需求采访)
   ↓ [用户回答 + 审批门 ✓]
Phase 2: Design Approval (设计审批)
   ↓ [用户选择门 ✓]
Phase 3: Task Breakdown (任务拆解)
   ↓ [自动执行]
Phase 4: OODA Implementation (实现 - OODA循环)
   ↓ [自主完成]
Phase 5: Quality Validation (质量验证)
   ↓ [用户决定门 ✓]
Phase 6: Finalization (完成)
   ↓ [自动执行]
Complete ✅
```

---

## Phase 0: Context & Knowledge (v3.0 Enhanced)

### 🎯 目的
在任何变更开始前，加载项目上下文，检测潜在问题，查询历史经验。

### 📋 执行步骤

1. **项目扫描**（使用 `scripts/scan-project.sh`）
   ```bash
   # 初次：深度扫描
   scan-project.sh deep
   
   # 日常：增量扫描
   scan-project.sh incremental  # 基于 git diff
   ```

2. **知识库查询**（使用 `scripts/query-knowledge.sh`）
   ```bash
   query-knowledge.sh query "user login"
   ```

3. **问题检测**（分级处理）
   
   | 级别 | 问题类型 | 处理方式 |
   |------|----------|----------|
   | 🔴 阻断级 | 重复功能、严重架构冲突 | 必须解决 |
   | 🟡 警告级 | 相似功能、轻微偏离 | 显示警告，用户选择 |
   | 🟢 建议级 | 历史模式、最佳实践 | 附加信息 |

4. **生成 phase0-context.md**
   ```markdown
   # Phase 0: Context Pre-Check
   
   ## Project Context
   - Tech Stack: Next.js 14, Drizzle, TypeScript
   - Modules: auth, users, posts
   - Recent Changes: 5 files in last 10 commits
   
   ## Knowledge Check
   - Related Pattern: PATTERN-001 (Repository Pattern)
   - Historical Error: ERROR-007 (N+1 query)
   - Prevention: Use pagination for lists
   
   ## Issues Detected
   - ⚠️ Warning: Similar feature "user list filter" exists
   ```

---

## Phase 0.5: Competitor Research (NEW in v3.0)

### 🎯 目的
理解用户意图，生成明确的需求文档（EARS 格式），获得用户确认。

### 📋 执行步骤

1. **读取全局约束**
   ```typescript
   const requirements = readFile('codebox/requirements.md');
   const design = readFile('codebox/design.md');
   const claudeMd = readFile('codebox/CLAUDE.md');
   ```

2. **启动 requirement-analyzer agent**
   ```typescript
   const proposal = await Task({
     subagent_type: 'requirement-analyzer',
     prompt: `
       用户请求: ${userRequest}

       全局需求: ${requirements}
       知识上下文: ${phase0Context}

       生成 proposal.md (EARS 格式)
     `
   });
   ```

3. **生成 proposal.md**
   ```markdown
   # Change Proposal: 001-user-auth

   ## 📚 知识预查 (Phase 0)
   [附加 phase0-context.md 内容]

   ## 引用全局需求
   - REQ-GLOBAL-001: API 规范
   - REQ-GLOBAL-002: 错误处理

   ## 本变更需求

   ### REQ-001: 用户登录功能
   **WHEN** 用户需要访问受保护资源
   **THE SYSTEM SHALL** 提供 JWT 认证机制
   **SO THAT** 用户身份得到验证

   ## What: 功能描述
   实现基于 JWT 的用户登录系统...

   ## Why: 用户价值
   用户可以安全地访问个人数据...

   ## Success Criteria
   - [ ] 用户可以用邮箱密码登录
   - [ ] 登录后获得 JWT token
   - [ ] Token 过期后自动刷新
   - [ ] 错误情况有明确提示
   ```

### 🚪 门控逻辑 (用户审批)

```typescript
const userApproval = await AskUserQuestion({
  questions: [{
    question: 'Does this proposal match your intent?',
    header: 'Approval',
    multiSelect: false,
    options: [
      { label: 'Yes, proceed', description: '需求理解正确，继续' },
      { label: 'No, cancel', description: '需求理解错误，取消' },
      { label: 'Refine', description: '需要修改和完善' }
    ]
  }]
});

if (userApproval === 'yes') {
  // → Phase 2 (if medium/complex) or Phase 3 (if simple)
} else if (userApproval === 'refine') {
  // → 重新 Phase 1
} else {
  return { action: 'cancel' };
}
```

### 📁 输出

- `changes/active/[change-id]/proposal.md`
- `state.json` 更新: `phase-1.status = completed`, `phase-1.user_approval = yes`

---

## Phase 2: Resource Discovery

### 🎯 目的
探索代码库，识别入口点、相似功能、数据流，为设计阶段提供证据。

### ⚡ 触发条件

**仅在 medium 或 complex 任务时执行**：
```typescript
if (complexity === 'simple') {
  skipPhase2();
  state.phases['phase-2-discovery'].status = 'skipped';
  state.phases['phase-2-discovery'].skip_reason = 'complexity=simple';
  // → 直接 Phase 3
}
```

### 📋 执行步骤

1. **并行启动 2-3 code-explorer agents**
   ```typescript
   const explorations = await Promise.all([
     Task({
       subagent_type: 'code-explorer',
       prompt: 'Perspective: Entry points and integration'
     }),
     Task({
       subagent_type: 'code-explorer',
       prompt: 'Perspective: Similar existing features'
     }),
     Task({
       subagent_type: 'code-explorer',
       prompt: 'Perspective: Data flow and dependencies'
     })
   ]);
   ```

2. **合并发现**
   ```typescript
   const mergedEvidence = mergeExplorations(explorations);
   ```

3. **读取识别的文件**
   ```typescript
   const identifiedFiles = mergedEvidence.filesToRead; // 5-15 files
   for (const file of identifiedFiles) {
     await Read({ file_path: file });
   }
   ```

4. **生成 evidence.md**
   ```markdown
   # Resource Discovery Evidence

   ## Entry Points
   - `src/app/api/auth/route.ts` - API endpoint
   - `src/components/LoginForm.tsx` - UI component

   ## Similar Features
   - User registration: `src/lib/services/UserService.ts`
   - Session management: `src/lib/session.ts`

   ## Data Flow
   ```
   LoginForm → API (/api/auth/login) → AuthService → UserRepository → Database
        ↓
   Store JWT in cookie
        ↓
   Redirect to dashboard
   ```

   ## Key Files to Modify
   1. `src/lib/services/AuthService.ts` (new)
   2. `src/lib/repositories/UserRepository.ts` (exists)
   3. `src/app/api/auth/login/route.ts` (new)
   4. `src/components/LoginForm.tsx` (new)

   ## Patterns Identified
   - Repository Pattern in use
   - Hono API structure
   - Zod validation standard
   ```

### 🚪 门控逻辑

无用户审批门，自动进入 Phase 3。

### 📁 输出

- `changes/active/[change-id]/evidence.md`
- `state.json` 更新: `phase-2.files_identified = [...]`

---

## Phase 3: Approach Design

### 🎯 目的
生成 2-3 种实现方案，权衡分析，让用户选择。

### 📋 执行步骤

1. **读取全局设计模式**
   ```typescript
   const globalDesign = readFile('codebox/design.md');
   ```

2. **并行启动 2-3 code-architect agents**
   ```typescript
   const approaches = await Promise.all([
     Task({
       subagent_type: 'code-architect',
       prompt: `
         Perspective: Minimal approach (fastest)
         Global design: ${globalDesign}
         Evidence: ${evidence}
       `
     }),
     Task({
       subagent_type: 'code-architect',
       prompt: 'Perspective: Clean approach (maintainable) ⭐'
     }),
     Task({
       subagent_type: 'code-architect',
       prompt: 'Perspective: Pragmatic approach (optimized)'
     })
   ]);
   ```

3. **生成 design.md**
   ```markdown
   # Design: 001-user-auth

   ## 架构遵循 (继承全局)

   ✅ 遵循分层架构 (Presentation → Application → Domain → Infrastructure)
   ✅ 使用 AppError 统一错误处理
   ✅ 符合 API 响应格式 ({ success, data/error })
   ✅ 使用 Repository Pattern

   ## 方案对比

   ### Approach 1: Minimal (2 hours)

   **实现**:
   - 单一 API endpoint: `/api/auth/login`
   - 直接在 route handler 中验证
   - 简单 JWT 签名

   **优点**:
   - 快速实现
   - 代码量少

   **缺点**:
   - 难以测试
   - 难以扩展（注册、找回密码）
   - 业务逻辑耦合

   **Build Sequence**:
   1. Create `/api/auth/login/route.ts`
   2. Add JWT signing
   3. Add tests

   ---

   ### Approach 2: Clean (4 hours) ⭐ Recommended

   **实现**:
   - Service Layer: `AuthService.ts`
   - Repository: `UserRepository.ts`
   - API endpoint: `/api/auth/login/route.ts`
   - Zod validation schemas

   **优点**:
   - 易于测试（可 mock repository）
   - 符合全局 design.md 架构
   - 易于扩展
   - 业务逻辑清晰

   **缺点**:
   - 需要更多时间
   - 文件更多

   **Build Sequence**:
   1. Create `IUserRepository` interface
   2. Create `UserRepository` implementation
   3. Create `AuthService` with DI
   4. Create API endpoint
   5. Add Zod schemas
   6. Add unit tests (service, repository)
   7. Add integration tests (API)

   ---

   ### Approach 3: Pragmatic (3 hours)

   **实现**:
   - Service Layer: `AuthService.ts`
   - 直接使用 Drizzle（无 Repository 抽象）
   - API endpoint + validation

   **优点**:
   - 平衡实现速度和质量
   - 适度抽象

   **缺点**:
   - Service 层耦合 Drizzle
   - 测试需要真实数据库

   **Build Sequence**:
   1. Create `AuthService.ts`
   2. Create API endpoint
   3. Add Zod validation
   4. Add integration tests

   ---

   ## 权衡分析

   | 维度 | Minimal | Clean ⭐ | Pragmatic |
   |------|---------|---------|-----------|
   | 开发时间 | 2h | 4h | 3h |
   | 可维护性 | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
   | 可测试性 | ⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ |
   | 可扩展性 | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ |
   | 架构合规 | ❌ | ✅ | ⚠️ |
   | 风险 | 高 | 低 | 中 |

   ## 推荐

   **Approach 2 (Clean)** - 虽然需要更多时间，但：
   - 符合全局 design.md 架构原则
   - 易于单元测试（关键路径 100% 覆盖）
   - 为未来扩展（注册、OAuth）奠定基础
   - 代码质量高，维护成本低
   ```

### 🚪 门控逻辑 (用户选择)

```typescript
const userChoice = await AskUserQuestion({
  questions: [{
    question: 'Select implementation approach:',
    header: 'Approach',
    multiSelect: false,
    options: [
      { label: '1 - Minimal (2h)', description: '最快实现，低质量' },
      { label: '2 - Clean (4h) [Recommended]', description: '标准实现，高质量' },
      { label: '3 - Pragmatic (3h)', description: '平衡实现，中质量' }
    ]
  }]
});

state.phases['phase-3-design'].selected_approach = userChoice;

// 合规性检查
const selectedApproach = approaches[parseInt(userChoice) - 1];
if (!isCompliantWithGlobalDesign(selectedApproach, globalDesign)) {
  console.warn('⚠️ 选定方案偏离全局架构，可能增加维护成本');
}

// → Phase 4
```

### 📁 输出

- `changes/active/[change-id]/design.md`
- `state.json` 更新: `phase-3.selected_approach = '2-clean'`

---

## Phase 4: Implementation (OODA Loop)

### 🎯 目的
自主执行实现任务，通过 OODA 循环持续进步，直到 `<promise>DONE</promise>`。

### 📋 执行步骤

#### 4.1 初始化 tasks.md

```markdown
# Implementation Tasks - 001-user-auth

## Build Sequence

- [ ] Create IUserRepository interface
- [ ] Create UserRepository implementation
- [ ] Create AuthService with DI
- [ ] Create API endpoint /api/auth/login
- [ ] Add Zod validation schemas
- [ ] Add unit tests (service, repository)
- [ ] Add integration tests (API)

## Completion Promise

<promise>PENDING</promise>

## Completion Criteria

- All checkboxes checked
- All tests pass: `npm test`
- Build succeeds: `npm run build`
- ESLint: 0 errors
- TypeScript: 0 errors

## Instructions

After each task:
1. Update checkbox to [x]
2. Run tests
3. If all complete AND tests pass, change PENDING → DONE

DO NOT output <promise>DONE</promise> until genuinely complete.
```

#### 4.2 OODA 循环

```typescript
async function oodaLoop(config) {
  for (let iteration = 1; iteration <= config.maxIterations; iteration++) {
    console.log(`OODA Iteration ${iteration}/${config.maxIterations}`);

    // ========== OBSERVE ==========
    const tasks = readTasks('tasks.md');
    const testResults = runTests();
    const buildStatus = checkBuild();
    const completionPromise = detectCompletionPromise('tasks.md');

    state.phases['phase-4-implementation'].ooda_iteration = iteration;

    // ========== ORIENT ==========
    const nextTask = findNextIncompleteTask(tasks);
    const blockers = identifyBlockers(testResults, buildStatus);

    if (!nextTask && allTestsPass && buildSucceeds) {
      // Ready to complete
      return decideDone();
    }

    // ========== DECIDE ==========
    let action;
    if (blockers.length > 0) {
      action = { type: 'fix', target: blockers[0] };
    } else if (nextTask) {
      action = { type: 'implement', task: nextTask };
    } else if (!allTestsPass) {
      action = { type: 'fix_tests' };
    } else {
      action = { type: 'done' };
    }

    // ========== ACT ==========
    await executeAction(action);
    updateTasksCheckbox('tasks.md', action.taskId);
    updateState();

    // Check completion
    if (completionPromise === 'DONE' && allTestsPass && buildSucceeds) {
      console.log('✅ Implementation complete!');
      return { success: true, iterations: iteration };
    }
  }

  // Max iterations reached
  console.error('⚠️ Max iterations reached without completion');
  return {
    success: false,
    reason: 'max_iterations',
    recommendation: 'Review tasks.md and identify blockers'
  };
}
```

#### 4.3 自我引用机制

**关键**: Agent 每次迭代都读取自己的 `tasks.md`：

```typescript
// 迭代 1
const tasks = readFile('tasks.md');
// tasks.checkboxes[0] = [ ] Create IUserRepository

implementTask('Create IUserRepository');

writeFile('tasks.md', updated); // [x] Create IUserRepository
```

```typescript
// 迭代 2
const tasks = readFile('tasks.md'); // 读取更新后的文件
// tasks.checkboxes[0] = [x] Create IUserRepository ✓
// tasks.checkboxes[1] = [ ] Create UserRepository implementation

implementTask('Create UserRepository implementation');
```

### 🚪 门控逻辑

无用户审批，自主执行直到：
- `<promise>DONE</promise>` 写入
- 所有 checkboxes 勾选
- 所有测试通过
- Build 成功

或达到最大迭代次数（10次）。

### 📁 输出

- `changes/active/[change-id]/tasks.md` (持续更新)
- 实现的代码文件
- 测试文件
- `state.json` 更新: `phase-4.ooda_iteration = N`, `phase-4.completion_promise = 'DONE'`

---

## Phase 5: Quality Validation

### 🎯 目的
通过置信度过滤的代码审查，只报告高置信度问题（≥80），减少噪音。

### 📋 执行步骤

#### 5.1 并行启动 3 code-reviewer agents

```typescript
const reviews = await Promise.all([
  Task({
    subagent_type: 'code-reviewer',
    prompt: `
      Perspective: CLAUDE.md compliance
      Review: ${implementedCode}
      CLAUDE.md: ${claudeMd}
    `
  }),
  Task({
    subagent_type: 'code-reviewer',
    prompt: 'Perspective: Simplicity and maintainability'
  }),
  Task({
    subagent_type: 'code-reviewer',
    prompt: 'Perspective: Bugs and edge cases'
  })
]);
```

#### 5.2 合并到唯一 issues

```typescript
const allIssues = reviews.flatMap(r => r.issues);
const uniqueIssues = deduplicateIssues(allIssues);
```

#### 5.3 置信度评分

```typescript
const scoredIssues = await Promise.all(
  uniqueIssues.map(async issue => {
    const score = await Task({
      subagent_type: 'confidence-scorer',
      model: 'haiku',  // 快速评分
      prompt: `
        Issue: ${issue.description}
        File: ${issue.file}:${issue.line}
        Code: ${issue.codeQuote}

        Score 0-100 based on:
        - Evidence quality
        - Guideline reference
        - Impact severity
        - Actionability
      `
    });

    return { ...issue, confidence: score.confidence };
  })
);
```

#### 5.4 过滤和排序

```typescript
const highConfidenceIssues = scoredIssues
  .filter(issue => issue.confidence >= 80)
  .sort((a, b) => b.confidence - a.confidence);

const lowConfidenceIssues = scoredIssues
  .filter(issue => issue.confidence < 80);
```

#### 5.5 生成审查报告

```markdown
# Code Review Report - 001-user-auth

## High-Confidence Issues (≥80) - 需要处理

### Issue 1: Missing input validation (Confidence: 95)

**文件**: `src/app/api/auth/login/route.ts:15-22`

**问题代码**:
```typescript
export async function POST(req: Request) {
  const { email, password } = await req.json();  // ❌ 无验证
  const result = await authService.login(email, password);
  ...
}
```

**问题**: 缺少输入验证，违反 REQ-GLOBAL-003 (数据验证)

**证据**:
- `constraints.md:149`: "使用 Zod 进行 schema 验证"
- 安全风险：注入攻击

**建议修复**:
```typescript
const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8)
});

export async function POST(req: Request) {
  const body = await req.json();
  const { email, password } = loginSchema.parse(body);  // ✅ Zod 验证
  ...
}
```

---

### Issue 2: Async error not handled (Confidence: 90)

**文件**: `src/lib/services/AuthService.ts:28-35`

**问题代码**:
```typescript
async login(email: string, password: string) {
  const user = await this.userRepo.findByEmail(email);  // ❌ 无 try-catch
  ...
}
```

**问题**: 未处理 Promise rejection，违反 ERROR-001 预防措施

**证据**:
- `knowledge/errors.json`: ERROR-001 (未处理 Promise rejection)
- `CLAUDE.md:错误处理`: "所有 async 函数必须 try-catch"

**建议修复**:
```typescript
async login(email: string, password: string) {
  try {
    const user = await this.userRepo.findByEmail(email);
    ...
    return { success: true, data: token };
  } catch (err) {
    return { success: false, error: toAppError(err) };
  }
}
```

---

## Low-Confidence Issues (<80) - 已过滤

共过滤 3 个低置信度问题：
- "Consider extracting magic number" (Confidence: 65)
- "Variable name could be more descriptive" (Confidence: 55)
- "Potential performance issue" (Confidence: 45)

这些问题已记录但不阻塞合并。

---

## 统计

- 总 issues: 5
- 高置信度 (≥80): 2 ⚠️
- 低置信度 (<80): 3 (已过滤)
```

### 🚪 门控逻辑 (用户决定)

```typescript
if (highConfidenceIssues.length === 0) {
  console.log('✅ No high-confidence issues found');
  // → Phase 6
} else {
  const userDecision = await AskUserQuestion({
    questions: [{
      question: `Found ${highConfidenceIssues.length} high-confidence issues. How to proceed?`,
      header: 'Fix Issues',
      multiSelect: false,
      options: [
        { label: 'Fix all', description: '修复所有高置信度问题' },
        { label: 'Fix critical only', description: '仅修复 confidence ≥90' },
        { label: 'Skip (accept risk)', description: '跳过，接受风险' }
      ]
    }]
  });

  if (userDecision === 'fix-all' || userDecision === 'fix-critical-only') {
    // → 回到 Phase 4, 新增 OODA iteration 修复 issues
    return { action: 'back_to_phase_4', issues: issuesToFix };
  } else {
    // → Phase 6 (用户接受风险)
    console.warn('⚠️ 用户选择跳过高置信度问题');
  }
}
```

### 📁 输出

- `changes/active/[change-id]/review-report.md`
- `state.json` 更新: `phase-5.issues_found = 5`, `phase-5.high_confidence_issues = 2`

---

## Phase 6: Finalization

### 🎯 目的
Git commit, 归档变更, 更新知识库, 推荐下一个特性。

### 📋 执行步骤

#### 6.1 Git Commit

```bash
# 检查状态
git status

# 生成提交信息
COMMIT_MSG="feat(auth): implement JWT login

- Add AuthService with dependency injection
- Add UserRepository with Drizzle ORM
- Add /api/auth/login endpoint
- Add Zod validation schemas
- Add unit tests (coverage: 95%)
- Add integration tests

Implements: 001-user-auth
Refs: REQ-GLOBAL-001, REQ-GLOBAL-002

🤖 Generated with Claude Code
Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# 提交
git add src/lib/services/AuthService.ts \
        src/lib/repositories/UserRepository.ts \
        src/app/api/auth/login/route.ts \
        ...

git commit -m "$COMMIT_MSG"

# 记录 commit hash
COMMIT_HASH=$(git rev-parse HEAD)
```

#### 6.2 更新 feature_list.json

```typescript
const featureList = JSON.parse(readFile('codebox/feature_list.json'));

// 更新 feature
const feature = featureList.features.find(f => f.change_id === '001-user-auth');
feature.passes = true;
feature.lifecycle.stage = 'completed';
feature.lifecycle.completed_at = new Date().toISOString();
feature.quality.build_status = 'success';
feature.quality.test_coverage = 95;

// 更新统计
featureList.statistics.completed_features++;
featureList.statistics.completion_rate =
  (featureList.statistics.completed_features / featureList.statistics.total_features) * 100;

// 从 active 移除
featureList.changes.active = featureList.changes.active.filter(
  c => c.id !== '001-user-auth'
);

// 增加 archived 计数
featureList.changes.archived_count++;

writeFile('codebox/feature_list.json', JSON.stringify(featureList, null, 2));
```

#### 6.3 追加 progress.txt

```bash
echo "$(date): ✅ Feature #1 完成 - 用户 JWT 登录 (001-user-auth)" >> codebox/progress.txt
echo "  - Commit: $COMMIT_HASH" >> codebox/progress.txt
echo "  - OODA iterations: 5" >> codebox/progress.txt
echo "  - Test coverage: 95%" >> codebox/progress.txt
echo "" >> codebox/progress.txt
```

#### 6.4 归档变更

```bash
YEAR_MONTH=$(date +"%Y-%m")
ARCHIVE_DIR="codebox/changes/archived/$YEAR_MONTH"

mkdir -p "$ARCHIVE_DIR"

mv "codebox/changes/active/001-user-auth" \
   "$ARCHIVE_DIR/001-user-auth"

echo "✅ 已归档到 $ARCHIVE_DIR/001-user-auth"
```

#### 6.5 更新知识库

```typescript
// 1. 更新成功模式使用次数
const patterns = JSON.parse(readFile('codebox/knowledge/patterns.json'));
const usedPatterns = ['PATTERN-001', 'PATTERN-002']; // 从 proposal.md 提取

usedPatterns.forEach(patternId => {
  const pattern = patterns.patterns.find(p => p.id === patternId);
  if (pattern) {
    pattern.usage_count++;
    pattern.success_rate = calculateSuccessRate(pattern);
  }
});

writeFile('codebox/knowledge/patterns.json', JSON.stringify(patterns, null, 2));

// 2. 追加经验总结
const learnings = `
## 📅 ${new Date().toISOString().split('T')[0]} - 用户 JWT 登录

### ✅ 成功经验
- **模式应用**: PATTERN-001 (Repository Pattern) 在认证模块运作良好，测试覆盖率 95%
- **技术选型**: Zod 验证 + bcrypt 加密，符合安全标准
- **架构决策**: Service Layer + Repository 分层，业务逻辑清晰

### 💡 建议
- 未来认证功能（注册、OAuth）可复用 AuthService 和 UserRepository 结构
- Zod schema 可提取为共享模块
`;

appendFile('codebox/knowledge/learnings.md', learnings);

console.log('✅ 知识库已更新');
```

#### 6.6 推荐下一个特性

```typescript
const nextFeatures = featureList.features.filter(f => !f.passes && !f.archived);

if (nextFeatures.length > 0) {
  const recommended = nextFeatures[0]; // 可以用更智能的算法

  console.log(`
📋 下一个推荐特性:

Feature #${recommended.id}: ${recommended.description}

建议执行: "ai 实现 Feature #${recommended.id}"
  `);
} else {
  console.log('🎉 所有特性已完成！');
}
```

### 🚪 门控逻辑

无用户审批，自动执行。

### 📁 输出

- Git commit (with hash)
- 更新的 `feature_list.json`
- 更新的 `progress.txt`
- 归档的变更目录
- 更新的 `knowledge/` 库

---

## 📊 状态持久化 (state.json)

每个阶段都更新 `state.json`，实现可恢复性：

```json
{
  "change_id": "001-user-auth",
  "workflow_id": "feature-development-v1",
  "status": "completed",

  "phases": {
    "phase-0-knowledge-check": {
      "status": "completed",
      "started_at": "2025-01-02T10:00:00Z",
      "completed_at": "2025-01-02T10:02:00Z",
      "artifacts": ["phase0-context.md"]
    },
    "phase-1-clarification": {
      "status": "completed",
      "user_approval": "yes",
      "artifacts": ["proposal.md"]
    },
    "phase-2-discovery": {
      "status": "completed",
      "files_identified": ["UserService.ts", "session.ts"]
    },
    "phase-3-design": {
      "status": "completed",
      "selected_approach": "2-clean",
      "user_choice": "2-clean"
    },
    "phase-4-implementation": {
      "status": "completed",
      "ooda_iteration": 5,
      "completion_promise": "DONE"
    },
    "phase-5-quality": {
      "status": "completed",
      "issues_found": 2,
      "high_confidence_issues": 2,
      "user_decision": "fix-all"
    },
    "phase-6-finalization": {
      "status": "completed",
      "git_committed": true,
      "commit_hash": "abc123...",
      "archived": true
    }
  },

  "resumability": {
    "can_resume": false,
    "resume_from": null
  }
}
```

---

## 🔄 恢复中断的工作流

```typescript
async function resumeWorkflow(changeId: string) {
  const statePath = `codebox/changes/active/${changeId}/state.json`;
  const state = JSON.parse(readFile(statePath));

  if (!state.resumability.can_resume) {
    console.error('❌ Workflow cannot be resumed');
    return;
  }

  const resumeFrom = state.resumability.resume_from;
  console.log(`🔄 Resuming from ${resumeFrom}...`);

  // 读取上下文文件
  state.resumability.context_files.forEach(file => {
    const content = readFile(`codebox/changes/active/${changeId}/${file}`);
    console.log(`📄 Loaded: ${file}`);
  });

  // 继续执行
  switch (resumeFrom) {
    case 'phase-4-implementation':
      const currentIteration = state.phases['phase-4-implementation'].ooda_iteration;
      console.log(`Continuing OODA loop from iteration ${currentIteration + 1}`);
      await oodaLoop({ startFrom: currentIteration + 1 });
      break;
    // ...其他阶段
  }
}
```

---

## 🎯 关键创新总结

1. **Phase 0 知识预查** - 事前预防胜于事后修复
2. **全局约束强制执行** - 确保多 feature 一致性
3. **EARS 格式需求** - 明确 WHEN...SHALL...SO THAT
4. **多视角 agents 并行** - 探索和设计阶段 2-3 个视角
5. **OODA 自主完成循环** - 减少用户干预，提高效率
6. **置信度过滤** - 减少 80% 代码审查噪音
7. **持久化状态机** - 支持跨会话恢复
8. **知识闭环** - 每次执行都学习，错误不重复

---

**核心价值**: 工业级质量 + 自主化执行 + 知识积累，让 AI 真正成为可信赖的开发伙伴。
