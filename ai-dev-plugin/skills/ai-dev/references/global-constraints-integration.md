# Global Constraints Integration Reference

> **Kiro Spec Integration**: Dual-layer constraint architecture (Global + Local)
> **Purpose**: Ensure all changes comply with project-wide requirements and design patterns
> **Key Innovation**: Phase 0 automatic pre-check before any change begins

---

## 📖 Table of Contents

1. [Overview](#overview)
2. [Dual-Layer Architecture](#dual-layer-architecture)
3. [The 4 Global Constraint Files](#the-4-global-constraint-files)
4. [Priority System](#priority-system)
5. [Phase 0: Automatic Pre-Check](#phase-0-automatic-pre-check)
6. [Integration Points](#integration-points)
7. [Compliance Checking](#compliance-checking)
8. [Examples](#examples)
9. [Best Practices](#best-practices)

---

## Overview

### What are Global Constraints?

**Global constraints** are project-wide rules that apply to **all changes**, documented in 4 files at the project root:

1. **requirements.md** - Functional and non-functional requirements
2. **design.md** - Architecture patterns and technical decisions
3. **CLAUDE.md** - Code style, conventions, and AI behavior rules
4. **constraints.md** - Quality rules and validation criteria

### Why Global Constraints?

**Problem without constraints**:
```
Change 1: Uses REST API
Change 2: Uses GraphQL
Change 3: Uses gRPC
  ↓
Result: ❌ Inconsistent architecture
```

**With global constraints**:
```
design.md: "All APIs SHALL use REST"
  ↓
Change 1: REST ✅
Change 2: GraphQL ❌ (rejected by Phase 0 check)
Change 3: REST ✅
  ↓
Result: ✅ Consistent architecture
```

---

## Dual-Layer Architecture

### Constraint Hierarchy

```
┌─────────────────────────────────────────────┐
│         Global Constraints (Root)          │
│  ✅ requirements.md                         │
│  ✅ design.md                               │
│  ✅ CLAUDE.md                               │
│  ✅ constraints.md                          │
│                                             │
│  Applies to: ALL CHANGES                   │
│  Priority: HIGHEST                          │
└─────────────────────────────────────────────┘
                    ↓
        (Cannot be overridden)
                    ↓
┌─────────────────────────────────────────────┐
│      Local Change Design (Per-Change)      │
│  📁 changes/active/001-user-auth/          │
│     ├── proposal.md                        │
│     ├── design.md                          │
│     └── tasks.md                           │
│                                             │
│  Applies to: THIS CHANGE ONLY              │
│  Priority: LOWER (must comply with global) │
└─────────────────────────────────────────────┘
```

### Priority Rules

**Rule 1**: Global constraints **always override** local decisions

```
Global design.md: "Use Repository pattern"
Local design.md: "Use direct DB calls for speed"
  ↓
Result: ❌ Rejected - violates global pattern
```

**Rule 2**: Local design **extends** global constraints (doesn't replace)

```
Global CLAUDE.md: "Functions ≤30 lines"
Local design.md: "For parsers, ≤20 lines"
  ↓
Result: ✅ Allowed - more strict is fine
```

**Rule 3**: Conflicts are resolved in favor of global constraints

```
Global requirements.md: "All APIs return JSON"
Local proposal.md: "Return XML for legacy clients"
  ↓
Result: ⚠️ Phase 0 flags conflict → User must update global requirement OR change proposal
```

---

## The 4 Global Constraint Files

### 1. requirements.md - What to Build

**Purpose**: Document functional and non-functional requirements

**Format**: EARS (Easy Approach to Requirements Syntax)
```
WHEN [trigger condition]
THE SYSTEM SHALL [required behavior]
SO THAT [business value]
```

**Example**:
```markdown
# Global Requirements

## REQ-GLOBAL-001: API Response Format
WHEN the system processes an API request
THE SYSTEM SHALL return responses in JSON format with structure:
```json
{
  "success": boolean,
  "data": any,
  "error": { code: string, message: string }
}
```
SO THAT clients have a consistent interface

## REQ-GLOBAL-002: Error Handling
WHEN an error occurs in any layer
THE SYSTEM SHALL throw an AppError instance with code, message, and statusCode
SO THAT errors are handled consistently

## REQ-GLOBAL-003: Authentication
WHEN a protected endpoint is accessed
THE SYSTEM SHALL verify JWT token in Authorization header
SO THAT only authenticated users can access protected resources
```

**Usage**:
- ✅ Phase 0 checks if proposal violates requirements
- ✅ Phase 5 checks if implementation meets requirements
- ✅ confidence-scorer adds +10 for requirement violations

---

### 2. design.md - How to Build

**Purpose**: Document architecture patterns and technical decisions

**Example**:
```markdown
# Global Design Patterns

## Architecture: Layered Architecture

```
Presentation Layer (app/, components/)
  ↓
Application Layer (lib/services/)
  ↓
Domain Layer (lib/models/)
  ↓
Infrastructure Layer (db/, lib/repositories/)
```

### Pattern 1: Repository Pattern
ALL data access MUST go through repository interfaces:
- Define IRepository interface
- Implement concrete repository
- Inject repository into services (DI)

### Pattern 2: Service Layer
ALL business logic MUST reside in service classes:
- Service classes in lib/services/
- Pure functions or classes with DI
- No direct DB calls in services

### Pattern 3: Error Handling
ALL errors MUST use AppError:
```typescript
throw new AppError('AUTH_FAILED', 'Invalid credentials', 401);
```

### Pattern 4: API Endpoints
ALL API routes MUST:
- Use Hono framework
- Validate inputs with Zod
- Return standard JSON response
- Handle errors with try-catch
```

**Usage**:
- ✅ Phase 0 checks if proposed design aligns
- ✅ Phase 3 architects reference patterns
- ✅ Phase 5 reviewers check pattern compliance

---

### 3. CLAUDE.md - Code Style & Conventions

**Purpose**: Code style, naming conventions, and AI behavior rules

**Example**:
```markdown
# AI Behavior and Code Standards

## 🎯 Core Principles

### 1. Quality Over Speed
- Never ship code with known bugs
- Tests must pass before completion
- Code review findings must be addressed

### 2. Constraint Priority
```
Global constraints (requirements/design/CLAUDE/constraints.md)
  ↓ HIGHEST PRIORITY
Local change design (changes/active/[id]/design.md)
  ↓ LOWER PRIORITY
```

## 📐 Code Style

### Naming Conventions
- **Files**: Components → PascalCase.tsx, others → camelCase.ts
- **Functions**: camelCase
- **Classes**: PascalCase
- **Constants**: UPPER_SNAKE_CASE
- **Interfaces**: PascalCase with I prefix (e.g., IUserRepository)

### Code Quality Rules
- ✅ Functions ≤30 lines (split if longer)
- ✅ No `any` types (use proper types or `unknown`)
- ✅ Async functions MUST have try-catch
- ✅ All public functions MUST have tests
- ✅ Cyclomatic complexity ≤10

### Import Rules
- Use absolute imports via `@/` alias
- Group imports: external → internal → relative
- No circular dependencies

### Error Handling
- NEVER use generic try-catch with silent errors
- ALWAYS use AppError for application errors
- ALWAYS propagate errors up (don't swallow)

## 🤖 AI Behavior Rules

### When Implementing Changes
- ALWAYS read global constraints first (Phase 0)
- NEVER violate global design patterns
- ALWAYS run tests after each task
- ALWAYS commit frequently (per task)
- NEVER output `<promise>DONE</promise>` until genuinely complete
```

**Usage**:
- ✅ Phase 0 reminds AI of behavior rules
- ✅ Phase 4 agent follows code style
- ✅ Phase 5 reviewers check style violations

---

### 4. constraints.md - Quality Gates

**Purpose**: Quality validation criteria and gates

**Example**:
```markdown
# Quality Constraints and Gates

## Build Quality

### Before Commit
- [ ] ESLint: 0 errors
- [ ] TypeScript: 0 errors (`tsc --noEmit`)
- [ ] Prettier: formatted (`npm run format`)

### Before Phase 5 (Quality Validation)
- [ ] All tasks completed
- [ ] All tests passing (`npm test`)
- [ ] Build succeeds (`npm run build`)
- [ ] No console.log in production code

## Test Coverage

### Minimum Coverage
- Overall: ≥80%
- Critical paths (auth, payment): ≥95%
- New code: ≥90%

### Test Types Required
- Unit tests: All services, repositories
- Integration tests: All API endpoints
- E2E tests: Critical user flows

## Code Quality Metrics

### Complexity
- Cyclomatic complexity ≤10 per function
- Cognitive complexity ≤15 per function
- Nesting depth ≤4

### Size
- Functions ≤30 lines
- Files ≤300 lines
- Classes ≤200 lines

## Security

### OWASP Top 10
- [ ] No SQL injection
- [ ] No XSS vulnerabilities
- [ ] No hardcoded secrets
- [ ] No insecure authentication

### Input Validation
- ALL user inputs MUST be validated with Zod
- ALL API endpoints MUST validate request bodies
- NO trusting client-side data
```

**Usage**:
- ✅ Phase 4 OODA loop checks completion criteria
- ✅ Phase 5 reviewers verify quality metrics
- ✅ confidence-scorer flags violations

---

## Priority System

### Conflict Resolution

**Scenario**: Global says REST, local says GraphQL

```
Global design.md:
  "All APIs SHALL use REST"

Local proposal.md (changes/active/002-analytics/):
  "Implement GraphQL API for analytics dashboard"
```

**Phase 0 Pre-Check**:
```
⚠️ CONSTRAINT CONFLICT DETECTED

Global constraint: "All APIs SHALL use REST" (design.md)
Proposed change: "GraphQL API"

Actions:
1. Update global design.md to allow GraphQL (requires approval)
2. Change proposal to use REST
3. Explain why GraphQL is necessary for this specific case

Please resolve before proceeding.
```

**Resolution Options**:

**Option 1**: Update global constraint (if valid justification)
```markdown
# design.md (updated)

## API Design
- Default: REST for CRUD operations
- Exception: GraphQL allowed for analytics/reporting (flexible queries)
```

**Option 2**: Change proposal to comply
```markdown
# proposal.md (updated)

## Implementation
- Use REST API with flexible query parameters
- Endpoint: GET /api/analytics?metrics=X,Y&filters=Z
```

**Option 3**: Document exception in local design
```markdown
# changes/active/002-analytics/design.md

## Exception Request
**Global constraint**: REST APIs
**Requested exception**: GraphQL for analytics
**Justification**:
  - Analytics requires complex, nested queries
  - REST would require 20+ endpoints
  - GraphQL reduces payload size by 70%
**Approval**: [Pending user approval]
```

---

## Phase 0: Automatic Pre-Check

### What is Phase 0?

**Phase 0** runs **automatically before every change** via a pre-change hook.

### Phase 0 Workflow

```
User: "ai 实现用户登录"
  ↓
ai-dev: Trigger Phase 0
  ↓
Phase 0: Knowledge Check
  ├─ 1. Read global constraints
  │    ├─ requirements.md
  │    ├─ design.md
  │    ├─ CLAUDE.md
  │    └─ constraints.md
  │
  ├─ 2. Query knowledge base
  │    ├─ patterns.json (related patterns)
  │    ├─ errors.json (historical errors)
  │    └─ learnings.md (lessons learned)
  │
  ├─ 3. Compliance check
  │    ├─ Does proposal align with requirements?
  │    ├─ Does design follow global patterns?
  │    └─ Any known risks from errors.json?
  │
  └─ 4. Generate phase0-context.md
       (summary for next phases)
  ↓
If compliance issues found:
  ❌ Stop, notify user

If all clear:
  ✅ Proceed to Phase 1
```

### phase0-context.md Example

```markdown
# Phase 0: Knowledge Check - User Login Feature

Generated: 2024-01-15 10:30:00

## Global Constraints Summary

### From requirements.md
- ✅ REQ-GLOBAL-001: API responses must use standard JSON format
- ✅ REQ-GLOBAL-002: Errors must use AppError class
- ✅ REQ-GLOBAL-003: Protected endpoints require JWT authentication

### From design.md
- ✅ Must follow layered architecture (Presentation → Service → Repository)
- ✅ Must use Repository pattern for data access
- ✅ Must use Dependency Injection in services

### From CLAUDE.md
- ✅ Functions ≤30 lines
- ✅ No `any` types
- ✅ Async functions require try-catch
- ✅ All public functions need tests

### From constraints.md
- ✅ Test coverage ≥90% for new code
- ✅ ESLint 0 errors
- ✅ TypeScript 0 errors

## Knowledge Base Findings

### Related Patterns (patterns.json)
- **PATTERN-001**: Repository Pattern
  - Used 15 times, 100% success rate
  - Recommendation: Follow UserRepository implementation

### Historical Errors (errors.json)
- **ERROR-012**: Unhandled async promise rejection in auth flow
  - Occurred 3 times
  - Prevention: All async functions must use try-catch

### Risk Level
- **Medium** - Authentication is security-critical
- **Mitigation**: Follow existing AuthService pattern

## Compliance Check

### ✅ No conflicts detected
- Proposed change aligns with global requirements
- Can proceed with standard workflow

## Recommendations for Implementation

1. Reference existing AuthService.ts for patterns
2. Use try-catch for all async operations
3. Write tests before marking tasks complete
4. Use AppError for all error handling

---

**Phase 0 Status**: ✅ PASSED
**Proceed to**: Phase 1 (Clarification)
```

---

## Integration Points

### Phase 0: Pre-Check

**When**: Before every change (automatic)

**Actions**:
1. Read all 4 global constraint files
2. Parse and summarize constraints
3. Check for conflicts with proposal
4. Generate phase0-context.md

**Output**: phase0-context.md or STOP (if conflicts)

---

### Phase 1: Clarification

**When**: requirement-analyzer generates proposal

**Actions**:
1. Read phase0-context.md
2. Ensure proposal complies with global requirements
3. Reference global design patterns
4. Include compliance notes in proposal.md

**Example**:
```markdown
# proposal.md

## Compliance with Global Constraints

### Requirements Compliance
- ✅ REQ-GLOBAL-001: Will use standard JSON response format
- ✅ REQ-GLOBAL-002: Will use AppError for errors
- ✅ REQ-GLOBAL-003: Will implement JWT authentication

### Design Pattern Compliance
- ✅ Will follow layered architecture
- ✅ Will use Repository pattern (IUserRepository)
- ✅ Will use DI in AuthService
```

---

### Phase 3: Design

**When**: code-architect generates approaches

**Actions**:
1. Read global design.md patterns
2. Ensure all approaches comply
3. Reference patterns in design.md
4. Cite constraints in trade-off analysis

**Example**:
```markdown
# design.md

## Approach 2: Clean (Recommended)

### Pattern Compliance
- ✅ Follows global Repository pattern (design.md)
- ✅ Uses DI (design.md)
- ✅ Layered architecture (Presentation → Service → Repository)

### CLAUDE.md Compliance
- ✅ All functions ≤30 lines
- ✅ No `any` types
- ✅ Try-catch for async
```

---

### Phase 5: Quality Validation

**When**: code-reviewer and confidence-scorer check code

**Actions**:
1. Check CLAUDE.md code style compliance
2. Check constraints.md quality gates
3. Verify requirements.md functional requirements
4. Score violations with confidence-scorer

**Example**:
```json
{
  "issue_id": "ISS-004",
  "confidence": 85,
  "category": "constraint",
  "title": "Function exceeds length limit",
  "description": "Function is 45 lines, violates CLAUDE.md limit of ≤30 lines",
  "evidence": {
    "constraint_violation": "CLAUDE.md: Functions ≤30 lines"
  }
}
```

---

## Compliance Checking

### Automated Checks

#### Check 1: Requirements Compliance

```typescript
async function checkRequirementsCompliance(
  proposal: string,
  requirements: string
): Promise<ComplianceResult> {
  const reqList = parseRequirements(requirements); // Extract EARS format

  const violations = [];
  for (const req of reqList) {
    if (!proposalMeetsRequirement(proposal, req)) {
      violations.push({
        id: req.id,
        title: req.title,
        issue: `Proposal doesn't address ${req.id}`
      });
    }
  }

  return {
    compliant: violations.length === 0,
    violations
  };
}
```

#### Check 2: Design Pattern Compliance

```typescript
async function checkDesignCompliance(
  code: string,
  designPatterns: string
): Promise<ComplianceResult> {
  const patterns = parsePatterns(designPatterns);

  const violations = [];

  // Example: Check Repository pattern
  if (patterns.includes('Repository Pattern')) {
    if (!usesRepositoryPattern(code)) {
      violations.push({
        pattern: 'Repository Pattern',
        issue: 'Direct DB calls found, should use repository'
      });
    }
  }

  return {
    compliant: violations.length === 0,
    violations
  };
}
```

#### Check 3: Code Style Compliance

```typescript
async function checkCodeStyleCompliance(
  code: string,
  claudeMd: string
): Promise<ComplianceResult> {
  const rules = parseCodeRules(claudeMd);

  const violations = [];

  // Example: Check function length
  const functions = extractFunctions(code);
  for (const fn of functions) {
    if (fn.lineCount > rules.maxFunctionLength) {
      violations.push({
        rule: 'Function length ≤30 lines',
        function: fn.name,
        actual: fn.lineCount,
        expected: rules.maxFunctionLength
      });
    }
  }

  // Check for `any` types
  if (code.includes(': any')) {
    violations.push({
      rule: 'No any types',
      issue: 'Found any type usage'
    });
  }

  return {
    compliant: violations.length === 0,
    violations
  };
}
```

---

## Examples

### Example 1: Compliant Change

**Global design.md**:
```markdown
## Pattern: Repository Pattern
ALL data access MUST use repository interfaces
```

**Proposed code**:
```typescript
// ✅ Compliant
export class AuthService {
  constructor(private userRepo: IUserRepository) {}

  async login(email: string, password: string) {
    const user = await this.userRepo.findByEmail(email);
    // ... business logic ...
  }
}
```

**Phase 0 Check**: ✅ PASS
**Phase 5 Check**: ✅ PASS

---

### Example 2: Non-Compliant Change (Caught in Phase 0)

**Global design.md**:
```markdown
## Pattern: Repository Pattern
ALL data access MUST use repository interfaces
```

**Proposed code**:
```typescript
// ❌ Non-compliant
export class AuthService {
  async login(email: string, password: string) {
    // Direct DB call, bypasses repository
    const user = await db.query.users.findFirst({
      where: eq(users.email, email)
    });
    // ...
  }
}
```

**Phase 0 Check**:
```
❌ DESIGN PATTERN VIOLATION

Global constraint: "All data access must use repository interfaces"
Proposed code: Direct DB call in AuthService

Please update design to use IUserRepository.
```

**Action**: ❌ STOP, require redesign

---

### Example 3: Constraint Violation (Caught in Phase 5)

**Global CLAUDE.md**:
```markdown
## Code Quality
- Functions ≤30 lines
```

**Implemented code**:
```typescript
// ❌ Violation
function validateUserInput(data: any): User {  // 65 lines
  // ... 65 lines of validation logic ...
}
```

**Phase 5 confidence-scorer**:
```json
{
  "issue_id": "ISS-005",
  "confidence": 80,
  "category": "constraint",
  "title": "Function exceeds length limit",
  "evidence": {
    "constraint_violation": "CLAUDE.md: Functions ≤30 lines",
    "actual": 65,
    "expected": 30
  },
  "recommendation": "SHOULD FIX - Split into smaller functions"
}
```

**Action**: ⚠️ Report to user, request fix

---

## Best Practices

### 1. Initialize Global Constraints Early

**When starting a new project**:
```bash
# Use project-initializer to create all 4 files
ai "Initialize project with global constraints"
```

### 2. Keep Constraints Updated

**When patterns change**:
```bash
# Update design.md immediately
# Don't let constraints diverge from reality
```

### 3. Document Exceptions

**If a change needs to violate a constraint**:
```markdown
# changes/active/XXX/design.md

## Exception Request
**Global constraint**: [which one]
**Requested exception**: [what you want to do]
**Justification**: [why it's necessary]
**Approval**: [user must approve]
```

### 4. Review Constraints Periodically

**Monthly review**:
- Are constraints still relevant?
- Any new patterns to document?
- Any outdated rules to remove?

### 5. Use EARS Format for Requirements

**Good** (EARS):
```
WHEN user submits login form
THE SYSTEM SHALL validate credentials against database
SO THAT only authorized users can access
```

**Bad** (vague):
```
System should have login
```

---

## Summary

### Key Takeaways

1. **4 Global Constraint Files**
   - requirements.md: What to build
   - design.md: How to build
   - CLAUDE.md: Code style & AI behavior
   - constraints.md: Quality gates

2. **Dual-Layer Architecture**
   - Global constraints (highest priority)
   - Local change design (must comply)
   - Conflicts resolved in favor of global

3. **Phase 0 Automatic Check**
   - Runs before every change
   - Catches violations early
   - Generates phase0-context.md

4. **Integration Throughout Workflow**
   - Phase 0: Pre-check
   - Phase 1: Proposal compliance
   - Phase 3: Design pattern compliance
   - Phase 5: Code review compliance

---

**End of Global Constraints Integration Reference**
