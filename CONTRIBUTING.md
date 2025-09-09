## Contributing

Thank you for contributing! Please follow these guidelines to help us keep quality high.

### Run tests before commit and PR
- Always run the full test suite locally before committing or opening a pull request.
- If tests fail, fix the issues before proceeding.
- If the repository has multiple packages/modules, ensure tests are run for all affected parts.

Common commands (adjust to your stack):

```bash
# Node.js
npm ci && npm test

# Python
python -m pip install --upgrade pip
pip install -r requirements.txt 2>/dev/null || true
pip install -e . 2>/dev/null || true
pytest -q

# Go
go test ./...

# Rust
cargo test

# Make
make test
```

### Pull requests
- Keep PRs focused and describe the rationale and testing steps.
- Ensure CI is green; do not merge on red.
- Update documentation and examples as needed.

### Commit messages
- Use clear, imperative subject lines (e.g., "Add X", "Fix Y").
- Reference related issues where applicable.