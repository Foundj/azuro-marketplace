# Spec Compliance Review Example

## Input Specification
Implement a function `add(a, b)` that returns the sum of two numbers.
- Must handle negative numbers.
- Must throw an error if inputs are not numbers.

## Implementer Report
Implemented `add` function with validation.

## Actual Code
```typescript
function add(a, b) {
  if (typeof a !== 'number' || typeof b !== 'number') {
    throw new Error('Inputs must be numbers');
  }
  console.log('Adding numbers'); // EXTRA WORK (not requested)
  return a + b;
}
```

## Reviewer Findings
- ✅ Missing Requirements: None
- ❌ Extra/Unneeded Work: Added `console.log` which wasn't in spec.
- ✅ Misunderstandings: None

## Result
❌ ISSUES FOUND: Remove `console.log` on line 5.
