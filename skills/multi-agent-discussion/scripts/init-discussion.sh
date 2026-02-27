#!/usr/bin/env bash
# 初始化讨论目录结构
# 用法: bash init-discussion.sh <project-root> <topic-name> [max-rounds]
#
# 注意: 此脚本仅负责目录骨架创建。角色填充、context.md 自动填充、
# Round 0 种子发言、邀请文件生成均由 Claude Code 在 SKILL.md 工作流中完成。

set -euo pipefail

PROJECT_ROOT="${1:?用法: init-discussion.sh <project-root> <topic-name> [max-rounds]}"
TOPIC="${2:?请提供讨论主题名称（kebab-case）}"
MAX_ROUNDS="${3:-3}"
DISCUSSION_DIR="${PROJECT_ROOT}/docs/discussions/${TOPIC}"

# 验证 project-root 存在
if [ ! -d "${PROJECT_ROOT}" ]; then
  echo "错误: 项目根目录不存在: ${PROJECT_ROOT}"
  exit 1
fi

if [ -d "${DISCUSSION_DIR}" ]; then
  echo "错误: 讨论目录已存在: ${DISCUSSION_DIR}"
  echo "如需重新初始化，请先删除该目录。"
  exit 1
fi

# 创建目录结构
mkdir -p "${DISCUSSION_DIR}"/{refs,continue}

# 跨平台 sed -i 兼容函数
sed_inplace() {
  if [[ "$OSTYPE" == "darwin"* ]]; then
    sed -i '' "$@"
  else
    sed -i "$@"
  fi
}

# 生成 README.md
cat > "${DISCUSSION_DIR}/README.md" << 'HEREDOC'
# 讨论规则

## 概述

本目录是一个跨 AI 工具的需求讨论空间。多个 AI 编码工具（Claude Code、Cursor、Codex 等）以不同专家角色在 `discussion.md` 中进行结构化讨论。Claude Code 以 @Coordinator 身份提供项目分析种子并协调流程。

## 参与角色

| 角色 | 代号 | 职责 | 工具 |
|------|------|------|------|
| 协调者 | @Coordinator | 项目分析、流程调度、汇总产出 | Claude Code |
| （其他角色由初始化时填充） | | | |

## 讨论规则

1. **先读后写**：发言前必须阅读所有已有内容（包括 Round 0 种子发言）
2. **追加模式**：只在 `discussion.md` 末尾追加，禁止修改他人发言
3. **格式规范**：使用规定的发言格式（见下方语法说明）
4. **@ 响应优先**：被 @ 提及时优先回应该议题
5. **更新状态**：发言后更新顶部 STATUS 面板
6. **完成后提示**：发言完毕后，打印下一步操作指引（哪个文件→哪个工具）

## 收敛规则

- **最大讨论轮次**：MAX_ROUNDS 轮（不含 Round 0 种子）
- **快速路径**：当所有 agent 的决策倾向一致（均标记 `#consensus`）时，可跳过草案直接汇总
- **超时调停**：超过最大轮次仍无共识时，Claude Code 介入调停

## Markdown 增强语法

### 发言格式

```markdown
## [Round N] @角色名 — 工具名
> 时间: YYYY-MM-DD HH:mm

### 分析
（正文）

### 建议
（方案提议）

### 关注点
（风险和待确认事项）

### 决策倾向
- [x] 方案 A #consensus
- [ ] 方案 B #pending

---
```

### @ 提及

| 语法 | 含义 |
|------|------|
| `@角色名` | 提及特定角色 |
| `@all` | 提及全体 |
| `@角色名 Round N` | 引用特定轮次发言 |

### Callout 类型

| Callout | 用途 |
|---------|------|
| `> [!analysis]` | 分析洞察 |
| `> [!proposal]` | 方案提案 |
| `> [!question]` | 提问 |
| `> [!warning]` | 风险提示 |
| `> [!decision]` | 决策记录 |
| `> [!quote] @角色 Round N` | 引用 |
| `> [!todo]` | 待办 |

### 标签

| 标签 | 含义 |
|------|------|
| `#consensus` | 已达成共识 |
| `#pending` | 待讨论 |
| `#rejected` | 已否决 |
| `#needs-input` | 需要输入 |
| `#blocker` | 阻塞项 |

### 引用语法

- `> [!quote] @角色 Round N` — 引用发言
- `[[context.md#章节]]` — 引用项目上下文
- `[[refs/文件名]]` — 引用附件
- `` `src/file.ts:行号` `` — 引用代码

## 文件说明

| 文件 | 用途 |
|------|------|
| `README.md` | 本文件，讨论规则 |
| `discussion.md` | 主讨论文档（含 Round 0 种子） |
| `context.md` | 项目背景资料（自动填充） |
| `invite-*.md` | 各角色邀请文件 |
| `refs/` | 附件目录 |
| `continue/` | 续接提示词 |
HEREDOC

# 替换 MAX_ROUNDS 占位符
sed_inplace "s/MAX_ROUNDS/${MAX_ROUNDS}/g" "${DISCUSSION_DIR}/README.md"

# 生成 discussion.md（STATUS 面板 + 标题，Round 0 由 Claude Code 追加）
cat > "${DISCUSSION_DIR}/discussion.md" << HEREDOC
<!-- STATUS
round: 0
pending: @Coordinator
completed:
mentions:
phase: init
max_rounds: ${MAX_ROUNDS}
-->

# ${TOPIC} — 需求讨论

> 创建时间: $(date '+%Y-%m-%d %H:%M')
> 参与者: （见 README.md 角色表）
> 状态: 初始化中

---

<!-- Round 0 种子发言由 Claude Code 追加 -->
HEREDOC

# 生成 context.md 骨架（Claude Code 将自动填充具体内容）
cat > "${DISCUSSION_DIR}/context.md" << HEREDOC
# 项目背景

> 此文件由 Claude Code 自动填充。如需补充信息，可直接编辑。

## 技术栈

（自动填充）

## 架构概览

（自动填充）

## 关键数据指标

（自动填充）

## 约束条件

（自动填充）
HEREDOC

# 生成草案和审阅续接提示词（通用的，不依赖角色）
cat > "${DISCUSSION_DIR}/continue/draft.md" << HEREDOC
讨论已进入草案阶段。请阅读 docs/discussions/${TOPIC}/discussion.md 的所有讨论内容。

操作：
1. 读取完整讨论记录
2. 综合所有角色的观点和 #consensus 决策
3. 在文件末尾追加 [Draft v1] 格式的草案
4. 更新 STATUS 面板中的 phase 为 draft
HEREDOC

cat > "${DISCUSSION_DIR}/continue/review.md" << HEREDOC
草案已提出，请进行审阅。读取 docs/discussions/${TOPIC}/discussion.md。

操作：
1. 读取完整内容，找到最新的 [Draft vN] 草案
2. 在文件末尾追加 [Draft vN Review] 格式的审阅意见
3. 更新 STATUS 面板
HEREDOC

# 注意：角色专属的 round-N-role-tool.md 续接文件
# 由 Claude Code 在 /discuss next 时动态生成，
# 因为它们需要包含上一轮的 @ 提及上下文。
# 此脚本不生成通用的 round-N-all.md（已证明无用）。

echo "讨论空间已创建: ${DISCUSSION_DIR}"
echo ""
echo "目录结构:"
echo "  ${DISCUSSION_DIR}/"
echo "  ├── README.md        # 讨论规则"
echo "  ├── discussion.md    # 主讨论文档（待 Round 0 种子）"
echo "  ├── context.md       # 项目背景（待自动填充）"
echo "  ├── refs/"
echo "  └── continue/"
echo "      ├── draft.md"
echo "      └── review.md"
echo ""
echo "下一步: Claude Code 将自动填充 context.md、追加 Round 0 种子、生成邀请文件。"
