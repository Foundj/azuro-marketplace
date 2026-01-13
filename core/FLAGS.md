# FLAGS.md - 行为标记系统

> 统一的命令行为修饰符，控制 AI 的执行模式和思考深度。

## 概述

Flags 是附加在命令后的修饰符，用于改变 AI 的行为模式。格式：`命令 --flag`

```bash
/ai:dev implement auth --think       # 深度思考模式
/fix login bug --quick               # 快速修复模式
/brainstorm new feature --ultrathink # 最大思考预算
```

## 可用 Flags

### 思考深度

| Flag | 别名 | 描述 | Token 预算 |
|------|------|------|------------|
| `--think` | `--深度`, `--考虑`, `--分析`, `-t` | 扩展思考，考虑多个方案 | 2x 标准 |
| `--ultrathink` | `--好好思考`, `--好好想想`, `--认真想`, `-ut` | 最大思考预算，适合复杂决策 | 5x 标准 |
| `--quick` | `--快速`, `--赶紧`, `-q` | 最小思考，快速执行 | 0.5x 标准 |

### 执行模式

| Flag | 别名 | 描述 | 行为 |
|------|------|------|------|
| `--parallel` | `--并行`, `-p` | 并行执行多个任务 | 启用 Wave 模式 |
| `--sequential` | `--顺序`, `-s` | 严格顺序执行 | 禁用并行 |
| `--safe` | `--安全`, `--dry-run` | 安全模式，只分析不修改 | 只读操作 |

### 输出控制

| Flag | 别名 | 描述 | 行为 |
|------|------|------|------|
| `--verbose` | `--详细`, `-v` | 详细输出 | 显示完整过程 |
| `--quiet` | `--静默`, `-Q` | 最小输出 | 只显示结果 |
| `--explain` | `--解释`, `-e` | 解释每个决策 | 教学模式 |

### 工作流控制

| Flag | 别名 | 描述 | 行为 |
|------|------|------|------|
| `--skip-research` | `--跳过调研` | 跳过竞品研究阶段 | Phase 0.5 跳过 |
| `--skip-review` | `--跳过审查` | 跳过代码审查 | Phase 5 简化 |
| `--force` | `--强制`, `-f` | 强制执行，跳过确认 | 减少交互 |
| `--interactive` | `--交互`, `-i` | 增加交互确认点 | 更多用户参与 |

### 探索模式

| Flag | 别名 | 描述 | 行为 |
|------|------|------|------|
| `--brainstorm` | `--头脑风暴`, `-b` | 启用发散探索 | 苏格拉底式提问 |
| `--research` | `--调研`, `--参考`, `-r` | 深度调研模式 | 多源信息收集 |
| `--explore` | `--熟悉`, `--好好熟悉`, `--学习` | 探索代码库 | 彻底了解项目 |

## 组合使用

Flags 可以组合使用：

```bash
# 深度思考 + 详细输出
/ai:dev design architecture --think --verbose

# 快速修复 + 安全模式（只分析）
/fix bug --quick --safe

# 并行执行 + 跳过调研
/ai:dev implement feature --parallel --skip-research

# 最大思考 + 解释模式
/ai:dev plan migration --ultrathink --explain
```

## Flag 优先级

当 flags 冲突时，按以下优先级解决：

1. 安全相关 (`--safe`) 最高优先级
2. 显式指定优先于默认
3. 后出现的覆盖先出现的

```bash
# --safe 优先，不会修改文件
/fix bug --force --safe

# --ultrathink 覆盖 --quick
/ai:dev feature --quick --ultrathink
```

## 默认 Flag 配置

在 `codebox/config.json` 中配置默认 flags：

```json
{
  "flags": {
    "defaults": {
      "ai:dev": ["--think"],
      "fix": ["--quick"],
      "brainstorm": ["--verbose"]
    },
    "aliases": {
      "--深思熟虑": "--ultrathink",
      "--全力": "--parallel"
    }
  }
}
```

## 自动检测

某些关键词自动触发对应 flags：

| 关键词 | 自动 Flag | 说明 |
|--------|-----------|------|
| `design`, `architect`, `设计`, `架构` | `--think` | 需要深度思考 |
| `fix`, `patch`, `修复`, `修补` | `--quick` | 快速修复 |
| `好好思考`, `好好想想`, `认真考虑`, `think through` | `--ultrathink` | 最大思考预算 |
| `快速`, `赶紧`, `urgent`, `asap` | `--quick` | 快速执行 |
| `全力`, `parallel`, `并行` | `--parallel` | 并行执行 |
| `优化`, `重构`, `简化`, `refactor` | code-simplifier | 代码优化 |
| `参考`, `知识`, `经验`, `history` | knowledge-graph | 查询知识库 |
| `问题`, `调试`, `debug`, `为什么` | debugger | 调试模式 |
| `熟悉`, `学习`, `了解`, `explore` | Explore agent | 探索代码库 |
| `需求`, `要求`, `requirement` | ai-dev-interview | 需求访谈 |
| `实现`, `开发`, `implement` | ai-dev | 开发工作流 |

## 与命令集成

### ai-dev 命令

```bash
/ai:dev implement auth
  ├── 默认: 标准 7 阶段流程
  ├── --think: Phase 2 使用扩展思考
  ├── --ultrathink: 所有阶段最大思考预算
  ├── --quick: 跳过 Phase 0.5, 1, 简化其他阶段
  └── --parallel: Phase 4 使用 Wave 并行执行
```

### fix 命令

```bash
/fix login bug
  ├── 默认: 快速修复流程
  ├── --think: 深度分析后修复
  ├── --safe: 只分析不修改
  └── --explain: 解释每个修复步骤
```

### brainstorm 命令

```bash
/brainstorm new feature
  ├── 默认: 发散探索
  ├── --think: 每个方向深入思考
  ├── --quick: 快速头脑风暴
  └── --verbose: 记录所有想法
```

## 实现说明

Flags 通过 `hooks/scripts/keyword-detector.sh` 检测：

```bash
# 检测 flags 并设置环境变量
if [[ "$*" =~ --think|--深度|-t ]]; then
  export AI_THINK_MODE="extended"
fi

if [[ "$*" =~ --ultrathink|--好好思考|-ut ]]; then
  export AI_THINK_MODE="ultra"
fi

if [[ "$*" =~ --safe|--安全|--dry-run ]]; then
  export AI_SAFE_MODE="true"
fi
```

## 最佳实践

1. **简单任务不需要 flags** - 默认行为通常足够
2. **复杂决策用 `--think`** - 架构、设计、重大重构
3. **紧急修复用 `--quick`** - 生产问题、简单 bug
4. **不确定时用 `--safe`** - 先分析再决定
5. **学习时用 `--explain`** - 理解 AI 的决策过程
