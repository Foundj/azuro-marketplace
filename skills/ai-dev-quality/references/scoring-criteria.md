# Quality Scoring Criteria Reference

> Confidence scoring rules for ai-dev-quality

## Confidence Score Calculation

| Factor | Weight | Description |
|--------|--------|-------------|
| Evidence | 40% | Concrete proof vs speculation |
| Impact | 30% | Severity if issue occurs |
| Likelihood | 20% | Probability of occurrence |
| Fixability | 10% | Effort to resolve |

**Filter**: Only issues ≥80 reported to users.

## Quality Gate Dimensions

| Dimension | Weight | Checks |
|-----------|--------|--------|
| Security | 40% | OWASP Top 10, secrets, auth |
| Code Quality | 30% | Complexity, duplication |
| Documentation | 20% | Comments, README |
| Architecture | 10% | Patterns, coupling |

**Pass Threshold**: Overall ≥80

## Security Checks (40%)

- No hardcoded secrets
- SQL parameterized queries
- XSS/CSRF protection
- Auth correctly implemented

## Code Quality Checks (30%)

- Function length < 50 lines
- Cyclomatic complexity < 10
- No duplicate blocks > 10 lines
- Naming follows conventions

## Documentation Checks (20%)

- Public functions documented
- README updated
- API docs (if applicable)

## Architecture Checks (10%)

- Single responsibility
- Correct dependency direction
- No circular dependencies

## Report Format

```
╔════════════════════════════════════╗
║       QUALITY GATE REPORT          ║
╠════════════════════════════════════╣
║ Security     │ 90/100 │ ✅ PASS   ║
║ Code Quality │ 75/100 │ ✅ PASS   ║
║ Documentation│ 65/100 │ ✅ PASS   ║
║ Architecture │ 80/100 │ ✅ PASS   ║
╠════════════════════════════════════╣
║ TOTAL: 79.5/100  STATUS: ✅ PASS  ║
╚════════════════════════════════════╝
```
