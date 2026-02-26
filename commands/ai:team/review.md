---
name: ai:team:review
description: 团队代码审查模式 - 多角度并行审查代码质量、安全性和性能
argument-hint: "<file-path-or-description> [--focus security|performance|quality|all]"
allowed-tools: TeamCreate, TeamDelete, TaskCreate, TaskUpdate, TaskList, TaskGet, SendMessage, Task, Read, Grep, Glob
internal: true
---

# AI Team: Code Review Mode

**多角度并行代码审查**

**Usage:**
- `/ai:team review <path>` - 审查指定路径的代码
- `/ai:team review --focus security` - 专注于安全审查
- `/ai:team review --focus performance` - 专注于性能审查
- `/ai:team review --focus quality` - 专注于代码质量

---

## 审查团队配置

### 团队成员

```typescript
const REVIEW_TEAMMATES = {
  security: {
    role: "security-reviewer",
    type: "ai-dev:code-reviewer",
    focus: [
      "XSS 跨站脚本攻击",
      "SQL 注入",
      "CSRF 跨站请求伪造",
      "认证授权漏洞",
      "敏感数据泄露",
      "输入验证不足"
    ],
    checklist: [
      "用户输入是否正确转义",
      "API 是否有权限检查",
      "敏感数据是否加密",
      "是否使用安全的密码学方法"
    ]
  },

  performance: {
    role: "performance-reviewer",
    type: "ai-dev:code-reviewer",
    focus: [
      "N+1 查询问题",
      "内存泄漏风险",
      "无限循环风险",
      "大数组/对象操作",
      "不必要的重新渲染",
      "缺少缓存策略"
    ],
    checklist: [
      "数据库查询是否优化",
      "是否有防抖/节流",
      "大数据是否分页",
      "资源是否正确释放"
    ]
  },

  quality: {
    role: "quality-reviewer",
    type: "ai-dev:quality-guardian",
    focus: [
      "代码风格一致性",
      "命名规范",
      "函数复杂度",
      "重复代码",
      "缺少测试覆盖",
      "文档完整性"
    ],
    checklist: [
      "函数是否单一职责",
      "是否有足够的注释",
      "测试覆盖率是否达标",
      "是否有代码坏味道"
    ]
  }
}
```

---

## 执行流程

### Step 1: 确定审查范围

```bash
# 解析参数
TARGET_PATH="${ARGUMENTS%% --*}"
FOCUS="${ARGUMENTS#*--focus }"  # 默认 "all"
```

**查找目标文件:**
```bash
# 如果是目录
find $TARGET_PATH -type f \( -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" \)

# 如果是文件，直接使用
```

### Step 2: 创建审查团队

```typescript
TeamCreate({
  team_name: `review-${Date.now()}`,
  description: `代码审查: ${TARGET_PATH}`,
  agent_type: "team-orchestrator"
})
```

### Step 3: 生成审查队友

**根据 --focus 参数选择性生成:**

```typescript
// 安全审查员
Task({
  subagent_type: "ai-dev:code-reviewer",
  team_name: currentTeam,
  name: "security-reviewer",
  prompt: `
    你是安全审查专家，负责审查: ${TARGET_PATH}

    ## 关注点
    - XSS 跨站脚本攻击
    - SQL 注入
    - 认证授权漏洞
    - 敏感数据处理

    ## 输出格式
    - 问题级别: CRITICAL / HIGH / MEDIUM / LOW
    - 文件位置: file:line
    - 问题描述
    - 修复建议
  `
})

// 性能审查员
Task({
  subagent_type: "ai-dev:code-reviewer",
  team_name: currentTeam,
  name: "performance-reviewer",
  prompt: `
    你是性能审查专家，负责审查: ${TARGET_PATH}

    ## 关注点
    - 数据库查询优化
    - 内存使用
    - 算法复杂度
    - 渲染性能

    ## 输出格式
    - 问题级别: CRITICAL / HIGH / MEDIUM / LOW
    - 文件位置: file:line
    - 性能影响
    - 优化建议
  `
})

// 质量审查员
Task({
  subagent_type: "ai-dev:quality-guardian",
  team_name: currentTeam,
  name: "quality-reviewer",
  prompt: `
    你是代码质量审查专家，负责审查: ${TARGET_PATH}

    ## 关注点
    - 代码风格
    - 可维护性
    - 测试覆盖
    - 文档完整性

    ## 输出格式
    - 问题级别: INFO / WARNING / ERROR
    - 文件位置: file:line
    - 问题描述
    - 改进建议
  `
})
```

### Step 4: 创建审查任务

```typescript
TaskCreate({
  subject: "安全审查",
  description: "检查安全漏洞和风险",
  activeForm: "执行安全审查中",
  owner: "security-reviewer"
})

TaskCreate({
  subject: "性能审查",
  description: "检查性能瓶颈和优化机会",
  activeForm: "执行性能审查中",
  owner: "performance-reviewer"
})

TaskCreate({
  subject: "质量审查",
  description: "检查代码质量和可维护性",
  activeForm: "执行质量审查中",
  owner: "quality-reviewer"
})
```

### Step 5: 等待结果并汇总

```typescript
// 定期检查进度
const status = TaskList()

// 所有任务完成后
const report = {
  security: [],   // 安全问题列表
  performance: [], // 性能问题列表
  quality: [],    // 质量问题列表
  summary: {
    critical: 0,
    high: 0,
    medium: 0,
    low: 0
  }
}
```

---

## 审查报告格式

```markdown
# 代码审查报告

## 📊 概览
- 审查范围: ${TARGET_PATH}
- 审查时间: ${timestamp}
- 发现问题: ${totalIssues} 个

## 🔴 严重问题 (CRITICAL)
[安全审查员发现的问题]

## 🟠 重要问题 (HIGH)
[性能审查员发现的问题]

## 🟡 中等问题 (MEDIUM)
[质量审查员发现的问题]

## 🟢 建议改进 (LOW/INFO)
[其他改进建议]

## 📋 下一步行动
- [ ] 修复 CRITICAL 问题
- [ ] 评估 HIGH 问题影响
- [ ] 计划 MEDIUM 问题修复
```

---

## 使用示例

```bash
# 全面审查
/ai:team review src/auth

# 专注安全
/ai:team review src/api --focus security

# 专注性能
/ai:team review src/components --focus performance

# 审查单个文件
/ai:team review src/utils/auth.ts
```