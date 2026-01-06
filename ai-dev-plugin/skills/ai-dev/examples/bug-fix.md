# 示例：快速 Bug 修复

## 场景
使用 `fix` 关键词快速修复登录按钮问题。

## 用户输入
```
fix 登录按钮点击没反应
```

## AI Orchestrator 处理流程

### 1. 关键词识别
```
触发词: fix
关键词: 登录, 按钮, 点击, 没反应
```

### 2. 意图分析
```
意图: BUG_FIXING
复杂度: SIMPLE (2/10)
紧急度: HIGH
预估时间: 30分钟
```

### 3. Agent 选择
```
候选 Agents 评分:
- quick-fixer: 0.95 ✅ (Primary) - 专门处理简单bug
- debugger: 0.65 ❌ (过重，适合复杂bug)
- test-automator: 0.70 ✅ (Supporting) - 验证修复

最终选择:
- Primary: quick-fixer
- Supporting: test-automator
```

### 4. 快速修复工作流
```
Phase 1: 问题诊断 (15分钟)
  - 定位登录按钮代码
  - 检查事件处理函数
  - 分析错误日志

Phase 2: 快速修复 (10分钟)
  - 修复问题代码
  - 限制: ≤50行, ≤3文件

Phase 3: 验证测试 (5分钟)
  - 手动测试
  - 运行相关单元测试
```

### 5. 修复结果
```
🔍 问题定位:
文件: src/components/LoginButton.tsx:23
原因: onClick 事件处理函数未绑定

❌ 错误代码:
<button onClick={handleLogin}>登录</button>
// handleLogin 未定义

✅ 修复代码:
<button onClick={handleLoginClick}>登录</button>
// 正确引用已定义的函数

📊 修复统计:
- 修改文件: 1
- 修改行数: 1
- 耗时: 8分钟
- 测试: ✅ 通过
```

## 关键点

- **快速响应**：`fix` 触发词优先选择 quick-fixer
- **时间限制**：30分钟内完成，避免过度工程
- **文件限制**：≤3文件，确保修改范围可控
- **立即验证**：修复后立即测试
