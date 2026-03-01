---
name: tdd-enforcement
description: |
  This skill should be used when implementing any feature, bugfix, or refactoring code.
  It enforces strict Test-Driven Development discipline with the Iron Law:
  "NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST". Code written before tests must be
  deleted and rewritten. Triggers on "TDD", "test first", "红绿重构", "implementing feature",
  "writing code", "bug fix", "refactoring", "behavior change". No exceptions without
  explicit user permission.
version: 6.0.7
status: ga
profile: dev
triggers:
  - implementing feature
  - writing code
  - bug fix
  - refactoring
  - behavior change
  - TDD
  - test first
  - 红绿重构
  - 测试优先
  - TDD强制
  - 先写测试
---

# Test-Driven Development (TDD) Enforcement

> **Adapted from Superpowers by obra** - The gold standard for TDD discipline.

## 触发词

此技能触发于: "TDD", "test first", "红绿重构", "测试优先", "implementing feature", "writing code".

## The Iron Law

```
╔═══════════════════════════════════════════════════════════════╗
║                                                               ║
║   NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST             ║
║                                                               ║
║   Write code before the test? DELETE IT. Start over.          ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

**No exceptions:**
- Don't keep it as "reference"
- Don't "adapt" it while writing tests
- Don't look at it
- **Delete means delete**

Implement fresh from tests. Period.

## Core Principle

> If you didn't watch the test fail, you don't know if it tests the right thing.

**Violating the letter of the rules is violating the spirit of the rules.**

## When to Use

**Always:**
- New features
- Bug fixes
- Refactoring
- Behavior changes

**Exceptions (ask your human partner):**
- Throwaway prototypes
- Generated code
- Configuration files

Thinking "skip TDD just this once"? Stop. That's rationalization.

## Red-Green-Refactor Cycle

```
    ┌─────────────────────────────────────────────────────┐
    │                                                     │
    │   ┌─────────┐    ┌─────────┐    ┌──────────────┐   │
    │   │   RED   │───▶│  GREEN  │───▶│   REFACTOR   │   │
    │   │  Write  │    │ Minimal │    │   Clean up   │   │
    │   │ failing │    │  code   │    │              │   │
    │   │  test   │    │         │    │              │   │
    │   └─────────┘    └─────────┘    └──────────────┘   │
    │        ▲                               │           │
    │        └───────────────────────────────┘           │
    │                    REPEAT                          │
    └─────────────────────────────────────────────────────┘
```

### Step 1: RED - Write Failing Test

Write ONE minimal test showing what should happen.

**Good Example:**
```typescript
test('retries failed operations 3 times', async () => {
  let attempts = 0;
  const operation = () => {
    attempts++;
    if (attempts < 3) throw new Error('fail');
    return 'success';
  };

  const result = await retryOperation(operation);

  expect(result).toBe('success');
  expect(attempts).toBe(3);
});
```
✅ Clear name, tests real behavior, one thing

**Bad Example:**
```typescript
test('retry works', async () => {
  const mock = jest.fn()
    .mockRejectedValueOnce(new Error())
    .mockResolvedValueOnce('success');
  await retryOperation(mock);
  expect(mock).toHaveBeenCalledTimes(2);
});
```
❌ Vague name, tests mock not code

**Requirements:**
- One behavior per test
- Clear descriptive name
- Real code (no mocks unless unavoidable)

### Step 2: Verify RED - Watch It Fail

**MANDATORY. Never skip.**

```bash
npm test path/to/test.test.ts
# or
pytest tests/test_feature.py -v
```

**Confirm:**
- Test fails (not errors)
- Failure message is expected
- Fails because feature missing (not typos)

**Test passes?** You're testing existing behavior. Fix test.

**Test errors?** Fix error, re-run until it fails correctly.

### Step 3: GREEN - Minimal Code

Write the SIMPLEST code to pass the test.

**Good Example:**
```typescript
async function retryOperation<T>(fn: () => Promise<T>): Promise<T> {
  for (let i = 0; i < 3; i++) {
    try {
      return await fn();
    } catch (e) {
      if (i === 2) throw e;
    }
  }
  throw new Error('unreachable');
}
```
✅ Just enough to pass

**Bad Example:**
```typescript
async function retryOperation<T>(
  fn: () => Promise<T>,
  options?: {
    maxRetries?: number;
    backoff?: 'linear' | 'exponential';
    onRetry?: (attempt: number) => void;
  }
): Promise<T> {
  // YAGNI - You Aren't Gonna Need It
}
```
❌ Over-engineered

**Don't add features, refactor other code, or "improve" beyond the test.**

### Step 4: Verify GREEN - Watch It Pass

**MANDATORY.**

```bash
npm test path/to/test.test.ts
```

**Confirm:**
- Test passes
- Other tests still pass
- Output pristine (no errors, warnings)

**Test fails?** Fix code, not test.

**Other tests fail?** Fix now.

### Step 5: REFACTOR - Clean Up

**After green only:**
- Remove duplication
- Improve names
- Extract helpers

Keep tests green. Don't add behavior.

### Step 6: COMMIT

```bash
git add tests/ src/
git commit -m "feat: add specific feature"
```

Then repeat for next failing test.

## Common Rationalizations - REJECTED

| Excuse | Reality |
|--------|---------|
| "Too simple to test" | Simple code breaks. Test takes 30 seconds. |
| "I'll test after" | Tests passing immediately prove nothing. |
| "Tests after achieve same goals" | Tests-after = "what does this do?" Tests-first = "what should this do?" |
| "Already manually tested" | Ad-hoc ≠ systematic. No record, can't re-run. |
| "Deleting X hours is wasteful" | Sunk cost fallacy. Keeping unverified code is technical debt. |
| "Keep as reference, write tests first" | You'll adapt it. That's testing after. Delete means delete. |
| "Need to explore first" | Fine. Throw away exploration, start with TDD. |
| "Test hard = design unclear" | Listen to test. Hard to test = hard to use. |
| "TDD will slow me down" | TDD faster than debugging. Pragmatic = test-first. |
| "Manual test faster" | Manual doesn't prove edge cases. You'll re-test every change. |
| "Existing code has no tests" | You're improving it. Add tests for code you change. |

## Red Flags - STOP and Start Over

If you encounter any of these, **DELETE code and restart with TDD:**

- ❌ Code before test
- ❌ Test after implementation
- ❌ Test passes immediately (without failing first)
- ❌ Can't explain why test failed
- ❌ Tests added "later"
- ❌ Rationalizing "just this once"
- ❌ "I already manually tested it"
- ❌ "Tests after achieve the same purpose"
- ❌ "It's about spirit not ritual"
- ❌ "Keep as reference" or "adapt existing code"
- ❌ "Already spent X hours, deleting is wasteful"
- ❌ "TDD is dogmatic, I'm being pragmatic"
- ❌ "This is different because..."

**All of these mean: Delete code. Start over with TDD.**

## Bug Fix Example

**Bug:** Empty email accepted

**RED:**
```typescript
test('rejects empty email', async () => {
  const result = await submitForm({ email: '' });
  expect(result.error).toBe('Email required');
});
```

**Verify RED:**
```bash
$ npm test
FAIL: expected 'Email required', got undefined
```

**GREEN:**
```typescript
function submitForm(data: FormData) {
  if (!data.email?.trim()) {
    return { error: 'Email required' };
  }
  // ...
}
```

**Verify GREEN:**
```bash
$ npm test
PASS
```

**REFACTOR:** Extract validation for multiple fields if needed.

**COMMIT:**
```bash
git commit -m "fix: reject empty email in form submission"
```

## Verification Checklist

Before marking work complete:

- [ ] Every new function/method has a test
- [ ] Watched each test fail before implementing
- [ ] Each test failed for expected reason (feature missing, not typo)
- [ ] Wrote minimal code to pass each test
- [ ] All tests pass
- [ ] Output pristine (no errors, warnings)
- [ ] Tests use real code (mocks only if unavoidable)
- [ ] Edge cases and errors covered

**Can't check all boxes? You skipped TDD. Start over.**

## When Stuck

| Problem | Solution |
|---------|----------|
| Don't know how to test | Write wished-for API. Write assertion first. Ask your human partner. |
| Test too complicated | Design too complicated. Simplify interface. |
| Must mock everything | Code too coupled. Use dependency injection. |
| Test setup huge | Extract helpers. Still complex? Simplify design. |

## Testing Anti-Patterns to Avoid

- ❌ Testing mock behavior instead of real behavior
- ❌ Adding test-only methods to production classes
- ❌ Mocking without understanding dependencies
- ❌ Tests that pass with any implementation
- ❌ Tests that break when refactoring (testing implementation, not behavior)

## Final Rule

```
Production code → test exists and failed first
Otherwise → not TDD
```

**No exceptions without your human partner's explicit permission.**

## Integration

**Used by:**
- `ultrawork` - Enforces TDD in all implementations
- `subagent-driven-development` - Subagents follow TDD
- `ai-dev:quick-fixer` - Quick fixes with TDD

**Pairs with:**
- `spec-compliance-review` - Verifies implementation matches spec
- `code-reviewer` - Reviews code quality after TDD

---

## Dependencies

- Requires test framework (Jest, pytest, etc.)
- Works with `ultrawork` and `subagent-driven-development`

---

## Version History

| Version | Changes |
|---------|---------|
| 5.0.20 | Added Chinese triggers and dependencies |
| 5.0.0 | Initial release with Iron Law pattern |
