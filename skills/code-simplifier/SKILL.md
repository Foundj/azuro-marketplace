---
name: code-simplifier
description: |
  This skill should be used when the user wants to simplify, refine, or refactor code for clarity,
  consistency, and maintainability. It includes SOLID principles checking, complexity metrics analysis,
  and refactoring pattern recommendations. Use when the user mentions "simplify code", "refine code",
  "clean up code", "refactor", "reduce complexity", "technical debt", "代码简化", "代码重构", "优化",
  "技术债务", or after code review passes.
version: 4.2.12
triggers:
  - simplify code
  - refine code
  - clean up code
  - polish code
  - improve readability
  - refactor
  - reduce complexity
  - technical debt
  - 代码简化
  - 代码优化
  - 优化
  - 整理代码
  - 代码重构
  - 技术债务
  - 重构
---

# Code Simplifier & Refactoring Expert

> Expert code simplification with SOLID principles, complexity metrics, and refactoring patterns.

## Quick Start

```bash
@code-simplifier review recent changes    # Simplify recently modified code
@code-simplifier refine src/api/          # Simplify specific directory
@code-simplifier solid-check src/         # Check SOLID principles compliance
@code-simplifier metrics src/utils.ts     # Analyze complexity metrics
```

## Core Principles

### 1. Preserve Functionality
- Never change what the code does - only how it does it
- All original features, outputs, and behaviors must remain intact

### 2. Apply Project Standards
Follow established coding standards from CLAUDE.md:
- ES modules with proper import sorting
- Prefer `function` keyword over arrow functions
- Explicit return type annotations
- Proper React component patterns
- Consistent naming conventions

### 3. Enhance Clarity
- Reduce unnecessary complexity and nesting
- Eliminate redundant code and abstractions
- Improve variable and function names
- Remove unnecessary comments
- **Avoid nested ternaries** - prefer switch/if-else

### 4. Maintain Balance
Avoid over-simplification that could:
- Reduce code clarity or maintainability
- Create overly clever solutions
- Combine too many concerns
- Remove helpful abstractions
- Prioritize "fewer lines" over readability

---

## SOLID Principles Checking

### S - Single Responsibility Principle
```yaml
check: Does each class/function have one reason to change?
symptoms:
  - Class with multiple unrelated methods
  - Function doing more than one thing
  - God objects with too many responsibilities
fix: Extract into focused, cohesive units
```

### O - Open/Closed Principle
```yaml
check: Is code open for extension but closed for modification?
symptoms:
  - Switch statements on type
  - Repeated if-else chains checking type
  - Modifying existing code to add features
fix: Use polymorphism, strategy pattern, or composition
```

### L - Liskov Substitution Principle
```yaml
check: Can subtypes replace their base types?
symptoms:
  - Subclass overrides breaking parent behavior
  - Empty method implementations in subclasses
  - Type checks before method calls
fix: Redesign inheritance hierarchy or use composition
```

### I - Interface Segregation Principle
```yaml
check: Are interfaces focused and minimal?
symptoms:
  - Interfaces with many unrelated methods
  - Implementing classes with empty methods
  - "Fat" interfaces
fix: Split into smaller, role-specific interfaces
```

### D - Dependency Inversion Principle
```yaml
check: Do high-level modules depend on abstractions?
symptoms:
  - Direct instantiation of dependencies
  - Hardcoded concrete class references
  - Tight coupling between modules
fix: Inject dependencies, depend on interfaces
```

---

## Complexity Metrics

### Cyclomatic Complexity
```
Target: < 10 per function

Calculation:
- Start with 1
- +1 for each: if, else if, for, while, case, catch, &&, ||, ?:

Levels:
  1-5   : ✅ Simple, easy to test
  6-10  : 🟡 Moderate, consider splitting
  11-20 : 🟠 Complex, should refactor
  21+   : 🔴 Very complex, must refactor
```

### Cognitive Complexity
```
Target: < 15 per function

Factors:
- Nesting depth (exponential penalty)
- Control flow breaks (continue, break, goto)
- Recursion
- Boolean logic complexity
```

### Function Length
```
Target: < 50 lines

Guidelines:
  < 20 lines : ✅ Ideal
  20-50 lines: 🟡 Acceptable
  50+ lines  : 🔴 Too long, extract methods
```

### Code Duplication
```
Target: No duplicate blocks > 10 lines

Detection:
- Exact duplicates
- Near-duplicates (renamed variables)
- Structural duplicates (same logic, different types)
```

---

## Refactoring Patterns Catalog

### Extract Method
```
When: Function too long, code block with comment
Before: Large function with multiple responsibilities
After: Multiple focused functions with descriptive names
```

### Replace Conditional with Polymorphism
```
When: Switch on type, repeated type checks
Before: switch(type) { case 'A': ...; case 'B': ... }
After: type.execute() using interface/abstract class
```

### Introduce Parameter Object
```
When: Function has > 3 related parameters
Before: function(x, y, width, height)
After: function(rect: Rectangle)
```

### Replace Temp with Query
```
When: Temp variable used once after calculation
Before: const total = price * qty; return total;
After: return calculateTotal(price, qty);
```

### Decompose Conditional
```
When: Complex boolean condition
Before: if (date.before(SUMMER_START) || date.after(SUMMER_END))
After: if (isNotSummer(date))
```

### Replace Magic Number with Constant
```
When: Literal number in code
Before: if (age >= 18)
After: if (age >= LEGAL_ADULT_AGE)
```

## Refinement Process

```
┌─────────────────────────────────────────────────────────┐
│           ENHANCED SIMPLIFICATION FLOW                   │
├─────────────────────────────────────────────────────────┤
│  1. IDENTIFY target code                                │
│     - Recently modified files (git diff)                │
│     - Specified directories/files                       │
│                    ↓                                    │
│  2. MEASURE complexity metrics                          │
│     - Cyclomatic complexity per function                │
│     - Cognitive complexity score                        │
│     - Function length analysis                          │
│     - Duplication detection                             │
│                    ↓                                    │
│  3. CHECK SOLID principles                              │
│     - Single Responsibility violations                  │
│     - Open/Closed compliance                            │
│     - Dependency Inversion issues                       │
│                    ↓                                    │
│  4. APPLY refactoring patterns                          │
│     - Select appropriate patterns                       │
│     - Preserve functionality                            │
│     - Follow project standards                          │
│                    ↓                                    │
│  5. VERIFY and REPORT                                   │
│     - Before/after metrics comparison                   │
│     - Behavior validation                               │
│     - Generate improvement report                       │
└─────────────────────────────────────────────────────────┘
```

---

## Output: Simplification Report

```markdown
# Code Simplification Report

## Metrics Summary
| File | Before CC | After CC | Δ | Status |
|------|-----------|----------|---|--------|
| src/api/users.ts | 15 | 8 | -7 | ✅ Improved |
| src/utils/format.ts | 22 | 10 | -12 | ✅ Improved |

## SOLID Violations Fixed
1. **SRP**: Extracted `validateUser()` from `createUser()`
2. **DIP**: Introduced `IUserRepository` interface

## Refactoring Applied
- Extract Method: 3 instances
- Decompose Conditional: 2 instances
- Replace Magic Number: 5 instances

## Technical Debt Reduced
- Lines removed: 45
- Duplication eliminated: 2 blocks
- Complexity reduction: 35%
```

## Integration with ai-dev Workflow

Runs automatically after Phase 5 (Quality Validation) when quality gate passes and `autoSimplify: true` is set:

```
Phase 5: Quality Validation
         ↓
    Gate Pass?
    ├── No → Fix issues, re-run Phase 5
    └── Yes ↓

Phase 5.5: Code Simplification (auto when enabled)
  - SOLID principles check
  - Complexity metrics analysis
  - Apply refactoring patterns
  - Ensure consistency
         ↓

Phase 6: Finalization
  - Commit ready code
```

**Manual Trigger**: Say "优化代码", "simplify", "refactor" at any time.

## Configuration

Enable auto-simplification in `codebox/config.json`:

```json
{
  "quality": {
    "autoSimplify": true,
    "simplifyScope": "recent",  // "recent" | "changed" | "all"
    "preserveComments": false
  }
}
```

## Examples

### Before
```typescript
const getUserData = async (id: string) => {
  try {
    const response = await fetch(`/api/users/${id}`);
    if (response.ok) {
      const data = await response.json();
      return data;
    } else {
      throw new Error('Failed');
    }
  } catch (e) {
    console.error(e);
    return null;
  }
};
```

### After
```typescript
async function getUserData(id: string): Promise<User | null> {
  const response = await fetch(`/api/users/${id}`);
  if (!response.ok) return null;
  return response.json();
}
```

## When to Use

| Scenario | Recommendation |
|----------|----------------|
| After implementing feature | ✅ Run to polish |
| After fixing bug | ✅ Clean up fix |
| Before major commit | ✅ Ensure consistency |
| During code review | ✅ Suggest improvements |
| Legacy code refactor | ⚠️ Be careful with scope |

## Model Recommendation

Uses **Opus** model for best results - requires nuanced understanding of code context and project-specific patterns.

---

## Anti-AI-Slop Principles

> 避免生成可预测、通用的「AI 味」代码

### 什么是 AI Slop？

AI Slop 是指 AI 生成的代码虽然「正确」，但缺乏个性，充满可预测的模式：

```
🔴 AI Slop 特征:
- 过度注释 (注释比代码还多)
- 过度抽象 (一次性逻辑也封装)
- 过度防御 (不可能的场景也处理)
- 通用命名 (dataHandler, processItem)
- 模板化结构 (每个函数都一样的格式)
```

### Anti-Slop 原则

#### 1. 上下文适配 (Context-Aware)

```yaml
原则: 代码风格应匹配项目既有风格
检测:
  - 与周围代码风格不一致
  - 使用项目未采用的模式
修复:
  - 读取 CLAUDE.md 了解项目风格
  - 参考临近代码的写法
```

#### 2. 注释克制 (Comment Restraint)

```yaml
原则: 代码应自解释，注释只用于「为什么」不是「是什么」
检测:
  - 解释显而易见的代码
  - 注释重复函数/变量名
  - 过多的 JSDoc 样板
修复:
  - 删除冗余注释
  - 用更好的命名替代注释
```

**反例**:
```typescript
// ❌ 过度注释
// Get the user by ID
async function getUserById(id: string) {
  // Make API call to get user
  const response = await fetch(`/api/users/${id}`);
  // Parse the response as JSON
  return response.json();
}

// ✅ 简洁
async function getUserById(id: string) {
  const response = await fetch(`/api/users/${id}`);
  return response.json();
}
```

#### 3. 抽象必要性 (Abstraction Necessity)

```yaml
原则: 只在有复用需求时抽象，三次规则
检测:
  - 单次使用的工具函数
  - 只有一个实现的接口
  - 过早的「可扩展性」设计
修复:
  - 删除不必要的抽象
  - 内联只用一次的函数
```

**反例**:
```typescript
// ❌ 过度抽象 (只用一次)
const formatUserName = (user: User) => `${user.firstName} ${user.lastName}`;
const greeting = `Hello, ${formatUserName(user)}`;

// ✅ 直接写
const greeting = `Hello, ${user.firstName} ${user.lastName}`;
```

#### 4. 错误处理适度 (Error Handling)

```yaml
原则: 只处理可能发生的错误
检测:
  - 内部代码的防御性检查
  - 不可能的 null 检查
  - 捕获后只是重新抛出
修复:
  - 信任内部代码
  - 只在边界验证
```

**反例**:
```typescript
// ❌ 过度防御
function add(a: number, b: number): number {
  if (typeof a !== 'number' || typeof b !== 'number') {
    throw new Error('Invalid arguments');
  }
  if (Number.isNaN(a) || Number.isNaN(b)) {
    throw new Error('NaN not allowed');
  }
  return a + b;
}

// ✅ 信任类型系统
function add(a: number, b: number): number {
  return a + b;
}
```

#### 5. 命名具体化 (Specific Naming)

```yaml
原则: 命名应反映具体用途，不是通用动作
检测:
  - dataHandler, processItem, executeAction
  - manager, service, helper (无具体语义)
  - temp, data, result (无意义)
修复:
  - 使用领域术语
  - 描述具体行为
```

**反例**:
```typescript
// ❌ 通用命名
const dataHandler = (data) => { ... }
const userManager = new Manager();

// ✅ 具体命名
const enrichOrderWithShipping = (order) => { ... }
const authenticationService = new AuthService();
```

### Anti-Slop 检查清单

在简化代码时，检查是否避免了以下问题：

| 问题 | 检测方法 |
|------|----------|
| 过度注释 | 注释行数 > 代码行数 20% |
| 过度抽象 | 函数只被调用一次 |
| 过度防御 | 内部函数有参数验证 |
| 通用命名 | 包含 data/handler/manager/process |
| 模板化 | 每个函数格式完全一样 |

### 与项目风格对齐

简化代码时，**必须**先读取项目的：

1. `CLAUDE.md` - 了解编码规范
2. 邻近文件 - 了解既有风格
3. 测试文件 - 了解预期行为

生成的代码应该看起来像是「由项目现有开发者写的」，而不是「由 AI 生成的」。

---

## Agent Collaboration

| Agent | Role |
|-------|------|
| `@code-reviewer` | 先审查代码，发现问题后触发 simplifier |
| `@oracle` | 复杂重构决策时咨询架构建议 |
| `@librarian` | 查询项目历史模式和最佳实践 |

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 4.2.6 | 2026-01-13 | Add 优化/重构 triggers, third-person description |
| 4.2.4 | 2026-01-13 | Add Anti-AI-Slop principles, SOLID checking |
| 4.0.0 | 2026-01-07 | Initial release with basic simplification |
