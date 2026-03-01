---
name: brainstorm-mode
description: |
  This skill provides Socratic exploration mode for discovering requirements from vague ideas.
  It uses open-ended questioning, divergent thinking, and iterative refinement to transform
  fuzzy concepts into clear specifications. Use when the user mentions "brainstorm", "explore ideas",
  "not sure what I need", "头脑风暴", "探索想法", "我不确定", "帮我想想", or has unclear requirements.
version: 6.0.0
status: ga
triggers:
  - brainstorm
  - explore ideas
  - not sure what I need
  - help me think through
  - 头脑风暴
  - 探索想法
  - 我不确定
  - 帮我想想
  - 还没想清楚
  - 好好想想
  - 考虑下
  - 分析下
---

# Brainstorm Mode

> 苏格拉底式探索对话，从模糊想法发现清晰需求。

## Quick Start

```bash
/brainstorm "I want to improve user experience"
@brainstorm 我想做个新功能但还没想清楚
brainstorm how to handle authentication
```

## 核心理念

**不是结构化访谈，而是发散探索。**

```
传统访谈 (ai-dev-interview):
  用户 → 回答问题 → 生成需求文档

头脑风暴 (brainstorm-mode):
  模糊想法 → 苏格拉底提问 → 发散探索 → 收敛聚焦 → 发现需求
```

## 工作流程

### Entry Modes

At session start, offer three entry modes per interaction-protocol:

```
How would you like to explore this?
1. Guided — I'll ask open-ended questions step by step (Socratic mode)
2. Context dump — Paste your existing ideas/constraints, I'll dig deeper
3. Quick mode — I'll suggest 3 directions, you pick and we go from there
```

If the user ignores this and starts describing their idea, default to **Guided**.

### Flow

```
┌─────────────────────────────────────────────────────────┐
│              BRAINSTORM FLOW                             │
├─────────────────────────────────────────────────────────┤
│  1. SEED           [Seed Q1/1]                          │
│     - 接收模糊想法                                       │
│     - 不急于下结论                                       │
│                    ↓                                    │
│  2. DIVERGE (发散)  [Diverge Q1-N/N]                    │
│     - 苏格拉底式提问，每轮一个核心问题                    │
│     - 探索多个方向                                       │
│     - "还有什么可能？"                                   │
│                    ↓                                    │
│  3. EXPLORE (深入)  [Explore Q1-N/N]                    │
│     - 追问 "为什么这个重要？"                            │
│     - 挖掘隐藏需求                                       │
│     - 发现约束和偏好                                     │
│                    ↓                                    │
│  4. CONVERGE (收敛) [Converge Q1-N/N]                   │
│     - 识别模式和主题                                     │
│     - Decision-point: 编号选项选择核心方向                │
│                    ↓                                    │
│  5. CRYSTALLIZE (结晶)                                  │
│     - 生成 discovery-brief.md                           │
│     - 可选：转入 ai-dev 正式流程                         │
└─────────────────────────────────────────────────────────┘
```

### Per-Phase Behavior (follows interaction-protocol)

- **One question per turn** — show progress label `[Diverge Q2/4]`
- **No numbered options** in Diverge/Explore — use open-ended Socratic questions
- **Decision points** only in Converge — present 3-5 directions with trade-offs
- **Flexible parsing** — accept numbers, free text, or `skip`
- **Interruption** — answer the tangent directly, then offer: `Ready to continue? We were on [Explore Q3/5].`
- **Fast path** — if user says "just summarize", skip remaining phases, generate discovery-brief with `[assumed]` markers

## 苏格拉底提问技巧

### 开放式问题

**避免**:
- "你想要 A 还是 B？" (封闭)
- "这个功能需要登录吗？" (是/否)

**使用**:
- "理想情况下，这会是什么样子？"
- "当你说 X 时，能给我一个具体的例子吗？"
- "如果没有任何限制，你会怎么做？"
- "这个问题最让你困扰的是什么？"

### 探索性追问

```markdown
用户: 我想改进用户体验

助手: 当你说"用户体验"时，你脑海中浮现的是什么场景？
      是某个特定的页面？某个操作流程？还是整体感受？

用户: 主要是注册流程太复杂

助手: 能描述一下现在的注册流程吗？哪个步骤让用户最困惑？

用户: 要填太多字段

助手: 如果只能保留 3 个字段，你会保留哪些？为什么？

用户: 邮箱、密码... 其实用户名也不是必须的

助手: 有意思！那如果连密码都不需要呢？比如用邮件链接登录？
      这样会带来什么好处和问题？
```

### 反转视角

- "如果竞争对手这样做，你会怎么看？"
- "最差的实现会是什么样？"
- "用户会如何滥用这个功能？"

## 发散-收敛节奏

```
时间线:
  ├── 0-30%: 纯发散，收集想法，不评判
  ├── 30-60%: 深入探索有潜力的方向
  ├── 60-80%: 开始收敛，识别模式
  └── 80-100%: 结晶，形成清晰需求
```

**发散阶段规则**:
- 不说"不行"
- 不急于解决
- 鼓励"还有呢？"
- 记录所有想法

**收敛阶段规则**:
- 回顾所有想法
- 识别重复主题
- 问"哪些是必须的？"
- 排列优先级

## 输出: discovery-brief.md

```markdown
# Discovery Brief: [主题]

## 背景
- 触发这次探索的原因
- 当前痛点

## 探索过程
### 发散的想法
1. [想法 1]
2. [想法 2]
3. [想法 3]

### 深入探索的方向
- [方向 A]: 探索结果
- [方向 B]: 探索结果

### 被排除的想法
- [想法 X]: 排除原因

## 发现的需求
### 核心需求 (Must Have)
1. [需求 1]
2. [需求 2]

### 期望需求 (Should Have)
1. [需求 3]

### 可选需求 (Could Have)
1. [需求 4]

## 约束和偏好
- [约束 1]
- [偏好 1]

## 下一步
- [ ] 转入 `/ai:dev` 正式开发
- [ ] 继续探索 [特定方向]
- [ ] 需要更多用户调研
```

## 与 ai-dev 工作流集成

```
brainstorm-mode (Phase -1, 可选)
       ↓
   生成 discovery-brief.md
       ↓
   用户确认方向
       ↓
ai-dev Phase 0: Context & Knowledge
       ↓
ai-dev Phase 1: Requirement Interview
   (此时需求已经清晰，访谈更高效)
```

**触发条件**:
- 用户表达不确定性
- 需求模糊
- 探索性项目

## 对话示例

```markdown
用户: brainstorm 我想给应用加点社交功能

助手: 社交功能是个很大的领域！让我们先探索一下。

当你想到"社交功能"时，脑海中浮现的第一个画面是什么？
是用户之间聊天？分享内容？还是其他？

用户: 主要是想让用户能互相看到对方在做什么

助手: 有意思！"看到对方在做什么"——这是实时的还是历史记录？
比如，是像状态更新那样，还是像活动流？

用户: 活动流那种

助手: 好的。那这个活动流主要是为了：
- 保持联系感？（知道朋友在干嘛）
- 发现新内容？（看别人在用什么功能）
- 还是竞争/激励？（看别人的进度）

哪个更接近你的想法？或者都不是？

用户: 保持联系感吧，但也希望能发现有趣的内容

助手: 明白了！那关于隐私呢——用户会想控制谁能看到自己的活动吗？
还是默认对所有人可见？

[... 继续探索 ...]
```

## 配置

```json
// codebox/config.json
{
  "brainstorm": {
    "minDivergenceRounds": 3,
    "autoTransitionToAiDev": false,
    "outputFile": "discovery-brief.md"
  }
}
```

## Common Pitfalls

### Pitfall 1: Premature Convergence
**Symptom:** Agent asks 2 questions then immediately proposes a solution.
**Consequence:** Misses hidden requirements. User gets a polished answer to the wrong question.
**Fix:** Enforce minimum 3 divergence rounds before converging. In the 0-30% phase, never evaluate ideas.

### Pitfall 2: Brainstorming Clear Requirements
**Symptom:** User says "brainstorm OAuth implementation" — the decision is already made.
**Consequence:** Wasted time exploring alternatives the user doesn't want.
**Fix:** If requirements are clear, redirect to `/ai:dev`. Brainstorm is for "I don't know what I need" — not "I know what I need but call it brainstorm."

### Pitfall 3: Endless Exploration
**Symptom:** Session exceeds 10+ rounds without producing a discovery-brief.
**Consequence:** User loses interest. Ideas discussed early are forgotten. No actionable output.
**Fix:** At 80% of the session, actively trigger CONVERGE phase. Summarize findings into discovery-brief.md even if exploration feels incomplete.

## 何时使用

| 场景 | 推荐模式 |
|------|----------|
| "我想做个用户认证" | ❌ 直接 `/ai:dev` |
| "我想改进一下体验" | ✅ `/brainstorm` |
| "帮我实现这个 API" | ❌ 直接 `/ai:dev` |
| "我在想要不要加个功能" | ✅ `/brainstorm` |
| "修复登录 bug" | ❌ 直接 `/fix` |
| "不知道该怎么设计这个" | ✅ `/brainstorm` |

## 哲学创作模式 (Philosophy-Driven Creation)

> 灵感来自 Anthropic 官方 Skills 的最佳实践

**核心理念**: 在创作任何东西之前，先明确指导原则。

```
传统流程:
  需求 → 直接实现 → 结果可能偏离

哲学创作流程:
  需求 → 创建哲学/宣言 → 基于哲学实现 → 结果符合愿景
```

### 何时使用哲学模式

| 场景 | 推荐 |
|------|------|
| 创建视觉设计 | ✅ 先定义设计哲学 |
| 开发用户体验 | ✅ 先明确体验原则 |
| 架构重大决策 | ✅ 先制定架构宣言 |
| 简单 bug 修复 | ❌ 无需 |
| 明确的功能实现 | ❌ 无需 |

### 哲学创作工作流

```
┌─────────────────────────────────────────────────────────┐
│          PHILOSOPHY-DRIVEN CREATION                     │
├─────────────────────────────────────────────────────────┤
│  Phase 1: DISCOVER (发现)                               │
│     - 使用苏格拉底提问探索用户愿景                       │
│     - 识别隐藏的价值观和偏好                            │
│     - 收集情感词汇和意象                                │
│                    ↓                                    │
│  Phase 2: ARTICULATE (表达)                             │
│     - 将发现转化为设计/创作哲学                         │
│     - 写成宣言形式 (3-7 条核心原则)                     │
│     - 包含反面定义 (这不是什么)                         │
│                    ↓                                    │
│  Phase 3: VALIDATE (验证)                               │
│     - 向用户展示哲学宣言                                │
│     - 确认是否捕捉到了核心愿景                          │
│     - 迭代修正                                          │
│                    ↓                                    │
│  Phase 4: CREATE (创作)                                 │
│     - 基于哲学进行创作/实现                             │
│     - 每个决策都参考哲学原则                            │
│     - 最终产出符合愿景                                  │
└─────────────────────────────────────────────────────────┘
```

### 哲学宣言模板

```markdown
# [项目/功能] 设计哲学

## 核心愿景
[一句话描述理想状态]

## 指导原则

### 1. [原则名称]
[具体描述]

### 2. [原则名称]
[具体描述]

### 3. [原则名称]
[具体描述]

## 这不是什么 (Anti-Patterns)
- ❌ [明确排除的方向]
- ❌ [明确排除的风格]

## 灵感来源
- [参考 1]
- [参考 2]

## 成功标准
[如何判断是否符合这个哲学]
```

### 哲学提问示例

```markdown
用户: 我想设计一个登录页面

助手 (启用哲学模式):
在我们开始设计之前，让我先了解你心中的理想画面。

当用户第一次看到这个登录页面时，你希望他们感受到什么？
是专业可靠？轻松友好？还是高端精致？

用户: 想让人觉得很专业，但又不冷冰冰的

助手: 「专业但有温度」——这是很好的方向！
能给我一个你见过的、符合这种感觉的例子吗？
可以是任何产品，不一定是软件。

用户: 像苹果商店那种感觉吧

助手: 明白了！苹果的那种「简洁、留白、但每个细节都精心设计」的感觉。
那你希望避免什么？有没有让你觉得「绝对不要这样」的例子？

用户: 不要太花哨，不要那种渐变色满屏的

助手: 好的，我来总结一下我们发现的设计哲学：

---
## 登录页面设计哲学

### 核心愿景
「简洁精致，专业却有温度」

### 指导原则
1. **克制的优雅**: 少即是多，每个元素都有存在的理由
2. **细节见品质**: 看似简单，但字体、间距、动效都经过精心考量
3. **温暖的专业**: 友好的文案，舒适的色彩，但保持专业感

### 这不是什么
- ❌ 花哨的渐变和装饰
- ❌ 冷冰冰的纯功能界面
- ❌ 过度设计的元素
---

这个哲学能代表你的愿景吗？
```

---

### Interaction Protocol
Use [`interaction-protocol`](../interaction-protocol/SKILL.md) as the default interaction behavior.
It defines entry modes, progress labels, decision-point recommendations, and interruption handling.
This file defines the domain-specific content. If conflict, follow this file's domain logic.

## 与其他 Skill 的区别

| Skill | 目的 | 输入 | 输出 |
|-------|------|------|------|
| `brainstorm-mode` | 发现需求 | 模糊想法 | discovery-brief.md |
| `brainstorm-mode` (哲学模式) | 建立创作原则 | 创意方向 | philosophy.md |
| `ai-dev-interview` | 细化需求 | 明确方向 | proposal.md |
| `competitor-research` | 调研方案 | 明确主题 | research.json |

## Agent Collaboration

| Agent | Role |
|-------|------|
| `ai-dev` | Receives discovery-brief.md as input |
| `ai-dev-interview` | Takes over after direction is clear |
| `@oracle` | Consult for complex strategic decisions |
| `competitor-research` | Research after initial direction |

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 4.2.6 | 2026-01-13 | Add third-person description, agent collaboration |
| 4.2.4 | 2026-01-10 | Add Philosophy-Driven Creation mode |
| 4.0.0 | 2026-01-07 | Initial release with Socratic workflow |

## References

See `references/socratic-techniques.md` for questioning techniques.
