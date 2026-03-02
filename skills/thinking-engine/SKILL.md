---
name: thinking-engine
description: |
  This skill should be used when the user asks to think deeply, analyze a task systematically,
  or needs structured reasoning before implementation. Provides 5-6 step analysis frameworks
  for task planning, problem solving, and architecture design decisions.
  Integrates with ai-dev workflow for complex task analysis and agent selection.

  <example>
  Context: User has a complex feature and wants thorough analysis before coding
  user: "我要给系统加一个分布式缓存层，先好好思考一下技术选型和架构设计"
  assistant: "I'll use thinking-engine in architecture design mode with 6-step analysis: requirements analysis, system decomposition, technology selection, interface design, performance/scaling, and security/reliability."
  <commentary>
  User explicitly asks to "think deeply" about architecture, triggering the 6-step architecture design mode.
  </commentary>
  </example>

  <example>
  Context: User encounters a complex bug and needs systematic root cause analysis
  user: "think step by step about why the WebSocket connections keep dropping after exactly 30 seconds in production but not locally"
  assistant: "I'll use thinking-engine in problem solving mode: define the problem symptoms, generate root cause hypotheses, design verification methods, plan implementation fixes, and validate the solution."
  <commentary>
  User requests step-by-step analysis of a complex bug, triggering the 5-step problem solving mode.
  </commentary>
  </example>

  <example>
  Context: User wants to evaluate task complexity before starting implementation
  user: "ultrathink 一下这个需求：实现完整的 OAuth2 + RBAC 权限系统，评估下复杂度和最优实现路径"
  assistant: "I'll use thinking-engine in task analysis mode: understand requirements, analyze project context, evaluate complexity (likely COMPLEX 8+/10), select agent strategy, and validate the approach with alternatives."
  <commentary>
  User uses "ultrathink" trigger with a complex feature, activating deep task analysis with complexity scoring.
  </commentary>
  </example>
version: 6.0.23
status: ga
profile: design
triggers:
  - think deeply
  - analyze task
  - think step by step
  - think
  - ultrathink
  - 好好思考
  - 仔细想
  - 深度分析
  - 思考
  - 考虑
---

# Thinking Engine

> Structured deep thinking engine for systematic AI analysis

## 触发词

此技能触发于: "think deeply", "analyze task", "好好思考", "深度分析", "ultrathink".

## Overview

Thinking Engine provides structured multi-step analysis for:

- **Task Analysis**: 5-step workflow for new feature development
- **Problem Solving**: 5-step workflow for bug fixing and issue resolution
- **Architecture Design**: 6-step workflow for system design decisions

Automatically activates in ai-dev `think` and `ultrathink` modes.

---

## Thinking Modes

### 1. Task Analysis Mode

**Use when**: Developing new features, implementing requirements

**5-Step Process**:

```
Step 1: Understand Task
├── Task type: [develop/fix/optimize/refactor]
├── Key verbs: [implement/fix/add/delete/update]
└── Domain: [frontend/backend/database/security/...]

Step 2: Analyze Context
├── Project tech stack
├── Existing code structure
└── Related dependencies

Step 3: Evaluate Complexity
├── Complexity level: [SIMPLE/MEDIUM/COMPLEX]
├── Risk factors
└── Dependencies

Step 4: Select Strategy
├── Recommended agent combination
├── Workflow steps
└── Time estimate

Step 5: Validate Approach
├── Feasibility check
├── Potential issues
└── Alternative solutions
```

### 2. Problem Solving Mode

**Use when**: Fixing bugs, troubleshooting issues

**5-Step Process**:

```
Step 1: Define Problem
├── Symptoms description
├── Impact scope
└── Reproduction steps

Step 2: Root Cause Analysis
├── Hypothesis list
├── Verification methods
└── Data collection

Step 3: Design Solution
├── Solution options
├── Pros/cons analysis
└── Recommended approach

Step 4: Implementation Plan
├── Files to modify
├── Testing strategy
└── Rollback plan

Step 5: Verification
├── Test results
├── Edge cases
└── Monitoring metrics
```

### 3. Architecture Design Mode

**Use when**: System design, technology selection, major refactoring

**6-Step Process**:

```
Step 1: Requirements Analysis
├── Functional requirements
├── Non-functional requirements (performance/security/availability)
└── Constraints

Step 2: System Decomposition
├── Module partitioning
├── Boundary definitions
└── Responsibility assignment

Step 3: Technology Selection
├── Candidate technologies
├── Evaluation criteria
└── Final selection

Step 4: Interface Design
├── API specifications
├── Data flow
└── Message protocols

Step 5: Performance & Scaling
├── Bottleneck analysis
├── Scaling strategy
└── Capacity planning

Step 6: Security & Reliability
├── Threat modeling
├── Protection measures
└── Failure recovery
```

---

## Complexity Evaluation

### Keyword Weights

| Complexity | Keywords | Weight |
|------------|----------|--------|
| High | system, architecture, complete, all, auth, security, distributed | +3 |
| Medium | includes, supports, database, storage, cache, API, integration | +2 |
| Simple | fix, simple, quick, temporary, small, single | -2 |

### Complexity Levels

| Score | Level | Recommended Mode |
|-------|-------|------------------|
| 1-3 | SIMPLE | quick |
| 4-6 | MEDIUM | standard |
| 7+ | COMPLEX | think |

---

## Agent Capability Matrix

| Agent | Expertise | Complexity | Thinking Depth |
|-------|-----------|------------|----------------|
| requirement-analyzer | Requirements, design | MEDIUM, COMPLEX | deep |
| api-helper | API design, specs | ALL | medium |
| frontend-developer | UI/UX, frameworks | SIMPLE, MEDIUM | medium |
| backend-architect | System, database | COMPLEX | deep |
| code-reviewer | Quality, security | ALL | deep |
| quick-fixer | Fast fixes | SIMPLE | shallow |
| debugger | Diagnosis, root cause | MEDIUM, COMPLEX | deep |
| test-automator | Test design, automation | MEDIUM, COMPLEX | medium |

---

## Integration with ai-dev

Thinking Engine activates automatically in:

1. **think mode**: `ai think <task>`
2. **ultrathink mode**: `ai ultrathink <task>` or `ai 好好思考 <task>`
3. **Complex task detection**: When complexity score >= 7

Output integrates directly into conversation flow.

---

## Usage Examples

```bash
# Automatic mode selection
ai implement user authentication   # → task-analysis (COMPLEX)
dev fix login button bug           # → problem-solving (SIMPLE)
ai think design payment system     # → architecture (COMPLEX)
```

## Common Pitfalls

### Pitfall 1: 所有任务都用 ultrathink 模式

**症状**: 修复一个 typo 也启动 6 步架构分析
**后果**: 简单任务被过度分析，浪费时间和上下文窗口
**修正**: 让复杂度评分决定模式：SIMPLE(1-3) 用 quick，MEDIUM(4-6) 用 standard，COMPLEX(7+) 用 think

### Pitfall 2: 分析完毕不输出行动建议

**症状**: 详细列出了 5 步分析结果，但没有 "下一步做什么"
**后果**: 用户看完分析后仍不知道如何行动
**修正**: 每次分析必须以 actionable 的推荐结束：推荐 agent、执行步骤、预期产出

### Pitfall 3: 忽略上下文直接匹配关键词

**症状**: 用户说 "想想午餐吃什么" 触发了深度任务分析
**后果**: 非开发任务被错误分析，用户体验差
**修正**: 结合对话上下文判断意图，仅在开发相关场景激活分析模式

## Agent Collaboration

| Agent | Role |
|-------|------|
| `ai-dev` | Triggers thinking-engine for complex tasks |
| `@oracle` | Strategic reasoning consultation |
| `requirement-analyzer` | Receives task analysis output |
| `backend-architect` | Uses architecture analysis |

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 4.2.6 | 2026-01-13 | Add triggers, agent collaboration |
| 4.0.0 | 2026-01-07 | Initial release with 3 thinking modes |

## References

See `references/analysis-frameworks.md` for detailed frameworks.

### Example Output

```
[Thinking Engine] Task Analysis Mode

📝 Step 1: Understand Task
   Type: Development
   Verb: implement
   Domain: Security/Auth

📊 Step 2: Analyze Context
   Stack: Next.js, TypeScript, Prisma
   Files: src/auth/, src/middleware/
   Deps: next-auth, bcrypt

⚖️ Step 3: Evaluate Complexity
   Level: COMPLEX (7/10)
   Risks: Security vulnerabilities, session management
   Dependencies: Database schema, API routes

🎯 Step 4: Select Strategy
   Agents: requirement-analyzer → api-helper → code-reviewer → test-automator
   Steps: 8 tasks
   Time: 30-45 minutes

✅ Step 5: Validate Approach
   Feasibility: High
   Issues: Need to confirm session storage
   Alternative: Use OAuth instead of custom auth
```
