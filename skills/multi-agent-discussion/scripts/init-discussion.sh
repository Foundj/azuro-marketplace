#!/usr/bin/env bash
# 初始化讨论目录结构
# 用法: bash init-discussion.sh <project-root> <topic-name> [max-rounds] [--preset <preset>]
#
# 支持的预设:
#   product-discovery    — @PM + @UserAdvocate + @Architect + @Critic
#   architecture-design  — @Architect + @Backend + @Security + @Critic
#   full-review          — @PM + @Architect + @Frontend + @Backend + @QA
#   security-audit       — @Architect + @Security + @Backend + @DevOps
#
# 注意: 此脚本仅负责目录骨架创建。角色填充、context.md 自动填充、
# Round 0 种子发言、邀请文件生成均由 Claude Code 在 SKILL.md 工作流中完成。

set -euo pipefail

# 解析参数
PROJECT_ROOT=""
TOPIC=""
MAX_ROUNDS="3"
PRESET=""

while [ $# -gt 0 ]; do
  case "$1" in
    --preset)
      PRESET="${2:?--preset 需要指定预设名称}"
      shift 2
      ;;
    --preset=*)
      PRESET="${1#--preset=}"
      shift
      ;;
    *)
      if [ -z "$PROJECT_ROOT" ]; then
        PROJECT_ROOT="$1"
      elif [ -z "$TOPIC" ]; then
        TOPIC="$1"
      else
        MAX_ROUNDS="$1"
      fi
      shift
      ;;
  esac
done

# 验证必需参数
if [ -z "$PROJECT_ROOT" ]; then
  echo "用法: init-discussion.sh <project-root> <topic-name> [max-rounds] [--preset <preset>]"
  exit 1
fi

if [ -z "$TOPIC" ]; then
  echo "请提供讨论主题名称（kebab-case）"
  exit 1
fi

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

# 根据预设确定角色列表
ROLES_DISPLAY=""
case "$PRESET" in
  product-discovery)
    ROLES_DISPLAY="@PM, @UserAdvocate, @Architect, @Critic"
    ;;
  architecture-design)
    ROLES_DISPLAY="@Architect, @Backend, @Security, @Critic"
    ;;
  full-review)
    ROLES_DISPLAY="@PM, @Architect, @Frontend, @Backend, @QA"
    ;;
  security-audit)
    ROLES_DISPLAY="@Architect, @Security, @Backend, @DevOps"
    ;;
  "")
    ROLES_DISPLAY="（由初始化时填充）"
    ;;
  *)
    echo "警告: 未知预设 '${PRESET}'，将使用自定义角色"
    ROLES_DISPLAY="（自定义角色，由初始化时填充）"
    ;;
esac

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

本目录是一个跨 AI 工具的需求讨论空间。多个 AI 编码工具（Claude Code、Cursor、Codex、Gemini、OpenCode 等）以不同专家角色在 `discussion.md` 中进行结构化讨论。Claude Code 以 @Coordinator 身份提供项目分析种子并协调流程。

支持两种讨论模式：
- **自动模式**：Claude Code 通过 CLI 自动调用各工具，全程无需手动操作
- **手动模式**：通过邀请文件手动将提示词复制到各工具

## 参与角色

| 角色 | 代号 | 职责 | 工具 |
|------|------|------|------|
| 协调者 | @Coordinator | 项目分析、流程调度、汇总产出 | Claude Code |
| PRESET_ROLES_PLACEHOLDER |

## 讨论规则

1. **先读后写**：发言前必须阅读所有已有内容（包括 Round 0 种子发言）
2. **追加模式**：只在 `discussion.md` 末尾追加，禁止修改他人发言
3. **格式规范**：使用规定的发言格式（见下方语法说明）
4. **@ 响应优先**：被 @ 提及时优先回应该议题
5. **更新状态**：发言后更新顶部 STATUS 面板
6. **独立分析**：从自己的专业角度提出其他角色可能忽视的问题
7. **假设标注**：使用 `> [!assumption]` 标注隐含假设

## 收敛规则

- **最大讨论轮次**：MAX_ROUNDS 轮（不含 Round 0 种子）
- **快速路径**：当收敛评估通过时（consensus_ratio >= 0.7），可跳过草案直接汇总
- **超时调停**：超过最大轮次仍无共识时，Claude Code 介入调停

## 反共识偏见

- @Critic 角色每次发言必须包含至少 1 个反对意见或风险提示
- 所有角色应独立分析，避免群体思维
- 使用 `> [!assumption]` 标注隐含假设

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
| `> [!assumption]` | 隐含假设（需后续验证） |

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
| `invite-*.md` | 各角色邀请文件（手动模式） |
| `refs/` | 附件目录 |
| `continue/` | 续接提示词（手动模式） |
HEREDOC

# 替换占位符
sed_inplace "s/MAX_ROUNDS/${MAX_ROUNDS}/g" "${DISCUSSION_DIR}/README.md"

# 替换预设角色占位符
if [ -n "$PRESET" ] && [ "$ROLES_DISPLAY" != "（由初始化时填充）" ]; then
  # 生成角色行（预设已知角色将由 Claude Code 详细填充）
  sed_inplace "s/| PRESET_ROLES_PLACEHOLDER/| （预设: ${PRESET}）角色: ${ROLES_DISPLAY} — 详细信息由初始化流程填充 |/g" "${DISCUSSION_DIR}/README.md"
else
  sed_inplace "s/| PRESET_ROLES_PLACEHOLDER/| （其他角色由初始化时填充） | | | |/g" "${DISCUSSION_DIR}/README.md"
fi

# 确定讨论模式初始值
MODE="pending"  # 模式将在 detect-cli-tools.sh 后确定

# 生成 discussion.md（STATUS 面板 + 标题，Round 0 由 Claude Code 追加）
cat > "${DISCUSSION_DIR}/discussion.md" << HEREDOC
<!-- STATUS
round: 0
pending: @Coordinator
completed:
mentions:
phase: init
mode: ${MODE}
max_rounds: ${MAX_ROUNDS}
preset: ${PRESET:-custom}
tools:
-->

# ${TOPIC} — 需求讨论

> 创建时间: $(date '+%Y-%m-%d %H:%M')
> 参与者: （见 README.md 角色表）
> 模式: 待检测（init 后确定）
> 状态: 初始化中

---

<!-- Round 0 种子发言由 Claude Code 追加 -->
HEREDOC

# 自动填充 context.md（使用 populate-context.sh 扫描项目）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTEXT_FILE="${DISCUSSION_DIR}/context.md"

if [ -x "${SCRIPT_DIR}/populate-context.sh" ] || [ -f "${SCRIPT_DIR}/populate-context.sh" ]; then
  bash "${SCRIPT_DIR}/populate-context.sh" "$PROJECT_ROOT" "$CONTEXT_FILE" 2>/dev/null || {
    echo "警告: context.md 自动填充失败，生成骨架" >&2
    cat > "$CONTEXT_FILE" << SKEL_EOF
# 项目背景

> 自动填充失败，请手动补充或重新运行 populate-context.sh。

## 技术栈

（待填充）

## 架构概览

（待填充）
SKEL_EOF
  }
else
  cat > "$CONTEXT_FILE" << SKEL_EOF
# 项目背景

> populate-context.sh 不可用，请手动补充。

## 技术栈

（待填充）

## 架构概览

（待填充）
SKEL_EOF
fi

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

echo "讨论空间已创建: ${DISCUSSION_DIR}"
echo ""
echo "目录结构:"
echo "  ${DISCUSSION_DIR}/"
echo "  ├── README.md        # 讨论规则"
echo "  ├── discussion.md    # 主讨论文档（待 Round 0 种子）"
echo "  ├── context.md       # 项目背景（已自动填充）"
echo "  ├── refs/"
echo "  └── continue/"
echo "      ├── draft.md"
echo "      └── review.md"
if [ -n "$PRESET" ]; then
  echo ""
  echo "预设: ${PRESET}"
  echo "角色: ${ROLES_DISPLAY}"
fi
echo ""
echo "下一步: Claude Code 将追加 Round 0 种子、检测 CLI 工具并确定讨论模式。"
