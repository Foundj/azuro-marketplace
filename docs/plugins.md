# 插件

> 来源: https://code.claude.com/docs/zh-CN/plugins

通过插件系统使用自定义命令、代理、钩子、技能和 MCP 服务器扩展 Claude Code。

有关完整的技术规范和架构，请参阅[插件参考](./plugins-reference.md)。有关市场管理，请参阅[插件市场](./plugin-marketplaces.md)。

插件让您能够使用可在项目和团队中共享的自定义功能来扩展 Claude Code。从市场安装插件以添加预构建的命令、代理、钩子、技能和 MCP 服务器，或创建您自己的插件来自动化您的工作流。

## 快速入门

### 前置条件

- 在您的机器上安装了 Claude Code
- 对命令行工具的基本熟悉

### 创建您的第一个插件

#### 1. 创建市场结构

```bash
mkdir test-marketplace
cd test-marketplace
```

#### 2. 创建插件目录

```bash
mkdir my-first-plugin
cd my-first-plugin
```

#### 3. 创建插件清单

创建 `.claude-plugin/plugin.json`:

```bash
mkdir .claude-plugin
cat > .claude-plugin/plugin.json << 'EOF'
{
  "name": "my-first-plugin",
  "description": "A simple greeting plugin to learn the basics",
  "version": "1.0.0",
  "author": {
    "name": "Your Name"
  }
}
EOF
```

#### 4. 添加自定义命令

创建 `commands/hello.md`:

```bash
mkdir commands
cat > commands/hello.md << 'EOF'
---
description: Greet the user with a personalized message
---

# Hello Command

Greet the user warmly and ask how you can help them today. Make the greeting personal and encouraging.
EOF
```

#### 5. 创建市场清单

创建 `marketplace.json`:

```bash
cd ..
mkdir .claude-plugin
cat > .claude-plugin/marketplace.json << 'EOF'
{
  "name": "test-marketplace",
  "owner": {
    "name": "Test User"
  },
  "plugins": [
    {
      "name": "my-first-plugin",
      "source": "./my-first-plugin",
      "description": "My first test plugin"
    }
  ]
}
EOF
```

#### 6. 安装并测试您的插件

从父目录启动 Claude Code:

```bash
cd ..
claude
```

添加测试市场:

```
/plugin marketplace add ./test-marketplace
```

安装您的插件:

```
/plugin install my-first-plugin@test-marketplace
```

选择"立即安装"。然后您需要重新启动 Claude Code 以使用新插件。

尝试您的新命令:

```
/hello
```

### 插件结构概览

您的插件遵循以下基本结构：

```
my-first-plugin/
├── .claude-plugin/
│   └── plugin.json          # 插件元数据
├── commands/                 # 自定义斜杠命令（可选）
│   └── hello.md
├── agents/                   # 自定义代理（可选）
│   └── helper.md
├── skills/                   # 代理技能（可选）
│   └── my-skill/
│       └── SKILL.md
└── hooks/                    # 事件处理程序（可选）
    └── hooks.json
```

**您可以添加的其他组件：**

- **命令**：在 `commands/` 目录中创建 markdown 文件
- **代理**：在 `agents/` 目录中创建代理定义
- **技能**：在 `skills/` 目录中创建 `SKILL.md` 文件
- **钩子**：为事件处理创建 `hooks/hooks.json`
- **MCP 服务器**：为外部工具集成创建 `.mcp.json`

## 安装和管理插件

### 前置条件

- Claude Code 已安装并运行
- 对命令行界面的基本熟悉

### 添加市场

市场是可用插件的目录。添加它们以发现和安装插件：

```bash
# 添加市场
/plugin marketplace add your-org/claude-plugins

# 浏览可用插件
/plugin
```

### 安装插件

#### 通过交互式菜单（推荐用于发现）

```bash
# 打开插件管理界面
/plugin
```

选择"浏览插件"以查看可用选项及其描述、功能和安装选项。

#### 通过直接命令（用于快速安装）

```bash
# 安装特定插件
/plugin install formatter@your-org

# 启用已禁用的插件
/plugin enable plugin-name@marketplace-name

# 禁用而不卸载
/plugin disable plugin-name@marketplace-name

# 完全删除插件
/plugin uninstall plugin-name@marketplace-name
```

### 验证安装

安装插件后：

1. **检查可用命令**：运行 `/help` 以查看新命令
2. **测试插件功能**：尝试插件的命令和功能
3. **查看插件详情**：使用 `/plugin` → "管理插件"以查看插件提供的内容

## 设置团队插件工作流

在存储库级别配置插件以确保整个团队的工具一致。当团队成员信任您的存储库文件夹时，Claude Code 会自动安装指定的市场和插件。

**设置团队插件：**

1. 将市场和插件配置添加到您的存储库的 `.claude/settings.json`
2. 团队成员信任存储库文件夹
3. 为所有团队成员自动安装插件

## 开发更复杂的插件

### 向您的插件添加技能

插件可以包含代理技能以扩展 Claude 的功能。技能是由模型调用的——Claude 根据任务上下文自主使用它们。

要向您的插件添加技能，请在您的插件根目录创建一个 `skills/` 目录，并添加包含 `SKILL.md` 文件的技能文件夹。插件技能在安装插件时自动可用。

### 组织复杂的插件

对于具有许多组件的插件，按功能组织您的目录结构。

### 在本地测试您的插件

开发插件时，使用本地市场来迭代测试更改。

#### 1. 设置您的开发结构

```bash
mkdir dev-marketplace
cd dev-marketplace
mkdir my-plugin
```

这将创建：

```
dev-marketplace/
├── .claude-plugin/marketplace.json  (您将创建此文件)
└── my-plugin/                        (您正在开发的插件)
    ├── .claude-plugin/plugin.json
    ├── commands/
    ├── agents/
    └── hooks/
```

#### 2. 创建市场清单

```bash
mkdir .claude-plugin
cat > .claude-plugin/marketplace.json << 'EOF'
{
  "name": "dev-marketplace",
  "owner": {
    "name": "Developer"
  },
  "plugins": [
    {
      "name": "my-plugin",
      "source": "./my-plugin",
      "description": "Plugin under development"
    }
  ]
}
EOF
```

#### 3. 安装并测试

```bash
cd ..
claude
```

```
/plugin marketplace add ./dev-marketplace
/plugin install my-plugin@dev-marketplace
```

#### 4. 迭代您的插件

对您的插件代码进行更改后：

```
/plugin uninstall my-plugin@dev-marketplace
/plugin install my-plugin@dev-marketplace
```

### 调试插件问题

如果您的插件无法按预期工作：

1. **检查结构**：确保您的目录位于插件根目录，而不是在 `.claude-plugin/` 内
2. **单独测试组件**：分别检查每个命令、代理和钩子
3. **使用验证和调试工具**：使用 `claude --debug` 查看插件加载详情

### 共享您的插件

当您的插件准备好共享时：

1. **添加文档**：包含一个 README.md，其中包含安装和使用说明
2. **版本化您的插件**：在您的 `plugin.json` 中使用语义版本控制
3. **创建或使用市场**：通过插件市场分发以便于安装
4. **与他人测试**：在更广泛分发之前让团队成员测试插件

## 后续步骤

### 对于插件用户

- **发现插件**：浏览社区市场以查找有用的工具
- **团队采用**：为您的项目设置存储库级别的插件
- **市场管理**：学习管理多个插件源
- **高级用法**：探索插件组合和工作流

### 对于插件开发者

- **创建您的第一个市场**：[插件市场指南](./plugin-marketplaces.md)
- **高级组件**：深入了解特定的插件组件：
  - 斜杠命令 - 命令开发详情
  - 子代理 - 代理配置和功能
  - 代理技能 - 扩展 Claude 的功能
  - 钩子 - 事件处理和自动化
  - MCP - 外部工具集成

### 对于团队主管和管理员

- **存储库配置**：为团队项目设置自动插件安装
- **插件治理**：建立插件批准和安全审查的指南
- **市场维护**：创建和维护组织特定的插件目录
- **培训和文档**：帮助团队成员有效地采用插件工作流

## 另请参阅

- [插件市场](./plugin-marketplaces.md) - 创建和管理插件目录
- [插件参考](./plugins-reference.md) - 完整的技术规范
