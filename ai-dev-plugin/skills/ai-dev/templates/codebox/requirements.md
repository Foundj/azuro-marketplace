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
**THE SYSTEM SHALL** 使用统一的错误处理机制
**SO THAT** 错误追踪一致，便于调试和监控

### REQ-GLOBAL-003: 数据验证
**WHEN** 处理用户输入或外部数据
**THE SYSTEM SHALL** 进行 schema 验证
**SO THAT** 数据类型安全，防止运行时错误

---

## 非功能性需求

### REQ-GLOBAL-NFR-001: 性能
**WHEN** 用户发起任何请求
**THE SYSTEM SHALL** 在合理时间内响应
**SO THAT** 用户体验流畅

### REQ-GLOBAL-NFR-002: 安全
**WHEN** 处理用户输入
**THE SYSTEM SHALL** 进行输入验证和消毒
**SO THAT** 防止 XSS 和注入攻击

### REQ-GLOBAL-NFR-003: 可维护性
**WHEN** 编写任何代码
**THE SYSTEM SHALL** 遵循代码规范和最佳实践
**SO THAT** 代码易于理解和维护

---

## 技术栈约束

> 根据项目实际情况填写

- **前端**: 
- **后端**: 
- **数据库**: 
- **测试**: 

---

## 引用说明

所有变更的 proposal.md 必须：

1. **明确引用相关的全局需求 ID**
   示例：本变更满足 REQ-GLOBAL-001 (API 规范)

2. **说明如何满足这些需求**
   示例：使用 RESTful endpoints，返回标准 JSON 响应

3. **如需偏离，必须提供充分理由并获用户批准**

---

## 更新日志

- **初始版本**: [日期]
