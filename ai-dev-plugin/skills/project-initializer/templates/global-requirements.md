# 项目全局需求

> 本文档定义适用于**所有功能**的全局约束
> 任何变更的 proposal.md 必须引用相关全局需求

---

## 功能性需求

### REQ-GLOBAL-001: API 规范
**WHEN** 实现任何 REST API
**THE SYSTEM SHALL** 遵循 RESTful 风格，使用标准 HTTP 状态码
**SO THAT** API 接口统一，易于理解和维护

### REQ-GLOBAL-002: 错误处理
**WHEN** 任何错误发生（前端/后端）
**THE SYSTEM SHALL** 使用统一的 AppError 类
**SO THAT** 错误追踪一致，便于调试和监控

### REQ-GLOBAL-003: 数据验证
**WHEN** 处理用户输入或外部数据
**THE SYSTEM SHALL** 使用 Zod 或类似库进行 schema 验证
**SO THAT** 数据类型安全，防止运行时错误

---

## 非功能性需求

### REQ-GLOBAL-NFR-001: 性能
**WHEN** 用户发起任何请求
**THE SYSTEM SHALL** 在 200ms 内返回首字节
**SO THAT** 用户体验流畅

### REQ-GLOBAL-NFR-002: 安全
**WHEN** 处理用户输入
**THE SYSTEM SHALL** 进行输入验证和消毒
**SO THAT** 防止 XSS 和注入攻击

### REQ-GLOBAL-NFR-003: 可维护性
**WHEN** 编写任何代码
**THE SYSTEM SHALL** 遵循函数 ≤30行，文件 ≤400行原则
**SO THAT** 代码易于理解和维护

### REQ-GLOBAL-NFR-004: 可测试性
**WHEN** 实现业务逻辑
**THE SYSTEM SHALL** 使用依赖注入，避免硬编码依赖
**SO THAT** 代码可测试，易于 mock

---

## 技术栈约束

- **前端**: Next.js 14+, React 18+, TypeScript 5+
- **后端**: Hono, Drizzle ORM
- **数据库**: PostgreSQL 14+
- **认证**: JWT + Refresh Token
- **状态管理**: Zustand 或 Context API
- **样式**: Tailwind CSS
- **测试**: Vitest (单元), Playwright (E2E)

---

## 引用说明

所有变更的 proposal.md 必须：

1. **明确引用相关的全局需求 ID**
   示例：本变更满足 REQ-GLOBAL-001 (API 规范)

2. **说明如何满足这些需求**
   示例：使用 Hono 框架实现 RESTful endpoints，返回标准 JSON 响应

3. **如需偏离，必须提供充分理由并获用户批准**
   示例：因性能原因，本 API 响应时间可能达到 500ms，需用户确认

---

## 更新日志

- **2025-01-02**: 初始版本
- 后续变更请记录在此
