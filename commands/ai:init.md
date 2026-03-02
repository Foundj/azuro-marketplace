---
name: ai:init
description: Quick start - initialize new project with ultrawork-compatible structure from templates
argument-hint: "[project-name] [--template=nodejs|python]"
allowed-tools: Bash, Read, Write, Glob
internal: true
---

Quick Start: Initialize Project

**Goal**: Create a new project with ultrawork-compatible structure from templates.

## Usage

```bash
# Create Node.js project
/ai:init my-project

# Create Python project
/ai:init my-project --template=python

# Initialize in current directory
/ai:init . --template=nodejs
```

---

## Phase 1: Parse Arguments (1s)

```bash
PROJECT_NAME="${ARGUMENTS%% *}"
TEMPLATE="${ARGUMENTS#*--template=}"
TEMPLATE="${TEMPLATE:-nodejs}"

# Default to nodejs if not specified
if [[ "$TEMPLATE" == "$ARGUMENTS" ]]; then
    TEMPLATE="nodejs"
fi

# Handle current directory
if [[ "$PROJECT_NAME" == "." || -z "$PROJECT_NAME" ]]; then
    PROJECT_NAME=$(basename "$(pwd)")
    INIT_IN_PLACE=true
fi
```

---

## Phase 2: Validate Template (1s)

Check available templates:

```bash
TEMPLATE_DIR="${CLAUDE_PLUGIN_ROOT}/templates/${TEMPLATE}"

if [[ ! -d "$TEMPLATE_DIR" ]]; then
    echo "❌ Template not found: $TEMPLATE"
    echo "Available templates:"
    ls -1 "${CLAUDE_PLUGIN_ROOT}/templates/"
    exit 1
fi

echo "✅ Using template: $TEMPLATE"
```

---

## Phase 3: Create Project Structure (3s)

### 3.1 Copy Template Files

```bash
if [[ "$INIT_IN_PLACE" == "true" ]]; then
    # Copy template to current directory
    cp -r "$TEMPLATE_DIR"/* .
    cp -r "$TEMPLATE_DIR"/.* . 2>/dev/null || true
    echo "✅ Initialized in current directory"
else
    # Create new directory
    mkdir -p "$PROJECT_NAME"
    cp -r "$TEMPLATE_DIR"/* "$PROJECT_NAME/"
    cp -r "$TEMPLATE_DIR"/.* "$PROJECT_NAME/" 2>/dev/null || true
    echo "✅ Created project: $PROJECT_NAME"
fi
```

### 3.2 Initialize Git

```bash
cd "$PROJECT_NAME" 2>/dev/null || true

if [[ ! -d ".git" ]]; then
    git init
    git add -A
    git commit -m "chore: initialize from template"
    echo "✅ Git initialized"
fi
```

### 3.3 Create .agent Structure

```bash
# Run .agent-setup script
bash "${CLAUDE_PLUGIN_ROOT}/hooks/scripts/agent-dir-setup.sh" "init" "." 2>/dev/null || {
    # Fallback if script not found
    mkdir -p .agent/changes
    mkdir -p .agent/archive

    cat > .agent/spec.md << 'EOF'
# Project Specification

## Overview
[Describe your project]

## Requirements

### Functional Requirements
| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | [Requirement] | Must |

### Non-Functional Requirements
| ID | Requirement | Target |
|----|-------------|--------|
| NFR-01 | Test Coverage | > 80% |

## Success Criteria
- [ ] All tests pass
- [ ] Code review approved
EOF

    echo "✅ .agent created"
}
```

---

## Phase 4: Install Dependencies (5s)

```bash
# Node.js
if [[ -f "package.json" ]]; then
    npm install
    echo "✅ Node.js dependencies installed"
fi

# Python
if [[ -f "requirements.txt" ]]; then
    python3 -m venv venv 2>/dev/null || true
    source venv/bin/activate 2>/dev/null || true
    pip install -r requirements.txt
    echo "✅ Python dependencies installed"
fi
```

---

## Phase 5: Output Summary

```
╔═══════════════════════════════════════════════════════════════╗
║                    PROJECT INITIALIZED                               ║
╠═══════════════════════════════════════════════════════════════╣
║                                                                   ║
║  Project: ${PROJECT_NAME}                                        ║
║  Template: ${TEMPLATE}                                           ║
║                                                                   ║
║  Structure:                                                      ║
║    ├── .agent/              # Requirements & plans               ║
║    │   ├── spec.md                                          ║
║    │   ├── plan.md                                          ║
║    │   └── changes/                                          ║
║    ├── src/                  # Source code                        ║
║    ├── tests/                # Test files                         ║
║    └── package.json          # Project config                      ║
║                                                                   ║
╠═══════════════════════════════════════════════════════════════╣
║                    NEXT STEPS                                     ║
╠═══════════════════════════════════════════════════════════════╣
║                                                                   ║
║  1. cd ${PROJECT_NAME}                                           ║
║  2. Edit .agent/spec.md with your requirements                ║
║  3. Run /ultrawork to start development                        ║
║                                                                   ║
║  Or start coding manually:                                        ║
║  - Add source files to src/                                      ║
║  - Add tests to tests/                                           ║
║  - Run tests: npm test                                          ║
║                                                                   ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## Available Templates

| Template | Description | Stack |
|----------|-------------|-------|
| nodejs | Node.js project with native assert testing | Node.js + npm |
| python | Python project with pytest | Python 3.8+ |

---

## Integration

- Called by user to quickly start a new project
- Creates .agent structure for ultrawork compatibility
- Can be followed by `/ultrawork` for full automation

---

## Examples

```bash
# Create a new API project
/ai:init my-api

# Create a Python data project
/ai:init data-processor --template=python

# Initialize existing directory
cd existing-project
/ai:init . --template=nodejs
```