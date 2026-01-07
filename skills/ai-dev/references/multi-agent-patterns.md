# Multi-Agent Patterns Reference

> Extracted from Agent-Skills-for-Context-Engineering

## Core Insight

Sub-agents exist primarily to **isolate context**, not to anthropomorphize role division. Multi-agent architectures address single-agent context limitations through distribution.

## Architecture Patterns

### Pattern 1: Supervisor/Orchestrator

```
User Query → Supervisor → [Specialist, Specialist, Specialist] → Aggregation → Final Output
```

**When to use**: Complex tasks with clear decomposition, tasks requiring coordination across domains.

**The Telephone Game Problem**: Supervisors paraphrase sub-agent responses incorrectly, losing fidelity.

**Solution**: Implement `forward_message` tool allowing sub-agents to pass responses directly to users:

```python
def forward_message(message: str, to_user: bool = True):
    """Forward sub-agent response directly without supervisor synthesis."""
    if to_user:
        return {"type": "direct_response", "content": message}
    return {"type": "supervisor_input", "content": message}
```

### Pattern 2: Peer-to-Peer/Swarm

```python
def transfer_to_agent_b():
    return agent_b  # Handoff via function return

agent_a = Agent(
    name="Agent A",
    functions=[transfer_to_agent_b]
)
```

**When to use**: Tasks requiring flexible exploration, emergent requirements.

### Pattern 3: Hierarchical

```
Strategy Layer (Goal Definition)
    ↓
Planning Layer (Task Decomposition)
    ↓
Execution Layer (Atomic Tasks)
```

**When to use**: Large-scale projects, enterprise workflows.

## Token Economics

| Architecture | Token Multiplier | Use Case |
|--------------|------------------|----------|
| Single agent chat | 1× baseline | Simple queries |
| Single agent with tools | ~4× baseline | Tool-using tasks |
| Multi-agent system | ~15× baseline | Complex research/coordination |

**Key insight**: Upgrading to better models often provides larger performance gains than doubling token budgets.

## Context Isolation Mechanisms

| Mechanism | When to Use | Trade-off |
|-----------|-------------|-----------|
| Full context delegation | Complex tasks needing complete understanding | Defeats purpose of isolation |
| Instruction passing | Simple, well-defined subtasks | Limits sub-agent flexibility |
| File system memory | Complex tasks with shared state | Latency and consistency challenges |

## Consensus Patterns

- **Weighted Voting**: Weight votes by confidence or expertise
- **Debate Protocols**: Require agents to critique each other (often yields higher accuracy)
- **Trigger-Based Intervention**: Detect stalls or sycophancy

## Failure Modes & Mitigations

| Failure | Mitigation |
|---------|------------|
| Supervisor Bottleneck | Output schema constraints, checkpointing |
| Coordination Overhead | Clear handoff protocols, batch results |
| Divergence | Objective boundaries, convergence checks, TTL limits |
| Error Propagation | Validate outputs, retry with circuit breakers |

## Application to ai-dev

| ai-dev Component | Pattern Used |
|---------------------------|--------------|
| 7-Phase Workflow | Hierarchical (phases as layers) |
| Code Explorer + Architect | Supervisor (orchestrator delegates) |
| OODA Loop | Peer-to-peer (self-feeding) |
| Quality Review | Debate (reviewer + scorer) |

## Guidelines

1. Design for context isolation as primary benefit
2. Choose pattern based on coordination needs, not organizational metaphor
3. Implement explicit handoff protocols with state passing
4. Use weighted voting or debate for consensus
5. Monitor for supervisor bottlenecks
6. Validate outputs before passing between agents
7. Set TTL limits to prevent infinite loops
