---
name: knowledge-graph
description: |
  项目知识图谱系统，管理跨项目的知识关联和经验复用。
  
  **触发词**: knowledge, 知识, 知识库, 经验, 相关项目
  **命令**: /ai:knowledge
  
  **功能**:
  - 项目间依赖和关联发现
  - 历史解决方案查询
  - 技术选型推荐
  - 经验知识复用
  
  **数据管理**:
  - 最大记录: 50 条
  - 自动清理: 30 天前的记录
  - 存储位置: .claude-project/knowledge/

version: 1.0.0
---

# Knowledge Graph

> 跨项目知识图谱 - 让经验得以传承和复用

## 概述

Knowledge Graph 构建项目间的知识关联网络，帮助：
- 发现相似项目和解决方案
- 复用历史经验
- 避免重复踩坑
- 加速技术决策

---

## 知识节点类型

| 类型 | 说明 | 示例 |
|------|------|------|
| `project` | 项目节点 | my-web-app |
| `technology` | 技术栈 | React, TypeScript, Prisma |
| `pattern` | 设计模式 | Repository Pattern, MVC |
| `decision` | 技术决策 | 选择 PostgreSQL 而非 MySQL |
| `solution` | 解决方案 | JWT 认证实现 |
| `error` | 错误记录 | CORS 问题解决 |

## 关系类型

| 关系 | 说明 |
|------|------|
| `uses` | 项目使用技术 |
| `implements` | 项目实现模式 |
| `similar_to` | 相似项目 |
| `depends_on` | 依赖关系 |
| `solved_by` | 问题被方案解决 |
| `learned_from` | 从错误中学习 |

---

## 使用方式

### 查询知识

```bash
/ai:knowledge                    # 查询当前项目相关知识
/ai:knowledge auth               # 查询认证相关经验
/ai:knowledge similar            # 查找相似项目
```

### 自动集成

在 ai-dev Phase 0 (Pre-check) 中自动查询：

```
[Knowledge Graph] Searching related knowledge...

📚 Related Solutions Found:
1. JWT Authentication (from: user-portal)
   - Used in: 3 projects
   - Success rate: 95%
   - Key files: src/auth/jwt.ts

2. Session Management (from: admin-dashboard)
   - Similar tech stack
   - Includes: Redis session store
```

---

## 数据结构

### 知识记录

```json
{
  "id": "know-20250107-001",
  "type": "solution",
  "title": "JWT 认证实现",
  "project": "user-portal",
  "tech_stack": ["Next.js", "TypeScript", "Prisma"],
  "description": "完整的 JWT 认证流程，包含刷新令牌",
  "key_files": [
    "src/auth/jwt.ts",
    "src/middleware/auth.ts"
  ],
  "tags": ["auth", "jwt", "security"],
  "created_at": "2025-01-07",
  "success_count": 3,
  "failure_count": 0
}
```

### 关系记录

```json
{
  "from": "user-portal",
  "to": "jwt-authentication",
  "type": "implements",
  "strength": 0.9,
  "context": "用于用户登录和 API 保护"
}
```

---

## 数据管理

### 存储位置

项目级别：`.claude-project/knowledge/`

```
.claude-project/
└── knowledge/
    ├── nodes.json      # 知识节点
    ├── relations.json  # 关系
    └── index.json      # 索引
```

### 自动清理策略

```yaml
max_records: 50           # 最大记录数
retention_days: 30        # 保留天数
cleanup_on_start: true    # 启动时清理

cleanup_priority:
  1. 超过 30 天的记录
  2. success_count = 0 的记录
  3. 最旧的记录 (当超过 50 条)
```

### 手动清理

```bash
# 在项目目录执行
${CLAUDE_PLUGIN_ROOT}/skills/knowledge-graph/scripts/cleanup.sh
```

---

## 知识录入

### 自动录入

ai-dev 工作流完成后自动记录：
- Phase 6 (Archive) 成功时
- 标记为有价值的解决方案时

### 手动录入

```bash
/ai:knowledge add "实现了 OAuth2 第三方登录"
```

---

## 查询示例

### 技术栈匹配

```
Query: "React + TypeScript 项目的状态管理"

Results:
1. Zustand (from: dashboard-app)
   - 简单易用，适合中小项目
   - 使用次数: 5

2. Redux Toolkit (from: enterprise-portal)  
   - 功能完整，适合大型项目
   - 使用次数: 3
```

### 错误解决

```
Query: "CORS 跨域问题"

Results:
1. Next.js API Routes CORS 配置
   - 解决方案: next.config.js headers 配置
   - 成功率: 100%

2. Express CORS 中间件
   - 解决方案: cors npm 包
   - 注意: 需要配置 credentials
```

---

## 与 ai-dev 集成

```
┌─────────────────────────────────────────┐
│           ai-dev Workflow               │
├─────────────────────────────────────────┤
│                                         │
│  Phase 0 (Pre-check)                    │
│  └── knowledge-graph: 查询相关知识      │
│                                         │
│  Phase 4 (Implementation)               │
│  └── knowledge-graph: 参考历史方案      │
│                                         │
│  Phase 6 (Archive)                      │
│  └── knowledge-graph: 记录新知识        │
│                                         │
└─────────────────────────────────────────┘
```

---

## 隐私说明

- 知识图谱数据**仅存储在本地**
- 不包含敏感信息（密钥、密码等）
- 可随时删除 `.claude-project/knowledge/` 清除所有数据
