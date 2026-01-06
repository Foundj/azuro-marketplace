# 项目全局架构设计

> 本文档定义项目整体架构，所有变更必须遵循

---

## 架构原则

### 1. 分层架构 (Layered Architecture)

```
┌─────────────────────────────────────┐
│   Presentation Layer (UI)          │  ← React Components, Pages
├─────────────────────────────────────┤
│   Application Layer (Business)     │  ← Services, Use Cases
├─────────────────────────────────────┤
│   Domain Layer (Core Models)       │  ← Entities, Value Objects
├─────────────────────────────────────┤
│   Infrastructure Layer (External)  │  ← Database, APIs, File System
└─────────────────────────────────────┘
```

**规则**:
- 上层可以依赖下层，下层不能依赖上层
- Domain Layer 不依赖任何层（纯业务逻辑）
- Infrastructure Layer 实现 Domain Layer 定义的接口

### 2. 单一职责 (Single Responsibility)

- 每个模块只负责一个领域
- 每个类/函数只做一件事
- 避免 God Objects（上帝对象）

### 3. 依赖注入 (Dependency Injection)

```typescript
// ❌ Bad: 硬编码依赖
class UserService {
  private repo = new UserRepository(); // 耦合
}

// ✅ Good: 依赖注入
class UserService {
  constructor(private repo: IUserRepository) {} // 解耦
}
```

---

## 模块组织

```
src/
├── app/                    # Next.js App Router
│   ├── (auth)/            # Route groups
│   ├── api/               # API routes
│   └── layout.tsx         # Root layout
│
├── components/             # React 组件
│   ├── ui/                # 基础 UI 组件
│   ├── features/          # 功能组件
│   └── layouts/           # 布局组件
│
├── lib/                   # 核心业务逻辑
│   ├── services/          # 业务服务
│   ├── models/            # 领域模型
│   ├── repositories/      # 数据访问层
│   └── utils/             # 工具函数
│
├── api/                   # Hono API (如果独立后端)
│   ├── routes/            # 路由定义
│   ├── middleware/        # 中间件
│   └── handlers/          # 请求处理器
│
└── db/                    # Drizzle 数据库层
    ├── schema/            # 表定义
    ├── migrations/        # 迁移脚本
    └── client.ts          # 数据库连接
```

---

## 数据流模式

### 前端数据流

```
User Action → Component → Service → Repository → Database
             ↓
          State Management (Zustand/Context)
```

### API 数据流

```
HTTP Request → Middleware (Auth, Validation) → Handler → Service → Repository → Database
                                                  ↓
                                            HTTP Response
```

---

## 错误处理模式

### 统一错误类

```typescript
// src/lib/errors/AppError.ts
export class AppError extends Error {
  constructor(
    public code: string,
    public message: string,
    public statusCode: number = 500,
    public details?: any
  ) {
    super(message);
    this.name = 'AppError';
  }
}

// 使用示例
throw new AppError('AUTH_FAILED', 'Invalid credentials', 401);
throw new AppError('NOT_FOUND', 'User not found', 404);
```

### 错误处理流程

```typescript
// 所有 async 函数必须包装
async function handleRequest() {
  try {
    const result = await businessLogic();
    return { success: true, data: result };
  } catch (err) {
    if (err instanceof AppError) {
      return { success: false, error: { code: err.code, message: err.message } };
    }
    // 未知错误
    return { success: false, error: { code: 'UNKNOWN', message: 'Internal error' } };
  }
}
```

---

## API 设计模式

### RESTful Endpoints

```
GET    /api/v1/users           # 列表
GET    /api/v1/users/:id       # 详情
POST   /api/v1/users           # 创建
PUT    /api/v1/users/:id       # 更新（全量）
PATCH  /api/v1/users/:id       # 更新（部分）
DELETE /api/v1/users/:id       # 删除
```

### 标准响应格式

```typescript
// 成功响应
{
  "success": true,
  "data": { ... }
}

// 错误响应
{
  "success": false,
  "error": {
    "code": "AUTH_FAILED",
    "message": "Invalid credentials"
  }
}

// 分页响应
{
  "success": true,
  "data": [...],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "total": 100,
    "totalPages": 5
  }
}
```

---

## 测试策略

### 测试金字塔

```
        /\
       /  \      E2E Tests (10%)
      /    \     - 关键用户流程
     /------\
    /        \   Integration Tests (30%)
   /          \  - API endpoints
  /            \ - 数据库交互
 /--------------\
/                \ Unit Tests (60%)
\                / - 业务逻辑
 \--------------/  - 工具函数
```

### 测试覆盖要求

- **关键路径**: 100% 覆盖（认证、支付、数据修改）
- **业务逻辑**: 80%+ 覆盖
- **UI 组件**: 核心组件需快照测试

---

## 命名约定

- **组件**: `PascalCase.tsx` (UserProfile.tsx)
- **函数**: `camelCase` (getUserById)
- **常量**: `UPPER_SNAKE_CASE` (MAX_RETRY_COUNT)
- **文件夹**: `kebab-case` (user-profile/)
- **接口**: `IPascalCase` (IUserRepository) 或 `PascalCase` (UserRepository)
- **类型**: `PascalCase` (UserDTO, CreateUserInput)

---

## 引用说明

所有变更的 design.md 必须：

1. **遵循分层架构**
   明确说明修改属于哪一层，是否引入跨层依赖

2. **使用统一的错误处理**
   所有错误必须使用 AppError 包装

3. **符合 API 设计模式**
   RESTful endpoints, 标准响应格式

4. **如需引入新模式，需在此文档更新**
   重大架构变更需要在此记录，避免模式混乱

---

## 更新日志

- **2025-01-02**: 初始版本
- 后续架构变更请记录在此
