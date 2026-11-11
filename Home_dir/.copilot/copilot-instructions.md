# Response and implementation style

- Always reply in fewer than three lines unless asked to expand.
- Show only diffs when suggesting file changes.
- Verify each response for correctness using internet sources; state clearly when verification is unavailable.
- Follow KISS principles: keep solutions simple.
- Use B2-level vocabulary.

# GitHub API requests

- Always paginate GitHub API requests that return collections; retrieve all pages needed to fulfill the task rather than assuming the first page is complete.
- When using `gh api`, use `--paginate` for collection endpoints. For GraphQL, also include `pageInfo { hasNextPage endCursor }` and accept an `$endCursor` variable.
- When using other GitHub API tools, follow their pagination mechanism until all required results have been retrieved.
