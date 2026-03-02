# Python Quick Start Template

A pre-configured project template for Python with ultrawork compatibility.

## Quick Start

```bash
# Copy template
cp -r templates/python my-project
cd my-project

# Create virtual environment
python -m venv venv
source venv/bin/activate  # or: venv\Scripts\activate

# Install dependencies
pip install pytest

# Initialize git
git init
git add -A
git commit -m "chore: init from template"
```

## Project Structure

```
my-project/
├── .agent/
│   ├── spec.md
│   ├── plan.md
│   └── changes/
│       ├── active.md
│       └── completed.md
├── src/
│   └── __init__.py
├── tests/
│   └── test_main.py
├── pyproject.toml
├── requirements.txt
└── .gitignore
```

## pyproject.toml

```toml
[project]
name = "my-project"
version = "1.0.0"
description = "Python project with ultrawork compatibility"
requires-python = ">=3.8"

[project.optional-dependencies]
dev = ["pytest>=7.0"]
```

## .gitignore

```
# Virtual environment
venv/
.venv/

# Python
__pycache__/
*.py[cod]
*.so

# Distribution
dist/
build/

# Testing
.pytest_cache/

# Worktrees
.worktrees/

# IDE
.vscode/
.idea/
```