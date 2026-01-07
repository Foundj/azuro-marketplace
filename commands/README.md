# Commands 命令说明

## ⚠️ 命令命名规范

### Claude Code 系统保留命令（禁止使用）

以下命令是 Claude Code 系统保留的，**请勿创建同名命令**：

```bash
/help       # 帮助系统
/clear      # 清除对话
/tasks      # 任务管理
/mcp        # MCP 服务器管理
/settings   # 设置
/debug      # 调试模式
/status     # 系统状态（已占用！）
```

### 我们的命令（避免冲突）

**AI-Dev 系列** (使用 `ai:` 前缀):
```bash
/ai:dev       # 完整开发工作流
/ai:check     # 预实现检查
/ai:archive   # 智能归档
/ai:loop      # 自引用循环
/ai:auto      # 自动完成任务
/ai:status    # 项目整体状态
/ai:list      # 列出所有功能 (原 /feature-list)
/ai:show      # 显示功能详情 (原 /feature-show)
/ai:resume    # 恢复功能 (原 /feature-resume)
/ai:fix       # 修复问题
/ai:review    # 代码审查
/ai:research  # 竞品调研
/ai:design    # 设计阶段
/ai:implement # 实现阶段
/ai:interview # 需求访谈
/ai:knowledge # 知识图谱查询
/ai:quality   # 质量门禁检查
```

**工具与审计**:
```bash
/skill-audit      # 审计所有技能质量
/skill-audit:one  # 审计单个技能质量
```

**快捷命令** (无前缀):
```bash
/dev        # 快速开发 (ai:dev 别名)
/fix        # 快速修复 (ai:fix 别名)
/research   # 竞品调研 (ai:research 别名)
/progress   # 查看项目进度 (ai:status 别名)
```

## 📝 可用命令列表

### `/dev <feature>`
快速开发功能，自动调用 ai-dev。

**示例：**
```bash
/dev user login
/dev add search功能
/dev implement avatar upload
```

### `/fix <bug>`
快速修复 bug，自动选择合适的 agent。

**示例：**
```bash
/fix login button
/fix 登录按钮点击没反应
/fix memory leak
```

### `/research <topic> [--backend] [--deep]`
多后端竞品调研（gemini/codex/claude）。

**示例：**
```bash
/research JWT authentication
/research 用户认证最佳实践
/research payment integration --deep
/research React patterns --backend gemini
```

### `/progress [--detailed]`
查看长运行项目的进度和健康状态。

**示例：**
```bash
/progress
/progress --detailed
```

### `/ai:loop <task> [--max-iterations N]`
自引用开发循环，持续执行直到 `<promise>DONE</promise>` 或达到最大迭代。
灵感来自 oh-my-opencode 的 Ralph Loop。

**示例：**
```bash
/ai:loop 实现用户登录功能
/ai:loop "Build REST API" --max-iterations 50
/ai:cancel-loop   # 取消运行中的循环
```

### `/ai:auto [--dry-run] [--from-task N.N]`
自动完成当前活动变更中的所有未勾选任务。
是 `/ai:loop` 的便捷封装，专门用于继续未完成的工作。

**示例：**
```bash
/ai:auto              # 自动完成所有剩余任务
/ai:auto --dry-run    # 仅预览，不执行
/ai:auto --from-task 2.1  # 从指定任务开始
```

### `/ai:check <feature> [--strict] [--quick]`
预实现检查：在开始实现前检查知识库，防止重复实现和错改代码。

**示例：**
```bash
/ai:check 用户登录功能         # 检查是否已有相关实现
/ai:check payment integration  # 查找相关代码和约束
/ai:check --strict "API auth"  # 严格模式，发现重复则阻止
```

### `/ai:archive [change_id] [--current] [--all-completed]`
智能归档已完成的变更，生成摘要，更新知识库。

**示例：**
```bash
/ai:archive CHG-20250106-001    # 归档指定变更
/ai:archive --current           # 归档当前活动变更
/ai:archive --all-completed     # 归档所有已完成变更
/ai:archive --dry-run           # 预览不执行
```

### `/ai:update-constraints [--full] [--scope <path>]`
更新实现约束文件，提取代码模式和约定。

**示例：**
```bash
/ai:update-constraints              # 增量更新
/ai:update-constraints --full       # 完整重建
/ai:update-constraints --scope src/auth/  # 限定范围
```

### `/ai:update-feature-index [--from-archive] [--rebuild]`
更新功能索引，映射功能到实现文件。

**示例：**
```bash
/ai:update-feature-index              # 从归档提取
/ai:update-feature-index --rebuild    # 完整重建
/ai:update-feature-index --dry-run    # 预览不执行
```

## 🔧 添加新命令指南

### 1. 检查命令名称
确保不与 Claude Code 系统命令冲突。

### 2. 创建命令文件
在 `commands/` 目录下创建 `<command-name>.md`。

### 3. 命令文件模板
```markdown
---
name: command-name
description: Brief description of what this command does
allowed-tools: Read, Write, Bash, etc.
argument-hint: "[optional-args]"
---

# Command Name - 命令说明

## 用途
描述命令的用途

## 使用方法
\`\`\`bash
/command-name <args>
\`\`\`

## 示例
...
```

### 4. 更新此文档
在上面的"可用命令列表"中添加新命令。

## 📋 命令开发最佳实践

1. **简短明了**：命令名应该简短（≤10个字符）
2. **避免冲突**：先检查 Claude Code 系统命令
3. **清晰文档**：提供清晰的使用示例
4. **参数提示**：使用 `argument-hint` 提示用户
5. **工具限制**：只列出必需的 `allowed-tools`

## 🚫 命令命名避坑指南

### ❌ 不要使用
- 太通用的词：`run`, `exec`, `cmd`
- 系统保留词：`help`, `clear`, `tasks`, `status`
- 太长的名字：`initialize-long-running-project`（太长！）

### ✅ 推荐使用
- 简短动词：`dev`, `fix`, `build`, `test`
- 领域特定：`progress`, `review`, `optimize`
- 清晰易记：用户一看就懂

## 🔍 冲突检查工具

运行以下命令检查是否有冲突：
```bash
# 列出所有命令文件
ls -la ${CLAUDE_PLUGIN_ROOT}/commands/

# 检查命令名称
grep "^name:" ${CLAUDE_PLUGIN_ROOT}/commands/*.md
```

---

**版本：1.4.0**
**更新日期：2026-01-07**
**重大变更：统一命令命名空间，重构 feature-* 为 ai:*，并移除冗余命令**
