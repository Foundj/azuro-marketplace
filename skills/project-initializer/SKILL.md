---
name: project-initializer
description: |
  Initialize AI development mode for projects. Creates codebox/ directory,
  initializes knowledge base, and performs deep project structure scanning.
version: 4.1.10
---

# Project Initializer - 项目初始化系统

## 🎯 一句话说明

**为项目启用 AI 开发模式，创建 codebox/ 配置目录并执行深度扫描。**

## ⚡ 快速使用（3种方式）

### 方式1：简短触发词 ⭐ 推荐
```bash
"init project 待办事项应用"       # 最简单
"setup ai-dev"                   # 启用模式
"initialize 博客系统"             # 中文触发
```

### 方式2：带需求的初始化
```bash
"init project 创建用户管理系统，包括：
- 用户注册登录
- 权限管理
- 个人资料"

# 自动生成功能列表和需求文档
```

### 方式3：现有项目启用
```bash
cd existing-project
"enable ai-dev mode for this project"

# 分析现有代码，生成项目快照
```

## 🧠 核心功能

### 1. 智能项目检测
- **技术栈识别**：自动识别 React, Next.js, Hono, Drizzle 等
- **项目规模评估**：Simple → Medium → Complex
- **Git 状态检查**：确保项目可追踪

### 2. 创建 codebox/ 目录结构

```
codebox/                          # AI 配置目录
├── config.json                   # 项目配置
├── requirements.md               # 全局需求 (EARS)
├── design.md                     # 架构设计
├── CLAUDE.md                     # AI 行为规则
├── feature_list.json             # 功能列表
├── project-snapshot.json         # 深度扫描结果
├── progress.txt                  # 进度日志
│
├── knowledge/                    # 知识库
│   ├── patterns.json             # 成功模式
│   ├── errors.json               # 历史错误
│   └── learnings.md              # 经验总结
│
├── research/                     # 竞品调研结果
│
└── changes/                      # 变更管理
    ├── active/                   # 进行中
    ├── staged/                   # 待审批
    └── archived/                 # 已归档
```

### 3. 深度项目扫描

执行 `scripts/scan-project.sh deep`：
- 识别技术栈和框架
- 检测架构模式
- 扫描现有模块
- 生成 `project-snapshot.json`

## 📋 使用示例

### 示例1：新项目初始化
```
你: "init project 待办事项应用"

Project Initializer 执行：
✓ 创建 codebox/ 目录
✓ 执行深度扫描 (scan-project.sh deep)
✓ 生成 project-snapshot.json
✓ 创建 requirements.md, design.md, CLAUDE.md
✓ 初始化 knowledge/ 目录
✓ 创建 feature_list.json
✓ Git commit 初始化

完成！可以开始开发：
"ai 实现用户登录"
```

### 示例2：带详细需求
```
你: "init project 博客系统，功能包括：
- 用户认证（注册、登录）
- 文章管理（CRUD、草稿）
- 评论系统（发表、回复）"

Project Initializer 分析：
✓ 复杂度: MEDIUM
✓ 生成需求文档和功能列表
✓ 执行深度扫描
✓ 创建完整 codebox/ 结构

特性列表已生成！
```

### 示例3：现有项目启用
```
你: "enable ai-dev mode"

Project Initializer 检测：
✓ 发现 package.json
✓ 技术栈: Next.js + Drizzle
✓ 执行深度扫描
✓ 识别现有模块: auth, users, posts

创建 codebox/ 并生成项目快照
```

## 📁 生成的文件

详细的文件格式和配置说明，请查看：
- **[文件格式详解](references/file-formats.md)** - feature_list.json, progress.txt, config.json 详细说明
- **[配置最佳实践](references/config-best-practices.md)** - 如何调整项目配置

## 🆕 v2.0-Enhanced 初始化

### 新增文件结构 (全局约束 + 知识库)

v2.0版本创建完整的约束和知识管理系统：

```
项目根目录/
├── requirements.md            # 全局需求 (EARS格式)
├── design.md                  # 架构模式和技术决策
├── CLAUDE.md                  # 代码规范和AI行为规则
├── constraints.md             # 质量门禁和验证规则
│
├── knowledge/                 # 知识库 (AISD-R)
│   ├── patterns.json          # 成功模式库
│   ├── errors.json            # 历史错误库
│   └── learnings.md           # 经验教训
│
├── changes/                   # OpenSpec变更管理
│   ├── active/                # 进行中的功能
│   ├── staged/                # 待审批的功能
│   └── archived/              # 已归档的功能
│       └── YYYY-MM/           # 按月归档
│
├── workflows/                 # Netflix Conductor工作流
│   ├── templates/             # 工作流模板
│   │   ├── feature-development-v1.json
│   │   └── bug-fix-v1.json
│   └── executions/            # 执行历史
│
├── state/                     # 持久化状态
│   └── (由ai-dev管理)
│
└── codebox/           # 原有项目文件
    ├── feature_list.json      # 升级到v2.0-enhanced
    ├── progress.txt
    ├── init.sh
    └── config.json
```

### 初始化时创建的全局约束模板

#### 1. requirements.md (EARS格式)
```markdown
# Global Requirements

## REQ-GLOBAL-001: API Response Format
WHEN the system processes an API request
THE SYSTEM SHALL return responses in JSON format with structure:
{
  "success": boolean,
  "data": any,
  "error": { code: string, message: string }
}
SO THAT clients have a consistent interface

## REQ-GLOBAL-002: Error Handling
WHEN an error occurs in any layer
THE SYSTEM SHALL throw an AppError instance
SO THAT errors are handled consistently

[...更多需求...]
```

#### 2. design.md (架构模式)
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

[...更多模式...]
```

#### 3. CLAUDE.md (代码规范)
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

[...更多规则...]
```

#### 4. constraints.md (质量门禁)
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

[...更多约束...]
```

### 知识库初始化

#### patterns.json (空模板)
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

#### errors.json (空模板)
```json
{
  "$schema": "knowledge-errors-schema-v1",
  "errors": [
    {
      "id": "ERROR-001",
      "category": "async",
      "title": "未处理的Promise rejection",
      "occurrence_count": 0,
      "last_occurrence": null,
      "prevention": [
        "所有async函数必须用try-catch包装",
        "使用AppError统一错误处理"
      ]
    }
  ]
}
```

#### learnings.md (空模板)
```markdown
# Project Learnings

记录项目开发中的经验教训和最佳实践。

## 格式
每条记录包括：
- 日期
- 类别 (成功经验/避免错误/改进建议)
- 描述
- 相关模式/错误ID

---

(随着项目推进自动更新)
```

### Enhanced feature_list.json (v2.0-enhanced)

自动升级到新schema:
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
  "ooda_loops": [],
  "statistics": {
    "total_features": 0,
    "completed_features": 0,
    "completion_rate": 0,
    "average_confidence": 0,
    "total_ooda_iterations": 0
  },
  "metadata": {
    "created_at": "2024-01-15T10:00:00Z",
    "last_updated": "2024-01-15T10:00:00Z",
    "project_name": "待办事项应用",
    "workflow_version": "v2.0-enhanced"
  }
}
```

### 工作流模板

创建预定义工作流:
- `feature-development-v1.json` - 7阶段完整开发流程
- `bug-fix-v1.json` - 简化的bug修复流程
- `refactor-v1.json` - 重构流程

### 初始化命令增强

```bash
# 基础初始化 (v1.0)
"init project 待办事项应用"
  → 创建 codebox/ 和 feature_list.json

# 完整初始化 (v2.0-enhanced)
"init project 待办事项应用 --enhanced"
  → 创建所有全局约束、知识库、工作流模板
  → 使用 v2.0-enhanced schema
  → 设置 7-phase workflow

# 现有项目升级
"upgrade project to v2.0"
  → 迁移 feature_list.json (v1 → v2.0-enhanced)
  → 创建缺失的全局约束文件
  → 初始化知识库
```

### 初始化后的项目报告 (v2.0)

```markdown
✅ 项目初始化完成 (v2.0-enhanced)

## 创建的文件 (4 + 3 + 7 = 14个)

### 全局约束 (4个)
✅ requirements.md (15 global requirements)
✅ design.md (5 architecture patterns)
✅ CLAUDE.md (code style rules)
✅ constraints.md (quality gates)

### 知识库 (3个)
✅ knowledge/patterns.json (12 pattern templates)
✅ knowledge/errors.json (5 common error templates)
✅ knowledge/learnings.md (初始化)

### 项目文件 (7个)
✅ codebox/feature_list.json (v2.0-enhanced, 15 features)
✅ codebox/progress.txt
✅ codebox/init.sh
✅ codebox/config.json
✅ changes/ (active/staged/archived)
✅ workflows/templates/ (3 workflow templates)
✅ state/ (状态目录)

## 项目配置
- **名称**: 待办事项应用
- **复杂度**: SIMPLE
- **估计时长**: 3-5天
- **技术栈**: Next.js + Hono + Drizzle
- **工作流**: 7-phase v2.0-enhanced

## 特性概览
- **总计**: 15个特性
- **Core**: 8个 (注册、登录、任务CRUD等)
- **UI**: 4个 (响应式设计、主题等)
- **Test**: 3个 (单元测试、E2E测试)

## 下一步
1. 查看全局约束: `cat requirements.md`
2. 开始第一个功能: `ai "实现用户注册"`
3. 或查看所有功能: `/feature-list`

## 7-Phase Workflow 已启用
每个功能将经过:
- Phase 0: Knowledge Check (自动)
- Phase 1: Clarification (用户审批)
- Phase 2-3: Discovery & Design
- Phase 4: OODA Loop Implementation
- Phase 5: Confidence-filtered Quality Review
- Phase 6: Finalization & Knowledge Update

准备好开始了！
```

### 与ai-dev集成

初始化完成后，ai-dev自动：
1. **Phase 0检查**: 所有新功能先检查全局约束
2. **知识查询**: 参考patterns.json和errors.json
3. **状态持久化**: 使用state/目录
4. **变更管理**: 使用changes/目录结构

## 🔄 初始化流程

```
1. 检测环境
   ├─ 当前目录
   ├─ package.json（技术栈）
   ├─ Git 状态
   └─ 项目规模
   ↓
2. 创建目录结构 (v2.0增强)
   ├─ mkdir codebox/
   ├─ mkdir codebox/archive/
   ├─ mkdir knowledge/ (新增)
   ├─ mkdir changes/{active,staged,archived}/ (新增)
   ├─ mkdir workflows/templates/ (新增)
   ├─ mkdir state/ (新增)
   └─ 设置权限
   ↓
3. 创建全局约束 (新增)
   ├─ 生成 requirements.md
   ├─ 生成 design.md
   ├─ 生成 CLAUDE.md
   └─ 生成 constraints.md
   ↓
4. 初始化知识库 (新增)
   ├─ 创建 patterns.json (模板)
   ├─ 创建 errors.json (模板)
   └─ 创建 learnings.md (空)
   ↓
5. 生成特性列表 (v2.0 schema)
   ├─ 分析需求描述
   ├─ 分解为可测试特性
   ├─ 建立依赖关系
   └─ 按优先级排序
   ↓
4. 创建配置文件
   ├─ feature_list.json
   ├─ progress.txt
   ├─ config.json
   └─ init.sh
   ↓
5. Git 初始化
   ├─ git add codebox/
   └─ git commit -m "chore: initialize long-running mode"
```

## 💡 使用技巧

### ✅ 推荐做法
1. **项目开始时就初始化**：越早越好
2. **提供详细需求**：描述越详细，特性列表越准确
3. **验证生成的特性**：初始化后检查 feature_list.json
4. **保持 Git 同步**：定期提交 codebox/

### ❌ 常见错误
1. 需求描述太模糊："做个应用" ❌
2. 开发到一半才初始化 ❌
3. 不检查生成的特性列表 ❌

## 🔗 与其他系统协作

- **ai-dev**：初始化后自动切换到长运行模式
- **session-manager**：创建的文件供 session 恢复使用
- **Commands**：可以用 `/progress` 查看初始化后的状态

## 📚 详细参考

想了解更多？查看：
- **[初始化最佳实践](references/initialization-guide.md)** - 详细步骤和案例
- **[特性列表设计](references/feature-list-design.md)** - 如何设计好的特性
- **[技术栈配置](references/tech-stack-configs.md)** - 各技术栈的配置模板

## ❓ 故障排除

**初始化失败？**
- 确保在项目根目录
- 检查 Git 仓库状态
- 确认有写入权限

**特性列表不准确？**
- 提供更详细的需求描述
- 手动编辑 feature_list.json
- 可以追加新特性："添加新功能：XX"

**init.sh 不工作？**
- 检查是否可执行：`chmod +x codebox/init.sh`
- 查看技术栈是否正确识别
- 手动编辑 init.sh 适配项目

---

**核心理念**: 一次设置，终身受益。让 AI 理解你的项目，实现真正的跨 session 协作。
