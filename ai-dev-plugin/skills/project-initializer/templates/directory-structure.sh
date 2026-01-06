#!/bin/bash
# 创建增强的 codebox 目录结构
# 集成 OpenSpec + Netflix Conductor + AISD-R + Kiro Spec 模式

set -e

PROJECT_DIR="codebox"

echo "🏗️  创建增强项目目录结构..."

# ============================================
# 🌍 全局约束 (Global Constraints - Kiro Spec)
# ============================================

echo ""
echo "📋 1. 创建全局约束层..."

# 全局约束文档（已由其他脚本创建模板，这里创建实例）
if [ ! -f "$PROJECT_DIR/requirements.md" ]; then
  echo "  - 创建 requirements.md (全局需求 - EARS 格式)"
  cp "${CLAUDE_PLUGIN_ROOT}/skills/project-initializer/templates/global-requirements.md" "$PROJECT_DIR/requirements.md"
fi

if [ ! -f "$PROJECT_DIR/design.md" ]; then
  echo "  - 创建 design.md (全局架构设计)"
  cp "${CLAUDE_PLUGIN_ROOT}/skills/project-initializer/templates/global-design.md" "$PROJECT_DIR/design.md"
fi

if [ ! -f "$PROJECT_DIR/CLAUDE.md" ]; then
  echo "  - 创建 CLAUDE.md (AI 行为约束)"
  cat > "$PROJECT_DIR/CLAUDE.md" <<'EOF'
# AI 行为约束和开发规范

> 本文档定义 AI 在开发过程中的行为规范和代码风格约束

---

## 🎯 核心原则

### 1. 质量大于速度
- 宁可多花时间理解，不要急于实现
- 所有变更必须通过质量门禁（ESLint, TypeScript, Tests, Build）
- 置信度 <80 的代码审查 issue 不阻塞，但需记录

### 2. 约束优先级
```
全局约束 (requirements/design/CLAUDE/constraints.md)
  ↓ 高优先级
变更级设计 (changes/active/[id]/design.md)
  ↓ 中优先级
实现细节 (代码)
```

冲突时，全局约束 > 变更级设计 > 实现细节

### 3. 知识闭环
- 每个变更开始前查询 knowledge/ 库（Phase 0）
- 每个变更结束后更新 knowledge/ 库（Phase 6）
- 识别的模式 → patterns.json
- 遇到的错误 → errors.json
- 经验教训 → learnings.md

---

## 📐 代码风格

### 命名约定
- **组件**: `PascalCase.tsx` (UserProfile.tsx)
- **函数**: `camelCase` (getUserById, validateEmail)
- **常量**: `UPPER_SNAKE_CASE` (MAX_RETRY_COUNT, API_BASE_URL)
- **接口/类型**: `PascalCase` (User, CreateUserDTO, IUserRepository)
- **文件夹**: `kebab-case` (user-profile/, auth-service/)

### 文件组织
```typescript
// ✅ Good: 清晰的导入顺序
// 1. 外部依赖
import { useState, useEffect } from 'react';
import { z } from 'zod';

// 2. 内部模块
import { UserRepository } from '@/lib/repositories/UserRepository';
import { AppError } from '@/lib/errors/AppError';

// 3. 类型
import type { User, CreateUserDTO } from '@/lib/types';

// 4. 样式
import styles from './UserProfile.module.css';
```

### 函数设计
```typescript
// ✅ Good: 单一职责，≤30行，清晰的类型
async function createUser(data: CreateUserDTO): Promise<Result<User>> {
  try {
    // 1. 验证
    const validated = createUserSchema.parse(data);

    // 2. 业务逻辑
    const hashedPassword = await bcrypt.hash(validated.password, 10);

    // 3. 持久化
    const user = await userRepo.create({
      ...validated,
      password: hashedPassword
    });

    return { success: true, data: user };
  } catch (err) {
    return { success: false, error: toAppError(err) };
  }
}

// ❌ Bad: 多职责，长函数，缺少错误处理
function doEverything(input: any) {
  // 100+ lines of mixed concerns...
}
```

---

## 🛡️ 质量标准

### TypeScript 严格模式
```typescript
// tsconfig.json
{
  "compilerOptions": {
    "strict": true,
    "noImplicitAny": true,
    "strictNullChecks": true,
    "noUnusedLocals": true,
    "noUnusedParameters": true
  }
}

// ✅ Good: 明确的类型
interface User {
  id: string;
  email: string;
  name: string | null;
  createdAt: Date;
}

function getUser(id: string): Promise<User | null> { ... }

// ❌ Bad: any 类型
function getUser(id: any): Promise<any> { ... }
```

### 错误处理模式
```typescript
// ✅ Good: 统一的错误类
export class AppError extends Error {
  constructor(
    public code: string,
    public message: string,
    public statusCode: number = 500,
    public details?: unknown
  ) {
    super(message);
    this.name = 'AppError';
  }
}

// 使用示例
async function login(email: string, password: string) {
  try {
    const user = await userRepo.findByEmail(email);
    if (!user) {
      throw new AppError('AUTH_FAILED', 'Invalid credentials', 401);
    }

    const valid = await bcrypt.compare(password, user.password);
    if (!valid) {
      throw new AppError('AUTH_FAILED', 'Invalid credentials', 401);
    }

    return { success: true, data: generateToken(user) };
  } catch (err) {
    if (err instanceof AppError) {
      return { success: false, error: err };
    }
    return { success: false, error: new AppError('UNKNOWN', 'Internal error', 500) };
  }
}
```

### 测试要求
```typescript
// ✅ Good: 清晰的测试结构
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid data', async () => {
      // Arrange
      const mockRepo = { create: vi.fn().mockResolvedValue(mockUser) };
      const service = new UserService(mockRepo);

      // Act
      const result = await service.createUser(validUserData);

      // Assert
      expect(result.success).toBe(true);
      expect(result.data).toEqual(mockUser);
    });

    it('should reject duplicate email', async () => {
      // ...
    });
  });
});
```

---

## 🚀 性能和优化

### 避免过度优化
```typescript
// ✅ Good: 简单直接（除非性能测试证明有问题）
const users = await db.query.users.findMany();
const activeUsers = users.filter(u => u.isActive);

// ❌ Bad: 过早优化
const activeUsers = await db.query.users.findMany({
  where: eq(users.isActive, true),
  with: { profile: true, posts: true }  // 可能不需要
});
```

### 适度缓存
```typescript
// ✅ Good: 有数据支持的缓存
// （仅在性能测试显示瓶颈后添加）
const userCache = new Map<string, User>();

async function getUser(id: string): Promise<User | null> {
  if (userCache.has(id)) {
    return userCache.get(id)!;
  }

  const user = await userRepo.findById(id);
  if (user) {
    userCache.set(id, user);
  }
  return user;
}
```

---

## 🔒 安全要求

### 输入验证
```typescript
// ✅ Good: Zod schema 验证
import { z } from 'zod';

const createUserSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  name: z.string().min(1).max(100)
});

// 使用
const validated = createUserSchema.parse(userInput);
```

### SQL 注入防护
```typescript
// ✅ Good: Drizzle ORM（自动参数化）
const user = await db.query.users.findFirst({
  where: eq(users.email, email)
});

// ❌ Bad: 字符串拼接 SQL
const query = `SELECT * FROM users WHERE email = '${email}'`;
```

### 敏感数据
```typescript
// ✅ Good: 环境变量 + bcrypt
const hashedPassword = await bcrypt.hash(password, 10);

// ❌ Bad: 明文存储
const user = { password: password };
```

---

## 📝 注释和文档

### 何时添加注释
```typescript
// ✅ Good: 复杂业务逻辑需要注释
/**
 * 计算用户的信用分数
 * 算法: 基础分 (500) + 完成订单数 * 10 - 投诉次数 * 50
 * 范围: 0-1000
 */
function calculateCreditScore(user: User): number {
  const baseScore = 500;
  const orderBonus = user.completedOrders * 10;
  const complaintPenalty = user.complaints * 50;
  return Math.max(0, Math.min(1000, baseScore + orderBonus - complaintPenalty));
}

// ❌ Bad: 不需要的注释
// Get user by ID
function getUserById(id: string) { ... }
```

### 何时不需要注释
```typescript
// ✅ Good: 自解释的代码
const isAdult = user.age >= 18;
const hasPermission = user.role === 'admin' || user.id === resource.ownerId;

// ❌ Bad: 用注释解释糟糕的命名
const x = u.a >= 18;  // Check if user is adult
```

---

## 🎯 变更流程约束

### Phase 0: 知识预查
- **必须执行**: 读取 knowledge/ 库
- **输出**: phase0-context.md (附加到 proposal.md)

### Phase 1: 需求澄清
- **必须执行**: 引用全局 requirements.md
- **输出**: proposal.md (EARS 格式)

### Phase 3: 方案设计
- **必须执行**: 遵循全局 design.md
- **输出**: design.md (继承全局架构)

### Phase 5: 质量验证
- **必须执行**: 置信度过滤 ≥80
- **输出**: 高置信度 issues only

### Phase 6: 完成
- **必须执行**: 更新 knowledge/ 库
- **输出**: 新的 patterns/errors/learnings

---

## ⚖️ 权衡原则

当遇到冲突时：
1. **安全 > 性能** - 宁可慢，不要不安全
2. **可读性 > 简洁性** - 宁可多几行，不要难懂
3. **明确性 > 灵活性** - 宁可重复，不要过度抽象
4. **测试性 > 便捷性** - 宁可多写接口，不要硬编码依赖

---

## 📊 门禁检查清单

每个变更在 Phase 5 必须通过：
- [ ] ESLint: 0 errors, 0 warnings
- [ ] TypeScript: 0 errors
- [ ] Prettier: 已格式化
- [ ] 单元测试: 通过率 100%
- [ ] 集成测试: 关键路径覆盖
- [ ] Build: 成功构建 (`npm run build`)
- [ ] 安全检查: Zod 验证, Drizzle ORM, bcrypt
- [ ] 代码审查: 置信度 ≥80 issues 全部修复

---

## 🔄 更新日志

- **2025-01-02**: 初始版本
- 后续更新记录在此
EOF
fi

if [ ! -f "$PROJECT_DIR/constraints.md" ]; then
  echo "  - 创建 constraints.md (质量门禁)"
  cp "${CLAUDE_PLUGIN_ROOT}/skills/project-initializer/templates/global-constraints.md" "$PROJECT_DIR/constraints.md"
fi

# ============================================
# 📚 知识管理 (Knowledge Management - AISD-R)
# ============================================

echo ""
echo "📚 2. 创建知识管理系统..."

if [ ! -d "$PROJECT_DIR/knowledge" ]; then
  echo "  - 执行 knowledge-structure.sh"
  bash "${CLAUDE_PLUGIN_ROOT}/skills/project-initializer/templates/knowledge-structure.sh"
else
  echo "  - 知识管理系统已存在，跳过"
fi

# ============================================
# 📦 变更管理 (Change Management - OpenSpec)
# ============================================

echo ""
echo "📦 3. 创建变更管理目录..."

mkdir -p "$PROJECT_DIR/changes/active"
echo "  - 创建 changes/active/ (正在开发的变更)"

mkdir -p "$PROJECT_DIR/changes/staged"
echo "  - 创建 changes/staged/ (已批准未开始的变更)"

mkdir -p "$PROJECT_DIR/changes/archived"
echo "  - 创建 changes/archived/ (已完成的变更，按月归档)"

# 创建 README
cat > "$PROJECT_DIR/changes/README.md" <<'EOF'
# Changes Directory - OpenSpec 风格变更管理

## 📁 目录结构

```
changes/
├── active/[change-id]/       # 正在开发的变更
│   ├── proposal.md           # 为什么和是什么（Phase 1）
│   ├── design.md             # 如何实现（Phase 3）
│   ├── tasks.md              # 执行任务（markdown checkboxes）
│   ├── evidence.md           # 探索发现（Phase 2）
│   ├── phase0-context.md     # 知识预查上下文（Phase 0）
│   └── state.json            # 持久化状态机（Conductor）
│
├── staged/[change-id]/       # 已批准未开始
│   └── proposal.md
│
└── archived/YYYY-MM/[change-id]/  # 已完成（按月归档）
    └── [所有文件]
```

## 🔄 变更生命周期

```
1. 用户请求
   ↓
2. Phase 0: 知识预查 → phase0-context.md
   ↓
3. Phase 1: 需求澄清 → proposal.md → 用户批准 → staged/
   ↓
4. Phase 2: 资源发现 (medium/complex) → evidence.md
   ↓
5. Phase 3: 方案设计 → design.md → 用户选择方案
   ↓
6. 开始实施 → mv staged/[id] → active/[id]
   ↓
7. Phase 4: 实现 (OODA) → tasks.md → <promise>DONE</promise>
   ↓
8. Phase 5: 质量验证 → 置信度 ≥80 issues
   ↓
9. Phase 6: 完成 → Git commit → mv active/[id] → archived/YYYY-MM/[id]
```

## 📋 变更 ID 格式

```
[seq]-[brief-description]

示例:
- 001-user-auth
- 002-api-caching
- 003-ui-dark-mode
```

## 🎯 状态管理

每个变更的 `state.json`:
```json
{
  "change_id": "001-user-auth",
  "workflow_id": "feature-development-v1",
  "status": "in_progress",
  "current_phase": "phase-4-implementation",
  "ooda_iteration": 3,
  "phases": {
    "phase-1-clarification": { "status": "completed", "decision": "proceed" },
    "phase-4-implementation": { "status": "in_progress", "completion_promise": "PENDING" }
  }
}
```

## 📊 查看变更状态

```bash
# 列出所有活跃变更
ls -la changes/active/

# 查看特定变更状态
cat changes/active/001-user-auth/state.json

# 查看任务进度
cat changes/active/001-user-auth/tasks.md
```
EOF

# ============================================
# 🔄 工作流管理 (Workflow Management - Conductor)
# ============================================

echo ""
echo "🔄 4. 创建工作流管理目录..."

mkdir -p "$PROJECT_DIR/workflows/templates"
echo "  - 创建 workflows/templates/ (工作流模板)"

mkdir -p "$PROJECT_DIR/workflows/executions"
echo "  - 创建 workflows/executions/ (执行日志)"

# 创建示例工作流模板
cat > "$PROJECT_DIR/workflows/templates/feature-development-v1.json" <<'EOF'
{
  "workflow_id": "feature-development-v1",
  "name": "Feature Development Workflow",
  "version": "1.0",
  "description": "7-phase gated workflow for feature development",

  "phases": [
    {
      "id": "phase-0-knowledge-check",
      "name": "Knowledge Check",
      "type": "automatic",
      "gate": false,
      "tasks": [
        "Check global constraints exist",
        "Query knowledge base",
        "Generate knowledge context",
        "Compliance pre-check"
      ],
      "outputs": ["phase0-context.md"],
      "next": "phase-1-clarification"
    },
    {
      "id": "phase-1-clarification",
      "name": "Requirement Clarification",
      "type": "agent_execution",
      "gate": true,
      "gate_type": "user_approval",
      "agent": "requirement-analyzer",
      "tasks": [
        "Extract intent and technical details",
        "Read global requirements.md",
        "Identify ambiguities",
        "Generate proposal.md (EARS format)"
      ],
      "outputs": ["proposal.md"],
      "approval_question": "Does this match your intent?",
      "approval_options": ["yes", "no", "refine"],
      "next": {
        "yes": "phase-2-discovery",
        "no": "cancel",
        "refine": "phase-1-clarification"
      }
    },
    {
      "id": "phase-2-discovery",
      "name": "Resource Discovery",
      "type": "parallel_agents",
      "gate": false,
      "condition": "complexity >= medium",
      "agents": ["code-explorer-1", "code-explorer-2", "code-explorer-3"],
      "agent_perspectives": [
        "Entry points and integration",
        "Similar existing features",
        "Data flow and dependencies"
      ],
      "tasks": [
        "Parallel exploration (2-3 agents)",
        "Merge discoveries",
        "Read identified files (5-15)",
        "Generate evidence.md"
      ],
      "outputs": ["evidence.md"],
      "next": "phase-3-design"
    },
    {
      "id": "phase-3-design",
      "name": "Approach Design",
      "type": "parallel_agents",
      "gate": true,
      "gate_type": "user_choice",
      "agents": ["code-architect-1", "code-architect-2", "code-architect-3"],
      "agent_perspectives": [
        "Minimal approach (fastest)",
        "Clean approach (maintainable) ⭐",
        "Pragmatic approach (optimized)"
      ],
      "tasks": [
        "Read global design.md",
        "Generate 2-3 approaches",
        "Trade-off analysis",
        "Generate design.md"
      ],
      "outputs": ["design.md"],
      "approval_question": "Select approach:",
      "approval_options": ["1-minimal", "2-clean", "3-pragmatic"],
      "next": "phase-4-implementation"
    },
    {
      "id": "phase-4-implementation",
      "name": "Implementation (OODA Loop)",
      "type": "autonomous_loop",
      "gate": false,
      "max_iterations": 10,
      "completion_criteria": [
        "All tasks.md checkboxes checked",
        "All tests pass",
        "Build succeeds",
        "<promise>DONE</promise> written"
      ],
      "tasks": [
        "Initialize tasks.md",
        "OODA loop (Observe, Orient, Decide, Act)",
        "Update checkboxes",
        "Run tests iteratively"
      ],
      "outputs": ["tasks.md", "implemented code"],
      "next": "phase-5-quality"
    },
    {
      "id": "phase-5-quality",
      "name": "Quality Validation",
      "type": "parallel_agents",
      "gate": true,
      "gate_type": "user_decision",
      "agents": ["code-reviewer-1", "code-reviewer-2", "code-reviewer-3"],
      "agent_perspectives": [
        "CLAUDE.md compliance",
        "Simplicity and maintainability",
        "Bugs and edge cases"
      ],
      "confidence_filter": 80,
      "tasks": [
        "3 parallel reviewers",
        "Merge to unique issues",
        "Score each issue (confidence-scorer)",
        "Filter ≥80",
        "Sort by confidence"
      ],
      "outputs": ["review-report.md"],
      "approval_question": "Fix issues?",
      "approval_options": ["all", "high-only", "skip"],
      "next": {
        "all": "phase-4-implementation",
        "high-only": "phase-4-implementation",
        "skip": "phase-6-finalization"
      }
    },
    {
      "id": "phase-6-finalization",
      "name": "Finalization",
      "type": "automatic",
      "gate": false,
      "tasks": [
        "Git commit",
        "Update feature_list.json (passes=true)",
        "Append progress.txt",
        "Archive: mv active/[id] → archived/YYYY-MM/[id]",
        "Update knowledge/ (patterns, errors, learnings)",
        "Recommend next feature"
      ],
      "outputs": ["Git commit", "Archived change"],
      "next": "complete"
    }
  ],

  "metadata": {
    "created_at": "2025-01-02",
    "author": "ai-orchestrator",
    "applicable_to": ["feature", "enhancement"],
    "estimated_duration": "2-4 hours"
  }
}
EOF

# 创建 Bug Fix 工作流模板
cat > "$PROJECT_DIR/workflows/templates/bug-fix-v1.json" <<'EOF'
{
  "workflow_id": "bug-fix-v1",
  "name": "Bug Fix Workflow",
  "version": "1.0",
  "description": "Quick bug fix workflow (simplified phases)",

  "phases": [
    {
      "id": "phase-0-knowledge-check",
      "name": "Knowledge Check",
      "type": "automatic",
      "gate": false,
      "tasks": ["Query errors.json for similar bugs"],
      "outputs": ["phase0-context.md"],
      "next": "phase-1-reproduce"
    },
    {
      "id": "phase-1-reproduce",
      "name": "Reproduce and Diagnose",
      "type": "agent_execution",
      "agent": "debugger",
      "tasks": [
        "Reproduce the bug",
        "Identify root cause",
        "Generate minimal fix proposal"
      ],
      "outputs": ["proposal.md"],
      "next": "phase-2-fix"
    },
    {
      "id": "phase-2-fix",
      "name": "Implement Fix",
      "type": "agent_execution",
      "agent": "quick-fixer",
      "constraints": {
        "max_time": "30 minutes",
        "max_files": 3,
        "max_lines": 50
      },
      "tasks": [
        "Implement fix",
        "Add test case",
        "Verify fix"
      ],
      "outputs": ["fixed code", "test"],
      "next": "phase-3-validate"
    },
    {
      "id": "phase-3-validate",
      "name": "Validate Fix",
      "type": "automatic",
      "tasks": [
        "Run tests",
        "Check regression",
        "Git commit"
      ],
      "outputs": ["Git commit"],
      "next": "complete"
    }
  ],

  "metadata": {
    "created_at": "2025-01-02",
    "author": "ai-orchestrator",
    "applicable_to": ["bug", "hotfix"],
    "estimated_duration": "30 minutes - 1 hour"
  }
}
EOF

# ============================================
# 💾 状态管理 (State Management)
# ============================================

echo ""
echo "💾 5. 创建状态管理目录..."

mkdir -p "$PROJECT_DIR/state"
echo "  - 创建 state/ (全局状态管理)"

mkdir -p "$PROJECT_DIR/state/agent-outputs"
echo "  - 创建 state/agent-outputs/ (Agent 输出缓存)"

# 创建当前阶段追踪文件
cat > "$PROJECT_DIR/state/current-phase.json" <<'EOF'
{
  "active_change": null,
  "current_phase": null,
  "workflow_id": null,
  "started_at": null,
  "last_updated": null
}
EOF

# ============================================
# 📊 现有文件（保持兼容）
# ============================================

echo ""
echo "📊 6. 确保现有文件存在..."

if [ ! -f "$PROJECT_DIR/config.json" ]; then
  echo "  - 创建 config.json"
  cat > "$PROJECT_DIR/config.json" <<'EOF'
{
  "mode": "long-running",
  "version": "2.0-enhanced",
  "features": {
    "global_constraints": true,
    "knowledge_management": true,
    "7_phase_workflow": true,
    "ooda_loop": true,
    "confidence_filtering": true,
    "openspec_structure": true
  },
  "quality_rules": {
    "max_function_lines": 30,
    "max_file_lines": 400,
    "cyclomatic_complexity": 10,
    "confidence_threshold": 80
  },
  "tech_stack": {
    "frontend": ["Next.js 14+", "React 18+", "TypeScript 5+", "Tailwind CSS"],
    "backend": ["Hono", "Drizzle ORM"],
    "database": ["PostgreSQL 14+"],
    "testing": ["Vitest", "Playwright"]
  }
}
EOF
fi

if [ ! -f "$PROJECT_DIR/progress.txt" ]; then
  echo "  - 创建 progress.txt"
  echo "# Project Progress Log" > "$PROJECT_DIR/progress.txt"
  echo "" >> "$PROJECT_DIR/progress.txt"
  echo "$(date): Project initialized with enhanced structure" >> "$PROJECT_DIR/progress.txt"
fi

if [ ! -f "$PROJECT_DIR/feature_list.json" ]; then
  echo "  - 创建 feature_list.json (增强 schema)"
  cat > "$PROJECT_DIR/feature_list.json" <<'EOF'
{
  "project": "my-project",
  "version": "2.0-enhanced",
  "tech_stack": [],

  "changes": {
    "active": [],
    "staged": [],
    "archived_count": 0
  },

  "features": [],

  "ooda_loops": [],

  "statistics": {
    "total_features": 0,
    "completed_features": 0,
    "completion_rate": 0,
    "average_confidence": 0,
    "total_ooda_iterations": 0
  }
}
EOF
fi

# ============================================
# ✅ 完成
# ============================================

echo ""
echo "✅ 增强目录结构创建完成！"
echo ""
echo "📂 目录结构："
echo ""
tree -L 2 "$PROJECT_DIR" 2>/dev/null || find "$PROJECT_DIR" -maxdepth 2 -type d | sort
echo ""
echo "🎯 核心能力："
echo "  ✅ 全局约束（Kiro Spec）"
echo "  ✅ 知识管理（AISD-R Phase 0）"
echo "  ✅ 变更管理（OpenSpec 风格）"
echo "  ✅ 工作流编排（Netflix Conductor）"
echo "  ✅ 7阶段门控工作流"
echo "  ✅ OODA 自主完成循环"
echo ""
echo "📚 下一步："
echo "  1. 编辑 requirements.md 定义项目全局需求"
echo "  2. 编辑 design.md 定义项目架构模式"
echo "  3. 编辑 CLAUDE.md 定义 AI 行为规范"
echo "  4. 运行 'ai 实现XX功能' 开始第一个变更"
echo ""
