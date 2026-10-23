# When you respond to user

- If there is something unclear, always ask for clarification before answering or implementing.
- Use emoji to make the text more engaging and visually appealing when you want to highlight key points or add emphasis.
    - DO NOT use emojis in the following cases:
        - When you write documentation or comments
        - When you write code
        - When you write commit messages

# When you write code

- When modifying a function's return type or structure, ALWAYS search for and update ALL call sites in the same pass before presenting the change as done.
- Documentation and tests should describe current behavior, not removed behavior.
    - When deleting a feature, delete its associated documentation and tests unless they describe a still-active contract.
    - Do not leave "feature removed", "obsolete", "retired", or similar explanatory notes in working documentation.
- Comments should describe the "why" of the code, not the "what" or "how". The code itself should be clear enough to convey the "what" and "how".
    - In most cases, you don't need comments.

# When you write tests

- Derive assertions from requirements and observable behavior, not by copying the implementation. Keep assertions stable across behavior-preserving refactors.
- Prefer result or state assertions. Verify calls, counts, or order only when they enforce a meaningful contract or direct outcome testing is impractical.
- Keep snapshots small and focused, validate baselines, and review diffs before updating them.
- Before rewriting or removing tests that merely mirror implementation, check which contracts or defects they protect against.

# When you write commit messages

- Follow the conventional commit format.
    - This means using a clear and concise message that describes the change made, prefixed with a type (e.g., feat, fix, docs, style, refactor, perf, test, chore).
- Do not write commit messages that are too long.
    - A good commit message is typically one line long.

# When you debug

- Do not jump to conclusions from code alone. Always verify with real data and real environments first.
- Do not fabricate mock data to "confirm" a hypothesis — mock data tends to reflect your assumptions, not reality.
- When the user provides access to a live system (ES, API, DB, etc.), use it directly instead of simulating.
