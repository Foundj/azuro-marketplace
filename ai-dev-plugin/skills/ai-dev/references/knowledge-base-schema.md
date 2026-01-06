# Knowledge Base Schema - 知识库结构规范

## 概述

知识库是AI-Orchestrator的核心组件之一（AISD-R方法论），用于：
1. **Phase 0知识预查** - 避免重复历史错误
2. **Phase 6知识更新** - 积累成功模式和经验教训
3. **跨变更学习** - 让每次执行都基于过往经验

知识库位置：
```
codebox/knowledge/
├── patterns.json      # 成功模式库
├── errors.json        # 历史错误库
└── learnings.md       # 经验总结文档
```

---

## 1. patterns.json - 成功模式库

### TypeScript Interface

```typescript
interface PatternsDatabase {
  version: string;                    // Schema版本 "1.0"
  lastUpdated: Date;                  // 最后更新时间
  patterns: Pattern[];                // 模式列表
}

interface Pattern {
  id: string;                         // 唯一ID "PATTERN-001"
  category: string;                   // 分类
  name: string;                       // 模式名称
  description: string;                // 详细描述
  context: string;                    // 适用上下文
  codeExample?: string;               // 代码示例（可选）
  files?: string[];                   // 相关文件路径
  usageCount: number;                 // 使用次数
  successRate: number;                // 成功率 (0-100)
  lastUsed?: Date;                    // 最后使用时间
  tags: string[];                     // 标签
  relatedPatterns?: string[];         // 关联模式ID
  createdBy: string;                  // 创建来源
  createdAt: Date;                    // 创建时间
}
```

### 分类（category）

- `architecture` - 架构模式 (Repository, Service Layer, MVC...)
- `authentication` - 认证相关
- `database` - 数据库模式
- `api` - API设计模式
- `ui` - UI组件模式
- `testing` - 测试模式
- `performance` - 性能优化
- `error-handling` - 错误处理
- `validation` - 数据验证
- `security` - 安全相关

### JSON示例

```json
{
  "version": "1.0",
  "lastUpdated": "2025-01-04T14:00:00Z",
  "patterns": [
    {
      "id": "PATTERN-001",
      "category": "architecture",
      "name": "Repository Pattern",
      "description": "使用Repository模式隔离数据访问层，提供统一的数据操作接口",
      "context": "当需要访问数据库或外部数据源时，使用Repository抽象隔离业务逻辑和数据访问",
      "codeExample": "export interface IUserRepository {\n  findById(id: string): Promise<User | null>;\n  findByEmail(email: string): Promise<User | null>;\n  save(user: User): Promise<void>;\n  delete(id: string): Promise<void>;\n}\n\nexport class UserRepository implements IUserRepository {\n  constructor(private db: Database) {}\n  \n  async findById(id: string): Promise<User | null> {\n    const row = await this.db.query('SELECT * FROM users WHERE id = ?', [id]);\n    return row ? mapToUser(row) : null;\n  }\n  // ...\n}",
      "files": [
        "src/lib/interfaces/IUserRepository.ts",
        "src/lib/repositories/UserRepository.ts"
      ],
      "usageCount": 25,
      "successRate": 98,
      "lastUsed": "2025-01-03T10:30:00Z",
      "tags": ["architecture", "data-access", "clean-code", "dependency-injection"],
      "relatedPatterns": ["PATTERN-002", "PATTERN-003"],
      "createdBy": "ai-dev",
      "createdAt": "2024-12-15T09:00:00Z"
    },
    {
      "id": "PATTERN-002",
      "category": "architecture",
      "name": "Service Layer Pattern",
      "description": "业务逻辑封装在Service层，协调多个Repository和其他依赖",
      "context": "当业务逻辑涉及多个数据源或需要事务协调时",
      "codeExample": "export class AuthService {\n  constructor(\n    private userRepo: IUserRepository,\n    private sessionRepo: ISessionRepository,\n    private emailService: IEmailService\n  ) {}\n\n  async login(email: string, password: string): Promise<Session> {\n    const user = await this.userRepo.findByEmail(email);\n    if (!user || !await this.verifyPassword(user, password)) {\n      throw new UnauthorizedError('Invalid credentials');\n    }\n    const session = await this.sessionRepo.create(user.id);\n    await this.emailService.sendLoginNotification(user.email);\n    return session;\n  }\n}",
      "files": [
        "src/lib/services/AuthService.ts"
      ],
      "usageCount": 18,
      "successRate": 95,
      "lastUsed": "2025-01-02T15:20:00Z",
      "tags": ["architecture", "business-logic", "dependency-injection"],
      "relatedPatterns": ["PATTERN-001"],
      "createdBy": "ai-dev",
      "createdAt": "2024-12-16T10:00:00Z"
    },
    {
      "id": "PATTERN-003",
      "category": "validation",
      "name": "Zod Schema Validation",
      "description": "使用Zod进行运行时类型验证和数据解析",
      "context": "API endpoints、用户输入验证",
      "codeExample": "import { z } from 'zod';\n\nconst loginSchema = z.object({\n  email: z.string().email(),\n  password: z.string().min(8),\n});\n\nexport async function POST(req: Request) {\n  const body = await req.json();\n  const { email, password } = loginSchema.parse(body); // 自动验证并抛出错误\n  // ...\n}",
      "files": [
        "src/lib/schemas/auth.ts",
        "src/app/api/auth/login/route.ts"
      ],
      "usageCount": 42,
      "successRate": 100,
      "lastUsed": "2025-01-04T08:15:00Z",
      "tags": ["validation", "type-safety", "error-handling"],
      "relatedPatterns": [],
      "createdBy": "ai-dev",
      "createdAt": "2024-12-10T14:30:00Z"
    },
    {
      "id": "PATTERN-004",
      "category": "error-handling",
      "name": "Custom Error Classes",
      "description": "定义自定义错误类，提供语义化的错误处理",
      "context": "业务逻辑、API错误响应",
      "codeExample": "export class NotFoundError extends Error {\n  constructor(resource: string, id: string) {\n    super(`${resource} with id ${id} not found`);\n    this.name = 'NotFoundError';\n  }\n}\n\nexport class UnauthorizedError extends Error {\n  constructor(message: string = 'Unauthorized') {\n    super(message);\n    this.name = 'UnauthorizedError';\n  }\n}\n\n// 使用\nconst user = await userRepo.findById(id);\nif (!user) throw new NotFoundError('User', id);",
      "files": [
        "src/lib/errors/index.ts"
      ],
      "usageCount": 30,
      "successRate": 97,
      "lastUsed": "2025-01-03T16:45:00Z",
      "tags": ["error-handling", "type-safety"],
      "relatedPatterns": [],
      "createdBy": "ai-dev",
      "createdAt": "2024-12-18T11:20:00Z"
    }
  ]
}
```

### 查询模式

```typescript
// 按category查询
function findPatternsByCategory(category: string): Pattern[] {
  const db = JSON.parse(readFile('knowledge/patterns.json'));
  return db.patterns.filter(p => p.category === category);
}

// 按tags查询
function findPatternsByTag(tag: string): Pattern[] {
  const db = JSON.parse(readFile('knowledge/patterns.json'));
  return db.patterns.filter(p => p.tags.includes(tag));
}

// 按名称模糊搜索
function searchPatterns(keyword: string): Pattern[] {
  const db = JSON.parse(readFile('knowledge/patterns.json'));
  const lower = keyword.toLowerCase();
  return db.patterns.filter(p =>
    p.name.toLowerCase().includes(lower) ||
    p.description.toLowerCase().includes(lower)
  );
}

// 获取最常用的模式
function getMostUsedPatterns(limit: number = 5): Pattern[] {
  const db = JSON.parse(readFile('knowledge/patterns.json'));
  return db.patterns
    .sort((a, b) => b.usageCount - a.usageCount)
    .slice(0, limit);
}
```

---

## 2. errors.json - 历史错误库

### TypeScript Interface

```typescript
interface ErrorsDatabase {
  version: string;                    // Schema版本 "1.0"
  lastUpdated: Date;                  // 最后更新时间
  errors: HistoricalError[];          // 错误列表
}

interface HistoricalError {
  id: string;                         // 唯一ID "ERROR-001"
  category: string;                   // 错误分类
  symptom: string;                    // 错误症状（用户看到的）
  rootCause: string;                  // 根本原因
  preventionMeasures: string[];       // 预防措施列表
  detectionMethod?: string;           // 如何检测此错误
  relatedFiles?: string[];            // 相关文件
  riskLevel: 'low' | 'medium' | 'high' | 'critical';  // 风险等级
  impact: string;                     // 影响描述
  occurrenceCount: number;            // 发生次数
  lastOccurred?: Date;                // 最后发生时间
  firstOccurred: Date;                // 首次发生时间
  resolved: boolean;                  // 是否已解决
  tags: string[];                     // 标签
  relatedPatterns?: string[];         // 可预防此错误的模式
  createdBy: string;                  // 记录人
  createdAt: Date;                    // 创建时间
}
```

### 错误分类（category）

- `async` - 异步处理错误
- `validation` - 验证错误
- `database` - 数据库错误
- `authentication` - 认证错误
- `authorization` - 授权错误
- `performance` - 性能问题
- `memory` - 内存泄漏
- `race-condition` - 竞态条件
- `integration` - 集成问题
- `deployment` - 部署错误

### JSON示例

```json
{
  "version": "1.0",
  "lastUpdated": "2025-01-04T14:00:00Z",
  "errors": [
    {
      "id": "ERROR-001",
      "category": "async",
      "symptom": "用户登录后偶尔看到 'UnhandledPromiseRejection' 错误",
      "rootCause": "AuthService.login()方法中数据库查询Promise未被正确catch",
      "preventionMeasures": [
        "所有async函数必须使用try-catch包裹",
        "在代码审查中检查Promise rejection handling",
        "添加ESLint规则 no-floating-promises"
      ],
      "detectionMethod": "运行时错误日志 + 单元测试覆盖异常路径",
      "relatedFiles": [
        "src/lib/services/AuthService.ts"
      ],
      "riskLevel": "high",
      "impact": "用户无法登录，生产环境崩溃",
      "occurrenceCount": 3,
      "lastOccurred": "2024-12-20T15:30:00Z",
      "firstOccurred": "2024-12-18T10:00:00Z",
      "resolved": true,
      "tags": ["async", "error-handling", "production-bug"],
      "relatedPatterns": ["PATTERN-004"],
      "createdBy": "ai-dev",
      "createdAt": "2024-12-18T11:00:00Z"
    },
    {
      "id": "ERROR-002",
      "category": "validation",
      "symptom": "用户提交表单后收到500错误而非400验证错误",
      "rootCause": "API endpoint未使用Zod验证，直接处理未验证的输入导致数据库约束违反",
      "preventionMeasures": [
        "所有API endpoints必须使用Zod schema验证输入",
        "在proposal.md中明确列出验证需求",
        "添加集成测试覆盖invalid input场景"
      ],
      "detectionMethod": "集成测试发送invalid payload",
      "relatedFiles": [
        "src/app/api/users/route.ts",
        "src/lib/schemas/user.ts"
      ],
      "riskLevel": "medium",
      "impact": "用户体验差，错误消息不清晰",
      "occurrenceCount": 5,
      "lastOccurred": "2024-12-25T09:15:00Z",
      "firstOccurred": "2024-12-15T14:20:00Z",
      "resolved": true,
      "tags": ["validation", "api", "user-experience"],
      "relatedPatterns": ["PATTERN-003"],
      "createdBy": "ai-dev",
      "createdAt": "2024-12-15T15:00:00Z"
    },
    {
      "id": "ERROR-003",
      "category": "database",
      "symptom": "用户报告数据丢失：保存后刷新页面数据不见了",
      "rootCause": "Repository.save()方法未await数据库事务commit",
      "preventionMeasures": [
        "所有数据库写操作必须await",
        "使用TypeScript strict mode确保Promise被正确处理",
        "添加E2E测试验证数据持久化"
      ],
      "detectionMethod": "E2E测试：保存 -> 刷新 -> 验证数据存在",
      "relatedFiles": [
        "src/lib/repositories/UserRepository.ts"
      ],
      "riskLevel": "critical",
      "impact": "数据丢失，用户信任度降低",
      "occurrenceCount": 2,
      "lastOccurred": "2024-12-28T11:45:00Z",
      "firstOccurred": "2024-12-27T16:30:00Z",
      "resolved": true,
      "tags": ["database", "data-loss", "critical"],
      "relatedPatterns": ["PATTERN-001"],
      "createdBy": "ai-dev",
      "createdAt": "2024-12-27T17:00:00Z"
    },
    {
      "id": "ERROR-004",
      "category": "performance",
      "symptom": "用户列表页面加载超过5秒",
      "rootCause": "N+1查询问题：循环中调用数据库查询而非使用JOIN",
      "preventionMeasures": [
        "使用ORM的eager loading或JOIN避免N+1查询",
        "在代码审查中检查循环内的数据库调用",
        "添加性能基准测试（<1s for 100 records）"
      ],
      "detectionMethod": "性能监控 + 数据库查询日志分析",
      "relatedFiles": [
        "src/lib/repositories/UserRepository.ts",
        "src/app/api/users/route.ts"
      ],
      "riskLevel": "medium",
      "impact": "用户体验差，页面加载慢",
      "occurrenceCount": 1,
      "lastOccurred": "2025-01-02T10:00:00Z",
      "firstOccurred": "2025-01-02T10:00:00Z",
      "resolved": true,
      "tags": ["performance", "database", "n+1-query"],
      "relatedPatterns": ["PATTERN-001"],
      "createdBy": "ai-dev",
      "createdAt": "2025-01-02T10:30:00Z"
    },
    {
      "id": "ERROR-005",
      "category": "validation",
      "symptom": "用户上传超大文件导致服务器崩溃",
      "rootCause": "文件上传endpoint未限制文件大小",
      "preventionMeasures": [
        "使用multer或类似中间件限制文件大小（如10MB）",
        "在前端也添加文件大小验证提供即时反馈",
        "添加集成测试上传超大文件验证错误处理"
      ],
      "detectionMethod": "集成测试上传11MB文件",
      "relatedFiles": [
        "src/app/api/upload/route.ts",
        "src/middleware/upload.ts"
      ],
      "riskLevel": "high",
      "impact": "服务器内存耗尽，影响所有用户",
      "occurrenceCount": 2,
      "lastOccurred": "2025-01-03T14:20:00Z",
      "firstOccurred": "2025-01-03T13:50:00Z",
      "resolved": false,
      "tags": ["validation", "file-upload", "memory", "security"],
      "relatedPatterns": ["PATTERN-003"],
      "createdBy": "ai-dev",
      "createdAt": "2025-01-03T14:30:00Z"
    }
  ]
}
```

### 查询错误

```typescript
// 查找未解决的高风险错误
function findUnresolvedHighRiskErrors(): HistoricalError[] {
  const db = JSON.parse(readFile('knowledge/errors.json'));
  return db.errors.filter(e =>
    !e.resolved && (e.riskLevel === 'high' || e.riskLevel === 'critical')
  );
}

// 按category查询
function findErrorsByCategory(category: string): HistoricalError[] {
  const db = JSON.parse(readFile('knowledge/errors.json'));
  return db.errors.filter(e => e.category === category);
}

// 查找相关预防措施
function getPreventionMeasures(tags: string[]): string[] {
  const db = JSON.parse(readFile('knowledge/errors.json'));
  const relevantErrors = db.errors.filter(e =>
    e.tags.some(tag => tags.includes(tag))
  );
  return Array.from(new Set(
    relevantErrors.flatMap(e => e.preventionMeasures)
  ));
}
```

---

## 3. learnings.md - 经验总结文档

### Markdown 格式定义

```markdown
# Project Learnings - 项目经验总结

> 记录每次变更的经验教训，持续改进

## 目录
- [2025-01](#2025-01)
  - [Sprint 05 - User Authentication](#sprint-05---user-authentication)
  - [Sprint 04 - Profile Management](#sprint-04---profile-management)
- [2024-12](#2024-12)
  - [Sprint 03 - Initial Setup](#sprint-03---initial-setup)

---

## 2025-01

### Sprint 05 - User Authentication
**Change ID**: 001-user-auth
**Date**: 2025-01-04
**Duration**: 4.5 hours (estimated 4h)
**Complexity**: Medium

#### Applied Patterns
- ✅ PATTERN-001: Repository Pattern
- ✅ PATTERN-002: Service Layer Pattern
- ✅ PATTERN-003: Zod Schema Validation
- ✅ PATTERN-004: Custom Error Classes

#### Avoided Errors
- ⚠️ ERROR-001: 所有async函数使用try-catch
- ⚠️ ERROR-002: API endpoints使用Zod验证

#### Lessons Learned

**What Went Well**:
1. **Repository Pattern isolation** - 数据层完全隔离，后续切换ORM很容易
2. **Zod validation** - 在API边界验证输入，减少90%的invalid data问题
3. **OODA autonomous completion** - Phase 4自主完成7个任务，仅需2次人工干预

**What Could Be Improved**:
1. **Initial scope clarity** - Phase 1 proposal需要refine 1次，花费15分钟
2. **Test coverage planning** - 应在Phase 3 design中明确测试策略，避免Phase 4补测试

**Key Takeaways**:
- 优先使用Zod validation避免ERROR-002类型问题
- Repository Pattern值得前期投资，长期维护成本低
- Phase 1 proposal应包含"Out of Scope"部分明确边界

**Metrics**:
- Tests: 27/27 passing (100%)
- Build time: 3.2s
- Code coverage: 89%
- OODA iterations: 7/10
- Quality score: 92/100

**Knowledge Updates**:
- patterns.json: PATTERN-001使用次数+1
- errors.json: 无新错误 ✅

---

### Sprint 04 - Profile Management
**Change ID**: 042-profile-mgmt
**Date**: 2025-01-02
**Duration**: 3 hours (estimated 3h)
**Complexity**: Simple

#### Applied Patterns
- ✅ PATTERN-001: Repository Pattern
- ✅ PATTERN-003: Zod Schema Validation

#### Avoided Errors
- ⚠️ ERROR-004: 使用JOIN避免N+1查询

#### Lessons Learned

**What Went Well**:
1. **Reused existing patterns** - UserRepository模式直接复用，节省1小时设计时间
2. **Performance baseline from start** - 在Phase 3设计时就考虑N+1问题，避免后期优化

**What Could Be Improved**:
1. **File upload error handling** - 未预见ERROR-005，生产环境出现文件大小问题

**Key Takeaways**:
- 文件上传功能必须添加文件大小限制（前后端都要）
- 性能基准测试应在Phase 5执行，而非上线后发现

**Metrics**:
- Tests: 18/18 passing (100%)
- Build time: 2.8s
- Code coverage: 91%
- OODA iterations: 5/10
- Quality score: 88/100

**Knowledge Updates**:
- errors.json: 新增ERROR-005 (文件上传大小限制)
- patterns.json: PATTERN-001使用次数+1

---

## 2024-12

### Sprint 03 - Initial Setup
**Change ID**: 000-init
**Date**: 2024-12-15
**Duration**: 2 hours
**Complexity**: Simple

#### Applied Patterns
- ✅ PATTERN-001: Repository Pattern (新建)
- ✅ PATTERN-002: Service Layer Pattern (新建)

#### Lessons Learned

**What Went Well**:
1. **Global constraints setup** - 创建requirements.md/design.md为后续变更提供清晰指导
2. **Pattern documentation** - 第一次就建立patterns.json，后续变更直接复用

**Key Takeaways**:
- 项目初始化时设置全局约束非常重要
- 第一个功能就应建立最佳实践模式

**Metrics**:
- Setup time: 2h
- Patterns created: 4
- Global constraints: 完整

---

## 统计摘要 (2024-12 ~ 2025-01)

- **Total Sprints**: 5
- **Total Changes**: 43
- **Success Rate**: 95% (41/43完成)
- **Average OODA Iterations**: 6.2/10
- **Average Quality Score**: 90/100
- **Pattern Library Size**: 12 patterns
- **Error Library Size**: 5 errors (3 resolved)
- **Most Used Pattern**: PATTERN-001 (25次)
- **Top Risk**: ERROR-005 (未解决，high risk)

---

## 最佳实践总结

### 架构
1. **始终使用Repository Pattern** - 数据层隔离
2. **Service Layer协调业务逻辑** - 避免Controller臃肿
3. **Dependency Injection** - 便于测试和替换实现

### 验证
1. **Zod schema at API boundary** - 100%输入验证覆盖
2. **前后端双重验证** - 前端UX + 后端安全

### 错误处理
1. **Custom Error Classes** - 语义化错误
2. **所有async函数try-catch** - 避免UnhandledPromiseRejection

### 测试
1. **单元测试 + 集成测试 + E2E测试** - 三层覆盖
2. **异常路径测试** - 覆盖invalid input和error cases
3. **性能基准测试** - 早期发现性能问题

### 工作流
1. **Phase 1 proposal明确边界** - "In Scope" + "Out of Scope"
2. **Phase 3 design考虑性能** - 避免后期优化
3. **Phase 5 修复high-confidence issues** - 质量优先

---

*此文档由ai-dev在Phase 6自动更新*
```

### Learning Entry 模板

每次变更完成后添加的entry应包含：

1. **Change元信息**：Change ID, Date, Duration, Complexity
2. **Applied Patterns**：使用了哪些模式（引用PATTERN-ID）
3. **Avoided Errors**：预防了哪些已知错误（引用ERROR-ID）
4. **Lessons Learned**：
   - What Went Well
   - What Could Be Improved
   - Key Takeaways
5. **Metrics**：Tests, Build time, Coverage, OODA iterations, Quality score
6. **Knowledge Updates**：patterns.json和errors.json的更新

---

## Phase 0 知识预查流程

### 查询逻辑

```typescript
function performPhase0KnowledgeCheck(changeIntent: string, tags: string[]): Phase0Context {
  // 1. 查询相关成功模式
  const relevantPatterns = searchPatterns(changeIntent);
  const taggedPatterns = tags.flatMap(tag => findPatternsByTag(tag));
  const combinedPatterns = deduplicateById([...relevantPatterns, ...taggedPatterns]);

  // 2. 查询相关历史错误
  const relevantErrors = tags.flatMap(tag => findErrorsByCategory(tag));
  const unresolvedErrors = findUnresolvedHighRiskErrors();

  // 3. 提取预防措施
  const preventionMeasures = getPreventionMeasures(tags);

  // 4. 风险评估
  const riskLevel = assessRisk(relevantErrors, unresolvedErrors);

  // 5. 生成phase0-context.md
  return {
    patterns: combinedPatterns.slice(0, 5),  // Top 5相关模式
    errors: relevantErrors.filter(e => !e.resolved),  // 仅未解决错误
    preventionMeasures,
    riskLevel,
    recommendations: generateRecommendations(combinedPatterns, relevantErrors)
  };
}

function assessRisk(errors: HistoricalError[], unresolved: HistoricalError[]): 'low' | 'medium' | 'high' {
  if (unresolved.some(e => e.riskLevel === 'critical')) return 'high';
  if (unresolved.some(e => e.riskLevel === 'high')) return 'high';
  if (errors.some(e => e.riskLevel === 'high')) return 'medium';
  return 'low';
}
```

### phase0-context.md 生成示例

```markdown
# Phase 0: Knowledge Pre-check Context

**Change Intent**: 实现用户登录功能
**Tags**: authentication, api, validation
**Risk Level**: Medium

## Relevant Success Patterns

### PATTERN-001: Repository Pattern
**Category**: architecture
**Usage**: 25 times (98% success rate)
**Recommendation**: 使用Repository隔离数据访问层

**Code Example**:
\`\`\`typescript
export interface IUserRepository {
  findByEmail(email: string): Promise<User | null>;
}
\`\`\`

**Related Files**:
- src/lib/interfaces/IUserRepository.ts
- src/lib/repositories/UserRepository.ts

---

### PATTERN-003: Zod Schema Validation
**Category**: validation
**Usage**: 42 times (100% success rate)
**Recommendation**: 所有API endpoints使用Zod验证输入

**Code Example**:
\`\`\`typescript
const loginSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
});
\`\`\`

---

## Historical Errors to Avoid

### ERROR-001: UnhandledPromiseRejection in async functions
**Risk Level**: High
**Occurrences**: 3 times
**Last Occurred**: 2024-12-20

**Symptom**: 用户登录后偶尔看到 'UnhandledPromiseRejection' 错误

**Prevention Measures**:
- 所有async函数必须使用try-catch包裹
- 添加ESLint规则 no-floating-promises

---

### ERROR-002: API返回500而非400验证错误
**Risk Level**: Medium
**Occurrences**: 5 times
**Last Occurred**: 2024-12-25

**Prevention Measures**:
- 所有API endpoints必须使用Zod schema验证输入
- 添加集成测试覆盖invalid input场景

---

## Risk Assessment

**Overall Risk**: Medium

**Reasons**:
- ⚠️ ERROR-001 (high risk, 已解决但需警惕)
- ⚠️ ERROR-002 (medium risk, 5次发生)
- ✅ 有成熟的PATTERN-001和PATTERN-003可参考

## Recommendations

1. **使用PATTERN-001 (Repository Pattern)** - 隔离数据访问层
2. **使用PATTERN-003 (Zod Validation)** - API边界验证输入
3. **警惕ERROR-001** - 所有async函数try-catch
4. **参考已有实现** - 查看src/lib/repositories/UserRepository.ts
5. **测试异常路径** - 覆盖invalid email、wrong password等场景

## Suggested File References

基于patterns和errors分析，建议参考以下文件：
- src/lib/repositories/UserRepository.ts (Repository模式参考)
- src/lib/schemas/auth.ts (Zod schema参考)
- src/lib/services/AuthService.ts (Service Layer参考)

---

*Generated by ai-dev Phase 0 - 2025-01-04T09:55:00Z*
```

---

## Phase 6 知识更新流程

### 更新逻辑

```typescript
function performPhase6KnowledgeUpdate(
  changeId: string,
  appliedPatterns: string[],
  newErrors?: HistoricalError,
  learningEntry: LearningEntry
): void {
  // 1. 更新patterns.json - 增加使用次数
  for (const patternId of appliedPatterns) {
    updatePatternUsage(patternId);
  }

  // 2. 更新errors.json - 添加新错误或更新existing
  if (newErrors) {
    addOrUpdateError(newErrors);
  }

  // 3. 更新learnings.md - 追加learning entry
  appendLearningEntry(learningEntry);

  console.log(`✅ Knowledge base updated for change ${changeId}`);
}

function updatePatternUsage(patternId: string): void {
  const db = JSON.parse(readFile('knowledge/patterns.json'));
  const pattern = db.patterns.find(p => p.id === patternId);
  if (pattern) {
    pattern.usageCount++;
    pattern.lastUsed = new Date().toISOString();
  }
  writeFile('knowledge/patterns.json', JSON.stringify(db, null, 2));
}

function addOrUpdateError(error: HistoricalError): void {
  const db = JSON.parse(readFile('knowledge/errors.json'));
  const existing = db.errors.find(e => e.id === error.id);

  if (existing) {
    existing.occurrenceCount++;
    existing.lastOccurred = new Date().toISOString();
  } else {
    db.errors.push(error);
  }

  db.lastUpdated = new Date().toISOString();
  writeFile('knowledge/errors.json', JSON.stringify(db, null, 2));
}

function appendLearningEntry(entry: LearningEntry): void {
  const content = readFile('knowledge/learnings.md');
  const newEntry = formatLearningEntry(entry);
  const updatedContent = insertEntryAtTop(content, newEntry);
  writeFile('knowledge/learnings.md', updatedContent);
}
```

---

## 初始化知识库

### 项目初始化时创建

```bash
# 由project-initializer在初始化时创建
mkdir -p codebox/knowledge

# 创建空的patterns.json
echo '{
  "version": "1.0",
  "lastUpdated": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
  "patterns": []
}' > codebox/knowledge/patterns.json

# 创建空的errors.json
echo '{
  "version": "1.0",
  "lastUpdated": "'$(date -u +%Y-%m-%dT%H:%M:%SZ)'",
  "errors": []
}' > codebox/knowledge/errors.json

# 创建learnings.md模板
cat > codebox/knowledge/learnings.md << 'EOF'
# Project Learnings - 项目经验总结

> 记录每次变更的经验教训，持续改进

## 目录

---

*此文档由ai-dev在Phase 6自动更新*
EOF
```

---

## 最佳实践

### Patterns
1. **尽早建立** - 第一个功能就应记录成功模式
2. **详细描述** - 包含context和code example
3. **定期清理** - 移除过时或不再使用的模式（usageCount = 0超过6个月）

### Errors
1. **及时记录** - 发现错误后立即记录，不要等修复后才记录
2. **详细根因** - 不仅记录symptom，更要记录root cause
3. **可操作预防措施** - 预防措施要具体可执行

### Learnings
1. **每次变更都记录** - 即使是小变更也有价值
2. **诚实反思** - "What Could Be Improved"要诚实
3. **量化指标** - 记录tests、coverage、quality score等客观数据

---

**核心价值**：知识积累 = 持续改进 = 错误不重复 = 质量螺旋上升
