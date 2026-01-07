# Skill Auditor - Best Practices

Validation checklist, common mistakes, and good/bad examples for skill development.

## Validation Checklist

Use this checklist before finalizing any skill.

### Structure (Required)

- [ ] SKILL.md file exists
- [ ] Valid YAML frontmatter with `---` delimiters
- [ ] `name` field present in frontmatter
- [ ] `description` field present in frontmatter
- [ ] Directory uses kebab-case naming
- [ ] No special characters in directory name

### Description Quality (Required)

- [ ] Uses third-person format ("This skill should be used when...")
- [ ] Includes specific trigger phrases users would say
- [ ] Lists concrete scenarios ("create X", "configure Y")
- [ ] 50+ characters minimum
- [ ] Not vague or generic

### Content Quality (Required)

- [ ] SKILL.md body uses imperative/infinitive form
- [ ] Body is lean (1,500-2,000 words ideal)
- [ ] Max 3,000 words in SKILL.md
- [ ] Detailed content moved to references/
- [ ] No second-person language ("You should...")

### Progressive Disclosure (Required)

- [ ] Core concepts in SKILL.md
- [ ] Detailed docs in references/
- [ ] Working code in examples/ or scripts/
- [ ] SKILL.md references all bundled resources
- [ ] No duplicated content across files

### Resources (If Applicable)

- [ ] All referenced files exist
- [ ] Scripts are executable (+x permission)
- [ ] Examples are complete and working
- [ ] No orphan files (unreferenced)

### Testing

- [ ] Skill triggers on expected user queries
- [ ] Content is helpful for intended tasks
- [ ] References load when needed

---

## Common Mistakes

### Mistake 1: Weak Trigger Description

❌ **Bad:**
```yaml
description: Provides guidance for working with hooks.
```

**Problems:**
- Vague - what kind of guidance?
- No trigger phrases - when does it activate?
- Not third person

✅ **Good:**
```yaml
description: |
  This skill should be used when the user asks to "create a hook", 
  "add a PreToolUse hook", "validate tool use", or mentions hook events 
  (PreToolUse, PostToolUse, Stop). Provides comprehensive hooks API guidance.
```

**Why it works:**
- Third person: "This skill should be used when..."
- Specific phrases: "create a hook", "add a PreToolUse hook"
- Concrete scenarios

---

### Mistake 2: Too Much Content in SKILL.md

❌ **Bad:**
```
skill-name/
└── SKILL.md  (8,000 words - everything in one file)
```

**Problems:**
- Bloats context when skill loads
- All content always loaded regardless of need
- Hard to navigate and maintain

✅ **Good:**
```
skill-name/
├── SKILL.md  (1,800 words - core essentials)
└── references/
    ├── patterns.md (2,500 words)
    └── advanced.md (3,700 words)
```

**Why it works:**
- Progressive disclosure
- Core always loaded, details on demand
- Easier to maintain separate concerns

---

### Mistake 3: Second Person Writing

❌ **Bad:**
```markdown
You should start by reading the configuration file.
You need to validate the input before processing.
You can use the grep tool to search for patterns.
```

**Problems:**
- Second person ("You") is inconsistent
- Not imperative form
- Adds unnecessary words

✅ **Good:**
```markdown
Start by reading the configuration file.
Validate the input before processing.
Use the grep tool to search for patterns.
```

**Why it works:**
- Imperative form - direct instructions
- Concise and clear
- Consistent voice

---

### Mistake 4: Missing Resource References

❌ **Bad:**
```markdown
# SKILL.md

[Core content about hooks]

## Advanced Topics

[Lots of detail that should be in references/]
```

**Problems:**
- Claude doesn't know references exist
- User can't find additional resources
- Content bloat in main file

✅ **Good:**
```markdown
# SKILL.md

[Core content about hooks]

## Additional Resources

### Reference Files
- **`references/patterns.md`** - Common hook patterns and examples
- **`references/advanced.md`** - Advanced configuration and edge cases

### Scripts
- **`scripts/validate-hook.sh`** - Validate hook configuration
```

**Why it works:**
- Claude knows where to find additional info
- Progressive disclosure enabled
- Resources are discoverable

---

### Mistake 5: Vague Feature List

❌ **Bad:**
```markdown
## Features

- Does stuff with files
- Helps with development
- Provides useful utilities
```

**Problems:**
- No actionable information
- Doesn't help Claude understand capabilities
- Wastes tokens on vague statements

✅ **Good:**
```markdown
## Features

- **Quality Scoring**: 0-100 score across 5 dimensions
- **Issue Detection**: Automatic problem identification with severity levels
- **Auto-Fix**: Resolve permissions, add version fields, fix formatting
- **Report Generation**: Markdown and JSON output formats
```

**Why it works:**
- Specific capabilities listed
- Actionable information
- Claude understands what the skill can do

---

### Mistake 6: No Usage Examples

❌ **Bad:**
```markdown
## Usage

Run the skill to audit your skills.
```

**Problems:**
- No concrete examples
- User doesn't know syntax
- Claude can't demonstrate usage

✅ **Good:**
```markdown
## Usage

### Audit All Skills

```bash
/skill-audit              # Audit all skills in project
/skill-audit --summary    # Summary output only
/skill-audit --fix        # Auto-fix simple issues
```

### Audit Single Skill

```bash
/skill-audit ai-dev       # By name
/skill-audit ./path/to   # By path
```
```

**Why it works:**
- Concrete command examples
- Multiple use cases shown
- Copy-paste ready

---

### Mistake 7: Wrong Description Format

❌ **Bad Examples:**
```yaml
# Wrong: Second person
description: Use this skill when you want to create hooks.

# Wrong: Imperative
description: Load this skill when user needs hook help.

# Wrong: Too short
description: Hook development.

# Wrong: No triggers
description: This skill provides comprehensive hook guidance.
```

✅ **Good Example:**
```yaml
description: |
  This skill should be used when the user asks to "create a hook", 
  "add a PreToolUse hook", "validate tool use", or mentions hook events.
  Provides comprehensive hooks API guidance with examples.
```

---

## Good vs Bad Comparison Table

| Aspect | Bad | Good |
|--------|-----|------|
| Description person | "You should use..." | "This skill should be used when..." |
| Trigger phrases | None or vague | Specific: "create X", "add Y" |
| Body writing style | "You need to..." | "Create the file..." |
| SKILL.md length | 8,000 words | 1,500-2,000 words |
| Progressive disclosure | Everything in one file | Core + references/ |
| Resource references | Not mentioned | Clearly documented |
| Examples | Missing or vague | Complete code blocks |
| Feature list | Generic descriptions | Specific capabilities |

---

## Description Templates

### Template 1: Tool/Utility Skill

```yaml
description: |
  This skill should be used when the user asks to "[action] [object]", 
  "[alternative action]", "[third action]", or needs help with [domain].
  Provides [specific capability 1], [capability 2], and [capability 3].
```

### Template 2: Workflow Skill

```yaml
description: |
  This skill should be used when the user wants to "[workflow trigger 1]",
  "[workflow trigger 2]", or mentions [domain keywords]. Orchestrates 
  [workflow description] with [key features].
```

### Template 3: Domain Expertise Skill

```yaml
description: |
  This skill should be used when working with [domain], including 
  "[specific task 1]", "[specific task 2]", and "[specific task 3]".
  Provides domain expertise for [area] with [key capabilities].
```

---

## Writing Style Examples

### Imperative Form (Correct)

```markdown
## Creating a Hook

Create the hooks directory:

```bash
mkdir -p hooks
```

Define the hook configuration in hooks.json:

```json
{
  "hooks": []
}
```

Add the event handler...
```

### Second Person (Incorrect)

```markdown
## Creating a Hook

You should first create the hooks directory:

```bash
mkdir -p hooks
```

You need to define the hook configuration. You can use this format:

```json
{
  "hooks": []
}
```

You should then add the event handler...
```

---

## Self-Audit Questions

Before publishing a skill, answer these questions:

1. **Trigger Quality**: Would I be able to identify exactly what queries should trigger this skill from the description alone?

2. **Content Focus**: Is every sentence in SKILL.md essential, or could some be moved to references/?

3. **Actionability**: Can a user immediately start using this skill after reading the quick start section?

4. **Completeness**: Are all bundled resources documented and referenced?

5. **Consistency**: Is the writing style consistently imperative throughout?

6. **Examples**: Are there concrete, working examples for primary use cases?

If any answer is "no" or uncertain, revise before publishing.

---

## Quick Fixes

### Fix Description Format

From:
```yaml
description: Helps with skill development.
```

To:
```yaml
description: |
  This skill should be used when the user asks to "create a skill", 
  "audit skill quality", or "validate skill structure".
```

### Fix Writing Style

From:
```markdown
You should run the validation script.
```

To:
```markdown
Run the validation script.
```

### Fix Content Bloat

1. Identify sections > 500 words
2. Create `references/[topic].md`
3. Move detailed content
4. Add reference link in SKILL.md:
   ```markdown
   For detailed [topic] information, see `references/[topic].md`.
   ```

### Fix Missing References

Add to SKILL.md:
```markdown
## Additional Resources

### Reference Files
- **`references/file.md`** - [Description]

### Scripts  
- **`scripts/tool.sh`** - [Description]
```
