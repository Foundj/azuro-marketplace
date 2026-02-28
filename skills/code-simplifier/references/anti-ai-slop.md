# Anti-AI-Slop Principles

> 避免生成可预测、通用的「AI 味」代码

## 什么是 AI Slop？

AI Slop 是指 AI 生成的代码虽然「正确」，但缺乏个性，充满可预测的模式：

```
🔴 AI Slop 特征:
- 过度注释 (注释比代码还多)
- 过度抽象 (一次性逻辑也封装)
- 过度防御 (不可能的场景也处理)
- 通用命名 (dataHandler, processItem)
- 模板化结构 (每个函数都一样的格式)
```

## Anti-Slop 原则

### 1. 上下文适配 (Context-Aware)

```yaml
原则: 代码风格应匹配项目既有风格
检测:
  - 与周围代码风格不一致
  - 使用项目未采用的模式
修复:
  - 读取 CLAUDE.md 了解项目风格
  - 参考临近代码的写法
```

### 2. 注释克制 (Comment Restraint)

```yaml
原则: 代码应自解释，注释只用于「为什么」不是「是什么」
检测:
  - 解释显而易见的代码
  - 注释重复函数/变量名
修复:
  - 删除冗余注释
  - 用更好的命名替代注释
```

**反例**:
```typescript
// ❌ 过度注释
// Get the user by ID
async function getUserById(id: string) {
  // Make API call to get user
  const response = await fetch(`/api/users/${id}`);
  // Parse the response as JSON
  return response.json();
}

// ✅ 简洁
async function getUserById(id: string) {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}
```

### 3. 抽象必要性 (Abstraction Necessity)

```yaml
原则: 只在有复用需求时抽象，三次规则
检测:
  - 单次使用的工具函数
  - 只有一个实现的接口
修复:
  - 删除不必要的抽象
  - 内联只用一次的函数
```

### 4. 错误处理适度 (Error Handling)

```yaml
原则: 只处理可能发生的错误
检测:
  - 内部代码的防御性检查
  - 不可能的 null 检查
修复:
  - 信任内部代码
  - 只在边界验证
```

### 5. 命名具体化 (Specific Naming)

```yaml
原则: 命名应反映具体用途，不是通用动作
检测:
  - dataHandler, processItem, executeAction
  - manager, service, helper (无具体语义)
修复:
  - 使用领域术语
  - 描述具体行为
```

## Anti-Slop 检查清单

| 问题 | 检测方法 |
|------|----------|
| 过度注释 | 注释行数 > 代码行数 20% |
| 过度抽象 | 函数只被调用一次 |
| 过度防御 | 内部函数有参数验证 |
| 通用命名 | 包含 data/handler/manager/process |
| 模板化 | 每个函数格式完全一样 |

## 与项目风格对齐

简化代码时，**必须**先读取项目的：

1. `CLAUDE.md` - 了解编码规范
2. 邻近文件 - 了解既有风格
3. 测试文件 - 了解预期行为

生成的代码应该看起来像是「由项目现有开发者写的」，而不是「由 AI 生成的」。