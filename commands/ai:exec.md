---
name: ai:exec
description: Execute versioned task plans from docs/tasks/ using the task-executor skill
argument-hint: "<version> [--supervised] [--executor <shorthand>]"
allowed-tools: Task, Read, Write, Edit, Grep, Glob, Bash
internal: false
---

Execute task plan: $ARGUMENTS

**Goal**: Automatically execute all tasks in `docs/tasks/v{VERSION}/task.md` through the 4-phase cycle: understand → implement → test → review.

## Step 1: Parse Arguments

Extract from `$ARGUMENTS`:
- `version`: Required. The version number (e.g., `2.0`, `1.1`)
- `--supervised`: Optional. Pause for confirmation after each task
- `--executor <shorthand>`: Optional. Override default executor for implement step

## Step 2: Validate & Load

```bash
# Verify task file exists
TASK_FILE="docs/tasks/v${VERSION}/task.md"
test -f "$TASK_FILE" || { echo "错误: $TASK_FILE 不存在"; exit 1; }

# Resolve merged config
bash skills/task-executor/scripts/resolve-config.sh "$VERSION"

# Parse task status
bash skills/task-executor/scripts/parse-task-yaml.sh "$TASK_FILE" --status

# Detect available executors
bash skills/task-executor/scripts/detect-executors.sh
```

## Step 3: Read task-executor SKILL.md

Read and follow the full task-executor skill for execution:

```
Read skills/task-executor/SKILL.md
```

Follow the execution flow defined in SKILL.md exactly:
1. Resolve config hierarchy
2. Parse task YAML and build Sprint/Task dependency graph
3. For each Sprint, execute each Task through 4 phases
4. Run full verification after all Sprints
5. Output `<promise>ALL_TASKS_DONE</promise>` on completion

## Step 4: Begin Execution

Start from the next uncompleted task:

```bash
bash skills/task-executor/scripts/parse-task-yaml.sh "$TASK_FILE" --next
```

- If `ALL_DONE`: Report completion
- Otherwise: Begin the understand → implement → test → review cycle

## Usage Examples

```bash
/ai:exec 2.0                        # Autonomous execution
/ai:exec 1.1 --supervised           # Confirm each task
/ai:exec 2.0 --executor gemini      # Use Gemini for implementation
```
