# Project Initializer Templates

> 初始化文件模板和详细配置

## Global Constraints Templates

### requirements.md (EARS 格式)

```markdown
# Global Requirements (EARS Format)

## REQ-GLOBAL-001: API Response Format
WHEN a client makes an API request
THE SYSTEM SHALL return a response in format:
{
  "data": { ... },
  "meta": { page, total, ... },
  "error": { code, message }
}
SO THAT clients have a consistent interface

## REQ-GLOBAL-002: Error Handling
WHEN an error occurs in any layer
THE SYSTEM SHALL throw an AppError instance
SO THAT errors are handled consistently
```

### design.md (架构模式)

```markdown
# Global Design Patterns

## Architecture: Layered Architecture
- Presentation Layer (app/, components/)
- Application Layer (lib/services/)
- Domain Layer (lib/models/)
- Infrastructure Layer (db/, lib/repositories/)

## Pattern 1: Repository Pattern
ALL data access MUST go through repository interfaces

## Pattern 2: Service Layer
ALL business logic MUST reside in service classes
```

### CLAUDE.md (代码规范)

```markdown
# AI Behavior and Code Standards

## Code Quality Rules
- ✅ Functions ≤30 lines
- ✅ No `any` types
- ✅ Async functions MUST have try-catch
- ✅ All public functions MUST have tests

## Naming Conventions
- Files: PascalCase.tsx (components), camelCase.ts (others)
- Functions: camelCase
- Classes: PascalCase
- Constants: UPPER_SNAKE_CASE
```

### constraints.md (质量门禁)

```markdown
# Quality Constraints

## Build Quality
- [ ] ESLint: 0 errors
- [ ] TypeScript: 0 errors
- [ ] Tests passing
- [ ] Build succeeds

## Test Coverage
- Overall: ≥80%
- Critical paths: ≥95%
- New code: ≥90%
```

---

## Knowledge Base Templates

### patterns.json

```json
{
  "$schema": "knowledge-patterns-schema-v1",
  "patterns": [
    {
      "id": "PATTERN-001",
      "name": "Repository Pattern",
      "category": "architecture",
      "usage_count": 0,
      "success_rate": 0,
      "when_to_use": "需要抽象数据访问逻辑时",
      "benefits": ["业务逻辑与数据访问解耦", "易于测试"]
    }
  ]
}
```

### errors.json

```json
{
  "$schema": "knowledge-errors-schema-v1",
  "errors": [
    {
      "id": "ERROR-001",
      "category": "async",
      "title": "未处理的Promise rejection",
      "occurrence_count": 0,
      "prevention": [
        "所有async函数必须用try-catch包装",
        "使用AppError统一错误处理"
      ]
    }
  ]
}
```

---

## feature_list.json Schema (v2.0)

```json
{
  "$schema": "feature-list-schema-v2.0-enhanced",
  "version": "2.0-enhanced",
  "changes": {
    "active": [],
    "staged": [],
    "archived_count": 0
  },
  "features": [],
  "statistics": {
    "total_features": 0,
    "completed_features": 0,
    "completion_rate": 0
  },
  "metadata": {
    "created_at": "2024-01-15T10:00:00Z",
    "project_name": "项目名称",
    "workflow_version": "v2.0-enhanced"
  }
}
```