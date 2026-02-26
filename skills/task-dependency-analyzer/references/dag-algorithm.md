# DAG Construction Algorithm

## Dependency Graph Construction

A Directed Acyclic Graph (DAG) represents task dependencies where:
- Nodes = Tasks
- Edges = Dependencies (Task A → Task B means B depends on A)

## Algorithm

### Step 1: Parse Plan

```python
def parse_plan(plan_md):
    tasks = []
    for task_section in extract_tasks(plan_md):
        task = {
            'id': extract_task_id(task_section),
            'files_created': extract_created_files(task_section),
            'files_modified': extract_modified_files(task_section),
            'dependencies': extract_explicit_deps(task_section)
        }
        tasks.append(task)
    return tasks
```

### Step 2: Infer Implicit Dependencies

```python
def infer_dependencies(tasks):
    # Build file -> task mapping
    file_creators = {}
    for task in tasks:
        for file in task['files_created']:
            file_creators[file] = task['id']

    # Check each task's file references
    for task in tasks:
        for file in task['files_modified'] + task.get('imports', []):
            if file in file_creators:
                # This task depends on the creator of this file
                task['dependencies'].append(file_creators[file])

    return tasks
```

### Step 3: Build Graph

```python
def build_dag(tasks):
    graph = {task['id']: [] for task in tasks}

    for task in tasks:
        for dep in task['dependencies']:
            if dep in graph:
                graph[dep].append(task['id'])

    return graph
```

### Step 4: Detect Cycles

```python
def has_cycle(graph):
    visited = set()
    rec_stack = set()

    def dfs(node):
        visited.add(node)
        rec_stack.add(node)

        for neighbor in graph.get(node, []):
            if neighbor not in visited:
                if dfs(neighbor):
                    return True
            elif neighbor in rec_stack:
                return True

        rec_stack.remove(node)
        return False

    for node in graph:
        if node not in visited:
            if dfs(node):
                return True

    return False
```

### Step 5: Topological Sort

```python
def topological_sort(graph):
    in_degree = {node: 0 for node in graph}

    for node in graph:
        for neighbor in graph[node]:
            in_degree[neighbor] += 1

    # Start with nodes that have no dependencies
    queue = [node for node, degree in in_degree.items() if degree == 0]
    result = []

    while queue:
        # All nodes in queue have same in_degree (can run in parallel)
        wave = list(queue)
        queue = []

        for node in wave:
            result.append(node)
            for neighbor in graph[node]:
                in_degree[neighbor] -= 1
                if in_degree[neighbor] == 0:
                    queue.append(neighbor)

    return result, wave
```

## Complexity Analysis

| Operation | Time Complexity | Space Complexity |
|-----------|----------------|------------------|
| Parse Plan | O(n) | O(n) |
| Build Graph | O(n × f) | O(n + e) |
| Detect Cycles | O(n + e) | O(n) |
| Topological Sort | O(n + e) | O(n) |

Where:
- n = number of tasks
- f = average files per task
- e = number of edges (dependencies)

## Parallelization Efficiency

```
Speedup = Sequential Time / Parallel Time

Sequential Time = n × avg_task_time
Parallel Time = waves × avg_task_time

Speedup % = (n - waves) / n × 100
```

### Example

```
10 tasks, 4 waves:
Speedup = (10 - 4) / 10 × 100 = 60%
```

## File Pattern Detection

### Common Dependency Patterns

```yaml
# Import statement detection
"import { X } from './module'"  # Depends on module
"from module import X"           # Depends on module
"require('./module')"             # Depends on module

# Test file detection
"tests/feature.test.js"          # Depends on src/feature.js
"spec/feature_spec.rb"           # Depends on lib/feature.rb
```

### Heuristics

1. If task creates `src/types.ts`, any task importing from `./types` depends on it
2. If task modifies `src/api.ts`, check imports to find dependencies
3. Test files typically depend on their corresponding source files