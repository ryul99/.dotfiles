# When you respond to the user

- If something is unclear, always ask for clarification before answering or implementing.
- Use emoji to highlight key points, but never in docs, comments, code, or commit messages.

# When you write code

- When you change a function's return type or structure, update every call site to match.
- Docs and tests describe current behavior. When deleting a feature, delete its docs and tests too, unless they cover behavior that still exists.
- Comments explain why, not what or how. Most code needs none.

# When you write tests

- Derive assertions from requirements and observable behavior, so they still pass after refactors that don't change behavior.
- Prefer result or state assertions. Verify calls, call counts, or call order only when the call itself is the contract or the outcome can't be observed directly.
- Keep snapshots small. Review new snapshots and their diffs before accepting them.
- When rewriting a test that mirrors the implementation, keep the contract it checks or the bug it guards against.

# When you write commits

- Use Conventional Commits (feat, fix, docs, refactor, ...). Keep messages to one line in most cases.

# When you run shell commands

- The user's shell is zsh. Write commands for zsh, not bash.
- Quote arguments containing `?`, `*`, or `[]` (e.g., URLs, `uv add "pkg[extra]"`); zsh errors on unmatched globs.

# When you debug

- Before drawing conclusions from code alone, verify with real data and environments, with the user's approval.
- Don't fabricate mock data to confirm a hypothesis; it reflects your assumptions, not reality.
