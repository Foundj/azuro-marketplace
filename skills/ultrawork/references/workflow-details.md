# Ultrawork Autonomous Workflow Reference

## Phase 0: ANALYZE
The system detects task complexity based on file impact and logic depth.

## Phase 1: CLARIFY
If requirements are ambiguous, the system asks maximum 3 focused questions.

## Phase 2: ISOLATE
For complex tasks, a git worktree is automatically created to isolate the development environment.

## Phase 3: PLAN
Fine-grained implementation tasks are generated (2-5 minutes each) following TDD principles.

## Phase 4: EXECUTE
A fresh subagent is dispatched for each task.

## Phase 5: REVIEW
Two-stage review: Spec Compliance first, then Code Quality.

## Phase 6: FINISH
Final verification and branch management.
