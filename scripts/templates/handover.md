# Handover: Task ${TASK_ID}

## 1. Session Context
- **Parent Session**: ${PARENT_SESSION_ID}
- **Worker Depth**: ${NEXT_DEPTH}
- **Timestamp**: ${TIMESTAMP}

## 2. Delegated Task
### Task ID
${TASK_ID}

### Description
${TASK_DESC}

### Verification Command
```bash
${VERIFY_CMD}
```

## 3. Worker Instructions
You are a specialized Worker Agent. Your goal is to complete the single task defined above.

### Step-by-Step Workflow:
1. **Initialize**: Run `bash scripts/worker-main.sh --init` to sync state.
2. **Execute**: Implement the requested changes in the codebase.
3. **Verify**: Run the verification command: `${VERIFY_CMD}`.
4. **Complete**:
   - If verification passes: Update `tasks.md` to mark the task as done, then output `<promise>DONE</promise>`.
   - If you get stuck: Log the issue to `errors.md` and signal the parent.

### Constraints:
- **Focus**: Only work on Task ${TASK_ID}.
- **Scope**: Do not modify files unrelated to this task.
- **Recursion**: Do not spawn further workers unless explicitly allowed.

## 4. Parent Handback
When you finish, the parent session will resume. Ensure all your changes are committed or reflected in the file system.
