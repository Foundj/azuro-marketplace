# 讨论预设配置

预设定义了常用的角色组合和工具分配策略，可通过 `--preset` 参数快速启用。

## 预设定义

### product-discovery — 产品发现

适用于需求分析、功能规划、用户价值判断。

```json
{
  "name": "product-discovery",
  "description": "需求分析与用户价值评估",
  "roles": ["@PM", "@UserAdvocate", "@Architect", "@Critic"],
  "max_rounds": 3,
  "focus": "问题定义优先，方案设计其次",
  "round_1_theme": "问题定义与假设识别",
  "tool_assignment_strategy": "max-diversity"
}
```

**工具分配建议：**

| 角色 | 首选工具 | 理由 |
|------|----------|------|
| @PM | codex | 产品视角，独立模型 |
| @UserAdvocate | gemini | 不同模型提供不同用户洞察 |
| @Architect | claudec | Claude 在架构分析上表现优秀 |
| @Critic | claudea | 不同模型倾向提出不同反对意见 |

### architecture-design — 架构设计

适用于技术选型、系统设计、架构评审。

```json
{
  "name": "architecture-design",
  "description": "技术选型与架构评审",
  "roles": ["@Architect", "@Backend", "@Security", "@Critic"],
  "max_rounds": 3,
  "focus": "技术可行性、性能、安全",
  "round_1_theme": "架构约束与非功能需求",
  "tool_assignment_strategy": "max-diversity"
}
```

**工具分配建议：**

| 角色 | 首选工具 | 理由 |
|------|----------|------|
| @Architect | claudec | 架构分析 |
| @Backend | codex | 实现视角 |
| @Security | gemini | 安全审计独立视角 |
| @Critic | claudea | 反共识偏见 |

### full-review — 全栈评审

适用于全栈功能开发的完整评审。

```json
{
  "name": "full-review",
  "description": "全栈功能开发评审",
  "roles": ["@PM", "@Architect", "@Frontend", "@Backend", "@QA"],
  "max_rounds": 3,
  "focus": "功能完整性、技术可行性、质量保障",
  "round_1_theme": "需求理解与技术约束",
  "tool_assignment_strategy": "max-diversity"
}
```

**工具分配建议：**

| 角色 | 首选工具 | 理由 |
|------|----------|------|
| @PM | codex | 产品视角 |
| @Architect | claudec | 架构分析 |
| @Frontend | gemini | 前端视角 |
| @Backend | claudea | 后端实现 |
| @QA | claudeg | 测试策略 |

### security-audit — 安全审计

适用于安全审计、合规评估。

```json
{
  "name": "security-audit",
  "description": "安全审计与合规评估",
  "roles": ["@Architect", "@Security", "@Backend", "@DevOps"],
  "max_rounds": 3,
  "focus": "威胁模型、安全约束、合规要求",
  "round_1_theme": "威胁面分析与攻击向量",
  "tool_assignment_strategy": "max-diversity"
}
```

## 工具分配策略

### max-diversity（最大多样性）

优先将不同角色分配到不同工具后端，以获得最多样化的视角。

**分配优先级（按多样性排序）：**
1. codex — OpenAI 模型
2. gemini — Google 模型
3. claudea — 代理模型（glm-5/MiniMax）
4. claudec — 远程 Claude/Gemini
5. claudeg — Gemini 模型代理 (gemini-3.1-pro)
6. opencode — 取决于配置的 provider

**降级规则：**
- 首选工具不可用时，尝试下一个可用工具
- 所有首选都不可用时，使用任意可用工具
- 零工具可用时，生成手动邀请文件

### round-robin（轮换）

每轮讨论中轮换工具分配，让同一角色在不同轮次使用不同模型。

## 自定义预设

用户可通过 `--roles` 参数自定义角色组合：

```bash
/ai:discuss init my-topic --roles PM,Architect,DBA,Critic
```

也可在讨论目录的 `preset.json` 中定义自定义预设。
