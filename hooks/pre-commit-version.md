---
name: pre-commit-version
description: Pre-commit hook to ensure plugin version is incremented
trigger: pre-commit
---

# Version Gate Pre-Commit Hook

在提交代码前检查插件版本号是否已更新。

## 检查逻辑

1. 读取 `.claude-plugin/plugin.json` 中的当前版本
2. 与缓存的上次提交版本比较
3. 如果版本未增加，阻止提交并提示更新

## 安装

将此 hook 添加到 `.git/hooks/pre-commit`:

```bash
#!/bin/bash
# Version gate for azuro marketplace

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(git rev-parse --show-toplevel)}"
bash "$PLUGIN_ROOT/hooks/scripts/version-gate.sh" "$PLUGIN_ROOT/.claude-plugin/plugin.json"
```

## 手动运行

```bash
bash hooks/scripts/version-gate.sh
```

## 版本更新

使用 bump 脚本快速更新版本:

```bash
bash hooks/scripts/bump.sh patch   # 3.2.0 → 3.2.1
bash hooks/scripts/bump.sh minor   # 3.2.0 → 3.3.0
bash hooks/scripts/bump.sh major   # 3.2.0 → 4.0.0
```

## 跳过检查

紧急情况下可跳过（不推荐）:

```bash
git commit --no-verify -m "message"
```
