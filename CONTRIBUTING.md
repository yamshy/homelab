## Contributing

Thank you for contributing! Please follow these guidelines to help us keep quality high.

### Run validation before commit and PR
- Always run repo validation locally before committing or opening a pull request.
- In this repo, run from the repo root:

```bash
bash scripts/validate.sh
```

- If validation fails, fix the issues before proceeding.
- CI also runs targeted linters to catch regressions early. Re-run them locally when touching the corresponding areas:

    - Shell scripts: install [`shellcheck`](https://www.shellcheck.net/) (e.g., `sudo apt-get install shellcheck` or `brew install shellcheck`) and execute `shellcheck $(git ls-files 'scripts/**/*.sh')`.
    - Talos configuration: install [`talhelper`](https://github.com/budimanjojo/talhelper) (e.g., `mise install talhelper` or download the latest release tarball) and run `talhelper validate talconfig talos/talconfig.yaml --env-file talos/talenv.yaml`.

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