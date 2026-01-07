---
name: ai:quality
description: 执行代码质量门禁检查，评估安全性、代码质量、文档和架构
---

# Quality Gate 快捷命令

根据用户参数执行质量门禁检查。

## 参数解析

- `$ARGUMENTS` 为空: 检查当前目录
- `$ARGUMENTS` 为路径: 检查指定目录
- `$ARGUMENTS` 包含 `json`: 输出 JSON 格式

## 执行流程

1. **加载 skill**: 加载 `quality-gate` skill 获取完整指导
2. **运行检查脚本**:
   ```bash
   bash ~/.claude/plugins/ai-dev-plugin/skills/quality-gate/scripts/quality-check.sh [path] [format]
   ```
3. **分析结果**: 根据评分提供改进建议

## 评分维度

| 维度 | 权重 | 阈值 |
|------|------|------|
| 🔒 安全性 | 40% | 85 |
| 📝 代码质量 | 30% | 60 |
| 📖 文档 | 20% | 50 |
| 🏗️ 架构 | 10% | 50 |

**总分阈值**: 70/100

## 示例用法

```
/ai:quality                    # 检查当前目录
/ai:quality ./src              # 检查 src 目录
/ai:quality . json             # JSON 格式输出
```

## 执行

请立即运行质量检查脚本，路径参数: `$ARGUMENTS` (默认为 `.`)
