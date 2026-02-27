# CLAUDE.md / AGENTS.md Update Guidelines

## Core Principle

Only add information that will genuinely help future Claude sessions. The context window is precious - every line must earn its place.

> **Research Warning**: LLM-generated context files can decrease performance (-0.5% to -2%) while human-written files improve success rates (+4%). Always have humans review and approve updates. Context files add ~20% inference cost regardless of quality.

## Key Insight

**Write for gaps, not overviews.** The best context files contain what the code itself cannot explain.

---

## What TO Add

### 1. Commands/Workflows Discovered

```markdown
## Build

`npm run build:prod` - Full production build with optimization
`npm run build:dev` - Fast dev build (no minification)
```

**Why**: Saves future sessions from discovering these again.

### 2. Gotchas and Non-Obvious Patterns

```markdown
## Gotchas

- Tests must run sequentially (`--runInBand`) due to shared DB state
- `yarn.lock` is authoritative; delete `node_modules` if deps mismatch
```

**Why**: Prevents repeating debugging sessions.

### 3. Package/Module Relationships

```markdown
## Dependencies

The `auth` module depends on `crypto` being initialized first.
Import order matters in `src/bootstrap.ts`.
```

**Why**: Architecture knowledge that isn't obvious from code.

### 4. Testing Approaches That Worked

```markdown
## Testing

For API endpoints: Use `supertest` with the test helper in `tests/setup.ts`
Mocking: Factory functions in `tests/factories/` (not inline mocks)
```

**Why**: Establishes patterns that work.

### 5. Configuration Quirks

```markdown
## Config

- `NEXT_PUBLIC_*` vars must be set at build time, not runtime
- Redis connection requires `?family=0` suffix for IPv6
```

**Why**: Environment-specific knowledge.

### 6. Agent Behavior Learnings

```markdown
## Behavior Rules (AGENTS.md)

- Always use TDD for new features
- Never skip the confidence gate before implementation
- Use subagent-driven-development for tasks > 5 minutes
```

**Why**: Captures workflow preferences from session corrections.

---

## What NOT to Add

### 1. Obvious Code Info

❌ Bad:
```markdown
The `UserService` class handles user operations.
```

The class name already tells us this.

### 2. Generic Best Practices

❌ Bad:
```markdown
Always write tests for new features.
Use meaningful variable names.
```

This is universal advice, not project-specific.

### 3. One-Off Fixes

❌ Bad:
```markdown
We fixed a bug in commit abc123 where the login button didn't work.
```

Won't recur; clutters the file.

### 4. Verbose Explanations

❌ Bad:
```markdown
The authentication system uses JWT tokens. JWT (JSON Web Tokens) are
an open standard (RFC 7519) that defines a compact and self-contained
way for securely transmitting information between parties as a JSON
object. In our implementation, we use the HS256 algorithm which...
```

✅ Good:
```markdown
Auth: JWT with HS256, tokens in `Authorization: Bearer <token>` header.
```

---

## Diff Format for Updates

For each suggested change:

### 1. Identify the File

```
File: ./CLAUDE.md
Section: Commands (new section after ## Architecture)
```

### 2. Show the Change

```diff
 ## Architecture
 ...

+## Commands
+
+| Command | Purpose |
+|---------|---------|
+| `npm run dev` | Dev server with HMR |
+| `npm run build` | Production build |
+| `npm test` | Run test suite |
```

### 3. Explain Why

> **Why this helps:** The build commands weren't documented, causing
> confusion about how to run the project. This saves future sessions
> from needing to inspect `package.json`.

---

## File-Specific Guidelines

### CLAUDE.md Updates

Focus on:
- Build/test commands that work
- Project-specific patterns
- Environment quirks
- Directory structure clarifications

### AGENTS.md Updates

Focus on:
- Behavior rules from session corrections
- Tool usage patterns
- Decision-making criteria
- Trigger conditions

---

## Validation Checklist

Before finalizing an update, verify:

- [ ] Each addition is project-specific
- [ ] No generic advice or obvious info
- [ ] Commands are tested and work
- [ ] File paths are accurate
- [ ] Would a new Claude session find this helpful?
- [ ] Is this the most concise way to express the info?

---

## Integration with Capture System

### From Session Corrections

When capturing corrections from sessions:

1. **Detect pattern** - Is this a recurring correction?
2. **Check for duplicates** - Does similar content exist?
3. **Determine target** - CLAUDE.md or AGENTS.md?
4. **Format concisely** - One line per concept
5. **Propose update** - Show diff with explanation

### Target File Selection

| Correction Type | Target File |
|----------------|-------------|
| Build/test commands | CLAUDE.md |
| Code style preferences | CLAUDE.md or `.claude/rules/linting.md` |
| Project-specific patterns | CLAUDE.md |
| Agent behavior rules | AGENTS.md |
| Tool usage patterns | AGENTS.md |
| Workflow preferences | AGENTS.md |
| Path-specific rules | Matching `.claude/rules/*.md` |
| General corrections | Global ~/.claude/CLAUDE.md |
| Project-specific corrections | ./CLAUDE.md |

---

## Smart Distribution Algorithm

When capturing learnings, determine the best target file:

```
用户更正内容
    │
    ├── 命令/构建相关 → 主 CLAUDE.md
    │   Examples: "use npm run build:prod", "run tests with --coverage"
    │
    ├── 代码风格/语言特定
    │   │
    │   ├── Python 相关 → .claude/rules/python.md
    │   ├── TypeScript 相关 → .claude/rules/typescript.md
    │   └── 通用风格 → 主 CLAUDE.md
    │
    ├── Agent 行为规则 → 主 AGENTS.md
    │   Examples: "always use TDD", "never skip tests"
    │
    ├── 文件/路径特定 → 匹配的 paths 规则文件
    │   Examples: "for .py files, use ruff"
    │
    └── 全局通用 → ~/.claude/CLAUDE.md
        Examples: "prefer gpt-5.1 for reasoning"
```

### Distribution Decision Tree

1. **Is this project-specific?**
   - No → `~/.claude/CLAUDE.md` (global)
   - Yes → Continue

2. **Is this about agent behavior?**
   - Yes → `AGENTS.md`
   - No → Continue

3. **Does it apply to specific file types?**
   - Yes → Check `.claude/rules/` for matching paths
   - No → Continue

4. **Is there an existing modular rule for this topic?**
   - Yes → Add to that rule file
   - No → Continue

5. **Add to `CLAUDE.md` or create new rule?**
   - If rule would be >20 lines → Create new modular rule
   - Otherwise → Add to `CLAUDE.md`

### Path Matching Examples

| Learning | Suggested File | Reason |
|----------|----------------|--------|
| "For Python files, use ruff" | `.claude/rules/python.md` | Path-specific |
| "Always run tests before commit" | `AGENTS.md` | Behavior rule |
| "The build uses webpack" | `CLAUDE.md` | Project context |
| "Use React Query for data fetching" | `.claude/rules/react.md` | Framework-specific |

---

## Deduplication

When similar entries exist:

1. **Consolidate** - Merge into single, clearer entry
2. **Remove redundancy** - Keep most recent/accurate
3. **Update context** - Add any missing context
4. **Preserve specifics** - Don't lose important details