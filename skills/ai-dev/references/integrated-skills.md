# Integrated Skills

ai-dev 工作流集成以下辅助 Skills：

| Skill | Phase | 作用 |
|-------|-------|------|
| `brainstorm-mode` | -1 (Optional) | 苏格拉底式需求探索，从模糊想法发现清晰需求 |
| `ai-dev-interview` | 1 (Interview) | 多轮需求访谈，并行上下文收集，风险检测，生成 proposal.md |
| `ai-dev-ooda` | 4 (Implementation) | OODA 自主执行引擎，验证门禁，Reflexion 学习，注意力管理 |
| `ai-dev-quality` | 5 (Review) | 多视角代码审查，confidence-scorer ≥80 过滤，4 维度质量评分 |
| `code-simplifier` | 5.5 (Polish) | 代码简化和优化，SOLID 原则检查，复杂度度量 |
| `thinking-engine` | 0 (Pre-check) | think/ultrathink 模式的结构化思考支持，5-6 步分析流程 |
| `knowledge-graph` | 0, 4, 6 | 跨项目知识图谱，查询历史方案，记录新知识 |
| `competitor-research` | 0.5 (Research) | 多源竞品研究，最佳实践分析 |
| `context-bridge` | Cross-session | 轻量级上下文恢复，Auto Checkpoint，Manus 3-file 模式 |
| `session-manager` | Cross-session | 完整项目恢复，10 步验证流程，环境启动 |

## Quality Validation (ai-dev-quality)

Phase 5 自动执行：

```
[ai-dev] Phase 5: Quality Validation
├── 3x code-reviewer (security, bugs, maintainability)
├── confidence-scorer (filter ≥80)
├── verification-agent (tests, build, lint)
└── 4-dimension scoring (Security 40%, Code 30%, Docs 20%, Arch 10%)
```

## Code Simplification (code-simplifier)

Phase 5 通过后，如果 `autoSimplify: true`：

```
[ai-dev] Phase 5.5: Code Simplification
├── Identify recently modified code
├── Apply CLAUDE.md standards
├── Reduce complexity
└── Verify behavior unchanged
```

手动执行：`/ai:simplify` 或提示 "简化代码"

## Thinking Engine

think 模式触发时自动激活：

```
[Thinking Engine] Task Analysis Mode
├── Step 1: 理解任务
├── Step 2: 分析上下文
├── Step 3: 评估复杂度
├── Step 4: 选择策略
└── Step 5: 验证方案
```

## Knowledge Graph

- **Phase 0**: 查询相关知识和历史方案
- **Phase 4**: 参考类似项目的实现
- **Phase 6**: 记录新知识到图谱

手动查询：`/ai:knowledge [关键词]`

## Dependencies

### Core Skills (Modular Architecture v4.1+)
- `ai-dev-interview` - Phase 1 requirement interview system
- `ai-dev-ooda` - Phase 4 OODA autonomous execution engine
- `ai-dev-quality` - Phase 5 quality validation (replaces legacy `quality-gate`)
- `code-simplifier` - Phase 5.5 code refinement

### Supporting Skills
- `competitor-research` - Phase 0.5 multi-source research
- `thinking-engine` - Structured thinking for complex decisions
- `knowledge-graph` - Cross-project knowledge management
- `context-bridge` - Cross-session context persistence
- `claude-reflect` - Learning capture and /reflect command
