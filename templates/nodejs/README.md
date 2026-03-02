# Node.js Quick Start Template

A pre-configured project template for Node.js with ultrawork compatibility.

## Features

- ✅ Standard .agent structure
- ✅ Pre-configured package.json
- ✅ Test framework setup (Node.js native assert)
- ✅ Example spec.md and plan.md
- ✅ .gitignore for worktrees

## Quick Start

```bash
# Copy template
cp -r templates/nodejs my-project
cd my-project

# Initialize git
git init
git add -A
git commit -m "chore: init from template"

# Start ultrawork
# In Claude Code: "ultrawork implement [feature description]"
```

## Project Structure

```
my-project/
├── .agent/
│   ├── spec.md           # Requirements specification
│   ├── plan.md           # Implementation plan
│   └── changes/
│       ├── active.md    # Current progress
│       └── completed.md # Archive
├── src/
│   └── index.js         # Entry point
├── tests/
│   └── index.test.js    # Test file
├── package.json
└── .gitignore
```

## package.json

```json
{
  "name": "my-project",
  "version": "1.0.0",
  "description": "Node.js project with ultrawork compatibility",
  "main": "src/index.js",
  "scripts": {
    "test": "node tests/index.test.js",
    "start": "node src/index.js"
  },
  "keywords": [],
  "author": "",
  "license": "MIT"
}
```

## Example spec.md

```markdown
# Feature Specification

## Overview
Brief description of the feature.

## Requirements

### Functional Requirements

| ID | Requirement | Priority |
|----|-------------|----------|
| FR-01 | [Requirement] | Must |
| FR-02 | [Requirement] | Should |

### Non-Functional Requirements

| ID | Requirement | Target |
|----|-------------|--------|
| NFR-01 | Performance | [target] |

## Success Criteria
- [ ] All tests pass
- [ ] Code review approved
```

## Example plan.md

```markdown
# Implementation Plan

## Task Breakdown

### Task 1: Setup (2 min)
- Create project structure
- Initialize dependencies

### Task 2: Core Implementation (5 min)
- Implement main functionality
- Write tests

### Task 3: Documentation (2 min)
- Update README
- Add JSDoc comments

## Execution Order
Task 1 → Task 2 → Task 3
```

## .gitignore

```
# Dependencies
node_modules/

# Worktrees
.worktrees/

# Environment
.env
.env.local

# IDE
.vscode/
.idea/

# OS
.DS_Store
Thumbs.db
```