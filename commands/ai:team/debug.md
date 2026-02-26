---
name: ai:team:debug
description: 团队问题调查模式 - 竞争假设并行调查，快速定位问题根因
argument-hint: "<problem-description> [--logs <log-file>] [--scope <path>]"
allowed-tools: TeamCreate, TeamDelete, TaskCreate, TaskUpdate, TaskList, TaskGet, SendMessage, Task, Read, Grep, Glob, Bash
internal: true
---

# AI Team: Debug Mode

**竞争假设并行调查问题**

**Usage:**
- `/ai:team debug <problem>` - 调查问题描述
- `/ai:team debug --logs error.log` - 基于日志文件调查
- `/ai:team debug --scope src/auth` - 限定调查范围

---

## 调查团队配置

### 团队成员

```typescript
const DEBUG_TEAMMATES = {
  logAnalyst: {
    role: "log-analyst",
    type: "ai-dev:debugger",
    focus: [
      "错误日志解析",
      "堆栈跟踪分析",
      "异常模式识别",
      "时间线重建"
    ],
    outputs: [
      "错误时间线",
      "异常模式报告",
      "初步假设列表"
    ]
  },

  codeTracer: {
    role: "code-tracer",
    type: "ai-dev:error-detective",
    focus: [
      "代码路径追踪",
      "数据流分析",
      "状态变化追踪",
      "边界条件检查"
    ],
    outputs: [
      "执行路径图",
      "数据流图",
      "可疑代码点"
    ]
  },

  hypothesisTester: {
    role: "hypothesis-tester",
    type: "ai-dev:debugger",
    focus: [
      "假设验证",
      "问题复现",
      "修复验证",
      "回归测试"
    ],
    outputs: [
      "验证结果",
      "复现步骤",
      "修复方案"
    ]
  }
}
```

---

## 调查方法论: 竞争假设

```
┌─────────────────────────────────────────────────────────────┐
│                    竞争假设调查流程                           │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  问题报告                                                    │
│      │                                                       │
│      ▼                                                       │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ Phase 1: 并行调查 (log-analyst + code-tracer)          │ │
│  │                                                         │ │
│  │  log-analyst          code-tracer                       │ │
│  │      │                    │                             │ │
│  │      ▼                    ▼                             │ │
│  │  分析日志            追踪代码路径                        │ │
│  │      │                    │                             │ │
│  │      ▼                    ▼                             │ │
│  │  生成假设 A         生成假设 B                           │ │
│  └──────┬────────────────────┬─────────────────────────────┘ │
│         │                    │                               │
│         └────────┬───────────┘                               │
│                  ▼                                            │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ Phase 2: 假设汇总与评估                                  │ │
│  │                                                         │ │
│  │  假设 A: 认证 token 过期处理不当                         │ │
│  │  假设 B: 数据库连接池耗尽                                │ │
│  │  假设 C: 并发竞态条件                                    │ │
│  │                                                         │ │
│  │  评估: A (概率 70%) > B (概率 20%) > C (概率 10%)        │ │
│  └─────────────────────────────────┬───────────────────────┘ │
│                                    │                         │
│                                    ▼                         │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ Phase 3: 假设验证 (hypothesis-tester)                   │ │
│  │                                                         │ │
│  │  按优先级依次验证假设...                                 │ │
│  │                                                         │ │
│  │  假设 A 验证: ✓ 确认 - 添加测试复现问题                  │ │
│  └─────────────────────────────────┬───────────────────────┘ │
│                                    │                         │
│                                    ▼                         │
│                              问题解决                         │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## 执行流程

### Step 1: 收集初始信息

```bash
# 解析参数
PROBLEM="${ARGUMENTS%% --*}"
LOG_FILE="${ARGUMENTS#*--logs }"
SCOPE="${ARGUMENTS#*--scope }"

# 如果提供了日志文件
if [ -n "$LOG_FILE" ]; then
  # 读取最近的错误日志
  tail -n 100 "$LOG_FILE"
fi
```

### Step 2: 创建调查团队

```typescript
TeamCreate({
  team_name: `debug-${Date.now()}`,
  description: `问题调查: ${PROBLEM}`,
  agent_type: "team-orchestrator"
})
```

### Step 3: 生成调查队友

```typescript
// 日志分析师
Task({
  subagent_type: "ai-dev:debugger",
  team_name: currentTeam,
  name: "log-analyst",
  prompt: `
    你是日志分析专家，负责调查问题: ${PROBLEM}

    ## 任务
    1. 分析错误日志模式
    2. 重建错误时间线
    3. 识别异常模式
    4. 生成初步假设

    ## 输出
    - 错误分析报告
    - 假设列表 (按概率排序)

    ## 方法
    使用 5-Why 方法深挖根因
  `
})

// 代码追踪师
Task({
  subagent_type: "ai-dev:error-detective",
  team_name: currentTeam,
  name: "code-tracer",
  prompt: `
    你是代码追踪专家，负责调查问题: ${PROBLEM}

    ## 调查范围
    ${SCOPE:-"整个项目"}

    ## 任务
    1. 追踪相关代码路径
    2. 分析数据流
    3. 检查边界条件
    4. 生成代码层面的假设

    ## 输出
    - 执行路径分析
    - 可疑代码点
    - 代码假设列表
  `
})

// 假设验证师
Task({
  subagent_type: "ai-dev:debugger",
  team_name: currentTeam,
  name: "hypothesis-tester",
  prompt: `
    你是假设验证专家，负责验证调查产生的假设。

    ## 任务
    等待 log-analyst 和 code-tracer 完成初步调查后:
    1. 收集所有假设
    2. 按概率排序
    3. 设计验证方案
    4. 执行验证

    ## 输出
    - 验证结果
    - 复现步骤 (如果成功复现)
    - 修复建议
  `
})
```

### Step 4: 创建调查任务

```typescript
TaskCreate({
  subject: "日志分析",
  description: "分析错误日志，识别模式",
  activeForm: "分析日志中",
  owner: "log-analyst"
})

TaskCreate({
  subject: "代码追踪",
  description: "追踪代码路径，识别问题点",
  activeForm: "追踪代码中",
  owner: "code-tracer"
})

TaskCreate({
  subject: "假设验证",
  description: "验证调查假设",
  activeForm: "验证假设中",
  owner: "hypothesis-tester",
  addBlockedBy: ["1", "2"]  // 等待日志分析和代码追踪完成
})
```

### Step 5: 协调调查过程

```typescript
// 监控调查进度
const status = TaskList()

// 当日志分析和代码追踪完成时
// 发送消息给假设验证师
SendMessage({
  type: "message",
  recipient: "hypothesis-tester",
  content: `
    ## 调查结果汇总

    ### 日志分析发现
    - 发现 3 个错误模式
    - 时间线: 14:30:00 - 14:45:00
    - 假设: Token 过期处理不当

    ### 代码追踪发现
    - 可疑路径: auth.ts:45-67
    - 边界条件问题: token === null 未处理
    - 假设: 空值检查缺失

    ### 待验证假设
    1. Token 过期处理不当 (概率 70%)
    2. 空值检查缺失 (概率 30%)

    请开始验证这些假设。
  `,
  summary: "调查结果汇总"
})
```

---

## 调查报告格式

```markdown
# 问题调查报告

## 📋 问题摘要
- 描述: ${PROBLEM}
- 调查时间: ${timestamp}
- 根因: ${rootCause}

## 🔍 调查过程

### Phase 1: 日志分析
- 发现的错误模式
- 时间线重建

### Phase 2: 代码追踪
- 相关代码路径
- 可疑代码点

### Phase 3: 假设验证
- 验证结果
- 复现步骤

## 🎯 根因分析
[使用 5-Why 方法分析]

## 🛠️ 修复建议
1. 立即修复: ...
2. 后续改进: ...
3. 预防措施: ...

## 📝 复现步骤
1. ...
2. ...
3. ...
```

---

## 使用示例

```bash
# 调查登录失败
/ai:team debug 用户登录时报 401 错误

# 基于日志调查
/ai:team debug --logs /var/log/app/error.log

# 限定调查范围
/ai:team debug 支付失败 --scope src/payment
```