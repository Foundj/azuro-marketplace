# State Machine Specification - Netflix Conductor Pattern

## 概述

本规范定义 `state.json` 文件的完整结构，用于实现跨会话的状态持久化和恢复（Netflix Conductor模式）。

每个变更（change）都有独立的 `state.json`，位于：
```
changes/active/[change-id]/state.json
```

## TypeScript Interface 定义

```typescript
interface ChangeState {
  // === 基本信息 ===
  changeId: string;                    // 变更ID，如 "001-user-auth"
  version: string;                     // State schema版本，当前为 "2.0"
  createdAt: Date;                     // 变更创建时间
  updatedAt: Date;                     // 最后更新时间

  // === Phase 状态 ===
  currentPhase: 0 | 1 | 2 | 3 | 4 | 5 | 6;  // 当前所处阶段
  phaseStartTime: Date;                // 当前phase开始时间
  phaseHistory: PhaseHistoryEntry[];   // Phase切换历史

  // === 用户决策记录 ===
  userDecisions: {
    // Phase 1: 需求理解审批
    phase1Approval?: {
      decision: 'yes' | 'no' | 'refine';
      timestamp: Date;
      refineFeedback?: string;         // 如果选择refine，记录反馈
    };

    // Phase 3: 设计方案选择
    phase3Selection?: {
      selectedApproach: 1 | 2 | 3;     // 选择的方案编号
      timestamp: Date;
      reasoning?: string;               // 选择理由（可选）
    };

    // Phase 5: 问题修复决策
    phase5Decision?: {
      action: 'all' | 'high-only' | 'skip';
      timestamp: Date;
      selectedIssues?: string[];        // 如果选择性修复，记录issue IDs
    };
  };

  // === OODA Loop 状态 (Phase 4专用) ===
  ooda: {
    enabled: boolean;                   // 是否启用OODA循环
    iterationCount: number;             // 当前迭代次数
    maxIterations: number;              // 最大迭代次数（默认10）
    lastCompletedTask?: string;         // 最后完成的任务
    completionPromise: 'PENDING' | 'DONE';  // 完成承诺状态
    iterationHistory: OODAIteration[];  // 迭代历史
  };

  // === Phase 输出文件路径 ===
  outputs: {
    phase0Context?: string;             // phase0-context.md 路径
    phase1Proposal?: string;            // proposal.md 路径
    phase2Evidence?: string;            // evidence.md 路径
    phase3Design?: string;              // design.md 路径
    phase4Tasks?: string;               // tasks.md 路径
    phase5Issues?: string;              // issues.json 路径
    phase6Commit?: string;              // Git commit SHA
  };

  // === 可恢复性信息 ===
  resumability: {
    canResume: boolean;                 // 是否可恢复
    resumeFrom: string;                 // 建议从哪个phase恢复
    lastSessionTime: Date;              // 上次会话时间
    sessionCount: number;               // 会话次数
    blockers?: string[];                // 阻塞问题（如果有）
    resumeInstructions?: string;        // 恢复指令
  };

  // === 质量指标 ===
  quality: {
    testsStatus?: 'passing' | 'failing' | 'not-run';
    testsPassing?: number;
    testsTotal?: number;
    buildStatus?: 'success' | 'failed' | 'not-run';
    issuesFound?: number;               // Phase 5发现的问题数
    issuesResolved?: number;            // 已解决的问题数
    confidenceScore?: number;           // 平均置信度（0-100）
  };

  // === 知识关联 ===
  knowledge: {
    relatedPatterns: string[];          // 关联的成功模式 ["PATTERN-001"]
    relatedErrors: string[];            // 关联的历史错误 ["ERROR-005"]
    preventionMeasures: string[];       // 采取的预防措施
  };

  // === 元数据 ===
  metadata: {
    complexity: 'simple' | 'medium' | 'complex';
    estimatedTime?: string;             // 估算时间
    actualTime?: string;                // 实际花费时间
    agentsUsed: string[];               // 使用的agents列表
    workflowPattern?: string;           // 工作流模式（如 "feature-development-v1"）
  };
}

// Phase历史条目
interface PhaseHistoryEntry {
  phase: 0 | 1 | 2 | 3 | 4 | 5 | 6;
  enteredAt: Date;
  exitedAt?: Date;
  duration?: number;                    // 毫秒
  status: 'in-progress' | 'completed' | 'skipped' | 'failed';
  notes?: string;
}

// OODA迭代记录
interface OODAIteration {
  iteration: number;                    // 迭代编号
  timestamp: Date;
  tasksCompleted: string[];             // 完成的任务列表
  testsStatus: {
    passing: number;
    failing: number;
    total: number;
  };
  buildStatus: 'success' | 'failed';
  decision: string;                     // 本次决策
  action: string;                       // 采取的行动
}
```

## 状态转换规则

### Phase 0 → Phase 1
```json
{
  "currentPhase": 1,
  "phaseStartTime": "2025-01-04T10:00:00Z",
  "phaseHistory": [
    {
      "phase": 0,
      "enteredAt": "2025-01-04T09:55:00Z",
      "exitedAt": "2025-01-04T10:00:00Z",
      "duration": 300000,
      "status": "completed"
    }
  ],
  "outputs": {
    "phase0Context": "changes/active/001-user-auth/phase0-context.md"
  },
  "resumability": {
    "canResume": true,
    "resumeFrom": "phase-1",
    "lastSessionTime": "2025-01-04T10:00:00Z",
    "sessionCount": 1
  }
}
```

### Phase 1 → Phase 2 (用户批准后)
```json
{
  "currentPhase": 2,
  "userDecisions": {
    "phase1Approval": {
      "decision": "yes",
      "timestamp": "2025-01-04T10:15:00Z"
    }
  },
  "outputs": {
    "phase0Context": "...",
    "phase1Proposal": "changes/active/001-user-auth/proposal.md"
  }
}
```

### Phase 1 Refine循环
如果用户选择 "refine"：
```json
{
  "currentPhase": 1,
  "userDecisions": {
    "phase1Approval": {
      "decision": "refine",
      "timestamp": "2025-01-04T10:15:00Z",
      "refineFeedback": "需要明确登录失败的重试次数限制"
    }
  },
  "phaseHistory": [
    // ... phase 0 completed
    {
      "phase": 1,
      "enteredAt": "2025-01-04T10:00:00Z",
      "exitedAt": "2025-01-04T10:15:00Z",
      "status": "completed",
      "notes": "First attempt - user requested refinement"
    },
    {
      "phase": 1,
      "enteredAt": "2025-01-04T10:16:00Z",
      "status": "in-progress",
      "notes": "Second attempt with user feedback"
    }
  ]
}
```

### Phase 4 OODA循环
```json
{
  "currentPhase": 4,
  "ooda": {
    "enabled": true,
    "iterationCount": 3,
    "maxIterations": 10,
    "lastCompletedTask": "Task 3: Create AuthService",
    "completionPromise": "PENDING",
    "iterationHistory": [
      {
        "iteration": 1,
        "timestamp": "2025-01-04T11:00:00Z",
        "tasksCompleted": ["Task 1: Create IUserRepository"],
        "testsStatus": {
          "passing": 5,
          "failing": 0,
          "total": 5
        },
        "buildStatus": "success",
        "decision": "Implement Task 2",
        "action": "Created UserRepository.ts"
      },
      {
        "iteration": 2,
        "timestamp": "2025-01-04T11:20:00Z",
        "tasksCompleted": ["Task 2: Implement UserRepository"],
        "testsStatus": {
          "passing": 10,
          "failing": 0,
          "total": 10
        },
        "buildStatus": "success",
        "decision": "Implement Task 3",
        "action": "Created AuthService.ts"
      },
      {
        "iteration": 3,
        "timestamp": "2025-01-04T11:40:00Z",
        "tasksCompleted": ["Task 3: Create AuthService"],
        "testsStatus": {
          "passing": 12,
          "failing": 3,
          "total": 15
        },
        "buildStatus": "failed",
        "decision": "Fix failing tests",
        "action": "Debugging AuthService tests"
      }
    ]
  },
  "quality": {
    "testsStatus": "failing",
    "testsPassing": 12,
    "testsTotal": 15,
    "buildStatus": "failed"
  },
  "resumability": {
    "canResume": true,
    "resumeFrom": "phase-4-iteration-3",
    "lastSessionTime": "2025-01-04T11:40:00Z",
    "sessionCount": 1,
    "blockers": ["3 failing tests in AuthService.test.ts"],
    "resumeInstructions": "继续修复failing tests，然后完成剩余4个tasks"
  }
}
```

### Phase 4 → Phase 5 (OODA完成)
```json
{
  "currentPhase": 5,
  "ooda": {
    "enabled": true,
    "iterationCount": 7,
    "maxIterations": 10,
    "lastCompletedTask": "Task 7: Add integration tests",
    "completionPromise": "DONE",
    "iterationHistory": [/* ... 7 iterations */]
  },
  "quality": {
    "testsStatus": "passing",
    "testsPassing": 25,
    "testsTotal": 25,
    "buildStatus": "success"
  },
  "outputs": {
    "phase4Tasks": "changes/active/001-user-auth/tasks.md"
  }
}
```

### Phase 5 → Phase 6 (质量验证通过)
```json
{
  "currentPhase": 6,
  "userDecisions": {
    "phase5Decision": {
      "action": "all",
      "timestamp": "2025-01-04T13:00:00Z",
      "selectedIssues": ["ISS-001", "ISS-002"]
    }
  },
  "quality": {
    "testsStatus": "passing",
    "testsPassing": 27,
    "testsTotal": 27,
    "buildStatus": "success",
    "issuesFound": 2,
    "issuesResolved": 2,
    "confidenceScore": 92
  },
  "outputs": {
    "phase5Issues": "changes/active/001-user-auth/issues.json"
  }
}
```

### Phase 6 完成
```json
{
  "currentPhase": 6,
  "phaseHistory": [/* ... all phases completed */],
  "outputs": {
    "phase0Context": "...",
    "phase1Proposal": "...",
    "phase2Evidence": "...",
    "phase3Design": "...",
    "phase4Tasks": "...",
    "phase5Issues": "...",
    "phase6Commit": "abc123def456"
  },
  "quality": {
    "testsStatus": "passing",
    "testsPassing": 27,
    "testsTotal": 27,
    "buildStatus": "success",
    "issuesFound": 2,
    "issuesResolved": 2,
    "confidenceScore": 92
  },
  "resumability": {
    "canResume": false,
    "resumeFrom": "completed",
    "lastSessionTime": "2025-01-04T14:00:00Z",
    "sessionCount": 1
  },
  "metadata": {
    "complexity": "medium",
    "estimatedTime": "4h",
    "actualTime": "4.5h",
    "agentsUsed": [
      "requirement-analyzer",
      "code-explorer",
      "code-architect",
      "code-reviewer",
      "confidence-scorer"
    ],
    "workflowPattern": "feature-development-v1"
  }
}
```

## 读写时机

### 写入时机
1. **Phase切换时** - 每次进入新phase，更新 `currentPhase` 和 `phaseHistory`
2. **用户决策时** - 记录 `userDecisions`
3. **OODA迭代时** - 每次迭代结束，更新 `ooda.iterationHistory`
4. **质量检查时** - 更新 `quality` 指标
5. **文件生成时** - 更新 `outputs` 路径

### 读取时机
1. **session-manager恢复时** - 扫描所有 `changes/active/*/state.json`
2. **Phase 4开始时** - 读取tasks.md路径和OODA状态
3. **错误恢复时** - 读取blockers和resumeInstructions

## 示例：完整的state.json

```json
{
  "changeId": "001-user-auth",
  "version": "2.0",
  "createdAt": "2025-01-04T09:55:00Z",
  "updatedAt": "2025-01-04T14:00:00Z",

  "currentPhase": 6,
  "phaseStartTime": "2025-01-04T13:30:00Z",
  "phaseHistory": [
    {
      "phase": 0,
      "enteredAt": "2025-01-04T09:55:00Z",
      "exitedAt": "2025-01-04T10:00:00Z",
      "duration": 300000,
      "status": "completed"
    },
    {
      "phase": 1,
      "enteredAt": "2025-01-04T10:00:00Z",
      "exitedAt": "2025-01-04T10:15:00Z",
      "duration": 900000,
      "status": "completed"
    },
    {
      "phase": 2,
      "enteredAt": "2025-01-04T10:16:00Z",
      "exitedAt": "2025-01-04T10:45:00Z",
      "duration": 1740000,
      "status": "completed"
    },
    {
      "phase": 3,
      "enteredAt": "2025-01-04T10:45:00Z",
      "exitedAt": "2025-01-04T11:00:00Z",
      "duration": 900000,
      "status": "completed"
    },
    {
      "phase": 4,
      "enteredAt": "2025-01-04T11:00:00Z",
      "exitedAt": "2025-01-04T13:00:00Z",
      "duration": 7200000,
      "status": "completed",
      "notes": "OODA completed in 7 iterations"
    },
    {
      "phase": 5,
      "enteredAt": "2025-01-04T13:00:00Z",
      "exitedAt": "2025-01-04T13:30:00Z",
      "duration": 1800000,
      "status": "completed",
      "notes": "2 high-confidence issues found and fixed"
    },
    {
      "phase": 6,
      "enteredAt": "2025-01-04T13:30:00Z",
      "exitedAt": "2025-01-04T14:00:00Z",
      "duration": 1800000,
      "status": "completed"
    }
  ],

  "userDecisions": {
    "phase1Approval": {
      "decision": "yes",
      "timestamp": "2025-01-04T10:15:00Z"
    },
    "phase3Selection": {
      "selectedApproach": 2,
      "timestamp": "2025-01-04T10:58:00Z",
      "reasoning": "Clean architecture with Repository pattern"
    },
    "phase5Decision": {
      "action": "all",
      "timestamp": "2025-01-04T13:05:00Z",
      "selectedIssues": ["ISS-001", "ISS-002"]
    }
  },

  "ooda": {
    "enabled": true,
    "iterationCount": 7,
    "maxIterations": 10,
    "lastCompletedTask": "Task 7: Add integration tests",
    "completionPromise": "DONE",
    "iterationHistory": [
      {
        "iteration": 1,
        "timestamp": "2025-01-04T11:00:00Z",
        "tasksCompleted": ["Task 1: Create IUserRepository"],
        "testsStatus": { "passing": 5, "failing": 0, "total": 5 },
        "buildStatus": "success",
        "decision": "Implement Task 2",
        "action": "Created UserRepository.ts"
      }
      // ... iterations 2-7
    ]
  },

  "outputs": {
    "phase0Context": "changes/active/001-user-auth/phase0-context.md",
    "phase1Proposal": "changes/active/001-user-auth/proposal.md",
    "phase2Evidence": "changes/active/001-user-auth/evidence.md",
    "phase3Design": "changes/active/001-user-auth/design.md",
    "phase4Tasks": "changes/active/001-user-auth/tasks.md",
    "phase5Issues": "changes/active/001-user-auth/issues.json",
    "phase6Commit": "abc123def456789"
  },

  "resumability": {
    "canResume": false,
    "resumeFrom": "completed",
    "lastSessionTime": "2025-01-04T14:00:00Z",
    "sessionCount": 1
  },

  "quality": {
    "testsStatus": "passing",
    "testsPassing": 27,
    "testsTotal": 27,
    "buildStatus": "success",
    "issuesFound": 2,
    "issuesResolved": 2,
    "confidenceScore": 92
  },

  "knowledge": {
    "relatedPatterns": ["PATTERN-001"],
    "relatedErrors": ["ERROR-005"],
    "preventionMeasures": [
      "使用Repository Pattern隔离数据层",
      "所有async函数添加try-catch",
      "输入验证使用Zod schema"
    ]
  },

  "metadata": {
    "complexity": "medium",
    "estimatedTime": "4h",
    "actualTime": "4.5h",
    "agentsUsed": [
      "requirement-analyzer",
      "code-explorer",
      "code-architect",
      "code-reviewer",
      "confidence-scorer"
    ],
    "workflowPattern": "feature-development-v1"
  }
}
```

## 错误恢复场景

### 场景1：Phase 4 OODA循环中断
```json
{
  "currentPhase": 4,
  "ooda": {
    "iterationCount": 5,
    "completionPromise": "PENDING"
  },
  "quality": {
    "testsStatus": "failing",
    "testsPassing": 18,
    "testsTotal": 22
  },
  "resumability": {
    "canResume": true,
    "resumeFrom": "phase-4-iteration-5",
    "blockers": ["4 failing tests"],
    "resumeInstructions": "修复failing tests后继续OODA循环"
  }
}
```

### 场景2：等待用户审批
```json
{
  "currentPhase": 1,
  "outputs": {
    "phase1Proposal": "changes/active/001-user-auth/proposal.md"
  },
  "resumability": {
    "canResume": true,
    "resumeFrom": "phase-1-awaiting-approval",
    "resumeInstructions": "等待用户审批proposal.md，然后继续Phase 2"
  }
}
```

## 归档时state.json处理

当变更完成并归档到 `changes/archived/YYYY-MM/[change-id]/` 时：
1. **state.json保持不变** - 作为历史记录保留
2. **resumability.canResume = false** - 标记为不可恢复
3. **metadata.actualTime** - 记录实际花费时间

## 版本兼容性

当前版本：`2.0`

如果未来schema变更：
- 添加 `version` 字段标识
- 保持向后兼容（旧字段保留）
- 提供迁移脚本

## State Validation (JSON Schema)

### Schema Definition

完整的JSON Schema定义在: `${CLAUDE_PLUGIN_ROOT}/skills/ai-dev/schemas/state-schema.json`

### Runtime Validation

```typescript
import Ajv from 'ajv';
import addFormats from 'ajv-formats';

// Initialize validator
const ajv = new Ajv({ allErrors: true });
addFormats(ajv); // Add date-time format support

// Load schema
const stateSchema = JSON.parse(
  await Read({ file_path: '${CLAUDE_PLUGIN_ROOT}/skills/ai-dev/schemas/state-schema.json' })
);

const validateState = ajv.compile(stateSchema);

// Validate function
function isValidState(state: any): state is ChangeState {
  const valid = validateState(state);

  if (!valid) {
    console.error('❌ State validation failed:');
    console.error(JSON.stringify(validateState.errors, null, 2));
  }

  return valid;
}
```

### Auto-Repair Strategy

```typescript
function attemptAutoRepair(state: any, errors: any[]): ChangeState | null {
  console.log(`🔧 Attempting auto-repair of ${errors.length} validation errors...`);

  const repaired = { ...state };
  let repairsMade = 0;

  for (const error of errors) {
    const { keyword, instancePath, params } = error;

    // Repair strategy 1: Missing required fields
    if (keyword === 'required') {
      const missing = params.missingProperty;

      switch (missing) {
        case 'currentPhase':
          repaired.currentPhase = 0;
          console.log(`  ✓ Added missing currentPhase = 0`);
          repairsMade++;
          break;

        case 'status':
          repaired.status = 'active';
          console.log(`  ✓ Added missing status = 'active'`);
          repairsMade++;
          break;

        case 'createdAt':
          repaired.createdAt = new Date().toISOString();
          console.log(`  ✓ Added missing createdAt`);
          repairsMade++;
          break;

        case 'updatedAt':
          repaired.updatedAt = new Date().toISOString();
          console.log(`  ✓ Added missing updatedAt`);
          repairsMade++;
          break;
      }
    }

    // Repair strategy 2: Invalid enum values
    if (keyword === 'enum') {
      if (instancePath === '/currentPhase') {
        repaired.currentPhase = Math.min(6, Math.max(0, repaired.currentPhase || 0));
        console.log(`  ✓ Fixed invalid currentPhase -> ${repaired.currentPhase}`);
        repairsMade++;
      }

      if (instancePath === '/status') {
        repaired.status = 'active';
        console.log(`  ✓ Fixed invalid status -> active`);
        repairsMade++;
      }
    }

    // Repair strategy 3: Invalid pattern (changeId)
    if (keyword === 'pattern' && instancePath === '/changeId') {
      const match = repaired.changeId?.match(/\d{3}/);
      if (match) {
        // Has number part, just format it
        const num = match[0];
        const desc = repaired.changeId.replace(/[^a-z0-9-]/g, '-');
        repaired.changeId = `${num}-${desc}`;
      } else {
        // Generate new ID
        repaired.changeId = `999-recovered-${Date.now()}`;
      }
      console.log(`  ✓ Fixed invalid changeId -> ${repaired.changeId}`);
      repairsMade++;
    }

    // Repair strategy 4: Add missing nested required fields
    if (keyword === 'required' && instancePath.includes('/ooda')) {
      if (!repaired.ooda) repaired.ooda = {};
      if (!repaired.ooda.iterationCount) repaired.ooda.iterationCount = 0;
      if (!repaired.ooda.completionPromise) repaired.ooda.completionPromise = 'PENDING';
      console.log(`  ✓ Fixed missing OODA fields`);
      repairsMade++;
    }

    if (keyword === 'required' && instancePath.includes('/knowledge')) {
      if (!repaired.knowledge) repaired.knowledge = {};
      if (!repaired.knowledge.appliedPatterns) repaired.knowledge.appliedPatterns = [];
      if (!repaired.knowledge.preventedErrors) repaired.knowledge.preventedErrors = [];
      console.log(`  ✓ Fixed missing knowledge fields`);
      repairsMade++;
    }

    if (keyword === 'required' && instancePath.includes('/resumability')) {
      if (!repaired.resumability) {
        repaired.resumability = {
          canResume: true,
          resumeFrom: `Phase ${repaired.currentPhase}`,
          lastSessionTime: new Date().toISOString(),
          nextAction: 'Resume from last position'
        };
      }
      console.log(`  ✓ Fixed missing resumability fields`);
      repairsMade++;
    }
  }

  if (repairsMade === 0) {
    console.log(`  ❌ No repairs could be made`);
    return null;
  }

  // Re-validate after repairs
  if (isValidState(repaired)) {
    console.log(`✅ Successfully repaired ${repairsMade} issues`);
    return repaired;
  } else {
    console.log(`❌ Repairs didn't fix all validation errors`);
    return null;
  }
}
```

---

## 工具函数建议

```typescript
// 读取state (with validation)
async function readState(changeId: string): Promise<ChangeState | null> {
  const path = `changes/active/${changeId}/state.json`;

  try {
    const content = await Read({ file_path: path });
    const state = JSON.parse(content);

    // Validate against schema
    if (!isValidState(state)) {
      console.warn(`⚠️ State validation failed for ${changeId}`);

      // Attempt auto-repair
      const repaired = attemptAutoRepair(state, validateState.errors || []);

      if (repaired) {
        console.log(`✅ State auto-repaired, saving...`);
        await writeState(changeId, repaired);
        return repaired;
      }

      // Cannot repair
      console.error(`❌ Cannot repair state.json for ${changeId}`);
      console.error(`Backup the file and restore manually, or delete to start fresh.`);
      return null;
    }

    return state;

  } catch (error) {
    if (error.message.includes('ENOENT')) {
      console.log(`ℹ️ State file not found for ${changeId} (new change)`);
      return null;
    }

    console.error(`Error reading state for ${changeId}:`, error.message);
    return null;
  }
}

// 写入state (with validation)
async function writeState(changeId: string, updates: Partial<ChangeState>): Promise<void> {
  const path = `changes/active/${changeId}/state.json`;

  // Read existing or create new
  let state = await readState(changeId);

  if (!state) {
    // Initialize new state
    state = {
      changeId,
      currentPhase: 0,
      status: 'active',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
      userDecisions: {},
      ooda: {
        iterationCount: 0,
        completionPromise: 'PENDING'
      },
      outputs: {},
      quality: {},
      knowledge: {
        appliedPatterns: [],
        preventedErrors: []
      },
      phaseHistory: [],
      resumability: {
        canResume: false,
        resumeFrom: 'Phase 0',
        lastSessionTime: new Date().toISOString(),
        nextAction: 'Start knowledge check'
      }
    };
  }

  // Merge updates
  const newState = {
    ...state,
    ...updates,
    updatedAt: new Date().toISOString()
  };

  // Validate before writing
  if (!isValidState(newState)) {
    throw new Error('Cannot write invalid state. Validation failed.');
  }

  // Write to file
  await Write({
    file_path: path,
    content: JSON.stringify(newState, null, 2)
  });

  console.log(`✅ State updated for ${changeId}`);
}

// 更新state
function updateState(changeId: string, updates: Partial<ChangeState>): void {
  const state = readState(changeId);
  const newState = { ...state, ...updates, updatedAt: new Date() };
  // ... 写入JSON
}

// 切换Phase
function transitionPhase(changeId: string, newPhase: number): void {
  updateState(changeId, {
    currentPhase: newPhase,
    phaseStartTime: new Date(),
    phaseHistory: [
      ...state.phaseHistory,
      {
        phase: state.currentPhase,
        exitedAt: new Date(),
        status: 'completed'
      },
      {
        phase: newPhase,
        enteredAt: new Date(),
        status: 'in-progress'
      }
    ]
  });
}

// 查找可恢复的变更
function findResumableChanges(): ChangeState[] {
  // 扫描 changes/active/*/state.json
  // 过滤 resumability.canResume === true
  // 按 lastSessionTime 排序
}
```

---

**核心价值**：完整的状态持久化 = 完美的跨会话恢复 = Netflix Conductor级别的可靠性
