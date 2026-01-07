# Complete Feature Development Example with ai-dev v2.0

> **Purpose**: 完整演示从需求到完成的7-Phase工作流，展示所有验证机制和自我完成能力
> **Feature**: 为博客系统添加评论功能（Comment System）
> **Duration**: 模拟完整流程（约2小时实际工作量）

---

## 📋 User Request

```
用户需求：我想在博客文章下面添加评论功能，用户可以发表评论、回复他人评论、点赞评论。
```

---

## 🚀 Phase 0: Knowledge Check (2分钟)

### Hook触发: pre-change-check

**系统自动执行**:

```typescript
// Hook: pre-change-check.md
async function executeKnowledgeCheck() {
  console.log('🔍 Phase 0: Checking knowledge base...');

  // 1. 查询 patterns.json
  const patterns = await queryPatterns('comment', 'user-interaction');
  // 找到: PATTERN-012 "Nested Comment Pattern"
  // 找到: PATTERN-034 "Optimistic UI Update"

  // 2. 查询 errors.json
  const errors = await queryErrors('comment', 'XSS', 'SQL injection');
  // 找到: ERROR-007 "Comment XSS vulnerability"
  // 找到: ERROR-019 "SQL injection in nested queries"

  // 3. 生成 phase0-context.md
  await generatePhase0Context({
    relevantPatterns: [patterns[0], patterns[1]],
    relevantErrors: [errors[0], errors[1]],
    recommendations: [
      '使用Nested Comment Pattern处理评论嵌套',
      '注意XSS防护：sanitize用户输入',
      '使用参数化查询防止SQL注入'
    ]
  });

  console.log('✅ Phase 0 完成 - 历史知识已应用');
}
```

**输出**: `changes/active/003-comment-system/phase0-context.md`

```markdown
# Phase 0 Knowledge Context

## 相关模式
- **PATTERN-012**: Nested Comment Pattern (成功率: 95%, 使用次数: 8)
- **PATTERN-034**: Optimistic UI Update (成功率: 90%, 使用次数: 12)

## 历史错误
- **ERROR-007**: Comment XSS vulnerability (发生次数: 2, 严重程度: high)
  - 原因: 未sanitize用户输入
  - 预防: 使用DOMPurify库

## 建议
1. ✅ 使用现有的Nested Comment Pattern
2. ⚠️ 必须防XSS（历史教训）
3. ✅ 参考PATTERN-034实现乐观更新
```

---

## 📝 Phase 1: Requirements Analysis (15分钟)

### Agent: requirement-analyzer

**执行**:

```bash
# ai-dev自动spawn
Task({
  subagent_type: 'requirement-analyzer',
  prompt: `分析需求：博客评论系统...`,
  context: {
    phase0Context: 'changes/active/003-comment-system/phase0-context.md',
    globalConstraints: ['requirements.md', 'design.md', 'CLAUDE.md']
  }
})
```

**输出**: `changes/active/003-comment-system/proposal.md`

```markdown
# Proposal: Comment System for Blog

## 📋 Summary
为博客文章添加评论功能，支持嵌套回复、点赞、编辑删除

## 🎯 Tech Stack
- **Frontend**: React + TypeScript
- **Backend**: Hono API
- **Database**: Drizzle ORM (PostgreSQL)
- **Validation**: Zod schema
- **Security**: DOMPurify (XSS防护)

## 🔒 Constraints
引用自全局约束：
- `requirements.md`: REQ-SEC-001 (所有用户输入必须验证)
- `design.md`: DES-DB-003 (使用Drizzle ORM)
- `CLAUDE.md`: CLD-FUNC-001 (函数≤30行)

应用历史模式：
- `PATTERN-012`: Nested Comment Pattern
- 预防历史错误 `ERROR-007`: XSS vulnerability

## ⏱️ Time Estimate
- Core implementation: 2h
- Testing: 1h
- Total: **3h** (符合21天Sprint)

## ✅ Success Criteria
1. 用户可发表评论
2. 支持3层嵌套回复
3. 点赞功能正常
4. 通过XSS安全测试
5. 测试覆盖率≥80%
```

### 🚪 Gate #1: User Approval (Phase 1)

**系统提示**:

```
🚪 Phase 1 审批

需求理解是否正确？

请查看: changes/active/003-comment-system/proposal.md

选项:
1. Yes - 继续 (需求理解正确，进入Phase 2)
2. Refine - 修正 (需求理解有误，重新分析)
3. No - 取消 (取消此次变更)
```

**用户选择**: `Yes - 继续`

**系统记录**:

```typescript
// 写入 state.json
{
  "changeId": "003-comment-system",
  "currentPhase": 1,
  "userDecisions": {
    "phase1Approval": {
      "decision": "yes",
      "timestamp": "2024-01-04T10:00:00Z"
    }
  }
}
```

---

## 🔍 Phase 2: Discovery (20分钟)

### Agent: code-explorer

**执行**:

```typescript
Task({
  subagent_type: 'code-explorer',
  prompt: `探索博客系统现有代码，找到：
    1. 现有的数据库schema文件
    2. API endpoint定义位置
    3. React组件结构
    4. 认证middleware`,
  thoroughness: 'medium'
})
```

**输出**: `changes/active/003-comment-system/evidence.md`

```markdown
# Discovery: Existing Codebase Analysis

## 🗂️ Key Files

### Database Schema
- **File**: `src/db/schema/posts.ts`
- **Pattern**: 使用Drizzle ORM定义table
- **Example**:
  ```typescript
  export const posts = pgTable('posts', {
    id: serial('id').primaryKey(),
    title: text('title').notNull(),
    content: text('content').notNull(),
    authorId: integer('author_id').references(() => users.id),
    createdAt: timestamp('created_at').defaultNow()
  });
  ```
- **Action**: 创建类似的 `comments` table

### API Endpoints
- **File**: `src/api/posts/index.ts`
- **Pattern**: Hono router with Zod validation
- **Example**:
  ```typescript
  app.post('/posts', zValidator('json', createPostSchema), async (c) => {
    const data = c.req.valid('json');
    // ... insert logic
  });
  ```
- **Action**: 创建 `src/api/comments/index.ts`

### React Components
- **Directory**: `src/components/blog/`
- **Existing**: `PostCard.tsx`, `PostDetail.tsx`
- **Pattern**: 函数组件 + hooks
- **Action**: 创建 `CommentSection.tsx`, `CommentItem.tsx`

### Authentication
- **Middleware**: `src/middleware/auth.ts`
- **Function**: `requireAuth()`
- **Usage**: 保护需要登录的endpoints

## 🔗 Dependencies
- React 18.2
- Hono 3.11
- Drizzle ORM 0.29
- Zod 3.22
- DOMPurify 3.0 (需要安装)

## 📊 Existing Patterns
✅ 使用Drizzle relations定义关联
✅ API统一使用Zod验证
✅ 组件使用TypeScript + Props interface
✅ 测试使用Vitest

## ⚠️ Constraints to Follow
- 所有新表必须有 `createdAt` 和 `updatedAt`
- API必须有rate limiting
- 组件必须有loading和error状态
```

**验证点 #3: Discovery Completeness**

```typescript
// 自动检查
const discoveryChecks = {
  keyFilesIdentified: discovery.includes('Key Files'),
  patternsDocumented: discovery.includes('Existing Patterns'),
  dependenciesListed: discovery.includes('Dependencies')
};

if (Object.values(discoveryChecks).every(Boolean)) {
  console.log('✅ Phase 2 Discovery 完整');
} else {
  console.log('⚠️ Discovery不完整，返回Phase 2');
}
```

---

## 🏗️ Phase 3: Design (30分钟)

### Agent: code-architect

**执行**:

```typescript
Task({
  subagent_type: 'code-architect',
  prompt: `基于evidence.md，设计评论系统的3个实现方案...`,
  context: {
    discovery: 'changes/active/003-comment-system/evidence.md',
    phase0Context: 'changes/active/003-comment-system/phase0-context.md'
  }
})
```

**输出**: `changes/active/003-comment-system/design.md`

```markdown
# Design: Comment System Implementation

## 🎨 Approach 1: Minimal (快速实现) - 2h

### Database Schema
```typescript
// src/db/schema/comments.ts
export const comments = pgTable('comments', {
  id: serial('id').primaryKey(),
  postId: integer('post_id').references(() => posts.id).notNull(),
  authorId: integer('author_id').references(() => users.id).notNull(),
  content: text('content').notNull(),
  parentId: integer('parent_id').references(() => comments.id), // 自引用
  likes: integer('likes').default(0),
  createdAt: timestamp('created_at').defaultNow()
});
```

### API Endpoints (Hono)
- `POST /api/comments` - 创建评论
- `GET /api/posts/:id/comments` - 获取文章评论
- `POST /api/comments/:id/like` - 点赞评论

### Frontend Components
- `CommentSection.tsx` - 评论列表容器
- `CommentItem.tsx` - 单条评论显示

**Tradeoffs**:
- ✅ 实现快速
- ❌ 嵌套评论查询性能一般（每次递归查询）
- ❌ 无编辑/删除功能
- ❌ 技术债较多

---

## 🎨 Approach 2: Clean (推荐) - 4h

### Database Schema
```typescript
// Materialized Path Pattern for nested comments
export const comments = pgTable('comments', {
  id: serial('id').primaryKey(),
  postId: integer('post_id').references(() => posts.id).notNull(),
  authorId: integer('author_id').references(() => users.id).notNull(),
  content: text('content').notNull(),
  parentId: integer('parent_id').references(() => comments.id),
  path: text('path').notNull(), // "1.2.5" for nested structure
  depth: integer('depth').default(0).notNull(),
  likes: integer('likes').default(0),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
  deletedAt: timestamp('deleted_at') // Soft delete
});

export const commentLikes = pgTable('comment_likes', {
  id: serial('id').primaryKey(),
  commentId: integer('comment_id').references(() => comments.id).notNull(),
  userId: integer('user_id').references(() => users.id).notNull(),
  createdAt: timestamp('created_at').defaultNow()
}, (table) => ({
  uniqueLike: unique().on(table.commentId, table.userId) // 防止重复点赞
}));
```

### API Endpoints
- `POST /api/comments` + Zod validation
- `GET /api/posts/:id/comments` + pagination
- `PATCH /api/comments/:id` + auth check
- `DELETE /api/comments/:id` + soft delete
- `POST /api/comments/:id/like` + 幂等性

### Frontend Components
- `CommentSection.tsx` with infinite scroll
- `CommentItem.tsx` with edit/delete UI
- `CommentForm.tsx` reusable form
- `useComments.ts` custom hook

### Security
- XSS防护: DOMPurify sanitize
- SQL注入: Drizzle参数化查询
- Rate limiting: 10 req/min per user
- Auth: requireAuth() middleware

**Tradeoffs**:
- ✅ 性能优化（materialized path查询高效）
- ✅ 完整功能（编辑、删除、分页）
- ✅ 安全性高
- ✅ 测试覆盖完整
- ⏱️ 开发时间稍长

---

## 🎨 Approach 3: Pragmatic (务实) - 3h

### 混合策略
- 使用Approach 1的简单schema
- 添加Approach 2的安全措施
- 延迟pagination和infinite scroll到Phase 5

**Tradeoffs**:
- ✅ 平衡速度和质量
- ⚠️ 未来可能需要重构嵌套查询

---

## ✅ Recommendation

**推荐 Approach 2 (Clean)** 原因：
1. 应用了历史模式PATTERN-012（Nested Comment Pattern = Materialized Path）
2. 防止了历史错误ERROR-007（XSS）
3. 符合全局约束（Drizzle ORM, Zod validation）
4. 4小时工作量符合21天Sprint范围
5. 技术债最少，长期维护成本低
```

### 🚪 Gate #2: User Selection (Phase 3)

**系统提示**:

```
🚪 Phase 3 审批

选择哪个设计方案？

请查看: changes/active/003-comment-system/design.md

选项:
1. Approach 1 - Minimal (2h) - 快速实现，技术债较多
2. Approach 2 - Clean (4h) [推荐] - 平衡质量和速度
3. Approach 3 - Pragmatic (3h) - 务实方案，适度优化
```

**用户选择**: `2 - Approach 2 (Clean)`

**系统记录**:

```typescript
// 更新 state.json
{
  "currentPhase": 3,
  "userDecisions": {
    "phase3SelectedApproach": 2,
    "phase3Timestamp": "2024-01-04T10:45:00Z"
  },
  "phaseHistory": [
    { "phase": 1, "status": "completed", "duration": 900 },
    { "phase": 2, "status": "completed", "duration": 1200 },
    { "phase": 3, "status": "completed", "duration": 1800 }
  ]
}
```

---

## ⚙️ Phase 4: Implementation with OODA Loop (2小时)

### Ralph-Wiggum Self-Completion Mode

**初始化 tasks.md**:

```markdown
# Tasks for Change #003-comment-system

## 📊 Metadata
- **Change ID**: 003-comment-system
- **Phase**: 4 (Implementation)
- **OODA Iteration**: 1/10
- **Completion**: <promise>PENDING</promise>
- **Approach**: Approach 2 (Clean) - Materialized Path Pattern

## 📋 Task List

### Phase 1: Database Schema
- [ ] Task 1: 创建 comments table with materialized path (src/db/schema/comments.ts)
  - Estimate: 20 min
  - Assertions:
    - `comments table有path字段`
    - `comments table有depth字段`
- [ ] Task 2: 创建 comment_likes table (src/db/schema/comments.ts)
  - Dependencies: Task 1
  - Estimate: 15 min
- [ ] Task 3: 添加Drizzle relations (src/db/schema/comments.ts)
  - Dependencies: Task 1, 2
  - Estimate: 10 min

### Phase 2: API Implementation
- [ ] Task 4: 创建POST /api/comments endpoint (src/api/comments/index.ts)
  - Dependencies: Task 1-3
  - Estimate: 30 min
  - Assertions:
    - `endpoint返回201状态码`
    - `content被DOMPurify sanitize`
- [ ] Task 5: 创建GET /api/posts/:id/comments endpoint
  - Estimate: 25 min
- [ ] Task 6: 创建PATCH /api/comments/:id endpoint
  - Estimate: 20 min
- [ ] Task 7: 创建POST /api/comments/:id/like endpoint
  - Estimate: 15 min

### Phase 3: Frontend Components
- [ ] Task 8: 创建CommentForm.tsx (src/components/blog/CommentForm.tsx)
  - Estimate: 25 min
- [ ] Task 9: 创建CommentItem.tsx (src/components/blog/CommentItem.tsx)
  - Estimate: 30 min
- [ ] Task 10: 创建CommentSection.tsx (src/components/blog/CommentSection.tsx)
  - Estimate: 35 min
- [ ] Task 11: 创建useComments.ts hook (src/hooks/useComments.ts)
  - Estimate: 20 min

### Phase 4: Security & Testing
- [ ] Task 12: 添加XSS测试 (src/__tests__/comments/xss.test.ts)
  - Estimate: 20 min
- [ ] Task 13: 添加API单元测试 (src/__tests__/comments/api.test.ts)
  - Estimate: 30 min
- [ ] Task 14: 添加组件测试 (src/__tests__/components/CommentSection.test.tsx)
  - Estimate: 25 min

## ✅ Validation Criteria
- [ ] 所有测试通过 (npm test)
- [ ] Build成功 (npm run build)
- [ ] ESLint clean (npm run lint)
- [ ] TypeScript clean (tsc --noEmit)
- [ ] 测试覆盖率≥80%
```

### OODA Iteration 1 (30分钟)

**Task 1-3: Database Schema**

```typescript
// Ralph-Wiggum OODA agent执行

console.log('🔄 OODA Iteration 1: Starting Tasks 1-3...');

// ACT: Implement Task 1
await Write({
  file_path: 'src/db/schema/comments.ts',
  content: `
import { pgTable, serial, integer, text, timestamp } from 'drizzle-orm/pg-core';
import { posts } from './posts';
import { users } from './users';

export const comments = pgTable('comments', {
  id: serial('id').primaryKey(),
  postId: integer('post_id').references(() => posts.id).notNull(),
  authorId: integer('author_id').references(() => users.id).notNull(),
  content: text('content').notNull(),
  parentId: integer('parent_id').references(() => comments.id),
  path: text('path').notNull(), // "1.2.5"
  depth: integer('depth').default(0).notNull(),
  likes: integer('likes').default(0),
  createdAt: timestamp('created_at').defaultNow(),
  updatedAt: timestamp('updated_at').defaultNow(),
  deletedAt: timestamp('deleted_at')
});
`
});

// VERIFY: Assertions for Task 1
const verifyResult = await verifyTaskAssertions('003-comment-system', 1);
if (!verifyResult.passed) {
  console.log('❌ Assertion failed, debugging...');
  await debugAndFix(); // 自我修复
  return;
}

console.log('✅ Task 1 verified');

// ACT: Implement Task 2... (similar)
// ACT: Implement Task 3... (similar)

// VERIFY: Run tests
const testResult = await Bash({ command: 'npm test -- schema' });
if (testResult.exitCode !== 0) {
  console.log('❌ Tests failed, auto-fixing...');
  await autoFixTests(); // Ralph-Wiggum自我修复
  return;
}

// VERIFY: Build
const buildResult = await Bash({ command: 'npm run build' });
if (buildResult.exitCode !== 0) {
  console.log('❌ Build failed, rolling back...');
  await Bash({ command: 'git stash' });
  await Bash({ command: 'git reset --hard HEAD~1' });
  await tryAlternativeApproach();
  return;
}

console.log('✅ OODA Iteration 1 完成 - Tasks 1-3 done');

// 更新 tasks.md
await updateTasksProgress(1, ['Task 1', 'Task 2', 'Task 3']);
```

**tasks.md更新后**:

```markdown
## 📋 Task List

### Phase 1: Database Schema
- [x] Task 1: 创建 comments table ✅
- [x] Task 2: 创建 comment_likes table ✅
- [x] Task 3: 添加Drizzle relations ✅

## 📈 OODA Loop History

### Iteration 1 (2024-01-04 11:00)
- **Completed**: Task 1, Task 2, Task 3
- **Tests**: ✅ schema tests passed (3/3)
- **Build**: ✅ Success
- **Decision**: Proceed to Task 4
```

### OODA Iteration 2-5 (90分钟)

(类似流程，完成Task 4-14，每次迭代自动验证、自我修复)

```markdown
### Iteration 2 (11:30)
- Completed: Task 4, Task 5
- Tests: ✅ API tests passed (5/5)
- Build: ✅ Success

### Iteration 3 (12:00)
- Completed: Task 6, Task 7
- Tests: ⚠️ Failed (like endpoint race condition)
- Auto-fix: 添加数据库transaction
- Re-test: ✅ Passed

### Iteration 4 (12:30)
- Completed: Task 8, Task 9, Task 10
- Tests: ✅ Component tests passed (8/8)
- Build: ✅ Success

### Iteration 5 (13:00)
- Completed: Task 11, Task 12, Task 13, Task 14
- Tests: ✅ All tests passed (25/25)
- Coverage: 87% ✅ (≥80%)
- Build: ✅ Success
- Lint: ✅ Clean
- TypeScript: ✅ No errors
```

### Final Update

```markdown
## 📊 Metadata
- **Completion**: <promise>DONE</promise>
- **Final Iteration**: 5/10
- **Total Time**: 2h 15min

## ✅ Validation Criteria
- [x] 所有测试通过 (npm test) - 25/25 ✅
- [x] Build成功 (npm run build) ✅
- [x] ESLint clean (npm run lint) ✅
- [x] TypeScript clean (tsc --noEmit) ✅
- [x] 测试覆盖率≥80% - 87% ✅
```

### 🔒 Gate #3: Phase 4 Quality Gate (自动)

**Stop Hook触发: post-phase-verify**

```typescript
// Hook检测到 <promise>DONE</promise>，自动触发验证

console.log('🔒 Phase 4 Quality Gate: Automatic Verification');

const verifyAgent = await Task({
  subagent_type: 'verification-agent',
  prompt: `Verify Phase 4 completion for 003-comment-system`,
  model: 'haiku'
});

const checks = [
  { name: 'tasks.md has DONE promise', passed: true },
  { name: 'All tasks marked [x]', passed: true },
  { name: 'npm test passes', passed: true },
  { name: 'npm run build succeeds', passed: true },
  { name: 'npm run lint clean', passed: true },
  { name: 'tsc --noEmit clean', passed: true },
  { name: 'state.json updated', passed: true }
];

if (checks.every(c => c.passed)) {
  console.log('✅ GATE PASSED - Proceeding to Phase 5');
  updateState({ currentPhase: 5 });
} else {
  console.log('❌ GATE FAILED - Blocking Phase 5');
  return { action: 'retry', phase: 4 };
}
```

**结果**: ✅ PASSED → 进入Phase 5

---

## 🔍 Phase 5: Quality Validation (30分钟)

### 并行代码审查

```typescript
// 启动3个并行code-reviewer
const reviews = await Promise.all([
  Task({
    subagent_type: 'code-reviewer',
    prompt: '从安全角度审查评论系统代码...',
    perspective: 'security'
  }),
  Task({
    subagent_type: 'code-reviewer',
    prompt: '从性能角度审查评论系统代码...',
    perspective: 'performance'
  }),
  Task({
    subagent_type: 'code-reviewer',
    prompt: '从可维护性角度审查评论系统代码...',
    perspective: 'maintainability'
  })
]);
```

**输出**: `changes/active/003-comment-system/issues-raw.json`

```json
{
  "issues": [
    {
      "issue_id": "ISSUE-001",
      "file": "src/api/comments/index.ts",
      "line": 45,
      "severity": "medium",
      "category": "performance",
      "title": "N+1查询问题：嵌套评论加载",
      "description": "当加载嵌套评论时，每个子评论都会触发单独的数据库查询",
      "code_snippet": "const children = await db.select().from(comments).where(eq(comments.parentId, comment.id));",
      "suggested_fix": "使用单次查询加载所有评论，然后在内存中构建树",
      "references": ["https://use-the-index-luke.com/"],
      "confidence": 65
    },
    {
      "issue_id": "ISSUE-002",
      "file": "src/components/blog/CommentItem.tsx",
      "line": 78,
      "severity": "low",
      "category": "maintainability",
      "title": "组件函数过长",
      "description": "CommentItem函数132行，超过CLAUDE.md约束（≤30行）",
      "impact": "违反全局约束CLAUDE.md: Functions ≤30 lines",
      "suggested_fix": "拆分为子组件: CommentHeader, CommentBody, CommentActions",
      "confidence": 95
    },
    {
      "issue_id": "ISSUE-003",
      "file": "src/api/comments/index.ts",
      "line": 23,
      "severity": "info",
      "category": "style",
      "title": "变量命名不一致",
      "description": "使用了snake_case和camelCase混合",
      "confidence": 40
    },
    // ... 20个issues
  ]
}
```

### Confidence Scoring

```typescript
// confidence-scorer处理issues
const scoredIssues = await Task({
  subagent_type: 'confidence-scorer',
  prompt: `Score all issues in issues-raw.json`,
  context: {
    globalConstraints: ['requirements.md', 'design.md', 'CLAUDE.md']
  }
});
```

**输出**: `changes/active/003-comment-system/issues-scored.json`

```json
{
  "issues": [
    {
      "issue_id": "ISSUE-002",
      "confidence": 95,
      "reasoning": "PROVEN: 实际读取文件确认132行 | IMPACT: 违反全局约束 | DOCUMENTED: CLAUDE.md明确规定≤30行"
    },
    {
      "issue_id": "ISSUE-001",
      "confidence": 82,
      "reasoning": "LIKELY: 代码模式显示N+1问题 | IMPACT: 性能中等影响 | MITIGATED: 当前评论量小，暂时可接受"
    },
    {
      "issue_id": "ISSUE-003",
      "confidence": 40,
      "reasoning": "ASSUMPTION: 仅基于几个示例 | IMPACT: 低 | 实际检查发现多数变量命名一致"
    }
  ],
  "filtered": [
    { "issue_id": "ISSUE-002", "confidence": 95 },
    { "issue_id": "ISSUE-001", "confidence": 82 }
  ],
  "threshold": 80,
  "summary": "发现2个高置信度问题（≥80），18个低置信度问题已过滤"
}
```

### 🚪 Gate #4: User Decision (Phase 5)

**系统提示**:

```
🚪 Phase 5 审批

发现2个高置信度问题（≥80分）

问题详情:
1. [95分] ISSUE-002: CommentItem.tsx函数过长 (132行 > 30行约束)
2. [82分] ISSUE-001: N+1查询问题（性能影响）

选项:
1. Fix All - 修复所有≥80分问题 (推荐)
2. Fix Critical Only - 仅修复≥95分问题
3. Accept Risk - 接受当前质量，进入Phase 6
```

**用户选择**: `1 - Fix All`

**系统执行**:

```typescript
// 自动修复2个issues
console.log('🔧 Auto-fixing 2 high-confidence issues...');

// Fix ISSUE-002: 拆分组件
await splitLongFunction('src/components/blog/CommentItem.tsx', {
  maxLines: 30,
  strategy: 'extract-components'
});

// Fix ISSUE-001: 优化查询
await optimizeQuery('src/api/comments/index.ts', {
  issue: 'N+1',
  solution: 'single-query-with-join'
});

// Re-run tests
const reTestResult = await Bash({ command: 'npm test' });
if (reTestResult.exitCode !== 0) {
  console.log('❌ 修复后测试失败，回退...');
  await Bash({ command: 'git reset --hard HEAD~1' });
  return { action: 'manual_review_needed' };
}

console.log('✅ 所有issues已修复，测试仍然通过');
```

### 🔒 Gate #5: Phase 5 Quality Gate (自动)

```typescript
// 再次验证
const finalVerify = await Task({
  subagent_type: 'verification-agent',
  prompt: 'Verify Phase 5 fixes complete'
});

const checks = [
  { name: 'issues-scored.json exists', passed: true },
  { name: 'All ≥80 issues fixed', passed: true },
  { name: 'Tests still pass', passed: true },
  { name: 'No new issues introduced', passed: true }
];

console.log('✅ GATE PASSED - Proceeding to Phase 6');
```

---

## 📦 Phase 6: Finalization (10分钟)

### Knowledge Base Update

**系统自动更新**:

```typescript
// 更新 knowledge/patterns.json
const newPattern = {
  id: 'PATTERN-045',
  category: 'database',
  name: 'Materialized Path with Depth',
  description: '使用path和depth字段优化嵌套评论查询，避免N+1问题',
  codeExample: `
    export const comments = pgTable('comments', {
      path: text('path').notNull(), // "1.2.5"
      depth: integer('depth').default(0).notNull()
    });

    // 查询所有子评论（单次查询）
    const allComments = await db.select()
      .from(comments)
      .where(like(comments.path, \`\${parentPath}.%\`));
  `,
  usageCount: 1,
  successRate: 100,
  lastUsed: '2024-01-04'
};

await addPattern(newPattern);

// 更新 knowledge/learnings.md
await appendLearning({
  sprint: 'Sprint 3',
  feature: 'Comment System',
  appliedPatterns: ['PATTERN-012', 'PATTERN-034'],
  lessons: [
    '✅ Materialized Path比Adjacency List性能好5x',
    '✅ DOMPurify成功防止XSS攻击',
    '⚠️ 组件容易过长，需要设置ESLint rule自动检查'
  ],
  timeSpent: '3h 15min',
  metrics: {
    testCoverage: '87%',
    issuesFound: 20,
    issuesFixed: 2,
    codeQuality: '95/100'
  }
});

console.log('✅ Knowledge base updated');
```

### Git Commit

```bash
git add .
git commit -m "$(cat <<'EOF'
feat: 添加博客评论系统

- 实现嵌套评论（Materialized Path模式）
- 支持点赞、编辑、删除功能
- XSS防护（DOMPurify）
- 测试覆盖率87%

Applied patterns: PATTERN-012, PATTERN-034
Fixed issues: ISSUE-001 (N+1查询), ISSUE-002 (组件过长)

Time: 3h 15min
Quality Score: 95/100

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
EOF
)"
```

### Final State

```json
{
  "changeId": "003-comment-system",
  "currentPhase": 6,
  "status": "completed",
  "userDecisions": {
    "phase1Approval": "yes",
    "phase3SelectedApproach": 2,
    "phase5IssueDecision": "fix-all"
  },
  "ooda": {
    "totalIterations": 5,
    "completionPromise": "DONE"
  },
  "quality": {
    "testCoverage": 87,
    "issuesFound": 20,
    "issuesFixed": 2,
    "confidenceThreshold": 80,
    "finalScore": 95
  },
  "phaseHistory": [
    { "phase": 0, "duration": 120, "status": "completed" },
    { "phase": 1, "duration": 900, "status": "completed" },
    { "phase": 2, "duration": 1200, "status": "completed" },
    { "phase": 3, "duration": 1800, "status": "completed" },
    { "phase": 4, "duration": 8100, "status": "completed", "verificationStatus": "passed" },
    { "phase": 5, "duration": 1800, "status": "completed", "verificationStatus": "passed" },
    { "phase": 6, "duration": 600, "status": "completed" }
  ],
  "totalDuration": 14520,
  "completedAt": "2024-01-04T13:30:00Z"
}
```

---

## 📊 Summary

### ✅ What Worked Well

1. **Knowledge Base (Phase 0)**
   - 成功应用历史模式PATTERN-012
   - 预防了历史错误ERROR-007（XSS）
   - 节省了设计时间（30分钟 → 15分钟）

2. **User Approval Gates**
   - 3次审批确保理解正确
   - 用户选择了最优方案（Approach 2）
   - 无需后期大改

3. **OODA Self-Completion**
   - 5次迭代自主完成14个任务
   - 自动发现并修复race condition
   - 无需人工干预

4. **Quality Gates**
   - Phase 4自动验证拦截了1次build失败
   - Phase 5自动验证确保修复后质量

5. **Confidence Scoring**
   - 过滤掉18个低置信度噪音（40-79分）
   - 保留2个真正需要修复的问题（≥80分）
   - 节省了1小时review时间

### 📈 Metrics

| Metric | Value | Target | Status |
|--------|-------|--------|--------|
| Total Time | 3h 15min | ≤4h | ✅ |
| Test Coverage | 87% | ≥80% | ✅ |
| Code Quality | 95/100 | ≥85 | ✅ |
| Issues Found | 20 | N/A | - |
| High-Confidence Issues | 2 | N/A | - |
| Issues Fixed | 2 | All ≥80 | ✅ |
| OODA Iterations | 5 | ≤10 | ✅ |
| User Approvals | 3 | Expected | ✅ |
| Gate Failures | 0 | Minimize | ✅ |

### 🎯 Quality Improvements from v2.0

| Feature | Before v2.0 | After v2.0 |
|---------|-------------|------------|
| Knowledge Reuse | ❌ None | ✅ 2 patterns applied |
| Approval Gates | ❌ None | ✅ 3 gates (100% hit rate) |
| Auto Verification | ❌ Manual | ✅ 2 quality gates |
| Self-Healing | ❌ None | ✅ 1 auto-fix (race condition) |
| Code Review Noise | 😫 20-50 issues | ✨ 2 high-confidence |
| Cross-Session Resume | ❌ Not possible | ✅ state.json enables it |

### 🚀 What's Next

**Feature is complete and ready for:**
1. ✅ Code review (已通过confidence scorer)
2. ✅ QA testing (87%测试覆盖率)
3. ✅ Staging deployment
4. ✅ Production release

**Knowledge captured for future:**
- PATTERN-045: Materialized Path with Depth
- Learning: 组件容易过长，需要ESLint rule
- Metric: 评论系统平均3h 15min（可作为估算参考）

---

**End of Complete Example**

**Total Duration**: 3h 15min
**Quality Score**: 95/100
**User Satisfaction**: ⭐⭐⭐⭐⭐ (all approvals, no rework)
**System Performance**: 5 OODA iterations, 0 gate failures, 2 auto-fixes
