# SOLID Principles & Complexity Metrics

> SOLID 原则检查和复杂度指标详细说明

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
  - Subclass throwing unexpected exceptions
fix: Redesign inheritance hierarchy or use composition
```

### I - Interface Segregation Principle
```yaml
check: Are interfaces specific to clients?
symptoms:
  - Clients forced to implement unused methods
  - "Fat" interfaces with many methods
  - Interface changes affecting many clients
fix: Split into smaller, specific interfaces
```

### D - Dependency Inversion Principle
```yaml
check: Do high-level modules depend on abstractions?
symptoms:
  - Direct instantiation with `new`
  - Hard-coded dependencies
  - Difficulty in testing
fix: Use dependency injection and interfaces
```

---

## Complexity Metrics

### Cyclomatic Complexity

**Formula**: CC = E - N + 2 (E = edges, N = nodes)

```yaml
Thresholds:
  1-10: Simple, low risk
  11-20: Moderate risk
  21-50: High risk
  50+: Untestable, must refactor
```

**Example**:
```typescript
// CC = 1 (simple)
function add(a: number, b: number) {
  return a + b;
}

// CC = 4 (multiple paths)
function process(value: string | null) {
  if (!value) return null;        // +1
  if (value.startsWith('error')) { // +1
    return handleError(value);     // +1
  }
  return processValue(value);      // +1
}
```

### Cognitive Complexity

**Focuses on readability**, penalizing:
- Nesting: +1 per level
- Boolean operators: +1 for `&&`, `||`
- Control flow: +1 for `if`, `for`, `while`

```yaml
Thresholds:
  0-5: Easy to understand
  6-10: Moderate complexity
  11-20: High complexity
  20+: Very complex, refactor recommended
```

---

## Refactoring Patterns

| Pattern | When to Use | Example |
|---------|-------------|---------|
| Extract Function | Long function, repeated logic | Inline → Named function |
| Extract Variable | Complex expression | `const isEligible = ...` |
| Replace Nested Conditional | Deep nesting | Guard clauses |
| Decompose Conditional | Complex if-else | Extract conditions |
| Consolidate Duplicate | Repeated code blocks | Single function |
| Introduce Parameter Object | Many parameters | Options object |
| Remove Assignments to Parameters | Parameter mutation | Use temp variable |