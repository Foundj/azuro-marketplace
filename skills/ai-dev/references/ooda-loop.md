# OODA Loop Reference - Autonomous Completion System

> **Ralph-Loop Integration**: Self-referencing tasks.md with completion promise mechanism
> **Purpose**: Enable agents to autonomously complete Phase 4 (Implementation) without human intervention
> **Key Innovation**: Agent reads and updates its own task file iteratively

---

## 📖 Table of Contents

1. [Overview](#overview)
2. [OODA Cycle Explained](#ooda-cycle-explained)
3. [Self-Referencing Mechanism](#self-referencing-mechanism)
4. [Completion Promise Protocol](#completion-promise-protocol)
5. [Implementation Example](#implementation-example)
6. [Iteration Limits](#iteration-limits)
7. [Error Recovery](#error-recovery)
8. [Integration with ai-dev](#integration-with-ai-dev)
9. [Best Practices](#best-practices)

---

## Overview

### What is OODA Loop?

**OODA** = **O**bserve → **O**rient → **D**ecide → **A**ct

Originally a military decision-making framework by John Boyd, adapted for autonomous software development.

### Why OODA in ai-dev?

**Problem**: Traditional workflows require human approval after every step
**Solution**: Autonomous loop where agent iteratively completes tasks until done

**Benefits**:
- ⚡ **Faster**: No waiting for human approval mid-implementation
- 🎯 **Focused**: Agent stays on track with clear task list
- 🔄 **Self-correcting**: Observe → fix → iterate
- 📊 **Measurable**: Clear completion criteria

---

## OODA Cycle Explained

### The 4 Phases

```
┌─────────────────────────────────────────────┐
│          OODA LOOP (Iteration N)            │
├─────────────────────────────────────────────┤
│                                             │
│  1. OBSERVE                                 │
│     - Read tasks.md                         │
│     - Check task statuses                   │
│     - Run tests (npm test)                  │
│     - Check build (npm run build)           │
│                                             │
│  2. ORIENT                                  │
│     - What's the next incomplete task?      │
│     - What failed in tests?                 │
│     - What's blocking progress?             │
│                                             │
│  3. DECIDE                                  │
│     - Which task to tackle next?            │
│     - What action is needed?                │
│     - Continue or declare completion?       │
│                                             │
│  4. ACT                                     │
│     - Execute the chosen action             │
│     - Update tasks.md (check box)           │
│     - Commit changes                        │
│     - Loop back to OBSERVE                  │
│                                             │
└─────────────────────────────────────────────┘
```

### Phase 1: OBSERVE 👁️

**Goal**: Gather current state of the world

**Actions**:
1. **Read tasks.md**
   ```bash
   cat changes/active/[change-id]/tasks.md
   ```
   - What tasks are complete? `[x]`
   - What tasks are pending? `[ ]`
   - What's the completion promise? `<promise>PENDING</promise>` or `<promise>DONE</promise>`

2. **Run tests**
   ```bash
   npm test
   ```
   - Are tests passing? ✅
   - Any failing tests? ❌
   - New errors introduced?

3. **Run build**
   ```bash
   npm run build
   ```
   - Build successful? ✅
   - TypeScript errors? ❌
   - ESLint errors? ❌

4. **Check completion criteria**
   - All checkboxes checked?
   - All tests passing?
   - Build succeeds?
   - ESLint/TypeScript clean?

**Output**: Current state snapshot

---

### Phase 2: ORIENT 🧭

**Goal**: Understand context and identify next step

**Questions**:
- What's the **first unchecked task** in the list?
- If tests are failing, **which test** and **why**?
- If build is failing, **what error** and **where**?
- Are we **blocked** by anything?

**Analysis**:
```typescript
// Example orientation logic
const tasks = parseTasks('tasks.md');
const nextTask = tasks.find(t => !t.completed);

if (nextTask) {
  // Continue with next task
} else if (testsFailure) {
  // Fix failing tests
} else if (buildFailure) {
  // Fix build errors
} else {
  // All done! Check completion criteria
}
```

**Output**: Clear understanding of situation

---

### Phase 3: DECIDE 🤔

**Goal**: Choose the optimal action

**Decision Tree**:

```
Are all tasks checked [x]?
  ├─ NO → DECIDE: Work on next unchecked task
  └─ YES → Are tests passing?
            ├─ NO → DECIDE: Fix failing tests
            └─ YES → Is build succeeding?
                      ├─ NO → DECIDE: Fix build errors
                      └─ YES → DECIDE: Declare completion (DONE)
```

**Possible Decisions**:
1. **Implement next task** - If tasks remain
2. **Fix test failures** - If tests fail
3. **Fix build errors** - If build fails
4. **Refine implementation** - If tests pass but logic is wrong
5. **Declare completion** - If all criteria met

**Output**: Chosen action

---

### Phase 4: ACT 💪

**Goal**: Execute the decided action

**Actions**:

#### Action Type 1: Implement Next Task

```typescript
// Example: Task is "Create IUserRepository interface"

// 1. Write code
const interfaceCode = `
export interface IUserRepository {
  findById(id: string): Promise<User | null>;
  findByEmail(email: string): Promise<User | null>;
}
`;
writeFile('src/lib/repositories/IUserRepository.ts', interfaceCode);

// 2. Update tasks.md (check the box)
updateTaskCheckbox('tasks.md', 'Create IUserRepository interface', true);

// 3. Commit
git('add', 'src/lib/repositories/IUserRepository.ts');
git('add', 'changes/active/001-user-auth/tasks.md');
git('commit', '-m', 'Create IUserRepository interface');
```

#### Action Type 2: Fix Test Failure

```typescript
// Example: Test fails "should return user by email"

// 1. Analyze error
const testOutput = runTests();
// Error: Expected user, got null

// 2. Fix code
const fix = `
async findByEmail(email: string): Promise<User | null> {
  return await db.query.users.findFirst({
    where: eq(users.email, email)  // Fixed: was missing 'where' clause
  });
}
`;
editFile('src/lib/repositories/UserRepository.ts', fix);

// 3. Verify fix
const newTestOutput = runTests();
// ✅ All tests pass

// 4. Commit
git('add', 'src/lib/repositories/UserRepository.ts');
git('commit', '-m', 'Fix: findByEmail missing where clause');
```

#### Action Type 3: Declare Completion

```typescript
// All tasks checked, all tests pass, build succeeds

// 1. Update completion promise
updateCompletionPromise('tasks.md', 'DONE');

// 2. Commit
git('add', 'changes/active/001-user-auth/tasks.md');
git('commit', '-m', 'Complete: User authentication feature');

// 3. Exit OODA loop
return { success: true, iterations: currentIteration };
```

**Output**: Changed state, ready for next observation

---

## Self-Referencing Mechanism

### The Core Innovation: Agent Reads Its Own Tasks

**Traditional Approach** (inefficient):
```
Human writes task list
  ↓
Agent reads once
  ↓
Agent completes all tasks in one shot
  ❌ Problem: Can't adapt to failures or new discoveries
```

**Ralph-Loop Approach** (self-referencing):
```
Agent reads tasks.md (iteration 1)
  ↓
Agent completes Task 1
  ↓
Agent updates tasks.md (check box)
  ↓
Agent reads tasks.md again (iteration 2)
  ↓
Agent sees Task 1 done, moves to Task 2
  ↓
... iterative loop ...
  ↓
Agent reads tasks.md (iteration N)
  ↓
Agent sees all tasks done, marks <promise>DONE</promise>
```

### How It Works

#### Step 1: Initialize tasks.md

**File**: `changes/active/001-user-auth/tasks.md`

```markdown
# Implementation Tasks - User Authentication

## 📋 Build Sequence
- [ ] Task 1: Create IUserRepository interface
- [ ] Task 2: Implement UserRepository class
- [ ] Task 3: Create AuthService with DI
- [ ] Task 4: Create API endpoint
- [ ] Task 5: Add unit tests
- [ ] Task 6: Add integration tests

## 🔄 Completion Promise
<promise>PENDING</promise>

## ✅ Completion Criteria
- [ ] All checkboxes above are checked
- [ ] All tests pass: `npm test`
- [ ] Build succeeds: `npm run build`
- [ ] ESLint: 0 errors
- [ ] TypeScript: 0 errors
```

#### Step 2: OODA Loop Reads tasks.md (Iteration 1)

```typescript
// Agent code (conceptual)
const tasksFile = readFile('changes/active/001-user-auth/tasks.md');
const tasks = parseTasksMarkdown(tasksFile);

console.log(tasks);
// Output:
// [
//   { id: 1, title: 'Create IUserRepository interface', completed: false },
//   { id: 2, title: 'Implement UserRepository class', completed: false },
//   ...
// ]

const completionPromise = extractPromise(tasksFile);
console.log(completionPromise); // "PENDING"
```

#### Step 3: Agent Completes Task 1

```typescript
// Agent creates interface file
writeFile('src/lib/repositories/IUserRepository.ts', interfaceCode);

// Agent updates tasks.md (self-modification!)
const updatedContent = tasksFile.replace(
  '- [ ] Task 1: Create IUserRepository interface',
  '- [x] Task 1: Create IUserRepository interface'
);
writeFile('changes/active/001-user-auth/tasks.md', updatedContent);
```

#### Step 4: OODA Loop Reads tasks.md Again (Iteration 2)

```typescript
// Agent reads tasks.md again (now updated)
const tasksFile = readFile('changes/active/001-user-auth/tasks.md');
const tasks = parseTasksMarkdown(tasksFile);

console.log(tasks);
// Output:
// [
//   { id: 1, title: 'Create IUserRepository interface', completed: true },  // ✅ Now true!
//   { id: 2, title: 'Implement UserRepository class', completed: false },
//   ...
// ]

// Agent sees Task 1 is done, moves to Task 2
const nextTask = tasks.find(t => !t.completed);
console.log(nextTask); // Task 2: Implement UserRepository class
```

#### Step 5: Repeat Until Completion

```
Iteration 1: Task 1 ✅
Iteration 2: Task 2 ✅
Iteration 3: Task 3 ✅
Iteration 4: Task 4 ✅ → Tests fail ❌
Iteration 5: Fix tests ✅
Iteration 6: Task 5 ✅
Iteration 7: Task 6 ✅
Iteration 8: All done → <promise>DONE</promise>
```

---

## Parsing Extended tasks.md Format

### New tasks.md Structure (v2.0-enhanced)

The extended tasks.md format includes additional metadata, dependency tracking, and detailed OODA history. Here's how to parse it:

### 1. Parsing Metadata Section

```typescript
interface TasksMetadata {
  changeId: string;
  phase: number;
  currentIteration: number;
  maxIterations: number;
  completion: 'PENDING' | 'DONE';
  started: string;
  lastUpdated: string;
}

function parseMetadata(content: string): TasksMetadata {
  const metadataSection = content.match(/## 📊 Metadata\n([\s\S]*?)\n---/);
  if (!metadataSection) throw new Error('Metadata section not found');

  const lines = metadataSection[1].split('\n');
  const getValue = (key: string) => {
    const line = lines.find(l => l.includes(key));
    if (!line) return null;
    return line.split(':')[1].trim();
  };

  const changeId = getValue('Change ID');
  const phase = parseInt(getValue('Phase') || '4');
  const iterationMatch = getValue('OODA Iteration')?.match(/(\d+)\/(\d+)/);
  const currentIteration = parseInt(iterationMatch?.[1] || '0');
  const maxIterations = parseInt(iterationMatch?.[2] || '10');
  const completion = getValue('Completion')?.includes('DONE') ? 'DONE' : 'PENDING';
  const started = getValue('Started') || '';
  const lastUpdated = getValue('Last Updated') || '';

  return {
    changeId,
    phase,
    currentIteration,
    maxIterations,
    completion,
    started,
    lastUpdated
  };
}
```

### 2. Parsing Task List with Dependencies

```typescript
interface Task {
  number: number;
  description: string;
  filePath?: string;
  dependencies?: string;
  estimate?: string;
  completed: boolean;
  phase: 'core' | 'integration' | 'testing' | 'issue-fixes';
}

function parseTaskList(content: string): Task[] {
  const tasks: Task[] = [];

  // Extract task list section
  const taskListSection = content.match(/## 📋 Task List\n([\s\S]*?)\n## ✅ Validation Criteria/);
  if (!taskListSection) throw new Error('Task list section not found');

  const lines = taskListSection[1].split('\n');
  let currentPhase: Task['phase'] = 'core';

  for (let i = 0; i < lines.length; i++) {
    const line = lines[i];

    // Detect phase headers
    if (line.includes('### Phase 1: Core Implementation')) {
      currentPhase = 'core';
      continue;
    } else if (line.includes('### Phase 2: Integration')) {
      currentPhase = 'integration';
      continue;
    } else if (line.includes('### Phase 3: Testing')) {
      currentPhase = 'testing';
      continue;
    } else if (line.includes('### Phase 5 Issue Fixes')) {
      currentPhase = 'issue-fixes';
      continue;
    }

    // Parse task line: "- [x] Task 1: Description (file/path)"
    const taskMatch = line.match(/^- \[([ x])\] Task (\d+): ([^(]+)(?:\(([^)]+)\))?/);
    if (taskMatch) {
      const [, checked, number, description, filePath] = taskMatch;
      const task: Task = {
        number: parseInt(number),
        description: description.trim(),
        filePath,
        completed: checked === 'x',
        phase: currentPhase
      };

      // Parse dependencies and estimate from next lines
      if (i + 1 < lines.length && lines[i + 1].includes('Dependencies:')) {
        task.dependencies = lines[i + 1].split(':')[1].trim();
      }
      if (i + 2 < lines.length && lines[i + 2].includes('Estimated:')) {
        task.estimate = lines[i + 2].split(':')[1].trim();
      }

      tasks.push(task);
    }
  }

  return tasks;
}
```

### 3. Parsing OODA History

```typescript
interface OODAIteration {
  iteration: number;
  timestamp: string;
  completed: string[];
  testsStatus: string;
  testsPassing?: number;
  testsTotal?: number;
  buildStatus: string;
  decision: string;
  action: string;
  notes: string;
}

function parseOODAHistory(content: string): OODAIteration[] {
  const iterations: OODAIteration[] = [];

  // Extract OODA history section
  const historySection = content.match(/## 🔍 OODA Loop History\n([\s\S]*?)(?:\n## |$)/);
  if (!historySection) return [];

  const iterationMatches = historySection[1].matchAll(/### Iteration (\d+) \(([^)]+)\)\n([\s\S]*?)(?=\n### Iteration |\n## |\*\(|$)/g);

  for (const match of iterationMatches) {
    const [, iterNum, timestamp, body] = match;

    const getValue = (key: string) => {
      const line = body.split('\n').find(l => l.includes(`**${key}**:`));
      return line?.split(':')[1].trim() || '';
    };

    const testsMatch = getValue('Tests').match(/(\d+)\/(\d+)/);

    iterations.push({
      iteration: parseInt(iterNum),
      timestamp,
      completed: getValue('Completed').split(',').map(s => s.trim()).filter(Boolean),
      testsStatus: getValue('Tests').split('(')[0].trim(),
      testsPassing: testsMatch ? parseInt(testsMatch[1]) : undefined,
      testsTotal: testsMatch ? parseInt(testsMatch[2]) : undefined,
      buildStatus: getValue('Build'),
      decision: getValue('Decision'),
      action: getValue('Action'),
      notes: getValue('Notes')
    });
  }

  return iterations;
}
```

### 4. Parsing Progress Tracking

```typescript
interface ProgressTracking {
  totalTasks: number;
  completed: number;
  remaining: number;
  progressPercentage: number;
  testStatus: string;
  buildStatus: string;
  blockers: string[];
}

function parseProgressTracking(content: string): ProgressTracking | null {
  const progressSection = content.match(/## 📈 Progress Tracking\n([\s\S]*?)(?:\n## |---)/);
  if (!progressSection) return null;

  const getValue = (key: string) => {
    const line = progressSection[1].split('\n').find(l => l.includes(`**${key}**:`));
    return line?.split(':')[1].trim() || '';
  };

  return {
    totalTasks: parseInt(getValue('Total Tasks')) || 0,
    completed: parseInt(getValue('Completed')) || 0,
    remaining: parseInt(getValue('Remaining')) || 0,
    progressPercentage: parseInt(getValue('Progress')?.replace('%', '')) || 0,
    testStatus: getValue('Test Status'),
    buildStatus: getValue('Build Status'),
    blockers: getValue('Blockers').split(',').map(s => s.trim()).filter(Boolean)
  };
}
```

### 5. Complete Parsing Function

```typescript
interface ParsedTasksFile {
  metadata: TasksMetadata;
  tasks: Task[];
  oodaHistory: OODAIteration[];
  progress: ProgressTracking | null;
  validationCriteria: string[];
}

function parseTasksFile(filePath: string): ParsedTasksFile {
  const content = readFile(filePath);

  return {
    metadata: parseMetadata(content),
    tasks: parseTaskList(content),
    oodaHistory: parseOODAHistory(content),
    progress: parseProgressTracking(content),
    validationCriteria: parseValidationCriteria(content)
  };
}

function parseValidationCriteria(content: string): string[] {
  const criteriaSection = content.match(/## ✅ Validation Criteria\n([\s\S]*?)\n---/);
  if (!criteriaSection) return [];

  return criteriaSection[1]
    .split('\n')
    .filter(line => line.startsWith('- [ ]') || line.startsWith('- [x]'))
    .map(line => line.replace(/^- \[[ x]\] /, ''));
}
```

### 6. Updating tasks.md During OODA Loop

```typescript
async function recordOODAIteration(
  tasksFilePath: string,
  iteration: OODAIteration
): Promise<void> {
  const content = readFile(tasksFilePath);

  // 1. Update metadata
  const updatedContent = content.replace(
    /(\*\*OODA Iteration\*\*: )\d+\/(\d+)/,
    `$1${iteration.iteration}/$2`
  ).replace(
    /(\*\*Last Updated\*\*: ).+/,
    `$1${new Date().toISOString()}`
  );

  // 2. Add new iteration to OODA History
  const newIterationEntry = `
### Iteration ${iteration.iteration} (${iteration.timestamp})
- **Completed**: ${iteration.completed.join(', ')}
- **Tests**: ${iteration.testsStatus} (${iteration.testsPassing}/${iteration.testsTotal})
- **Build**: ${iteration.buildStatus}
- **Decision**: ${iteration.decision}
- **Action**: ${iteration.action}
- **Notes**: ${iteration.notes}
`;

  const historyInsertPoint = content.indexOf('*(每次迭代后添加新的iteration记录');
  const finalContent = [
    updatedContent.slice(0, historyInsertPoint),
    newIterationEntry,
    '\n',
    updatedContent.slice(historyInsertPoint)
  ].join('');

  // 3. Update progress tracking
  const tasks = parseTaskList(finalContent);
  const completed = tasks.filter(t => t.completed).length;
  const total = tasks.length;
  const progress = Math.round((completed / total) * 100);

  const progressUpdated = finalContent.replace(
    /- \*\*Total Tasks\*\*: \d+/,
    `- **Total Tasks**: ${total}`
  ).replace(
    /- \*\*Completed\*\*: \d+/,
    `- **Completed**: ${completed}`
  ).replace(
    /- \*\*Remaining\*\*: \d+/,
    `- **Remaining**: ${total - completed}`
  ).replace(
    /- \*\*Progress\*\*: \d+%/,
    `- **Progress**: ${progress}%`
  );

  writeFile(tasksFilePath, progressUpdated);
}
```

### 7. Usage in OODA Loop

```typescript
async function oodaLoopEnhanced(config: {
  changeId: string;
  maxIterations: number;
}): Promise<{ success: boolean; iterations: number }> {

  const tasksFile = `changes/active/${config.changeId}/tasks.md`;

  for (let iteration = 1; iteration <= config.maxIterations; iteration++) {
    console.log(`\n=== OODA Iteration ${iteration} ===`);

    // OBSERVE: Parse tasks.md with extended format
    const parsed = parseTasksFile(tasksFile);
    console.log(`Metadata: ${parsed.metadata.changeId}, Iteration ${parsed.metadata.currentIteration}/${parsed.metadata.maxIterations}`);
    console.log(`Progress: ${parsed.progress?.completed}/${parsed.progress?.totalTasks} tasks (${parsed.progress?.progressPercentage}%)`);

    // Check for completion
    if (parsed.metadata.completion === 'DONE') {
      console.log('✅ Completion promise is DONE. Exiting OODA loop.');
      return { success: true, iterations: iteration };
    }

    // ORIENT: Analyze current state
    const nextTask = parsed.tasks.find(t => !t.completed);
    const testResult = await runCommand('npm test');
    const buildResult = await runCommand('npm run build');

    // DECIDE & ACT
    let actionTaken = '';
    let completedTasks: string[] = [];

    if (nextTask) {
      await implementTask(nextTask);
      await updateTaskCheckbox(tasksFile, `Task ${nextTask.number}`, true);
      actionTaken = `Implement Task ${nextTask.number}`;
      completedTasks = [`Task ${nextTask.number}`];
    } else if (testResult.exitCode !== 0) {
      await fixTests();
      actionTaken = 'Fix failing tests';
    } else if (buildResult.exitCode !== 0) {
      await fixBuild();
      actionTaken = 'Fix build errors';
    } else {
      await updateCompletionPromise(tasksFile, 'DONE');
      actionTaken = 'Declare completion';
    }

    // Record iteration
    await recordOODAIteration(tasksFile, {
      iteration,
      timestamp: new Date().toISOString(),
      completed: completedTasks,
      testsStatus: testResult.exitCode === 0 ? '✅ Passed' : '❌ Failed',
      testsPassing: parseTestCount(testResult.stdout).passing,
      testsTotal: parseTestCount(testResult.stdout).total,
      buildStatus: buildResult.exitCode === 0 ? '✅ Success' : '❌ Failed',
      decision: nextTask ? `Next task = Task ${nextTask.number}` : 'All criteria met',
      action: actionTaken,
      notes: `Iteration ${iteration} complete`
    });
  }

  return { success: false, iterations: config.maxIterations };
}
```

---

## Completion Promise Protocol

### The `<promise>` Tag

**Purpose**: Simple, unambiguous signal for completion state

**States**:
- `<promise>PENDING</promise>` - Work in progress
- `<promise>DONE</promise>` - All criteria met, ready for Phase 5

### Detection Logic

```typescript
function detectCompletionPromise(tasksFilePath: string): 'PENDING' | 'DONE' {
  const content = readFile(tasksFilePath);

  if (content.includes('<promise>DONE</promise>')) {
    return 'DONE';
  }

  if (content.includes('<promise>PENDING</promise>')) {
    return 'PENDING';
  }

  throw new Error('No completion promise found in tasks.md');
}
```

### When to Set `<promise>DONE</promise>`

**Criteria** (ALL must be true):
1. ✅ All task checkboxes are checked `[x]`
2. ✅ All tests pass: `npm test` exit code 0
3. ✅ Build succeeds: `npm run build` exit code 0
4. ✅ ESLint clean: `npm run lint` exit code 0
5. ✅ TypeScript clean: `tsc --noEmit` exit code 0

**Example**:
```typescript
async function checkCompletionCriteria(tasksFile: string): Promise<boolean> {
  // 1. All tasks checked?
  const tasks = parseTasksMarkdown(tasksFile);
  const allTasksDone = tasks.every(t => t.completed);

  // 2. Tests pass?
  const testResult = await runCommand('npm test');
  const testsPass = testResult.exitCode === 0;

  // 3. Build succeeds?
  const buildResult = await runCommand('npm run build');
  const buildSucceeds = buildResult.exitCode === 0;

  // 4. Lint clean?
  const lintResult = await runCommand('npm run lint');
  const lintClean = lintResult.exitCode === 0;

  // 5. TypeScript clean?
  const tscResult = await runCommand('tsc --noEmit');
  const tscClean = tscResult.exitCode === 0;

  return allTasksDone && testsPass && buildSucceeds && lintClean && tscClean;
}
```

### Updating the Promise

```typescript
async function updateCompletionPromise(
  tasksFilePath: string,
  newState: 'PENDING' | 'DONE'
): Promise<void> {
  const content = readFile(tasksFilePath);

  const updatedContent = content.replace(
    /<promise>(PENDING|DONE)<\/promise>/,
    `<promise>${newState}</promise>`
  );

  writeFile(tasksFilePath, updatedContent);

  // Commit the change
  await runCommand(`git add ${tasksFilePath}`);
  await runCommand(`git commit -m "Update completion promise: ${newState}"`);
}
```

---

## Implementation Example

### Complete OODA Loop Code (Pseudocode)

```typescript
async function oodaLoop(config: {
  changeId: string;
  maxIterations: number;
}): Promise<{ success: boolean; iterations: number }> {

  const tasksFile = `changes/active/${config.changeId}/tasks.md`;

  for (let iteration = 1; iteration <= config.maxIterations; iteration++) {
    console.log(`\n=== OODA Iteration ${iteration} ===`);

    // ─────────────────────────────────────
    // 1. OBSERVE
    // ─────────────────────────────────────
    console.log('🔍 OBSERVE: Gathering current state...');

    const tasksContent = readFile(tasksFile);
    const tasks = parseTasksMarkdown(tasksContent);
    const completionPromise = detectCompletionPromise(tasksFile);

    const testResult = await runCommand('npm test');
    const buildResult = await runCommand('npm run build');

    console.log(`Tasks: ${tasks.filter(t => t.completed).length}/${tasks.length} done`);
    console.log(`Tests: ${testResult.exitCode === 0 ? '✅ PASS' : '❌ FAIL'}`);
    console.log(`Build: ${buildResult.exitCode === 0 ? '✅ PASS' : '❌ FAIL'}`);
    console.log(`Promise: ${completionPromise}`);

    // Check for completion
    if (completionPromise === 'DONE') {
      console.log('✅ Completion promise is DONE. Exiting OODA loop.');
      return { success: true, iterations: iteration };
    }

    // ─────────────────────────────────────
    // 2. ORIENT
    // ─────────────────────────────────────
    console.log('🧭 ORIENT: Analyzing situation...');

    const nextTask = tasks.find(t => !t.completed);
    const testsFailing = testResult.exitCode !== 0;
    const buildFailing = buildResult.exitCode !== 0;

    let situation: string;
    if (nextTask) {
      situation = `Next task: ${nextTask.title}`;
    } else if (testsFailing) {
      situation = 'All tasks done, but tests failing';
    } else if (buildFailing) {
      situation = 'All tasks done, tests pass, but build failing';
    } else {
      situation = 'All criteria met - ready for completion';
    }

    console.log(`Situation: ${situation}`);

    // ─────────────────────────────────────
    // 3. DECIDE
    // ─────────────────────────────────────
    console.log('🤔 DECIDE: Choosing action...');

    let action: Action;

    if (nextTask) {
      action = { type: 'implement_task', task: nextTask };
    } else if (testsFailing) {
      action = { type: 'fix_tests', error: testResult.stderr };
    } else if (buildFailing) {
      action = { type: 'fix_build', error: buildResult.stderr };
    } else {
      action = { type: 'declare_completion' };
    }

    console.log(`Action: ${action.type}`);

    // ─────────────────────────────────────
    // 4. ACT
    // ─────────────────────────────────────
    console.log('💪 ACT: Executing action...');

    await executeAction(action, tasksFile);

    console.log(`✅ Action completed. Looping back to OBSERVE...\n`);
  }

  // Max iterations reached
  console.log(`❌ Max iterations (${config.maxIterations}) reached without completion.`);
  return { success: false, iterations: config.maxIterations };
}

// ─────────────────────────────────────
// Action Execution
// ─────────────────────────────────────

async function executeAction(action: Action, tasksFile: string): Promise<void> {
  switch (action.type) {
    case 'implement_task':
      await implementTask(action.task);
      await updateTaskCheckbox(tasksFile, action.task.title, true);
      await gitCommit(`Implement: ${action.task.title}`);
      break;

    case 'fix_tests':
      await analyzeAndFixTests(action.error);
      await gitCommit('Fix: Resolve test failures');
      break;

    case 'fix_build':
      await analyzeAndFixBuild(action.error);
      await gitCommit('Fix: Resolve build errors');
      break;

    case 'declare_completion':
      await updateCompletionPromise(tasksFile, 'DONE');
      await gitCommit('Complete: All tasks done');
      break;
  }
}

// ─────────────────────────────────────
// Helper Functions
// ─────────────────────────────────────

function parseTasksMarkdown(content: string): Task[] {
  const lines = content.split('\n');
  const tasks: Task[] = [];

  for (const line of lines) {
    const match = line.match(/^- \[([ x])\] (.+)$/);
    if (match) {
      tasks.push({
        title: match[2],
        completed: match[1] === 'x'
      });
    }
  }

  return tasks;
}

async function updateTaskCheckbox(
  tasksFile: string,
  taskTitle: string,
  completed: boolean
): Promise<void> {
  const content = readFile(tasksFile);
  const checkbox = completed ? '[x]' : '[ ]';

  const updatedContent = content.replace(
    new RegExp(`- \\[[ x]\\] ${escapeRegex(taskTitle)}`),
    `- ${checkbox} ${taskTitle}`
  );

  writeFile(tasksFile, updatedContent);
}

async function gitCommit(message: string): Promise<void> {
  await runCommand('git add .');
  await runCommand(`git commit -m "${message}"`);
}
```

### Example Run

```
=== OODA Iteration 1 ===
🔍 OBSERVE: Gathering current state...
Tasks: 0/6 done
Tests: ✅ PASS (no tests yet)
Build: ✅ PASS
Promise: PENDING

🧭 ORIENT: Analyzing situation...
Situation: Next task: Create IUserRepository interface

🤔 DECIDE: Choosing action...
Action: implement_task

💪 ACT: Executing action...
✅ Action completed. Looping back to OBSERVE...

=== OODA Iteration 2 ===
🔍 OBSERVE: Gathering current state...
Tasks: 1/6 done
Tests: ✅ PASS
Build: ✅ PASS
Promise: PENDING

🧭 ORIENT: Analyzing situation...
Situation: Next task: Implement UserRepository class

🤔 DECIDE: Choosing action...
Action: implement_task

💪 ACT: Executing action...
✅ Action completed. Looping back to OBSERVE...

... (iterations 3-7) ...

=== OODA Iteration 8 ===
🔍 OBSERVE: Gathering current state...
Tasks: 6/6 done
Tests: ✅ PASS
Build: ✅ PASS
Promise: PENDING

🧭 ORIENT: Analyzing situation...
Situation: All criteria met - ready for completion

🤔 DECIDE: Choosing action...
Action: declare_completion

💪 ACT: Executing action...
✅ Action completed. Looping back to OBSERVE...

=== OODA Iteration 9 ===
🔍 OBSERVE: Gathering current state...
Promise: DONE

✅ Completion promise is DONE. Exiting OODA loop.

Result: { success: true, iterations: 9 }
```

---

## Ralph-Wiggum Self-Completion Enhancements

### Overview

**Ralph-Wiggum模式** 是OODA循环的增强版本，添加了**自我验证**和**自动修复**能力，实现真正的自主完成。

**核心增强**:
1. **Assertion-based Verification** (TDD模式) - 每次迭代后验证关键断言
2. **Auto Regression Testing** - 自动运行回归测试防止破坏现有功能
3. **Performance Baseline Check** - 性能退化自动检测
4. **Self-Healing Iteration** - 失败后自主修复，无需人工干预

### Assertion-Based Verification (TDD模式)

**概念**: 在tasks.md中定义关键断言，OODA循环每次迭代后自动验证

**实现**:

```typescript
// tasks.md format with assertions
interface TaskWithAssertions {
  task: string;
  assertions: string[];  // 关键验证点
}

// Example tasks.md
/**
 * - [x] Task 1: Create UserRepository
 *   - Assertions:
 *     - `await repo.findById(1)` returns user
 *     - `await repo.findById(999)` returns null
 *     - `await repo.create({...})` inserts to DB
 */

async function verifyTaskAssertions(
  changeId: string,
  taskNumber: number
): Promise<boolean> {
  // 1. Read task assertions
  const tasks = parseTasksFile(`changes/active/${changeId}/tasks.md`);
  const task = tasks.find(t => t.number === taskNumber);

  if (!task.assertions || task.assertions.length === 0) {
    return true;  // No assertions = skip verification
  }

  // 2. Run each assertion
  for (const assertion of task.assertions) {
    try {
      // SECURITY: Don't use `node -e` with user input (code injection risk)
      // Instead, create a temporary test file and run it safely
      const testFile = `.claude-temp-assertion-${taskNumber}-${Date.now()}.test.js`;

      await Write({
        file_path: testFile,
        content: `
// Auto-generated assertion test for Task ${taskNumber}
const assert = require('assert');

try {
  ${assertion}
  console.log('ASSERTION_PASSED');
  process.exit(0);
} catch (error) {
  console.error('ASSERTION_FAILED:', error.message);
  process.exit(1);
}
`
      });

      const result = await Bash({
        command: `node ${testFile}`,
        timeout: 30000,
        description: `Verify assertion: ${assertion.slice(0, 50)}...`
      });

      // Cleanup temp file
      await Bash({ command: `rm -f ${testFile}` });

      if (result.exitCode !== 0) {
        console.log(`❌ Assertion failed: ${assertion}`);
        console.log(`   Output: ${result.stderr}`);
        return false;
      }

      console.log(`✓ Assertion passed: ${assertion}`);
    } catch (error) {
      console.log(`❌ Assertion error: ${assertion} - ${error.message}`);
      return false;
    }
  }

  return true;  // All assertions passed
}

// Enhanced OODA loop with assertion verification
async function oodaLoopWithAssertions(config: OODAConfig): Promise<OODAResult> {
  for (let iteration = 1; iteration <= config.maxIterations; iteration++) {
    // OBSERVE & ORIENT & DECIDE
    const nextTask = findNextTask();

    // ACT
    await implementTask(nextTask);
    await updateTaskCheckbox(nextTask.number, true);

    // VERIFY ASSERTIONS (NEW!)
    const assertionsPassed = await verifyTaskAssertions(config.changeId, nextTask.number);

    if (!assertionsPassed) {
      console.log(`⚠️ Task ${nextTask.number} assertions failed. Rolling back...`);

      // Self-healing: Mark task as incomplete and retry
      await updateTaskCheckbox(nextTask.number, false);

      // Add debugging task
      await addTask({
        number: nextTask.number + 0.5,
        description: `Debug and fix assertions for Task ${nextTask.number}`,
        dependencies: [`Task ${nextTask.number}`]
      });

      continue;  // Retry in next iteration
    }

    // Run tests
    const testResult = await runTests();
    if (!testResult.passed) {
      // Self-healing: Fix tests
      await fixFailingTests(testResult.failures);
    }
  }
}
```

---

### Auto Regression Testing

**概念**: 每次迭代后自动运行完整测试套件，防止破坏现有功能

**实现**:

```typescript
interface RegressionTestResult {
  passed: boolean;
  totalTests: number;
  passingTests: number;
  newFailures: string[];  // Tests that passed before but fail now
}

async function runRegressionTests(
  changeId: string,
  baseline?: RegressionTestResult
): Promise<RegressionTestResult> {
  // 1. Run full test suite
  const testResult = await Bash({
    command: 'npm test -- --json --outputFile=test-results.json',
    timeout: 180000,
    description: 'Run full regression test suite'
  });

  // 2. Parse results
  const results = JSON.parse(await Read({ file_path: 'test-results.json' }));

  const currentResult: RegressionTestResult = {
    passed: testResult.exitCode === 0,
    totalTests: results.numTotalTests,
    passingTests: results.numPassedTests,
    newFailures: []
  };

  // 3. Compare with baseline (if exists)
  if (baseline) {
    const previouslyPassing = results.testResults.filter(
      test => test.status === 'failed' &&
              wasPassingBefore(test.name, baseline)
    );

    currentResult.newFailures = previouslyPassing.map(t => t.name);

    if (currentResult.newFailures.length > 0) {
      console.log(`⚠️ Regression detected! ${currentResult.newFailures.length} tests broke:`);
      currentResult.newFailures.forEach(name => console.log(`  - ${name}`));
    }
  }

  return currentResult;
}

// Enhanced OODA with regression testing
async function oodaLoopWithRegressionTests(config: OODAConfig): Promise<OODAResult> {
  // Establish baseline before starting
  const baseline = await runRegressionTests(config.changeId);

  for (let iteration = 1; iteration <= config.maxIterations; iteration++) {
    // ACT
    await implementNextTask();

    // VERIFY: Run regression tests
    const regressionResult = await runRegressionTests(config.changeId, baseline);

    if (regressionResult.newFailures.length > 0) {
      console.log(`🔧 Auto-fixing ${regressionResult.newFailures.length} regressions...`);

      // Self-healing: Attempt to fix regressions
      for (const failedTest of regressionResult.newFailures) {
        await Task({
          subagent_type: 'debugger',
          prompt: `Fix regression: ${failedTest} is now failing`,
          model: 'haiku'
        });
      }

      // Re-run tests
      const retryResult = await runRegressionTests(config.changeId, baseline);
      if (retryResult.newFailures.length > 0) {
        // Still failing - escalate to user
        console.log(`❌ Cannot auto-fix regressions. User intervention needed.`);
        return { success: false, reason: 'regression_unfixable' };
      }
    }
  }

  return { success: true };
}
```

---

### Performance Baseline Check

**概念**: 检测性能退化，确保优化不引入性能问题

**实现**:

```typescript
interface PerformanceBaseline {
  testSuiteDuration: number;     // milliseconds
  buildTime: number;              // milliseconds
  bundleSize?: number;            // bytes
  criticalPaths: {
    [pathName: string]: number;   // milliseconds
  };
}

async function establishPerformanceBaseline(): Promise<PerformanceBaseline> {
  // 1. Measure test duration
  const testStart = Date.now();
  await Bash({ command: 'npm test', description: 'Baseline test run' });
  const testDuration = Date.now() - testStart;

  // 2. Measure build time
  const buildStart = Date.now();
  await Bash({ command: 'npm run build', description: 'Baseline build' });
  const buildDuration = Date.now() - buildStart;

  // 3. Measure bundle size (if applicable)
  const bundleSize = await getBundleSize();

  return {
    testSuiteDuration: testDuration,
    buildTime: buildDuration,
    bundleSize
  };
}

async function checkPerformanceRegression(
  baseline: PerformanceBaseline,
  threshold: number = 1.2  // 20% regression tolerance
): Promise<{ passed: boolean; issues: string[] }> {
  const current = await establishPerformanceBaseline();
  const issues: string[] = [];

  // Check test duration
  if (current.testSuiteDuration > baseline.testSuiteDuration * threshold) {
    const regression = ((current.testSuiteDuration / baseline.testSuiteDuration - 1) * 100).toFixed(1);
    issues.push(`Test suite ${regression}% slower (${baseline.testSuiteDuration}ms → ${current.testSuiteDuration}ms)`);
  }

  // Check build time
  if (current.buildTime > baseline.buildTime * threshold) {
    const regression = ((current.buildTime / baseline.buildTime - 1) * 100).toFixed(1);
    issues.push(`Build ${regression}% slower (${baseline.buildTime}ms → ${current.buildTime}ms)`);
  }

  // Check bundle size
  if (current.bundleSize && baseline.bundleSize &&
      current.bundleSize > baseline.bundleSize * threshold) {
    const regression = ((current.bundleSize / baseline.bundleSize - 1) * 100).toFixed(1);
    issues.push(`Bundle ${regression}% larger (${baseline.bundleSize} → ${current.bundleSize} bytes)`);
  }

  return {
    passed: issues.length === 0,
    issues
  };
}

// Enhanced OODA with performance checking
async function oodaLoopWithPerformanceCheck(config: OODAConfig): Promise<OODAResult> {
  // Establish baseline
  const perfBaseline = await establishPerformanceBaseline();

  for (let iteration = 1; iteration <= config.maxIterations; iteration++) {
    // ACT
    await implementNextTask();

    // VERIFY: Check performance
    const perfCheck = await checkPerformanceRegression(perfBaseline);

    if (!perfCheck.passed) {
      console.log(`⚠️ Performance regression detected:`);
      perfCheck.issues.forEach(issue => console.log(`  - ${issue}`));

      // User decision: acceptable or fix?
      const decision = await AskUserQuestion({
        questions: [{
          question: "Performance regression detected. How to proceed?",
          header: "Performance",
          multiSelect: false,
          options: [
            { label: "Accept", description: "Regression acceptable for this change" },
            { label: "Fix", description: "Attempt to optimize and fix regression" },
            { label: "Investigate", description: "Profile and analyze before deciding" }
          ]
        }]
      });

      if (decision.answers["Performance"] === "Fix") {
        // Self-healing: Attempt optimization
        await Task({
          subagent_type: 'performance-optimizer',
          prompt: `Optimize to fix performance regressions: ${perfCheck.issues.join(', ')}`,
          model: 'sonnet'
        });
      }
    }
  }

  return { success: true };
}
```

---

### Self-Healing Iteration Logic

**概念**: 当测试失败或问题出现时，自动尝试修复而不是立即停止

**策略**:
1. **First attempt**: 使用debugger agent快速修复
2. **Second attempt**: 使用更强模型（sonnet）深度分析
3. **Third attempt**: 回滚更改，尝试替代方案
4. **Final**: 升级给用户

**实现**:

```typescript
interface SelfHealingConfig {
  maxRetries: number;        // Max自动修复尝试次数
  escalationThreshold: number;  // 失败多少次后升级
  rollbackOnFailure: boolean;   // 是否自动回滚
}

async function selfHealingOODALoop(
  config: OODAConfig,
  healingConfig: SelfHealingConfig = {
    maxRetries: 3,
    escalationThreshold: 2,
    rollbackOnFailure: true
  }
): Promise<OODAResult> {
  let consecutiveFailures = 0;

  for (let iteration = 1; iteration <= config.maxIterations; iteration++) {
    // ACT
    const task = findNextTask();
    await implementTask(task);

    // VERIFY
    const testResult = await runTests();

    if (!testResult.passed) {
      consecutiveFailures++;
      console.log(`⚠️ Tests failed (failure #${consecutiveFailures})`);

      // Self-healing strategy
      if (consecutiveFailures <= healingConfig.maxRetries) {
        console.log(`🔧 Attempting auto-fix (try ${consecutiveFailures}/${healingConfig.maxRetries})...`);

        // Strategy depends on failure count
        if (consecutiveFailures === 1) {
          // Try 1: Quick fix with debugger (haiku)
          await Task({
            subagent_type: 'debugger',
            prompt: `Fix failing tests: ${testResult.failures.join(', ')}`,
            model: 'haiku'
          });
        } else if (consecutiveFailures === 2) {
          // Try 2: Deep analysis with sonnet
          await Task({
            subagent_type: 'debugger',
            prompt: `Deep analysis and fix for persistent test failures: ${testResult.failures.join(', ')}`,
            model: 'sonnet'
          });
        } else {
          // Try 3: Rollback and alternative approach
          if (healingConfig.rollbackOnFailure) {
            console.log(`⏪ Rolling back Task ${task.number}...`);
            await Bash({ command: 'git reset --hard HEAD~1', description: 'Rollback last commit' });

            await Task({
              subagent_type: 'plan-agent',
              prompt: `Alternative implementation for: ${task.description}`,
              model: 'sonnet'
            });
          }
        }

        // Re-verify
        const retryResult = await runTests();
        if (retryResult.passed) {
          console.log(`✅ Auto-fix successful!`);
          consecutiveFailures = 0;  // Reset counter
        }
      } else {
        // Escalate to user
        console.log(`❌ Cannot auto-fix after ${healingConfig.maxRetries} attempts.`);
        console.log(`🆘 User intervention required.`);

        return {
          success: false,
          reason: 'escalated_to_user',
          failedTask: task,
          failures: testResult.failures
        };
      }
    } else {
      // Tests passed - reset failure counter
      consecutiveFailures = 0;
    }
  }

  return { success: true, iterations: config.maxIterations };
}
```

---

### Full Enhanced OODA Loop

**Combining all enhancements**:

```typescript
async function ralphWiggumOODALoop(config: OODAConfig): Promise<OODAResult> {
  // 1. Establish baselines
  const perfBaseline = await establishPerformanceBaseline();
  const regressionBaseline = await runRegressionTests(config.changeId);

  let consecutiveFailures = 0;

  for (let iteration = 1; iteration <= config.maxIterations; iteration++) {
    console.log(`\n🔄 OODA Iteration ${iteration}/${config.maxIterations}`);

    // OBSERVE
    const tasks = parseTasksFile(`changes/active/${config.changeId}/tasks.md`);
    const completedTasks = tasks.filter(t => t.completed);

    if (tasks.every(t => t.completed)) {
      // All done!
      return { success: true, iterations: iteration };
    }

    // ORIENT & DECIDE
    const nextTask = tasks.find(t => !t.completed);

    // ACT
    console.log(`→ Implementing: ${nextTask.description}`);
    await implementTask(nextTask);
    await updateTaskCheckbox(nextTask.number, true);

    // VERIFY: Assertions
    const assertionsPassed = await verifyTaskAssertions(config.changeId, nextTask.number);
    if (!assertionsPassed) {
      console.log(`❌ Assertions failed - self-healing...`);
      await selfHealTask(nextTask);
      consecutiveFailures++;
      continue;
    }

    // VERIFY: Regression tests
    const regressionResult = await runRegressionTests(config.changeId, regressionBaseline);
    if (regressionResult.newFailures.length > 0) {
      console.log(`❌ Regression detected - self-healing...`);
      await fixRegressions(regressionResult.newFailures);
      consecutiveFailures++;
      continue;
    }

    // VERIFY: Performance
    const perfCheck = await checkPerformanceRegression(perfBaseline);
    if (!perfCheck.passed) {
      console.log(`⚠️ Performance regression: ${perfCheck.issues.join(', ')}`);
      // Log but don't block (performance can be addressed later)
    }

    // All verifications passed
    consecutiveFailures = 0;
    console.log(`✅ Task ${nextTask.number} completed and verified`);
  }

  return { success: false, reason: 'max_iterations_reached' };
}
```

---

### Usage in ai-dev

```typescript
// Phase 4 implementation with Ralph-Wiggum OODA
async function phase4_implementation(changeId: string) {
  console.log(`Starting Phase 4 with Ralph-Wiggum self-completion...`);

  const result = await ralphWiggumOODALoop({
    changeId,
    maxIterations: 10
  });

  if (result.success) {
    console.log(`✅ Phase 4 completed autonomously in ${result.iterations} iterations`);
    return { status: 'success', phase: 5 };
  } else {
    console.log(`⚠️ Phase 4 incomplete: ${result.reason}`);
    return { status: 'blocked', phase: 4, reason: result.reason };
  }
}
```

---

## Iteration Limits

### Why Limit Iterations?

**Problem**: Infinite loop if agent gets stuck
**Solution**: Max iterations (default: 10)

### Configuration

```typescript
const config = {
  changeId: '001-user-auth',
  maxIterations: 10  // Stop after 10 iterations
};
```

### What Happens at Max Iterations?

```typescript
if (iteration > config.maxIterations) {
  console.log(`❌ Max iterations reached without completion.`);

  // Save state for resumability
  await saveState({
    status: 'incomplete',
    lastIteration: iteration,
    tasksRemaining: tasks.filter(t => !t.completed).length,
    resumable: true
  });

  return { success: false, iterations: iteration };
}
```

### Typical Iteration Counts

| Complexity | Tasks | Expected Iterations | Max Iterations |
|------------|-------|---------------------|----------------|
| Simple     | 3-5   | 4-6                 | 10             |
| Medium     | 6-10  | 8-12                | 15             |
| Complex    | 11-20 | 15-25               | 30             |

---

## Error Recovery

### Common Failure Scenarios

#### Scenario 1: Test Failures

```
Iteration 5: Implement Task 4 ✅
Iteration 6: Run tests → ❌ FAIL
  Error: "Expected user, got null"

  ↓ ORIENT

  Situation: Tests failing after Task 4

  ↓ DECIDE

  Action: fix_tests

  ↓ ACT

  Analyze error → Fix code → Commit

Iteration 7: Run tests → ✅ PASS
```

#### Scenario 2: Build Failures

```
Iteration 7: Implement Task 6 ✅
Iteration 8: Run build → ❌ FAIL
  Error: "Type 'string' is not assignable to type 'number'"

  ↓ ORIENT

  Situation: TypeScript error in line 45

  ↓ DECIDE

  Action: fix_build

  ↓ ACT

  Fix type error → Commit

Iteration 9: Run build → ✅ PASS
```

#### Scenario 3: Stuck in Loop

```
Iteration 8: Fix test → ❌ Still failing
Iteration 9: Try different fix → ❌ Still failing
Iteration 10: Max iterations reached

  ↓ SAVE STATE

  State: incomplete, resumable

  ↓ ESCALATE TO USER

  Message: "Implementation incomplete after 10 iterations.
            Last issue: Test 'should return user' failing.
            Would you like to:
            1. Resume and continue (increase max iterations)
            2. Review current state and provide guidance
            3. Skip failing test and continue"
```

### Recovery Strategies

1. **Automatic Retry**
   - Try different approach
   - Simplify implementation
   - Skip optional tasks

2. **State Persistence**
   - Save progress to state.json
   - Enable resumability
   - Preserve context

3. **Escalation**
   - Ask user for help
   - Provide detailed error log
   - Offer options

---

## Integration with ai-dev

### Phase 4 Workflow

```
Phase 3: Design ✅
  ↓
Phase 4: Implementation (OODA Loop)
  ↓
[Initialize tasks.md from design.md build sequence]
  ↓
[Launch OODA loop with max_iterations=10]
  ↓
  ┌──────────────────────────────┐
  │   OODA Loop (Iterations 1-N) │
  │   - Observe                  │
  │   - Orient                   │
  │   - Decide                   │
  │   - Act                      │
  │   - Repeat                   │
  └──────────────────────────────┘
  ↓
[Detect <promise>DONE</promise>]
  ↓
Phase 5: Quality Validation
```

### ai-dev Responsibilities

1. **Initialize tasks.md**
   ```typescript
   // Extract build sequence from design.md
   const buildSequence = extractBuildSequence('design.md');

   // Create tasks.md
   createTasksFile('tasks.md', buildSequence);
   ```

2. **Launch OODA loop**
   ```typescript
   const result = await oodaLoop({
     changeId: '001-user-auth',
     maxIterations: 10
   });
   ```

3. **Monitor progress**
   ```typescript
   // Check state.json periodically
   const state = readState('state.json');
   console.log(`Phase 4: ${state.phases['phase-4-implementation'].ooda_iteration}/10 iterations`);
   ```

4. **Handle completion**
   ```typescript
   if (result.success) {
     console.log(`✅ Phase 4 complete in ${result.iterations} iterations`);
     // Move to Phase 5
   } else {
     console.log(`❌ Phase 4 incomplete after ${result.iterations} iterations`);
     // Escalate to user
   }
   ```

---

## Best Practices

### 1. Clear Task Granularity

**Good** (atomic tasks):
```markdown
- [ ] Create IUserRepository interface (15 min)
- [ ] Implement UserRepository.findByEmail (20 min)
- [ ] Add unit test for findByEmail (15 min)
```

**Bad** (too vague):
```markdown
- [ ] Implement repository layer
- [ ] Add tests
```

### 2. Explicit Completion Criteria

**Good** (measurable):
```markdown
## ✅ Completion Criteria
- [ ] All checkboxes above are checked
- [ ] All tests pass: `npm test`
- [ ] Build succeeds: `npm run build`
- [ ] ESLint: 0 errors
- [ ] TypeScript: 0 errors
```

**Bad** (subjective):
```markdown
## ✅ Completion Criteria
- [ ] Code looks good
- [ ] Everything works
```

### 3. Incremental Testing

**Good** (test after each task):
```
Task 1: Create interface ✅
  ↓ npm test → ✅ PASS
Task 2: Implement repository ✅
  ↓ npm test → ✅ PASS
Task 3: Add service ✅
  ↓ npm test → ❌ FAIL → Fix → ✅ PASS
```

**Bad** (test at end):
```
Task 1-6: Implement everything ✅
  ↓ npm test → ❌ 10 failures → Hard to debug
```

### 4. Commit Frequently

**Good** (commit per task):
```bash
git commit -m "Create IUserRepository interface"
git commit -m "Implement UserRepository.findByEmail"
git commit -m "Add unit test for findByEmail"
```

**Bad** (one big commit):
```bash
# After all tasks
git commit -m "Implement user repository"
```

### 5. Descriptive Task Names

**Good**:
```markdown
- [ ] Create IUserRepository interface with findByEmail, findById methods
- [ ] Implement UserRepository using Drizzle ORM
- [ ] Add unit test: findByEmail returns user when exists
- [ ] Add unit test: findByEmail returns null when not found
```

**Bad**:
```markdown
- [ ] Interface
- [ ] Implementation
- [ ] Tests
```

---

## Summary

### Key Takeaways

1. **OODA = Autonomous Loop**
   - Observe → Orient → Decide → Act → Repeat
   - Self-referencing: Agent reads and updates its own tasks.md

2. **Completion Promise**
   - `<promise>PENDING</promise>` → Work in progress
   - `<promise>DONE</promise>` → All criteria met

3. **Iteration Limits**
   - Default: 10 iterations
   - Prevents infinite loops
   - Enables resumability

4. **Integration**
   - Phase 4 of 7-phase workflow
   - Launched by ai-dev
   - Monitored via state.json

### Next Steps

After OODA loop completes (`<promise>DONE</promise>`):
1. ai-dev proceeds to **Phase 5: Quality Validation**
2. Parallel code reviewers check implementation
3. confidence-scorer filters issues (≥80)
4. User reviews high-confidence issues
5. If approved → **Phase 6: Finalization**

---

**End of OODA Loop Reference**
