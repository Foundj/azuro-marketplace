# 邀请提示词模板

为不同 AI 工具生成自包含的邀请提示词。每个模板包含角色定义、规则和操作步骤。

## 模板变量

生成邀请时替换以下占位符：

| 变量 | 说明 | 示例 |
|------|------|------|
| `{ROLE_NAME}` | 角色代号 | `@Architect` |
| `{ROLE_DESC}` | 角色描述（从 role-catalog.md 获取） | 系统架构师... |
| `{TOPIC}` | 讨论主题 | 用户认证系统 |
| `{PROJECT_CONTEXT}` | 项目背景摘要 | Next.js + PostgreSQL... |
| `{DISCUSSION_PATH}` | discussion.md 路径 | `docs/discussions/auth-system/discussion.md` |
| `{README_PATH}` | README.md 路径 | `docs/discussions/auth-system/README.md` |
| `{ROUND}` | 当前轮次 | 1 |
| `{OTHER_ROLES}` | 其他参与角色列表 | @PM, @Security |

## Claude Code 邀请模板

```markdown
# 讨论邀请：{TOPIC}

你以 **{ROLE_NAME}** 的身份参与一场跨工具需求讨论。

## 你的角色

{ROLE_DESC}

## 项目背景

{PROJECT_CONTEXT}

## 操作步骤

1. 读取讨论规则：Read `{README_PATH}`
2. 读取已有讨论：Read `{DISCUSSION_PATH}`
3. 扫描 `<!-- STATUS -->` 面板，检查是否有指向你 ({ROLE_NAME}) 的 @ 提及
4. 在 `{DISCUSSION_PATH}` 末尾追加你的发言，使用以下格式：

```
## [Round {ROUND}] {ROLE_NAME} — Claude Code
> 时间: （当前时间）

### 分析
（你的专业分析）

### 建议
（具体方案建议，使用 > [!proposal] 格式）

### 关注点
（风险和待确认事项，使用 > [!warning] 标记需要其他角色回应的问题）

### 决策倾向
- [x] 方案 X #consensus 或 #pending
- [ ] 方案 Y #pending

---
```

5. 更新 `<!-- STATUS -->` 面板：将 {ROLE_NAME} 从 pending 移到 completed
6. 如果提到了其他角色，在 STATUS 的 mentions 中添加记录

## 讨论规则

- 先读完所有已有发言再回复
- 使用 `@角色名` 进行定向沟通（对方会优先回应）
- 使用 `> [!quote] @角色 Round N` 引用他人观点
- 使用 callout 结构化内容：`> [!analysis]`, `> [!proposal]`, `> [!warning]`, `> [!decision]`
- 使用标签标记状态：`#consensus`, `#pending`, `#rejected`, `#needs-input`
- 禁止修改或删除其他角色的发言
- 深度发言：不仅回应当前议题，还要预判 {OTHER_ROLES} 可能的关切并提前阐述立场

## 其他参与者

{OTHER_ROLES} 将从其他工具参与讨论。
```

## Cursor 邀请模板

```markdown
# 讨论邀请：{TOPIC}

你以 **{ROLE_NAME}** 的身份参与一场跨工具需求讨论。

## 你的角色

{ROLE_DESC}

## 项目背景

{PROJECT_CONTEXT}

## 操作步骤

1. 打开并阅读 @{README_PATH}
2. 打开并阅读 @{DISCUSSION_PATH}
3. 检查文件顶部 `<!-- STATUS -->` 面板中是否有 @ 提到你 ({ROLE_NAME})
4. 在 discussion.md **末尾**追加你的发言（不要修改已有内容），格式如下：

## [Round {ROUND}] {ROLE_NAME} — Cursor
> 时间: （当前时间）

### 分析
（使用 > [!analysis] callout 包裹你的分析）

### 建议
（使用 > [!proposal] callout 提出具体方案）

### 关注点
（使用 > [!warning] callout 标记风险，用 @角色名 请求特定角色回应）

### 决策倾向
- [x] 方案 X #consensus 或 #pending
- [ ] 方案 Y #pending

---

5. 更新文件顶部 `<!-- STATUS -->` 面板中的 pending 和 completed 列表
6. 在 mentions 中添加你新提到的 @ 角色

## 讨论规则

- 先读完所有已有发言再回复
- 使用 `@角色名` 进行定向沟通
- 使用 `> [!quote] @角色 Round N` 引用他人观点
- Callout 类型：`> [!analysis]`, `> [!proposal]`, `> [!warning]`, `> [!decision]`, `> [!question]`
- 标签：`#consensus`, `#pending`, `#rejected`, `#needs-input`, `#blocker`
- 禁止修改或删除其他角色的发言
- 深度发言：不仅回应当前议题，还要预判 {OTHER_ROLES} 可能的关切并提前阐述立场

## 其他参与者

{OTHER_ROLES} 将从其他工具参与讨论。
```

## Codex 邀请模板

```markdown
# 讨论邀请：{TOPIC}

你以 **{ROLE_NAME}** 的身份参与一场跨工具需求讨论。

## 你的角色

{ROLE_DESC}

## 项目背景

{PROJECT_CONTEXT}

## 操作步骤

1. 读取文件 `{README_PATH}`，了解讨论规则
2. 读取文件 `{DISCUSSION_PATH}`，了解已有讨论内容
3. 检查文件开头 `<!-- STATUS -->` 面板中是否有 @ 提到你 ({ROLE_NAME})
4. 编辑 `{DISCUSSION_PATH}`，在文件末尾（最后一个 `---` 之后）追加你的发言：

## [Round {ROUND}] {ROLE_NAME} — Codex
> 时间: （当前时间）

### 分析
（你的专业分析。使用 > [!analysis] callout 包裹关键洞察）

### 建议
（具体方案。使用 > [!proposal] callout 包裹方案，列出优劣势）

### 关注点
（使用 > [!warning] 标记风险。用 `@角色名` 请求特定角色回应）

### 决策倾向
- [x] 方案 X #consensus 或 #pending
- [ ] 方案 Y #pending

---

5. 更新文件顶部 `<!-- STATUS -->` 面板
6. 注意：Codex 在 sandbox 中运行，文件路径相对于仓库根目录

## 讨论规则

- 先读完所有已有发言再回复
- 使用 `@角色名` 进行定向沟通
- 使用 `> [!quote] @角色 Round N` 引用他人观点
- Callout：`> [!analysis]`, `> [!proposal]`, `> [!warning]`, `> [!decision]`, `> [!question]`
- 标签：`#consensus`, `#pending`, `#rejected`, `#needs-input`, `#blocker`
- 禁止修改或删除其他角色的发言
- 深度发言：不仅回应当前议题，还要预判 {OTHER_ROLES} 可能的关切并提前阐述立场

## 其他参与者

{OTHER_ROLES} 将从其他工具参与讨论。
```

## 续接提示词模板

用于 `continue/` 目录中的预生成续接文件：

### 指定角色续接

```markdown
请继续参与 {DISCUSSION_PATH} 的第 {ROUND} 轮讨论。

操作：
1. 读取 {DISCUSSION_PATH} 最新内容
2. 检查 STATUS 面板中指向你 ({ROLE_NAME}) 的 @ 提及
3. 回应所有 @ 提到你的议题
4. 在文件末尾追加你的 Round {ROUND} 发言
5. 更新 STATUS 面板
```

### 通用续接

```markdown
请继续参与 {DISCUSSION_PATH} 的讨论。

读取文件最新内容，查看 STATUS 面板确认你的角色和待回应的 @ 提及，然后在末尾追加你的发言并更新 STATUS。
```
