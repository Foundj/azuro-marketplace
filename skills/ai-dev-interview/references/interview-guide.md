# Interview Guide Reference

> Best practices for ai-dev-interview

## Interview Rounds by Complexity

| Complexity | Rounds | Examples |
|------------|--------|----------|
| Simple | 2 | Bug fix, small update |
| Medium | 3-4 | New endpoint, component |
| Complex | 5-6 | New system, major refactor |

## Question Categories

### Functional Questions
- What should this feature do?
- What are the expected inputs/outputs?
- What are the edge cases?

### Technical Questions
- Any technology preferences?
- Integration requirements?
- Performance constraints?

### Business Questions
- Who are the users?
- What's the priority?
- Any deadlines?

## Risk Detection

| Level | Icon | Action |
|-------|------|--------|
| 🔴 Blocking | ❌ | Must resolve |
| 🟡 Warning | ⚠️ | User decides |
| 🟢 Info | ℹ️ | Note in proposal |

## Parallel Context Collection

```javascript
await Promise.all([
  scanProjectStructure(),
  queryKnowledgeBase(),
  loadResearchResults()
]);
```

## Output: proposal.md

- Summary
- Requirements (numbered)
- Constraints
- Risks identified
- Research references
- Next steps
