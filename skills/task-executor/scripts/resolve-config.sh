#!/usr/bin/env bash
# 合并层级配置（版本 README > 全局 README > 默认值）
# 用法: bash resolve-config.sh <version> [project-root]
#
# 解析 docs/tasks/README.md 和 docs/tasks/v<version>/README.md 的 YAML frontmatter，
# 合并后输出最终配置（版本级覆盖全局）。
#
# 输出: JSON 格式的合并后配置
# 依赖: yq (https://github.com/mikefarah/yq)

set -euo pipefail

VERSION="${1:?用法: resolve-config.sh <version> [project-root]}"
PROJECT_ROOT="${2:-.}"

GLOBAL_README="${PROJECT_ROOT}/docs/tasks/README.md"
VERSION_README="${PROJECT_ROOT}/docs/tasks/v${VERSION}/README.md"

if ! command -v yq &>/dev/null; then
  echo "错误: 需要安装 yq (https://github.com/mikefarah/yq)" >&2
  exit 1
fi

# 提取 YAML frontmatter 为临时文件
extract_frontmatter() {
  if [ ! -f "$1" ]; then
    return
  fi
  awk '/^---$/ { count++; next } count == 1 { print } count >= 2 { exit }' "$1"
}

TMPDIR_RESOLVE=$(mktemp -d)
trap "rm -rf $TMPDIR_RESOLVE" EXIT

GLOBAL_TMP="${TMPDIR_RESOLVE}/global.yml"
VERSION_TMP="${TMPDIR_RESOLVE}/version.yml"
DEFAULTS_TMP="${TMPDIR_RESOLVE}/defaults.yml"
MERGED_TMP="${TMPDIR_RESOLVE}/merged.yml"

extract_frontmatter "$GLOBAL_README" > "$GLOBAL_TMP"
extract_frontmatter "$VERSION_README" > "$VERSION_TMP"

cat > "$DEFAULTS_TMP" <<'EOF'
execution:
  engine: task-executor
  mode: autonomous
  max_iterations: 50
  pause_on_unclear: true
  completion_promise: "ALL_TASKS_DONE"
steps:
  understand: self
  implement: self
  test: self
  review: self
executors: {}
roles: {}
rules: []
EOF

# 逐层合并: 默认值 ← 全局配置 ← 版本配置
cp "$DEFAULTS_TMP" "$MERGED_TMP"

if [ -s "$GLOBAL_TMP" ]; then
  yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
    "$MERGED_TMP" "$GLOBAL_TMP" > "${TMPDIR_RESOLVE}/step1.yml"
  cp "${TMPDIR_RESOLVE}/step1.yml" "$MERGED_TMP"
fi

if [ -s "$VERSION_TMP" ]; then
  yq eval-all 'select(fileIndex == 0) * select(fileIndex == 1)' \
    "$MERGED_TMP" "$VERSION_TMP" > "${TMPDIR_RESOLVE}/step2.yml"
  cp "${TMPDIR_RESOLVE}/step2.yml" "$MERGED_TMP"
fi

yq -o json "$MERGED_TMP"
