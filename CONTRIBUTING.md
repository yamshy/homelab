## Contributing

Thank you for contributing! Please follow these guidelines to help us keep quality high.

### Run validation before commit and PR
- Always run repo validation locally before committing or opening a pull request.
- In this repo, run from the repo root:

```bash
bash scripts/validate.sh
```

- If validation fails, fix the issues before proceeding.

### Helm chart source placement
- Co-locate chart sources with the app’s HelmRelease in the same file (`app/helmrelease.yaml`) as a second YAML document (`---`) when adding new apps.
  - For HTTP charts: add a `HelmRepository` next to the `HelmRelease`.
  - For OCI charts: add an `OCIRepository` next to the `HelmRelease` (unless the app already uses a central shared `OCIRepository`).
- Only add repositories under `kubernetes/flux/meta/repos` if the repository is truly cluster-wide and intentionally shared by multiple apps.
- Put the repository object in the same namespace as the `HelmRelease`.
- Keep all Helm values in `app/helm/values.yaml` and use `spec.valuesFrom` in the `HelmRelease`.
- See AGENTS.md for full templates and details.

### Pull requests
- Keep PRs focused and describe the rationale and testing steps.
- Ensure CI is green; do not merge on red.
- Update documentation and examples as needed.

### Commit messages
- Use clear, imperative subject lines (e.g., "Add X", "Fix Y").
- Reference related issues where applicable.