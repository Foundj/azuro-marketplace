---
name: progress
description: Quick project progress shortcut - display status and health check for long-running projects
argument-hint: "[--detailed]"
allowed-tools: Read, Bash, Grep
---

# Progress Command - 项目进度命令

## 用途
快速查看长运行项目的当前进度、状态和健康信息。本命令是 `/ai:status` 的快捷别名。

**注意**：使用 `/progress` 而非 `/status`（避免与 Claude Code 系统命令冲突）

## 使用方法

### 基本语法
```bash
/progress              # 基本进度
/progress --detailed   # 详细进度
```

## 显示信息

### 基本模式
```
📊 Project Status
==================
Project: my-app
Total Features: 150
Completed: 42 (28%)
In Progress: Feature #43
Remaining: 108
Estimated Time: 15 days

📁 File Health
progress.txt: 856 lines (✅ healthy)
feature_list.json: 150 features (✅ healthy)

🔄 Git Status
Branch: main
Clean: ✅
Last Commit: feat: #42 implement user profile

📋 Next Steps
Recommended: Feature #43 "用户可以上传头像"
```

### 详细模式 (--detailed)
额外显示：
- 最近 5 个完成的特性
- 按类别统计进度
- 依赖关系检查
- 测试覆盖率
- 质量指标
- 归档文件列表

## 实现方式

Read `codebox/` 目录下的文件：
1. `feature_list.json` - 特性统计
2. `progress.txt` - 最近进度
3. `config.json` - 项目配置
4. Git log - 最近提交

生成格式化报告。

## 何时使用

- 新 session 开始时，了解项目状态
- 完成几个特性后，查看进度
- 向团队汇报项目进展
- 检查项目健康状况
