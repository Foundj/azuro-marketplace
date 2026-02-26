# CLAUDE.md / AGENTS.md Templates

## Key Principles

- **Concise**: Dense, human-readable content; one line per concept when possible
- **Actionable**: Commands should be copy-paste ready
- **Project-specific**: Document patterns unique to this project, not generic advice
- **Current**: All info should reflect actual codebase state

---

## CLAUDE.md Templates

### Template: Project Root (Minimal)

```markdown
# <Project Name>

<One-line description>

## Commands

| Command | Description |
|---------|-------------|
| `<command>` | <description> |

## Architecture

\`\`\`
<root>/
  <dir>/    # <purpose>
  <dir>/    # <purpose>
\`\`\`

## Gotchas

- <gotcha>
```

### Template: Project Root (Comprehensive)

```markdown
# <Project Name>

<One-line description>

## Commands

| Command | Description |
|---------|-------------|
| `<command>` | <description> |

## Architecture

\`\`\`
<structure with descriptions>
\`\`\`

## Key Files

- `<path>` - <purpose>

## Code Style

- <convention>

## Environment

- `<VAR>` - <purpose>

## Testing

- `<command>` - <scope>

## Gotchas

- <gotcha>
```

### Template: Package/Module

```markdown
# <Package Name>

<Purpose of this package>

## Usage

\`\`\`
<import/usage example>
\`\`\`

## Key Exports

- `<export>` - <purpose>

## Dependencies

- `<dependency>` - <why needed>

## Notes

- <important note>
```

### Template: Monorepo Root

```markdown
# <Monorepo Name>

<Description>

## Packages

| Package | Description | Path |
|---------|-------------|------|
| `<name>` | <purpose> | `<path>` |

## Commands

| Command | Description |
|---------|-------------|
| `<command>` | <description> |

## Cross-Package Patterns

- <shared pattern>
- <generation/sync pattern>
```

---

## AGENTS.md Templates

### Template: Minimal Agent

```markdown
# Agent: <Name>

<One-line purpose>

## Behavior

- <behavior rule>
- <behavior rule>

## Tools

- Allowed: <tool list>
- Restricted: <tool list>

## Triggers

Use this agent when:
- <trigger condition>
- <trigger condition>
```

### Template: Full Agent

```markdown
# Agent: <Name>

<One-line purpose>

## Role

<detailed role description>

## Capabilities

- <capability>
- <capability>

## Behavior Rules

### Always
- <rule>
- <rule>

### Never
- <rule>
- <rule>

## Tools

| Tool | Usage |
|------|-------|
| `<tool>` | <when/how to use> |

## Triggers

Use this agent when:
- <trigger condition>
- <trigger condition>

## Output Format

<expected output structure>

## Examples

\`\`\`
<example interaction>
\`\`\`

## Gotchas

- <important note>
```

### Template: Multi-Agent Project

```markdown
# Project Agents

## Agent Overview

| Agent | Purpose | Trigger |
|-------|---------|---------|
| `<name>` | <purpose> | <trigger> |

## Agent Details

### <Agent 1 Name>

<description>

- **Role**: <role>
- **Tools**: <tools>
- **Triggers**: <triggers>

### <Agent 2 Name>

<description>

- **Role**: <role>
- **Tools**: <tools>
- **Triggers**: <triggers>

## Agent Coordination

<handoff and communication patterns>
```

---

## Recommended Sections by File Type

### CLAUDE.md Sections (use what's relevant)

| Section | Purpose | When to Include |
|---------|---------|-----------------|
| Commands | Build/test/dev commands | Always |
| Architecture | Directory structure | Always |
| Key Files | Important entry points | Medium+ complexity |
| Code Style | Project conventions | If non-standard |
| Environment | Required vars/setup | If env vars needed |
| Testing | Test commands/patterns | If tests exist |
| Gotchas | Non-obvious issues | If quirks exist |
| Workflow | When to do what | If process matters |

### AGENTS.md Sections (use what's relevant)

| Section | Purpose | When to Include |
|---------|---------|-----------------|
| Role | Agent's purpose | Always |
| Capabilities | What it can do | Always |
| Behavior Rules | Always/Never rules | Always |
| Tools | Tool restrictions | If restrictions exist |
| Triggers | When to use | Always |
| Output Format | Expected structure | If structured output |
| Examples | Sample interactions | If complex behavior |
| Gotchas | Important notes | If quirks exist |

---

## Update Principles

When updating any CLAUDE.md or AGENTS.md:

1. **Be specific**: Use actual file paths, real commands from this project
2. **Be current**: Verify info against the actual codebase
3. **Be brief**: One line per concept when possible
4. **Be useful**: Would this help a new Claude session understand the project?