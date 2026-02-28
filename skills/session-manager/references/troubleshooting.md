# Troubleshooting Guide

> Session Manager 常见问题和解决方案

## 恢复失败

**症状**: `continue` 或 `resume` 命令无法恢复进度

**检查清单**:
1. 确保在正确的项目目录 (`pwd`)
2. 检查 `codebox/` 目录存在
3. 验证文件格式：`jq . feature_list.json`

**解决方案**:
```bash
# 检查当前目录
pwd

# 创建 codebox 目录（如果不存在）
mkdir -p codebox

# 验证 JSON 格式
jq . codebox/feature_list.json
```

## 环境启动失败

**症状**: `init.sh` 执行失败

**检查清单**:
1. 检查 init.sh 可执行权限
2. 手动运行并查看错误
3. 检查端口占用

**解决方案**:
```bash
# 添加执行权限
chmod +x init.sh

# 手动运行查看错误
./init.sh

# 检查端口占用
lsof -i :3000  # 替换为实际端口
```

## 特性依赖未满足

**症状**: 推荐的特性无法开始

**检查清单**:
1. 查看特性的 `dependencies` 字段
2. 确认依赖特性状态

**解决方案**:
```bash
# 查看特性依赖
jq '.features[] | select(.id == 43) | .dependencies' codebox/feature_list.json

# 先完成依赖特性，或选择其他可执行特性
```

## Git 状态异常

**症状**: Git 相关检查失败

**检查清单**:
1. 检查是否在 Git 仓库中
2. 检查是否有未提交的更改

**解决方案**:
```bash
# 初始化 Git（如果需要）
git init

# 查看状态
git status

# 提交更改
git add . && git commit -m "WIP"
```

## 进度文件过大

**症状**: `progress.txt` 超过 2000 行

**解决方案**:
```bash
# 手动归档
head -n 1000 codebox/progress.txt > codebox/progress.txt.new
tail -n +1001 codebox/progress.txt >> codebox/archive/progress-$(date +%Y%m%d).txt
mv codebox/progress.txt.new codebox/progress.txt
```