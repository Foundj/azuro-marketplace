---
name: feature-archive
description: 归档已完成的功能，将其从active移动到archived，更新知识库
invocation: /ai:feature-archive <id>
---

# Feature Archive Command

归档已完成的功能到`changes/archived/`。

## 用法

```bash
/ai:feature-archive 001
/ai:feature-archive 001-user-auth
```

## 执行步骤

### Step 1: 验证功能状态

1. **读取feature_list.json**
   ```bash
   cat feature_list.json
   ```

2. **检查功能状态**
   - 必须是`lifecycle.stage = "completed"` 或 `"validated"`
   - 如果未完成，提示用户确认

3. **确认归档**
   ```
   ⚠️ 功能 #001 "用户登录功能" 状态: in_progress (未完成)

   确定要归档吗？归档后可以使用 /feature-resume 恢复。

   [y/N]:
   ```

### Step 2: 归档文件

1. **创建归档目录**
   ```bash
   # 按月份归档
   ARCHIVE_DIR="changes/archived/$(date +%Y-%m)"
   mkdir -p "$ARCHIVE_DIR"
   ```

2. **移动功能文件夹**
   ```bash
   # 从active或staged移动
   mv "changes/active/001-user-auth" "$ARCHIVE_DIR/"
   # 或
   mv "changes/staged/001-user-auth" "$ARCHIVE_DIR/"
   ```

3. **添加归档元数据**
   ```bash
   cat > "$ARCHIVE_DIR/001-user-auth/ARCHIVED.md" <<EOF
   # 归档信息

   - **归档时间**: $(date -Iseconds)
   - **归档原因**: Completed
   - **最终阶段**: Phase 6 (Finalization)
   - **最终状态**: validated
   - **质量评分**: 95/100
   - **OODA迭代**: 8

   ## 成果
   - ✅ 实现了完整的用户登录功能
   - ✅ JWT认证
   - ✅ 测试覆盖率 95%
   - ✅ 所有质量检查通过

   ## 相关提交
   - abc123f: Implement user authentication
   - def456g: Add login API endpoint
   - ghi789h: Add comprehensive tests

   ## 知识更新
   - 更新了 PATTERN-001 (使用次数+1)
   - 记录了新的最佳实践
   EOF
   ```

### Step 3: 更新feature_list.json

```json
{
  "changes": {
    "active": [],  // 移除001
    "staged": [],
    "archived_count": 11  // +1
  },
  "features": [
    {
      "id": 1,
      "change_id": "001-user-auth",
      "lifecycle": {
        "stage": "archived",
        "archived_at": "2024-01-20T15:30:00Z",
        "archive_location": "changes/archived/2024-01/001-user-auth/"
      }
    }
  ]
}
```

### Step 4: 更新知识库 (Phase 6 集成)

1. **更新patterns.json**
   ```json
   {
     "id": "PATTERN-001",
     "usage_count": 16,  // +1
     "success_rate": 100,
     "last_used": "2024-01-20T15:30:00Z"
   }
   ```

2. **更新learnings.md**
   ```markdown
   ## 2024-01-20: 用户登录功能完成

   ### 学到的经验
   - Repository pattern非常适合认证逻辑
   - JWT token过期时间设置为7天最佳
   - 密码哈希应该使用bcrypt (rounds=10)

   ### 避免的错误
   - 使用try-catch包装所有async操作 (避免ERROR-012)
   - 参数化SQL查询避免注入 (避免CWE-89)
   ```

3. **更新errors.json** (如果有新错误)
   - 如果发现了新的错误模式，记录下来

### Step 5: Git提交

```bash
# 归档提交
git add changes/archived/2024-01/001-user-auth/
git add feature_list.json
git add knowledge/

git commit -m "Archive: 001-user-auth - 用户登录功能完成

- 移动到 changes/archived/2024-01/
- 更新 feature_list.json
- 更新知识库 (PATTERN-001 usage +1)
- 记录最佳实践
"
```

### Step 6: 显示结果

```markdown
✅ 功能 #001 "用户登录功能" 已归档

## 归档信息
- **归档位置**: changes/archived/2024-01/001-user-auth/
- **归档时间**: 2024-01-20 15:30:00
- **最终质量**: 95/100
- **OODA迭代**: 8

## 知识更新
- ✅ PATTERN-001 使用次数更新 (15 → 16)
- ✅ 记录了3条最佳实践
- ✅ 更新了learnings.md

## 文件位置
- 归档文件夹: changes/archived/2024-01/001-user-auth/
- 归档元数据: changes/archived/2024-01/001-user-auth/ARCHIVED.md

---
使用 /feature-resume 001 可以恢复此功能
使用 /feature-list --archived 查看所有归档功能
```

## 安全检查

在归档前检查：
- [ ] 没有未提交的更改
- [ ] 所有测试通过
- [ ] 质量评分 ≥80
- [ ] 没有critical未解决问题

如果检查失败：
```
⚠️ 归档前检查失败

问题:
- ❌ 有2个未解决的critical问题
- ❌ 质量评分 78/100 (低于80)

建议: 先修复问题再归档

继续归档? [y/N]:
```

## 示例

```bash
$ /ai:feature-archive 001

验证功能状态...
✅ 功能 #001 已完成 (stage: validated)

归档中...
✅ 移动文件到 changes/archived/2024-01/001-user-auth/
✅ 创建归档元数据
✅ 更新 feature_list.json
✅ 更新知识库
✅ Git提交

功能 #001 "用户登录功能" 已成功归档
```
