# Interaction Protocol Usage Example

> Demonstrates how a referencing skill applies the protocol in practice.

## Scenario: ai-dev-interview conducting a requirement interview

### Session Start (Entry Modes)

```
I'll help you clarify the requirements for this feature.

How would you like to proceed?
1. Guided — I'll walk you through step by step
2. Context dump — Paste what you already have, I'll fill gaps
3. Quick mode — I'll infer details and flag assumptions
```

User selects: `1`

### Guided Mode with Progress Labels

```
[Context Q1/4]
What problem does this feature solve for the end user?
```

User: "Users can't find relevant items in search results."

```
[Context Q2/4]
What's the current search implementation? (e.g., full-text, fuzzy, external service)

1. Database LIKE/ILIKE queries
2. Elasticsearch / OpenSearch
3. Algolia or similar SaaS
4. None yet
```

User: `2`

### Decision Point (numbered options with trade-offs)

```
[Design Q1/3]
How should we improve relevance ranking?

1. Field boosting — weight title > description > tags. Simple, fast.
2. ML re-ranking — train a model on click data. Better results, needs data.
3. Hybrid — boosting now, ML later when click data is available.

Which approach fits best? (number, or describe your preference)
```

User: `3`

### Interruption Handling

```
[Design Q2/3]
Should we add typo tolerance or synonym expansion?
```

User: "Wait, does Elasticsearch support Chinese tokenization?"

```
Yes — Elasticsearch supports Chinese via the ICU or IK analyzer plugins.
The IK analyzer is more popular for Chinese full-text search.

Ready to continue? We were on [Design Q2/3].
```

### Fast Path

User: "Just give me the full proposal."

```
Here's the complete proposal based on what we've discussed:

## Feature Proposal: Search Relevance Improvement

### Requirements
1. [assumed] Add field boosting (title ×3, description ×1.5, tags ×2)
2. Implement hybrid ranking strategy (boost now, ML re-rank later)
3. [assumed] Add IK analyzer for Chinese tokenization
4. [assumed] Add typo tolerance via fuzziness parameter

Review the assumptions above. Reply with corrections, or confirm to proceed.
```
