---
name: feature-show
description: 显示指定功能的详细信息，包括状态、进度、质量指标和任务列表
invocation: /feature-show [id]
---

# Feature Show Command

显示单个功能的完整详细信息。

## 用法

```bash
/feature-show 001
/feature-show 001-user-auth
```

## 执行步骤

1. **读取feature_list.json**
   ```bash
   cat feature_list.json
   ```

2. **查找指定功能**
   - 根据ID或change_id查找
   - 如果找不到，显示错误

3. **显示详细信息**

```markdown
# 功能详情: [Feature Title]

## 基本信息
- **ID**: 001
- **Change ID**: 001-user-auth
- **标题**: 实现用户登录功能
- **描述**: 使用JWT实现用户认证和登录

## 状态
- **阶段**: Phase 4 (Implementation)
- **状态**: in_progress
- **工作流状态**: active
- **完成承诺**: PENDING

## 进度
- **总任务**: 8
- **已完成**: 5
- **完成率**: 62.5%
- **OODA迭代**: 6/10

## 质量指标
- **平均置信度**: 92
- **高置信度问题**: 2
- **测试覆盖率**: 85%

## 任务列表
- [x] Task 1: Create IUserRepository interface
- [x] Task 2: Implement UserRepository class
- [x] Task 3: Create AuthService with DI
- [x] Task 4: Create API endpoint
- [x] Task 5: Add unit tests
- [ ] Task 6: Add integration tests
- [ ] Task 7: Fix security issues
- [ ] Task 8: Update documentation

## 相关文件
- `changes/active/001-user-auth/proposal.md`
- `changes/active/001-user-auth/design.md`
- `changes/active/001-user-auth/tasks.md`
- `changes/active/001-user-auth/state.json`

## 知识关联
- **相关模式**: PATTERN-001 (Repository Pattern)
- **相关错误**: ERROR-012 (Async rejection)
- **风险等级**: medium

## 代理历史
- requirement-analyzer (Phase 1) - 2024-01-15 10:30
- code-explorer x2 (Phase 2) - 2024-01-15 11:00
- code-architect x2 (Phase 3) - 2024-01-15 12:00
- OODA loop (Phase 4) - In progress...

## 下一步
- 完成剩余3个任务
- 修复2个高置信度问题
- 运行完整测试套件
```

4. **如果功能已归档**，显示归档位置：
```
⚠️ 此功能已归档
位置: changes/archived/2024-01/001-user-auth/
归档时间: 2024-01-20 15:30
```

## 示例

```bash
$ /feature-show 001

# 功能详情: 实现用户登录功能

## 基本信息
- **ID**: 001
- **Change ID**: 001-user-auth
- **标题**: 实现用户登录功能

## 状态
- **阶段**: Phase 4 (Implementation)
- **状态**: in_progress
- **完成率**: 62.5% (5/8 tasks)

## 质量
- **置信度**: 92
- **待修复问题**: 2

## 相关文件
- changes/active/001-user-auth/

---
使用 /feature-list 查看所有功能
```
