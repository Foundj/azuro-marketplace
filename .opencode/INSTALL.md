# Installing Azuro Marketplace for OpenCode

## Prerequisites

- [OpenCode.ai](https://opencode.ai) installed
- Git installed

## Installation Steps

### 1. Install Azuro Marketplace

```bash
mkdir -p ~/.config/opencode/azuro-marketplace
git clone https://github.com/Foundj/azuro-marketplace.git ~/.config/opencode/azuro-marketplace
```

### 2. Link Skills Directory

Create a symlink so OpenCode discovers the skills:

```bash
mkdir -p ~/.config/opencode/skills
ln -sf ~/.config/opencode/azuro-marketplace/skills/* ~/.config/opencode/skills/
```

### 3. Restart OpenCode

Restart OpenCode. The skills will be automatically discovered.

## Core Commands

After installation, you can use:

| Command | Description |
|---------|-------------|
| `/ai:dev <feature>` | Full 7-phase development workflow |
| `/ai:fix <bug>` | Quick bug fix with verification |
| `/ai:status` | View project progress |

## Usage

### Finding Skills

Use the `find_skills` tool to list all available skills:

```
use find_skills tool
```

### Loading a Skill

Use the `use_skill` tool to load a specific skill:

```
use use_skill tool with skill_name: "context-bridge"
```

### Personal Skills

Create your own skills in `~/.config/opencode/skills/`:

```bash
mkdir -p ~/.config/opencode/skills/my-skill
```

Create `~/.config/opencode/skills/my-skill/SKILL.md`:

```markdown
---
name: my-skill
description: Use when [condition] - [what it does]
---

# My Skill

[Your skill content here]
```

Personal skills override azuro-marketplace skills with the same name.

## Updating

```bash
cd ~/.config/opencode/azuro-marketplace
git pull
```

## Troubleshooting

### Skills not found

1. Verify skills directory exists: `ls ~/.config/opencode/azuro-marketplace/skills`
2. Use `find_skills` tool to see what's discovered
3. Check file structure: each skill should have a `SKILL.md` file

### Tool mapping issues

When a skill references a Claude Code tool you don't have:
- `TodoWrite` → use `update_plan`
- `Task` with subagents → use `@mention` syntax to invoke OpenCode subagents
- `Skill` → use `use_skill` tool
- File operations → use your native tools

## Getting Help

- Report issues: https://github.com/Foundj/azuro-marketplace/issues
- Documentation: https://github.com/Foundj/azuro-marketplace
