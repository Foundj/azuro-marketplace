# Atomic Task Patterns

## 2-5 Minute Task Structure

```markdown
### Task N: [Action Verb] [Component]

**Files:**
- Create/Update: `path/to/file.ext`

**Step 1:** [Specific action]
```language
// code
```

**Step 2:** Verify
```bash
command to verify
```

Expected: [result]

**Time Estimate:** X minutes
```

## TDD Task Pattern

```markdown
### Task N: Write failing test for [feature]

**Files:**
- Create: `tests/test_feature.py`

**Step 1:** Write the failing test
**Step 2:** Run test to verify it fails
Expected: FAIL

---

### Task N+1: Implement minimal code

**Files:**
- Create: `src/feature.py`

**Step 1:** Write minimal implementation
**Step 2:** Run test to verify it passes
Expected: PASS
```
