---
name: ai:knowledge
description: Query project knowledge graph to discover related knowledge and solutions
argument-hint: "[query] [add] [stats]"
allowed-tools: Bash, Read, Grep
---


# /ai:knowledge

加载 `knowledge-graph` skill，执行知识查询。

## 使用方式

```bash
/ai:knowledge              # 显示当前项目的所有知识
/ai:knowledge auth         # 搜索认证相关知识
/ai:knowledge similar      # 查找相似项目
/ai:knowledge add          # 添加新知识（交互式）
```

## 执行流程

1. 检查 `.claude-project/knowledge/` 是否存在
2. 如果不存在，初始化知识图谱
3. 根据查询参数搜索知识
4. 显示匹配结果

## 输出格式

```
[Knowledge Graph] Searching: auth

[solution] JWT 认证实现
  Project: user-portal
  Tags: auth, jwt, security
  Description: 完整的 JWT 认证流程

[error] CORS 跨域问题
  Project: api-gateway
  Tags: cors, security
  Description: Next.js API Routes CORS 配置
```

## 添加知识

当用户请求添加知识时，引导用户提供：
- 类型: solution / error / decision / pattern
- 标题
- 描述
- 标签（逗号分隔）

然后调用脚本：
```bash
${CLAUDE_PLUGIN_ROOT}/skills/knowledge-graph/scripts/graph-manager.sh add . <type> "<title>" "<description>" "<tags>"
```

## 统计信息

```bash
/ai:knowledge stats
```

显示知识图谱统计：节点数、关系数、类型分布。
