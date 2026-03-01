---
name: project-initializer
description: |
  This skill should be used when the user wants to initialize AI development mode for projects.
  It creates the codebox/ directory, initializes knowledge base, and performs deep project
  structure scanning. Use when the user mentions "init project", "setup ai-dev", "initialize",
  "启用 AI 模式", "初始化项目", or wants to start a new AI-assisted development workflow.
version: 6.0.8
status: ga
profile: dev
triggers:
  - init project
  - initialize
  - setup ai-dev
  - enable ai-dev
  - 初始化项目
  - 启用 AI 模式
  - 项目初始化
---

# Project Initializer - 项目初始化系统

## 🎯 一句话说明

**为项目启用 AI 开发模式，创建 codebox/ 配置目录并执行深度扫描。**

## ⚡ 快速使用

```bash
"init project 待办事项应用"       # 最简单
"setup ai-dev"                   # 启用模式
"initialize 博客系统"             # 中文触发
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
├── knowledge/                    # 知识库
│   ├── patterns.json             # 成功模式
│   ├── errors.json               # 历史错误
│   └── learnings.md              # 经验总结
└── changes/                      # 变更管理
    ├── active/                   # 进行中
    ├── staged/                   # 待审批
    └── archived/                 # 已归档
```

### 3. 深度项目扫描

执行 `scripts/migrate-schema.sh deep`：
- 识别技术栈和框架
- 检测架构模式
- 扫描现有模块

## 📋 初始化流程

```
1. 检测环境 (目录、技术栈、Git)
2. 创建目录结构 (codebox/, knowledge/, changes/)
3. 创建全局约束 (requirements.md, design.md, CLAUDE.md)
4. 初始化知识库 (patterns.json, errors.json)
5. 生成特性列表 (feature_list.json)
6. Git 初始化 (commit codebox/)
```

## Common Pitfalls

### Pitfall 1: 需求描述过于模糊

**症状**: "初始化一个应用" 没有任何具体说明
**后果**: 生成的 feature_list.json 和 requirements.md 缺乏针对性，后续返工
**修正**: 提供具体需求（技术栈、核心功能、目标用户），至少一句话描述目标

### Pitfall 2: 跳过生成文件的审查

**症状**: 初始化完成后直接进入开发
**后果**: feature_list.json 中有不合理的特性拆分，设计方向偏差
**修正**: 初始化后检查 requirements.md 和 feature_list.json，确认后再继续

### Pitfall 3: 在已有 codebox/ 的项目上重复初始化

**症状**: 项目已有 codebox/ 目录，再次运行初始化
**后果**: 覆盖已有配置和知识库，丢失积累的模式和错误记录
**修正**: 检测到现有 codebox/ 时提示用户确认，默认跳过已存在的文件

## 💡 使用技巧

### ✅ 推荐
- 项目开始时就初始化
- 提供详细需求描述
- 验证生成的特性列表

### ❌ 避免
- 需求描述太模糊
- 开发到一半才初始化
- 不检查生成的特性列表

## 🔗 与其他系统协作

| Agent | Role |
|-------|------|
| `session-manager` | Use initialized files for session recovery |
| `ai-dev` | Consume codebox/ config for development workflow |

## 📚 详细参考

- **[templates.md](references/templates.md)** - 初始化文件模板

## ❓ 故障排除

**初始化失败？**
- 确保在项目根目录
- 检查 Git 仓库状态
- 确认有写入权限

## Version History

| Version | Changes |
|---------|---------|
| 5.2.4 | Split detailed docs to references/ |
| 4.2.0 | Add v2.0-enhanced with knowledge base |
| 4.0.0 | Initial release |

---

**核心理念**: 一次设置，终身受益。让 AI 理解你的项目。