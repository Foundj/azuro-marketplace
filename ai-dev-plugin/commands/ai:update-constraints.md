# /ai:update-constraints - Update Implementation Constraints

## Overview
Updates the implementation constraints file based on the current codebase state,
extracting patterns, conventions, and standards for pre-implementation checks.

## Usage
```
/ai:update-constraints [options]
```

## Options
| Option | Description |
|--------|-------------|
| `--scope <path>` | Limit analysis to specific directory |
| `--full` | Full codebase analysis (default: incremental) |
| `--dry-run` | Show what would be updated without writing |
| `--output <path>` | Custom output path for constraints file |

## Behavior

### 1. Analysis Scope
```yaml
default_analysis:
  directories:
    - src/
    - lib/
    - app/
  
  file_types:
    - "*.ts", "*.tsx"
    - "*.js", "*.jsx"
    - "*.py"
    - "*.go"
    - "*.rs"
  
  patterns_to_extract:
    - naming_conventions
    - import_patterns
    - error_handling
    - logging_patterns
    - testing_patterns
```

### 2. Constraint Categories
```
┌─────────────────────────────────────────────────────────────┐
│                  Constraint Categories                       │
├─────────────────────────────────────────────────────────────┤
│  1. Naming Conventions                                       │
│     ├─ Variables: camelCase, snake_case, etc.               │
│     ├─ Functions: naming patterns                            │
│     ├─ Classes: PascalCase conventions                       │
│     └─ Files: naming patterns                                │
│                                                              │
│  2. Code Patterns                                            │
│     ├─ Error handling style                                  │
│     ├─ Async/await patterns                                  │
│     ├─ State management                                      │
│     └─ Dependency injection                                  │
│                                                              │
│  3. Architecture                                             │
│     ├─ Layer boundaries                                      │
│     ├─ Module structure                                      │
│     └─ Import restrictions                                   │
│                                                              │
│  4. Testing                                                  │
│     ├─ Test file naming                                      │
│     ├─ Test structure                                        │
│     └─ Mocking patterns                                      │
└─────────────────────────────────────────────────────────────┘
```

### 3. Output
Updates `codebox/knowledge/implementation-constraints.json`:
```json
{
  "version": "1.0.0",
  "lastUpdated": "2025-01-06T12:00:00Z",
  "constraints": {
    "naming": {
      "variables": "camelCase",
      "functions": "camelCase",
      "classes": "PascalCase",
      "files": "kebab-case"
    },
    "patterns": {
      "errorHandling": "try-catch with custom Error classes",
      "async": "async/await preferred over .then()",
      "logging": "structured logging with levels"
    },
    "architecture": {
      "layers": ["api", "service", "repository"],
      "importRules": "no circular imports"
    }
  }
}
```

## Examples

### Full Analysis
```
/ai:update-constraints --full
```
Analyzes entire codebase and regenerates constraints.

### Scoped Analysis
```
/ai:update-constraints --scope src/auth/
```
Only analyzes the auth module.

### Dry Run
```
/ai:update-constraints --dry-run
```
Shows what constraints would be extracted without saving.

## Integration

### With /ai:check
The constraints file is used by `/ai:check` to validate
proposed implementations against project standards.

### Automatic Updates
Can be configured to run:
- After major refactors
- When changing coding standards
- Before starting new features

## Related Commands
- `/ai:check` - Uses constraints for pre-implementation validation
- `/ai:update-feature-index` - Updates feature index
- `/ai:archive` - Archives changes and updates knowledge base
