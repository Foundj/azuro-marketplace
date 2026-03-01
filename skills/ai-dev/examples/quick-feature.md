# 示例：快速功能开发

## 场景
使用简短触发词快速实现一个用户头像上传功能。

## 用户输入
```
ai 实现头像上传
```

## AI Orchestrator 处理流程

### 1. 关键词识别
```
触发词: ai, 实现
关键词: 头像, 上传
```

### 2. 意图分析
```
意图: FEATURE_DEVELOPMENT
复杂度: SIMPLE (3/10)
技术栈: React, Hono (从项目自动识别)
预估时间: 0.5天
```

### 3. Agent 选择
```
候选 Agents 评分:
- api-helper: 0.85 ✅ (Primary)
- frontend-developer: 0.82 ✅ (Supporting)
- code-reviewer: 0.90 ✅ (Mandatory)
- quick-fixer: 0.35 ❌ (能力不匹配)

最终选择:
- Primary: api-helper
- Supporting: frontend-developer
- Mandatory: code-reviewer
```

### 4. 工作流编排
```
Phase 1: 需求分析 (10% 时间)
  Agents: requirement-analyzer

Phase 2: 架构设计 (30% 时间)
  Agents: api-helper, frontend-developer (并行)

Phase 3: 实现开发 (40% 时间)
  Agents: api-helper, frontend-developer (并行)

Phase 4: 质量保障 (20% 时间)
  Agents: code-reviewer, test-automator (并行)
```

### 5. 执行结果
```
✅ 后端:
- 配置 multer 中间件
- 创建 /api/avatar/upload endpoint
- 添加文件验证（类型、大小）
- 存储到 uploads/ 目录

✅ 前端:
- 创建 AvatarUpload.tsx 组件
- 添加文件选择和预览
- 集成上传 API
- 错误处理和进度显示

✅ 质量检查:
- Code review: 8.5/10 (Good)
- 测试覆盖: 85%
- 无安全问题
```

## 关键点

- **简短触发词** `ai` 立即触发 orchestrator
- **自动分析**：无需手动选择 agents
- **并行执行**：前后端同时开发，提高效率
- **质量保证**：自动 code review
