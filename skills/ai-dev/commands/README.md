# AI-Dev Commands

AI-Dev 使用 `ai-xxx` 系列命令，支持分阶段执行或完整工作流。

## 命令总览

```
┌─────────────────────────────────────────────────────────────┐
│                    AI-Dev 命令系列                           │
├─────────────────────────────────────────────────────────────┤
│  /ai:dev <feature>     完整 7-phase 工作流                   │
│  ├── /ai-research      Phase 0.5: 竞品调研                   │
│  ├── /ai-interview     Phase 1: 需求沟通                     │
│  ├── /ai-design        Phase 2: 设计评审                     │
│  ├── /ai-implement     Phase 4: OODA 实现                    │
│  ├── /ai-review        Phase 5: 代码审查                     │
│  ├── /ai-fix           Review-Fix-Verify 循环               │
│  └── /ai:status        进度/状态查看                         │
├─────────────────────────────────────────────────────────────┤
│  /fix <bug>            快速修复 (legacy, 建议用 /ai-fix)     │
│  /dev <feature>        ai-dev 别名                           │
└─────────────────────────────────────────────────────────────┘
```

## 核心命令

| 命令 | 描述 | 阶段 |
|------|------|------|
| `/ai:dev <feature>` | 完整 7-phase 开发工作流 | 0-6 |
| `/ai-research <topic>` | 多源竞品调研 | 0.5 |
| `/ai-interview <feature>` | 多轮需求沟通，生成 proposal.md | 1 |
| `/ai-design <feature>` | 设计评审，生成 design.md | 2 |
| `/ai-implement <feature>` | OODA 自主实现 | 4 |
| `/ai-review [files]` | 代码审查，置信度评分 | 5 |
| `/ai-fix <bug>` | Review-Fix-Verify 循环修复 | 5+ |
| `/ai:status` | 查看开发状态和进度 | - |

## 快捷命令

| 命令 | 描述 |
|------|------|
| `/fix <bug>` | 快速修复 (legacy，建议用 `/ai-fix`) |
| `/dev <feature>` | `/ai:dev` 的简短别名 |
| `/progress` | `/ai:status` 的别名 |

## 使用示例

### 完整工作流
```bash
/ai:dev 用户登录功能
```

### 分阶段执行
```bash
# 1. 先调研
/ai-research OAuth 2.0 最佳实践

# 2. 需求沟通
/ai-interview 用户登录功能

# 3. 设计评审 (基于 proposal)
/ai-design --from-proposal

# 4. 实现 (基于 design)
/ai-implement --from-design

# 5. 代码审查
/ai-review --staged

# 随时查看状态
/ai:status
```

### 快速开发 (跳过前期)
```bash
# 跳过 interview/design，直接实现
/ai-implement 添加用户头像上传 --quick

# 修复 bug
/fix 登录按钮点击无响应
```

## 命令选项

### /ai:dev
| 选项 | 描述 |
|------|------|
| `--skip-research` | 跳过 Phase 0.5 竞品调研 |
| `--quick` | 跳过 Phase 1/2，直接实现 |

### /ai-research
| 选项 | 描述 |
|------|------|
| `--deep` | 多模型深度调研 (Gemini + Codex + Claude) |
| `--save` | 保存结果到 `codebox/research/` |

### /ai-design
| 选项 | 描述 |
|------|------|
| `--from-proposal` | 基于现有 proposal.md |

### /ai-implement
| 选项 | 描述 |
|------|------|
| `--from-design` | 基于现有 design.md |
| `--quick` | 跳过加载，直接实现 |

### /ai-review
| 选项 | 描述 |
|------|------|
| `--staged` | 审查暂存区变更 |
| `--diff <branch>` | 审查与指定分支的差异 |

### /ai:status
| 选项 | 描述 |
|------|------|
| `--detailed` | 显示详细进度信息 |

### /ai-fix
| 选项 | 描述 |
|------|------|
| `--deep` | 强制深度调试模式 |
| `--no-verify` | 跳过验证循环 (仅快速修复) |
| `--max-retries N` | 最大重试次数 (默认: 3) |

## 学习命令

| 命令 | 描述 |
|------|------|
| `/reflect` | 触发学习反思 |
| `/view-queue` | 查看待反思队列 |
| `/skip-reflect` | 跳过当前反思 |

## 特性管理

| 命令 | 描述 |
|------|------|
| `/feature-list` | 列出所有特性 |
| `/feature-show <id>` | 显示特性详情 |
| `/feature-resume [id]` | 恢复/继续特性 |
| `/feature-archive <id>` | 归档完成的特性 |

## 命令文件位置

```
~/.claude/commands/           # Claude 识别 (符号链接)
├── ai-dev.md → ../skills/commands/ai:dev.md
├── ai-research.md → ...
├── ai-interview.md → ...
├── ai-design.md → ...
├── ai-implement.md → ...
├── ai-review.md → ...
└── ai-status.md → ...

~/.claude/skills/commands/    # 源文件
├── ai-dev.md
├── ai-research.md
├── ai-interview.md
├── ai-design.md
├── ai-implement.md
├── ai-review.md
├── ai-status.md
├── fix.md
└── ...
```

## 相关文档

- [AI-Dev SKILL.md](../SKILL.md) - 完整技能定义
- [AI-Dev README.md](../README.md) - 快速入门
