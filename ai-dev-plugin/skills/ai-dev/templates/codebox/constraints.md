# 项目约束和质量门禁

> 本文档定义项目的技术约束和质量门禁
> 所有变更必须通过这些门禁才能合并

---

## 技术约束

### 技术栈

- **语言**: <!-- e.g., TypeScript 5.x -->
- **框架**: <!-- e.g., Next.js 14, React 18 -->
- **数据库**: <!-- e.g., PostgreSQL, Drizzle ORM -->
- **测试**: <!-- e.g., Vitest, Jest -->

### 代码规范

- ESLint 配置: <!-- e.g., eslint.config.js -->
- Prettier 配置: <!-- e.g., .prettierrc -->
- TypeScript 配置: <!-- e.g., tsconfig.json -->

---

## 质量门禁

### 必须通过

| 门禁 | 命令 | 阈值 |
|------|------|------|
| TypeScript 编译 | `npm run build` 或 `tsc --noEmit` | 0 errors |
| ESLint 检查 | `npm run lint` | 0 errors |
| 单元测试 | `npm test` | 100% pass |
| 类型检查 | `tsc --noEmit` | 0 errors |

### 建议通过

| 门禁 | 命令 | 阈值 |
|------|------|------|
| 测试覆盖率 | `npm run test:coverage` | ≥80% |
| Bundle 大小 | `npm run build` | <!-- 根据项目设定 --> |

---

## 安全约束

- [ ] 不提交敏感信息（密钥、密码、token）
- [ ] 不使用硬编码的敏感值
- [ ] 所有用户输入必须验证
- [ ] 使用参数化查询（防止 SQL 注入）
- [ ] 依赖项无已知漏洞

---

## 架构约束

- [ ] 遵循项目分层架构
- [ ] 新组件符合现有模式
- [ ] 不引入循环依赖
- [ ] 公共 API 保持向后兼容

---

## 变更管理

### 允许的变更类型

- `feat`: 新功能
- `fix`: Bug 修复
- `refactor`: 重构（不改变行为）
- `docs`: 文档更新
- `test`: 测试添加/修改
- `chore`: 构建/工具变更

### 变更大小限制

- 单次变更建议 ≤500 行代码改动
- 超过限制需拆分为多个变更

---

## 更新日志

- **初始版本**: [日期]
