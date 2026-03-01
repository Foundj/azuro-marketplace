# CLI Prompt 模板

为不同 CLI 工具后端优化的 prompt 模板。这些模板用于自动化调用时构建发送给外部 agent 的提示词。

## 设计原则

1. **自包含**：每个 prompt 必须包含完整上下文，无需 agent 额外读取文件
2. **角色注入**：包含角色描述和行为约束
3. **黑板内容**：包含当前 discussion.md 的完整内容
4. **输出格式**：明确指定输出格式，确保可解析
5. **工具适配**：根据工具能力调整指令（如 Codex 有文件写入能力，纯 prompt 模式没有）

## 通用 Prompt 模板

所有工具共享的基础结构：

```markdown
# 角色: {ROLE_NAME}

{ROLE_DESC}

## 你的任务

参与关于 **{TOPIC}** 的第 {ROUND} 轮讨论。

## 独立分析要求

你必须独立分析，从你的专业角度提出其他角色可能忽视的问题。不要简单附和前序发言，提供你独特的专业洞察。

## 项目背景

{PROJECT_CONTEXT}

## 当前讨论内容

以下是 discussion.md 的完整内容，请仔细阅读所有发言后再回复：

---
{DISCUSSION_CONTENT}
---

## 待回应的 @ 提及

{PENDING_MENTIONS}

## 输出格式

请**严格**按以下格式输出你的发言（不要包含其他内容）：

```
## [Round {ROUND}] {ROLE_NAME} — {TOOL_NAME}
> 时间: {TIMESTAMP}

### 分析

（你的专业分析，使用 > [!analysis] callout 包裹关键洞察）

### 建议

（具体方案建议，使用 > [!proposal] callout 提出方案）

### 关注点

（风险和待确认事项，使用 > [!warning] 标记风险，用 @角色名 请求特定角色回应）

### 决策倾向

- [x] 方案 X #consensus 或 #pending
- [ ] 方案 Y #pending

---
```

## 讨论规则

- 使用 `@角色名` 进行定向沟通
- 使用 `> [!quote] @角色 Round N` 引用他人观点
- Callout 类型: `> [!analysis]`, `> [!proposal]`, `> [!warning]`, `> [!decision]`, `> [!question]`, `> [!assumption]`
- 标签: `#consensus`, `#pending`, `#rejected`, `#needs-input`, `#blocker`
- 禁止修改或删除其他角色的发言
```

## @Critic 专用模板扩展

在通用模板的"独立分析要求"之后追加：

```markdown
## 反共识职责（重要）

作为批评者/魔鬼代言人，你有特殊职责：

1. **必须反对**：每次发言必须包含至少 1 个 `> [!warning]` 或 `> [!assumption]` callout
2. **禁止全面赞同**：你的决策倾向中至少保留 1 个 `#pending`，或提出替代方案
3. **挑战假设**：识别讨论中的隐含假设，使用 `> [!assumption]` 标注
4. **压力测试**：对主流方案进行"如果失败会怎样"的思考
5. **首轮特殊**：如果是第一轮，聚焦"问题定义是否正确"而非方案评判
```

## 工具特定适配

### Codex 适配

Codex 使用 `codex exec` 执行，prompt 通过 stdin 或直接参数传递：

```bash
# 构建 prompt 时注意：
# - Codex 有文件读写能力，但在 --full-auto 下使用 workspace-write 沙箱
# - prompt 中不要要求 Codex 修改 discussion.md（由编排器负责）
# - 在 prompt 末尾加上明确的输出指令
```

在通用模板末尾追加：

```markdown
## 重要提示

请直接输出你的发言内容，不要尝试编辑任何文件。你的输出将由编排系统自动追加到 discussion.md。
```

### OpenCode 适配

OpenCode 使用 `opencode run`，输出格式为 JSON：

```markdown
## 重要提示

请直接输出你的发言内容，不要尝试编辑任何文件。你的输出将由编排系统自动追加到 discussion.md。
```

### Gemini 适配

Gemini 使用 `gemini -p`，在沙箱模式下运行：

```markdown
## 重要提示

请直接输出你的发言内容，不要尝试编辑任何文件。你的输出将由编排系统自动追加到 discussion.md。如果你有文件系统访问能力，可以读取项目文件以获取更多上下文，但不要写入任何文件。
```

### Claude* 适配

所有 `claude/claudea/claudec/claudeg` 变体共享相同适配：

```markdown
## 重要提示

请直接输出你的发言内容。你被限制为只读工具（Read, Glob, Grep），可以读取项目文件获取更多上下文。不要尝试写入或编辑文件。你的输出将由编排系统自动追加到 discussion.md。
```

## Prompt 构建流程

编排器（Claude Code）在调用每个 agent 前，按以下步骤构建 prompt：

1. 从 `role-catalog.md` 获取角色描述 → `{ROLE_DESC}`
2. 从 `context.md` 获取项目背景 → `{PROJECT_CONTEXT}`
3. 读取当前 `discussion.md` 完整内容 → `{DISCUSSION_CONTENT}`
4. 从 STATUS 面板提取该角色的待回应 @ 提及 → `{PENDING_MENTIONS}`
5. 填充轮次、时间戳等元数据
6. 根据目标工具追加工具特定适配段落
7. 如果角色是 @Critic，追加反共识职责段落
8. 将完整 prompt 写入临时文件
9. 调用 `invoke-agent.sh <tool> <prompt-file> <working-dir>`
