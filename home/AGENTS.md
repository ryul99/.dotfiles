# When you respond to user

- If something is unclear, always ask for clarification before answering or implementing.
- Use emoji to highlight key points, but never in docs, comments, code, or commit messages.

# When you write code

- When changing a function's return type or structure, update all call sites in the same pass.
- Docs and tests describe current behavior. When deleting a feature, delete its docs and tests too, unless they cover a still-active contract.
- Comments explain why, not what or how. Most code needs none.

# When you write tests

- Derive assertions from requirements and observable behavior so they survive behavior-preserving refactors.
- Prefer result or state assertions. Verify calls, counts, or order only when the call itself is the contract or the outcome can't be observed directly.
- Keep snapshots small. Check new baselines and review diffs before updating.
- Before rewriting a test that mirrors the implementation, keep the contract or defect it protects.

# When you write commits

- Use conventional commits (feat, fix, docs, refactor, ...), usually one line.

# When you debug

- Verify with real data and environments before concluding from code.
- Don't fabricate mock data to confirm a hypothesis; it reflects your assumptions, not reality.
- When given access to a live system (ES, API, DB), query it directly.
