---
name: knowledge-graph
description: |
  This skill should be used when the user asks to "query knowledge", "find related solutions",
  "查知识库", "知识图谱", "related projects", "similar implementations", or uses keywords like
  "knowledge", "experience", "历史方案", "经验复用", "参考". Manages cross-project knowledge relationships
  and enables experience reuse across projects.
version: 4.2.10
triggers:
  - query knowledge
  - find related solutions
  - 查知识库
  - 知识图谱
  - related projects
  - similar implementations
  - 参考
  - 经验
  - 历史方案
  - 以前怎么做
---

# Knowledge Graph

> Cross-project knowledge management for experience reuse

## Trigger Phrases
- "query knowledge"
- "find related solutions"
- "查知识库"
- "知识图谱"
- "related projects"
- "similar implementations"

## Overview
...
(existing content)
...

## Agent Collaboration
- **@librarian**: Uses knowledge graph to provide historical context during research.
- **feature-planner**: Queries graph for similar project structures during Phase 1.

## Version History
- **1.0.0**: Initial release with local storage and ai-dev integration.


Knowledge Graph builds a network of project relationships to:

- Discover similar projects and solutions
- Reuse historical experience
- Avoid repeating mistakes
- Accelerate technical decisions

---

## Knowledge Node Types

| Type | Description | Example |
|------|-------------|---------|
| `project` | Project node | my-web-app |
| `technology` | Tech stack | React, TypeScript, Prisma |
| `pattern` | Design pattern | Repository Pattern, MVC |
| `decision` | Technical decision | Chose PostgreSQL over MySQL |
| `solution` | Solution record | JWT authentication implementation |
| `error` | Error record | CORS problem resolution |

## Relationship Types

| Relationship | Description |
|--------------|-------------|
| `uses` | Project uses technology |
| `implements` | Project implements pattern |
| `similar_to` | Similar projects |
| `depends_on` | Dependency relationship |
| `solved_by` | Problem solved by solution |
| `learned_from` | Learned from error |

---

## Usage

### Query Knowledge

```bash
/ai:knowledge                    # Query current project related knowledge
/ai:knowledge auth               # Query authentication related experience
/ai:knowledge similar            # Find similar projects
```

### Auto Integration

In ai-dev Phase 0 (Pre-check), automatically queries:

```
[Knowledge Graph] Searching related knowledge...

📚 Related Solutions Found:
1. JWT Authentication (from: user-portal)
   - Used in: 3 projects
   - Success rate: 95%
   - Key files: src/auth/jwt.ts

2. Session Management (from: admin-dashboard)
   - Similar tech stack
   - Includes: Redis session store
```

---

## Data Structure

### Knowledge Record

```json
{
  "id": "know-20250107-001",
  "type": "solution",
  "title": "JWT Authentication Implementation",
  "project": "user-portal",
  "tech_stack": ["Next.js", "TypeScript", "Prisma"],
  "description": "Complete JWT auth flow with refresh tokens",
  "key_files": [
    "src/auth/jwt.ts",
    "src/middleware/auth.ts"
  ],
  "tags": ["auth", "jwt", "security"],
  "created_at": "2025-01-07",
  "success_count": 3,
  "failure_count": 0
}
```

### Relationship Record

```json
{
  "from": "user-portal",
  "to": "jwt-authentication",
  "type": "implements",
  "strength": 0.9,
  "context": "Used for user login and API protection"
}
```

---

## Data Management

### Storage Location

Project level: `.claude-project/knowledge/`

```
.claude-project/
└── knowledge/
    ├── nodes.json      # Knowledge nodes
    ├── relations.json  # Relationships
    └── index.json      # Index
```

### Auto Cleanup Strategy

```yaml
max_records: 50           # Maximum records
retention_days: 30        # Retention period
cleanup_on_start: true    # Cleanup on startup

cleanup_priority:
  1. Records older than 30 days
  2. Records with success_count = 0
  3. Oldest records (when exceeding 50)
```

### Manual Cleanup

```bash
${CLAUDE_PLUGIN_ROOT}/skills/knowledge-graph/scripts/cleanup.sh
```

---

## Knowledge Recording

### Automatic Recording

ai-dev workflow automatically records:
- On Phase 6 (Archive) success
- When solution is marked as valuable

### Manual Recording

```bash
/ai:knowledge add "Implemented OAuth2 third-party login"
```

---

## Query Examples

### Tech Stack Matching

```
Query: "React + TypeScript state management"

Results:
1. Zustand (from: dashboard-app)
   - Simple and easy to use, suitable for small/medium projects
   - Usage count: 5

2. Redux Toolkit (from: enterprise-portal)  
   - Full-featured, suitable for large projects
   - Usage count: 3
```

### Error Resolution

```
Query: "CORS cross-origin issues"

Results:
1. Next.js API Routes CORS Configuration
   - Solution: next.config.js headers configuration
   - Success rate: 100%

2. Express CORS Middleware
   - Solution: cors npm package
   - Note: Need to configure credentials
```

---

## Integration with ai-dev

```
┌─────────────────────────────────────────┐
│           ai-dev Workflow               │
├─────────────────────────────────────────┤
│                                         │
│  Phase 0 (Pre-check)                    │
│  └── knowledge-graph: Query knowledge   │
│                                         │
│  Phase 4 (Implementation)               │
│  └── knowledge-graph: Reference history │
│                                         │
│  Phase 6 (Archive)                      │
│  └── knowledge-graph: Record knowledge  │
│                                         │
└─────────────────────────────────────────┘
```

---

## Privacy

- Knowledge graph data is **stored locally only**
- Does not contain sensitive information (keys, passwords)
- Delete `.claude-project/knowledge/` to clear all data

---

## Dependencies

- `jq` - JSON processing
- `bash` - Script execution
