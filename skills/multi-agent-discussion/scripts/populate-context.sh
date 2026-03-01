#!/usr/bin/env bash
# 项目上下文自动扫描 — 为 context.md 提供结构化数据
# 用法: bash populate-context.sh <project-root> [context-file]
#
# 扫描项目目录，检测技术栈、目录结构、关键文件等信息。
# 输出 Markdown 格式，可直接写入 context.md 或由 Claude Code 进一步增强。
#
# 如果提供了 context-file 参数，直接写入该文件；否则输出到 stdout。

set -euo pipefail

PROJECT_ROOT="${1:?用法: populate-context.sh <project-root> [context-file]}"
CONTEXT_FILE="${2:-}"

if [ ! -d "$PROJECT_ROOT" ]; then
  echo "错误: 项目目录不存在: $PROJECT_ROOT" >&2
  exit 1
fi

# 进入项目目录
cd "$PROJECT_ROOT"

# --- 辅助函数 ---

detect_tech_stack() {
  local stack=()

  # JavaScript/TypeScript
  [ -f "package.json" ] && {
    stack+=("Node.js")
    grep -q '"typescript"' package.json 2>/dev/null && stack+=("TypeScript")
    grep -q '"react"' package.json 2>/dev/null && stack+=("React")
    grep -q '"next"' package.json 2>/dev/null && stack+=("Next.js")
    grep -q '"vue"' package.json 2>/dev/null && stack+=("Vue")
    grep -q '"express"' package.json 2>/dev/null && stack+=("Express")
    grep -q '"hono"' package.json 2>/dev/null && stack+=("Hono")
  }

  # Python
  [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ] && stack+=("Python")
  [ -f "pyproject.toml" ] && {
    grep -q 'django' pyproject.toml 2>/dev/null && stack+=("Django")
    grep -q 'fastapi' pyproject.toml 2>/dev/null && stack+=("FastAPI")
    grep -q 'flask' pyproject.toml 2>/dev/null && stack+=("Flask")
  }

  # Rust
  [ -f "Cargo.toml" ] && stack+=("Rust")

  # Go
  [ -f "go.mod" ] && stack+=("Go")

  # Java/Kotlin
  [ -f "pom.xml" ] && stack+=("Java/Maven")
  [ -f "build.gradle" ] || [ -f "build.gradle.kts" ] && stack+=("Gradle")

  # Infrastructure
  [ -f "Dockerfile" ] || [ -f "docker-compose.yml" ] && stack+=("Docker")
  [ -f ".github/workflows/"*.yml ] 2>/dev/null && stack+=("GitHub Actions")

  # Markdown/Docs 项目
  [ -f ".claude-plugin/marketplace.json" ] && stack+=("Claude Plugin")

  if [ ${#stack[@]} -eq 0 ]; then
    echo "未检测到已知框架"
  else
    local IFS=", "
    echo "${stack[*]}"
  fi
}

count_files() {
  local ext="$1"
  find . -name "*.${ext}" \
    -not -path '*/node_modules/*' \
    -not -path '*/.git/*' \
    -not -path '*/dist/*' \
    -not -path '*/build/*' \
    -not -path '*/.cache/*' \
    -not -path '*/bak/*' \
    -not -path '*/.opencode/*' \
    -not -path '*/.next/*' \
    -not -path '*/vendor/*' \
    2>/dev/null | wc -l | tr -d ' '
}

get_dir_tree() {
  # 只显示前两层目录结构
  if command -v tree &>/dev/null; then
    tree -L 2 -d --noreport -I 'node_modules|.git|dist|build|__pycache__|.next|.cache|bak|.opencode|vendor' 2>/dev/null | head -30
  else
    find . -maxdepth 2 -type d \
      -not -path '*/node_modules/*' \
      -not -path '*/.git/*' \
      -not -path '*/dist/*' \
      -not -path '*/build/*' \
      -not -path '*/.cache/*' \
      -not -path '*/bak/*' \
      -not -path '*/.opencode/*' \
      -not -path '*/vendor/*' \
      2>/dev/null | sort | head -30
  fi
}

get_git_info() {
  if ! command -v git &>/dev/null || ! git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
    echo "非 Git 仓库"
    return
  fi

  local branch=$(git branch --show-current 2>/dev/null || echo "unknown")
  local commit_count=$(git rev-list --count HEAD 2>/dev/null || echo "?")
  local last_commit=$(git log -1 --format="%h %s" 2>/dev/null || echo "N/A")
  local contributors=$(git shortlog -sn HEAD 2>/dev/null | wc -l | tr -d ' ')

  echo "- 当前分支: \`${branch}\`"
  echo "- 提交数: ${commit_count}"
  echo "- 最近提交: \`${last_commit}\`"
  echo "- 贡献者: ${contributors}"
}

get_key_files() {
  local files=()
  [ -f "README.md" ] && files+=("README.md")
  [ -f "CLAUDE.md" ] || [ -f "AGENTS.md" ] && files+=("CLAUDE.md / AGENTS.md")
  [ -f "package.json" ] && files+=("package.json")
  [ -f "tsconfig.json" ] && files+=("tsconfig.json")
  [ -f "pyproject.toml" ] && files+=("pyproject.toml")
  [ -f "Cargo.toml" ] && files+=("Cargo.toml")
  [ -f "go.mod" ] && files+=("go.mod")
  [ -f "Dockerfile" ] && files+=("Dockerfile")
  [ -f "docker-compose.yml" ] && files+=("docker-compose.yml")
  [ -f ".env.example" ] && files+=(".env.example")

  for f in "${files[@]}"; do
    echo "- \`${f}\`"
  done
}

# --- 生成 Markdown ---

generate_context() {
  local project_name=$(basename "$PROJECT_ROOT")

  cat <<EOF
# 项目背景

> 此文件由 populate-context.sh 自动扫描生成 ($(date '+%Y-%m-%d %H:%M'))。
> Claude Code 可进一步增强分析。如需补充信息，可直接编辑。

## 技术栈

$(detect_tech_stack)

### 文件统计
| 类型 | 数量 |
|------|------|
| Markdown (.md) | $(count_files md) |
| Shell (.sh) | $(count_files sh) |
| TypeScript (.ts/.tsx) | $(($(count_files ts) + $(count_files tsx))) |
| JavaScript (.js/.jsx) | $(($(count_files js) + $(count_files jsx))) |
| Python (.py) | $(count_files py) |
| JSON (.json) | $(count_files json) |

## 架构概览

\`\`\`
$(get_dir_tree)
\`\`\`

## 关键文件

$(get_key_files)

## 版本控制

$(get_git_info)

## 约束条件

（由 Claude Code 或参与者补充）
EOF
}

# --- 输出 ---

if [ -n "$CONTEXT_FILE" ]; then
  generate_context > "$CONTEXT_FILE"
  echo "已写入: ${CONTEXT_FILE}" >&2
else
  generate_context
fi
