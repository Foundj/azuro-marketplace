# Commands 命令说明

## 用户命令 (6 个)

核心命令，注册在 marketplace.json 中，用户可直接调用。

| 命令 | 功能 | 参数/子命令 |
|------|------|-------------|
| `/ai:dev` | 开发主入口 | `<feature>`, `auto`, `--quick`, `--skip-research` |
| `/ai:fix` | 快速修复 (subagent) | `<bug>`, `--deep`, `--no-verify`, `--max-retries N` |
| `/ai:status` | 状态查看 | `--list`, `<id>` (详情) |
| `/ai:session-save` | 保存会话进度 | - |
| `/ai:session-resume` | 恢复会话 | `[id]`, `--full`, `--show` |
| `/ai:skills-audit` | 技能审计 | `[skill-name]` |

---

## 命令详解

### `/ai:dev <feature> | auto`

完整 7-phase 开发工作流。

**用法：**
```bash
/ai:dev user login           # 启动完整开发工作流
/ai:dev auto                  # 自动完成所有未完成任务
/ai:dev auto --dry-run        # 预览任务不执行
/ai:dev <feature> --quick     # 快速模式 (跳过 Phase 2/3)
/ai:dev <feature> --skip-research  # 跳过竞品研究
```

### `/ai:fix <bug>`

智能 bug 修复，作为 subagent 执行，不占用主会话上下文。

**用法：**
```bash
/ai:fix login button not working     # 自动检测复杂度
/ai:fix --deep race condition        # 强制深度调试模式
/ai:fix --no-verify typo fix         # 快速修复，跳过验证
/ai:fix --max-retries 5 complex bug  # 自定义最大重试次数
```

### `/ai:status [--list] [<id>]`

项目状态、功能列表、功能详情（三合一）。

**用法：**
```bash
/ai:status              # 显示项目整体状态
/ai:status --list       # 列出所有功能及状态
/ai:status 001          # 显示功能 #001 详情
/ai:status --detailed   # 详细模式
```

### `/ai:session-save`

保存当前会话进度，生成摘要和下一步任务文件。

**用法：**
```bash
/ai:session-save       # 保存进度到 codebox/context/
```

**生成文件：**
- `codebox/context/session_summary.md` - 会话摘要
- `codebox/context/next_steps.md` - 下一步任务

### `/ai:session-resume [<id>] [--full]`

恢复会话上下文并继续执行。

**用法：**
```bash
/ai:session-resume           # 快速恢复并自动继续
/ai:session-resume 001       # 恢复特定功能
/ai:session-resume --full    # 完整恢复 (10步验证)
/ai:session-resume --show    # 仅显示状态不执行
```

### `/ai:skills-audit [skill-name]`

审计技能质量。

**用法：**
```bash
/ai:skills-audit              # 审计所有技能
/ai:skills-audit ai-dev       # 审计指定技能
```

---

## 内部命令

以下命令由工作流内部调用，文件保留但不注册到 marketplace.json：

| 命令 | 调用者 | 说明 |
|------|--------|------|
| `ai:interview` | ai:dev Phase 1 | 需求访谈 |
| `ai:design` | ai:dev Phase 3 | 设计评审 |
| `ai:implement` | ai:dev Phase 4 | 实现 |
| `ai:quality` | ai:dev Phase 5 | 质量验证 |
| `ai:review` | ai:dev Phase 5 | 代码审查 |
| `ai:loop` | ai:dev auto | OODA 循环引擎 |
| `ai:check` | ai:dev Phase 0 | 预检查 |
| `ai:archive` | ai:dev Phase 6 | 归档 |
| `ai:research` | ai:dev Phase 0.5 | 竞品研究 |
| `ai:knowledge` | 多阶段 | 知识查询 |
| `ai:update-constraints` | 维护 | 约束更新 |
| `ai:update-feature-index` | 维护 | 索引更新 |
| `ai:skills-audit:one` | ai:skills-audit | 单技能审计 |

---

## 归档命令

以下命令已归档到 `bak/commands/`，功能已合并到新命令：

| 旧命令 | 新命令 | 说明 |
|--------|--------|------|
| `/ai:auto` | `/ai:dev auto` | 自动完成功能 |
| `/ai:list` | `/ai:status --list` | 列出功能 |
| `/ai:show` | `/ai:status <id>` | 功能详情 |
| `/ai:resume` | `/ai:session-resume` | 恢复功能 |
| `/session:save` | `/ai:session-save` | 保存会话 |
| `/session:resume` | `/ai:session-resume` | 恢复会话 |

---

## 命令命名规范

### Claude Code 系统保留命令（禁止使用）

```bash
/help       # 帮助系统
/clear      # 清除对话
/tasks      # 任务管理
/mcp        # MCP 服务器管理
/settings   # 设置
/debug      # 调试模式
/status     # 系统状态（已占用！我们用 ai:status）
```

### 命名约定

- 使用 `ai:` 前缀避免冲突
- 保持简短（≤10 字符）
- 使用动词开头

---

**版本：2.0.0**
**更新日期：2026-01-13**
**重大变更：命令精简为 6 个用户命令，其他改为内部命令**
