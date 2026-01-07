---
name: thinking-engine
description: |
  Sequential Thinking 深度思考引擎，提供结构化的任务分析和决策支持。
  
  **触发词**: think, 思考, 深度分析, 仔细想, ultrathink, 好好思考
  
  **思考模式**:
  - task-analysis: 5 步任务分析 (默认)
  - problem-solving: 5 步问题解决
  - architecture: 6 步架构设计
  
  **输出方式**: 直接输出到会话（不保存日志文件）
  
  **与 ai-dev 集成**: think/ultrathink 模式自动激活

version: 1.0.0
---

# Thinking Engine

> 结构化深度思考引擎 - 让 AI 思考更系统化

## 思考模式

### 1. Task Analysis (任务分析)

**适用场景**: 开发新功能、实现需求

**5 步思考流程**:

```
┌─────────────────────────────────────────────────────────────┐
│                   TASK ANALYSIS MODE                        │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  Step 1: 理解任务                                           │
│  ├─ 任务类型: [开发/修复/优化/重构]                          │
│  ├─ 关键动词: [实现/修复/添加/删除/更新]                      │
│  └─ 领域识别: [前端/后端/数据库/安全/...]                    │
│                                                             │
│  Step 2: 分析上下文                                         │
│  ├─ 项目技术栈                                              │
│  ├─ 现有代码结构                                            │
│  └─ 相关依赖                                                │
│                                                             │
│  Step 3: 评估复杂度                                         │
│  ├─ 复杂度等级: [SIMPLE/MEDIUM/COMPLEX]                     │
│  ├─ 风险因素                                                │
│  └─ 依赖关系                                                │
│                                                             │
│  Step 4: 选择策略                                           │
│  ├─ 推荐 Agent 组合                                         │
│  ├─ 工作流步骤                                              │
│  └─ 预估时间                                                │
│                                                             │
│  Step 5: 验证方案                                           │
│  ├─ 可行性检查                                              │
│  ├─ 潜在问题                                                │
│  └─ 备选方案                                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2. Problem Solving (问题解决)

**适用场景**: 修复 Bug、排查问题

**5 步思考流程**:

```
Step 1: 问题定义
├─ 症状描述
├─ 影响范围
└─ 复现条件

Step 2: 根因分析
├─ 假设列表
├─ 验证方法
└─ 数据收集

Step 3: 方案设计
├─ 解决选项
├─ 利弊分析
└─ 推荐方案

Step 4: 实施计划
├─ 修改文件
├─ 测试策略
└─ 回滚方案

Step 5: 验证确认
├─ 测试结果
├─ 边界情况
└─ 监控指标
```

### 3. Architecture Design (架构设计)

**适用场景**: 系统设计、技术选型、重大重构

**6 步思考流程**:

```
Step 1: 需求分析
├─ 功能需求
├─ 非功能需求 (性能/安全/可用性)
└─ 约束条件

Step 2: 系统分解
├─ 模块划分
├─ 边界定义
└─ 职责分配

Step 3: 技术选型
├─ 候选技术
├─ 评估标准
└─ 最终选择

Step 4: 接口设计
├─ API 规范
├─ 数据流
└─ 消息协议

Step 5: 性能与扩展
├─ 瓶颈分析
├─ 扩展策略
└─ 容量规划

Step 6: 安全与可靠
├─ 威胁建模
├─ 防护措施
└─ 故障恢复
```

---

## 复杂度评估规则

### 关键词权重

```yaml
high_complexity:  # +3 分/词
  - 系统, 架构, 完整, 全部, 所有
  - 认证, 权限, 安全, 加密
  - 分布式, 微服务, 集群

medium_complexity:  # +2 分/词
  - 包括, 支持, 以及, 同时
  - 数据库, 存储, 缓存
  - API, 接口, 集成

simple_indicators:  # -2 分/词
  - 修复, 简单, 快速, 临时
  - 小, 单个, 一个
```

### 复杂度等级

| 评分 | 等级 | 建议模式 |
|------|------|----------|
| 1-3 | SIMPLE | quick |
| 4-6 | MEDIUM | standard |
| 7+ | COMPLEX | think |

---

## Agent 能力矩阵

| Agent | 专长领域 | 复杂度偏好 | 思考深度 |
|-------|---------|-----------|---------|
| feature-planner | 需求分析, 功能设计 | MEDIUM, COMPLEX | deep |
| api-helper | API 设计, 接口规范 | ALL | medium |
| frontend-developer | UI/UX, 前端框架 | SIMPLE, MEDIUM | medium |
| backend-architect | 系统架构, 数据库 | COMPLEX | deep |
| code-reviewer | 代码质量, 安全审查 | ALL | deep |
| quick-fixer | 快速修复, 问题定位 | SIMPLE | shallow |
| debugger | 问题诊断, 根因分析 | MEDIUM, COMPLEX | deep |
| test-automator | 测试设计, 自动化 | MEDIUM, COMPLEX | medium |

---

## 使用示例

### 自动模式选择

```bash
ai implement user authentication   # → task-analysis (COMPLEX)
dev fix login button bug           # → problem-solving (SIMPLE)
ai think design payment system     # → architecture (COMPLEX)
```

### 思考输出示例

```
[Thinking Engine] Task Analysis Mode

📝 Step 1: 理解任务
   任务类型: 开发创建
   关键动词: 实现 (implement)
   领域识别: 安全认证

📊 Step 2: 分析上下文
   技术栈: Next.js, TypeScript, Prisma
   相关文件: src/auth/, src/middleware/
   依赖: next-auth, bcrypt

⚖️ Step 3: 评估复杂度
   复杂度: COMPLEX (7/10)
   风险: 安全漏洞, 会话管理
   依赖: 数据库 schema, API routes

🎯 Step 4: 选择策略
   Agent 组合: feature-planner → api-helper → code-reviewer → test-automator
   预估步骤: 8 个任务
   预估时间: 30-45 分钟

✅ Step 5: 验证方案
   可行性: 高
   潜在问题: 需要确认 session 存储方案
   备选: 使用 OAuth 代替自建认证
```

---

## 与 ai-dev 集成

Thinking Engine 在以下场景自动激活：

1. **think 模式**: `ai think <task>`
2. **ultrathink 模式**: `ai ultrathink <task>` 或 `ai 好好思考 <task>`
3. **复杂任务检测**: 当任务复杂度 >= 7 时自动建议

输出直接嵌入会话流，无需查看单独日志。
