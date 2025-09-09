## Rule: Always run tests before committing or opening a PR

Purpose: Ensure code quality stays high and prevent breaking changes from entering the main branch.

### What Cursor agents must do
- Run the full test suite locally before creating commits or opening pull requests.
- If tests fail, do not proceed with committing or opening a PR. Fix failures first.
- For monorepos or multi-package repos, run tests for all impacted packages/modules.
- If the repository genuinely has no tests, explicitly note this in the commit/PR description and explain how the change was validated.

### Common commands (examples)
- Node.js: `npm test` (or `pnpm test`, `yarn test`)
- Python: `pytest`
- Go: `go test ./...`
- Rust: `cargo test`
- Make: `make test`

### CI enforcement
- CI will run tests on pull requests. Keep the main branch green.
- Do not bypass CI failures without an explicit, reviewed justification.

### Notes for automation
- Prefer non-interactive flags and deterministic installs (e.g., `npm ci`, pinned deps) where possible.
- Surface a short summary of test results in your commit/PR message body when helpful.
