#!/bin/bash
# 创建知识管理目录结构
# 用于 AISD-R Phase 0 知识预查和学习闭环

set -e

KNOWLEDGE_DIR=".agent/knowledge"

echo "📚 初始化知识管理系统..."

# 创建知识目录
mkdir -p "$KNOWLEDGE_DIR"

# 1. 成功模式库
cat > "$KNOWLEDGE_DIR/patterns.json" <<'EOF'
{
  "$schema": "knowledge-patterns-schema-v1",
  "patterns": [
    {
      "id": "PATTERN-001",
      "name": "Repository Pattern",
      "category": "architecture",
      "description": "数据访问抽象层，分离业务逻辑和数据库操作",
      "usage_count": 0,
      "success_rate": 0,
      "example_file": "src/lib/repositories/UserRepository.ts",
      "when_to_use": "需要抽象数据访问逻辑，便于测试和切换数据源时",
      "benefits": [
        "业务逻辑与数据访问解耦",
        "易于编写单元测试（可 mock repository）",
        "易于切换数据源（SQL → NoSQL）",
        "集中处理数据访问错误"
      ],
      "example_code": {
        "interface": "export interface IUserRepository {\n  findById(id: string): Promise<User | null>;\n  create(data: CreateUserDTO): Promise<User>;\n  update(id: string, data: UpdateUserDTO): Promise<User>;\n  delete(id: string): Promise<void>;\n}",
        "implementation": "export class UserRepository implements IUserRepository {\n  constructor(private db: Database) {}\n  \n  async findById(id: string): Promise<User | null> {\n    return this.db.query.users.findFirst({ where: eq(users.id, id) });\n  }\n}"
      },
      "related_errors": ["ERROR-003"],
      "tags": ["database", "clean-architecture", "dependency-injection"]
    },
    {
      "id": "PATTERN-002",
      "name": "Service Layer Pattern",
      "category": "architecture",
      "description": "业务逻辑封装层，协调多个 repositories 和外部服务",
      "usage_count": 0,
      "success_rate": 0,
      "example_file": "src/lib/services/AuthService.ts",
      "when_to_use": "业务逻辑涉及多个数据源或复杂协调时",
      "benefits": [
        "集中业务逻辑",
        "可复用业务规则",
        "易于测试（注入 mock repositories）"
      ],
      "tags": ["business-logic", "clean-architecture"]
    },
    {
      "id": "PATTERN-003",
      "name": "Error Boundary (React)",
      "category": "error-handling",
      "description": "React 组件错误边界，捕获子组件错误",
      "usage_count": 0,
      "success_rate": 0,
      "example_file": "src/components/ErrorBoundary.tsx",
      "when_to_use": "需要优雅处理 UI 组件错误，防止整个应用崩溃时",
      "benefits": [
        "防止整个应用崩溃",
        "提供用户友好的错误页面",
        "记录错误日志"
      ],
      "tags": ["react", "error-handling", "ui"]
    }
  ],
  "statistics": {
    "total_patterns": 3,
    "most_used_category": null,
    "average_success_rate": 0
  }
}
EOF

# 2. 错误库
cat > "$KNOWLEDGE_DIR/errors.json" <<'EOF'
{
  "$schema": "knowledge-errors-schema-v1",
  "errors": [
    {
      "id": "ERROR-001",
      "category": "async",
      "title": "未处理的 Promise rejection",
      "severity": "high",
      "occurrences": 0,
      "last_seen": null,
      "root_cause": "异步函数缺少 try-catch 包装",
      "symptoms": [
        "UnhandledPromiseRejectionWarning",
        "应用崩溃",
        "无错误日志"
      ],
      "prevention": [
        "所有 async 函数必须用 try-catch 包装",
        "使用 Promise.catch() 处理 rejected promises",
        "配置全局 unhandledRejection 监听器",
        "使用 ESLint 规则 @typescript-eslint/no-floating-promises"
      ],
      "detection": [
        "运行时监控 unhandledRejection 事件",
        "ESLint 静态检查"
      ],
      "example": {
        "bad": "async function fetchUser(id: string) {\n  const user = await api.getUser(id); // ❌ 无错误处理\n  return user;\n}",
        "good": "async function fetchUser(id: string) {\n  try {\n    const user = await api.getUser(id);\n    return { success: true, data: user };\n  } catch (err) {\n    logger.error('Failed to fetch user', { id, error: err });\n    return { success: false, error: err };\n  }\n}"
      },
      "related_patterns": ["PATTERN-002"],
      "tags": ["async", "error-handling", "promise"]
    },
    {
      "id": "ERROR-002",
      "category": "security",
      "title": "SQL 注入漏洞",
      "severity": "critical",
      "occurrences": 0,
      "last_seen": null,
      "root_cause": "使用字符串拼接构造 SQL 查询",
      "symptoms": [
        "数据库被篡改",
        "未授权数据访问"
      ],
      "prevention": [
        "使用 Drizzle ORM（自动参数化查询）",
        "禁止字符串拼接 SQL",
        "使用 prepared statements",
        "输入验证（Zod schema）"
      ],
      "detection": [
        "代码审查检查字符串拼接 SQL",
        "安全扫描工具"
      ],
      "example": {
        "bad": "const query = `SELECT * FROM users WHERE email = '${email}'`; // ❌ SQL 注入",
        "good": "const user = await db.query.users.findFirst({ where: eq(users.email, email) }); // ✅ Drizzle ORM"
      },
      "tags": ["security", "sql", "database"]
    },
    {
      "id": "ERROR-003",
      "category": "architecture",
      "title": "业务逻辑耦合数据访问",
      "severity": "medium",
      "occurrences": 0,
      "last_seen": null,
      "root_cause": "Service 层直接使用数据库查询",
      "symptoms": [
        "难以编写单元测试",
        "难以切换数据源",
        "业务逻辑分散"
      ],
      "prevention": [
        "使用 Repository Pattern",
        "依赖注入 IRepository 接口",
        "业务逻辑只依赖接口，不依赖实现"
      ],
      "detection": [
        "代码审查检查 Service 是否直接导入 db 实例"
      ],
      "example": {
        "bad": "class AuthService {\n  async login(email: string) {\n    const user = await db.query.users.findFirst(...); // ❌ 直接耦合\n  }\n}",
        "good": "class AuthService {\n  constructor(private userRepo: IUserRepository) {} // ✅ 依赖注入\n  \n  async login(email: string) {\n    const user = await this.userRepo.findByEmail(email);\n  }\n}"
      },
      "related_patterns": ["PATTERN-001"],
      "tags": ["architecture", "clean-code", "testing"]
    }
  ],
  "statistics": {
    "total_errors": 3,
    "by_severity": {
      "critical": 1,
      "high": 1,
      "medium": 1,
      "low": 0
    },
    "most_common_category": null
  }
}
EOF

# 3. 经验总结
cat > "$KNOWLEDGE_DIR/learnings.md" <<'EOF'
# 项目经验总结

> 记录开发过程中的成功经验、教训和建议

## 📅 2025-01-02 - 项目初始化

### ✅ 成功经验

**无（项目刚初始化）**

### ⚠️ 教训

**无（项目刚初始化）**

### 💡 建议

- 新功能优先考虑复用现有 patterns（参考 knowledge/patterns.json）
- 高风险操作（认证、支付、数据修改）必须详细测试
- 遇到问题先查询 knowledge/errors.json，避免重复错误

---

## 📋 如何使用此文档

### 添加成功经验
```markdown
## 📅 YYYY-MM-DD - 功能名称

### ✅ 成功经验
- **模式应用**: [PATTERN-XXX] 在 [模块名] 中运作良好，[具体收益]
- **技术选型**: [技术名] 比 [替代方案] 更适合，因为 [原因]
- **性能优化**: [优化手段] 使 [指标] 提升 [百分比]
```

### 添加教训
```markdown
### ⚠️ 教训
- **错误重现**: [ERROR-XXX] 在 [场景] 中再次出现，根因是 [分析]
- **性能问题**: [问题描述]，解决方案是 [方案]
- **架构决策**: [决策] 导致 [负面影响]，应该 [改进建议]
```

### 添加建议
```markdown
### 💡 建议
- [针对未来开发的建议]
- [需要注意的风险点]
- [推荐的最佳实践]
```

---

## 🎯 知识闭环流程

1. **Phase 0 预查**: 每个变更开始前查询此知识库
2. **Phase 1-5 执行**: 实施变更
3. **Phase 6 总结**: 更新此文档（成功经验、教训、建议）
4. **知识积累**: patterns.json, errors.json 自动更新统计

---

## 📊 知识库统计

- **成功模式**: 3个
- **历史错误**: 3个
- **经验条目**: 0个（待积累）

**下一步**: 完成第一个 feature，积累第一条真实经验！
EOF

# 4. 创建 README
cat > "$KNOWLEDGE_DIR/README.md" <<'EOF'
# Knowledge Management System

## 📚 概述

这是 AISD-R Phase 0 知识管理系统，用于：
- **事前预防**: 变更开始前查询历史错误和成功模式
- **持续学习**: 每次变更后积累经验教训
- **知识复用**: 识别可复用的架构模式和解决方案

## 📂 文件说明

### `patterns.json` - 成功模式库
记录在项目中验证有效的架构模式、设计模式、最佳实践。

**字段说明**:
- `id`: 模式唯一标识 (PATTERN-XXX)
- `name`: 模式名称
- `category`: 分类（architecture, error-handling, performance, etc.）
- `usage_count`: 使用次数（越高 = 越成熟）
- `success_rate`: 成功率（0-1）
- `when_to_use`: 适用场景
- `benefits`: 收益列表
- `example_code`: 代码示例

### `errors.json` - 错误库
记录历史错误、根因分析、预防措施。

**字段说明**:
- `id`: 错误唯一标识 (ERROR-XXX)
- `category`: 分类（async, security, architecture, etc.）
- `severity`: 严重程度（critical, high, medium, low）
- `occurrences`: 发生次数
- `root_cause`: 根因分析
- `prevention`: 预防措施列表
- `example`: 错误代码 vs 正确代码

### `learnings.md` - 经验总结
按时间顺序记录项目开发中的成功经验、教训、建议。

**格式**:
```markdown
## 📅 YYYY-MM-DD - 功能名称
### ✅ 成功经验
### ⚠️ 教训
### 💡 建议
```

## 🔄 使用流程

### Phase 0: 知识预查 (变更开始前)

```bash
# 自动查询知识库
node .claude/scripts/knowledge-search.js \
  --query "用户登录功能" \
  --categories "patterns,errors"

# 输出预查报告
{
  "相关模式": ["PATTERN-001: Repository Pattern", "PATTERN-002: Service Layer"],
  "历史错误": ["ERROR-001: 未处理 Promise", "ERROR-003: 业务逻辑耦合"],
  "风险等级": "中",
  "预防措施": [
    "使用 Repository Pattern 分离数据访问",
    "所有 async 函数必须 try-catch",
    "使用依赖注入便于测试"
  ]
}
```

### Phase 6: 知识更新 (变更完成后)

```bash
# 更新成功模式
node .claude/scripts/knowledge-update.js \
  --type pattern \
  --id PATTERN-001 \
  --action increment_usage

# 记录新错误
node .claude/scripts/knowledge-update.js \
  --type error \
  --id ERROR-004 \
  --data '{"title": "...", "prevention": [...]}'

# 追加经验总结
echo "## 📅 $(date +%Y-%m-%d) - 用户登录
### ✅ 成功经验
- Repository Pattern 在认证模块运作良好
" >> learnings.md
```

## 📊 统计信息

查看知识库统计:
```bash
node .claude/scripts/knowledge-stats.js

# 输出示例:
# 成功模式: 12个
# 历史错误: 8个
# 最常用模式: PATTERN-001 (使用 23 次, 成功率 95%)
# 最常见错误: ERROR-001 (发生 5 次)
```

## 🎯 最佳实践

1. **每个变更必须 Phase 0 预查** - 避免重复历史错误
2. **及时更新知识库** - 完成变更后立即记录经验
3. **引用具体 ID** - proposal.md 中引用 PATTERN-XXX, ERROR-XXX
4. **持续改进** - 定期 review learnings.md，提炼新 patterns

## 🔗 集成

知识库与以下系统集成:
- **ai-orchestrator**: Phase 0 自动查询
- **project-initializer**: 初始化时创建知识库结构
- **session-manager**: 恢复会话时展示知识库统计
- **code-reviewer**: 检查是否遵循已知 patterns，避免已知 errors
EOF

echo "✅ 知识管理系统初始化完成！"
echo ""
echo "创建的文件："
echo "  - $KNOWLEDGE_DIR/patterns.json (成功模式库)"
echo "  - $KNOWLEDGE_DIR/errors.json (错误库)"
echo "  - $KNOWLEDGE_DIR/learnings.md (经验总结)"
echo "  - $KNOWLEDGE_DIR/README.md (使用说明)"
echo ""
echo "📚 知识库已就绪，可开始 Phase 0 预查！"
