## Rule: Always run tests before committing or opening a PR

Purpose: Ensure code quality stays high and prevent breaking changes from entering the main branch.

### What Cursor agents must do
- Run repository validation locally before creating commits or opening pull requests.
- In this repo, run: `bash scripts/validate.sh` from the repo root.
- If validation fails, do not proceed with committing or opening a PR. Fix failures first.
- For changes spanning multiple overlays, ensure all impacted overlays pass validation.

### Common commands in this repository
- Kustomize build + kubeconform: `bash scripts/validate.sh`

### CI enforcement
- CI runs kubeconform and flux-local on pull requests. Keep the main branch green.
- Do not bypass CI failures without an explicit, reviewed justification.

### Notes for automation
- Prefer non-interactive flags and deterministic installs (e.g., `npm ci`, pinned deps) where possible.
- Surface a short summary of test results in your commit/PR message body when helpful.
