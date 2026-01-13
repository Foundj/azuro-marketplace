# Detection Patterns Reference

> Pattern matching rules for claude-reflect learning capture

## Correction Patterns

| Pattern | Example | Confidence |
|---------|---------|------------|
| `no, use X` | "no, use gpt-5 not gpt-4" | 0.85 |
| `don't use` | "don't use that library" | 0.80 |
| `stop using` | "stop using deprecated API" | 0.80 |
| `that's wrong` | "that's wrong, it should be..." | 0.85 |
| `actually` | "actually, we use TypeScript here" | 0.75 |
| `use X not Y` | "use fetch not axios" | 0.90 |

## Positive Patterns

| Pattern | Example | Confidence |
|---------|---------|------------|
| `perfect!` | "perfect! that's exactly right" | 0.85 |
| `exactly right` | "exactly right, keep doing that" | 0.90 |
| `great approach` | "great approach to the problem" | 0.80 |
| `nailed it` | "you nailed it" | 0.85 |

## Explicit Markers

| Pattern | Example | Confidence |
|---------|---------|------------|
| `remember:` | "remember: always use ES modules" | 0.95 |
| `always` | "always add error handling" | 0.75 |
| `never` | "never commit .env files" | 0.75 |

## Confidence Calculation

```
base_confidence = pattern_weight
multiplier = 1.0 + (pattern_count - 1) * 0.05
final_confidence = min(0.95, base_confidence * multiplier)
```
