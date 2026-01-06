---
name: feature-resume
description: 恢复归档的功能或继续未完成的功能，支持跨会话恢复和状态恢复
invocation: /feature-resume <id>
---

# Feature Resume Command

恢复归档的功能或继续未完成的工作。

## 用法

```bash
/feature-resume 001               # 恢复归档的功能
/feature-resume 001 --continue    # 继续未完成的功能
```

## 场景1: 恢复归档功能

### Step 1: 查找归档功能

1. **搜索归档目录**
   ```bash
   # 在所有归档月份中搜索
   find changes/archived -name "001-user-auth" -type d
   ```

2. **读取归档元数据**
   ```bash
   cat changes/archived/2024-01/001-user-auth/ARCHIVED.md
   ```

3. **显示归档信息**
   ```markdown
   # 归档功能: 001-user-auth

   - **标题**: 用户登录功能
   - **归档时间**: 2024-01-20 15:30:00
   - **归档原因**: Completed
   - **最终阶段**: Phase 6 (Finalization)
   - **质量评分**: 95/100

   确定要恢复到active吗？

   [y/N]:
   ```

### Step 2: 恢复文件

1. **移动回active**
   ```bash
   mv "changes/archived/2024-01/001-user-auth" "changes/active/"
   ```

2. **重置状态**
   ```bash
   # 更新state.json
   cat > "changes/active/001-user-auth/state.json" <<EOF
   {
     "change_id": "001-user-auth",
     "status": "resumed",
     "current_phase": "phase-4-implementation",
     "resumability": {
       "can_resume": true,
       "resume_from": "phase-4-implementation",
       "resumed_at": "$(date -Iseconds)",
       "resumed_from_archive": true
     }
   }
   EOF
   ```

3. **更新feature_list.json**
   ```json
   {
     "changes": {
       "active": ["001-user-auth"],  // 添加回来
       "archived_count": 10  // -1
     },
     "features": [
       {
         "id": 1,
         "lifecycle": {
           "stage": "resumed",
           "resumed_at": "2024-01-22T10:00:00Z"
         }
       }
     ]
   }
   ```

### Step 3: 显示恢复信息

```markdown
✅ 功能 #001 "用户登录功能" 已恢复

## 恢复信息
- **恢复时间**: 2024-01-22 10:00:00
- **恢复到**: changes/active/001-user-auth/
- **恢复阶段**: Phase 4 (Implementation)
- **上次状态**: Completed (质量 95/100)

## 可用文件
- proposal.md - 需求提案
- design.md - 设计方案
- tasks.md - 任务列表
- state.json - 工作流状态

## 下一步
使用 `ai` 命令继续开发，或者查看 tasks.md 了解剩余工作。

示例:
  ai "继续开发用户登录功能"
  ai "查看001的任务列表"
```

---

## 场景2: 继续未完成的功能 (跨会话恢复)

### 使用场景

**问题**: 上次会话OODA loop在第7次迭代时超出context限制，未完成

**解决**: 使用resumability机制恢复

### Step 1: 读取state.json

```bash
cat changes/active/001-user-auth/state.json
```

```json
{
  "change_id": "001-user-auth",
  "status": "incomplete",
  "current_phase": "phase-4-implementation",
  "phases": {
    "phase-4-implementation": {
      "status": "in_progress",
      "ooda_iteration": 7,
      "completion_promise": "PENDING",
      "last_task_completed": "Task 5: Add unit tests"
    }
  },
  "resumability": {
    "can_resume": true,
    "resume_from": "phase-4-implementation",
    "context_files": [
      "changes/active/001-user-auth/tasks.md",
      "changes/active/001-user-auth/design.md"
    ],
    "last_session": "2024-01-21T18:45:00Z"
  }
}
```

### Step 2: 恢复上下文

1. **读取关键文件**
   ```bash
   # 恢复上下文
   cat changes/active/001-user-auth/tasks.md
   cat changes/active/001-user-auth/design.md
   ```

2. **分析剩余工作**
   ```markdown
   # 恢复点分析

   ## 已完成 (Tasks 1-5)
   - [x] Task 1: Create IUserRepository interface
   - [x] Task 2: Implement UserRepository class
   - [x] Task 3: Create AuthService with DI
   - [x] Task 4: Create API endpoint
   - [x] Task 5: Add unit tests

   ## 待完成 (Tasks 6-8)
   - [ ] Task 6: Add integration tests
   - [ ] Task 7: Fix 2 high-confidence issues
   - [ ] Task 8: Update documentation

   ## OODA状态
   - 上次迭代: 7/10
   - 完成承诺: PENDING
   - 剩余迭代: 3

   ## 上次会话
   - 中断时间: 2024-01-21 18:45
   - 原因: Context window limit
   ```

### Step 3: 继续OODA Loop

1. **更新state.json**
   ```json
   {
     "status": "resumed",
     "resumability": {
       "resumed_at": "2024-01-22T10:00:00Z",
       "resume_iteration": 8
     }
   }
   ```

2. **重启OODA loop**
   ```typescript
   // 从第8次迭代开始
   await oodaLoop({
     changeId: '001-user-auth',
     startIteration: 8,
     maxIterations: 10,
     resumeFromState: true
   });
   ```

### Step 4: 显示恢复信息

```markdown
✅ 功能 #001 "用户登录功能" 继续中

## 会话信息
- **上次会话**: 2024-01-21 18:45 (中断)
- **本次会话**: 2024-01-22 10:00 (恢复)
- **中断原因**: Context window limit

## 进度
- **已完成任务**: 5/8 (62.5%)
- **OODA迭代**: 7/10 → 继续
- **完成承诺**: PENDING

## 剩余工作
1. Task 6: Add integration tests (20 min)
2. Task 7: Fix 2 high-confidence issues (30 min)
3. Task 8: Update documentation (15 min)

预计完成时间: ~65分钟

## 恢复执行
正在启动OODA loop (iteration 8)...

---
[OBSERVE] 读取 tasks.md...
[ORIENT] 下一个任务: Task 6 (Add integration tests)
[DECIDE] 开始实现集成测试
[ACT] ...
```

---

## 通用功能

### 恢复检查清单

在恢复前验证：
- [ ] state.json存在且有效
- [ ] tasks.md存在
- [ ] 上次会话没有未提交的更改
- [ ] Git工作区干净

### 恢复策略

**智能恢复**:
1. **Phase 0-1**: 从头开始（轻量级）
2. **Phase 2-3**: 读取evidence.md和design.md恢复
3. **Phase 4**: 读取tasks.md + state.json，继续OODA loop
4. **Phase 5-6**: 读取quality report，继续验证

### 冲突处理

如果active中已有同名功能：
```
⚠️ 冲突检测

changes/active/001-user-auth/ 已存在

选项:
1. 覆盖现有版本 (备份到 .backup/)
2. 合并 (手动解决冲突)
3. 取消恢复

[1/2/3]:
```

## 示例

### 示例1: 恢复归档功能

```bash
$ /feature-resume 001

搜索归档...
✅ 找到: changes/archived/2024-01/001-user-auth/

归档信息:
- 归档时间: 2024-01-20 15:30
- 最终状态: Completed (95/100)

确定恢复? [y/N]: y

恢复中...
✅ 移动到 changes/active/001-user-auth/
✅ 更新 feature_list.json
✅ 重置状态

功能 #001 已恢复到 active
```

### 示例2: 继续未完成功能

```bash
$ /feature-resume 001 --continue

读取状态...
✅ 功能 #001 在 Phase 4 (iteration 7/10)

上次会话: 2024-01-21 18:45 (中断)
剩余任务: 3/8

继续OODA loop...

[Iteration 8] OBSERVE → ORIENT → DECIDE → ACT
...
```

## 与ai-dev集成

当用户执行`ai "继续001"`时，ai-dev会：
1. 检测到"继续"关键词
2. 查找change_id=001
3. 读取state.json
4. 自动调用恢复逻辑
5. 从断点继续执行

**无需手动调用** `/feature-resume` - ai-dev会自动处理。

但如果需要手动控制，可以使用此命令。
