# AI-Dev v3.0 Quick Start Guide

> **5分钟快速上手** - 学会使用 ai-dev 的 7-Phase 工作流进行高质量开发

---

## 🎯 What is ai-dev v3.0?

**ai-dev** 是一个工业级 AI 开发编排系统，通过 7 个阶段的门控流程，确保：

- ✅ **智能需求采访**: 多轮提问 + 竞品调研，完全理解需求
- ✅ **项目上下文感知**: 检测重复功能、架构冲突、历史经验
- ✅ **自主完成**: OODA 循环自动实现，90%+ 任务无需干预
- ✅ **质量保证**: 仅显示 ≥80 置信度问题，过滤噪音
- ✅ **跨会话恢复**: 随时中断和恢复开发

---

## ⚡ 3分钟快速开始

### 步骤1: 初始化项目 (30秒)

```bash
# 在项目根目录
cd your-project

# 初始化 AI 开发模式
"init project 用户管理系统"
```

**系统会自动创建**:
```
codebox/                    # AI 配置目录
├── config.json             # 项目配置
├── requirements.md         # 全局需求
├── design.md               # 架构约束
├── CLAUDE.md               # AI 行为规则
├── project-snapshot.json   # 深度扫描结果
├── knowledge/              # 知识库
├── research/               # 竞品调研
└── changes/                # 变更管理
```

### 步骤2: 启动功能开发 (5秒)

```bash
# 直接说出需求
"ai implement 用户登录功能"
```

**ai-dev 会自动**:
1. 🔍 扫描项目上下文（检测重复、冲突）
2. 📊 调研竞品（Gemini 搜索 + Codex 分析）
3. 💬 多轮采访（带参考建议的提问）
4. 📝 生成 proposal.md
5. 请你审批

### 步骤3: 审批和完成 (1-2分钟)

**Phase 1 审批** (需求确认):
```
🚪 Phase 1 审批

需求采访完成，请确认：

📄 查看: codebox/changes/active/CHG-001/proposal.md

选项:
1. Yes - 继续 ✅
2. Refine - 修改
3. No - 取消
```

选择 `1. Yes` 后，系统会：
- ✅ 设计方案并请你选择（Phase 2）
- ✅ 自动拆解任务（Phase 3）
- ✅ OODA 自主实现（Phase 4）
- ✅ 质量验证 + 自动修复（Phase 5）
- ✅ 归档 + 更新知识库（Phase 6）

**完成！** 🎉

---

## 🔑 核心概念

### 7-Phase 工作流

| Phase | 名称 | 作用 | 用户参与 |
|-------|------|------|----------|
| 0 | Context & Knowledge | 上下文预加载 + 知识检查 | ❌ 自动 |
| 0.5 | Research | 竞品调研（新功能） | ❌ 自动/可跳过 |
| 1 | Requirement Interview | 多轮需求采访 | ✅ 回答问题 + 审批 |
| 2 | Design Approval | 设计方案选择 | ✅ 选择方案 |
| 3 | Task Breakdown | 任务拆解 | ❌ 自动 |
| 4 | OODA Implementation | 自主实现 | ❌ 自动 |
| 5 | Quality Validation | 代码审查 + 验证 | ✅ 决定修复 |
| 6 | Finalization | 归档 + 知识更新 | ❌ 自动 |

### 3 个审批门控

你只需要在 3 个关键点做决策：

1. **Phase 1**: 需求理解对不对？
2. **Phase 2**: 选哪个设计方案？
3. **Phase 5**: 如何处理发现的问题？

### 需求采访示例

```
Q1: 你想实现什么类型的登录？

💡 调研参考：
   分析 2,847 个 Next.js 项目：
   
   a) 邮箱/密码 (62% 采用)
   b) OAuth 第三方 (28% 采用)
   c) Magic Link (10% 采用)

⚠️ 项目上下文：
   codebox/design.md 要求使用 Repository 模式

📝 你的选择：
```

### OODA 自主完成

Phase 4 自动运行 **OODA 循环**：

```
Observe  → 检查当前状态
   ↓
Orient   → 决定下一步
   ↓
Decide   → 选择行动
   ↓
Act      → 执行并验证
   ↓
Loop     → 重复直到 <promise>DONE</promise>
```

**特点**:
- ✅ 自动写代码、跑测试、修 bug
- ✅ 测试失败自动重试
- ✅ 完成后自动标记 `<promise>DONE</promise>`

---

## 📋 常用命令

| 命令 | 描述 |
|------|------|
| `init project [名称]` | 初始化项目 |
| `ai [任务]` | 启动完整 7-phase 流程 |
| `dev [任务]` | `ai` 的别名 |
| `fix [问题]` | 快速修复 (<30分钟) |
| `/ai:dev [任务]` | 完整 7-phase 工作流 |
| `/research "功能"` | 手动竞品调研 |
| `/ai:status` | 查看当前进度 |

---

## 💡 使用技巧

### 1. 如何跳过调研？

```bash
# 简单修复不需要调研
"ai fix the login button bug"  # 自动跳过

# 或明确说明
"ai implement logout, skip research"
```

### 2. 如何查看进度？

```bash
# 查看当前任务
cat codebox/changes/active/CHG-001/tasks.md

# 查看状态
cat codebox/changes/active/CHG-001/state.json
```

### 3. 如何中断和恢复？

**随时中断**（按 Ctrl+C）:
- `state.json` 自动保存当前进度

**恢复开发**:
```bash
"continue"  # session-manager 自动恢复
```

### 4. 如何利用历史经验？

**第一次做某功能**:
- Phase 0 找不到相关 pattern
- Phase 6 自动记录到 `knowledge/patterns.json`

**第二次做类似功能**:
- Phase 0 自动找到历史 pattern
- 采访时提供参考建议
- 开发速度快 30-50%

---

## 📁 目录结构

```
codebox/                          # AI 配置目录
├── config.json                   # 项目配置
├── requirements.md               # 全局需求 (EARS)
├── design.md                     # 架构约束
├── CLAUDE.md                     # AI 行为规则
├── project-snapshot.json         # 项目扫描结果
├── feature_list.json             # 功能列表
│
├── knowledge/                    # 知识库
│   ├── patterns.json             # 成功模式
│   ├── errors.json               # 历史错误
│   └── learnings.md              # 经验总结
│
├── research/                     # 竞品调研
│   └── [feature]-research.json
│
└── changes/                      # 变更管理
    ├── active/[id]/              # 进行中
    │   ├── proposal.md           # 需求提案
    │   ├── design.md             # 设计文档
    │   ├── tasks.md              # 任务列表
    │   ├── phase0-context.md     # 上下文检查
    │   └── state.json            # 状态
    └── archived/YYYY-MM/         # 已归档
```

---

## ❓ 常见问题

**Q: 需求采访会不会太慢？**

A: 通常 2-5 个问题，每个问题提供参考选项，1-2 分钟完成。比起事后返工，这是值得的投入。

**Q: 竞品调研需要多久？**

A: Quick 模式 3-5 秒，Deep 模式 10-15 秒。新功能自动触发，简单修复跳过。

**Q: OODA 循环会不会卡住？**

A: 有多重保护：
- 最多 50 次迭代（通常 5-10 次完成）
- 完成后自动标记 `<promise>DONE</promise>`
- 可随时中断

**Q: 如何与团队共享？**

A: `codebox/` 目录可以 git 提交：
```bash
git add codebox/
git commit -m "chore: update project knowledge"
```

---

## 🚀 下一步

1. ✅ 阅读完本文档（你已经完成！）
2. 🧪 尝试 `init project` 初始化一个项目
3. 🎯 用 `ai implement` 开发第一个功能
4. 📚 查看详细参考: `references/7-phase-workflow.md`

---

**Quick Start 完成！** 🎉

开始使用：
```bash
init project 我的应用
ai implement 用户登录
```
