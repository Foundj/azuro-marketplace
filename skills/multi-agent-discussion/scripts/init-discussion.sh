#!/usr/bin/env bash
# 初始化讨论目录结构
# 用法: bash init-discussion.sh <project-root> <topic-name> [max-rounds]

set -euo pipefail

PROJECT_ROOT="${1:?用法: init-discussion.sh <project-root> <topic-name> [max-rounds]}"
TOPIC="${2:?请提供讨论主题名称（kebab-case）}"
MAX_ROUNDS="${3:-3}"
DISCUSSION_DIR="${PROJECT_ROOT}/docs/discussions/${TOPIC}"

if [ -d "${DISCUSSION_DIR}" ]; then
  echo "错误: 讨论目录已存在: ${DISCUSSION_DIR}"
  echo "如需重新初始化，请先删除该目录。"
  exit 1
fi

# 创建目录结构
mkdir -p "${DISCUSSION_DIR}"/{refs,continue}

# 生成 README.md
cat > "${DISCUSSION_DIR}/README.md" << 'HEREDOC'
# 讨论规则

## 概述

本目录是一个跨 AI 工具的需求讨论空间。多个 AI 编码工具（Claude Code、Cursor、Codex 等）以不同专家角色在 `discussion.md` 中进行结构化讨论。

## 参与角色

| 角色 | 代号 | 职责 | 工具 |
|------|------|------|------|
| （初始化时填充） | | | |

## 讨论规则

1. **先读后写**：发言前必须阅读所有已有内容
2. **追加模式**：只在 `discussion.md` 末尾追加，禁止修改他人发言
3. **格式规范**：使用规定的发言格式（见下方语法说明）
4. **@ 响应优先**：被 @ 提及时优先回应该议题
5. **更新状态**：发言后更新顶部 STATUS 面板

## 收敛规则

- **最大讨论轮次**：MAX_ROUNDS 轮
- **草案轮次**：1 轮提议 + 1 轮审阅
- **共识检测**：当所有 agent 的决策倾向一致时，可提前进入草案阶段
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
| `discussion.md` | 主讨论文档 |
| `context.md` | 项目背景资料 |
| `refs/` | 附件目录 |
| `continue/` | 续接提示词 |
HEREDOC

# 替换 MAX_ROUNDS 占位符
sed -i '' "s/MAX_ROUNDS/${MAX_ROUNDS}/g" "${DISCUSSION_DIR}/README.md" 2>/dev/null || \
sed -i "s/MAX_ROUNDS/${MAX_ROUNDS}/g" "${DISCUSSION_DIR}/README.md"

# 生成 discussion.md
cat > "${DISCUSSION_DIR}/discussion.md" << HEREDOC
<!-- STATUS
round: 1
pending: (待填充)
completed:
mentions:
phase: discuss
max_rounds: ${MAX_ROUNDS}
-->

# ${TOPIC} — 需求讨论

> 创建时间: $(date '+%Y-%m-%d %H:%M')
> 参与者: （见 README.md 角色表）
> 状态: 讨论中

---

<!-- 在此行下方追加发言 -->
HEREDOC

# 生成 context.md
cat > "${DISCUSSION_DIR}/context.md" << HEREDOC
# 项目背景

> 请填充以下信息，帮助讨论参与者理解项目上下文。

## 技术栈

（描述项目使用的技术栈）

## 现有架构

（描述与本次讨论相关的现有系统架构）

## 业务背景

（描述业务需求和目标用户）

## 约束条件

（列出时间、技术、资源等约束）
HEREDOC

# 生成续接提示词
for round in $(seq 2 $((MAX_ROUNDS + 1))); do
  cat > "${DISCUSSION_DIR}/continue/round-${round}-all.md" << HEREDOC
请继续参与 docs/discussions/${TOPIC}/discussion.md 的第 ${round} 轮讨论。

操作：
1. 读取 docs/discussions/${TOPIC}/discussion.md 最新内容
2. 检查 STATUS 面板中指向你的 @ 提及
3. 回应所有 @ 提到你的议题
4. 在文件末尾追加你的 Round ${round} 发言（使用 README.md 中规定的格式）
5. 更新 STATUS 面板（将自己从 pending 移至 completed）
HEREDOC
done

# 生成草案轮续接提示词
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

echo "讨论空间已创建: ${DISCUSSION_DIR}"
echo ""
echo "目录结构:"
echo "  ${DISCUSSION_DIR}/"
echo "  ├── README.md"
echo "  ├── discussion.md"
echo "  ├── context.md"
echo "  ├── refs/"
echo "  └── continue/"
for f in "${DISCUSSION_DIR}/continue/"*.md; do
  echo "      ├── $(basename "$f")"
done
echo ""
echo "下一步: 生成邀请提示词并分发给各 AI 工具。"
