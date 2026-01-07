# 项目质量约束和门禁

> 本文档定义代码质量标准，所有变更必须通过这些门禁

---

## 代码质量规则

### 复杂度限制

| 指标 | 限制 | 理由 |
|------|------|------|
| 函数行数 | ≤ 30 行 | 易于理解和测试 |
| 文件行数 | ≤ 400 行 | 避免上帝文件 |
| 圈复杂度 | ≤ 10 | 降低维护成本 |
| 嵌套深度 | ≤ 3 | 提高可读性 |
| 函数参数 | ≤ 4 个 | 使用对象传参 |

### 命名规范

```typescript
// 组件
export function UserProfile() {}       // PascalCase

// 函数
function getUserById() {}              // camelCase

// 常量
const MAX_RETRY_COUNT = 3;            // UPPER_SNAKE_CASE

// 接口/类型
interface User {}                      // PascalCase
type UserRole = 'admin' | 'user';     // PascalCase

// 文件夹
user-profile/                          // kebab-case
```

### TypeScript 要求

- ✅ **禁止 `any`**（除非有充分理由并注释说明）
- ✅ **所有函数参数必须类型化**
- ✅ **使用严格模式** (`strict: true`)
- ✅ **优先使用 `interface`** over `type`（除非需要联合类型）
- ✅ **使用 `unknown`** 代替 `any` 处理未知类型
- ✅ **避免类型断言**（`as`），优先类型保护

```typescript
// ❌ Bad
function process(data: any) { ... }

// ✅ Good
function process(data: unknown) {
  if (typeof data === 'string') {
    // TypeScript 知道这里 data 是 string
  }
}
```

---

## 质量门禁

### Phase 5 门禁：代码完成后

所有变更必须通过：

- [ ] **ESLint**: 0 errors, 0 warnings
- [ ] **TypeScript**: 0 errors
- [ ] **Prettier**: 已格式化
- [ ] **单元测试**: 通过率 100%
- [ ] **集成测试**: 关键路径覆盖
- [ ] **Build**: 成功构建（`npm run build`）

### 置信度过滤门禁

- 代码审查 issues: **仅报告 confidence ≥ 80**
- 按置信度排序（高 → 低）
- 低置信度 issues 记录但不阻塞合并

---

## Git 提交规范

### Commit Message 格式

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Type 类型

| Type | 描述 | 示例 |
|------|------|------|
| `feat` | 新功能 | `feat(auth): add login API` |
| `fix` | Bug 修复 | `fix(user): resolve avatar upload issue` |
| `docs` | 文档更新 | `docs(readme): update installation guide` |
| `style` | 代码格式 | `style(api): format with prettier` |
| `refactor` | 重构 | `refactor(db): extract repository pattern` |
| `test` | 测试 | `test(auth): add login flow tests` |
| `chore` | 构建/工具 | `chore(deps): upgrade next to 14.0` |

### 示例

```bash
feat(auth): implement JWT refresh token

- Add refresh token endpoint
- Store refresh token in httpOnly cookie
- Auto-refresh when access token expires

Closes #123
```

---

## 性能标准

### Web Vitals (Lighthouse)

| 指标 | 目标 | 测量工具 |
|------|------|----------|
| Performance Score | ≥ 90 | Lighthouse |
| First Contentful Paint (FCP) | ≤ 1.5s | Lighthouse |
| Largest Contentful Paint (LCP) | ≤ 2.5s | Lighthouse |
| Time to Interactive (TTI) | ≤ 3.5s | Lighthouse |
| Cumulative Layout Shift (CLS) | ≤ 0.1 | Lighthouse |

### API 性能

| 指标 | 目标 | 测量工具 |
|------|------|----------|
| Response Time (P50) | ≤ 100ms | APM |
| Response Time (P95) | ≤ 200ms | APM |
| Response Time (P99) | ≤ 500ms | APM |
| Error Rate | ≤ 0.1% | APM |

---

## 安全检查清单

所有变更必须检查：

### 输入验证
- [ ] 使用 Zod 或类似库进行 schema 验证
- [ ] 验证所有用户输入
- [ ] 验证所有外部 API 响应

### SQL 注入防护
- [ ] 使用 Drizzle ORM（自动参数化查询）
- [ ] 禁止字符串拼接 SQL

### XSS 防护
- [ ] React 自动转义（默认安全）
- [ ] `dangerouslySetInnerHTML` 仅用于可信内容
- [ ] 使用 `DOMPurify` 清理用户 HTML

### CSRF 防护
- [ ] API 使用 Token 验证
- [ ] 关键操作需要重新验证

### 敏感数据加密
- [ ] 密码使用 `bcrypt` (rounds ≥ 10)
- [ ] 敏感数据使用 `crypto` 加密
- [ ] 环境变量存储密钥，不提交代码

### 认证授权
- [ ] JWT 签名验证
- [ ] Refresh token 存储在 httpOnly cookie
- [ ] 实现 rate limiting 防暴力破解

---

## 可访问性标准 (A11y)

- [ ] 所有图片有 `alt` 属性
- [ ] 表单控件有 `label`
- [ ] 语义化 HTML (`<nav>`, `<main>`, `<article>`)
- [ ] 键盘导航支持
- [ ] ARIA 属性正确使用
- [ ] 颜色对比度符合 WCAG AA 标准

---

## 引用说明

所有变更在 Phase 5 必须：

1. **通过所有质量门禁**
   ESLint, TypeScript, Tests, Build 全部成功

2. **满足性能标准**
   如果是用户可见功能，需要 Lighthouse 测试

3. **完成安全检查清单**
   特别是涉及用户输入、认证、支付的功能

4. **置信度过滤后的 issues 全部修复**
   confidence ≥ 80 的所有问题必须解决

---

## 豁免流程

如果某些约束无法满足，需要：

1. 在 PR 中明确说明原因
2. 提供替代方案或缓解措施
3. 获得团队 review 批准
4. 记录在 `exceptions.md`

---

## 更新日志

- **2025-01-02**: 初始版本
- 后续约束调整请记录在此
