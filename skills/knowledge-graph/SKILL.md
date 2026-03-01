---
name: knowledge-graph
description: |
  This skill should be used when the user asks to "query knowledge", "find related solutions",
  "查知识库", "知识图谱", "related projects", "similar implementations", or uses keywords like
  "knowledge", "experience", "历史方案", "经验复用", "参考". Manages cross-project knowledge relationships
  and enables experience reuse across projects. Now enhanced with MCP semantic search and LSP-first navigation.

  <example>
  Context: User is starting a new feature and wants to check if similar work was done before
  user: "我记得之前做过一个 JWT 鉴权的方案，帮我查一下知识库看看当时怎么实现的"
  assistant: "I'll use the knowledge-graph skill to search for JWT authentication solutions in the knowledge base."
  <commentary>
  User explicitly requests querying the knowledge base for a historical solution about JWT auth, directly triggering this skill.
  </commentary>
  </example>

  <example>
  Context: User wants to avoid repeating past mistakes on a new project
  user: "this new project uses React + Prisma, find related projects and see what patterns worked well"
  assistant: "I'll use the knowledge-graph skill to search for related projects with matching tech stacks and surface successful patterns."
  <commentary>
  Keywords "find related projects" and "patterns" combined with tech stack matching trigger this skill for experience reuse.
  </commentary>
  </example>

  <example>
  Context: User encounters a familiar error and wants to check historical resolutions
  user: "又碰到 CORS 跨域问题了，以前怎么解决的来着？查下历史方案"
  assistant: "I'll use the knowledge-graph skill to look up historical CORS error resolutions from past projects."
  <commentary>
  Chinese trigger phrase "历史方案" combined with wanting to reuse past error resolution knowledge activates this skill.
  </commentary>
  </example>
version: 6.0.16
status: ga
profile: design
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

## 触发词 / Trigger Phrases

此技能触发于: "query knowledge", "find related solutions", "查知识库", "知识图谱", "经验复用".
- "query knowledge"
- "find related solutions"
- "查知识库"
- "知识图谱"
- "related projects"
- "similar implementations"

## Overview

Knowledge Graph builds a network of project relationships to:

- Discover similar projects and solutions
- Reuse historical experience
- Avoid repeating mistakes
- Accelerate technical decisions

---

## Tool Priority (v5.0.9)

### 1. LSP-First Navigation

**Always prefer LSP tools over grep/glob for code navigation:**

| Task | Preferred (LSP) | Fallback |
|------|-----------------|----------|
| Find definition | `LSP.goToDefinition` | Grep pattern |
| Find references | `LSP.findReferences` | Grep symbol |
| Get type info | `LSP.hover` | Read file |
| Find implementations | `LSP.goToImplementation` | Grep interface |
| List symbols | `LSP.documentSymbol` | Glob patterns |
| Search workspace | `LSP.workspaceSymbol` | Grep + Glob |
| Call hierarchy | `LSP.incomingCalls/outgoingCalls` | Manual tracing |

**Example Usage:**
```typescript
// ✅ GOOD: Use LSP for accurate navigation
LSP({ operation: "goToDefinition", filePath: "src/auth/jwt.ts", line: 45, character: 12 })
LSP({ operation: "findReferences", filePath: "src/auth/jwt.ts", line: 10, character: 20 })

// ❌ AVOID: Grep for symbol navigation (less accurate)
Grep({ pattern: "function verifyToken", path: "src/" })
```

**Benefits:**
- Semantic understanding (not just text matching)
- Accurate cross-file navigation
- Type-aware references
- Respects language semantics (imports, aliases, etc.)

### 2. MCP Semantic Search

**Use Context7 MCP for semantic knowledge queries:**

```
Step 1: Resolve library for context
  mcp__context7__resolve-library-id
    - libraryName: "react"
    - query: "hooks state management patterns"

Step 2: Query semantic documentation
  mcp__context7__query-docs
    - libraryId: "/facebook/react"
    - query: "useEffect cleanup best practices"
```

**When to Use MCP vs Local:**

| Scenario | Use MCP | Use Local |
|----------|---------|-----------|
| Official API docs | ✅ Context7 | ❌ |
| Current best practices | ✅ Tavily | ❌ |
| Project-specific patterns | ❌ | ✅ knowledge/ |
| Historical solutions | ❌ | ✅ nodes.json |
| Error resolutions | ❌ | ✅ errors/ |

### 3. Fallback Chain

```yaml
Query Priority:
  1. LSP (code navigation) → Most accurate for code
  2. MCP Context7 (documentation) → Official docs
  3. Local knowledge base → Project-specific
  4. Grep/Glob (pattern matching) → Last resort
```

---

## Agent Collaboration
- **@librarian**: Uses knowledge graph to provide historical context during research.
- **requirement-analyzer**: Queries graph for similar project structures during Phase 1.

## Version History
- **5.0.9**: Add LSP-first navigation, MCP semantic search, tool priority chain
- **1.0.0**: Initial release with local storage and ai-dev integration.

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
  "status": "active",
  "success_count": 3,
  "failure_count": 0
}
```

**status 字段**:
- `active` — 当前有效的知识（默认值，SessionStart hook 加载此类记录）
- `superseded` — 被更新的知识替代（同 project + 重叠 tags 时自动标记）

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
  1. Superseded records older than 30 days (first to go)
  2. Any records older than 30 days
  3. When over 50: keep active records, drop superseded first
```

### Knowledge Lifecycle

```
New knowledge added → Mark same-project overlapping-tag records as "superseded"
                    → New record status = "active"

SessionStart hook → Load top 10 "active" records → ~1500 tokens
Query default     → Show "active" only (use --all for all)
Cleanup           → Remove "superseded" before "active"
```

cleanup_priority:
  1. Records older than 30 days
  2. Records with success_count = 0
  3. Oldest records (when exceeding 50)
```

### Manual Cleanup

```bash
${CLAUDE_PLUGIN_ROOT}/skills/knowledge-graph/scripts/graph-manager.sh
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
│  SessionStart (Hook)                    │
│  └── knowledge-graph: Auto-load active  │
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
