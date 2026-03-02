---
name: plugin-auditor
description: |
  This skill should be used when the user asks to "audit plugin", "validate plugin", "check plugin quality",
  "review plugin structure", "plugin-check", "verify plugin", "score plugin", or wants to ensure plugins
  follow Claude Code best practices. Also triggers on Chinese phrases: "审计插件", "校验插件",
  "检查插件质量", "插件评分".

  Provides multi-dimensional quality assessment with scoring, issue detection, and optimization recommendations for Claude Code Plugins.

  <example>
  Context: User has finished developing a plugin and wants to check if it meets production standards
  user: "audit plugin ./my-awesome-plugin 看看能不能发布到 marketplace"
  assistant: "I'll use the plugin-auditor skill to run a full quality audit on your plugin and check if it meets marketplace publication standards."
  <commentary>
  Trigger phrase "audit plugin" with a specific path triggers a comprehensive plugin quality assessment.
  </commentary>
  </example>

  <example>
  Context: User wants to validate their plugin structure after reorganizing directories
  user: "刚重构了插件目录结构，帮我校验插件看 commands 和 hooks 位置对不对"
  assistant: "I'll use the plugin-auditor skill to validate the directory structure and ensure components are correctly placed."
  <commentary>
  Chinese trigger "校验插件" combined with structural concern triggers structure validation checks.
  </commentary>
  </example>

  <example>
  Context: User wants a quick score to see where their plugin stands
  user: "score plugin azuro-marketplace, I want to see the breakdown by dimension"
  assistant: "I'll use the plugin-auditor skill to score your plugin across all 5 dimensions and provide a detailed breakdown."
  <commentary>
  Trigger phrase "score plugin" with request for dimensional breakdown activates scoring workflow.
  </commentary>
  </example>
version: 6.0.23
status: ga
profile: review
---

# Plugin Auditor

Quality gate system ensuring Claude Code plugins meet production standards.

## Overview

Plugin Auditor validates Claude Code plugins against official specifications:

- **Structure Validation** - Ensures correct file layout and manifest location
- **Component Checks** - Validates Commands, Agents, Skills, and Hooks
- **Safety Analysis** - Detects hardcoded paths and permission issues
- **Quality Scoring** - 0-100 score across 5 weighted dimensions

## Scoring Dimensions

| Dimension | Weight | Focus |
|-----------|--------|-------|
| Structure | 20% | Directory layout, manifest location |
| Manifest | 20% | plugin.json validity, metadata completeness |
| Components | 30% | Commands, Agents, Hooks specification compliance |
| Safety | 15% | Path usage, script permissions |
| Skills | 15% | Embedded skills quality (delegates to skill-auditor) |

### Grade Scale

| Score | Grade | Status |
|-------|-------|--------|
| 90-100 | A | Production Ready |
| 80-89 | B | Good |
| 70-79 | C | Acceptable |
| <70 | D/F | Needs Work |

For detailed scoring rules, see `references/scoring-rules.md`.

---

## Audit Process

### Step 1: Locate Plugin

Identify the plugin root directory containing `.claude-plugin/plugin.json`.

### Step 2: Validate Structure

Check critical layout rules:
1. **Manifest Location**: `.claude-plugin/plugin.json` must exist
2. **Component Roots**: `commands/`, `agents/`, `hooks/` must be at plugin root (NOT inside `.claude-plugin/`)
3. **Naming**: Kebab-case for all files and directories

### Step 3: Validate Manifest

Analyze `plugin.json`:
- **Required Fields**: `name`, `version`
- **Metadata**: `description`, `author`, `license`
- **Schema**: Valid JSON format

### Step 4: Check Components

Validate each component type:

- **Commands**: Check frontmatter (`description`, `argument-hint`)
- **Agents**: Check frontmatter (`name`, `description`, `model`, `tools`)
- **Hooks**: Validate `hooks.json` schema and event names

### Step 5: Safety Checks

- **Paths**: Ensure usage of `${CLAUDE_PLUGIN_ROOT}` instead of absolute paths
- **Permissions**: Check scripts are executable

### Step 6: Embedded Skills

Recursively audit `skills/` directory using `skill-auditor` logic.

---

## Issue Severity

| Level | Icon | Impact |
|-------|------|--------|
| CRITICAL | 🚨 | Plugin unusable (e.g., missing manifest) |
| ERROR | ❌ | Broken functionality (e.g., wrong directory nesting) |
| WARNING | ⚠️ | Non-compliant but usable |
| INFO | ℹ️ | Optimization opportunity |

---

## Usage

### Audit a Plugin

```bash
/audit-plugin ./my-plugin
```

### JSON Output

```bash
/audit-plugin ./my-plugin --json
```

---

## Additional Resources

### Reference Files

- **`references/scoring-rules.md`** - Detailed scoring dimensions and common mistakes

### Utility Scripts

- **`scripts/validate-plugin.sh`** - Automated validation script

---

## Dependencies

- `bash` - Script execution
- `grep` - Text search
- `jq` - JSON processing (optional, falls back to text parsing)

---

## Workflow Integration

Used in:
- Pre-commit hooks to validate plugins
- CI/CD pipelines for quality gates
- Plugin development workflow

---

## Version History

| Version | Changes |
|---------|---------|
| 5.0.20 | Added Chinese triggers and workflow integration |
| 5.0.0 | Initial release with scoring system |
