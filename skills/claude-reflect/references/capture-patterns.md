# Capture Patterns

## Detection Methods

### Regex Patterns (Real-time)

```python
CORRECTION_PATTERNS = [
    (r'\bno[,\s]+(use|don\'?t use|not)\b', 0.80),
    (r'\b(stop using|don\'?t use)\b', 0.75),
    (r'\bthat\'?s wrong\b', 0.70),
    (r'\bactually[,\s]+\b', 0.70),
    (r'\buse\s+\S+\s+not\s+\S+', 0.85),
    (r'\bremember:\s*', 0.90),
]
```

### Confidence Scoring

| Pattern | Confidence | Decay Days |
|---------|------------|------------|
| Explicit "remember:" | 0.90 | 365 |
| Strong negation | 0.85 | 180 |
| Medium negation | 0.70 | 90 |
| Positive feedback | 0.60 | 30 |

### Decay Formula

```
effective_confidence = confidence * (1 - (age_days / decay_days))
```

- Stale threshold: `effective_confidence < 0.3`
- Permanence after application to CLAUDE.md