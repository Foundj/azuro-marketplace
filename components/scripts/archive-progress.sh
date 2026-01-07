#!/bin/bash
# 自动归档旧的 progress.txt

set -e

echo "📦 Archiving Progress Log..."
echo "============================"
echo ""

# 检查项目目录
if [ ! -d "codebox" ]; then
  echo "❌ ERROR: codebox/ not found"
  echo "   → Run this script from project root directory"
  exit 1
fi

# 创建归档目录
ARCHIVE_DIR="codebox/archive"
mkdir -p "$ARCHIVE_DIR"

# 获取当前日期
DATE=$(date +"%Y-%m-%d")
MONTH=$(date +"%Y-%m")

# 检查文件大小
CURRENT_LINES=$(wc -l < codebox/progress.txt)
echo "Current progress.txt: $CURRENT_LINES lines"

if [ "$CURRENT_LINES" -lt 2000 ]; then
  echo "✅ File size healthy, no archiving needed"
  exit 0
fi

echo ""
echo "⚠️  File exceeds 2000 lines, archiving..."

# 备份原文件
cp codebox/progress.txt codebox/progress.txt.bak

# 保留最近 1000 行
tail -n 1000 codebox/progress.txt > codebox/progress.tmp

# 归档旧内容
head -n -1000 codebox/progress.txt > "$ARCHIVE_DIR/progress-$DATE.txt"

# 替换原文件
mv codebox/progress.tmp codebox/progress.txt

NEW_LINES=$(wc -l < codebox/progress.txt)
ARCHIVED_LINES=$((CURRENT_LINES - NEW_LINES))

echo ""
echo "✅ Archiving completed!"
echo "   Archived: $ARCHIVED_LINES lines → $ARCHIVE_DIR/progress-$DATE.txt"
echo "   Remaining: $NEW_LINES lines"
echo "   Backup: codebox/progress.txt.bak"
echo ""
echo "📝 Next steps:"
echo "   1. Verify: cat codebox/progress.txt | head -20"
echo "   2. Remove backup: rm codebox/progress.txt.bak"
