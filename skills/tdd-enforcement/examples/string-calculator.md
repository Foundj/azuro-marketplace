# TDD Examples

## Example 1: String Calculator

### Step 1: RED (Fail)
Write a test that fails.
```typescript
test('add(1, 2) should return 3', () => {
  expect(add(1, 2)).toBe(3);
});
```
Result: `ReferenceError: add is not defined`

### Step 2: GREEN (Pass)
Write minimal code.
```typescript
function add(a, b) {
  return 3; // Minimal possible implementation
}
```
Result: `PASS`

### Step 3: REFACTOR
Improve code while keeping it green.
```typescript
function add(a, b) {
  return a + b;
}
```
Result: `PASS`
