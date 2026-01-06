# Tasks for Change {{CHANGE_ID}}

> Phase 4 OODA Loop 任务清单
> 此文件由 agent 自我引用，每次迭代读取和更新

---

## 📊 Metadata

- **Change ID**: {{CHANGE_ID}}
- **Phase**: 4 (Implementation)
- **OODA Iteration**: {{CURRENT_ITERATION}}/{{MAX_ITERATIONS}}
- **Completion**: <promise>PENDING</promise>
- **Started**: {{START_TIME}}
- **Last Updated**: {{LAST_UPDATE}}

---

## 📋 Task List

### Phase 1: Core Implementation

{{#CORE_TASKS}}
- [ ] Task {{TASK_NUMBER}}: {{TASK_DESCRIPTION}} ({{FILE_PATH}})
  - Dependencies: {{DEPENDENCIES}}
  - Estimated: {{ESTIMATE}}
{{/CORE_TASKS}}

### Phase 2: Integration

{{#INTEGRATION_TASKS}}
- [ ] Task {{TASK_NUMBER}}: {{TASK_DESCRIPTION}} ({{FILE_PATH}})
  - Dependencies: {{DEPENDENCIES}}
  - Estimated: {{ESTIMATE}}
{{/INTEGRATION_TASKS}}

### Phase 3: Testing

{{#TESTING_TASKS}}
- [ ] Task {{TASK_NUMBER}}: {{TASK_DESCRIPTION}} ({{FILE_PATH}})
  - Dependencies: {{DEPENDENCIES}}
  - Estimated: {{ESTIMATE}}
{{/TESTING_TASKS}}

### Phase 5 Issue Fixes (如果Phase 5发现问题)

*(此部分在Phase 5返回时添加)*

{{#ISSUE_FIX_TASKS}}
- [ ] Fix Issue {{ISSUE_ID}}: {{ISSUE_TITLE}} ({{FILE_PATH}}:{{LINE}})
{{/ISSUE_FIX_TASKS}}

---

## ✅ Validation Criteria

必须满足以下所有条件才能将 `<promise>PENDING</promise>` 改为 `<promise>DONE</promise>`:

- [ ] All tasks above are completed (checkboxes checked)
- [ ] All tests pass: `npm test`
- [ ] Build succeeds: `npm run build`
- [ ] ESLint: 0 errors (`npm run lint`)
- [ ] TypeScript: 0 errors (`npm run type-check` or `tsc --noEmit`)
- [ ] All global constraints met (符合 requirements.md, design.md, CLAUDE.md, constraints.md)

---

## 📖 Instructions

### 每完成一个任务后:

1. **更新 checkbox**: 将 `- [ ]` 改为 `- [x]`
2. **运行测试**: `npm test` 确保没有破坏现有功能
3. **运行 build**: `npm run build` 确保没有编译错误
4. **检查剩余任务**: 还有未完成的？继续下一个

### 所有任务完成后:

1. **最终验证**:
   ```bash
   npm test       # 所有测试通过 ✓
   npm run build  # 构建成功 ✓
   npm run lint   # 无 lint 错误 ✓
   tsc --noEmit   # 无类型错误 ✓
   ```

2. **更新 Completion Promise**:
   ```markdown
   <promise>DONE</promise>
   ```

3. **OODA 循环自动退出**，进入 Phase 5 (Quality Validation)

---

## ⚠️ 重要提醒

### DO:
- ✅ 每完成一个任务立即更新 checkbox
- ✅ 每次修改代码后运行测试
- ✅ 遇到失败的测试立即修复，不要继续下一个任务
- ✅ 保持任务粒度适中（每个任务 30 分钟内完成）
- ✅ 真正完成所有任务且测试通过后才写 `<promise>DONE</promise>`

### DON'T:
- ❌ 不要在测试失败时标记任务为完成
- ❌ 不要跳过任务（按顺序执行）
- ❌ 不要在没有真正完成时就写 `<promise>DONE</promise>`
- ❌ 不要批量更新 checkboxes（一个一个来）
- ❌ 不要忽略 build 或 lint 错误

---

## 🔍 OODA Loop History

### Iteration 1 ({{ITERATION_1_TIME}})
- **Completed**: {{ITERATION_1_TASKS}}
- **Tests**: {{ITERATION_1_TESTS}} ({{PASSING}}/{{TOTAL}})
- **Build**: {{ITERATION_1_BUILD}}
- **Decision**: {{ITERATION_1_DECISION}}
- **Action**: {{ITERATION_1_ACTION}}
- **Notes**: {{ITERATION_1_NOTES}}

### Iteration 2 ({{ITERATION_2_TIME}})
- **Completed**: {{ITERATION_2_TASKS}}
- **Tests**: {{ITERATION_2_TESTS}} ({{PASSING}}/{{TOTAL}})
- **Build**: {{ITERATION_2_BUILD}}
- **Decision**: {{ITERATION_2_DECISION}}
- **Action**: {{ITERATION_2_ACTION}}
- **Notes**: {{ITERATION_2_NOTES}}

*(每次迭代后添加新的iteration记录，追踪完整的OODA历史)*

---

## 📈 Progress Tracking

- **Total Tasks**: {{TOTAL_TASKS}}
- **Completed**: {{COMPLETED_TASKS}}
- **Remaining**: {{REMAINING_TASKS}}
- **Progress**: {{PROGRESS_PERCENTAGE}}%
- **Test Status**: {{TEST_PASSING}}/{{TEST_TOTAL}} passing
- **Build Status**: {{BUILD_STATUS}}
- **Blockers**: {{BLOCKERS}}

---

## 📝 任务模板示例

下面是一些常见的任务模板，可作为参考：

### 示例 1: 创建 Repository

```markdown
- [ ] Create IUserRepository interface
  - 定义接口: findById, findByEmail, create, update, delete
  - 类型定义: User, CreateUserDTO, UpdateUserDTO
  - 文件: src/lib/repositories/IUserRepository.ts
```

### 示例 2: 创建 Service

```markdown
- [ ] Create AuthService with DI
  - 依赖注入 IUserRepository
  - 实现 login(email, password) 方法
  - 使用 bcrypt 验证密码
  - 生成 JWT token
  - 错误处理: try-catch + AppError
  - 文件: src/lib/services/AuthService.ts
```

### 示例 3: 创建 API Endpoint

```markdown
- [ ] Create API endpoint /api/auth/login
  - Hono route handler
  - Zod schema 验证 (email, password)
  - 调用 AuthService.login
  - 返回标准响应格式: { success, data/error }
  - 设置 httpOnly cookie (JWT)
  - 文件: src/app/api/auth/login/route.ts
```

### 示例 4: 添加测试

```markdown
- [ ] Add unit tests for AuthService
  - Test: login with valid credentials → success
  - Test: login with invalid password → error
  - Test: login with non-existent user → error
  - Test: login with malformed email → error
  - Mock IUserRepository
  - 覆盖率 ≥ 90%
  - 文件: src/lib/services/AuthService.test.ts
```

---

## 🎯 成功标准

当你看到以下输出时，说明可以写 `<promise>DONE</promise>` 了：

```bash
$ npm test
✓ All tests passed (23/23)

$ npm run build
✓ Build successful

$ npm run lint
✓ No ESLint errors

$ tsc --noEmit
✓ No TypeScript errors
```

**此时**:
1. 确认所有 checkboxes 已勾选 ✓
2. 更新 `<promise>DONE</promise>`
3. OODA 循环自动检测并退出
4. 进入 Phase 5 (Quality Validation)

---

## 📄 Complete Example (User Authentication Feature)

Below is a complete example of a filled-out tasks.md for a user authentication feature:

```markdown
# Tasks for Change 001-user-auth

## 📊 Metadata

- **Change ID**: 001-user-auth
- **Phase**: 4 (Implementation)
- **OODA Iteration**: 5/10
- **Completion**: <promise>PENDING</promise>
- **Started**: 2025-01-04T09:55:00Z
- **Last Updated**: 2025-01-04T11:30:00Z

---

## 📋 Task List

### Phase 1: Core Implementation

- [x] Task 1: Create IUserRepository interface (src/lib/interfaces/IUserRepository.ts)
  - Dependencies: None
  - Estimated: 15 min
  - Status: ✅ Completed

- [x] Task 2: Implement UserRepository class (src/lib/repositories/UserRepository.ts)
  - Dependencies: Task 1
  - Estimated: 30 min
  - Status: ✅ Completed

- [x] Task 3: Create AuthService (src/lib/services/AuthService.ts)
  - Dependencies: Task 1, Task 2
  - Estimated: 30 min
  - Status: ✅ Completed

- [ ] Task 4: Add Zod validation schemas (src/lib/schemas/auth.schema.ts)
  - Dependencies: None
  - Estimated: 15 min
  - Status: ⏳ In Progress

### Phase 2: Integration

- [ ] Task 5: Create login API endpoint (src/api/auth/login/route.ts)
  - Dependencies: Task 3, Task 4
  - Estimated: 25 min

- [ ] Task 6: Create signup API endpoint (src/api/auth/signup/route.ts)
  - Dependencies: Task 3, Task 4
  - Estimated: 25 min

### Phase 3: Testing

- [ ] Task 7: Add unit tests for AuthService (src/lib/__tests__/AuthService.test.ts)
  - Dependencies: Task 3
  - Estimated: 30 min

- [ ] Task 8: Add integration tests for /api/auth/login (src/api/__tests__/auth.test.ts)
  - Dependencies: Task 5, Task 6
  - Estimated: 40 min

---

## ✅ Validation Criteria

- [ ] All tasks above are completed (checkboxes checked)
- [x] All tests pass: `npm test` (18/18 passing)
- [x] Build succeeds: `npm run build`
- [x] ESLint: 0 errors (`npm run lint`)
- [x] TypeScript: 0 errors (`tsc --noEmit`)
- [x] All global constraints met

---

## 🔍 OODA Loop History

### Iteration 1 (2025-01-04 09:55:00)
- **Completed**: Task 1
- **Tests**: ✅ Passed (0/0)
- **Build**: ✅ Success
- **Decision**: Next task = Task 2
- **Action**: Implement UserRepository
- **Notes**: Created IUserRepository interface with 5 methods

### Iteration 2 (2025-01-04 10:10:00)
- **Completed**: Task 2
- **Tests**: ✅ Passed (5/5)
- **Build**: ✅ Success
- **Decision**: Next task = Task 3
- **Action**: Implement AuthService
- **Notes**: UserRepository with Drizzle ORM integration

### Iteration 3 (2025-01-04 10:35:00)
- **Completed**: Task 3 (partial)
- **Tests**: ❌ Failed (7/8)
- **Build**: ✅ Success
- **Decision**: Fix failing test
- **Action**: Debug async error handling in AuthService.login
- **Notes**: 1 test failing - unhandled promise rejection

### Iteration 4 (2025-01-04 10:50:00)
- **Completed**: Task 3 (fixed)
- **Tests**: ✅ Passed (8/8)
- **Build**: ✅ Success
- **Decision**: Next task = Task 4
- **Action**: Create Zod schemas
- **Notes**: Fixed async error handling with try-catch

### Iteration 5 (2025-01-04 11:15:00)
- **Completed**: Task 4 (in progress)
- **Tests**: ✅ Passed (8/8)
- **Build**: ✅ Success
- **Decision**: Continue Task 4
- **Action**: Finish Zod validation schemas
- **Notes**: Created loginSchema, signupSchema

---

## 📈 Progress Tracking

- **Total Tasks**: 8
- **Completed**: 3
- **Remaining**: 5
- **Progress**: 37.5%
- **Test Status**: 18/18 passing
- **Build Status**: ✅ Success
- **Blockers**: None
```

---

**Happy Coding! 🚀**
