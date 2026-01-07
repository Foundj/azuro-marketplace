---
name: dev
description: Quick development command - implements features using ai-dev with optimal agent selection
allowed-tools: Task, Read, Grep, Glob
argument-hint: "<feature-description>"
---

# Dev Command - 快速开发命令

## 用途
快速启动功能开发，自动调用 ai-dev 选择最优 agents 并实施。

## 使用方法

### 基本语法
```bash
/dev <feature-description>
```

### 示例
```bash
/dev user login
/dev add search功能
/dev implement avatar upload
/dev 实现评论系统
```

## 实现逻辑

调用 ai-dev skill，自动：
1. 分析功能需求
2. 识别意图为 FEATURE_DEVELOPMENT
3. 选择最优 agents
4. 编排工作流并执行

## 等价于

```bash
"ai implement <feature-description>"
```

但更简洁，专门用于功能开发。

## 与其他命令的区别

- `/dev` - 功能开发（本命令）
- `/fix` - Bug 修复
- `/review` - 代码审查
- `/optimize` - 性能优化
