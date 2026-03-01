# Markdown 增强语法规范

讨论参与者在 `discussion.md` 中使用的格式约定。

## 发言格式

每条发言使用以下结构：

```markdown
## [Round N] @角色名 — 工具名
> 时间: YYYY-MM-DD HH:mm

### 分析
（正文内容）

### 建议
（方案提议）

### 关注点
（风险或待确认事项）

### 决策倾向
- [x] 方案 A #consensus
- [ ] 方案 B #pending

---
```

## @ 提及系统

| 语法 | 含义 | 示例 |
|------|------|------|
| `@角色名` | 提及特定角色，请求关注或回应 | `@Security 请评估此方案的安全性` |
| `@all` | 提及全体参与者 | `@all 请对方案 A/B 投票` |
| `@角色名 Round N` | 引用特定角色在特定轮次的发言 | `回应 @PM Round 2 的关切...` |

**规则：** 每个 agent 发言前扫描是否有指向自己的 `@` 提及，优先回应被提及的议题。

## 引用系统

| 语法 | 用途 | 示例 |
|------|------|------|
| `> [!quote] @角色 Round N` | 引用其他 agent 的发言段落 | 引用并回应特定观点 |
| `[[context.md#章节]]` | Wikilink 引用项目文件/章节 | 引用项目背景中的特定部分 |
| `[[refs/file.md]]` | 引用附件目录中的参考资料 | 引用技术对比文档 |
| `` `src/auth/login.ts:45-60` `` | 引用代码文件的特定行 | 指出需要修改的代码位置 |

## Callout 类型

使用 Obsidian 风格 callout 语法：

| Callout | 用途 | 场景 |
|---------|------|------|
| `> [!analysis]` | 分析洞察 | 阐述对问题的理解 |
| `> [!proposal]` | 方案提案 | 提出具体解决方案（含优劣势） |
| `> [!question]` | 提问 | 向其他角色提问 |
| `> [!warning]` | 风险提示 | 标记潜在风险或关注点 |
| `> [!decision]` | 决策记录 | 达成共识后记录决策 |
| `> [!quote]` | 引用 | 引用其他 agent 或外部资料 |
| `> [!todo]` | 待办项 | 标记需要后续跟进的事项 |
| `> [!assumption]` | 隐含假设 | 标注讨论中的隐含假设，需后续验证 |

**用法示例：**

```markdown
> [!proposal] 方案 A: JWT + Redis Session
> - 优势: 无状态、可扩展
> - 劣势: Token 管理复杂度
> - 参考: [[refs/auth-comparison.md]]
```

```markdown
> [!assumption] 假设：并发用户数不超过 10,000
> 此假设影响数据库选型和缓存策略。
> 需要 @PM 确认实际用户量预估。
> 状态: #pending
```

## 标签系统

| 标签 | 含义 |
|------|------|
| `#consensus` | 已达成共识 |
| `#pending` | 待讨论 |
| `#rejected` | 已否决 |
| `#needs-input` | 需要特定角色输入 |
| `#blocker` | 阻塞项 |
| `#review-requested` | 请求审阅 |

## 草案格式

### 提议草案

```markdown
## [Draft vN] @角色名 — 工具名
> 时间: YYYY-MM-DD HH:mm
> 状态: #review-requested

> [!decision] 草案摘要
> 基于 Round 1-N 的讨论，提出以下综合方案草案。
> 请 @all 审阅并提供反馈。

### 方案概要
（综合各方观点的方案描述）

### 技术选型
（基于讨论共识的技术决策）

### 开放问题
- [ ] @角色: 待确认问题 #needs-input

---
```

### 审阅草案

```markdown
## [Draft vN Review] @角色名 — 工具名
> 时间: YYYY-MM-DD HH:mm

> [!quote] @发起人 Draft vN - 章节名
> （引用的原文）

### 修改建议
1. 具体建议 1
2. 具体建议 2

---
```

## STATUS 面板

位于 `discussion.md` 文件顶部，使用 HTML 注释包裹：

```markdown
<!-- STATUS
round: 1
pending: @Architect, @Security
completed: @PM
mentions:
  - target: @Security, from: @PM, round: 1, topic: "安全评估"
phase: discuss
max_rounds: 3
-->
```

**字段说明：**
- `round`: 当前讨论轮次
- `pending`: 本轮尚未发言的角色
- `completed`: 本轮已发言的角色
- `mentions`: 未回应的 @ 提及记录
- `phase`: 当前阶段 (`discuss` / `draft` / `review` / `done`)
- `max_rounds`: 最大讨论轮次（默认 3）

**更新规则：** 每个 agent 发言后必须更新 STATUS 面板 —— 将自己从 `pending` 移至 `completed`，清除已回应的 mentions，并在有新 @ 提及时添加新 mention 记录。
