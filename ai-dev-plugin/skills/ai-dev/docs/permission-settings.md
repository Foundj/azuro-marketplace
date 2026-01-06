# Permission Settings - Avoid Approval Prompts

> **Purpose**: 如何配置Claude Code权限避免频繁的审批卡顿
> **Target Users**: ai-dev users who want uninterrupted autonomous execution

---

## 🎯 The Problem

**Without proper permission configuration**, Claude Code will frequently prompt for approval:
- "Allow running `npm test`?" → Interrupts OODA loop
- "Allow writing to `src/lib/auth.ts`?" → Breaks autonomous flow
- "Allow executing `git commit`?" → Stops finalization

**Impact**:
- ⏸️ Workflow interruptions every few minutes
- 🤯 User frustration (constant clicking "Allow")
- 🐌 10x slower execution (waiting for user approval)
- ❌ Cannot run unattended (requires user presence)

**Solution**: Pre-configure permissions to allow ai-dev autonomous operation.

---

## ✅ Recommended Permission Configuration

### Option 1: Project-Level Permission Mode (Recommended)

**Best for**: Most users - allows specific ai-dev commands without being too permissive

**Setup**:

1. Create `.claude/config.json` in your project root:

```json
{
  "permissionMode": "dontAsk",
  "allowedCommands": [
    "npm test",
    "npm run build",
    "npm run lint",
    "npm run type-check",
    "tsc --noEmit",
    "git status",
    "git diff",
    "git log",
    "git add",
    "git commit"
  ],
  "allowedPaths": [
    "src/**",
    "changes/**",
    "knowledge/**",
    "tests/**",
    ".claude/**"
  ]
}
```

2. Reload Claude Code to apply changes

**Benefits**:
- ✅ No prompts for whitelisted commands
- ✅ No prompts for whitelisted paths
- ✅ Still prompts for dangerous commands (rm, sudo, etc.)
- ✅ Safe for continuous use

---

### Option 2: Global Don't Ask Mode

**Best for**: Power users who trust ai-dev completely

**Setup**:

Add to your `~/.claude/settings.json`:

```json
{
  "permissionMode": "dontAsk"
}
```

**Benefits**:
- ✅ Zero approval prompts across all projects
- ✅ Maximum autonomous execution
- ⚡ Fastest workflow

**Risks**:
- ⚠️ No safety prompts (including for potentially dangerous operations)
- ⚠️ Requires full trust in the system

**Recommendation**: Use with caution. Prefer Option 1 for production use.

---

### Option 3: Dangerously Skip Permissions (Not Recommended)

**Best for**: Advanced users debugging permission issues

**Usage**:

```bash
claude --dangerously-skip-permissions
```

**Warning**: This flag disables ALL safety checks. Only use for debugging.

---

## 🔧 Configuration Examples

### Example 1: New Feature Development

Allow ai-dev full autonomy for feature development:

```json
{
  "permissionMode": "dontAsk",
  "allowedCommands": [
    // Testing
    "npm test",
    "npm run test:watch",
    "npm run coverage",

    // Building
    "npm run build",
    "npm run build:prod",

    // Quality checks
    "npm run lint",
    "npm run type-check",
    "tsc --noEmit",
    "eslint .",

    // Git operations
    "git status",
    "git diff",
    "git log",
    "git add .",
    "git commit -m *",
    "git push",

    // Package management
    "npm install",
    "npm ci"
  ],
  "allowedPaths": [
    "src/**",
    "tests/**",
    "changes/**",
    "knowledge/**",
    ".claude/**",
    "package.json",
    "tsconfig.json",
    "jest.config.js"
  ]
}
```

---

### Example 2: Bug Fix Workflow

Minimal permissions for bug fixing:

```json
{
  "permissionMode": "dontAsk",
  "allowedCommands": [
    "npm test",
    "npm run build",
    "npm run lint",
    "git diff",
    "git status"
  ],
  "allowedPaths": [
    "src/**",
    "tests/**"
  ]
}
```

---

### Example 3: Code Review Only

Read-only permissions for code review:

```json
{
  "permissionMode": "dontAsk",
  "allowedCommands": [
    "npm test",
    "npm run lint",
    "git diff",
    "git log",
    "git show"
  ],
  "allowedPaths": [
    "**/*.ts",
    "**/*.tsx",
    "**/*.js",
    "**/*.jsx"
  ],
  "readonly": true
}
```

---

## 🚦 Permission Modes Comparison

| Mode | Prompts | Safety | Speed | Recommended For |
|------|---------|--------|-------|-----------------|
| **Ask** (default) | Every operation | Highest | Slowest | First-time users |
| **Don't Ask (project)** | None (whitelisted) | High | Fast | Most users ✅ |
| **Don't Ask (global)** | None | Medium | Fastest | Power users |
| **Dangerously Skip** | None | None | Fastest | Debugging only ❌ |

---

## 🎯 Workflow-Specific Recommendations

### For 7-Phase Workflow (ai-dev)

**Recommended**: Option 1 (Project-Level Don't Ask)

**Required Commands**:
```json
{
  "allowedCommands": [
    // Phase 0: Knowledge Check
    "find knowledge/ -name '*.json'",
    "grep -r pattern knowledge/",

    // Phase 2: Discovery
    "find src/ -name '*.ts'",
    "grep -r 'pattern' src/",

    // Phase 4: Implementation
    "npm test",
    "npm run build",
    "npm run lint",
    "tsc --noEmit",

    // Phase 5: Quality Validation
    "npm test",
    "npm run build",

    // Phase 6: Finalization
    "git add .",
    "git commit -m *",
    "git push"
  ]
}
```

---

### For OODA Loop (Phase 4)

**Recommended**: Option 1 with expanded test/build commands

**Required Commands**:
```json
{
  "allowedCommands": [
    "npm test",
    "npm run test:unit",
    "npm run test:integration",
    "npm run build",
    "npm run lint",
    "tsc --noEmit",
    "git diff HEAD",
    "git status"
  ]
}
```

**Why**: OODA loop runs tests/builds repeatedly (up to 10 iterations). Without don't-ask mode, user must click "Allow" 50+ times.

---

### For Ralph-Wiggum Self-Healing

**Recommended**: Option 1 with git reset capability

**Required Commands**:
```json
{
  "allowedCommands": [
    // Standard checks
    "npm test",
    "npm run build",

    // Self-healing rollback
    "git reset --hard HEAD~1",
    "git stash",
    "git stash pop"
  ]
}
```

**Warning**: `git reset --hard` is destructive. Only whitelist if you trust the self-healing logic.

---

## 🛡️ Security Best Practices

### DO:
- ✅ Use project-level `.claude/config.json` (not global)
- ✅ Whitelist specific commands (not wildcards)
- ✅ Whitelist specific paths (not entire filesystem)
- ✅ Review permissions periodically
- ✅ Use version control (git) as safety net

### DON'T:
- ❌ Use `--dangerously-skip-permissions` in production
- ❌ Whitelist `sudo`, `rm -rf`, or destructive commands
- ❌ Whitelist `~/.ssh`, `~/.aws`, or credential paths
- ❌ Share config files containing sensitive paths

---

## 📊 Performance Impact

### Without Permission Configuration

```
Workflow Duration: 2 hours
User Interactions: 50+ approval clicks
Unattended Operation: ❌ Impossible
```

### With Permission Configuration (Option 1)

```
Workflow Duration: 15 minutes
User Interactions: 3 (approval gates only)
Unattended Operation: ✅ Possible
```

**Speedup**: **8x faster**

---

## 🔍 Debugging Permission Issues

### Issue: Commands Still Prompt Despite Configuration

**Solution 1**: Check config file location
```bash
ls -la .claude/config.json  # Should exist in project root
```

**Solution 2**: Validate JSON syntax
```bash
cat .claude/config.json | jq .  # Should parse without errors
```

**Solution 3**: Reload Claude Code
```bash
# Restart Claude Code to apply config changes
```

---

### Issue: Config Ignored

**Cause**: Global settings override project settings

**Solution**: Check `~/.claude/settings.json` for conflicting settings

---

### Issue: Some Commands Still Prompt

**Cause**: Command not in whitelist or uses wildcards

**Solution**: Add exact command to `allowedCommands`:

```json
{
  "allowedCommands": [
    "npm test",              // ✅ Exact match
    "npm run test:*",        // ❌ Wildcard not supported
    "npm run test:unit",     // ✅ Add specific variant
    "npm run test:integration"  // ✅ Add another variant
  ]
}
```

---

## 📚 References

- **Claude Code Hooks Guide**: https://code.claude.com/docs/en/hooks-guide
- **Claude Code Settings**: https://code.claude.com/docs/en/settings
- **ai-dev Workflow**: `${CLAUDE_PLUGIN_ROOT}/skills/ai-dev/references/7-phase-workflow.md`
- **OODA Loop**: `${CLAUDE_PLUGIN_ROOT}/skills/ai-dev/references/ooda-loop.md`

---

## 🎉 Quick Start

**TL;DR**: Add this to `.claude/config.json` in your project root and reload Claude Code:

```json
{
  "permissionMode": "dontAsk",
  "allowedCommands": [
    "npm test",
    "npm run build",
    "npm run lint",
    "npm run type-check",
    "tsc --noEmit",
    "git status",
    "git diff",
    "git log",
    "git add .",
    "git commit -m *"
  ],
  "allowedPaths": [
    "src/**",
    "changes/**",
    "knowledge/**",
    "tests/**",
    ".claude/**"
  ]
}
```

**Result**: ai-dev can now run autonomously without constant approval prompts!

---

**End of Permission Settings Guide**
