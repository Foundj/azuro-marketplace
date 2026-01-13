# OODA State Machine Reference

> State transitions and lifecycle for ai-dev-ooda

## States

| State | Description | Transitions |
|-------|-------------|-------------|
| IDLE | No active loop | → RUNNING |
| RUNNING | Executing OODA cycle | → PAUSED, VERIFYING, ERROR, COMPLETED |
| PAUSED | User requested pause | → RUNNING, IDLE |
| VERIFYING | Running verify_with command | → RUNNING, ERROR |
| ERROR | Verification failed | → RUNNING (after fix), IDLE |
| COMPLETED | All tasks done | → IDLE |

## Transition Diagram

```
┌─────────┐    start     ┌──────────┐
│  IDLE   │ ──────────→  │ RUNNING  │
└─────────┘              └────┬─────┘
     ↑                        │
     │    ┌───────────────────┼───────────────────┐
     │    │                   │                   │
     │    ↓                   ↓                   ↓
     │ ┌──────┐         ┌─────────┐         ┌─────────┐
     │ │PAUSED│         │VERIFYING│         │ ERROR   │
     │ └──────┘         └─────────┘         └─────────┘
     │    │                   │                   │
     │    └───────────────────┼───────────────────┘
     │                        │
     │                        ↓
     │                 ┌──────────┐
     └──────────────── │ COMPLETED│
                       └──────────┘
```

## Completion Promise

Exit only with: `<promise>DONE</promise>`

**Requirements**:
- All tasks checked ✅
- All verify_with commands passed
- Stop Hook validates promise

## Iteration Limits

| Config | Default | Description |
|--------|---------|-------------|
| maxIterations | 50 | Maximum OODA cycles |
| attentionRefresh | 5 | Iterations between /focus |
| workerSpawnThreshold | 80% | Context usage to spawn worker |
