# Memory Systems Reference

> Extracted from Agent-Skills-for-Context-Engineering

## Core Insight

Memory provides persistence that allows agents to maintain continuity across sessions. Simple vector stores lack relationship and temporal structure. Knowledge graphs preserve relationships. Temporal knowledge graphs add validity periods.

## Memory Architecture Layers

| Layer | Latency | Persistence | Use Case |
|-------|---------|-------------|----------|
| Working Memory | Zero | Volatile | Current context window |
| Short-Term Memory | Low | Session | Searchable within session |
| Long-Term Memory | Medium | Cross-session | Learn from past interactions |
| Entity Memory | Medium | Permanent | Track entities and relationships |
| Temporal KG | Medium | Permanent | Time-aware facts with validity |

## Benchmark Performance

| Memory System | Accuracy | Retrieval Latency | Notes |
|---------------|----------|-------------------|-------|
| Zep (Temporal KG) | 94.8% | 2.58s | Best accuracy, fast |
| MemGPT | 93.4% | Variable | Good general performance |
| GraphRAG | ~75-85% | Variable | 20-35% gains over baseline |
| Vector RAG | ~60-70% | Fast | Loses relationship structure |
| Recursive Summarization | 35.3% | Low | Severe information loss |

## Why Vector Stores Fall Short

- Lose relationship information (can't traverse connections)
- No temporal validity (can't distinguish current vs outdated)
- Can't answer "What products did customers who bought X also buy?"

## Implementation Patterns

### Pattern 1: File-System-as-Memory

```
memory/
├── entities/
│   ├── user-123.json
│   └── project-abc.json
├── patterns/
│   └── auth-pattern-001.json
└── errors/
    └── xss-vulnerability-001.json
```

**Advantages**: Simple, transparent, portable
**Disadvantages**: No semantic search, manual organization

### Pattern 2: Vector RAG with Metadata

```python
memory.store({
    "text": "User prefers dark mode",
    "metadata": {
        "entity": "user-123",
        "valid_from": "2025-01-01",
        "confidence": 0.9
    }
})
```

### Pattern 3: Knowledge Graph

```
(User)-[PREFERS]->(DarkMode)
(User)-[WORKS_ON]->(Project)
(Project)-[USES]->(TypeScript)
```

### Pattern 4: Temporal Knowledge Graph

```python
def query_address_at_time(user_id, query_time):
    return graph.query("""
        MATCH (user)-[r:LIVES_AT]->(address)
        WHERE user.id = $user_id
        AND r.valid_from <= $query_time
        AND (r.valid_until IS NULL OR r.valid_until > $query_time)
        RETURN address
    """)
```

## Application to ai-dev

| ai-dev Component | Memory Type |
|---------------------------|-------------|
| codebox/knowledge/patterns.json | Long-Term (structured) |
| codebox/knowledge/errors.json | Long-Term (structured) |
| ~/.claude/learnings-queue.json | Short-Term (pending) |
| CLAUDE.md | Permanent (preferences) |
| changes/active/{id}/state.json | Working (current task) |

## Memory Selection Guide

| Requirement | Recommended System |
|-------------|-------------------|
| Simple persistence | File-system memory |
| Semantic search | Vector RAG with metadata |
| Relationship reasoning | Knowledge graph |
| Temporal validity | Temporal knowledge graph |
| Cross-agent state | File-system + indexing |

## Memory Consolidation

Memories accumulate and require periodic consolidation:

1. Identify outdated facts
2. Merge related facts
3. Update validity periods
4. Archive or delete obsolete facts
5. Rebuild indexes

**Triggers**: After significant accumulation, periodic schedule, explicit request

## Guidelines

1. Match architecture to query requirements
2. Use temporal validity to prevent outdated conflicts
3. Consolidate memories periodically
4. Design for retrieval failures gracefully
5. Consider privacy implications
6. Monitor memory growth over time

## Integration with codebox

```
codebox/
├── knowledge/
│   ├── patterns.json      # Successful patterns (graph-like)
│   ├── errors.json        # Error prevention (graph-like)
│   └── entities.json      # Entity tracking (optional)
├── research/
│   └── {topic}-research.json  # Research results (temporal)
└── changes/
    └── active/{id}/
        └── state.json     # Working memory (volatile)
```
